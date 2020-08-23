void LoadShop()	{
	ShopItem item;

	gShopMemory.Clear();
	gShopItems.Clear();
	gShopHumanItems = 0;
	KeyValues kv = new KeyValues("shop");
	char sBuffer[96];
	BuildPath(Path_SM, sBuffer, sizeof sBuffer, "configs/ze_premium/shop.cfg");
	kv.Rewind();
	if(kv.JumpToKey("human", false) && kv.GotoFirstSubKey(true))	{
		do	{
			kv.GetSectionName(item.ident, sizeof item.ident);
			kv.GetString("name", item.name, sizeof item.name, "");
			if(!item.name[0])	{
				LogError("Shop item \"%s\" has no name", item.ident);
				continue;
			}
			item.price = kv.GetNum("price", 0);
			kv.GetString("access", sBuffer, sizeof sBuffer, "");
			if(sBuffer[0])	item.access = ReadFlagString(sBuffer) | ADMFLAG_ROOT;
			else	item.access = 0;
			item.type = 0;
			item.id = gShopItems.Length;
			gShopItems.PushArray(item, sizeof item); gShopHumanItems++;
		}
		while(kv.GotoNextKey(true));
	}
	kv.Rewind();
	if(kv.JumpToKey("zombie", false) && kv.GotoFirstSubKey(true))	{
		do	{
			kv.GetSectionName(item.ident, sizeof item.ident);
			kv.GetString("name", item.name, sizeof item.name, "");
			if(!item.name[0])	{
				LogError("Shop item \"%s\" has no name", item.ident);
				continue;
			}
			item.price = kv.GetNum("price", 0);
			kv.GetString("access", sBuffer, sizeof sBuffer, "");
			if(sBuffer[0])	item.access = ReadFlagString(sBuffer) | ADMFLAG_ROOT;
			else	item.access = 0;
			item.type = 0;
			item.id = gShopItems.Length;
			gShopItems.PushArray(item, sizeof item);
		}
		while(kv.GotoNextKey(true));
	}
}

void ShopPlayerShop(int client)	{
	Menu menu = new Menu(ShopMenuHandler);
	int start;
	int size;
	if(g_bInfected[client]){
		menu.SetTitle("Zombie Shop:\n ");
		start = gShopHumanItems;
		size = gShopItems.Length;
	}
	else	{
		menu.SetTitle("Human Shop:\n ");
		start = 0;
		size = gShopHumanItems;
	}

	ShopItem item;
	char sBuffer[32];
	char sBuffer2[96];
	int l, l2;
	bool hide;
	for(;start!=size;start++)	{
		gShopItems.GetArray(start, item, sizeof item);
		l = strcopy(sBuffer2, sizeof sBuffer2, item.name);
		FormatEx(sBuffer, sizeof sBuffer, " [%i $]", item.price);

		hide = item.access ? false : !(GetUserFlagBits(client) & item.access);
		if(!hide && item.limit)	{
			if(Shop_GetClientBuyID(client, start) >= item.limit)	{
				//hide = true;
				strcopy(sBuffer, sizeof sBuffer, " [LIMIT]");
			}
		}

		l2 = strlen(sBuffer);
		if(l + l2 + 1 > sizeof sBuffer2)	l = sizeof sBuffer2 - l2 - 1;
		strcopy(sBuffer2[l], sizeof sBuffer2 - l, sBuffer);
		FormatEx(sBuffer, sizeof sBuffer, "%X", start);
		menu.AddItem(sBuffer, sBuffer2, hide);
	}
	menu.Display(client, 0);
}

public int ShopMenuHandler(Menu thismenu, MenuAction action, int client, int param)	{
	if(action == MenuAction_End)	{
		delete thismenu;
	}
	else if(action == MenuAction_Select)	{
		char sInfo[8];
		int id;

		thismenu.GetItem(param, sInfo, sizeof sInfo);
		StringToIntEx(sInfo, id, 16);
		if(id >= gShopHumanItems != g_bInfected[client])	return;

		ShopItem item;
		gShopItems.GetArray(id, item, sizeof item);

		if(item.access && !(GetUserFlagBits(client) & item.access))	return;

		if(item.limit && Shop_GetClientBuyID(client, id) >= item.limit)	{
			//CReplyToCommand(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
			CPrintToChat(client, " \x04[ZE-Shop]\x01 You reached the limit (%i)");
			ShopPlayerShop(client);
			return;
		}

		int money = GetEntProp(client, Prop_Send, "m_iAccount");
		if(money < item.price)	{
			CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "not_enough_money");
			ShopPlayerShop(client);
			return;
		}

		if(!item.type)	GivePlayerItem2(client, item.ident);

		Shop_AddClientBuyID(client, id);
		SetEntProp(client, Prop_Send, "m_iAccount", money - item.price);
		spended[client] += item.price;
		CPrintToChat(client, " \x04[ZE-Shop]\x01 %t", "bought_item", item.name);
	}
}

int Shop_GetClientBuyID(int client, int id)	{
	char sBuffer[40];
	FormatEx(sBuffer, sizeof sBuffer, "%X", id);
	int len = strlen(sBuffer);
	GetClientAuthId(client, AuthId_Steam2, sBuffer[len], sizeof sBuffer - len);
	if(!gShopMemory.GetValue(sBuffer, len))	return 0;
	return len;
}

void Shop_AddClientBuyID(int client, int id)	{
	char sBuffer[40];
	FormatEx(sBuffer, sizeof sBuffer, "%X", id);
	int len = strlen(sBuffer);
	GetClientAuthId(client, AuthId_Steam2, sBuffer[len], sizeof sBuffer - len);
	if(!gShopMemory.GetValue(sBuffer, len))	len = 0;
	gShopMemory.SetValue(sBuffer, len + 1);
}