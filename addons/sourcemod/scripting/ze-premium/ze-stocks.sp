stock int GetTeamAliveCount(int iTeamNum)
{
	int iCount;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	if (IsClientInGame(iClient) && GetClientTeam(iClient) == iTeamNum && IsPlayerAlive(iClient))
		iCount++;
	return iCount;
}

stock int GetHumanAliveCount()
{
	int iCount;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	if (IsClientInGame(iClient) && g_bInfected[iClient] == false && IsPlayerAlive(iClient))
		iCount++;
	return iCount;
}

stock int GetZombieAliveCount()
{
	int iCount;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	if (IsClientInGame(iClient) && g_bInfected[iClient] == true && IsPlayerAlive(iClient))
		iCount++;
	return iCount;
}

stock bool IsValidClient(int client, bool bots = true, bool dead = true)
{
	if (client <= 0)
		return false;
	
	if (client > MaxClients)
		return false;
	
	if (!IsClientInGame(client))
		return false;
	
	if (IsFakeClient(client) && !bots)
		return false;
	
	if (IsClientSourceTV(client))
		return false;
	
	if (IsClientReplay(client))
		return false;
	
	if (!IsPlayerAlive(client) && !dead)
		return false;
	
	return true;
}

stock int SetReserveAmmo(int client, int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
	
	int ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammotype == -1)return;
	
	SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}

stock int SetClipAmmo(int client, int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iClip1", ammo);
	SetEntProp(weapon, Prop_Send, "m_iClip2", ammo);
}

stock int GetRandomsPlayer(bool alive = true)
{
	int[] clients = new int[MaxClients];
	int clientCount;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i, _, !alive))
			continue;
		
		if (g_bInfected[i] != false)
			continue;
		
		if (g_bWasFirstInfected[i] != false)
			continue;
		
		clients[clientCount++] = i;
	}
	
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount - 1)];
}

stock bool IsClientAdmin(int client)
{
	return CheckCommandAccess(client, "", ADMFLAG_BAN);
}

stock bool IsClientLeader(int client)
{
	return CheckCommandAccess(client, "", ADMFLAG_CUSTOM1);
}

stock bool IsClientVIP(int client)
{
	return CheckCommandAccess(client, "", ADMFLAG_RESERVATION);
}

//TAKING GUNS ZOMBIES
public Action OnWeaponCanUse(int client, int weapon)
{
	if (ZR_IsClientZombie(client))
		return Plugin_Continue;
	
	char sWeapon[8];
	GetEntityNetClass(weapon, sWeapon, sizeof(sWeapon));
	if(!strncmp(sWeapon, "CKnife", 6))
		return Plugin_Continue;
	return Plugin_Handled;
}

public int SpawnMarker(int client, char[] sprite)
{
	if (!IsPlayerAlive(client))
	{
		return -1;
	}
	
	float Origin[3];
	GetClientEyePosition(client, Origin);
	Origin[2] += 25.0;
	
	int Ent = CreateEntityByName("env_sprite");
	if (!Ent)return -1;
	DispatchKeyValue(Ent, "model", sprite);
	DispatchKeyValue(Ent, "classname", "env_sprite");
	DispatchKeyValue(Ent, "spawnflags", "1");
	DispatchKeyValue(Ent, "scale", "0.1");
	DispatchKeyValue(Ent, "rendermode", "1");
	DispatchKeyValue(Ent, "rendercolor", "255 255 255");
	DispatchSpawn(Ent);
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);
	return Ent;
}

public int AttachSprite(int client, char[] sprite) //https://forums.alliedmods.net/showpost.php?p=1880207&postcount=5
{
	if (!IsPlayerAlive(client))
	{
		return -1;
	}
	
	char iTarget[16], sTargetname[64];
	GetEntPropString(client, Prop_Data, "m_iName", sTargetname, sizeof(sTargetname));
	
	Format(iTarget, sizeof(iTarget), "Client%d", client);
	DispatchKeyValue(client, "targetname", iTarget);
	
	float Origin[3];
	GetClientEyePosition(client, Origin);
	Origin[2] += 45.0;
	
	int Ent = CreateEntityByName("env_sprite");
	if (!Ent)return -1;
	
	DispatchKeyValue(Ent, "model", sprite);
	DispatchKeyValue(Ent, "classname", "env_sprite");
	DispatchKeyValue(Ent, "spawnflags", "1");
	DispatchKeyValue(Ent, "scale", "0.1");
	DispatchKeyValue(Ent, "rendermode", "1");
	DispatchKeyValue(Ent, "rendercolor", "255 255 255");
	DispatchSpawn(Ent);
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(iTarget);
	AcceptEntityInput(Ent, "SetParent", Ent, Ent, 0);
	
	DispatchKeyValue(client, "targetname", sTargetname);
	
	return Ent;
}

public void RemoveSprite(int client)
{
	if (i_spriteEntities[client] != -1 && IsValidEdict(i_spriteEntities[client]))
	{
		char m_szClassname[64];
		GetEdictClassname(i_spriteEntities[client], m_szClassname, sizeof(m_szClassname));
		if (strcmp("env_sprite", m_szClassname) == 0)
			AcceptEntityInput(i_spriteEntities[client], "Kill");
	}
	i_spriteEntities[client] = -1;
}

public void RemoveMarker(int client)
{
	if (i_markerEntities[client] != -1 && IsValidEdict(i_markerEntities[client]))
	{
		char m_szClassname[64];
		GetEdictClassname(i_markerEntities[client], m_szClassname, sizeof(m_szClassname));
		if (strcmp("env_sprite", m_szClassname) == 0)
			AcceptEntityInput(i_markerEntities[client], "Kill");
	}
	i_markerEntities[client] = -1;
}

void CheckTimer()
{
	if(0 < i_Infection && i_Infection <= 10)	{
		char sBuffer[20];
		FormatEx(sBuffer, sizeof sBuffer, "ze_premium/%i.mp3", i_Infection);
		EmitSoundToAll(sBuffer);
	}
}

void CheckTeam(int client)
{
	int T = GetTeamClientCount(2);
	int CT = GetTeamClientCount(3);
	if (CT > T)
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			CS_SwitchTeam(client, CS_TEAM_T);
		}
	}
	
	if (T > CT)
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			CS_SwitchTeam(client, CS_TEAM_CT);
		}
	}
}

void DisableAll(int client)
{
	g_bInfected[client] = false;
	i_typeofsprite[client] = 0;
	i_Maximum_Choose[client] = 0;
	g_bBeacon[client] = false;
	g_bIsLeader[client] = false;
	spended[client] = 0;
	i_Power[client] = 0;
	f_causeddamage[client] = 0.0;
	g_bUltimate[client] = false;
	i_respawn[client] = 0;
	g_bNoRespawn[client] = false;
}

void DisableTimers(int client)
{
	if(g_bBeacon[client] == true)
	{
		if (H_Beacon[client] != INVALID_HANDLE)
		{
			delete H_Beacon[client];
		}
	}
	if(H_Respawntimer[client] != INVALID_HANDLE)
	{
		delete H_Respawntimer[client];
	}
}

void SetZombie(int client, bool respawn = false, bool first = false, bool nemesis = false)
{
	g_bInfected[client] = true;
	EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
	if (respawn == true)
	{
		CS_SwitchTeam(client, CS_TEAM_T);
		CS_RespawnPlayer(client);
	}
	if (g_bIsLeader[client] == true)
	{
		g_bIsLeader[client] = false;
		CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "leader_died", client);
	}
	if (first && spended[client] > 0)
	{
		int money = GetEntProp(client, Prop_Send, "m_iAccount");
		SetEntProp(client, Prop_Send, "m_iAccount", money + spended[client]);
	}
	DisableTimers(client);
	DisableSpells(client);
	if(nemesis)	ApplyPlayerZombieClass(client, gZombieNemesis);
	else	SetPlayerAsZombie(client);
	if (gRoundType == ROUND_RIOT && g_cZEZombieShieldType.IntValue > 0)
	{
		GivePlayerItem2(client, "weapon_shield");
	}
}

void HumanPain(int victim)
{
	i_pause[victim]++;
	if (i_pause[victim] >= 2)
	{
		i_pause[victim] = 0;
		int hit = GetRandomInt(1, 4);
		if (hit == 1)
		{
			EmitSoundToAll("ze_premium/ze-humanpain.mp3", victim);
		}
		else
		{
			char soundPath[PLATFORM_MAX_PATH];
			Format(soundPath, sizeof(soundPath), "ze_premium/ze-humanpain%i.mp3", hit);
			EmitSoundToAll(soundPath, victim);
		}
	}
}

void ZombiePain(int victim)
{
	i_pause[victim]++;
	if (i_pause[victim] >= 5)
	{
		i_pause[victim] = 0;
		if (!strcmp(gPlayerZombieClass[victim].ident, gZombieNemesis.ident))
		{
			int hit = GetRandomInt(1, 3);
			if (hit == 1)
			{
				EmitSoundToAll("ze_premium/ze-nemesispain.mp3", victim);
			}
			else
			{
				char soundPath[PLATFORM_MAX_PATH];
				Format(soundPath, sizeof(soundPath), "ze_premium/ze-nemesispain%i.mp3", hit);
				EmitSoundToAll(soundPath, victim);
			}
		}
		else
		{
			int hit = GetRandomInt(1, 6);
			if (hit == 1)
			{
				EmitSoundToAll("ze_premium/ze-pain.mp3", victim);
			}
			else
			{
				char soundPath[PLATFORM_MAX_PATH];
				Format(soundPath, sizeof(soundPath), "ze_premium/ze-pain%i.mp3", hit);
				EmitSoundToAll(soundPath, victim);
			}
		}
	}
}

public Action SoundHook(int clients[64], int &numClients, char sound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (entity != -1 && !strncmp(sound, "weapons/knife/knife_", 20) && g_cZEZombieSounds.IntValue > 0)
	{
		char sBuffer[8];
		GetEntityNetClass(entity, sBuffer, sizeof sBuffer);
		if(strncmp(sBuffer, "CKnife", 6))	return Plugin_Continue;
		static int offset = -1;
		if(offset == -1)	offset = FindDataMapInfo(entity, "m_hOwner");
		int player = GetEntDataEnt2(entity, offset);
		if (player != -1 && g_bInfected[player] == true)
		{
			if (!strncmp(sound[20], "hit", 3))
			{
				if(sound[23] == '_')	strcopy(sound, sizeof sound, "ze_premium/ze-wallhit.mp3");
				else	FormatEx(sound, sizeof(sound), "ze_premium/ze-zombiehit%i.mp3", GetRandomInt(1, 4));
				return Plugin_Changed;
			}
			else if (!strncmp(sound[20], "slash", 5))
			{
				FormatEx(sound, sizeof sound, "ze_premium/ze-slash%i.mp3", GetRandomInt(1, 6));
				return Plugin_Changed;
			}
			else if (!strncmp(sound[20], "stab", 4))
			{
				strcopy(sound, sizeof sound, "ze_premium/ze-stab.mp3");
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public void StopMapMusic()
{
	//wtf
	char sSound[PLATFORM_MAX_PATH];
	int entity = INVALID_ENT_REFERENCE;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i)) { continue; }
		for (int u = 0; u < g_iNumSounds; u++) {
			entity = EntRefToEntIndex(g_iSoundEnts[u]);
			if (entity != INVALID_ENT_REFERENCE) {
				GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
				Client_StopSound(i, entity, SNDCHAN_STATIC, sSound);
			}
		}
	}
}

void Client_StopSound(int client, int entity, int channel, const char[] name)
{
	EmitSoundToClient(client, name, entity, channel, SNDLEVEL_NONE, SND_STOP, 0.0, SNDPITCH_NORMAL, _, _, _, true);
}

public void Command_DataUpdate(int client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		char szSteamId[32], szQuery[512];
		GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
		
		g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM ze_premium_sql WHERE steamid='%s'", szSteamId);
		g_hDatabase.Query(szQueryUpdateData, szQuery, GetClientUserId(client));
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

public bool FilterTarget(int entity, int contentsMask, any data)
{
	return (data == entity);
}

void LightCreate(int grenade, float pos[3])
{
	int iEntity = CreateEntityByName("light_dynamic");
	DispatchKeyValue(iEntity, "inner_cone", "0");
	DispatchKeyValue(iEntity, "cone", "80");
	DispatchKeyValue(iEntity, "brightness", "1");
	DispatchKeyValueFloat(iEntity, "spotlight_radius", 150.0);
	DispatchKeyValue(iEntity, "pitch", "90");
	DispatchKeyValue(iEntity, "style", "1");
	switch (grenade)
	{
		case SMOKE : 
		{
			DispatchKeyValue(iEntity, "_light", "75 75 255 255");
			DispatchKeyValueFloat(iEntity, "distance", g_cZEInfnadedistance.FloatValue);
			CreateTimer(0.2, Delete, iEntity, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	DispatchSpawn(iEntity);
	TeleportEntity(iEntity, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(iEntity, "TurnOn");
}

//TRAIL GRENADE
public void Grenade_SpawnPost(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (client == -1)return;
	
	char classname[64];
	GetEdictClassname(entity, classname, 64);
	
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
			CreateTimer(1.3, CreateEvent_DecoyDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (!strcmp(classname, "smokegrenade_projectile"))
	{
		if (g_cZESmokeEffect.IntValue == 1)
		{
			BeamFollowCreate(entity, SmokeColor);
			CreateTimer(1.3, CreateEvent_SmokeDetonate, entity, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

//SMOKE GRENADE
void SmokeInfection(int client, float origin[3])
{
	#pragma unused client
	origin[2] += 10.0;
	
	int infectedplayers;
	float targetOrigin[3];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || ZR_IsClientZombie(i))
		{
			continue;
		}
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= g_cZEInfnadedistance.FloatValue)
		{
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
			{
				if(infectedplayers < 3)
				{
					int randominf = GetRandomInt(1, 5);
					char soundPath[PLATFORM_MAX_PATH];
					Format(soundPath, sizeof(soundPath), "ze_premium/ze-infected%i.mp3", randominf);
					EmitSoundToAll(soundPath, i);
					infectedplayers++;
					if (g_cZEInfectionNadeEffect.IntValue > 0)
					{
						SetZombie(i, false);
					}
					else
					{
						SetZombie(i, true);
					}
				}
				CloseHandle(trace);
			}
			
			else
			{
				CloseHandle(trace);
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
				
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
				
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
				{
					if(infectedplayers < 3)
					{
						int randominf = GetRandomInt(1, 5);
						char soundPath[PLATFORM_MAX_PATH];
						Format(soundPath, sizeof(soundPath), "ze_premium/ze-infected%i.mp3", randominf);
						EmitSoundToAll(soundPath, i);
						infectedplayers++;
						if (g_cZEInfectionNadeEffect.IntValue > 0)
						{
							SetZombie(i, false);
						}
						else
						{
							SetZombie(i, true);
						}
					}
				}
				
				CloseHandle(trace);
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, g_cZEInfnadedistance.FloatValue, g_iBeamSprite, g_iHaloSprite, 1, 1, 0.2, 100.0, 1.0, SmokeColor, 0, 0);
	CreateTimer(1.0, EndOfRound);
	TE_SendToAll();
	LightCreate(SMOKE, origin);
}

//FREEZE GRENADE
void FlashFreeze(int client, float origin[3])
{
	#pragma unused client
	origin[2] += 10.0;
	
	float targetOrigin[3];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || ZR_IsClientHuman(i))
		{
			continue;
		}
		
		GetClientAbsOrigin(i, targetOrigin);
		targetOrigin[2] += 2.0;
		if (GetVectorDistance(origin, targetOrigin) <= g_cZEFreezenadedistance.FloatValue)
		{
			Handle trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
			
			if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
			{
				SetEntityRenderColor(i, 0, 191, 255);
				SetEntityMoveType(i, MOVETYPE_NONE);
				CreateTimer(5.0, Timer_Unfreeze, GetClientUserId(i));
				CloseHandle(trace);
			}
			
			else
			{
				CloseHandle(trace);
				
				GetClientEyePosition(i, targetOrigin);
				targetOrigin[2] -= 2.0;
				
				trace = TR_TraceRayFilterEx(origin, targetOrigin, MASK_SOLID, RayType_EndPoint, FilterTarget, i);
				
				if ((TR_DidHit(trace) && TR_GetEntityIndex(trace) == i) || (GetVectorDistance(origin, targetOrigin) <= 100.0))
				{
					SetEntityRenderColor(i, 0, 191, 255);
					SetEntityMoveType(i, MOVETYPE_NONE);
					CreateTimer(5.0, Timer_Unfreeze, GetClientUserId(i));
				}
				
				CloseHandle(trace);
			}
		}
	}
	
	TE_SetupBeamRingPoint(origin, 10.0, g_cZEFreezenadedistance.FloatValue, g_iBeamSprite, g_iHaloSprite, 1, 1, 0.2, 100.0, 1.0, FlashColor, 0, 0);
	TE_SendToAll();
	LightCreate(SMOKE, origin);
}

void BeamFollowCreate(int entity, int color[4])
{
	TE_SetupBeamFollow(entity, g_iBeamSprite, 0, 1.0, 10.0, 10.0, 5, color);
	TE_SendToAll();
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

void DisableSpells(int client)
{
	g_bBeacon[client] = false;
	i_Power[client] = 0;
	f_causeddamage[client] = 0.0;
	g_bUltimate[client] = false;
	if(g_bIsLeader[client] == true)
	{
		g_bIsLeader[client] = false;
		CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "leader_died", client);
	}
}

void RemoveGuns(int client)
{
	int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	if (IsValidEdict(primweapon) && primweapon != -1)
	{
		RemoveEdict(primweapon);
	}
	
	int secweapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (IsValidEdict(secweapon) && secweapon != -1)
	{
		RemoveEdict(secweapon);
	}
	
	RemoveNades(client);
}

stock int RemoveNades(int iClient)
{
	while (RemoveWeaponBySlot(iClient, 3)) {  }
	for (new i = 0; i < 6; i++)
	SetEntProp(iClient, Prop_Send, "m_iAmmo", 0, _, g_iaGrenadeOffsets[i]);
}

stock bool RemoveWeaponBySlot(int iClient, int iSlot)
{
	int iEntity = GetPlayerWeaponSlot(iClient, iSlot);
	if (IsValidEdict(iEntity)) {
		RemovePlayerItem(iClient, iEntity);
		AcceptEntityInput(iEntity, "Kill");
		return true;
	}
	return false;
}

// Show overlay to all clients with lifetime | 0.0 = no auto remove
stock void ShowOverlayAll(char[] path, float lifetime)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i))
			continue;
		
		ClientCommand(i, "r_screenoverlay \"%s.vtf\"", path);
		
		if (lifetime != 0.0)
			CreateTimer(lifetime, DeleteOverlay, GetClientUserId(i));
	}
}

// Remove overlay from a client - Timer!
stock Action DeleteOverlay(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
		return;
	
	ClientCommand(client, "r_screenoverlay \"\"");
}

public Action CS_OnBuyCommand(int iClient, const char[] chWeapon)
{
    if(StrEqual(chWeapon, "smokegrenade") || StrEqual(chWeapon, "incgrenade") || StrEqual(chWeapon, "molotov") || StrEqual(chWeapon, "flashbang") || StrEqual(chWeapon, "hegrenade") || StrEqual(chWeapon, "decoy") || StrEqual(chWeapon, "g3sg1") || StrEqual(chWeapon, "scar20")) 
    {
        return Plugin_Handled; // Block the buy.
    }
    
    return Plugin_Continue; // Continue as normal.
} 

public Action Command_PowerH(int client, const char[] command, int args)
{
    if(IsValidClient(client, _, false) && g_bInfected[client] == false)
	{
    	if(g_bUltimate[client] == true)
    	{
			i_Power[client] = gPlayerHumanClass[client].power;
			if (i_Power[client])
			{
				if(1 < i_Power[client] && i_Power[client] <= 3)	{
					H_AmmoTimer[client] = CreateTimer(1.0, PowerOfTimer, client, TIMER_REPEAT);
				}
				CreateTimer(6.0, EndPower, client);
				PrintToChatAll(" \x04[ZE-Class]\x01 Player \x06%N\x01 activated his ultimate power!", client);
				PrintHintText(client, "\n<font class='fontSize-l'><font color='#00FF00'>[ZE-Class]</font> <font color='#FFFFFF'>You activated:</font> <font color='#FF8C00'>%s", GetPowerName(i_Power[client]));
				EmitSoundToAll("ze_premium/ze-powereffect.mp3", client);
				g_bUltimate[client] = false;
			}
		}
		else
		{
			PrintToChat(client, " \x04[ZE-Class]\x01 Your ultimate power is \x07not\x01 ready !");
		}
	}
}

stock int CheckPlayerRange(int client)
{
	for (int i; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsValidClient(client))
		{
			if (i != client && IsPlayerAlive(i) && IsPlayerAlive(client))
			{
				if(g_bInfected[i] == false && g_bInfected[client] == false)
				{
					float iOrigin[3];
					GetClientAbsOrigin(client, iOrigin);
					float fOrigin[3];
					GetClientAbsOrigin(i, fOrigin);
					if (GetVectorDistance(iOrigin, fOrigin) <= 200)
					{
						iOrigin[2] += 30.0;
						fOrigin[2] += 30.0;
						SetEntityHealth(i, GetClientHealth(i) + 5);
						TE_SetupBeamPoints(iOrigin, fOrigin, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 0.33, 0.33, 10, 0.5, {0, 255, 0, 255}, 0);
						TE_SendToAll();
					}
				}
			}
		}
	}
	return false;
}

stock int GetPowerIDByName(const char[] name)	{
	if(!strcmp(name, "SuperKnockback")) return 1;
	if(!strcmp(name, "Healing")) return 2;
	if(!strcmp(name, "Unlimited")) return 3;
	return 0;
}

stock char[] GetPowerName(int power)	{
	char sBuffer[16];
	switch(power)	{
		case 0: strcopy(sBuffer, sizeof sBuffer, "SuperKnockback");
		case 1: strcopy(sBuffer, sizeof sBuffer, "Healing");
		case 2: strcopy(sBuffer, sizeof sBuffer, "Unlimited");
		default: sBuffer[0] = 0;
	}
	return sBuffer;
}

stock StripPlayer(int client)	{
	static int offset = -1;
	static int size;

	if(offset != -1)	{
		offset = FindDataMapInfo(client, "m_hMyWeapons");
		size = GetEntPropArraySize(client, Prop_Data, "m_hMyWeapons");
	}

	int weapon;
	for(int i = 0;i!=size;i++)	{
		weapon = GetEntDataEnt2(client, offset + i * 4);
		if(weapon != -1)	{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);
		}
	}
}

stock void EraseArrayItem(int item, any[] data, int &count)	{
	count--;
	for(int i = item;i!=count;)	{
		data[i] = data[i++];
	}
}

stock int FindPlayerWeapon(int client, const char[] weaponname)	{
	static int offset = -1;
	static int size;

	if(offset != -1)	{
		offset = FindDataMapInfo(client, "m_hMyWeapons");
		size = GetEntPropArraySize(client, Prop_Data, "m_hMyWeapons");
	}

	int weapon;
	char classname[32];
	for(int i = 0;i!=size;i++)	{
		weapon = GetEntDataEnt2(client, offset + i * 4);
		if(weapon != -1)	{
			GetEdictClassname(weapon, classname, sizeof classname);
			if(!strcmp(weaponname, classname))	return weapon;
		}
	}
	return -1;
}

stock int GivePlayerNade(int client, const char[] item)	{
	int nade = FindPlayerWeapon(client, item);
	if(nade != -1)	{
		int ammotype = GetEntProp(nade, Prop_Data, "m_iPrimaryAmmoType");
		if(ammotype != -1)	{
			SetEntProp(client, Prop_Send, "m_iAmmo", GetEntProp(client, Prop_Send, "m_iAmmo", .element = ammotype) + 1, .element = ammotype);
		}

		if(HasEntProp(nade, Prop_Send, "m_iPrimaryAmmoCount"))	{
			SetEntProp(nade, Prop_Send, "m_iPrimaryAmmoCount", GetEntProp(nade, Prop_Send, "m_iPrimaryAmmoCount") + 1);
		}
		return nade;
	}
	return GivePlayerItem2(client, item);
}

stock int GivePlayerItem2(int client, const char[] item)	{
	if(IsWeaponNade(item[7]))	return GivePlayerNade(client, item);
	int tmp = GivePlayerItem(client, item);
	if(tmp != -1 && GetEntPropEnt(tmp, Prop_Data, "m_hOwner") == -1)
		EquipPlayerWeapon(client, tmp);
	return tmp;
}

stock bool IsWeaponNade(const char[] weapon)	{
	switch(CS_AliasToWeaponID(weapon))	{
		case	CSWeapon_HEGRENADE,
				CSWeapon_SMOKEGRENADE,
				CSWeapon_FLASHBANG,
				CSWeapon_INCGRENADE,
				CSWeapon_MOLOTOV,
				CSWeapon_TAGGRENADE,
				CSWeapon_FIREBOMB,
				CSWeapon_DIVERSION,
				CSWeapon_FRAGGRENADE,
				CSWeapon_SNOWBALL:	return true;
	}
	return false;
}

void UpdateClientWeaponCookie(int client)	{
	char sBuffer[64];
	int len = strcopy(sBuffer, sizeof sBuffer, Primary_Gun[client]);
	sBuffer[len++] = ';'
	strcopy(sBuffer[len], sizeof sBuffer - len, Secondary_Gun[client]);
	g_hSavedWeapons.Set(client, sBuffer);
}