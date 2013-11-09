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
	import Dgame.Audio.Internal.core;
	import Dgame.Math.VecN;
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
private:
	static vec3f _listenerPos;
	static vec3f _listenerVel;
	static vec6f _listenerOri;
	
public:
	/**
	 * Set the position with a vec3f
	 */
	static void setPosition(ref const vec3f pos) {
		Listener._listenerPos = pos;
		
		alListenerfv(AL_POSITION, &pos[0]);
	}
	
	/**
	 * Rvalue version
	 */
	static void setPosition(const vec3f pos) {
		Listener.setPosition(pos);
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
	static ref const(vec3f) getPosition() {
		return Listener._listenerPos;
	}
	
	/**
	 * Set the celocity with a vec3f.
	 */
	static void setVelocity(ref const vec3f vel) {
		_listenerVel = vel;
		
		alListenerfv(AL_VELOCITY, &vel[0]);
	}
	
	/**
	 * Rvalue version
	 */
	static void setVelocity(const vec3f vel) {
		Listener.setVelocity(vel);
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
	static ref const(vec3f) getVelocity() {
		return _listenerVel;
	}
	
	/**
	 * Set the orientation.
	 */
	static void setOrientation(ref const vec6f ori) {
		Listener._listenerOri = ori;
		
		alListenerfv(AL_ORIENTATION, &ori[0]);
	}
	
	/**
	 * Rvalue version
	 */
	static void setOrientation(const vec6f ori) {
		Listener.setOrientation(ori);
	}
	
	/**
	 * Returns the current orientation.
	 */
	static ref const(vec6f) getOrientation() {
		return Listener._listenerOri;
	}
}