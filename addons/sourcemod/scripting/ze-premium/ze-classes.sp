void LoadClasses()	{
	char g_sZEConfig[PLATFORM_MAX_PATH];
	char flags[40];
	gZombieClasses.Clear();
	KeyValues kv = new KeyValues("zombies_classes");
	BuildPath(Path_SM, g_sZEConfig, sizeof(g_sZEConfig), "configs/ze_premium/zombies_classes.cfg");
	kv.ImportFromFile(g_sZEConfig);
	ZombieClass zc;
	if(!kv.GotoFirstSubKey(true))	kv.JumpToKey("default", true);
	do	{
		zc.health = kv.GetNum("health", 10000);
		zc.speed = kv.GetFloat("speed", 1.2);
		zc.gravity = kv.GetFloat("gravity", 1.0);
		kv.GetString("name", zc.name, sizeof zc.name, "Default");
		kv.GetString("model_path", zc.model, sizeof zc.model, "models/player/custom_player/kodua/frozen_nazi/frozen_nazi.mdl");
		if(!FileExists(zc.model, true))	zc.model[0] = 0;
		kv.GetString("arms_path", zc.arms, sizeof zc.arms, "models/player/custom_player/kodua/frozen_nazi/arms.mdl");
		if(!FileExists(zc.arms, true))	zc.arms[0] = 0;
		kv.GetSectionName(zc.ident, sizeof zc.ident);

		if(zc.arms[0])	PrecacheModel(zc.arms, true);
		if(zc.model[0])	PrecacheModel(zc.model, true);

		kv.GetString("flags", flags, sizeof flags, "");
		zc.access = ReadFlagString(flags) | ADMFLAG_ROOT;

		gZombieClasses.PushArray(zc, sizeof zc);
	}	while(kv.GotoNextKey(true));
	kv.Close();

	gHumanClasses.Clear();
	kv = new KeyValues("humans_classes");
	BuildPath(Path_SM, g_sZEConfig, sizeof(g_sZEConfig), "configs/ze_premium/humans_classes.cfg");
	kv.ImportFromFile(g_sZEConfig);
	HumanClass hc;
	char power[32];
	if(!kv.GotoFirstSubKey(true))	kv.JumpToKey("default", true);
	do	{
		hc.health = kv.GetNum("health", 100);
		hc.protection = kv.GetNum("protection", 0);
		hc.speed = kv.GetFloat("speed", 1.0);
		hc.gravity = kv.GetFloat("gravity", 1.0);
		kv.GetString("item", hc.item, sizeof hc.item, "");
		kv.GetString("name", hc.name, sizeof hc.name, "Default");
		kv.GetString("model_path", hc.model, sizeof hc.model, "");
		if(!FileExists(hc.model, true))	hc.model[0] = 0;
		kv.GetSectionName(hc.ident, sizeof hc.ident);

		if(hc.model[0])	PrecacheModel(hc.model, true);

		kv.GetString("power", power, sizeof power);
		hc.power = GetPowerIDByName(power);

		kv.GetString("flags", flags, sizeof flags, "");
		hc.access = ReadFlagString(flags) | ADMFLAG_ROOT;

		gHumanClasses.PushArray(hc, sizeof hc);
	}	while(kv.GotoNextKey(true));
	kv.Close();
}

GetHumanClass(int item, HumanClass hc)	{
	gHumanClasses.GetArray(item, hc, sizeof hc);
}

GetZombieClass(int item, ZombieClass zc)	{
	gZombieClasses.GetArray(item, zc, sizeof zc);
}

FindZombieClassID(const char[] ident)	{
	ZombieClass zc;
	for(int i = gZombieClasses.Length-1;i!=-1;i--)	{
		gZombieClasses.GetArray(i, zc, sizeof zc);
		if(!strcmp(ident, zc.ident))	return i;
	}
	return -1;
}

FindHumanClassID(const char[] ident)	{
	HumanClass hc;
	for(int i = gHumanClasses.Length-1;i!=-1;i--)	{
		gHumanClasses.GetArray(i, hc, sizeof hc);
		if(!strcmp(ident, hc.ident))	return i;
	}
	return -1;
}