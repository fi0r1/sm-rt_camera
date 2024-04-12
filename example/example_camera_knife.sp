#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <camera>

#pragma newdecls required
#pragma semicolon 1

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_SpawnPost, OnPlayerSpawn);
}

void OnPlayerSpawn(int client)
{
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;

	int		  weapon = GetPlayerWeaponSlot(client, 2);

	es_Camera cache;
	cache.FOV  = 110;
	int camera = Camera_CreateLink(weapon, client, true, cache);
	if (camera == -1)
	{
		DataPack dp = new DataPack();
		dp.WriteCell(client);
		dp.WriteCell(weapon);
		RequestFrame(OnCamera, dp);
	}
	else
	{
		PrintToConsole(client, "camera entity: %d\ncamera link entity: %d", camera, Camera_GetCameraLink(client, weapon));
	}
}

void OnCamera(any data)
{
	DataPack dp = view_as<DataPack>(data);
	dp.Reset();
	int client = dp.ReadCell();
	int entity = dp.ReadCell();
	delete dp;

	PrintToConsole(client, "camera entity: %d\ncamera link entity: %d", Camera_GetCamera(client), Camera_GetCameraLink(client, entity));
}

stock bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientInGame(client) && !IsClientSourceTV(client) && (!bAlive || IsPlayerAlive(client)));
}