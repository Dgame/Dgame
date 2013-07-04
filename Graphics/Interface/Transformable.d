module Dgame.Graphics.Interface.Transformable;

private import Dgame.Math.Vector2;

/**
 * An Interface for all transformable objects.
 *
 * Author: rschuett
 */
interface Transformable {
	/**
	 * Stores the rotation data for the current shape.
	 * The second parameter is the center point of rotation.
	 */
	void rotate(T)(short, T, T);
	/**
	 * Stores the rotation data for the current shape.
	 * The second parameter is the center point of rotation.
	 */
	void rotate(T)(short, ref const Vector2!T);
	/**
	 * Returns the center point if rotation.
	 */
	ref const(Vector2f) getRotation() const;
	/**
	 * Stores the scale data of this shape.
	 */
	void scale(T)(T, T);
	/**
	 * Stores the scale data of this shape.
	 */
	void scale(T)(ref const Vector2!T);
	/**
	 * Returns the scale data.
	 */
	ref const(Vector2f) getScale() const;
	/**
	 * Returns only the X component of the scale vector
	 */
	@property
	float scaleX() const pure nothrow;
	/**
	 * Returns only the Y component of the scale vector
	 */
	@property
	float scaleY() const pure nothrow;
	/**
	 * Set only the X component of the scale vector
	 */
	@property
	void scaleX(float x);
	/**
	 * Set only the Y component of the scale vector
	 */
	@property
	void scaleY(float y);
	/**
	 * Returns only the X component of the rotation vector
	 */
	@property
	float rotX() const pure nothrow;
	/**
	 * Returns only the Y component of the rotation vector
	 */
	@property
	float rotY() const pure nothrow;
	/**
	 * Set only the X component of the rotation vector
	 */
	@property
	void rotX(float x);
	/**
	 * Set only the Y component of the rotation vector
	 */
	@property
	void rotY(float y);
}

mixin template TTransformable() {
private:
	Vector2f _rotation;
	Vector2f _scale = Vector2f(1f, 1f);
	
	short _rotAngle;
	
public:
final:
	
	/**
	 * Stores the rotation data for the current shape.
	 * The second parameter is the center point of rotation.
	 */
	void rotate(T)(short angle, T x, T y) {
		this._rotAngle += angle;
		this._rotation.move(x, y);
	}
	
	/**
	 * Stores the rotaion data for the current shape.
	 * The second parameter is the center point of rotation.
	 */
	void rotate(T)(short angle, ref const Vector2!T vec) {
		this._rotAngle += angle;
		this._rotation += vec;
	}
	
	/**
	 * Returns the rotation angle.
	 */
	short getAngle() const pure nothrow {
		return this._rotAngle;
	}
	
	/**
	 * Returns the center point if rotation.
	 */
	ref const(Vector2f) getRotation() const {
		return this._rotation;
	}
	
	/**
	 * Stores the scale data of this shape.
	 */
	void scale(T)(T x, T y) {
		this._scale.move(x, y);
	}
	
	/**
	 * Stores the scale data of this shape.
	 */
	void scale(T)(ref const Vector2!T vec) {
		this._scale += vec;
	}
	
	/**
	 * Returns the scale data.
	 */
	ref const(Vector2f) getScale() const {
		return this._scale;
	}
	
	/**
	 * Returns only the X component of the scale vector
	 */
	@property
	float scaleX() const pure nothrow {
		return this._scale.x;
	}
	
	/**
	 * Returns only the Y component of the scale vector
	 */
	@property
	float scaleY() const pure nothrow {
		return this._scale.y;
	}
	
	/**
	 * Set only the X component of the scale vector
	 */
	@property
	void scaleX(float x) {
		this._scale.x = x;
	}
	
	/**
	 * Set only the Y component of the scale vector
	 */
	@property
	void scaleY(float y) {
		this._scale.y = y;
	}
	
	/**
	 * Returns only the X component of the rotation vector
	 */
	@property
	float rotX() const pure nothrow {
		return this._rotation.x;
	}
	
	/**
	 * Returns only the Y component of the rotation vector
	 */
	@property
	float rotY() const pure nothrow {
		return this._rotation.y;
	}
	
	/**
	 * Set only the X component of the rotation vector
	 */
	@property
	void rotX(float x) {
		this._rotation.x = x;
	}
	
	/**
	 * Set only the Y component of the rotation vector
	 */
	@property
	void rotY(float y) {
		this._rotation.y = y;
	}
}

