public Action FirstInfection(Handle timer)
{
	int numberofplayers = GetTeamClientCount(2) + GetTeamClientCount(3);
	//Counting
	if (GameRules_GetProp("m_bWarmupPeriod") != 1)
	{
		if(g_bPause == false && numberofplayers >= g_cZEMinConnectedPlayers.IntValue)
		{
			i_Infection--;
			if(g_bWaitingForPlayer == true)
			{
				g_bWaitingForPlayer = false;
				CS_TerminateRound(5.0, CSRoundEnd_Draw, true);
			}
		}
		else if(numberofplayers <= g_cZEMinConnectedPlayers.IntValue)
		{
			if(g_bWaitingForPlayer == false)
			{
				g_bWaitingForPlayer = true;
			}
		}
	}
	//Counting end

	int numberinfected = numberofplayers / 4;
	if(!numberinfected)	numberinfected = 1;
	float newpercent = float(numberinfected) / float(numberofplayers) * 100.0;
	
	if(i_Infection > 0)
	{	
		CheckTimer(); // show timer
		
		SetHudTextParams(-1.0, 0.1, 1.02, 0, 255, 0, 255, 0, 0.0, 0.0, 0.0);
		char text[4];
		strcopy(text, (GetTime() % 3) + 2, "...");
		for (int i = MaxClients; i ; i--)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				if(numberofplayers >= g_cZEMinConnectedPlayers.IntValue)
				{
					if(i_infectionban[i] > 0)
					{
						ShowHudText(i, -1, "First infected will be: %i sec\nYou will be infected [YOU HAVE: %i INFECTION BANS]", i_Infection, i_infectionban[i]);
					}
					else
					{
						if(g_bWasFirstInfected[i] == true)
						{
							ShowHudText(i, -1, "First infected will be: %i sec\nChance to be infected is: +0 percent", i_Infection);
						}
						else
						{
							ShowHudText(i, -1, "First infected will be: %i sec\nChance to be infected is: +%.1f percent", i_Infection, newpercent);
						}
					}
				}
				else
				{
					ShowHudText(i, -1, "Waiting for players%s\nPlayer on server: %i/%i", text, numberofplayers, g_cZEMinConnectedPlayers.IntValue);
				}
			}
		}
	}
	

	if(i_Infection <= 0)
	{
		g_bRoundStarted = true;

		int ctoz[64]; // Clients to zombie
		int ctozc = 0; // Clients to zombie count
		int jc[64]; // Just clients
		int jcc = 0; // Just clients count

		// Collect just players and players with infection ban
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && GetClientTeam(i) > 1)
			{
				if(i_infectionban[i] > 0)	ctoz[ctozc++] = i;
				else if(!g_bWasFirstInfected[i])	jc[jcc++] = i;
				CS_SwitchTeam(i, CS_TEAM_CT);
				SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			}
		}

		//Fill ctoz array
		int l;
		while(ctozc < numberinfected)	{
			l = GetRandomInt(0, jcc-1);
			ctoz[ctozc++] = jc[l];
			EraseArrayItem(l, jc, jcc);
		}

		// Check free human in case all players have infection ban
		if(!jcc)	{
			EraseArrayItem(GetRandomInt(0, ctozc-1), ctoz, ctozc);
		}

		if(GetRandomInt(1, 100) <= g_cZEZombieRiots.IntValue)
		{
			gRoundType = ROUND_RIOT;
			CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "riot_round");
			CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "riot_round");
			CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "riot_round");
			EmitSoundToAll("ze_premium/ze-riotround.mp3");
		}
		else if(GetRandomInt(1, 100) <= g_cZENemesis.IntValue)	{
			gRoundType = ROUND_NEMESIS;
			EmitSoundToAll("ze_premium/ze-nemesis.mp3");
			CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "infection_start_nemesis");
		}
		else	{
			gRoundType = ROUND_NORMAL;
			CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "infection_start_normal");
		}

		int user;
		char sNames[128] = "";
		int lu = (sizeof sNames - 1) / ctozc - 2;
		int la;
		for(int z = 0;ctozc;z++)	{
			l = GetRandomInt(0, ctozc-1);
			user = ctoz[l];
			EraseArrayItem(l, ctoz, ctozc);
			la = strlen(sNames);
			if(la)	la += strcopy(sNames[la], sizeof sNames - la, ", ");
			GetClientName(user, sNames[la], lu);

			SetZombie(user, g_cZETeleportFirstToSpawn.BoolValue, true);
			if(g_cZEMotherZombieHP.IntValue)	SetEntityHealth(user, g_cZEMotherZombieHP.IntValue);

			if(!z)	{
				g_bFirstInfected[user] = true;
				if(gRoundType == ROUND_NEMESIS)	{
					ApplyPlayerZombieClass(user, gZombieNemesis);
				}
				else if(gRoundType != ROUND_RIOT)	{
					char soundPath[PLATFORM_MAX_PATH];
					FormatEx(soundPath, sizeof(soundPath), "ze_premium/ze-firstzm%i.mp3", GetRandomInt(1, 3));
					EmitSoundToAll(soundPath);
				}

				SetHudTextParams(-1.0, 0.1, 4.02, 255, 0, 0, 255, 0, 0.0, 0.0, 0.0);
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i))
					{
						ShowHudText(i, -1, (gRoundType == ROUND_NEMESIS) ? "Player %N is NEMESIS ! Run, run save your lives..." :
							"Players was infected ! Apocalypse has started...", user);
					}
				}
			}
			CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "first_infected_names", sNames);

			CreateTimer(g_cZEInfectionTime.FloatValue, AntiDisconnect, GetClientUserId(user));
			g_bAntiDisconnect[user] = true;
			Forward_OnClientInfected(user, user);
		}
		H_FirstInfection = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_Beacon(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client)
	{
		float fPos[3];
		GetClientAbsOrigin(client, fPos);
		TE_SetupBeamRingPoint(fPos, 50.0, 20.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.2, 4.0, 0.0, {255, 0, 0, 255}, 0, 0);
		TE_SendToAll();	
	}
}

public Action Respawn(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(!client)	return;
	H_Respawntimer[client] = INVALID_HANDLE;
	if(!g_bNoRespawn[client] && !IsPlayerAlive(client))
	{
		CS_RespawnPlayer(client);
		Forward_OnClientRespawned(client);
	}
}

public Action EndOfRound(Handle timer)
{
	if(GetHumanAliveCount() == 0 && g_bRoundEnd == false)
	{
		StopMapMusic();
		CS_TerminateRound(5.0, CSRoundEnd_TerroristWin, true);
	}
	else if(GetZombieAliveCount() == 0 && g_bRoundEnd == false)
	{
		StopMapMusic();
		CS_TerminateRound(5.0, CSRoundEnd_CTWin, true);
	}
}

public Action AntiDisconnect(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client)
	{
		g_bAntiDisconnect[client] = false;
	}
}

public Action SwitchTeam(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && !IsClientSourceTV(client) && !IsClientReplay(client))
	{
		if(g_bRoundStarted == true)
		{
			g_bInfected[client] = true;
			CS_SwitchTeam(client, CS_TEAM_T);
			CS_RespawnPlayer(client);
			SetPlayerAsZombie(client);
		}
		else
		{
			int random = GetRandomInt(1, 2);
			if(random == 1)
			{
				ChangeClientTeam(client, CS_TEAM_T);
				CS_RespawnPlayer(client);
			}
			else
			{
				ChangeClientTeam(client, CS_TEAM_CT);
				CS_RespawnPlayer(client);
			}
			SetEntProp(client, Prop_Send, "m_CollisionGroup", 2);
		}
	}
}

public Action Timer_Unfreeze(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (client && !IsPlayerAlive(client))
		return Plugin_Handled;
	
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntityRenderColor(client);
	
	return Plugin_Handled;
}

public Action Onfire(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsPlayerAlive(client))
	{
		if(GetClientTeam(client) == CS_TEAM_T && g_bOnFire[client] == true)
		{
			EmitSoundToAll("ze_premium/ze-fire2.mp3", client);
		}
	}
}

public Action Slowdown(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsPlayerAlive(client))
	{
		if(g_bInfected[client] == true)
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gPlayerZombieClass[client].speed);
		}
	}
}

public Action PointsCheck(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !IsFakeClient(i))
		{
			Command_DataUpdate(i);
		}
	}
}

public Action HUD(Handle timer)
{
	if(g_cZEHUDInfo.IntValue > 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{
				if(g_bInfected[i] == true)
				{
					SetHudTextParams(-1.0, -0.05, 1.02, 255, 0, 0, 255, 0, 0.0, 0.0, 0.0);
					ShowHudText(i, -1, "Type: Zombie | Class: %s | Infected players: %i", gPlayerZombieClass[i].name, i_infectedh[i]);
				}
				else
				{
					if(gPlayerHumanClass[i].power)
					{
						char progress[32];
						if(i_Power[i])	{
							strcopy(progress, sizeof(progress), "ACTIVE");
						}
						else if(f_causeddamage[i] < g_cZEUltimateDamageNeed.FloatValue)
						{
							static int charsize = -1;
							if(charsize == -1)	{
								char buf[4] = "☐";
								charsize = strlen(buf);
							} 
							int chars = RoundToFloor(5.0 * f_causeddamage[i] / g_cZEUltimateDamageNeed.FloatValue);
							strcopy(progress, chars * charsize + 1, "☒☒☒☒☒");
							strcopy(progress[chars], 1 + (5 - chars) * charsize, "☐☐☐☐☐");
						}
						else
						{
							strcopy(progress, sizeof(progress), "READY TO USE (F)");
						}
						SetHudTextParams(-1.0, -0.05, 1.02, 65, 105, 225, 255, 0, 0.0, 0.0, 0.0);
						ShowHudText(i, -1, "Type: Human | Class: %s | Won rounds: %i\nUltimate Power: %s", gPlayerHumanClass[i].name, i_hwins[i], progress);
					}
					else
					{
						SetHudTextParams(-1.0, -0.05, 1.02, 65, 105, 225, 255, 0, 0.0, 0.0, 0.0);
						ShowHudText(i, -1, "Type: Human | Class: %s | Won rounds: %i", gPlayerHumanClass[i].name, i_hwins[i]);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action CreateEvent_SmokeDetonate(Handle timer, any entity)
{
	entity = EntRefToEntIndex(entity);
	if (entity == -1)
	{
		return Plugin_Stop;
	}
	
	char g_szClassname[64];
	GetEdictClassname(entity, g_szClassname, sizeof(g_szClassname));
	if (!strcmp(g_szClassname, "smokegrenade_projectile", false))
	{
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		EmitSoundToAll("ze_premium/ze-infectionnade.mp3", entity);
		SmokeInfection(client, origin);
		AcceptEntityInput(entity, "kill");
	}
	
	return Plugin_Stop;
}

public Action CreateEvent_DecoyDetonate(Handle timer, any entity)
{
	entity = EntRefToEntIndex(entity);
	if (entity == -1)
	{
		return Plugin_Stop;
	}
	
	char g_szClassname[64];
	GetEdictClassname(entity, g_szClassname, sizeof(g_szClassname));
	if (!strcmp(g_szClassname, "decoy_projectile", false))
	{
		float origin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		int client = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		EmitSoundToAll("ze_premium/freeze.mp3", entity);
		FlashFreeze(client, origin);
		AcceptEntityInput(entity, "kill");
	}
	
	return Plugin_Stop;
}

public Action Delete(Handle timer, any entity)
{
	entity = EntRefToEntIndex(entity);
	if (entity != -1)
	{
		AcceptEntityInput(entity, "kill");
	}
}

public Action EndPower(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (client)
	{
		ResetPlayerUltimate(client, false);
		PrintHintText(client, "\n<font class='fontSize-l'><font color='#00FF00'>[ZE-Class]</font> <font color='#FF0000'>Your ultimate power has expired!");
	}	
}

public Action PowerOfTimer(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (client)
	{
		if(i_Power[client] == 2)
		{
			float fPos[3];
			GetClientAbsOrigin(client, fPos);
			TE_SetupBeamRingPoint(fPos, 150.0, 10.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 4.0, 0.0, {255, 215, 0, 255}, 0, 0);
			TE_SendToAll();
			SetEntityHealth(client, GetClientHealth(client) + 5);
			CheckPlayerRange(client);
		}
		else if(i_Power[client] == 3)
		{
			int Primary = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
			if (Primary != -1)
			{
				char SecondaryName[30];
				GetEntityClassname(Primary, SecondaryName, sizeof(SecondaryName));
				if (StrEqual(SecondaryName, "weapon_negev", false) || StrEqual(SecondaryName, "weapon_m249", false))
				{
					SetClipAmmo(client, Primary, 100);
				}
				else if (StrEqual(SecondaryName, "weapon_bizon", false) || StrEqual(SecondaryName, "weapon_p90", false))
				{
					SetClipAmmo(client, Primary, 50);
				}
				else
				{
					SetClipAmmo(client, Primary, 40);
				}
			}
		}
	}	
}

public Action SetArms(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client)	SetPlayerArms(client, Zombie_Arms[client]);	
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
			dpack.WriteCell(GetClientUserId(client));
			dpack.WriteCell(EntIndexToEntRef(activeWeapon));
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
	int clientIndex = GetClientOfUserId(pack.ReadCell());
	int activeWeapon = EntRefToEntIndex(pack.ReadCell());
	pack.ReadString(model, 128);
	
	if(clientIndex)
	{
		SetEntPropString(clientIndex, Prop_Send, "m_szArmsModel", model);
		
		if(activeWeapon != -1) SetEntPropEnt(clientIndex, Prop_Send, "m_hActiveWeapon", activeWeapon);
	}
}