#if defined __CAMERA
	#endinput
#endif

#define __CAMERA

/**
 * Create _rt_Camera materials entity link with target
 * nextframe - Whether nextframe will be triggered in the next frame. // Prevent the sequence of some events of origin
 *
 * @param entity					entity index.
 * @param target					client index.
 * @param nextframe					boolean
 *
 * @noreturn
 */
native void Camera_CreateLink(int entity, int target, bool nextframe = false);

/**
 * Remove _rt_Camera materials entity link with target
 *
 * @param entity					entity index.
 * @param target					client index.
 * @param clean						boolean
 *
 * @noreturn
 */
native void Camera_RemoveLink(int entity, int target, bool clean = false);

/**
 * Has _rt_Camera materials entity link with target
 *
 * @param entity					entity index.
 * @param target					client index.
 *
 * @return boolean
 */
native bool Camera_HasLink(int entity, int target);