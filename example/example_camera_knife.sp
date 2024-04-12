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

	es_Camera camera;
	camera.FOV = 30;
	Camera_CreateLink(weapon, client, true, camera);
}

stock bool IsValidClient(int client, bool bAlive = false)
{
	return (client >= 1 && client <= MaxClients && IsClientInGame(client) && !IsClientSourceTV(client) && (!bAlive || IsPlayerAlive(client)));
}