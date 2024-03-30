#pragma semicolon 1
#pragma newdecls required

#include <sdktools_sound>
#include <sdktools_stringtables>

Database
	hDatabase;

ArrayList
	hArray;

Handle
	hAdvertTimer;
	
ConVar
	cvEnable,
	cvAdvertTime,
	cvMySQL;

enum struct Data
{
	bool enable;
	float volume;
	char steam[32];
}

Data Voice[MAXPLAYERS+1];

#include "voice_adverts/db.sp"
#include "voice_adverts/menu.sp"

public Plugin myinfo =
{
	name = "[Any] Voice Adverts",
	author = "Nek.'a 2x2 | ggwp.site ",
	description = "Voice Adverts",
	version = "1.0.4",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	ReloadClients();
	hArray = new ArrayList(ByteCountToCells(256));
	
	cvEnable = CreateConVar("sm_voiceadverts", "1", "Включить/Выключить плагин");
	cvAdvertTime = CreateConVar("sm_voiceadverts_time", "180", "С какой переодичностью (в секундах) будут проигрываться треки");
	cvMySQL = CreateConVar("sm_voiceadverts_mysql", "0", "Хранение данных удалённо - 1; Хранение данных на сервере - 0");

	AutoExecConfig(true, "voice_adverts");

	LoadAdvSounds();

	RegConsoleCmd("sm_vr", CmdVoiceMenu);
}

public void OnMapStart()
{
	if(!cvEnable.BoolValue)
		return;
	
	if(cvMySQL.BoolValue)
	{
		Database.Connect(ConnectCallBack, "voice_adverts");
	}
	else
	{
		Custom_SQLite();
	}
	
	LoadAdvSounds();
	hAdvertTimer = CreateTimer(cvAdvertTime.FloatValue, PlayVoiceAdv);
}

public void OnClientDisconnect(int client)
{
	DataPack hPack = new DataPack();
	hPack.WriteCell(view_as<int>(Voice[client].enable));
	hPack.WriteFloat(Voice[client].volume);
	hPack.WriteString(Voice[client].steam);
	SaveSettings(hPack);
}

void ReloadClients()
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		Voice[i].enable = true;
		Voice[i].volume = 1.0;
	}
}

Action CmdVoiceMenu(int client, any argc)
{
	if(!IsValideClient(client))
		return Plugin_Continue;
	
	CreatMenu_Base(client);

	return Plugin_Handled; 
}

int GetVolume(int client)
{
	switch(Voice[client].volume)
	{
		case 1.0: return 100;
		case 0.8: return 80;
		case 0.6: return 60;
		case 0.4: return 40;
		case 0.2: return 20;
		case 0.0: return 0;
	}
	return 0;
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsValideClient(client))
		return;

	char sQuery[512];
	GetClientAuthId(client, AuthId_Steam2, Voice[client].steam, sizeof(Data::steam));

	FormatEx(sQuery, sizeof(sQuery), "SELECT `enable`, `volume` FROM `voice_adverts` WHERE `steam_id` = '%s';", Voice[client].steam);
	hDatabase.Query(SQL_Callback_SelectClient, sQuery, GetClientUserId(client));
}

void LoadAdvSounds()
{
	hArray.Clear();
	char sConfigFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sConfigFile, sizeof(sConfigFile), "configs/voice_adverts.ini");
	
	if(!FileExists(sConfigFile))
		LogMessage("Файл voice_adverts.ini не найден !");
	else
	{
		Handle hFile = OpenFile(sConfigFile, "r");
		char sBuffer[2][256];
		while(!IsEndOfFile(hFile))
		{
			ReadFileLine(hFile, sBuffer[0], sizeof(sBuffer[]));
			TrimString(sBuffer[0]);
			
			if(sBuffer[0][0] == '/' || sBuffer[0][0] == '\0')
				continue;

			hArray.PushString(sBuffer[0]);
			
			Format(sBuffer[1], sizeof(sBuffer[]), "sound/%s", sBuffer[0]);
			AddFileToDownloadsTable(sBuffer[1]);
			if(sBuffer[0][0]) PrecacheSound(sBuffer[0], true);
 		}
		CloseHandle(hFile);
	}
}

Action PlayVoiceAdv(Handle timer)
{
	if(!cvEnable.BoolValue)
		return Plugin_Continue;
		
	hAdvertTimer = CreateTimer(cvAdvertTime.FloatValue, PlayVoiceAdv);

	int iRnd = GetRandomInt(0, GetArraySize(hArray) - 1);
	char sSoundList[256];
	GetArrayString(hArray, iRnd, sSoundList, sizeof(sSoundList));

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i) && Voice[i].enable == true)
	{
		EmitSoundToClient(i, sSoundList, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, Voice[i].volume);
	}

	return Plugin_Continue;
}

public void OnMapEnd()
{
	hArray.Clear();
	delete hAdvertTimer;
}

bool IsValideClient(int client)
{
	return 0 < client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client);
}