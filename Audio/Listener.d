/*
 *******************************************************************************************
 * Dgame (a D game framework) - Copyright (c) Randy Schütt
 * 
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not claim
 *    that you wrote the original software. If you use this software in a product,
 *    an acknowledgment in the product documentation would be appreciated but is
 *    not required.
 * 
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source distribution.
 *******************************************************************************************
 */
module Dgame.Audio.Listener;

private {
	import derelict.openal.al;

	import Dgame.Math.Vector3;
}

@safe
pure nothrow
private T[n + m] merge(T, uint n, uint m)(auto ref const T[n] lhs, auto ref const T[m] rhs)
{
	T[n + m] result = void;

	size_t i = 0;

	foreach (ref const T val; lhs) {
		result[i++] = val;
	}

	foreach (ref const T val; rhs) {
		result[i++] = val;
	}

	return result;
}

static this() {
	Listener.setPosition(0, 0, 0);
	Listener.setVelocity(0, 0, 0);
	Listener.setOrientation(0, 0, -1, 0, 1, 0);
}

/**
 * Listener sets the position, velocity and orientation of the sound set.
 * Default is <code>vec3f(0, 0, 0)</code> for position and velocity 
 * and <code>vec6f(0, 0, -1, 0, 1, 0)</code> for orientation.
 *
 * Author: rschuett
 */
final abstract class Listener {
public:
	/**
	 * Set the position
	 */
	static void setPosition(float[3] pos) {
		alListenerfv(AL_POSITION, &pos[0]);
	}

	/**
	 * Set the position
	 */
	static void setPosition(ref const Vector3f pos) {
		Listener.setPosition(pos.asArray());
	}
	
	/**
	 * Set the position with x, y and z coordinates.
	 */
	static void setPosition(float x, float y, float z = 0) {
		const float[3] pos = [x, y, z];

		Listener.setPosition(pos);
	}
	
	/**
	 * Returns the current position.
	 */
	static Vector3f getPosition() {
		float[3] pos = void;
		alGetListenerfv(AL_POSITION, &pos[0]);
		
		return Vector3f(pos);
	}
	
	/**
	 * Set the celocity with a vec3f.
	 */
	static void setVelocity(float[3] vel) {
		alListenerfv(AL_VELOCITY, &vel[0]);
	}

	/**
	 * Set the celocity with a vec3f.
	 */
	static void setVelocity(ref const Vector3f vel) {
		Listener.setVelocity(vel.asArray());
	}

	/**
	 * Set the celocity with coordinates.
	 */
	static void setVelocity(float x, float y, float z = 0) {
		const float[3] vel = [x, y, z];

		Listener.setVelocity(vel);
	}
	
	/**
	 * Returns the current velocity.
	 */
	static Vector3f getVelocity() {
		float[3] vel = void;
		alGetListenerfv(AL_VELOCITY, &vel[0]);
		
		return Vector3f(vel);
	}
	
	/**
	 * Set the orientation.
	 */
	static void setOrientation(float[6] ori) {
		alListenerfv(AL_ORIENTATION, &ori[0]);
	}

	/**
	 * Set the orientation.
	 */
	static void setOrientation(ref const Vector3f at, ref const Vector3f up) {
		const float[6] ori = merge(at.asArray(), up.asArray());

		Listener.setOrientation(ori);
	}

	/**
	 * Set the orientation.
	 */
	static void setOrientation(float u, float v, float w, float x, float y, float z) {
		const float[6] ori = [u, v, w, x, y, z];

		Listener.setOrientation(ori);
	}
	
	/**
	 * Returns the current orientation.
	 */
	static Vector3f[2] getOrientation() {
		float[6] ori = void;
		alGetListenerfv(AL_ORIENTATION, &ori[0]);
		
		return [Vector3f(ori[0 .. 3]), Vector3f(ori[3 .. 6])];
	}
}