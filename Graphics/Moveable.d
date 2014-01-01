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
module Dgame.Graphics.Moveable;

private {
	import derelict.opengl3.gl;
	
	import Dgame.Math.Vector2;
}

/**
 * Basic implementation for moveable objects
 *
 * Author: rschuett
 */
abstract class Moveable {
private:
	Vector2f _position;
	
protected:
	/**
	 * Overloadable method if the position is moved.
	 */
	void _positionMoved(float dx, float dy) {
	
	}
	
	/**
	 * Overloadable method if the position is reset.
	 */
	void _positionReset(float nx, float ny) {
	
	}

	/**
	 * Overloadable method to reset the position.
	 * The position is set to 0|0.
	 */
	void _resetTranslation() {
		this.setPosition(0, 0);
	}

	/**
	* Apply translation to the object.
	*/
	void _applyTranslation() const {
		glTranslatef(this._position.x, this._position.y, 0f);
	}

public:	
final:
	/**
	 * Setting a new position.
	 */
	void setPosition(ref const Vector2f vec) {
		this._position = vec;
		this._positionReset(vec.x, vec.y);
	}
	
	/**
	 * Setting a new position.
	 */
	void setPosition(float x, float y) {
		this._position.set(x, y);
		this._positionReset(x, y);
	}
	
	/**
	 * Setting a new position.
	 */
	void setPosition(float[2] pos) {
		this.setPosition(pos[0], pos[1]);
	}
	
	/**
	 * Returns the current position.
	 */
	ref const(Vector2f) getPosition() const pure nothrow {
		return this._position;
	}

	/**
	 * Returns inout reference to the x coordinate.
	 */
	@property
	ref inout(float) X() inout pure nothrow {
		return this._position.x;
	}

	/**
	 * Returns inout reference to the y coordinate.
	 */
	@property
	ref inout(float) Y() inout pure nothrow {
		return this._position.y;
	}
	
	/**
	 * Move the current position by vec.
	 */
	void move(ref const Vector2f vec) {
		this._position += vec;
		this._positionMoved(vec.x, vec.y);
	}
	
	/**
	 * Move the current position by x|y.
	 */
	void move(float x, float y) {
		this._position.move(x, y);
		this._positionMoved(x, y);
	}

	/**
	 * Move the position by pos.
	 */
	void move(float[2] pos) {
		this.move(pos[0], pos[1]);
	}
}
