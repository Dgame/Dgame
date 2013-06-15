module Dgame.Audio.Listener;

private {
	import std.traits : isNumeric;
	
	//import Dgame.Core.AutoRef;
	import Dgame.Audio.Core.core;
}

/**
 * A little helper struct to define 
 * n dimensional vector arrays without unnecessary funcitonality.
 */
struct vecn(T, const uint Dim) if (isNumeric!T) {
public:
	/**
	 * Stores the vector values.
	 */
	T[Dim] values;
	
	alias values this;
	
	/**
	 * CTor
	 */
	this(U...)(U values) {
		foreach (uint idx, val; values) {
			if (idx >= Dim)
				break;
			this.values[idx] = cast(T) val;
		}
	}
}

/**
 * Alias for a three dimensional vector.
 */
alias vec3f = vecn!(float, 3);
/**
 * Alias for a six dimensional vector.
 */
alias vec6f = vecn!(float, 6);

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
	static vec3f _listenerPos = void;
	static vec3f _listenerVel = void;
	static vec6f _listenerOri = void;
	
public:
	/**
	 * Set the position with a vec3f
	 */
	static void setPosition(const vec3f pos) {
		Listener._listenerPos = pos;
		
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
	static ref const(vec3f) getPosition() {
		return Listener._listenerPos;
	}
	
	/**
	 * Set the celocity with a vec3f.
	 */
	static void setVelocity(const vec3f vel) {
		_listenerVel = vel;
		
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
	static ref const(vec3f) getVelocity() {
		return _listenerVel;
	}
	
	/**
	 * Set the orientation.
	 */
	static void setOrientation(const vec6f ori) {
		Listener._listenerOri = ori;
		
		alListenerfv(AL_ORIENTATION, &ori[0]);
	}
	
	/**
	 * Returns the current orientation.
	 */
	static ref const(vec6f) getOrientation() {
		return Listener._listenerOri;
	}
}