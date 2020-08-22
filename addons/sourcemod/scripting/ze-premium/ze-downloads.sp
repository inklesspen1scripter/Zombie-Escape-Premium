stock void DownloadFiles()	{
	//	Use https://forums.alliedmods.net/showthread.php?t=303985
	
	//char file[96];
	//BuildPath(Path_SM, file, sizeof file, "configs/ze_premium-download.ini");
	//Handle fileh = OpenFile(file, "r");
	//char buffer[96];
	
	//if(fileh == INVALID_HANDLE)	CloseHandle(fileh);
	//else while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	//{
	//	TrimString(buffer);
	//	if(buffer[0])	ReadFileFolder(buffer);
	//	if (IsEndOfFile(fileh))
	//		break;
	//}
}

stock void ReadFileFolder(char[] path)
{
	//if(DirExists(path))
	//{
	//	char buffer[96];
	//	char tmp_path[96];
	//	FileType type = FileType_Unknown;
	//	int len = strcopy(tmp_path, sizeof tmp_path, path);
	//	tmp_path[len++] = '/';
	//	Handle dirh = OpenDirectory(path);
	//	while(ReadDirEntry(dirh, buffer, sizeof(buffer), type))
	//	{
	//		TrimString(buffer);

	//		if (buffer[0] && strcmp(buffer, ".", false) && strcmp(buffer, "..", false))
	//		{
	//			strcopy(tmp_path[len], sizeof tmp_path - len, buffer);
	//			if(type == FileType_File)	{
	//				if(FileExists(tmp_path)) AddFileToDownloadsTable(tmp_path);
	//			}
	//			else	ReadFileFolder(tmp_path);
	//		}
	//	}
	//	dirh.Close();
	//}
	//else
	//{
	//	AddFileToDownloadsTable(path);
	//}
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
	
	//BEACON
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow06.vmt");
}