void MenuBase(int client)
{
	Menu hMenu = new Menu(ShowMenu_Callback);
	hMenu.SetTitle("Меню голосовой рекламы");
	
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "Включить звук [%s]", player[client].enable ? "√" : "×");
	hMenu.AddItem("item1", sBuffer);

	Format(sBuffer, sizeof(sBuffer), "Изменить громкость [%d♫]", player[client].GetVolume());
	hMenu.AddItem("item2", sBuffer);

	hMenu.Display(client, 40);
}

int ShowMenu_Callback(Menu hMenu, MenuAction action, int client, int iItem)
{
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
					player[client].enable = !player[client].enable;
					MenuBase(client);
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
	Menu hMenu = new Menu(MenuValume_Callback);
	hMenu.SetTitle("Меню громкости рекламы");

	for (int i = 0; i <= 5; i++)
	{
		char text[64];
		int volume = 100 - (i * 20);
		Format(text, sizeof(text), "Громкость %d [♫]", volume);
		hMenu.AddItem("", text);
	}

	hMenu.ExitBackButton = true;

	hMenu.Display(client, 25);
}

int MenuValume_Callback(Menu hMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Select:
		{
			float volume = 1.0 - (0.2 * item);
			player[client].volume = volume;
			MenuBase(client);
		}
		case MenuAction_Cancel:
		{
			if(item == MenuCancel_ExitBack)
			{
            	MenuBase(client);
        	}
   		}
	}
	return 0;
}