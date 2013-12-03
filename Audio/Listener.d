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

private import derelict.openal.al;

/**
 * A 3 dimensional float vector.
 */
float[3] vec3f(float x, float y, float z) pure nothrow {
	return [x, y, z];
}

/**
 * A 6 dimensional float vector.
 */
float[6] vec6f(float x, float y, float z, float u, float v, float w) pure nothrow {
	return [x, y, z, u, v, w];
}

static this() {
	Listener.setPosition(vec3f(0, 0, 0));
	Listener.setVelocity(vec3f(0, 0, 0));
	Listener.setOrientation(vec6f(0, 0, -1, 0, 1, 0));
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
	 * Set the position with x, y and z coordinates.
	 */
	static void setPosition(float x, float y, float z = 0) {
		Listener.setPosition(vec3f(x, y, z));
	}
	
	/**
	 * Returns the current position.
	 */
	static float[3] getPosition() {
		float[3] pos = void;
		alGetListenerfv(AL_POSITION, &pos[0]);
		
		return pos;
	}
	
	/**
	 * Set the celocity with a vec3f.
	 */
	static void setVelocity(float[3] vel) {
		alListenerfv(AL_VELOCITY, &vel[0]);
	}
	
	/**
	 * Set the celocity with coordinates.
	 */
	static void setVelocity(float x, float y, float z = 0) {
		Listener.setVelocity(vec3f(x, y, z));
	}
	
	/**
	 * Returns the current velocity.
	 */
	static float[3] getVelocity() {
		float[3] vel = void;
		alGetListenerfv(AL_VELOCITY, &vel[0]);
		
		return vel;
	}
	
	/**
	 * Set the orientation.
	 */
	static void setOrientation(float[6] ori) {
		alListenerfv(AL_ORIENTATION, &ori[0]);
	}
	
	/**
	 * Returns the current orientation.
	 */
	static float[6] getOrientation() {
		float[6] ori = void;
		alGetListenerfv(AL_ORIENTATION, &ori[0]);
		
		return ori;
	}
}