module Dgame.Graphics.Drawable;

package {
	import Dgame.Graphics.Interface.Moveable;
	import Dgame.Math.Vector2;
}

/**
 * The base class for all drawable objects. Maintains the position where the object is drawn.
 *
 * Author: rschuett
 */
abstract class Drawable : Moveable {
protected:
	abstract void _render();
	
	/**
	 * Possible observer method if the position change.
	 */
	void _positionChanged(float dx, float dy) {
		
	}
	
protected:
	/**
	 * Position of the drawable object.
	 */
	Vector2f _position;
	
public:
final:
	
	/**
	 * Render method
	 */
	void render() {
		this._render();
	}
	
	/**
	 * Set a new position vector.
	 */
	void setPosition(T)(ref const Vector2!T position) {
		this.setPosition(position.x, position.y);
	}
	
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(T)(T[2] coord) {
		this.setPosition(coord[0], coord[1]);
	}
	
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(T)(T x, T y) {
		this._position.set(x, y);
		this._positionChanged(x, y);
	}
	
	/**
	 * Returns the current position.
	 */
	ref const(Vector2f) getPosition() const pure nothrow {
		return this._position;
	}
	
	/**
	 * Returns only the x coordinate of the current position
	 */
	@property
	float X() const pure nothrow {
		return this._position.x;
	}
	
	/**
	 * Returns only the y coordinate of the current position
	 */
	@property
	float Y() const pure nothrow {
		return this._position.y;
	}
	
	/**
	 * Set only the x coordinate of the current position
	 */
	@property
	void X(float x) {
		this._position.x = x;
	}
	
	/**
	 * Set only the y coordinate of the current position
	 */
	@property
	void Y(float y) {
		this._position.y = y;
	}
	
	/**
	 * Move the object only in X direction
	 */
	void moveX(T)(T x) {
		this._position.x += x;
	}
	
	/**
	 * Move the object only in Y direction
	 */
	void moveY(T)(T y) {
		this._position.y += y;
	}
	
	/**
	 * Move the object.
	 */
	void move(T)(ref const Vector2!T vec) {
		this._position += vec;
		this._positionChanged(vec.x, vec.y);
	}
	
	/**
	 * Move the object.
	 */
	void move(T)(T x, T y) {
		this._position.move(x, y);
		this._positionChanged(x, y);
	}
	
	/**
	 * Calculate the difference Vector from this position to another.
	 */
	Vector2f diff(T)(ref const Vector2!T point) {
		return this._position.diff(point);
	}
	
	/**
	 * Calculate the distance from this position to another.
	 */
	int distance(T)(ref const Vector2!T point) {
		return this.diff(point).length;
	}
}
