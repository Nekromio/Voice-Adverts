void CreatMenu_Base(int client)
{
	Menu hMenu = new Menu(ShowMenu_Base);
	hMenu.SetTitle("Меню голосовой рекламы");
	
	char sBuffer[256];
	FormatEx(sBuffer, sizeof(sBuffer), "Включить звук [%s]", Voice[client].enable ? "√" : "×");
	hMenu.AddItem("item1", sBuffer);

	Format(sBuffer, sizeof(sBuffer), "Изменить громкость [%d♫]", GetVolume(client));
	hMenu.AddItem("item2", sBuffer);

	hMenu.Display(client, 40);
}

int ShowMenu_Base(Menu hMenu, MenuAction action, int client, int iItem)
{
	if(!IsValideClient(client))
		return 0;

	switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Select:
		{
			switch(iItem)
    		{
				case 0:
				{
					if(Voice[client].enable == true)
					{
						Voice[client].enable = false;
						CreatMenu_Base(client);
					}
					else
					{
						Voice[client].enable = true;
						CreatMenu_Base(client);
					}
				}
				case 1:
				{
					CreatMenu_Valume(client);
				}
			}
		}
	}
	return 0;
}

void CreatMenu_Valume(int client)
{
	Menu hMenu = new Menu(ShowMenu_Valume);
	hMenu.SetTitle("Меню громкости рекламы");
	
	hMenu.AddItem("item1", "Громкость 100 [♫]");
	hMenu.AddItem("item2", "Громкость 80 [♫]");
	hMenu.AddItem("item3", "Громкость 60 [♫]");
	hMenu.AddItem("item4", "Громкость 40 [♫]");
	hMenu.AddItem("item5", "Громкость 20 [♫]");
	hMenu.AddItem("item6", "Громкость 0 [♫]");

	hMenu.Display(client, 25);
}

int ShowMenu_Valume(Menu hMenu, MenuAction action, int client, int item)
{
	if(!IsValideClient(client))
		return 0;

	switch(action)
    {
		case MenuAction_End:
        {
            delete hMenu;
        }
		case MenuAction_Select:
		{
			switch(item)
    		{
				case 0:
				{
					Voice[client].volume = 1.0;
					CreatMenu_Base(client);
				}
				case 1:
				{
					Voice[client].volume = 0.8;
					CreatMenu_Base(client);
				}
				case 2:
				{
					Voice[client].volume = 0.6;
					CreatMenu_Base(client);
				}
				case 3:
				{
					Voice[client].volume = 0.4;
					CreatMenu_Base(client);
				}
				case 4:
				{
					Voice[client].volume = 0.2;
					CreatMenu_Base(client);
				}
				case 5:
				{
					Voice[client].volume = 0.0;
					CreatMenu_Base(client);
				}
			}
		}
	}
	return 0;
}