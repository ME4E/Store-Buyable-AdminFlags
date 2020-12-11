#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Rowdy4E."
#define PLUGIN_VERSION "1.01"

#include <sourcemod>
#include <sdktools>
#include <store>

int iAdminFlagId = 0;
char cAdminFlag[STORE_MAX_ITEMS][12];
bool bGotClientsDefaultFlags[MAXPLAYERS + 1] = false;
int iClientFlagBits[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "Store - Buyable AdminFlags", 
	author = PLUGIN_AUTHOR, 
	description = "Buy AdminFlag in ZephStore", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/profiles/76561198307962930"
};
public void OnPluginStart() {
	Store_RegisterHandler("AdminFlag", "FlagAssign", AdminFlag_OnMapStart, AdminFlag_Reset, AdminFlag_Config, AdminFlag_Equip, AdminFlag_Remove, true);
}

public void OnClientDisconnect(client) {
	bGotClientsDefaultFlags[client] = false;
	if (iClientFlagBits[client] != 0)
		SetUserFlagBits(client, iClientFlagBits[client]);
	iClientFlagBits[client] = 0;
}

public void AdminFlag_OnMapStart() {}

public void AdminFlag_Reset() { 
	iAdminFlagId = 0;
}

public bool AdminFlag_Config(Handle &kv, int itemid) {
	Store_SetDataIndex(itemid, iAdminFlagId);
	KvGetString(kv, "FlagAssign", cAdminFlag[iAdminFlagId++], 12);
	
	return true;
}

public int AdminFlag_Equip(int client, int id) {
	int index = Store_GetDataIndex(id);
	int flagslen = strlen(cAdminFlag[index]);
	if (flagslen == 0)
		return -1;
	
	if (!bGotClientsDefaultFlags[client]) {
		iClientFlagBits[client] = GetUserFlagBits(client);
		bGotClientsDefaultFlags[client] = !bGotClientsDefaultFlags[client];
	}
	
	int flags = iClientFlagBits[client];
	for (int i = 0; i < flagslen; i++) {
		int adminFlag = ReadFlagString(cAdminFlag[index][i]);
		flags |= adminFlag;
	}
	SetUserFlagBits(client, flags);
	return 0;
}

void AdminFlag_Remove(int client, int id) { 
	if (iClientFlagBits[client] != 0)
		SetUserFlagBits(client, iClientFlagBits[client]);
}