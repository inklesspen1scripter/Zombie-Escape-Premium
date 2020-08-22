void LoadCommands()	{
	RegConsoleCmd("sm_menu", CMD_MainMenu);
	RegConsoleCmd("sm_zombieescape", CMD_MainMenu);
	RegConsoleCmd("sm_ze", CMD_MainMenu);
	RegConsoleCmd("sm_zr", CMD_MainMenu);
	RegConsoleCmd("sm_zm", CMD_MainMenu);
	
	RegConsoleCmd("sm_respawn", CMD_Respawn);
	RegConsoleCmd("sm_r", CMD_Respawn);
	RegConsoleCmd("sm_zrespawn", CMD_Respawn);
	
	RegConsoleCmd("sm_get", CMD_GetGun);
	RegConsoleCmd("sm_weapon", CMD_Weapon);
	RegConsoleCmd("sm_weapons", CMD_Weapon);
	RegConsoleCmd("sm_gun", CMD_Weapon);
	RegConsoleCmd("sm_guns", CMD_Weapon);
	
	RegConsoleCmd("sm_class", CMD_Class);
	
	RegConsoleCmd("sm_leader", CMD_Leader);
	
	RegConsoleCmd("sm_zshop", CMD_Shop);
	
	RegConsoleCmd("sm_humanclass", CMD_HumanClass);
	RegConsoleCmd("sm_zombieclass", CMD_ZMClass);
	
	RegConsoleCmd("sm_za", CMD_Admin);
	RegConsoleCmd("sm_zea", CMD_Admin);
	RegConsoleCmd("sm_zadmin", CMD_Admin);
	RegConsoleCmd("sm_zeadmin", CMD_Admin);
	
	RegConsoleCmd("p90", CMD_WeaponAlias);
	RegConsoleCmd("bizon", CMD_WeaponAlias);
	RegConsoleCmd("negev", CMD_WeaponAlias);
	
	RegConsoleCmd("sm_topplayer", CMD_Topplayer);
	RegConsoleCmd("sm_toplayer", CMD_Topplayer);
	RegConsoleCmd("sm_nejhrac", CMD_Topplayer);
	RegConsoleCmd("sm_top10", CMD_Topplayer);
	
	RegConsoleCmd("sm_stats", CMD_Statistic);

	AddCommandListener(Command_PowerH, "+lookatweapon");
	AddCommandListener(Command_CheckJoin, "jointeam");
}

public Action CMD_HumanClass(int client, int args)	{
	ShowPlayerHumanClass(client);
	return Plugin_Handled;
}

public Action CMD_ZMClass(int client, int args)	{
	ShowPlayerZMClass(client);
	return Plugin_Handled;
}

public Action CMD_Weapon(int client, int args)
{
	if (g_bInfected[client] == false)	openWeapons(client);
	else	CReplyToCommand(client, " \x04[Zombie-Escape]\x01 %t", "no_human");
	return Plugin_Handled;
}

public Action CMD_Admin(int client, int args)
{
	if (IsClientAdmin(client))	openAdmin(client);
	return Plugin_Handled;
}

public Action CMD_Class(int client, int args)
{
	openClasses(client);
	return Plugin_Handled;
}

public Action CMD_Shop(int client, int args)
{
	openShop(client);
	return Plugin_Handled;
}

public Action CMD_MainMenu(int client, int args)
{
	openMenu(client);
	return Plugin_Handled;
}

public Action CMD_Respawn(int client, int args)
{
	if (i_Infection > 0 && g_bInfected[client] == false)
	{
		CS_RespawnPlayer(client);
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		CPrintToChat(client, " \x04[ZE-Respawn]\x01 %t", "player_respawned");
	}
	else if(g_bInfected[client] == false && !IsPlayerAlive(client))
	{
		CS_SwitchTeam(client, CS_TEAM_T);
		g_bInfected[client] = true;	
		CS_RespawnPlayer(client);
		EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
	}
	else
	{
		if(g_bInfected[client] == true && i_Infection == 0)
		{
			if(i_respawn[client] < 3)
			{
				CS_RespawnPlayer(client);
				i_respawn[client]++;
				int uses = 3 - i_respawn[client];
				CPrintToChat(client, " \x04[ZE-Respawn]\x01 %t", "zombie_respawned", uses);
				PrintHintText(client, "\n<font class='fontSize-l'><font color='#00FF00'>You have:</font>%i respawns", uses);
			}
		}
	}
	return Plugin_Handled;
}

public Action CMD_Leader(int client, int args)
{
	if (g_bIsLeader[client] == true || IsClientAdmin(client) || IsClientLeader(client))
	{
		openLeader(client);
	}
	else
	{
		CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "no_leader");
	}
	return Plugin_Handled;
}

public Action CMD_WeaponAlias(int client, int args)
{
	if (g_bInfected[client] == false)
	{
		if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
		{
			char sBuffer[32];
			strcopy(sBuffer, sizeof sBuffer, "weapon_");
			GetCmdArg(0, sBuffer[7], sizeof sBuffer - 7);
			ChoosePlayerGun(client, sBuffer[7], true);
			GivePlayerItem2(client, sBuffer);
			i_Maximum_Choose[client]++;
			int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
		}
	}
	return Plugin_Handled;
}

public Action CMD_GetGun(int client, int args)
{
	if (g_bInfected[client] == false)
	{
		if (Primary_Gun[client][0] || Secondary_Gun[client][0])
		{
			if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
			{
				char sBuffer[32];
				strcopy(sBuffer, sizeof sBuffer, "weapon_");
				i_Maximum_Choose[client]++;
				int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
				if (Primary_Gun[client][0])
				{
					strcopy(sBuffer[7], sizeof sBuffer - 7, Primary_Gun[client]);
					GivePlayerItem2(client, sBuffer);
				}
				if (Secondary_Gun[client][0] == 'w')
				{
					strcopy(sBuffer[7], sizeof sBuffer - 7, Primary_Gun[client]);
					int secweapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					if(secweapon != -1 && !IsSpecialItem(secweapon))
						SDKHooks_DropWeapon(client, secweapon, view_as<float>({0.0,0.0,0.0}), view_as<float>({0.0,0.0,0.0}));
					GivePlayerItem(client, sBuffer);
				}
			}
			else
			{
				CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "maxium_usages_gunmenu");
			}
		}
		else
		{
			CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "choose_gun_first");
		}
	}
	else
	{
		CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "no_human");
	}
	return Plugin_Handled;
}

public Action CMD_Topplayer(int client, int args)
{
	g_hDatabase.Query(SQL_QueryToplist, "SELECT * FROM ze_premium_sql ORDER BY humanwins DESC LIMIT 10", GetClientUserId(client));
	return Plugin_Handled;
}

public Action CMD_Statistic(int client, int args)
{
	char szSteamId[32], szQuery[512];
	GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
	
	g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM ze_premium_sql WHERE steamid='%s'", szSteamId);
	
	g_hDatabase.Query(szQueryCallback, szQuery, GetClientUserId(client));
	return Plugin_Handled;
}

public Action Command_PowerH(int client, const char[] command, int args)
{
	RequestPlayerUltimate(client);
	return Plugin_Handled;
}

public Action CS_OnBuyCommand(int iClient, const char[] chWeapon)
{
	if(StrEqual(chWeapon, "smokegrenade") || StrEqual(chWeapon, "incgrenade") || StrEqual(chWeapon, "molotov") || StrEqual(chWeapon, "flashbang") || StrEqual(chWeapon, "hegrenade") || StrEqual(chWeapon, "decoy") || StrEqual(chWeapon, "g3sg1") || StrEqual(chWeapon, "scar20")) 
	{
		return Plugin_Handled; // Block the buy.
	}
	
	return Plugin_Continue; // Continue as normal.
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