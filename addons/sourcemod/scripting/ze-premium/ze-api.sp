void LoadNatives()	{
	CreateNative("ZR_IsInfection", Native_StartingInfection);
	CreateNative("ZR_IsSpecialround", Native_SpecialRound);
	CreateNative("ZR_RespawnAction", Native_SetRespawnAction);
	CreateNative("ZR_IsClientZombie", Native_IsInfected);
	CreateNative("ZR_IsClientHuman", Native_IsHuman);
	CreateNative("ZR_IsNemesis", Native_IsNemesis);
	CreateNative("ZR_Power", Native_GetPower);
}

public int Native_StartingInfection(Handle plugin, int argc)
{
	if (i_Infection == 0)
	{
		return false;
	}
	return true;
}

public int Native_SpecialRound(Handle plugin, int argc)
{
	return gRoundType != ROUND_NORMAL;
}

public int Native_IsInfected(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!g_bInfected[client])
	{
		return false;
	}
	return true;
}

public int Native_IsHuman(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!g_bInfected[client])
	{
		return true;
	}
	return false;
}

public int Native_IsNemesis(Handle plugin, int argc)
{
	return !strcmp(gPlayerZombieClass[GetNativeCell(1)].ident, gZombieNemesis.ident);
}

public int Native_SetRespawnAction(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!IsValidClient(client))
	{
		return;
	}
	
	g_bNoRespawn[client] = GetNativeCell(2);
}

public int Native_GetPower(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	if (!IsValidClient(client))
	{
		return -1;
	}
	
	return i_Power[client];
}

void LoadForwards()	{
	gF_ClientInfected = CreateGlobalForward("ZR_OnClientInfected", ET_Ignore, Param_Cell, Param_Cell);
	gF_ClientHumanPost = CreateGlobalForward("ZR_OnClientHumanPost", ET_Ignore, Param_Cell);
	gF_ClientRespawned = CreateGlobalForward("ZR_OnClientRespawned", ET_Ignore, Param_Cell);
}

Forward_OnClientInfected(int victim, int attacker)	{
	Call_StartForward(gF_ClientInfected);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_Finish();
}

Forward_OnClientHumanPost(int client)	{
	Call_StartForward(gF_ClientHumanPost);
	Call_PushCell(client);
	Call_Finish();
}

Forward_OnClientRespawned(int client)	{
	Call_StartForward(gF_ClientRespawned);
	Call_PushCell(client);
	Call_Finish();
}