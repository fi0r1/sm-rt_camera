#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <camera>

#pragma newdecls required
#pragma semicolon 1

int gI_Camera[MAXPLAYERS + 1];
int gI_CameraLink[MAXPLAYERS + 1][2048];

public Plugin myinfo =
{
	name		= "Camera",
	author		= "花花花。",
	description = "Screen materials with hook entity",
	version		= "Flower",
	url			= "mufiu.com"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Camera_CreateLink", Native_CreateLink);
	CreateNative("Camera_RemoveLink", Native_RemoveLink);
	CreateNative("Camera_HasLink", Native_HasLink);

	RegPluginLibrary("camera");

	return APLRes_Success;
}

void SpawnCameraFrame(any data)
{
	DataPack dp = view_as<DataPack>(data);
	dp.Reset();
	int entity = dp.ReadCell();
	int target = dp.ReadCell();
	delete dp;

	SpawnCamera(target, entity);
}

void SpawnCamera(int client, int entity)
{
	char sCameraName[MAX_NAME_LENGTH], sTargetName[MAX_NAME_LENGTH];
	FormatEx(sCameraName, sizeof(sCameraName), "sm_camera_%d", client);
	GetEntPropString(entity, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));

	if (!gI_Camera[client] || !(IsValidEdict(gI_Camera[client]) && IsValidEntity(gI_Camera[client])))
	{
		// Camera
		int camera = CreateEntityByName("point_camera");

		DispatchKeyValue(camera, "FOV", "90");
		DispatchKeyValue(camera, "fogMaxDensity", "1");
		DispatchKeyValue(camera, "fogStart", "2048");
		DispatchKeyValue(camera, "fogEnd", "4096");
		DispatchKeyValue(camera, "targetname", sCameraName);
		DispatchKeyValue(camera, "spawnflags", "0");
		DispatchSpawn(camera);
		ActivateEntity(camera);

		float fOrigin[3], fAngles[3];
		int	  viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
		GetClientAbsOrigin(client, fOrigin);
		GetClientAbsAngles(client, fAngles);
		TeleportEntity(camera, fOrigin, fAngles, NULL_VECTOR);

		SetVariantString("!activator");
		AcceptEntityInput(camera, "SetParent", viewmodel);

		gI_Camera[client] = camera;
	}

	if (!gI_CameraLink[client][entity] || !(IsValidEdict(gI_CameraLink[client][entity]) && IsValidEntity(gI_CameraLink[client][entity])))
	{
		// Camera Link
		int	 camera_link = CreateEntityByName("info_camera_link");
		char sCameraLinkName[MAX_NAME_LENGTH];
		FormatEx(sCameraLinkName, sizeof(sCameraLinkName), "sm_link_%d%d", gI_Camera[client], entity);
		DispatchKeyValue(camera_link, "targetname", sCameraLinkName);
		DispatchKeyValue(camera_link, "PointCamera", sCameraName);

		DispatchKeyValue(camera_link, "target", sTargetName);
		DispatchSpawn(camera_link);
		ActivateEntity(camera_link);

		gI_CameraLink[client][entity] = camera_link;
	}
}

int Native_HasLink(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	int target = GetNativeCell(2);

	return gI_CameraLink[target][entity] && IsValidEdict(gI_CameraLink[target][entity]) && IsValidEntity(gI_CameraLink[target][entity]);
}

int Native_RemoveLink(Handle plugin, int numParams)
{
	int	 entity = GetNativeCell(1);
	int	 target = GetNativeCell(2);
	bool clean	= GetNativeCell(3);

	if (clean && gI_Camera[target] && IsValidEdict(gI_Camera[target]) && IsValidEntity(gI_Camera[target])) RemoveEntity(gI_Camera[target]);
	if (gI_CameraLink[target][entity] && IsValidEdict(gI_CameraLink[target][entity]) && IsValidEntity(gI_CameraLink[target][entity])) RemoveEntity(gI_CameraLink[target][entity]);
	return 0;
}

int Native_CreateLink(Handle plugin, int numParams)
{
	int	 entity	   = GetNativeCell(1);
	int	 target	   = GetNativeCell(2);
	bool nextframe = GetNativeCell(3);

	char sTargetName[MAX_NAME_LENGTH];
	GetEntPropString(entity, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
	if (StrEqual(sTargetName, ""))
	{
		FormatEx(sTargetName, sizeof(sTargetName), "sm_entity_%d", entity);
		SetEntPropString(entity, Prop_Data, "m_iName", sTargetName);
	}

	if (nextframe)
	{
		DataPack dp = new DataPack();
		dp.WriteCell(entity);
		dp.WriteCell(target);
		RequestFrame(SpawnCameraFrame, dp);

		return 0;
	}

	SpawnCamera(target, entity);

	return 0;
}