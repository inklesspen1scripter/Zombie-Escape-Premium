void DownloadFiles()	{
	char file[96];
	BuildPath(Path_SM, file, sizeof file, "configs/ze_premium-download.ini");
	Handle fileh = OpenFile(file, "r");
	char buffer[96];
	
	if(fileh == INVALID_HANDLE)	CloseHandle(fileh);
	else while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		TrimString(buffer);
		if(buffer[0])	ReadFileFolder(buffer);
		if (IsEndOfFile(fileh))
			break;
	}
}

public ReadFileFolder(char[] path)
{
	if(DirExists(path))
	{
		char buffer[96];
		char tmp_path[96];
		FileType type = FileType_Unknown;
		int len = strcopy(tmp_path, sizeof tmp_path, path);
		tmp_path[len++] = '/';
		Handle dirh = OpenDirectory(path);
		while(ReadDirEntry(dirh, buffer, sizeof(buffer), type))
		{
			TrimString(buffer);

			if (buffer[0] && strcmp(buffer, ".", false) && strcmp(buffer, "..", false))
			{
				strcopy(tmp_path[len], sizeof tmp_path - len, buffer);
				if(type == FileType_File)	{
					if(FileExists(tmp_path)) AddFileToDownloadsTable(tmp_path);
				}
				else	ReadFileFolder(tmp_path);
			}
		}
		dirh.Close();
	}
	else
	{
		AddFileToDownloadsTable(path);
	}
}

void LoadStaticDownloads()	{
	//MODELS
	g_cZEDefendModelVmt.GetString(DEFEND, sizeof(DEFEND));
	g_cZEDefendModelVtf.GetString(DEFENDVTF, sizeof(DEFENDVTF));
	g_cZEFollowmeModelVmt.GetString(FOLLOWME, sizeof(FOLLOWME));
	g_cZEFollowmeModelVtf.GetString(FOLLOWMEVTF, sizeof(FOLLOWMEVTF));
	g_cZEZMwinmodelVmt.GetString(ZMWINS, sizeof(ZMWINS));
	g_cZEZMwinmodelVtf.GetString(ZMWINSVTF, sizeof(ZMWINSVTF));
	g_cZEHUMANwinmodelVmt.GetString(HUMANWINS, sizeof(HUMANWINS));
	g_cZEHUMANwinmodelVtf.GetString(HUMANWINSVTF, sizeof(HUMANWINSVTF));
	g_cZEHUMANwinmodel.GetString(HUMANWINSMAT, sizeof(HUMANWINSMAT));
	g_cZEZMwinmodel.GetString(ZMWINSMAT, sizeof(ZMWINSMAT));
	
	
	//DECALS
	AddFileToDownloadsTable(DEFENDVTF);
	AddFileToDownloadsTable(DEFEND);
	AddFileToDownloadsTable(FOLLOWMEVTF);
	AddFileToDownloadsTable(FOLLOWME);
	AddFileToDownloadsTable(ZMWINSVTF);
	AddFileToDownloadsTable(ZMWINS);
	AddFileToDownloadsTable(HUMANWINSVTF);
	AddFileToDownloadsTable(HUMANWINS);
	
	PrecacheDecal(ZMWINS, true);
	PrecacheDecal(ZMWINSVTF, true);
	PrecacheDecal(HUMANWINS, true);
	PrecacheDecal(HUMANWINSVTF, true);
	PrecacheDecal(DEFEND, true);
	PrecacheDecal(DEFENDVTF, true);
	PrecacheDecal(FOLLOWME, true);
	PrecacheDecal(FOLLOWMEVTF, true);
	
	PrecacheModel(DEFAULT_ARMS);
	
	//SOUNDS
	AddFileToDownloadsTable("sound/ze_premium/ze-defend.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-fire.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-fire2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-folowme.mp3");
	AddFileToDownloadsTable("sound/ze_premium/freeze.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-hit.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-die.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-die2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-die3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-ctdie.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-ctdie2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-ctdie3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-pain6.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-respawn.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesis.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesispain.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesispain2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-nemesispain3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-riotround.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanpain4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infected5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-infectionnade.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-powereffect.mp3");
	
	AddFileToDownloadsTable("sound/ze_premium/10.mp3");
	AddFileToDownloadsTable("sound/ze_premium/9.mp3");
	AddFileToDownloadsTable("sound/ze_premium/8.mp3");
	AddFileToDownloadsTable("sound/ze_premium/7.mp3");
	AddFileToDownloadsTable("sound/ze_premium/6.mp3");
	AddFileToDownloadsTable("sound/ze_premium/5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/1.mp3");
	
	//OTHER GAME SOUNDS
	AddFileToDownloadsTable("sound/ze_premium/ze-stab.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-wallhit.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash5.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-slash6.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiehit4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading3.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-reloading4.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanwin1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-humanwin2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-zombiewin.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-firstzm1.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-firstzm2.mp3");
	AddFileToDownloadsTable("sound/ze_premium/ze-firstzm3.mp3");
	
	PrecacheSound("ze_premium/ze-hit.mp3");
	PrecacheSound("ze_premium/ze-defend.mp3");
	PrecacheSound("ze_premium/ze-folowme.mp3");
	PrecacheSound("ze_premium/freeze.mp3");
	PrecacheSound("ze_premium/ze-fire.mp3");
	PrecacheSound("ze_premium/ze-fire2.mp3");
	PrecacheSound("ze_premium/ze-die.mp3");
	PrecacheSound("ze_premium/ze-die2.mp3");
	PrecacheSound("ze_premium/ze-die3.mp3");
	PrecacheSound("ze_premium/ze-ctdie.mp3");
	PrecacheSound("ze_premium/ze-ctdie2.mp3");
	PrecacheSound("ze_premium/ze-ctdie3.mp3");
	PrecacheSound("ze_premium/ze-pain.mp3");
	PrecacheSound("ze_premium/ze-pain2.mp3");
	PrecacheSound("ze_premium/ze-pain3.mp3");
	PrecacheSound("ze_premium/ze-pain4.mp3");
	PrecacheSound("ze_premium/ze-pain5.mp3");
	PrecacheSound("ze_premium/ze-pain6.mp3");
	PrecacheSound("ze_premium/ze-respawn.mp3");
	PrecacheSound("ze_premium/ze-nemesis.mp3");
	PrecacheSound("ze_premium/ze-nemesispain.mp3");
	PrecacheSound("ze_premium/ze-nemesispain2.mp3");
	PrecacheSound("ze_premium/ze-nemesispain3.mp3");
	PrecacheSound("ze_premium/ze-riotround.mp3");
	PrecacheSound("ze_premium/ze-humanpain.mp3");
	PrecacheSound("ze_premium/ze-humanpain2.mp3");
	PrecacheSound("ze_premium/ze-humanpain3.mp3");
	PrecacheSound("ze_premium/ze-humanpain4.mp3");
	
	PrecacheSound("ze_premium/10.mp3");
	PrecacheSound("ze_premium/9.mp3");
	PrecacheSound("ze_premium/8.mp3");
	PrecacheSound("ze_premium/7.mp3");
	PrecacheSound("ze_premium/6.mp3");
	PrecacheSound("ze_premium/5.mp3");
	PrecacheSound("ze_premium/4.mp3");
	PrecacheSound("ze_premium/3.mp3");
	PrecacheSound("ze_premium/2.mp3");
	PrecacheSound("ze_premium/1.mp3");
	
	//OTHERS SOUND
	PrecacheSound("ze_premium/ze-stab.mp3");
	PrecacheSound("ze_premium/ze-wallhit.mp3");
	PrecacheSound("ze_premium/ze-slash2.mp3");
	PrecacheSound("ze_premium/ze-slash1.mp3");
	PrecacheSound("ze_premium/ze-slash3.mp3");
	PrecacheSound("ze_premium/ze-slash4.mp3");
	PrecacheSound("ze_premium/ze-slash5.mp3");
	PrecacheSound("ze_premium/ze-slash6.mp3");
	PrecacheSound("ze_premium/ze-zombiehit1.mp3");
	PrecacheSound("ze_premium/ze-zombiehit2.mp3");
	PrecacheSound("ze_premium/ze-zombiehit3.mp3");
	PrecacheSound("ze_premium/ze-zombiehit4.mp3");
	PrecacheSound("ze_premium/ze-reloading1.mp3");
	PrecacheSound("ze_premium/ze-reloading2.mp3");
	PrecacheSound("ze_premium/ze-reloading3.mp3");
	PrecacheSound("ze_premium/ze-reloading4.mp3");
	PrecacheSound("ze_premium/ze-humanwin1.mp3");
	PrecacheSound("ze_premium/ze-humanwin2.mp3");
	PrecacheSound("ze_premium/ze-zombiewin.mp3");
	PrecacheSound("ze_premium/ze-firstzm1.mp3");
	PrecacheSound("ze_premium/ze-firstzm2.mp3");
	PrecacheSound("ze_premium/ze-firstzm3.mp3");
	PrecacheSound("ze_premium/ze-infected1.mp3");
	PrecacheSound("ze_premium/ze-infected2.mp3");
	PrecacheSound("ze_premium/ze-infected3.mp3");
	PrecacheSound("ze_premium/ze-infected4.mp3");
	PrecacheSound("ze_premium/ze-infected5.mp3");
	PrecacheSound("ze_premium/ze-infectionnade.mp3");
	PrecacheSound("ze_premium/ze-powereffect.mp3");
	
	//BEACON
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
}