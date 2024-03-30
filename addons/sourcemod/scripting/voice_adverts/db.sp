void Custom_SQLite()
{
	KeyValues hKv = new KeyValues("");
	hKv.SetString("driver", "sqlite");
	hKv.SetString("host", "localhost");
	hKv.SetString("database", "voice_adverts");
	hKv.SetString("user", "root");
	hKv.SetString("pass", "");
	
	char sError[255];
	hDatabase = SQL_ConnectCustom(hKv, sError, sizeof(sError), true);

	if(sError[0])
	{
		SetFailState("Ошибка подключения к локальной базе SQLite: %s", sError);
	}
	hKv.Close();

	First_ConnectionSQLite();
}

void First_ConnectionSQLite()
{
	SQL_LockDatabase(hDatabase);
	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `voice_adverts` (\
		`id` INTEGER PRIMARY KEY,\
		`enable` BOOLEAN,\
		`steam_id` VARCHAR(32),\
		'volume' REAL(3))");

	hDatabase.Query(First_ConnectionSQLite_Callback, sQuery);

	SQL_UnlockDatabase(hDatabase);
	hDatabase.SetCharset("utf8");
}

public void First_ConnectionSQLite_Callback(Database hDb, DBResultSet results, const char[] sError, any iUserID)
{
	if (hDb == null || sError[0])
	{
		SetFailState("[First_Connection] Ошибка подключения к базе: %s", sError);
		return;
	}
}

public void ConnectCallBack(Database hDB, const char[] szError, any data)
{
	if (hDB == null || szError[0])
	{
		SetFailState("[ConnectCallBack] Ошибка подключения к базе: %s", szError);
		return;
	}
	
	char sQuery[512];
	hDatabase = hDB;
	SQL_LockDatabase(hDatabase);

	FormatEx(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS `voice_adverts` (\
		`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,\
		`enable` BOOLEAN,\
		`steam_id` VARCHAR(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,\
		`volume` FLOAT(2, 1)");
	
	hDatabase.Query(SQL_Callback_Select, sQuery);

	SQL_UnlockDatabase(hDatabase);
	hDatabase.SetCharset("utf8");
}

public void SQL_Callback_Select(Database hDatabaseLocal, DBResultSet results, const char[] sError, any iUserID) // Обратный вызов
{
	if(sError[0])
	{
		LogError("SQL_Callback_Select: %s", sError);
		return;
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
		char sQuery[512];

		if(hResults.FetchRow())
		{
			Voice[client].enable = view_as<bool>(hResults.FetchInt(0));
			Voice[client].volume = hResults.FetchFloat(1);
		}
		else
		{
			FormatEx(sQuery, sizeof(sQuery), "INSERT INTO `voice_adverts` (`enable`, `steam_id`, `volume`) VALUES ('%d', '%s', '%.1f');", Voice[client].enable = true, Voice[client].steam, Voice[client].volume = 1.0);
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

void SaveSettings(DataPack hPack)
{
	hPack.Reset();
	bool enable = view_as<bool>(hPack.ReadCell());
	float volume = hPack.ReadFloat();

	char steam[32];
	hPack.ReadString(steam, sizeof(steam));
	delete hPack;

	char sQuery[512];
	FormatEx(sQuery, sizeof(sQuery), "UPDATE `voice_adverts` SET `volume` = '%.1f', `enable` = '%d' WHERE `steam_id` = '%s';", volume, enable, steam);
	hDatabase.Query(SQL_Callback_SaveSettings, sQuery);
}

public void SQL_Callback_SaveSettings(Database hDatabaseLocal, DBResultSet results, const char[] szError, any data)
{
	if(szError[0])
	{
		LogError("SQL_Callback_SaveSettings: %s", szError);
	}
}

public void SQL_Callback_CheckErrorMenu(Database hDatabaseLocal, DBResultSet results, const char[] szError, any data)
{
	if(szError[0])
	{
		LogError("SQL_Callback_CheckErrorMenu: %s", szError);
	}
}