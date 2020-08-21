void LoadCommands()	{
	RegConsoleCmd("sm_menu", CMD_MainMenu);
	RegConsoleCmd("sm_zombieescape", CMD_MainMenu);
	RegConsoleCmd("sm_ze", CMD_MainMenu);
	RegConsoleCmd("sm_zr", CMD_MainMenu);
	RegConsoleCmd("sm_zm", CMD_MainMenu);
	
	RegConsoleCmd("sm_respawn", CMD_Respawn);
	RegConsoleCmd("sm_r", CMD_Respawn);
	RegConsoleCmd("sm_zrespawn", CMD_Respawn);
	
	RegConsoleCmd("sm_rifle", CMD_WeaponsRifle);
	RegConsoleCmd("sm_heavygun", CMD_WeaponsHeavy);
	RegConsoleCmd("sm_smg", CMD_WeaponsSmg);
	RegConsoleCmd("sm_pistols", CMD_WeaponsPistols);
	
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
	
	RegConsoleCmd("sm_p90", CMD_P90);
	RegConsoleCmd("sm_bizon", CMD_Bizon);
	RegConsoleCmd("sm_negev", CMD_Negev);
	
	RegConsoleCmd("sm_topplayer", CMD_Topplayer);
	RegConsoleCmd("sm_toplayer", CMD_Topplayer);
	RegConsoleCmd("sm_nejhrac", CMD_Topplayer);
	RegConsoleCmd("sm_top10", CMD_Topplayer);
	
	RegConsoleCmd("sm_stats", CMD_Statistic);

	AddCommandListener(Command_PowerH, "+lookatweapon");
	AddCommandListener(Command_CheckJoin, "jointeam");
}

public Action CMD_WeaponsRifle(int client, int args)	{
	ShowPlayerWeapons(client, "Rifles");
	return Plugin_Handled;
}

public Action CMD_WeaponsHeavy(int client, int args)	{
	ShowPlayerWeapons(client, "Heavyguns");
	return Plugin_Handled;
}

public Action CMD_WeaponsSmg(int client, int args)	{
	ShowPlayerWeapons(client, "Smg");
	return Plugin_Handled;
}

public Action CMD_WeaponsPistols(int client, int args)	{
	ShowPlayerWeapons(client, "Pistols", true);
	return Plugin_Handled;
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
		SetPlayerAsZombie(client);
		EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
		g_bInfected[client] = true;
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

public Action CMD_P90(int client, int args)
{
	if (g_bInfected[client] == false)
	{
		if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
		{
			int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (IsValidEdict(primweapon) && primweapon != -1)
			{
				RemoveEdict(primweapon);
			}
			Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_p90");
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			GivePlayerItem(client, Primary_Gun[client]);
			i_Maximum_Choose[client]++;
			int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
		}
	}
	return Plugin_Handled;
}

public Action CMD_Bizon(int client, int args)
{
	if (g_bInfected[client] == false)
	{
		if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
		{
			int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (IsValidEdict(primweapon) && primweapon != -1)
			{
				RemoveEdict(primweapon);
			}
			Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_bizon");
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			GivePlayerItem(client, Primary_Gun[client]);
			i_Maximum_Choose[client]++;
			int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
		}
	}
	return Plugin_Handled;
}

public Action CMD_Negev(int client, int args)
{
	if (g_bInfected[client] == false)
	{
		if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
		{
			int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (IsValidEdict(primweapon) && primweapon != -1)
			{
				RemoveEdict(primweapon);
			}
			Format(Primary_Gun[client], sizeof(Primary_Gun), "weapon_negev");
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			GivePlayerItem(client, Primary_Gun[client]);
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
		if (Primary_Gun[client][0] == 'w' || Secondary_Gun[client][0] == 'w')
		{
			if (i_Maximum_Choose[client] < g_cZEMaximumUsage.IntValue)
			{
				i_Maximum_Choose[client]++;
				int usages = g_cZEMaximumUsage.IntValue - i_Maximum_Choose[client];
				CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "gun_uses_left", usages);
				if (Primary_Gun[client][0] == 'w')
				{
					int primweapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
					if (IsValidEdict(primweapon) && primweapon != -1)
					{
						RemoveEdict(primweapon);
					}
					GivePlayerItem(client, Primary_Gun[client]);
				}
				if (Secondary_Gun[client][0] == 'w')
				{
					int secweapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
					if(secweapon != -1 && !IsSpecialItem(secweapon))
					{
						RemovePlayerItem(client, secweapon);
						RemoveEdict(secweapon);
					}
					GivePlayerItem(client, Secondary_Gun[client]);
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