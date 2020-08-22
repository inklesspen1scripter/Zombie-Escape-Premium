public void OnClientDisconnect(int client)
{
	UpdateClientWeaponCookie(client);
	if(g_bAntiDisconnect[client] == true)
	{
		char szSteamId[32], szQuery[512];
		GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
		int newiban = i_infectionban[client] + g_cZEInfectionBans.IntValue;
		g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
		g_hDatabase.Query(SQL_Error, szQuery);
		CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "infected_disconnected", client, newiban);
	}
	i_typeofsprite[client] = 0;
	PrintToChatAll(" \x04[Zombie Escape] \x01Player\x06 %N\x01 has disconnected from the server!", client);
}

public void OnClientConnected(int client)
{
	GetHumanClass(0, gPlayerHumanClass[client]);
	GetZombieClass(0, gPlayerZombieClass[client]);
	gPlayerSelectedClass[client][0] = 0;
	gPlayerSelectedClass[client][1] = 0;

	gWeaponList1.GetString(0, Primary_Gun[client], sizeof Primary_Gun[]);
	gWeaponList2.GetString(0, Secondary_Gun[client], sizeof Secondary_Gun[]);
	i_Maximum_Choose[client] = 0;
	g_bSamegun[client] = false;
	g_bIsLeader[client] = false;
	g_bInfected[client] = false;
	g_bBeacon[client] = false;
	g_bNoRespawn[client] = false;
	g_bAntiDisconnect[client] = false;
	i_respawn[client] = 0;
	i_Power[client] = 0;
	gPlayerNextReloadSound[client] = 0.0;
	gPlayerNextUltimate[client] = 0.0;
	gPlayerUltimateTimer[client] = INVALID_HANDLE;
	H_AmmoTimer[client] = INVALID_HANDLE;

}

public void OnClientPutInServer(int client)	{
	LoadPlayerHooks(client);
	PrintToChatAll(" \x04[Zombie Escape] \x01Player\x06 %N\x01 has join to the server!", client);
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsFakeClient(client))
	{
		CheckDb(client);
	}
	
	if(i_Infection <= 0)
	{
		CreateTimer(1.0, SwitchTeam, GetClientUserId(client));
	}
}

public void OnClientCookiesCached(int client)	{
	char szClass[64];
	int id;
	GetClientCookie(client, g_hZombieClass, szClass, sizeof(szClass));
	id = FindZombieClassID(szClass);
	if(id == -1)
		id = 0;
	gPlayerSelectedClass[client][1] = id;

	GetClientCookie(client, g_hHumanClass, szClass, sizeof(szClass));
	id = FindHumanClassID(szClass);
	if(id == -1)
		id = 0;
	gPlayerSelectedClass[client][0] = id;

	g_hSavedWeapons.Get(client, szClass, sizeof szClass);
	if(szClass[0])	{
		int pos = FindCharInString(szClass, ';');
		if(pos == -1)	return;

		szClass[pos++] = 0;
		strcopy(Primary_Gun[client], sizeof Primary_Gun[], szClass);
		strcopy(Secondary_Gun[client], sizeof Secondary_Gun[], szClass[pos]);
		if(gWeaponList1.FindString(Primary_Gun[client]) == -1)	gWeaponList1.GetString(0, Primary_Gun[client], sizeof Primary_Gun[]);
		if(gWeaponList2.FindString(Secondary_Gun[client]) == -1)	gWeaponList2.GetString(0, Secondary_Gun[client], sizeof Secondary_Gun[]);
	}
}
