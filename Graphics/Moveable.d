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
protected:
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
	 * Apply translation to the object.
	 */
	void _applyTranslation() const {
		glTranslatef(this._position.x, this._position.y, 0f);
	}
	
public:
	/**
	 * Overloadable method to reset the position.
	 * The position is set to 0|0.
	 */
	void resetTranslation() {
		this.setPosition(0, 0);
	}
	
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
	
@property:
	/**
	 * Returns the x coordinate of the current position.
	 */
	float X() const pure nothrow {
		return this._position.x;
	}
	
	/**
	 * Returns the y coordinate of the current position.
	 */
	float Y() const pure nothrow {
		return this._position.y;
	}
	
	/**
	 * Sets a new x coordinate to the current position.
	 */
	void X(float x) {
		this._position.x = x;
		
		this._positionReset(x, this._position.y);
	}
	
	/**
	 * Sets a new y coordinate to the current position.
	 */
	void Y(float y) {
		this._position.y = y;
		
		this._positionReset(this._position.x, y);
	}
}