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

bool bDisable;

char sTrackNow[512];

enum struct settings
{
	int id;
	bool enable;
	float volume;
	char steam[32];

	void Init(int client)
	{
		this.id = client;
		this.Reset();
	}

	void Reset()
	{
		if(!this.IsValidClient()) return;
		this.enable = false;
		this.volume = 1.0;
		this.steam = "";
	}

	bool IsValidClient()
	{
		return 0 < this.id <= MaxClients && IsClientInGame(this.id);
	}

	int GetVolume()
	{
		return RoundToNearest(this.volume * 100.0);
	}

	void Save()
	{
		char sQuery[512];
		FormatEx(sQuery, sizeof(sQuery), "UPDATE `voice_adverts` SET `volume` = '%.1f', `enable` = '%d' WHERE `steam_id` = '%s';", this.volume, this.enable, this.steam);
		hDatabase.Query(SQL_Callback_Save, sQuery);
	}
}

settings player[MAXPLAYERS+1];

#include "voice_adverts/db.sp"
#include "voice_adverts/menu.sp"

public Plugin myinfo =
{
	name = "[Any] Voice Adverts",
	author = "Nek.'a 2x2 | ggwp.site ",
	description = "Voice Adverts",
	version = "1.0.5",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	ReloadClients();
	hArray = new ArrayList(ByteCountToCells(512));
	
	cvEnable = CreateConVar("sm_voiceadverts", "1", "Включить/Выключить плагин");
	cvAdvertTime = CreateConVar("sm_voiceadverts_time", "180", "С какой переодичностью (в секундах) будут проигрываться треки");
	cvMySQL = CreateConVar("sm_voiceadverts_mysql", "0", "Хранение данных удалённо - 1; Хранение данных на сервере - 0");

	HookConVarChange(cvAdvertTime, OnConVarChanged);

	AutoExecConfig(true, "voice_adverts");

	HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i)) player[i].Init(i);

	LoadAdvSounds();

	RegConsoleCmd("sm_vr", Cmd_VoiceMenu);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar != cvAdvertTime)
		return;

	if(hAdvertTimer) delete hAdvertTimer;
	if (cvAdvertTime.FloatValue > 0.0)
		hAdvertTimer = CreateTimer(cvAdvertTime.FloatValue, Timer_PlayVoiceAdv, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnMapStart()
{
	LoadAdvSounds();
}

public void OnConfigsExecuted()
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

	bDisable = false;

	hAdvertTimer = CreateTimer(cvAdvertTime.FloatValue, Timer_PlayVoiceAdv, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public void Event_Disconnect(Event hEvent, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	player[client].Save();
	player[client].Reset();
}

void ReloadClients()
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		player[i].enable = true;
		player[i].volume = 1.0;
	}
}

Action Cmd_VoiceMenu(int client, any argc)
{
	if(!player[client].IsValidClient())
		return Plugin_Continue;
	
	MenuBase(client);

	return Plugin_Handled; 
}

public void OnClientPostAdminCheck(int client)
{
	if(IsFakeClient(client))
		return;

	player[client].Init(client);

	char sQuery[512];
	GetClientAuthId(client, AuthId_Steam2, player[client].steam, sizeof(settings::steam));

	FormatEx(sQuery, sizeof(sQuery), "SELECT `enable`, `volume` FROM `voice_adverts` WHERE `steam_id` = '%s';", player[client].steam);
	hDatabase.Query(SQL_Callback_SelectClient, sQuery, GetClientUserId(client));
}

void LoadAdvSounds()
{
	hArray.Clear();

	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/voice_adverts.ini");

	if (!FileExists(path))
	{
		ThrowError("Файл voice_adverts.ini не найден!");
		return;
	}

	File file = OpenFile(path, "r");
	if (file == null)
	{
		LogError("Ошибка при открытии файла voice_adverts.ini");
		return;
	}

	char line[512];
	int count = 0;

	while (ReadFileLine(file, line, sizeof(line)))
	{
		TrimString(line);

		if (line[0] == '/' || line[0] == '\0')
			continue;

		HandleSoundLine(line);
		count++;
	}

	delete file;
}

void HandleSoundLine(const char[] line)
{
	hArray.PushString(line);

	char path[512];
	Format(path, sizeof(path), "sound/%s", line);
	AddFileToDownloadsTable(path);

	PrecacheSound(line, true);
}

Action Timer_PlayVoiceAdv(Handle timer)
{
	if(!cvEnable.BoolValue || !hArray.Length)
		return Plugin_Continue;

	if(bDisable)
	{
		StopAllVoiceAdverts();
		return Plugin_Continue;
	}

	char sound[512];
	GetRandomAdvert(sound, sizeof(sound));
	strcopy(sTrackNow, sizeof(sTrackNow), sound);
	PlayAdvertToAll(sound);

	return Plugin_Continue;
}

void GetRandomAdvert(char[] buffer, int size)
{
	int index = GetRandomInt(0, hArray.Length - 1);
	hArray.GetString(index, buffer, size);
}

void PlayAdvertToAll(const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && player[i].enable)
		{
			EmitSoundToClient(i, sound, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, player[i].volume);
		}
	}
}

public void Event_RoundEnd(Event hEvent, const char[] name, bool dontBroadcast)
{
	bDisable = true;
	StopAllVoiceAdverts();
}

public void Event_RoundStart(Event hEvent, const char[] name, bool dontBroadcast)
{
	bDisable = false;
}

void StopAllVoiceAdverts()
{
	if(!sTrackNow[0])
		return;
	for (int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		StopSound(i, SNDCHAN_AUTO, sTrackNow);
	}
	sTrackNow = "";
}