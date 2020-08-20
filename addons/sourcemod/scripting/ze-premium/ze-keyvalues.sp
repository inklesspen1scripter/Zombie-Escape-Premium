public ReadFileFolder(char[] path)
{
	Handle dirh = INVALID_HANDLE;
	char buffer[256];
	char tmp_path[256];
	FileType type = FileType_Unknown;
	int len;
	
	len = strlen(path);
	if (path[len-1] == '\n')
		path[--len] = '\0';

	TrimString(path);
	
	if(DirExists(path))
	{
		dirh = OpenDirectory(path);
		while(ReadDirEntry(dirh,buffer,sizeof(buffer),type))
		{
			len = strlen(buffer);
			if (buffer[len-1] == '\n')
				buffer[--len] = '\0';

			TrimString(buffer);

			if (!StrEqual(buffer,"",false) && !StrEqual(buffer,".",false) && !StrEqual(buffer,"..",false))
			{
				strcopy(tmp_path,255,path);
				StrCat(tmp_path,255,"/");
				StrCat(tmp_path,255,buffer);
				if(type == FileType_File)
				{
					StartToDownload(tmp_path);
				}
				else
				{
					ReadFileFolder(tmp_path);
				}
			}
		}
	}
	else
	{
		StartToDownload(path);
	}
	if(dirh != INVALID_HANDLE)
	{
		CloseHandle(dirh);
	}
}

public DownloadFiles(){
	char file[256];
	BuildPath(Path_SM, file, 255, "configs/ze_premium-download.ini");
	Handle fileh = OpenFile(file, "r");
	char buffer[256];
	int len;
	
	if(fileh == INVALID_HANDLE) return;
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(!StrEqual(buffer,"",false))
		{
			ReadFileFolder(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	if(fileh != INVALID_HANDLE){
		CloseHandle(fileh);
	}
}

public void StartToDownload(char[] buffer)
{
	int len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);
	if(len >= 2 && buffer[0] == '/' && buffer[1] == '/')
	{
		//Comment
	}
	else if (!StrEqual(buffer,"",false) && FileExists(buffer))
	{
		AddFileToDownloadsTable(buffer);
	}
}

public Action CMD_ZMClass(int client, int args)
{
	if(!(g_cZECanChoiceClass.IntValue & 2))	return Plugin_Handled;

	ZombieClass zc;
	GetZombieClass(gPlayerSelectedClass[client][1], zc);
	Menu zmmenu = new Menu(MenuHandler_ZombieClass);
	SetMenuTitle(zmmenu, "Zombie class\nSelected: %s", zc.name);
	int size = gZombieClasses.Length;
	for(int i = 0;i != size;i++)
	{
		GetZombieClass(i, zc);
		zmmenu.AddItem(zc.ident, zc.name);
	}
	zmmenu.Display(client, 0);
	return Plugin_Handled;
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

public Action CMD_HumanClass(int client, int args)
{
	if(!(g_cZECanChoiceClass.IntValue & 1))	return Plugin_Handled;

	HumanClass hc;
	GetHumanClass(gPlayerSelectedClass[client][0], hc);
	Menu zmmenu = new Menu(MenuHandler_HumanClass);
	SetMenuTitle(zmmenu, "Human class\nSelected: %s", hc.name);
	int size = gHumanClasses.Length;
	for(int i = 0;i != size;i++)
	{
		GetHumanClass(i, hc);
		zmmenu.AddItem(hc.ident, hc.name);
	}
	zmmenu.Display(client, 0);
	return Plugin_Handled;
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

void SetPlayerAsZombie(int client)
{
	ZombieClass zc;
	if(g_cZECanChoiceClass.IntValue & 2)	{
		GetZombieClass(gPlayerSelectedClass[client][1], zc);
		if(zc.access && !(zc.access & GetUserFlagBits(client)))	{
			gPlayerSelectedClass[client][1] = 0;
			GetZombieClass(0, zc);
		}
	}
	else	{
		GetZombieClass(GetRandomInt(0, gZombieClasses.Length-1), zc);
	}

	ApplyPlayerZombieClass(client, zc);
}

void SetPlayerAsHuman(int client)
{
	HumanClass hc;
	if(g_cZECanChoiceClass.IntValue & 1)	{
		GetHumanClass(gPlayerSelectedClass[client][0], hc);
		if(hc.access && !(hc.access & GetUserFlagBits(client)))	{
			gPlayerSelectedClass[client][0] = 0;
			GetHumanClass(0, hc);
		}
	}
	else	{
		GetHumanClass(GetRandomInt(0, gHumanClasses.Length-1), hc);
	}

	ApplyPlayerHumanClass(client, hc);
}

public Action CMD_WeaponsRifle(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsRifle);
		SetMenuTitle(zmmenu, "Rifle Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Rifles"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsRifle(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Primary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action CMD_WeaponsHeavy(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsHeavy);
		SetMenuTitle(zmmenu, "Heavy Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Heavyguns"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsHeavy(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Primary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action CMD_WeaponsSmg(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsSmg);
		SetMenuTitle(zmmenu, "SMG Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Smg"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsSmg(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Primary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Primary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action CMD_WeaponsPistols(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		Menu zmmenu = new Menu(MenuHandler_WeaponsPistols);
		SetMenuTitle(zmmenu, "Pistols Guns:");
	 	
	 	kvWeapons.Rewind();
	 	if (!kvWeapons.JumpToKey("Pistols"))
	 		return Plugin_Handled;
	 	
		if (!kvWeapons.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[32];
		char name[150];
		do
		{
			kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
			kvWeapons.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvWeapons.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_WeaponsPistols(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			Secondary_Gun[client] = info;
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "chosen_gun", Secondary_Gun[client]);
			CPrintToChat(client, " \x04[ZE-Weapons]\x01 %t", "get_the_gun");
			openWeapons(client);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action SetArms(Handle timer, int client)
{
	SetPlayerArms(client, Zombie_Arms[client]);	
}

public void SetPlayerArms(int client, char[] arms)
{
	if(!IsPlayerAlive(client)) 
	{
		return;
	}
	
	char currentmodel[128];
	
	GetEntPropString(client, Prop_Send, "m_szArmsModel", currentmodel, sizeof(currentmodel));

	if(g_bInfected[client] == true)
	{
		int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(activeWeapon != -1)
		{
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
		}
		if(activeWeapon != -1)
		{
			DataPack dpack;
			CreateDataTimer(0.1, ResetGlovesTimer2, dpack);
			dpack.WriteCell(client);
			dpack.WriteCell(activeWeapon);
			dpack.WriteString(arms);
		}
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
		if(ent != -1)
		{
			AcceptEntityInput(ent, "KillHierarchy");
		}
		SetEntPropString(client, Prop_Send, "m_szArmsModel", arms);
	}
	else
	{
		int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(activeWeapon != -1)
		{
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
		}
		if(activeWeapon != -1)
		{
			DataPack dpack;
			CreateDataTimer(0.1, ResetGlovesTimer2, dpack);
			dpack.WriteCell(client);
			dpack.WriteCell(activeWeapon);
			dpack.WriteString(DEFAULT_ARMS);
		}
		int ent = GetEntPropEnt(client, Prop_Send, "m_hMyWearables");
		if(ent != -1)
		{
			AcceptEntityInput(ent, "KillHierarchy");
		}
		SetEntPropString(client, Prop_Send, "m_szArmsModel", DEFAULT_ARMS);
	}
}

public Action ResetGlovesTimer2(Handle timer, DataPack pack)
{
	char model[128];
	ResetPack(pack);
	int clientIndex = pack.ReadCell();
	int activeWeapon = pack.ReadCell();
	pack.ReadString(model, 128);
	
	if(IsClientInGame(clientIndex))
	{
		SetEntPropString(clientIndex, Prop_Send, "m_szArmsModel", model);
		
		if(IsValidEntity(activeWeapon)) SetEntPropEnt(clientIndex, Prop_Send, "m_hActiveWeapon", activeWeapon);
	}
}

void ApplyPlayerZombieClass(int client, ZombieClass zc)	{
	gPlayerZombieClass[client] = zc;

	CS_SwitchTeam(client, CS_TEAM_T);
	CS_UpdateClientModel(client);

	if(zc.arms[0])
	{
		strcopy(Zombie_Arms[client], sizeof Zombie_Arms[], zc.arms);
		CreateTimer(0.7, SetArms, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	SetEntityHealth(client, zc.health);
	SetEntityGravity(client, zc.gravity);
	SetEntityModel(client, zc.model);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", zc.speed);

	StripPlayer(client);
	GivePlayerItem(client, "weapon_knife");
}

void ApplyPlayerHumanClass(int client, HumanClass hc)	{
	gPlayerHumanClass[client] = hc;
	
	CS_SwitchTeam(client, CS_TEAM_CT);
	CS_UpdateClientModel(client);

	CreateTimer(0.7, SetArms, client, TIMER_FLAG_NO_MAPCHANGE);

	if(hc.item[0])
	{
		if (!strcmp(hc.item, "FireNade", false))
			FireNade(client);
		else if (!strcmp(hc.item, "FreezeNade", false))
			FreezeNade(client);
		else
			GivePlayerItem(client, hc.item);
	}

	i_protection[client] = hc.protection;
	SetEntityHealth(client, hc.health);
	SetEntityGravity(client, hc.gravity);
	SetEntityModel(client, hc.model);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", hc.speed);
}