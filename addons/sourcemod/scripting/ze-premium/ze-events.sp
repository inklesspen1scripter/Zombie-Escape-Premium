void LoadEvents()	{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("round_end", OnRoundEnd);
	HookEvent("player_spawn", Event_Spawn, EventHookMode_Post);
	HookEvent("player_team", Event_Team, EventHookMode_Post);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("hegrenade_detonate", OnHeGrenadeDetonate);
}

public void Event_Team(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client && IsClientSourceTV(client))	{
		ThrowError("IT IS SOURCETV");
	}	
}
public void OnPlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	int numberofplayers = GetTeamClientCount(2) + GetTeamClientCount(3);
	
	if (GameRules_GetProp("m_bWarmupPeriod") != 1 && numberofplayers > g_cZEMinConnectedPlayers.IntValue)
	{
		if (IsValidClient(client))
		{	
			if(!g_bInfected[client])
			{
				DisableTimers(client);
				DisableSpells(client);
				Sound_EmitToAll("human_die", client);
				g_bInfected[client] = true;
				CS_SwitchTeam(client, CS_TEAM_T);
				if(i_Infection > 0)
				{
					float nextrespawn = float(i_Infection);
					if(H_Respawntimer[client])	delete H_Respawntimer[client];
					H_Respawntimer[client] = CreateTimer(nextrespawn, Respawn, GetClientUserId(client));
				}
				else
				{
					CreateTimer(1.0, Respawn, GetClientUserId(client));
				}
				if(GetHumanAliveCount() == 0)
				{
					CreateTimer(1.0, EndOfRound);
				}
			}
			else
			{
				i_killedzm[attacker]++;
				Sound_EmitToAll("zombie_die", client);
				CreateTimer(1.0, Respawn, GetClientUserId(client));
				if(GetZombieAliveCount() == 0)
				{
					CreateTimer(1.0, EndOfRound);
				}
			}
		}
	}
	else
	{
		CreateTimer(1.0, Respawn, GetClientUserId(client));
	}
}

public Action Event_Spawn(Event gEventHook, const char[] gEventName, bool iDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(gEventHook, "userid"));
	if(!iClient || GetClientTeam(iClient) <= 1)	return;

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

public void OnHeGrenadeDetonate(Handle event, char[] name, bool dontBroadcast)
{
	if (g_cZEHeGrenadeEffect.IntValue == 0)
	{
		return;
	}
	
	float origin[3];
	origin[0] = GetEventFloat(event, "x"); origin[1] = GetEventFloat(event, "y"); origin[2] = GetEventFloat(event, "z");
	
	TE_SetupBeamRingPoint(origin, 10.0, 400.0, g_iBeamSprite, g_iHaloSprite, 1, 1, 0.2, 100.0, 1.0, FragColor, 0, 0);
	TE_SendToAll();
}

public void Event_RoundStart(Event event, const char[] name, bool bDontBroadcast)
{
	gShopMemory.Clear();
	g_bRoundEnd = false;
	i_Infection = g_cZEFirstInfection.IntValue;

	if (H_FirstInfection != INVALID_HANDLE)	KillTimer(H_FirstInfection);
	H_FirstInfection = CreateTimer(1.0, FirstInfection, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	int weapon;
	char sBuffer[32];
	strcopy(sBuffer, sizeof sBuffer, "weapon_");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			ClientCommand(i, "r_screenoverlay \"\"");
			if (IsPlayerAlive(i))
			{	
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
				SetEntProp(i, Prop_Send, "m_CollisionGroup", 2);
				SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
				DisableAll(i);
				SetPlayerAsHuman(i);
				openWeapons(i);
				
				if (g_bSamegun[i] == true)
				{
					if (Primary_Gun[i][0])
					{
						strcopy(sBuffer[7], sizeof sBuffer - 7, Primary_Gun[i]);
						weapon = GetPlayerWeaponSlot(i, CS_SLOT_PRIMARY);
						if(weapon != -1)	{
							RemovePlayerItem(i, weapon);
							RemoveEdict(weapon);
						}
						GivePlayerItem(i, sBuffer);
					}
					if (Secondary_Gun[i][0])
					{
						strcopy(sBuffer[7], sizeof sBuffer - 7, Secondary_Gun[i]);
						weapon = GetPlayerWeaponSlot(i, CS_SLOT_SECONDARY);
						if(weapon != -1)	{
							RemovePlayerItem(i, weapon);
							RemoveEdict(weapon);
						}
						GivePlayerItem(i, sBuffer);
					}
				}
				DisableTimers(i);
			}
		}
	}
}

public void OnRoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int soucet = GetTeamClientCount(2) + GetTeamClientCount(3);
	g_bRoundStarted = false;
	g_bRoundEnd = true;
	g_bMarker = false;
	g_bPause = false;
	gRoundType = ROUND_NORMAL;
	int winner_team = GetEventInt(event, "winner");
	
	if(winner_team == 2)
	{
		Sound_EmitToAll("zombie_win");
	}
	else if(winner_team == 3)
	{
		Sound_EmitToAll("human_win");
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			ClientCommand(i, "r_screenoverlay \"%s.vtf\"", (winner_team == 2) ? ZMWINSMAT : HUMANWINSMAT);
			if(g_bWasFirstInfected[i] == true)
			{
				g_bWasFirstInfected[i] = false;
			}
			
			if(g_bFirstInfected[i] == true)
			{
				g_bFirstInfected[i] = false;
				g_bWasFirstInfected[i] = true;
			}
			
			if(winner_team == 3)
			{ 
				if(g_bInfected[i] == false)
				{
					i_wins[i]++;
				}
			}

			if(i_infectionban[i] > 0 && soucet >= g_cZEInfectionBanPlayers.IntValue)
			{
				char szSteamId[32], szQuery[512];
				GetClientAuthId(i, AuthId_Engine, szSteamId, sizeof(szSteamId));
				int newiban = i_infectionban[i] - 1;
				g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
				g_hDatabase.Query(SQL_Error, szQuery);
			}
			CheckTeam(i);
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
			DisableAll(i);
			DisableTimers(i);
		}
	}
}