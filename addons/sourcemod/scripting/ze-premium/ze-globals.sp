#define FREEZE_SOUND "ze_premium/freeze.mp3"
#define DEFAULT_ARMS "models/weapons/ct_arms_gign.mdl"

//GRENADES
#define FragColor 	{255,75,75,255}
#define FlashColor	{0,255,255,255}
#define SmokeColor	{0,255,0,255}
#define SMOKE 1
char g_iaGrenadeOffsets[] = {15, 17, 16, 14, 18, 17};

//COKIES
Handle g_hHumanClass;
Handle g_hZombieClass;
Cookie g_hSavedWeapons;

//FORWARDS
Handle gF_ClientInfected;
Handle gF_ClientRespawned;
Handle gF_ClientHumanPost;

//TIMERS
Handle H_FirstInfection;
Handle H_AmmoTimer[MAXPLAYERS + 1];

int g_iBeamSprite;
int g_iHaloSprite;

ConVar g_cZECanChoiceClass;
ConVar g_cZEFirstInfection;
ConVar g_cZEHealthShot;
ConVar g_cZEHeNade;
ConVar g_cZEFreezeNadePrice;
ConVar g_cZEMolotov;
ConVar g_cZEMaximumUsage;
ConVar g_cZEMotherZombieHP;
ConVar g_cZEDefendModelVmt;
ConVar g_cZEDefendModelVtf;
ConVar g_cZEFollowmeModelVmt;
ConVar g_cZEFollowmeModelVtf;
ConVar g_cZETeleportFirstToSpawn;
ConVar g_cZENemesis;
ConVar g_cZENemesisModel;
ConVar g_cZENemesisHP;
ConVar g_cZENemesisSpeed;
ConVar g_cZENemesisGravity;
ConVar g_cZEZombieRiots;
ConVar g_cZEZombieShieldType;
ConVar g_cZEHeGrenadeEffect;
ConVar g_cZEFreezeNadeEffect;
ConVar g_cZESmokeEffect;
ConVar g_cZEInfnade;
ConVar g_cZEInfnadeusages;
ConVar g_cZEReloadingSoundCooldown;
ConVar g_cZEInfnadedistance;
ConVar g_cZEFreezeNadeDistance;
ConVar g_cZEInfectionBans;
ConVar g_cZEInfectionTime;
ConVar g_cZEInfectionBanPlayers;
ConVar g_cZEHUDInfo;
ConVar g_cZEZombieSounds;
ConVar g_cZEZMwinmodelVmt;
ConVar g_cZEZMwinmodelVtf;
ConVar g_cZEHUMANwinmodelVmt;
ConVar g_cZEHUMANwinmodelVtf;
ConVar g_cZEHUMANwinmodel;
ConVar g_cZEZMwinmodel;
ConVar g_cZEReloadingMaxHuman;
ConVar g_cZEReloadingSound;
ConVar g_cZEReloadingSoundType;
ConVar g_cZEMinConnectedPlayers;
ConVar g_cZEInfectionNadeEffect;
ConVar g_cZEUltimateDamageNeed;
ConVar g_cZEUltimateCooldown;
ConVar g_cZEUltimateTime;

ArrayList gWeaponList1;
ArrayList gWeaponList2;

enum struct ZombieClass	{
	char ident[32];
	char name[96];
	char desc[96];

	char model[96];
	char arms[96];

	int health;
	float gravity;
	float speed;

	int access;
	bool hidden;
}
ArrayList gZombieClasses;

enum struct HumanClass	{
	char ident[32];
	char name[96];
	char desc[96];

	char model[96];

	int health;
	float gravity;
	float speed;
	int power;
	int protection;
	char item[64];

	int access;
	bool hidden;
}
ArrayList gHumanClasses;
int gPlayerSelectedClass[MAXPLAYERS + 1][2];
ZombieClass gPlayerZombieClass[MAXPLAYERS + 1];
HumanClass gPlayerHumanClass[MAXPLAYERS + 1];

ZombieClass gZombieNemesis;

Database g_hDatabase;

//MODELS
char DEFEND[128], DEFENDVTF[128];
char FOLLOWME[128], FOLLOWMEVTF[128];
char ZMWINS[128], HUMANWINS[128];
char ZMWINSVTF[128], HUMANWINSVTF[128];
char HUMANWINSMAT[128], ZMWINSMAT[128];

//GUNS
char Primary_Gun[MAXPLAYERS + 1][32];
char Secondary_Gun[MAXPLAYERS + 1][32];
int i_Maximum_Choose[MAXPLAYERS + 1];
bool g_bSamegun[MAXPLAYERS + 1] = false;

//LEADER
int i_spriteEntities[MAXPLAYERS + 1];
int i_markerEntities[MAXPLAYERS + 1];
int i_typeofsprite[MAXPLAYERS + 1];
bool g_bMarker = false;
bool g_bIsLeader[MAXPLAYERS + 1] = false;
bool g_bBeacon[MAXPLAYERS + 1] = false;
Handle H_Beacon[MAXPLAYERS + 1];

//ZOMBIES
enum ROUNDTYPE	{
	ROUND_NORMAL,
	ROUND_RIOT,
	ROUND_NEMESIS
};
ROUNDTYPE gRoundType;

bool g_bInfected[MAXPLAYERS + 1] = false;
int i_pause[MAXPLAYERS + 1];
bool g_bFirstInfected[MAXPLAYERS + 1] = false;
bool g_bWasFirstInfected[MAXPLAYERS + 1];
bool g_bNoRespawn[MAXPLAYERS + 1] = false;
bool g_bAntiDisconnect[MAXPLAYERS + 1] = false;
char Zombie_Arms[MAXPLAYERS + 1][PLATFORM_MAX_PATH + 1];

//CLASSES
Handle gPlayerUltimateTimer[MAXPLAYERS + 1];
int i_Power[MAXPLAYERS + 1];
int i_protection[MAXPLAYERS + 1];
float f_causeddamage[MAXPLAYERS + 1];
float gPlayerNextUltimate[MAXPLAYERS + 1];
Handle H_Respawntimer[MAXPLAYERS + 1];
bool g_bRoundEnd = false;

//GAME
int i_Infection;
bool g_bWaitingForPlayer = false;
bool g_bRoundStarted = false;
bool g_bPause = false;
int i_respawn[MAXPLAYERS + 1];
int i_infectionban[MAXPLAYERS + 1];
float gPlayerNextReloadSound[MAXPLAYERS + 1];

int g_iSoundEnts[2048];
int g_iNumSounds;

//SHOP
bool g_bOnFire[MAXPLAYERS + 1] = false;
int spended[MAXPLAYERS + 1];
int i_binfnade;

//DATABASE
int i_wins[MAXPLAYERS + 1];
int i_infected[MAXPLAYERS + 1];
int i_killedzm[MAXPLAYERS + 1];
int i_hwins[MAXPLAYERS + 1];
int i_infectedh[MAXPLAYERS + 1];