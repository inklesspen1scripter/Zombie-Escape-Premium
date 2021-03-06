void openMenu(int client)
{
	Menu menu = new Menu(mZeHandler);
	
	menu.SetTitle("[Zombie Escape] Main menu:");
	
	menu.AddItem("1", "Weapons");
	if(g_cZECanChoiceClass.IntValue & 3)	menu.AddItem("2", "Zombie/Human classes");
	menu.AddItem("3", "Human/Zombie Shop");
	if(IsClientAdmin(client) || IsClientLeader(client))
	{
		menu.AddItem("4", "Admin menu");
	}
	else
	{
		menu.AddItem("4", "Admin menu [NO ACCESS]", ITEMDRAW_DISABLED);
	}
	menu.AddItem("5", ">Your stats<");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[4];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (szItem[0] == '1')
				{
					if(g_bInfected[client] == false)
					{
						openWeapons(client);
					}
					else
					{
						CReplyToCommand(client, " \x04[ZE-Weapons]\x01 %t", "no_human");
						openMenu(client);
					}
				}
				else if (szItem[0] == '2')
				{
					openClasses(client);
				}
				else if (szItem[0] == '3')
				{
					//openShop(client);
					ShopPlayerShop(client);
				}
				else if (szItem[0] == '4')
				{
					if(IsClientAdmin(client) || IsClientLeader(client))
					{
						openAdmin(client);
					}
				}
				else if (szItem[0] == '5')
				{
					char szSteamId[32], szQuery[512];
					GetClientAuthId(client, AuthId_Engine, szSteamId, sizeof(szSteamId));
					
					g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM ze_premium_sql WHERE steamid='%s'", szSteamId);
					
					g_hDatabase.Query(szQueryCallback, szQuery, GetClientUserId(client));
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

//*****GUNS MENU*****

void openWeapons(int client)
{
	char text[84];
	char sBuffer[32];
	Menu menu = new Menu(mZeGunsHandler);
	menu.SetTitle("[Weapons] Choose a gun:");

	strcopy(sBuffer, sizeof sBuffer, Primary_Gun[client]);
	CS_GetTranslatedWeaponAlias(sBuffer, sBuffer, sizeof sBuffer);
	FormatEx(text, sizeof text, "Primary gun [%s]", sBuffer);
	menu.AddItem("1", text);
	strcopy(sBuffer, sizeof sBuffer, Secondary_Gun[client]);
	CS_GetTranslatedWeaponAlias(sBuffer, sBuffer, sizeof sBuffer);
	FormatEx(text, sizeof text, "Secondary gun [%s]", sBuffer);
	menu.AddItem("2", text);
	
	FormatEx(text, sizeof text, "Same gun next round [%s]", g_bSamegun[client] ? "ON" : "OFF");
	menu.AddItem("5", text);
	menu.AddItem("6", ">Get chosen guns<");
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeGunsHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[4];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (szItem[0] == '1')	ShowPlayerWeapons(client, false);
				else if (szItem[0] == '2')	ShowPlayerWeapons(client, true);
				else if (szItem[0] == '5')
				{
					g_bSamegun[client] = !g_bSamegun[client];
					CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", g_bSamegun[client] ? "samegun_true" : "samegun_false");
					openWeapons(client);
				}
				else if (szItem[0] == '6')	FakeClientCommand(client, "sm_get");
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

//*****HUMAN/ZOMBIE CLASSES*****
void openClasses(int client)
{
	Menu menu = new Menu(mZeClassHandler);
	
	menu.SetTitle("[Classes] Main Menu:");
	
	if(g_cZECanChoiceClass.IntValue & 1)	menu.AddItem("1", "Human class");
	if(g_cZECanChoiceClass.IntValue & 2)	menu.AddItem("2", "Zombie class");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeClassHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[4];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (szItem[0] == '1')	FakeClientCommand(client, "sm_humanclass");
				else if (szItem[0] == '2')	FakeClientCommand(client, "sm_zombieclass");
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

//*****ADMIN MENU*****
void openAdmin(int client)
{
	Menu menu = new Menu(mZeAdminHandler);
	
	menu.SetTitle("[Admin-Menu] Main Menu:");
	
	if(IsClientAdmin(client))
	{
		menu.AddItem("menu1", "Change team");
		if(g_bPause == true)
		{
			menu.AddItem("menu2", "Pause infection timer [ACTIVE]");
		}
		else
		{
			menu.AddItem("menu2", "Pause infection timer");
		}
		menu.AddItem("menu3", "Infection Ban");
	}
	else
	{
		menu.AddItem("menu1", "Change team", ITEMDRAW_DISABLED);
		menu.AddItem("menu2", "Pause infection timer", ITEMDRAW_DISABLED);
		menu.AddItem("menu3", "Infection Ban", ITEMDRAW_DISABLED);
	}
	menu.AddItem("menu4", "Leader");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeAdminHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (!strcmp(szItem, "menu1"))
				{
					openSwapTeam(client);
				}
				else if (!strcmp(szItem, "menu2"))
				{
					if(i_Infection > 0)
					{
						if(g_bPause == false)
						{
							g_bPause = true;
							CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_timer_paused", client);
							openAdmin(client);
						}
						else
						{
							g_bPause = false;
							CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_timer_unpaused", client);
							openAdmin(client);
						}
					}
					else
					{
						CReplyToCommand(client, " \x04[ZE-Admin]\x01 %t", "nextround_infection_timer");
						openAdmin(client);
					}
				}
				else if (!strcmp(szItem, "menu3"))
				{
					openInfectionBan(client);
				}
				else if (!strcmp(szItem, "menu4"))
				{
					openLeader(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openLeader(int client)
{
	Menu menu = new Menu(mZeLeaderHandler);
	
	menu.SetTitle("[Leader] Main Menu:");
	
	if(IsClientAdmin(client))
	{
		menu.AddItem("menu1", "Choose leader");
	}
	menu.AddItem("menu2", "Sprites & Markers");
	if(H_Beacon[client])
	{
		menu.AddItem("menu3", "Beacon [ON]");
	}
	else
	{
		menu.AddItem("menu3", "Beacon [OFF]");
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeLeaderHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if (!strcmp(szItem, "menu1"))
				{
					openChooseLeader(client);
				}
				else if (!strcmp(szItem, "menu2"))
				{
					openSpritesMarkers(client);
				}
				else if (!strcmp(szItem, "menu3"))
				{
					if(H_Beacon[client])
					{
						if (H_Beacon[client] != INVALID_HANDLE)
						{
							delete H_Beacon[client];
							H_Beacon[client] = INVALID_HANDLE;
							CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "beacon_off");
							openLeader(client);
						}
					}
					else
					{
						H_Beacon[client] = CreateTimer(0.2, Timer_Beacon, GetClientUserId(client), TIMER_REPEAT);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "beacon_on");
						openLeader(client);
					}
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openSpritesMarkers(int client)
{
	Menu menu = new Menu(mZeLeaderSpritesHandler);
	
	menu.SetTitle("[Leader] Sprites & Markers:");
	
	if(g_bMarker == true)
	{
		menu.AddItem("menu1", "Defend Marker [ACTIVE]");
	}
	else
	{
		menu.AddItem("menu1", "Defend Marker");
	}
	menu.AddItem("menu2", "[Remove Marker]");
	if(i_typeofsprite[client] > 0)
	{
		if(i_typeofsprite[client] == 1)
		{
			menu.AddItem("menu3", "Defend Sprite [ACTIVE]");
			menu.AddItem("menu4", "Follow-me Sprite");
		}
		else
		{
			menu.AddItem("menu3", "Defend Sprite");
			menu.AddItem("menu4", "Follow-me Sprite [ACTIVE]");
		}
	}
	else
	{
		menu.AddItem("menu3", "Defend Sprite");
		menu.AddItem("menu4", "Follow-me Sprite");
	}
	menu.AddItem("menu5", "[Remove Sprite]");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeLeaderSpritesHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				if(g_bInfected[client] == false && g_bIsLeader[client] == true)
				{
					if (!strcmp(szItem, "menu1"))
					{
						RemoveMarker(client);
						i_markerEntities[client] = SpawnMarker(client, DEFEND);
						g_bMarker = true;
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "defend_marker_spawned");
						openSpritesMarkers(client);
					}
					else if (!strcmp(szItem, "menu2"))
					{
						g_bMarker = false;
						RemoveMarker(client);
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "defend_marker_removed");
					}
					else if (!strcmp(szItem, "menu3"))
					{
						RemoveSprite(client);
						i_spriteEntities[client] = AttachSprite(client, DEFEND);
						i_typeofsprite[client] = 1;
						Sound_EmitToAll("leader_defend", client);
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "chosen_defend_sprite");
					}
					else if (!strcmp(szItem, "menu4"))
					{
						RemoveSprite(client);
						i_spriteEntities[client] = AttachSprite(client, FOLLOWME);
						i_typeofsprite[client] = 2;
						Sound_EmitToAll("leader_followme", client);
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "chosen_follow_sprite");
					}
					else if (!strcmp(szItem, "menu5"))
					{
						RemoveSprite(client);
						i_typeofsprite[client] = 0;
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "sprite_removed");
					}
				}
				else
				{
					CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "no_human");
					CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "no_leader");
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openSwapTeam(int client)
{	
	Menu menu = new Menu(mRoundBanHandler);
	
	menu.SetTitle("[Change Team] Choose player:");
	
	int iValidCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			char userid[12];
			char username[MAX_NAME_LENGTH];
			FormatEx(userid, sizeof userid, "%i", GetClientUserId(i)); // FormatEx faster IntToString (or not)
			if(g_bInfected[i] == false)
			{
				FormatEx(username, sizeof(username), "%N [CT]", i);
			}
			else
			{
				FormatEx(username, sizeof(username), "%N [T]", i);
			}
			menu.AddItem(userid, username);
			iValidCount++;
		}
	}

	if (iValidCount == 0)
	{
		menu.AddItem("", "NO PLAYERS", ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int mRoundBanHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{	
				char name[32];
				menu.GetItem(index, name, sizeof(name));
				int user = GetClientOfUserId(StringToInt(name));
				
				if(IsValidClient(user))
				{
					if(g_bInfected[user] == false)
					{
						CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "swaped_to_zombies", user, client);
						SetZombie(user, false);
						//CS_SwitchTeam(user, CS_TEAM_T);
						//g_bInfected[user] = true;
						//RemoveGuns(user);
						//DisableSpells(user);
						//SetPlayerAsZombie(user);
						Forward_OnClientInfected(user, client);
					}
					else
					{
						CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "swaped_to_humans", user, client);
						CS_SwitchTeam(user, CS_TEAM_CT);
						g_bInfected[user] = false;
						DisableSpells(user);
						SetPlayerAsHuman(user);
						Forward_OnClientHumanPost(user);
					}
					openSwapTeam(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openChooseLeader(int client)
{	
	Menu menu = new Menu(mLeaderChooseHandler);
	
	menu.SetTitle("[Leader] Choose player:");
	
	int iValidCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i, _, false))
		{
			char userid[12];
			char username[MAX_NAME_LENGTH];
			FormatEx(userid, sizeof userid, "%i", GetClientUserId(i));
			if(g_bInfected[i] == false)
			{
				if(g_bIsLeader[i] == true)
				{
					FormatEx(username, sizeof(username), "%N [L]", i); // FormatEx faster Format
				}
				else
				{
					FormatEx(username, sizeof(username), "%N", i); // Format replacable if formatting string it's argument
				}
				menu.AddItem(userid, username);
				iValidCount++;
			}
		}
	}

	if (iValidCount == 0)
	{
		menu.AddItem("", "NO PLAYERS", ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int mLeaderChooseHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{	
				char name[32];
				menu.GetItem(index, name, sizeof(name));
				int user = GetClientOfUserId(StringToInt(name));
				
				if(IsValidClient(user))
				{
					if(g_bInfected[user] == false && IsPlayerAlive(user))
					{
						for (int i = 1; i <= MaxClients; i++)
						{
							if (IsValidClient(i))
							{
								if(g_bIsLeader[i] == true)
								{
									g_bIsLeader[i] = false;
									CPrintToChat(i, " \x04[ZE-Leader]\x01 %t", "removed_from_leader");
									if(H_Beacon[i])
									{
										if (H_Beacon[i] != null && H_Beacon[i] != INVALID_HANDLE)
										{
											delete H_Beacon[i];
											H_Beacon[i] = INVALID_HANDLE;
										}
									}
								}
							}
						}
						CPrintToChatAll(" \x04[ZE-Leader]\x01 %t", "new_leader", user);
						g_bIsLeader[user] = true;
					}
					else
					{
						CReplyToCommand(client, " \x04[ZE-Leader]\x01 %t", "player_is_dead");
						openChooseLeader(client);
					}
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openInfectionBan(int client)
{
	Menu menu = new Menu(mInfectionChooseHandler);
	
	menu.SetTitle("[Infection Ban] Choose player:");
	
	int iValidCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			char userid[11];
			char username[MAX_NAME_LENGTH];
			FormatEx(userid, sizeof userid, "%i", GetClientUserId(i));
			FormatEx(username, sizeof(username), "%N [%i]", i, i_infectionban[i]);
			menu.AddItem(userid, username);
			iValidCount++;
		}
	}

	if (iValidCount == 0)
	{
		menu.AddItem("", "NO PLAYERS", ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

public int mInfectionChooseHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{	
				char name[32];
				menu.GetItem(index, name, sizeof(name));
				int user = GetClientOfUserId(StringToInt(name));
				
				if(user)	openInfectionLong(client, user);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openInfectionLong(int client, int target)
{
	Menu menu = new Menu(mZeInfectionLongHandler);
	
	menu.SetTitle("[Infection Ban] How long?");
	char sInfo[16];
	FormatEx(sInfo, sizeof sInfo, "%i\n", GetClientUserId(target));
	int len = strlen(sInfo);
	strcopy(sInfo[len], sizeof sInfo - len, "2");
	menu.AddItem(sInfo, "2 rounds");
	strcopy(sInfo[len], sizeof sInfo - len, "5");
	menu.AddItem(sInfo, "5 rounds");
	strcopy(sInfo[len], sizeof sInfo - len, "10");
	menu.AddItem(sInfo, "10 rounds");
	strcopy(sInfo[len], sizeof sInfo - len, "0");
	menu.AddItem(sInfo, "[Remove ban]");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeInfectionLongHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char szItem[32];
				menu.GetItem(index, szItem, sizeof(szItem));
				int pos = FindCharInString(szItem, '\n');
				szItem[pos++] = 0;
				int user = GetClientOfUserId(StringToInt(szItem));
				if(!user)	return;

				int newiban;
				char szSteamId[32], szQuery[512];
				GetClientAuthId(user, AuthId_Engine, szSteamId, sizeof(szSteamId));
				
				int addtoban = StringToInt(szItem[pos]);
				newiban = addtoban ? (i_infectionban[user] + addtoban) : 0;
				i_infectionban[user] = newiban;
				g_hDatabase.Format(szQuery, sizeof(szQuery), "UPDATE ze_premium_sql SET infectionban = '%i' WHERE steamid='%s'", newiban, szSteamId);
				g_hDatabase.Query(SQL_Error, szQuery);
				if(addtoban)
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_ban", user, newiban);
				else
					CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "infection_unban", user);
				openInfectionBan(client);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void ShowPlayerZMClass(int client)	{
	if(!(g_cZECanChoiceClass.IntValue & 2))	return;

	ZombieClass zc;
	GetZombieClass(gPlayerSelectedClass[client][1], zc);
	Menu zmmenu = new Menu(MenuHandler_ZombieClass);
	SetMenuTitle(zmmenu, "Zombie class\nSelected: %s", zc.name);
	int size = gZombieClasses.Length;
	char sBuffer[192];
	int len;
	for(int i = 0;i != size;i++)
	{
		GetZombieClass(i, zc);
		if(zc.hidden)	continue;
		len = strcopy(sBuffer, sizeof sBuffer, zc.name);
		if(zc.desc[0])	{
			sBuffer[len++] = '\n';
			strcopy(sBuffer[len], sizeof sBuffer - len, zc.desc);
		}
		zmmenu.AddItem(zc.ident, zc.name, i == gPlayerSelectedClass[client][1]);
	}
	zmmenu.Display(client, 0);
	return;
}

public int MenuHandler_ZombieClass(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			int id = FindZombieClassID(info);
			if(id == -1)	{
				PrintToChat(client, " \x04[ZE-Class]\x01 Error");
				return;
			}
			ZombieClass zc;
			GetZombieClass(id, zc);
			if(zc.access)	{
				if(!(GetUserFlagBits(client) & zc.access))	{
					PrintToChat(client, " \x04[ZE-Class]\x01 You don't have a \x04VIP");
					return;
				}
			}

			SetClientCookie(client, g_hZombieClass, zc.ident);
			gPlayerSelectedClass[client][1] = id;
			CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", zc.name);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void ShowPlayerHumanClass(int client)	{
	if(!(g_cZECanChoiceClass.IntValue & 1))	return;

	HumanClass hc;
	GetHumanClass(gPlayerSelectedClass[client][0], hc);
	Menu zmmenu = new Menu(MenuHandler_HumanClass);
	SetMenuTitle(zmmenu, "Human class\nSelected: %s", hc.name);
	int size = gHumanClasses.Length;
	char sBuffer[192];
	int len;
	for(int i = 0;i != size;i++)
	{
		GetHumanClass(i, hc);
		if(hc.hidden)	continue;
		len = strcopy(sBuffer, sizeof sBuffer, hc.name);
		if(hc.desc[0])	{
			sBuffer[len++] = '\n';
			strcopy(sBuffer[len], sizeof sBuffer - len, hc.desc);
		}
		zmmenu.AddItem(hc.ident, sBuffer, i == gPlayerSelectedClass[client][0]);
	}
	zmmenu.Display(client, 0);
	return;
}

public int MenuHandler_HumanClass(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			int id = FindHumanClassID(info);
			if(id == -1)	{
				PrintToChat(client, " \x04[ZE-Class]\x01 Error");
				return;
			}
			HumanClass hc;
			GetHumanClass(id, hc);
			if(hc.access)	{
				if(!(GetUserFlagBits(client) & hc.access))	{
					PrintToChat(client, " \x04[ZE-Class]\x01 You don't have a \x04VIP");
					return;
				}
			}

			SetClientCookie(client, g_hHumanClass, hc.ident);
			gPlayerSelectedClass[client][0] = id;
			CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", hc.name);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void ShowPlayerWeapons(int client, bool secondary = false)	{
	if(g_bInfected[client])	return;
	char sBuffer[32];
	Menu zmmenu = new Menu(MenuHandler_WeaponsSelect);
	SetMenuTitle(zmmenu, "%s:", secondary ? "Secondary weapon" : "Primary weapon");
 
	char ClassID[32];
	ClassID[0] = secondary ? '2' : '1';
	ArrayList list = secondary ? gWeaponList2 : gWeaponList1;
	int size = list.Length;
	for(int i = 0;i!=size;i++)
	{
		list.GetString(i, ClassID[1], sizeof ClassID - 1);
		strcopy(sBuffer, sizeof sBuffer, ClassID[1]);
		CS_GetTranslatedWeaponAlias(sBuffer, sBuffer, sizeof sBuffer);
		zmmenu.AddItem(ClassID, sBuffer);
	}
 
	zmmenu.Display(client, 0);	
}

public int MenuHandler_WeaponsSelect(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			ChoosePlayerGun(client, info[1], info[0] == '1');
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void ChoosePlayerGun(int client, const char[] alias, bool primary)	{
	if(primary)	strcopy(Primary_Gun[client], sizeof Primary_Gun[], alias);
	else	strcopy(Secondary_Gun[client], sizeof Secondary_Gun[], alias);

	char sBuffer[32];
	strcopy(sBuffer, sizeof sBuffer, alias);
	CS_GetTranslatedWeaponAlias(sBuffer, sBuffer, sizeof sBuffer);
	CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", sBuffer);
}