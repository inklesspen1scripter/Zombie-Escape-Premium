void LoadConVars()	{
	g_cZEDefendModelVmt = CreateConVar("sm_ze_defend_leader_material_vmt", "materials/ze_premium/defendhere.vmt", "Model for defend material sprite/marker (VMT)");
	g_cZEDefendModelVtf = CreateConVar("sm_ze_defend_leader_material_vtf", "materials/ze_premium/defendhere.vtf", "Model for defend material sprite/marker (VTF)");
	g_cZEFollowmeModelVmt = CreateConVar("sm_ze_followme_leader_material_vmt", "materials/ze_premium/followme.vmt", "Model for followme material sprite (VMT)");
	g_cZEFollowmeModelVtf = CreateConVar("sm_ze_followme_leader_material_vtf", "materials/ze_premium/followme.vtf", "Model for followme material sprite (VTF)");
	g_cZEZMwinmodelVmt = CreateConVar("sm_ze_zombie_win_material_vmt", "materials/ze_premium/zombiewin.vmt", "Model for zombie win material sprite (VMT)");
	g_cZEZMwinmodelVtf = CreateConVar("sm_ze_zombie_win_material_vtf", "materials/ze_premium/zombiewin.vtf", "Model for zombie win material sprite (VTF)");
	g_cZEHUMANwinmodelVmt = CreateConVar("sm_ze_human_win_material_vmt", "materials/ze_premium/humanwin.vmt", "Model for human win material sprite (VMT)");
	g_cZEHUMANwinmodelVtf = CreateConVar("sm_ze_human_win_material_vtf", "materials/ze_premium/humanwin.vtf", "Model for human win material sprite (VTF)");
	g_cZEHUMANwinmodel = CreateConVar("sm_ze_human_win_material", "ze_premium/humanwin", "Model for human win material sprite (DON'T TYPE .VMT OF .VTF)");
	g_cZEZMwinmodel = CreateConVar("sm_ze_zombie_win_material", "ze_premium/zombiewin", "Model for zombie win material sprite (DON'T TYPE .VMT OF .VTF)");
	
	g_cZENemesis = CreateConVar("sm_ze_nemesis", "10", "How much chance in percent to first zombie will be nemesis, 0 = disabled");
	g_cZENemesisModel = CreateConVar("sm_ze_nemesis_model", "models/player/custom_player/ventoz/marauder/marauder.mdl", "Model of Nemesis");
	g_cZENemesisHP = CreateConVar("sm_ze_nemesis_hp", "30000", "Amout of nemesis HP");
	g_cZENemesisSpeed = CreateConVar("sm_ze_nemesis_speed", "1.7", "Amout of nemesis speed");
	g_cZENemesisGravity = CreateConVar("sm_ze_nemesis_gravity", "0.7", "Amout of nemesis gravity");
	
	g_cZEMotherZombieHP = CreateConVar("sm_ze_motherzombiehp", "20000", "Amout of mother zombie HP\nSet 0 to disable this option");

	g_cZEZombieRiots = CreateConVar("sm_ze_zombie_riot", "10", "How much chance in percent to will be zombie riot round, 0 = disabled");
	g_cZEZombieShieldType = CreateConVar("sm_ze_zombie_riot_shield", "1", "When will player get shield (1 = after infected, respawn, 0 = only after respawn)");
	
	g_cZETeleportFirstToSpawn = CreateConVar("sm_ze_teleport_first_to_spawn", "1", "0 - first zombies will not be teleported to spawn\n1 - first zombies will be teleported to spawn");
	g_cZECanChoiceClass = CreateConVar("sm_ze_can_player_choose_class", "3", "0 - Fully random\n1 - Humans can choose class\n2 - Zombies can choose class\n-1 - Everyone can choose class");
	g_cZEFirstInfection = CreateConVar("sm_ze_infection", "30", "Time to first infection");
	g_cZEHealthShot = CreateConVar("sm_ze_healthshot", "2000", "Price of healthshot");

	// HE grenade
	g_cZEHeNade = CreateConVar("sm_ze_henade", "1000", "Price of he nade");
	g_cZEHeGrenadeEffect = CreateConVar("sm_ze_hegrenade_effect", "1", "1 = enable he fire grenade, 0 = disable");

	// Molotov
	g_cZEMolotov = CreateConVar("sm_ze_molotov", "1000", "Price of molotov");

	// Freeze nade
	g_cZEFreezeNadePrice = CreateConVar("sm_ze_flashnade", "1000", "Price of flash nade");
	g_cZEFreezeNadeDistance = CreateConVar("sm_ze_freezenade_distance", "400", "Distance of freeze grenade");
	g_cZEFreezeNadeEffect = CreateConVar("sm_ze_decoy_effect", "1", "1 = enable decoy freeze grenade, 0 = disable");

	// Infection name
	g_cZEInfnade = CreateConVar("sm_ze_infnade", "2000", "Price of infection nade");
	g_cZEInfnadeusages = CreateConVar("sm_ze_infnade_usages", "1", "How many times can zombies buy this nade in 1 round (for whole team)");
	g_cZEInfnadedistance = CreateConVar("sm_ze_infnade_distance", "400", "Distance of infection grenade");
	g_cZESmokeEffect = CreateConVar("sm_ze_smoke_effect", "1", "1 = enable smoke infect grenade, 0 = disable");
	g_cZEInfectionNadeEffect = CreateConVar("sm_ze_infection_nade_effect", "1", "1 = infect player in place of infection, 0 = infect player and respawn them");

	g_cZEMaximumUsage = CreateConVar("sm_ze_maximum_usage", "2", "Maximum usage of weapon menu");
	
	g_cZEInfectionBans = CreateConVar("sm_ze_infection_bans", "2", "How many rounds ban player will get after he disconnected, when he is first zombie");
	g_cZEInfectionTime = CreateConVar("sm_ze_infection_time", "10", "How long (sec) player have to be first zombie to don't get infection ban, after he disconnected");
	g_cZEInfectionBanPlayers = CreateConVar("sm_ze_infection_ban_players", "3", "How many player have to be on server for removing infection bans on round end");
	
	g_cZEHUDInfo = CreateConVar("sm_ze_hud_information", "1", "1 = enable hud information panel, 0 = disable");
	
	g_cZEZombieSounds = CreateConVar("sm_ze_zombie_attack_sounds", "1", "1 = enable zombie attack sound, 0 = disable");
	
	g_cZEReloadingSound = CreateConVar("sm_ze_human_reloading_sound", "1", "1 = enable human reloading sound, 0 = disable");
	g_cZEReloadingSoundType = CreateConVar("sm_ze_human_reloading_sound_type", "1", "1 = emit sound to all players, 0 = emit sound only to reloading player");
	g_cZEReloadingSoundCooldown = CreateConVar("sm_ze_human_reloading_sound_cooldown", "10", "Cooldown for weapon reload");
	
	g_cZEMinConnectedPlayers = CreateConVar("sm_ze_minimum_players", "2", "Minimum of connected players on server for start the game", _, true, 2.0, true, 6.0);

	g_cZEUltimateDamageNeed = CreateConVar("sm_ze_ultimate_damage", "2000", "Damage amount to ready ultimate (0 - no need damage)", _, true, 0.0);
	g_cZEUltimateCooldown = CreateConVar("sm_ze_ultimate_cooldown", "20.0", "Ultimate cooldown (0 - no need cooldown)", _, true, 0.0);
	g_cZEUltimateTime = CreateConVar("sm_ze_ultimate_time", "6.0", "Ultimate time", _, true, 1.0);

	SetConVarAlwaysZero(FindConVar("mp_teamlimit"));
	SetConVarAlwaysZero(FindConVar("mp_autoteambalance"));
}

void SetConVarAlwaysZero(ConVar cvar)	{
	if(!cvar)	return;
	cvar.BoolValue = false;
	cvar.AddChangeHook(ResetCvarIntoZero);
}

public void ResetCvarIntoZero(ConVar cvar, const char[] oldValue, const char[] newValue)	{
	if(strcmp(newValue, "0"))	{
		cvar.BoolValue = false;
	}
}