void LoadPlayerHooks(int client)	{
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "_projectile") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, Grenade_SpawnPost);
	}
	else if(!strncmp(classname, "weapon_", 7, false))	{
		SDKHook(entity, SDKHook_ReloadPost, WeaponReloadPost);
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

//TRAIL GRENADE
public void Grenade_SpawnPost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (client == -1)return;
	
	char classname[24];
	GetEdictClassname(entity, classname, sizeof classname);
	
	if (!strcmp(classname, "hegrenade_projectile"))
	{
		if (g_cZEHeGrenadeEffect.IntValue == 1)
		{
			BeamFollowCreate(entity, FragColor);
		}
	}
	else if (!strcmp(classname, "decoy_projectile"))
	{
		if (g_cZEFlashbangEffect.IntValue == 1)
		{
			BeamFollowCreate(entity, FlashColor);
			CreateTimer(1.3, CreateEvent_DecoyDetonate, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (!strcmp(classname, "smokegrenade_projectile"))
	{
		if (g_cZESmokeEffect.IntValue == 1)
		{
			BeamFollowCreate(entity, SmokeColor);
			CreateTimer(1.3, CreateEvent_SmokeDetonate, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
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
						Forward_OnClientInfected(victim, attacker);

						Event event1 = CreateEvent("player_death");
						event1.SetInt("userid", GetClientUserId(victim));
						event1.SetInt("attacker", GetClientUserId(attacker));
						event1.SetString("weapon", "knife");
						for(int i = MaxClients;i;i--)	{
							if(IsClientInGame(i) && !IsFakeClient(i))	{
								event1.FireToClient(i);
							}
						}
						event1.Close();

						if(GetHumanAliveCount() == 0)
						{
							CreateTimer(1.0, EndOfRound);
						}
						return Plugin_Handled;
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
				CreateTimer(3.0, Onfire, GetClientUserId(victim));
				CreateTimer(5.0, Slowdown, GetClientUserId(victim));
				IgniteEntity(victim, 5.0);
				SetEntPropFloat(victim, Prop_Data, "m_flLaggedMovementValue", 0.5);
			}
		}
	}
	return Plugin_Continue;
}

//TAKING GUNS ZOMBIES
public Action OnWeaponCanUse(int client, int weapon)
{
	if (ZR_IsClientHuman(client))
		return Plugin_Continue;
	
	char sWeapon[8];
	GetEntityNetClass(weapon, sWeapon, sizeof(sWeapon));
	if(!strncmp(sWeapon, "CKnife", 6))
		return Plugin_Continue;
	return Plugin_Handled;
}