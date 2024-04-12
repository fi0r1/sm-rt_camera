#if defined __CAMERA
	#endinput
#endif

#define __CAMERA

#define CAMERA_DEFAULT	0
#define CAMERA_STARTOFF (1 << 0)

#define CAMERA_BITCOUNT 1

enum struct es_Camera
{
	int FOV;
	int fogMaxDensity;
	int fogStart;
	int fogEnd;
	int spawnflags;
}

/**
 * es_Camera default
 *
 * FOV - 90
 * fogMaxDensity - 1
 * fogStart - 2048
 * fogEnd - 4096
 * spawnflags - CAMERA_DEFAULT
 *
 */
stock void Camera_FormatCamera(es_Camera camera)
{
	if (!camera.FOV) camera.FOV = 90;
	if (!camera.fogMaxDensity) camera.fogMaxDensity = 1;
	if (!camera.fogStart) camera.fogStart = 2048;
	if (!camera.fogEnd) camera.fogEnd = 4096;
	if (!camera.spawnflags) camera.spawnflags = CAMERA_DEFAULT;
}

/**
 * Create _rt_Camera materials entity link with target
 * nextframe - Whether nextframe will be triggered in the next frame. // Prevent the sequence of some events of origin
 *
 * @param entity					entity index
 * @param target					client index
 * @param nextframe					boolean
 * @param camera					es_Camera
 *
 * @return camera entity			// -1 for nextframe
 */
native int	Camera_CreateLink(int entity, int target, bool nextframe = false, any[] camera = { 90, 1, 2048, 4096, CAMERA_DEFAULT });

/**
 * Remove _rt_Camera materials entity link with target
 *
 * @param entity					entity index
 * @param target					client index
 * @param clean						boolean
 *
 * @noreturn
 */
native void Camera_RemoveLink(int entity, int target, bool clean = false);

/**
 * Reset player's camera parent
 *
 * @param target					client index
 *
 * @noreturn
 */
native void Camera_ResetCamera(int target);

/**
 * Has _rt_Camera materials entity link with target
 *
 * @param entity					entity index
 * @param target					client index
 *
 * @return boolean
 */
native bool Camera_HasLink(int entity, int target);

/**
 * Get player's camera entity
 *
 * @param target					client index
 *
 * @return camera entity index
 */
native int	Camera_GetCamera(int target);

/**
 * Get player's camera link entity
 *
 * @param target					client index
 * @param entity					entity index
 *
 * @return camera link entity index
 */
native int	Camera_GetCameraLink(int target, int entity);