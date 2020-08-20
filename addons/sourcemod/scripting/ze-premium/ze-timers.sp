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
	
	if(i_Infection > 0)
	{	
		CheckTimer(); // show timer
		
		for (int i = MaxClients; i ; i--)
		{
			if (IsValidClient(i) && !IsFakeClient(i))
			{
				int numberinfected;
				if(numberofplayers < 4)
				{
					numberinfected = 1;
				}
				else
				{
					numberinfected = numberofplayers / 4;
				}
				float newpercent = float(numberinfected) / float(numberofplayers) * 100.0;
				SetHudTextParams(-1.0, 0.1, 1.02, 0, 255, 0, 255, 0, 0.0, 0.0, 0.0);
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
					char text[4];
					strcopy(text, (GetTime() % 3) + 2, "...");
					ShowHudText(i, -1, "Waiting for players%s\nPlayer on server: %i/%i", text, numberofplayers, g_cZEMinConnectedPlayers.IntValue);
				}
				if(g_bInfected[i] == false)
				{
					PrintHintText(i, "\n<font class='fontSize-l'><font color='#FF4500'>CHOSEN GUN:</font>%s | %s", Primary_Gun[i], Secondary_Gun[i]);
				}
				else
				{
					PrintHintText(i, "\n<font class='fontSize-l'>You will be respawned in: <font color='#00FF00'>%i</font> sec", i_Infection);
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

		int numberinfected = numberofplayers / 4;
		if(!numberinfected)	numberinfected = 1;

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
		}
		else	gRoundType = ROUND_NORMAL;

		int user;
		for(int z = 0;ctozc;z++)	{
			l = GetRandomInt(0, ctozc-1);
			user = ctoz[l];
			EraseArrayItem(l, ctoz, ctozc);

			SetZombie(user, g_cZETeleportFirstToSpawn.BoolValue);
			if(g_cZEMotherZombieHP.IntValue)	SetEntityHealth(user, g_cZEMotherZombieHP.IntValue);

			if(!z)	{
				g_bFirstInfected[user] = true;
				if(gRoundType == ROUND_NEMESIS)	{
					ApplyPlayerZombieClass(user, gZombieNemesis);
				}
				else if(gRoundType != ROUND_RIOT)	{
					char soundPath[PLATFORM_MAX_PATH];
					Format(soundPath, sizeof(soundPath), "ze_premium/ze-firstzm%i.mp3", GetRandomInt(1, 3));
					EmitSoundToAll(soundPath);
				}

				SetHudTextParams(-1.0, 0.1, 4.02, 255, 0, 0, 255, 0, 0.0, 0.0, 0.0);
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i))
					{
						ShowHudText(i, -1, (gRoundType == ROUND_NEMESIS) ? "Player %N is NEMESIS ! Run, run save your lives..." :
							"Player %N was infected ! Apocalypse has started...", user);
					}
				}
				CPrintToChatAll(" \x04[Zombie-Escape]\x01 %t", "first_infected", user);
			}

			CreateTimer(g_cZEInfectionTime.FloatValue, AntiDisconnect, GetClientUserId(user));
			g_bAntiDisconnect[user] = true;
			Call_StartForward(gF_ClientInfected);
			Call_PushCell(user);
			Call_PushCell(user);
			Call_Finish();
		}
		H_FirstInfection = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_Beacon(Handle timer, int client)
{
	if(g_bBeacon[client] == true && IsValidClient(client))
	{
		float fPos[3];
		GetClientAbsOrigin(client, fPos);
		TE_SetupBeamRingPoint(fPos, 50.0, 20.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.2, 4.0, 0.0, {255, 0, 0, 255}, 0, 0);
		TE_SendToAll();	
	}
}

public Action Respawn(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		if(g_bNoRespawn[client] == false)
		{
			CS_RespawnPlayer(client);
			if(g_bInfected[client] == true)
			{
				if(gRoundType == ROUND_RIOT)
				{
					GivePlayerItem(client, "weapon_shield");
				}
				EmitSoundToAll("ze_premium/ze-respawn.mp3", client);
			}
			Call_StartForward(gF_ClientRespawned);
			Call_PushCell(client);
			Call_Finish();
		}
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
	if(IsValidClient(client))
	{
		g_bAntiDisconnect[client] = false;
	}
}

public Action SwitchTeam(Handle timer, int client)
{
	if(IsValidClient(client))
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

public Action Timer_Unfreeze(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	
	if (!IsValidClient(client) && !IsPlayerAlive(client))
		return Plugin_Handled;
	
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntityRenderColor(client);
	
	return Plugin_Handled;
}

public Action Onfire(Handle timer, int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(GetClientTeam(client) == CS_TEAM_T && g_bOnFire[client] == true)
		{
			EmitSoundToAll("ze_premium/ze-fire2.mp3", client);
		}
	}
}

public Action Slowdown(Handle timer, int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		if(g_bInfected[client] == true && g_bOnFire[client] == true)
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gPlayerZombieClass[client].speed);
			g_bOnFire[client] = false;
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

public Action EndFireHe(Handle timer, int client)
{
	g_bFireHE[client] = false;
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
						if(g_bUltimate[i] == true)
						{
							strcopy(progress, sizeof(progress), "READY TO USE (F)");
						}
						else
						{
							if(f_causeddamage[i] >= 2000)strcopy(progress, sizeof(progress), "☒☒☒☒☐");
							else if(f_causeddamage[i] >= 1000)strcopy(progress, sizeof(progress), "☒☒☒☐☐");
							else if(f_causeddamage[i] >= 500)strcopy(progress, sizeof(progress), "☒☒☐☐☐");
							else if(f_causeddamage[i] < 500)strcopy(progress, sizeof(progress), "☒☐☐☐☐");
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
	if (!IsValidEdict(entity))
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
	if (!IsValidEdict(entity))
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
	if (IsValidEdict(entity))
	{
		AcceptEntityInput(entity, "kill");
	}
}

public Action EndPower(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		i_Power[client] = 0;
		PrintHintText(client, "\n<font class='fontSize-l'><font color='#00FF00'>[ZE-Class]</font> <font color='#FF0000'>Your ultimate power has expired!");
		if (H_AmmoTimer[client] != INVALID_HANDLE)
		{
			delete H_AmmoTimer[client];
		}
	}	
}

public Action PowerOfTimer(Handle timer, int client)
{
	if (IsValidClient(client))
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
			if (IsValidEdict(Primary))
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
