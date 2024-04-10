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

	RegPluginLibrary("camera");

	return APLRes_Success;
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

void SpawnCameraFrame(any data)
{
	DataPack dp = view_as<DataPack>(data);
	dp.Reset();
	int entity = dp.ReadCell();
	int target = dp.ReadCell();
	delete dp;

	SpawnCamera(target, entity);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (gI_Camera[client] && IsValidEdict(gI_Camera[client]) && IsValidEntity(gI_Camera[client]))
	{
		float fOrigin[3], fAngles[3];
		GetClientEyePosition(client, fOrigin);
		GetClientEyeAngles(client, fAngles);
		TeleportEntity(gI_Camera[client], fOrigin, fAngles, NULL_VECTOR);
	}

	return Plugin_Continue;
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		gI_Camera[i] = 0;
		for (int j = MaxClients + 1; j < GetMaxEntities(); j++)
		{
			gI_CameraLink[i][j] = 0;
		}
	}
}

void SpawnCamera(int client, int entity)
{
	char sCameraName[MAX_NAME_LENGTH];
	FormatEx(sCameraName, sizeof(sCameraName), "sm_camera_%d", client);

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

		char sTargetName[MAX_NAME_LENGTH];
		GetEntPropString(entity, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
		DispatchKeyValue(camera_link, "target", sTargetName);
		DispatchSpawn(camera_link);
		ActivateEntity(camera_link);

		gI_CameraLink[client][entity] = camera_link;
	}
}