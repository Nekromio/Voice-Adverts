# Voice-Adverts
Voice Adverts

# en
A database connection is required

Either SQLite or MySQL

for SQLite, enter the following item in the /addons/sourcemod/configs/databases.cfg file

	"voice advertising"
	{
		"driver" "sqlite"
		"database" "voice ads"
	}

for MySQL, enter the following item in the /addons/sourcemod/configs/databases.cfg file

	"voice advertising"
	{
		"driver" "mysql"
		"host" "Your ip address"
		"database" "Name of your database"
		"user" "User name"
		"pass" "Database password"
		//"timeout" "0"
		"port" "3306"
	}


# ru
Необходимо подключение к базе данных

Либо SqLite, либо MySQL

для SqLite введите в файле /addons/sourcemod/configs/databases.cfg следующий пункт

	"voiceadverts"
	{
		"driver"			"sqlite"
		"database"			"voiceadverts"
	}
	
для MySQL введите в файле /addons/sourcemod/configs/databases.cfg следующий пункт

	"voiceadverts"
	{
		"driver"	"mysql" 
		"host"		"Ваш ip адрес" 
		"database"	"Название вашей базы данных" 
		"user"		"Имя юзера" 
		"pass"		"Пароль от базы данных" 
		//"timeout"	"0" 
		"port"		"3306"
	}
