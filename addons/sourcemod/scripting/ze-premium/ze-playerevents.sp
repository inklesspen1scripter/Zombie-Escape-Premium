public void OnPlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	int numberofplayers = GetTeamClientCount(2) + GetTeamClientCount(3);
	
	if (GameRules_GetProp("m_bWarmupPeriod") != 1 && numberofplayers > g_cZEMinConnectedPlayers.IntValue)
	{
		if (IsValidClient(client))
		{	
			if(g_bInfected[client] == false)
			{
				DisableTimers(client);
				DisableSpells(client);
				int die = GetRandomInt(1, 3);
				if(die == 1)
				{
					EmitSoundToAll("ze_premium/ze-ctdie.mp3", client);
				}
				else
				{
					char soundPath[PLATFORM_MAX_PATH];
					FormatEx(soundPath, sizeof(soundPath), "ze_premium/ze-ctdie%i.mp3", die);
					EmitSoundToAll(soundPath, client);
				}
				g_bInfected[client] = true;
				CS_SwitchTeam(client, CS_TEAM_T);
				SetPlayerAsZombie(client);
				if(i_Infection > 0)
				{
					float nextrespawn = float(i_Infection);
					H_Respawntimer[client] = CreateTimer(nextrespawn, Respawn, client);
				}
				else
				{
					CreateTimer(1.0, Respawn, client);
				}
				if(GetHumanAliveCount() == 0)
				{
					CreateTimer(1.0, EndOfRound);
				}
			}
			else if(g_bInfected[client] == true)
			{
				i_killedzm[attacker]++;
				int die = GetRandomInt(1, 3);
				if(die == 1)
				{
					EmitSoundToAll("ze_premium/ze-die.mp3", client);
				}
				else
				{
					char soundPath[PLATFORM_MAX_PATH];
					FormatEx(soundPath, sizeof(soundPath), "ze_premium/ze-die%i.mp3", die);
					EmitSoundToAll(soundPath, client);
				}
				CreateTimer(1.0, Respawn, client);
				if(GetZombieAliveCount() == 0)
				{
					CreateTimer(1.0, EndOfRound);
				}
			}
		}
	}
	else
	{
		CreateTimer(1.0, Respawn, client);
	}
}

public Action Event_Spawn(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(gEventHook, "userid"));
	if(!iClient)	return;
	
	if(i_Infection > 0)
	{
		SetPlayerAsHuman(iClient);
	}
	else
	{
		if(GetClientTeam(iClient) == CS_TEAM_CT)
		{
			SetPlayerAsHuman(iClient);
		}
		else
		{
			SetZombie(iClient);
		}
	}
	SetEntProp(iClient, Prop_Send, "m_CollisionGroup", 2);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{	
	if(IsValidClient(victim))
	{
		if(damagetype & DMG_FALL)
		{
			return Plugin_Handled;
		}
	}
	
	if (GameRules_GetProp("m_bWarmupPeriod") != 1)
	{
		if(IsValidClient(attacker) && IsValidClient(victim))
		{
			if(attacker != victim && i_Infection == 0)
			{	
				if(g_bInfected[attacker] == false)
				{
					if(g_bUltimate[attacker] == false && gPlayerHumanClass[attacker].power)
					{
						f_causeddamage[attacker] += damage;
					}
					
					if(f_causeddamage[attacker] >= 2000.0)
					{
						PrintHintText(attacker, "\n<font class='fontSize-l'><font color='#00FF00'>[ZE-Class]</font> <font color='#FFFFFF'>Your ultimate power is ready!");
						PrintToChat(attacker, " \x04[ZE-Class]\x01 You have ready your \x0Bultimate power!");
						f_causeddamage[attacker] = 0.0;
						g_bUltimate[attacker] = true;
					}
				}
				
				if(g_bInfected[attacker] == true && g_bInfected[victim] == false)
				{
					if(i_protection[victim] > 0)
					{
						i_protection[victim]--;
						EmitSoundToAll("ze_premium/ze-hit.mp3", victim);
						return Plugin_Handled;
					}
					else
					{
						SetZombie(victim, false);
						EmitSoundToAll("ze_premium/ze-respawn.mp3", victim);
						i_infected[attacker]++;
						CPrintToChat(victim, " \x04[Zombie-Escape]\x01 %t", "infected_by_player", attacker);
						SetEntProp(attacker, Prop_Data, "m_iFrags", GetClientFrags(attacker) + 1);
						CPrintToChat(attacker, " \x04[Zombie-Escape]\x01 %t", "infected_frag", victim);
						Call_StartForward(gF_ClientInfected);
						Call_PushCell(victim);
						Call_PushCell(attacker);
						Call_Finish();

						Event event1 = CreateEvent("player_death");
						event1.SetInt("userid", GetClientUserId(victim));
						event1.SetInt("attacker", GetClientUserId(attacker));
						event1.SetString("weapon", "knife");
						for(int i = MaxClients;i;i--)	{
							if(IsClientInGame(i))	{
								event1.FireToClient(i);
							}
						}
						event1.Close();

						if(GetHumanAliveCount() == 0)
						{
							CreateTimer(1.0, EndOfRound);
						}
					}
				}
			}
		}
	}
	
	if(damagetype & DMG_BLAST)
	{
		if(IsValidClient(victim) && attacker != victim)
		{
			if(ZR_IsClientHuman(victim))
			{
				return Plugin_Handled;
			}
			else if(ZR_IsClientZombie(victim))
			{
				EmitSoundToAll("ze_premium/ze-fire.mp3", victim);
				CreateTimer(3.0, Onfire, victim);
				CreateTimer(5.0, Slowdown, victim);
				IgniteEntity(victim, 5.0);
				SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 0.5);
			}
		}
	}
	return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event,"userid")); // get victim & attacker
	
	if(victim)
	{
		if(GetClientTeam(victim) == CS_TEAM_CT)
		{
			HumanPain(victim);
		}
		else if(GetClientTeam(victim) == CS_TEAM_T)
		{
			ZombiePain(victim);
		}
	}
}

public void WeaponReloadPost(int weapon, bool success)	{
	if(!success)	return;
	int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwner");
	if(client == -1 || ZR_IsClientZombie(client))	return;

	if(g_cZEReloadingSound.BoolValue)	{
		if(GetGameTime() >= gPlayerNextReloadSound[client])	{
			gPlayerNextReloadSound[client] = GetGameTime() + g_cZEReloadingSoundCooldown.FloatValue;
			char soundPath[32];
			FormatEx(soundPath, sizeof(soundPath), "ze_premium/ze-reloading%i.mp3", GetRandomInt(1, 4));
			if(g_cZEReloadingSoundType.BoolValue)
				EmitSoundToAll(soundPath, client);
			else	EmitSoundToClient(client, soundPath);
		}
	}
	SetReserveAmmo(client, weapon, 200);
}