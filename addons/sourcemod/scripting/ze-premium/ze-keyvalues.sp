void SetZombie(int client, bool respawn = false, bool first = false, bool nemesis = false)
{
	g_bInfected[client] = true;
	Sound_EmitToAll("respawn", client);
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

void ApplyPlayerZombieClass(int client, ZombieClass zc)	{
	gPlayerZombieClass[client] = zc;

	g_bInfected[client] = true;
	CS_SwitchTeam(client, CS_TEAM_T);
	CS_UpdateClientModel(client);

	if(zc.arms[0])
	{
		strcopy(Zombie_Arms[client], sizeof Zombie_Arms[], zc.arms);
		CreateTimer(0.7, SetArms, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	SetEntityHealth(client, zc.health);
	SetEntityGravity(client, zc.gravity);
	SetEntityModel(client, zc.model);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", zc.speed);

	StripPlayer(client);
	int tmp = GivePlayerItem2(client, "weapon_knife");
	if(tmp != -1)	{
		char sBuffer[24];
		GetEdictClassname(tmp, sBuffer, sizeof sBuffer);
		FakeClientCommand(client, "use %s", sBuffer);
	}
}

void ApplyPlayerHumanClass(int client, HumanClass hc)	{
	gPlayerHumanClass[client] = hc;
	
	g_bInfected[client] = false;
	if(g_bRoundStarted)	CS_SwitchTeam(client, CS_TEAM_CT);
	CS_UpdateClientModel(client);

	CreateTimer(0.7, SetArms, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

	if(hc.item[0])
	{
		char buffer2[sizeof hc.item];
		strcopy(buffer2, sizeof buffer2, hc.item);
		char buffer[32] = "weapon_";
		for(int pos = FindCharInString(buffer2, ';', true);;pos = FindCharInString(buffer2, ';', true))	{
			strcopy(buffer[7], sizeof buffer - 7, buffer2[pos + 1]);
			GivePlayerItem2(client, buffer);
			if(pos != -1)	buffer2[pos] = 0;
			else	break;
		}
	}

	i_protection[client] = hc.protection;
	SetEntityHealth(client, hc.health);
	SetEntityGravity(client, hc.gravity);
	SetEntityModel(client, hc.model);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", hc.speed);
}