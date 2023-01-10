#pragma semicolon 1
#pragma newdecls required

#include <sdktools_sound>
#include <sdktools_stringtables>

Database
	hDatabase;

ArrayList
	hArray;

Menu
	hMenu[2];
	
Handle
	hAdvertTimer;
	
ConVar
	cvEnable,
	cvAdvertTime,
	cvMySQL;

bool
	bEnableSound[MAXPLAYERS+1];
	
float
	fVol[MAXPLAYERS+1];

char
	sSqlInfo[3][MAXPLAYERS+1][128];
	
public Plugin myinfo =
{
	name = "[Any] Voice Adverts",
	author = "Cep>|< ( rewritten Nek.'a 2x2 | ggwp.site )",
	description = "Voice Adverts",
	version = "1.0.3",
	url = "http://www.sourcemod.net/ and https://ggwp.site/"
};

public void OnPluginStart()
{
	ReloadClients();
	hArray = new ArrayList(ByteCountToCells(256));
	
	cvEnable = CreateConVar("sm_voiceadverts", "1", "Включить/Выключить плагин");
	cvAdvertTime = CreateConVar("sm_voiceadverts_time", "180", "С какой переодичностью (в секундах) будут проигрываться треки");
	cvMySQL = CreateConVar("sm_voiceadverts_mysql", "1", "Хранение данных удалённо - 1; Хранение данных на сервере - 0");

	AutoExecConfig(true, "voiceadverts");
	
	//Database.Connect(ConnectCallBack, "voiceadverts_sqlite");
	RequestFrame(DatabaseConnect);
	
	LoadAdvSounds();
	CreatMenuEnable();
	CreatMenuVal();
	
	RegConsoleCmd("sm_vr", CmdVoiceMenu);
}

public void DatabaseConnect(any data)
{
	if(cvMySQL.BoolValue)
	{
		Database.Connect(ConnectCallBack, "voiceadverts");		//Подвключаемся к базе данных
	}
	else
	{
		Database.Connect(ConnectCallBackSqlite, "voiceadverts");		//Подвключаемся к базе данных
	}
}

void ReloadClients()
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		fVol[i] = 1.0;
		bEnableSound[i] = true;
	}
}

public Action CmdVoiceMenu(int client, any argc)
{
	if(!client || IsFakeClient(client))
		return Plugin_Continue;
		
	hMenu[0].Display(client, MENU_TIME_FOREVER);
	
	return Plugin_Handled; 
}

void CreatMenuEnable()
{
	hMenu[0] = new Menu(VoiceMenu);
	hMenu[0].SetTitle("Меню голосовой рекламы");
	
	hMenu[0].AddItem("item1", "Вкл/Выкл звук [√]");
	hMenu[0].AddItem("item2", "Изменить громкость [♫]");
}

void CreatMenuVal()
{
	hMenu[1] = new Menu(ValMenu);
	hMenu[1].SetTitle("Меню громкости рекламы");
	
	hMenu[1].AddItem("item1", "Громкость 100 [♫]");
	hMenu[1].AddItem("item2", "Громкость 80 [♫]");
	hMenu[1].AddItem("item3", "Громкость 60 [♫]");
	hMenu[1].AddItem("item4", "Громкость 40 [♫]");
	hMenu[1].AddItem("item5", "Громкость 20 [♫]");
	hMenu[1].AddItem("item6", "Громкость 0 [♫]");
}

public int VoiceMenu(Menu hMenuLocal, MenuAction action, int client, int iItem)
{
	if(action == MenuAction_Select)
	{
		switch(iItem)
		{
			case 0:
			{
				char sQuery[512], sSteam[32];
				GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam), true);
				if(bEnableSound[client] == true)
				{
					bEnableSound[client] = false;
					PrintToChat(client, "Проигрывание аудио рекламы отключено !");
					FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `enable_sound` = '%s' WHERE `steam_id` = '%s';", "0", sSteam);
				}
				else
				{
					bEnableSound[client] = true;
					PrintToChat(client, "Аудио реклама активна !");
					FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `enable_sound` = '%s' WHERE `steam_id` = '%s';", "1", sSteam);
				}
				hDatabase.Query(SQL_Callback_CheckErrorMenu, sQuery);
			}
			case 1:
			{
				hMenu[1].Display(client, 25);
			}
		}
	}
}

public void SQL_Callback_CheckErrorMenu(Database hDatabaseLocal, DBResultSet results, const char[] szError, any data)
{
	if(szError[0])
	{
		LogError("SQL_Callback_CheckError: %s", szError);
	}
}

public int ValMenu(Menu hMenuLocal, MenuAction action, int client, int iItem)
{
	if(action == MenuAction_Select)
	{
		char sQuery[512], sSteam[32];
		GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam), true);
		
		switch(iItem)
		{
			case 0:
			{
				fVol[client] = 1.0;
				PrintToChat(client, "Вы выбрали громкость в [100%]");
				FloatToString(fVol[client], sSqlInfo[1][client], sizeof(sSqlInfo[]));
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `volume` = '%s' WHERE `steam_id` = '%s';", sSqlInfo[1][client], sSteam);
				hDatabase.Query(SQL_Callback_CheckError, sQuery);
			}
			case 1:
			{
				fVol[client] = 0.8;
				PrintToChat(client, "Вы выбрали громкость в [80%]");
				FloatToString(fVol[client], sSqlInfo[1][client], sizeof(sSqlInfo[]));
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `volume` = '%s' WHERE `steam_id` = '%s';", sSqlInfo[1][client], sSteam);
				hDatabase.Query(SQL_Callback_CheckError, sQuery);
			}
			case 2:
			{
				fVol[client] = 0.6;
				PrintToChat(client, "Вы выбрали громкость в [60%]");
				FloatToString(fVol[client], sSqlInfo[1][client], sizeof(sSqlInfo[]));
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `volume` = '%s' WHERE `steam_id` = '%s';", sSqlInfo[1][client], sSteam);
				hDatabase.Query(SQL_Callback_CheckError, sQuery);
			}
			case 3:
			{
				fVol[client] = 0.4;
				PrintToChat(client, "Вы выбрали громкость в [40%]");
				FloatToString(fVol[client], sSqlInfo[1][client], sizeof(sSqlInfo[]));
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `volume` = '%s' WHERE `steam_id` = '%s';", sSqlInfo[1][client], sSteam);
				hDatabase.Query(SQL_Callback_CheckError, sQuery);
			}
			case 4:
			{
				fVol[client] = 0.2;
				PrintToChat(client, "Вы выбрали громкость в [20%]");
				FloatToString(fVol[client], sSqlInfo[1][client], sizeof(sSqlInfo[]));
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `volume` = '%s' WHERE `steam_id` = '%s';", sSqlInfo[1][client], sSteam);
				hDatabase.Query(SQL_Callback_CheckError, sQuery);
			}
			case 5:
			{
				fVol[client] = 0.0;
				PrintToChat(client, "Звук был отключен [0%] !");
				FloatToString(fVol[client], sSqlInfo[1][client], sizeof(sSqlInfo[]));
				FormatEx(sQuery, sizeof(sQuery), "UPDATE `voiceadverts` SET `volume` = '%s' WHERE `steam_id` = '%s';", sSqlInfo[1][client], sSteam);
				hDatabase.Query(SQL_Callback_CheckError, sQuery);
			}
		}
	}
}

public void SQL_Callback_CheckError(Database hDatabaseLocal, DBResultSet results, const char[] szError, any data)
{
	if(szError[0])
	{
		LogError("SQL_Callback_CheckError: %s", szError);
	}
}

public void ConnectCallBack(Database hDB, const char[] szError, any data)
{
	if (hDB == null || szError[0])
	{
		SetFailState("Ошибка подключения к базе: %s", szError);
		return;
	}
	
	char sQuery[512];
	hDatabase = hDB;
	SQL_LockDatabase(hDatabase);

	FormatEx(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `voiceadverts` (\
		`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT ,\
		`steam_id` VARCHAR(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,\
		`enable_sound` VARCHAR(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,\
		`volume` VARCHAR(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,\
		UNIQUE `id` (`id`)) ENGINE = MyISAM CHARSET=utf8 COLLATE utf8_general_ci;");
	
	hDatabase.Query(SQL_Callback_Select, sQuery);

	SQL_UnlockDatabase(hDatabase);
	hDatabase.SetCharset("utf8");
}

public void ConnectCallBackSqlite(Database hDB, const char[] szError, any data)
{
	if (hDB == null || szError[0])
	{
		SetFailState("Ошибка подключения к базе: %s", szError);
		return;
	}
	
	char sQuery[512];
	hDatabase = hDB;
	SQL_LockDatabase(hDatabase);

	FormatEx(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `voiceadverts` (\
		`id` INTEGER PRIMARY KEY,\
		`steam_id` VARCHAR(32),\
		`enable_sound` VARCHAR(32),\
		`volume` VARCHAR(32));");
	
	hDatabase.Query(SQL_Callback_Select, sQuery);

	SQL_UnlockDatabase(hDatabase);
	hDatabase.SetCharset("utf8");
}

public void SQL_Callback_Select(Database hDatabaseLocal, DBResultSet results, const char[] sError, any iUserID) // Обратный вызов
{
	if(sError[0])
	{
		LogError("SQL_Callback_SelectClient: %s", sError);
		return;
	}
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsFakeClient(client))
	{
		char sQuery[512], sSteam[32];
		GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam));
		FormatEx(sQuery, sizeof(sQuery), "SELECT `enable_sound`, `volume` FROM `voiceadverts` WHERE `steam_id` = '%s';", sSteam);	// Формируем запрос
		hDatabase.Query(SQL_Callback_SelectClient, sQuery, GetClientUserId(client)); // Отправляем запрос
	}
}

public void SQL_Callback_SelectClient(Database hDatabaseLocal, DBResultSet hResults, const char[] sError, any iUserID)
{
	if(sError[0])
	{
		LogError("SQL_Callback_SelectClient: %s", sError);
		return;
	}
	
	int client = GetClientOfUserId(iUserID);
	if(client)
	{
		char sQuery[512], sSteam[32];
		GetClientAuthId(client, AuthId_Steam2, sSteam, sizeof(sSteam));

		if(hResults.FetchRow())
		{
			//Получаем включен ли трек
			hResults.FetchString(0, sSqlInfo[0][client], sizeof(sSqlInfo[]));
			bEnableSound[client] = view_as<bool>(StringToInt(sSqlInfo[0][client]));		//Ахалай махалай
			
			//Получаем громкость звука
			hResults.FetchString(1, sSqlInfo[1][client], sizeof(sSqlInfo[]));
			fVol[client] = StringToFloat(sSqlInfo[1][client]);
			
			sSqlInfo[2][client] = sSteam;
		}
		else
		{
			sSqlInfo[0][client] = "1";
			bEnableSound[client] = true;
			sSqlInfo[1][client] = "1.0";
			fVol[client] = 1.0;
			FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `voiceadverts` (`steam_id`, `enable_sound`, `volume`) VALUES ('%s', '%s', '%s');", sSteam, sSqlInfo[0][client], sSqlInfo[1][client]);
			hDatabase.Query(SQL_Callback_CreateClient, sQuery, GetClientUserId(client));
		}
	}
}

public void SQL_Callback_CreateClient(Database hDatabaseLocal, DBResultSet results, const char[] szError, any iUserID)
{
	if(szError[0])
	{
		LogError("SQL_Callback_CreateClient: %s", szError);
		return;
	}
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
		while(!IsEndOfFile(hFile))	//Читаем до конца файла
		{
			ReadFileLine(hFile, sBuffer[0], sizeof(sBuffer[]));	//Читаем строки
			TrimString(sBuffer[0]);	//Удаляем пробелы
			
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

public void OnMapStart()
{
	if(!cvEnable.BoolValue)
		return;
	LoadAdvSounds();
	hAdvertTimer = CreateTimer(cvAdvertTime.FloatValue, PlayVoiceAdv);
}

public Action PlayVoiceAdv(Handle timer)
{
	if(!cvEnable.BoolValue)
		return;
		
	hAdvertTimer = CreateTimer(cvAdvertTime.FloatValue, PlayVoiceAdv);

	int iRnd = GetRandomInt(0, GetArraySize(hArray) - 1);
	char sSoundList[256];

	GetArrayString(hArray, iRnd, sSoundList, sizeof(sSoundList));

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		bEnableSound[i] = view_as<bool>(StringToInt(sSqlInfo[0][i]));
		fVol[i] = StringToFloat(sSqlInfo[1][i]);
		if(bEnableSound[i] == true)
			EmitSoundToClient(i, sSoundList, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, fVol[i]);
	}
}

public void OnMapEnd()
{
	delete hAdvertTimer;
}