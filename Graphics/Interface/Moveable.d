module Dgame.Graphics.Interface.Moveable;

private import Dgame.Math.Vector2;

/**
 * An interface for all moveable objects.
 *
 * Author: rschuett
 */
interface Moveable {
	/**
	 * Set a new position vector.
	 */
	void setPosition(T)(ref const Vector2!T);
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(T)(T[2] coord);
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(T)(T, T);
	/**
	 * Returns the current position.
	 */
	ref const(Vector2f) getPosition() const pure nothrow;
	/**
	 * Move the object.
	 */
	void move(T)(ref const Vector2!T);
	/**
	 * Move the object.
	 */
	void move(T)(T x, T y);
}