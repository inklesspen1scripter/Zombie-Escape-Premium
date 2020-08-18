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

			if (buffer[0] && strcmp(buffer,".",false) && strcmp(buffer,"..",false))
			{
				strcopy(tmp_path,sizeof tmp_path,path);
				StrCat(tmp_path,sizeof tmp_path,"/");
				StrCat(tmp_path,sizeof tmp_path,buffer);
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
	BuildPath(Path_SM, file, sizeof file, "configs/ze_premium-download.ini");
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
	CloseHandle(fileh);
}

public void StartToDownload(char[] buffer)
{
	int len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);
	//if(len >= 2 && buffer[0] == '/' && buffer[1] == '/')
	//{
	//	//Comment
	//}
	//else
	if (buffer[0] && FileExists(buffer))
	{
		AddFileToDownloadsTable(buffer);
	}
}

public Action CMD_ZMClass(int client, int args)
{
	if(GetClientTeam(client) > 1)
	{
		Menu zmmenu = new Menu(MenuHandler_ZombieClass);
		SetMenuTitle(zmmenu, "Zombie class (%s)", Selected_Class_Zombie[client]);
	 	
	 	kvZombies.Rewind();
		if (!kvZombies.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[12];
		char name[152];
		do
		{
			kvZombies.GetSectionName(ClassID, sizeof(ClassID));
			kvZombies.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvZombies.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_ZombieClass(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			int SelectedZMClass = StringToInt(info);
			
			//Check for VIP class
			kvZombies.Rewind();
			char s_SelectedClass[12];
			FormatEx(s_SelectedClass, sizeof s_SelectedClass, "%i", SelectedZMClass);
			if (!kvZombies.JumpToKey(s_SelectedClass)) return;

			char flags[40];
			kvZombies.GetString("flags", flags, sizeof(flags), "");
			
			if(flags[0] && !HasPlayerFlags(client, flags))
			{
				PrintToChat(client, " \x04[ZE-Class]\x01 You don't have a \x04VIP");
			}
			else	{
				i_zclass[client] = SelectedZMClass;
				char szClass[16];
				FormatEx(szClass, sizeof(szClass), "%i", i_zclass[client]);
				SetClientCookie(client, g_hZombieClass, szClass);
				CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", s_SelectedClass);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action CMD_HumanClass(int client, int args)
{
	if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT)
	{
		Menu zmmenu = new Menu(MenuHandler_HumanClass);
		SetMenuTitle(zmmenu, "Human class (%s)", Selected_Class_Human[client]);
	 	
	 	kvHumans.Rewind();
		if (!kvHumans.GotoFirstSubKey())
			return Plugin_Handled;
	 
		char ClassID[12];
		char name[152];
		do
		{
			kvHumans.GetSectionName(ClassID, sizeof(ClassID));
			kvHumans.GetString("name", name, sizeof(name));
			zmmenu.AddItem(ClassID, name);
		} while (kvHumans.GotoNextKey());
	 
		zmmenu.Display(client, 0);
	}
	return Plugin_Continue;
}

public int MenuHandler_HumanClass(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			GetMenuItem(menu, item, info, sizeof(info));
			
			int SelectedHumanClass = StringToInt(info);
			
			//Check for VIP class
			kvHumans.Rewind();
			char s_SelectedClass[10];
			FormatEx(s_SelectedClass, sizeof(s_SelectedClass), "%i", SelectedHumanClass);
			if (!kvHumans.JumpToKey(s_SelectedClass)) return;

			char flags[40];
			kvHumans.GetString("flags", flags, sizeof(flags), "");
			
			if(flags[0] && !HasPlayerFlags(client, flags))
			{
				PrintToChat(client, " \x04[ZE-Class]\x01 You don't have a \x04VIP");
			}
			else
			{
				i_hclass[client] = SelectedHumanClass;
				char szClass[16];
				FormatEx(szClass, sizeof(szClass), "%i", i_hclass[client]);
				SetClientCookie(client, g_hHumanClass, szClass);
				CPrintToChat(client, " \x04[ZE-Class]\x01 %t", "chosen_class", s_SelectedClass);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

void SetPlayerAsZombie(int client)
{
	CS_UpdateClientModel(client); // reset model
	kvZombies.Rewind();
	char clientclass[12];
	FormatEx(clientclass, sizeof(clientclass), "%i", i_zclass[client]);
	if (!kvZombies.JumpToKey(clientclass)) 
	{
		SetEntityHealth(client, g_cZEZombieHP.IntValue);
		SetEntityModel(client, ZOMBIEMODEL);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_cZEZombieSpeed.FloatValue);
		strcopy(Selected_Class_Zombie[client], sizeof(Selected_Class_Zombie), "Default");
		return;		
	}
		
	char zmName[100];
	char zmModel[PLATFORM_MAX_PATH + 1];
	char zmArms[PLATFORM_MAX_PATH + 1];
	kvZombies.GetString("name", 		zmName, 	sizeof(zmName));
	kvZombies.GetString("model_path", 	zmModel, 	sizeof(zmModel), "-");
	kvZombies.GetString("arms_path", 	zmArms, 	sizeof(zmArms), "-");
	
	Selected_Class_Zombie[client] = zmName;
	
	if(zmArms[0] != '-')
	{
		Zombie_Arms[client] = zmArms;
		if(!IsModelPrecached(zmArms))
			PrecacheModel(zmArms, true);
		CreateTimer(0.7, SetArms, client, TIMER_FLAG_NO_MAPCHANGE);
	}

	if(zmModel[0] != '-')	{
		if(!IsModelPrecached(zmModel))
			PrecacheModel(zmModel);
		SetEntityModel(client, zmModel);
	}
	
	SetEntityHealth(client, kvZombies.GetNum("health", 3000));
	SetEntityGravity(client, kvZombies.GetFloat("gravity", 1.0));
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", kvZombies.GetFloat("speed", 1.0));
}

void SetPlayerAsHuman(int client)
{
	CS_UpdateClientModel(client);
	kvHumans.Rewind();
	char clientclass[12];
	FormatEx(clientclass, sizeof(clientclass), "%i", i_hclass[client]);
	if (!kvHumans.JumpToKey(clientclass)) 
	{
		SetEntityHealth(client, g_cZEHumanHP.IntValue);
		SetEntityModel(client, HUMANMODEL);
		SetEntityGravity(client, 1.0);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);	
		CreateTimer(0.7, SetArms, client, TIMER_FLAG_NO_MAPCHANGE);
		Selected_Class_Human[client] = "Default";
		return;		
	}
		
	char humanName[100];
	char humanItem[32];
	char humanModel[PLATFORM_MAX_PATH + 1];
	kvHumans.GetString("name", 			humanName, 		sizeof(humanName));
	kvHumans.GetString("item", 			humanItem, 		sizeof(humanItem), "-");
	kvHumans.GetString("power", 		Human_Power[client], 	sizeof(Human_Power[]));
	kvHumans.GetString("model_path", 	humanModel, 	sizeof(humanModel), "-");
	
	i_protection[client] = kvHumans.GetNum("protection", 0);
	Selected_Class_Human[client] = humanName;
	
	CreateTimer(0.7, SetArms, client, TIMER_FLAG_NO_MAPCHANGE);
	SetEntityHealth(client, kvHumans.GetNum("health", 100));
	if(humanItem[0] != '-')
	{
		if (!strcmp(humanItem, "FireNade", false))
		{
			FireNade(client);
		}
		else if (!strcmp(humanItem, "FreezeNade", false))
		{
			FreezeNade(client);
		}
		else
		{
			GivePlayerItem(client, humanItem);
		}
	}

	SetEntityGravity(client, kvHumans.GetFloat("gravity", 1.0));
	if(humanModel[0] != '-')	{
		if(!IsModelPrecached(humanModel))
			PrecacheModel(humanModel);
		SetEntityModel(client, humanModel);
	}
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", kvHumans.GetFloat("speed", 1.0));
}

void ShowPrimaryWeapons(int client, const char[] key, const char[] title, bool primary = true)	{

 	kvWeapons.Rewind();
 	if (!kvWeapons.JumpToKey(key))
 		return;
 	
	if (!kvWeapons.GotoFirstSubKey())
		return;
 
	char ClassID[32];
	char name[152];

	Menu zmmenu = new Menu(primary ? MenuHandler_WeaponsPrimary : MenuHandler_WeaponsSecondary);
	SetMenuTitle(zmmenu, title);
	do
	{
		kvWeapons.GetSectionName(ClassID, sizeof(ClassID));
		kvWeapons.GetString("name", name, sizeof(name));
		zmmenu.AddItem(ClassID, name);
	} while (kvWeapons.GotoNextKey());
 
	zmmenu.Display(client, 0);
}

public int MenuHandler_WeaponsPrimary(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			GetMenuItem(menu, item, Primary_Gun[client], sizeof(Primary_Gun[]));
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

public int MenuHandler_WeaponsSecondary(Menu menu, MenuAction action, int client, int item) 
{
	switch(action)
	{
		case MenuAction_Select:
		{
			GetMenuItem(menu, item, Secondary_Gun[client], sizeof(Secondary_Gun[]));
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

public Action CMD_WeaponsRifle(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		ShowPrimaryWeapons(client, "Rifles", "Rifle Guns:");
	}
	return Plugin_Continue;
}

public Action CMD_WeaponsHeavy(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		ShowPrimaryWeapons(client, "Heavyguns", "Heavy Guns:");
	}
	return Plugin_Continue;
}

public Action CMD_WeaponsSmg(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		ShowPrimaryWeapons(client, "Smg", "SMG Guns:");
	}
	return Plugin_Continue;
}

public Action CMD_WeaponsPistols(int client, int args)
{
	if(g_bInfected[client] == false)
	{
		ShowPrimaryWeapons(client, "Pistols", "Pistols Guns:", false);
	}
	return Plugin_Continue;
}

public bool HasPlayerFlags(int client, char flags[40])
{
	// wtf man
	// wtf me
	return (GetUserFlagBits(client) & (ReadFlagString(flags) | ADMFLAG_ROOT)) != 0;
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