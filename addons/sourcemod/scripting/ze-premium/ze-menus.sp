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
					openShop(client);
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
	Menu menu = new Menu(mZeGunsHandler);
	menu.SetTitle("[Weapons] Choose a gun:");

	int len = strcopy(text, sizeof text, "Rifle guns");
	if(Primary_Gun[client][0] == 'w')	FormatEx(text[len], sizeof text - len, " [%s]", Primary_Gun[client]);
	menu.AddItem("1", text);
	len = strcopy(text, sizeof text, "Heavy guns");
	if(Primary_Gun[client][0] == 'w')	FormatEx(text[len], sizeof text - len, " [%s]", Primary_Gun[client]);
	menu.AddItem("2", text);
	len = strcopy(text, sizeof text, "SMG guns");
	if(Primary_Gun[client][0] == 'w')	FormatEx(text[len], sizeof text - len, " [%s]", Primary_Gun[client]);
	menu.AddItem("3", text);

	len = strcopy(text, sizeof text, "Pistol guns");
	if(Secondary_Gun[client][0] == 'w')	FormatEx(text[len], sizeof text - len, " [%s]", Secondary_Gun[client]);
	menu.AddItem("4", text);
	
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
				
				if (szItem[0] == '1')	FakeClientCommand(client, "sm_rifle");
				else if (szItem[0] == '2')	FakeClientCommand(client, "sm_heavygun");
				else if (szItem[0] == '3')	FakeClientCommand(client, "sm_smg");
				else if (szItem[0] == '4')	FakeClientCommand(client, "sm_pistols");
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

//*****SHOP*****
void openShop(int client)
{
	char text[84];
	
	Menu menu = new Menu(mZeShopHandler);
	
	menu.SetTitle("[Shop] Main Menu:");
	if(ZR_IsClientHuman(client))	{
		FormatEx(text, sizeof(text), "Health-Shot [%i $] [HUMAN]", g_cZEHealthShot.IntValue);
		menu.AddItem("11", text);
		FormatEx(text, sizeof(text), "Fire Grenade [%i $] [HUMAN]", g_cZEHeNade.IntValue);
		menu.AddItem("12", text);
		FormatEx(text, sizeof(text), "[VIP] Freeze Grenade [%i $] [HUMAN]", g_cZEFlashNade.IntValue);
		menu.AddItem("131", text, !IsClientVIP(client));
		FormatEx(text, sizeof(text), "Molotov [%i $] [HUMAN]", g_cZEMolotov.IntValue);
		menu.AddItem("14", text);
	}
	else	{
		FormatEx(text, sizeof(text), "[VIP] Infection Grenade [%i $] [ZOMBIE]", g_cZEInfnade.IntValue);
		menu.AddItem("21", text, !IsClientVIP(client));
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int mZeShopHandler(Menu menu, MenuAction action, int client, int index)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				int money = GetEntProp(client, Prop_Send, "m_iAccount");
				char szItem[4];
				menu.GetItem(index, szItem, sizeof(szItem));
				
				char szBoughtItem[64];
				if(ZR_IsClientHuman(client) != (szItem[0] == '1'))	return;
				if(szItem[2] == '1' && !IsClientVIP(client))	return;
				
				if(szItem[0] == '1')
				{	
					if (szItem[1] == '1')
					{
						if(money >= g_cZEHealthShot.IntValue)
						{
							GivePlayerItem(client, "weapon_healthshot");
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEHealthShot.IntValue);
							spended[client] += g_cZEHealthShot.IntValue;
							strcopy(szBoughtItem, sizeof(szBoughtItem), "HealthShot");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
					else if (szItem[1] == '2')
					{
						if(money >= g_cZEHeNade.IntValue)
						{
							GivePlayerNade(client, "weapon_hegrenade");
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEHeNade.IntValue);
							spended[client] += g_cZEHeNade.IntValue;
							strcopy(szBoughtItem, sizeof(szBoughtItem), "Fire Grenade");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
					else if (szItem[1] == '3')
					{
						if(money >= g_cZEFlashNade.IntValue)
						{
							GivePlayerNade(client, "weapon_decoy");
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEFlashNade.IntValue);
							spended[client] += g_cZEFlashNade.IntValue;
							strcopy(szBoughtItem, sizeof(szBoughtItem), "Freeze Grenade");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
					else if (szItem[1] == '4')
					{
						if(money >= g_cZEMolotov.IntValue)
						{
							GivePlayerNade(client, "weapon_molotov");
							SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEMolotov.IntValue);
							spended[client] += g_cZEMolotov.IntValue;
							strcopy(szBoughtItem, sizeof(szBoughtItem), "Molotov");	
							CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
					}
				}
				else if(szItem[0] == '2')
				{
					if (szItem[1] == '1')
					{
						if(money >= g_cZEInfnade.IntValue)
						{
							if(g_cZEInfnadeusages.IntValue > i_binfnade)
							{
								GivePlayerNade(client, "weapon_smokegrenade");
								SetEntProp(client, Prop_Send, "m_iAccount", money - g_cZEInfnade.IntValue);
								spended[client] += g_cZEHealthShot.IntValue;
								strcopy(szBoughtItem, sizeof(szBoughtItem), "Infection Grenade");	
								CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", szBoughtItem);
								i_binfnade++;
							}
							else
							{
								CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_infection_nades");
								openShop(client);
							}
						}
						else
						{
							CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
							openShop(client);
						}
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
	if(g_bBeacon[client] == true)
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
					if(g_bBeacon[client] == true)
					{
						g_bBeacon[client] = false;
						if (H_Beacon[client] != INVALID_HANDLE)
						{
							delete H_Beacon[client];
							g_bBeacon[client] = false;
							CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "beacon_off");
							openLeader(client);
						}
					}
					else
					{
						g_bBeacon[client] = true;
						H_Beacon[client] = CreateTimer(0.2, Timer_Beacon, client, TIMER_REPEAT);
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
						EmitSoundToAll("ze_premium/ze-defend.mp3", client);
						openSpritesMarkers(client);
						CPrintToChat(client, " \x04[ZE-Leader]\x01 %t", "chosen_defend_sprite");
					}
					else if (!strcmp(szItem, "menu4"))
					{
						RemoveSprite(client);
						i_spriteEntities[client] = AttachSprite(client, FOLLOWME);
						i_typeofsprite[client] = 2;
						EmitSoundToAll("ze_premium/ze-folowme.mp3", client);
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
						CS_SwitchTeam(user, CS_TEAM_T);
						g_bInfected[user] = true;
						RemoveGuns(user);
						DisableSpells(user);
						SetPlayerAsZombie(user);
						Call_StartForward(gF_ClientInfected);
						Call_PushCell(user);
						Call_PushCell(client);
						Call_Finish();
					}
					else
					{
						CPrintToChatAll(" \x04[ZE-Admin]\x01 %t", "swaped_to_humans", user, client);
						CS_SwitchTeam(user, CS_TEAM_CT);
						g_bInfected[user] = false;
						DisableSpells(user);
						SetPlayerAsHuman(user);
						SetEntityGravity(user, 1.0);
						Call_StartForward(gF_ClientHumanPost);
						Call_PushCell(user);
						Call_Finish();
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
									if(g_bBeacon[i] == true)
									{
										if (H_Beacon[i] != null && H_Beacon[i] != INVALID_HANDLE)
										{
											delete H_Beacon[i];
											g_bBeacon[i] = false;
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
				
				if(IsValidClient(user))
				{
					g_hDataPackUser = CreateDataPack();
					WritePackCell(g_hDataPackUser, user);
					openInfectionLong(client);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void openInfectionLong(int client)
{
	Menu menu = new Menu(mZeInfectionLongHandler);
	
	menu.SetTitle("[Infection Ban] How long?");
	
	menu.AddItem("2", "2 rounds");
	menu.AddItem("5", "5 rounds");
	menu.AddItem("10", "10 rounds");
	menu.AddItem("0", "[Remove ban]");
	
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
				
				ResetPack(g_hDataPackUser);
				int user = ReadPackCell(g_hDataPackUser);
				int newiban;
				char szSteamId[32], szQuery[512];
				GetClientAuthId(user, AuthId_Engine, szSteamId, sizeof(szSteamId));
				
				int addtoban = StringToInt(szItem);
				newiban = addtoban ? (i_infectionban[user] + 2) : 0;
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