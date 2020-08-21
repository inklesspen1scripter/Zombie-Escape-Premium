#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Sniper007 & inklesspen"
#define PLUGIN_VERSION "8.0DV1"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors>
#include <clientprefs>
#include <smlib>
#include <sdkhooks>
#include <zepremium>
#include <emitsoundany>

native bool entWatch_IsSpecialItem(int entity);
native bool EntWatch_IsSpecialItem(int entity);

#include "ze-premium/ze-globals.sp"
#include "ze-premium/ze-classes.sp"
#include "ze-premium/ze-hooks.sp"
#include "ze-premium/ze-commands.sp"
#include "ze-premium/ze-convars.sp"
#include "ze-premium/ze-stocks.sp"
#include "ze-premium/ze-client.sp"
#include "ze-premium/ze-timers.sp"
#include "ze-premium/ze-database.sp"
#include "ze-premium/ze-downloads.sp"
#include "ze-premium/ze-events.sp"
#include "ze-premium/ze-menus.sp"
#include "ze-premium/ze-api.sp"
#include "ze-premium/ze-keyvalues.sp"

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Zombie Escape Premium-Dev", 
	author = PLUGIN_AUTHOR, 
	description = "Zombie escape plugin with new features", 
	version = PLUGIN_VERSION, 
	url = "https://github.com/inklesspen1scripter/Zombie-Escape-Premium"
};

public void OnPluginStart()
{
	LoadEvents();
	LoadConVars();
	LoadCommands();
	LoadForwards();

	PrepareClasses();
	LoadTranslations("ZE-Premium");
	
	gWeaponList1 = new ArrayList(ByteCountToCells(32));
	gWeaponList2 = new ArrayList(ByteCountToCells(32));
	g_hZombieClass = RegClientCookie("zombie_class_chosen", "", CookieAccess_Private);
	g_hHumanClass = RegClientCookie("human_class_chosen", "", CookieAccess_Private);
	g_hSavedWeapons = new Cookie("ze_weapon_selected", "", CookieAccess_Private);
	
	CreateTimer(1.0, HUD, _, TIMER_REPEAT);
	CreateTimer(5.0, PointsCheck, _, TIMER_REPEAT);
	
	AddNormalSoundHook(SoundHook);
	
	AutoExecConfig(true, "ze_premium");
	Database.Connect(SQL_Connection, "ze_premium_sql");
}

public void OnConfigsExecuted()	{
	LoadConVarClasses();
}

public void SQL_Error(Database hDatabase, DBResultSet hResults, const char[] szError, int iData)
{
	if (hResults == null)
	{
		ThrowError(szError);
	}
}

public void SQL_Connection(Database hDatabase, const char[] szError, int iData)
{
	if (hDatabase == null)
	{
		ThrowError(szError);
	}
	else
	{
		g_hDatabase = hDatabase;
		//Tady si většinou vytváříš tabulku, pokud ji ještě nemáš, toto doporučuji vždy dělat - taková kontrola, jestli ti to funguje, když se tabulka vytvoří, tak si cajk
		g_hDatabase.Query(SQL_Error, "CREATE TABLE IF NOT EXISTS ze_premium_sql ( `id` INT NOT NULL AUTO_INCREMENT , `lastname` VARCHAR(128) NOT NULL DEFAULT 'N/A' , `steamid` VARCHAR(64) NOT NULL , `humanwins` INT(128) NOT NULL , `infected` INT(128) NOT NULL , `killedzm` INT(128) NOT NULL , `infectionban` INT(128) NOT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;");
		g_hDatabase.SetCharset("utf8mb4");
		PrintToServer("[MySQL] Ze Premium-SQL connected.");
	}
}

// Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Natives
	LoadNatives(); // Natives
	
	MarkNativeAsOptional("entWatch_IsSpecialItem");
	MarkNativeAsOptional("EntWatch_IsSpecialItem");

	RegPluginLibrary("zepremium");
	
	return APLRes_Success;
}

bool IsSpecialItem(int entity)	{
	if(CanTestFeatures())	{
		if(GetFeatureStatus(FeatureType_Native, "entWatch_IsSpecialItem") == FeatureStatus_Available)
		return entWatch_IsSpecialItem(entity);
		if(GetFeatureStatus(FeatureType_Native, "EntWatch_IsSpecialItem") == FeatureStatus_Available)
		return EntWatch_IsSpecialItem(entity);
	}
	return false;
}

public Action Command_CheckJoin(int client, const char[] command, int args)
{
	char teamString[3];
	GetCmdArg(1, teamString, sizeof(teamString));
	
	int newTeam = StringToInt(teamString);
	int oldTeam = GetClientTeam(client);
	
	if (newTeam == 3 && oldTeam == 2)
	{
		PrintToChat(client, " \x04[Zombie Escape]\x01 You can't change your team!");
		return Plugin_Handled;	
	}
	else if (newTeam == 2 && oldTeam == 3)
	{
		PrintToChat(client, " \x04[Zombie Escape]\x01 You can't change your team!");
		return Plugin_Handled;	
	}
	return Plugin_Continue;
}

public void OnMapStart()
{
	char g_sZEConfig[PLATFORM_MAX_PATH];
	char sBuffer[32];
	gWeaponList1.Clear();
	gWeaponList2.Clear();
	BuildPath(Path_SM, g_sZEConfig, sizeof(g_sZEConfig), "configs/ze_premium/weapons.cfg");
	KeyValues kv = new KeyValues("Weapons");
	kv.ImportFromFile(g_sZEConfig);
	kv.Rewind();
	if(kv.JumpToKey("primary", false))	{
		if(kv.GotoFirstSubKey(false))	{
			do	{
				kv.GetString(NULL_STRING, sBuffer, sizeof sBuffer, "");
				if(sBuffer[0] && CS_IsValidWeaponID(CS_AliasToWeaponID(sBuffer)))
					gWeaponList1.PushString(sBuffer);
				}	while(kv.GotoNextKey(false));
			kv.GoBack();
		}
		kv.GoBack();
	}

	if(!gWeaponList1.Length){
		gWeaponList1.PushString("ak47");
		gWeaponList1.PushString("m4a1");
	}

	if(kv.JumpToKey("secondary", false))	{
		if(kv.GotoFirstSubKey(false))	{
			do	{
				kv.GetString(NULL_STRING, sBuffer, sizeof sBuffer, "");
				if(sBuffer[0] && CS_IsValidWeaponID(CS_AliasToWeaponID(sBuffer)))
					gWeaponList2.PushString(sBuffer);
				}	while(kv.GotoNextKey(false));
			kv.GoBack();
		}
		kv.GoBack();
	}

	if(!gWeaponList2.Length){
		gWeaponList2.PushString("glock");
	}
	kv.Close();

	LoadClasses();
	
	//AUTOMATIC DOWNLOAD
	LoadStaticDownloads();
	DownloadFiles();
	
	g_bRoundStarted = false;
	g_bPause = false;
	g_bRoundEnd = false;
	g_bWaitingForPlayer = false;
	H_FirstInfection = INVALID_HANDLE;
}

/*
	TODO:
	Make gun menu like francisco
	Ability to define with cvar Ultimate power button
	!voteleader
*/