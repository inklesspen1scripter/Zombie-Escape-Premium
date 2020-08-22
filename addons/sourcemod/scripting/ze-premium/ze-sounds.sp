void LoadSounds()	{
	int tableindex = FindStringTable("soundprecache");
	StringMapSnapshot snap = gSoundList.Snapshot();
	char sBuffer[96];
	ArrayList list;
	for(int i = snap.Length - 1;i != -1;i--)	{
		snap.GetKey(i, sBuffer, sizeof sBuffer);
		gSoundList.GetValue(sBuffer, list);
		list.Close();
	}
	snap.Close();
	gSoundList.Clear();

	KeyValues kv = new KeyValues("sounds");
	BuildPath(Path_SM, sBuffer, sizeof sBuffer, "configs/ze_premium/sounds.cfg");
	kv.ImportFromFile(sBuffer);
	strcopy(sBuffer, sizeof sBuffer, "sound/");
	if(kv.GotoFirstSubKey(false))	{
		do
		{
			kv.GetSectionName(sBuffer[6], sizeof sBuffer - 6);
			if(!gSoundList.GetValue(sBuffer[6], list))
			{
				list = new ArrayList(ByteCountToCells(96));
				gSoundList.SetValue(sBuffer[6], list);
			}
			kv.GetString(NULL_STRING, sBuffer[6], sizeof sBuffer - 6, "");
			if(!sBuffer[6])	continue;
			if(list.FindString(sBuffer) == -1)	{
				list.PushString(sBuffer);
				AddToStringTable(tableindex, sBuffer);
			}
		}	while(kv.GotoNextKey(false));
	}
	kv.Close();
}

stock bool GetSound(const char[] key, char[] sound, int max)	{
	ArrayList list;
	if(!gSoundList.GetValue(key, list))
		return false;
	int size = list.Length;
	if(!size)	return false;
	list.GetString(GetRandomInt(0, size - 1), sound, max);
	return true;
}

stock void Sound_Emit(const int[] clients,
				 int numClients,
				 const char[] sample,
				 int entity = SOUND_FROM_PLAYER,
				 int channel = SNDCHAN_AUTO,
				 int level = SNDLEVEL_NORMAL,
				 int flags = SND_NOFLAGS,
				 float volume = SNDVOL_NORMAL,
				 int pitch = SNDPITCH_NORMAL,
				 int speakerentity = -1,
				 const float origin[3] = NULL_VECTOR,
				 const float dir[3] = NULL_VECTOR,
				 bool updatePos = true,
				 float soundtime = 0.0)	{
	char sBuffer[96];
	if(!GetSound(sample, sBuffer, sizeof sBuffer))	return;
	EmitSound(clients, numClients, sBuffer, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

stock void Sound_EmitToClient(int client,
				 const char[] sample,
				 int entity = SOUND_FROM_PLAYER,
				 int channel = SNDCHAN_AUTO,
				 int level = SNDLEVEL_NORMAL,
				 int flags = SND_NOFLAGS,
				 float volume = SNDVOL_NORMAL,
				 int pitch = SNDPITCH_NORMAL,
				 int speakerentity = -1,
				 const float origin[3] = NULL_VECTOR,
				 const float dir[3] = NULL_VECTOR,
				 bool updatePos = true,
				 float soundtime = 0.0)
{
	int clients[1];
	clients[0] = client;
	/* Save some work for SDKTools and remove SOUND_FROM_PLAYER references */
	entity = (entity == SOUND_FROM_PLAYER) ? client : entity;
	Sound_Emit(clients, 1, sample, entity, channel,
		level, flags, volume, pitch, speakerentity,
		origin, dir, updatePos, soundtime);
}

stock void Sound_EmitToAll(const char[] sample,
				 int entity = SOUND_FROM_PLAYER,
				 int channel = SNDCHAN_AUTO,
				 int level = SNDLEVEL_NORMAL,
				 int flags = SND_NOFLAGS,
				 float volume = SNDVOL_NORMAL,
				 int pitch = SNDPITCH_NORMAL,
				 int speakerentity = -1,
				 const float origin[3] = NULL_VECTOR,
				 const float dir[3] = NULL_VECTOR,
				 bool updatePos = true,
				 float soundtime = 0.0)
{
	int[] clients = new int[MaxClients];
	int total = 0;

	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			clients[total++] = i;
		}
	}

	if (total)
	{
		Sound_Emit(clients, total, sample, entity, channel,
			level, flags, volume, pitch, speakerentity,
			origin, dir, updatePos, soundtime);
	}
}