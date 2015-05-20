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
module Dgame.Graphic.Transformable;

private:

import Dgame.Math.Vector2;
import Dgame.Math.Matrix4x4;

public:

/**
 * Transformable is an abstract class which enables his child classes to be transformable
 * which means that they have a position, can be scaled and can be rotated.
 * For that purpose an additional Matrix is used (besides the Vector2f and float components) which maps the transformations.
 *
 * See: Matrix4
 * See: Vector2f
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
class Transformable {
private:
    Vector2f _position;
    Vector2f _rotationCenter;
    Vector2f _origin;
    Vector2f _scale = Vector2f(1, 1);

    float _rotationAngle = 0;

    Matrix4x4 _matrix;
    bool _was_transformed = true;

protected:
    @nogc
    final void _notifyTransform() pure nothrow {
        _was_transformed = true;
    }

public:
final:
    /**
     * Returns the current matrix.
     * If any transformations was made, the matrix is updated before
     */
    @nogc
    ref const(Matrix4x4) getMatrix() pure nothrow {
        if (_was_transformed) {
            const Vector2f* center = _origin.isEmpty() ? &_rotationCenter : &_origin;
            _matrix.loadIdentity()
                   .translate(_position - _origin)
                   .rotate(_rotationAngle, *center)
                   .scale(_scale, *center);
            _was_transformed = false;
        }

        return _matrix;
    }

    /**
     * Sets the position
     */
    @nogc
    void setPosition(float x, float y) pure nothrow {
        _position.x = x;
        _position.y = y;
        _notifyTransform();
    }

    /**
     * Sets the position
     */
    @nogc
    void setPosition(const Vector2f pos) pure nothrow {
        _position = pos;
        _notifyTransform();
    }

    /**
     * Move the position by offset (x, y)
     */
    @nogc
    void move(float x, float y) pure nothrow {
        _position.x += x;
        _position.y += y;
        _notifyTransform();
    }

    /**
     * Move the position by offset (x, y)
     */
    @nogc
    void move(const Vector2f offset) pure nothrow {
        _position += offset;
        _notifyTransform();
    }

    /**
     * Returns the current position
     */
    @nogc
    ref const(Vector2f) getPosition() const pure nothrow{
        return _position;
    }

    /**
     * Returns the x coordinate <b>by value</b>
     * 
     * Note: if you want to change the coordinate, use either move or setPosition
     */
    @nogc
    @property
    float x() const pure nothrow {
        return _position.x;
    }

    /**
     * Sets a new x coordinate
     */
    @nogc
    @property
    void x(float cx) pure nothrow {
        _position.x = cx;
        _notifyTransform();
    }

    /**
     * Returns the y coordinate <b>by value</b>
     * 
     * Note: if you want to change the coordinate, use either move or setPosition
     */
    @nogc
    @property
    float y() const pure nothrow {
        return _position.y;
    }

    /**
     * Sets a new y coordinate
     */
    @nogc
    @property
    void y(float cy) pure nothrow {
        _position.y = cy;
        _notifyTransform();
    }

    /**
     * Sets the center position
     *
     * Note: if you use this function with setOrigin,
     *       the origin takes the place of the rotation center.
     */
    @nogc
    void setRotationCenter(float x, float y) pure nothrow {
        _rotationCenter.x = x;
        _rotationCenter.y = y;
        _notifyTransform();
    }

    /**
     * Sets the center of the rotation
     *
     * Note: if you use this function with setOrigin,
     *       the origin takes the place of the rotation center.
     */
    @nogc
    void setRotationCenter(const Vector2f center) pure nothrow {
        _rotationCenter = center;
        _notifyTransform();
    }

    /**
     * Returns the current rotation center
     */
    @nogc
    ref const(Vector2f) getRotationCenter() const  pure nothrow {
        return _rotationCenter;
    }

    /**
     * Sets the origin. The origin is a offset which is added to the position
     * and serves as center position for scaling and rotation.
     *
     * Note: If you use this with setRotationCenter
     *       the origin will suppress the rotation center and takes it's place.
     */
    @nogc
    void setOrigin(float x, float y) pure nothrow {
        _origin.x = x;
        _origin.y = y;
        _notifyTransform();
    }

    /**
     * Sets the origin. The origin is a offset which is added to the position
     * and serves as center position for scaling and rotation.
     *
     * Note: If you use this with setRotationCenter
     *       the origin will suppress the rotation center and takes it's place.
     */
    @nogc
    void setOrigin(const Vector2f origin) pure nothrow {
        _origin = origin;
        _notifyTransform();
    }

    /**
     * Returns the current origin
     */
    @nogc
    ref const(Vector2f) getOrigin() const  pure nothrow {
        return _origin;
    }

    /**
     * Sets the scaling (for both, x and y)
     */
    @nogc
    void setScale(float x, float y) pure nothrow  {
        _scale.x = x;
        _scale.y = y;
        _notifyTransform();
    }

    /**
     * Sets the scaling (for both, x and y)
     */
    @nogc
    void setScale(const Vector2f offset) pure nothrow  {
        _scale = offset;
        _notifyTransform();
    }

    /**
     * Inc-/Decrease the scaling
     */
    @nogc
    void scale(const Vector2f offset) pure nothrow {
        _scale += offset;
        _notifyTransform();
    }

    /**
     * Inc-/Decrease the scaling
     */
    @nogc
    void scale(float offset) pure nothrow {
        _scale += offset;
        _notifyTransform();
    }

    /**
     * Returns the current scaling
     */
    @nogc
    ref const(Vector2f) getScale() const pure nothrow {
        return _scale;
    }

    /**
     * Set the rotation angle. If not in range of 0 .. 360 it will be set to 0.
     */
    @nogc
    void setRotation(float rotation) pure nothrow {
        _rotationAngle = rotation;
        if (_rotationAngle < 0 || _rotationAngle > 360)
            _rotationAngle = 0;
        _notifyTransform();
    }

    /**
     * Inc-/Decrease the rotation.
     * If the rotation is <b>after</b> that not in range of 0 .. 360 it will be set to 0.
     */
    @nogc
    void rotate(float rotation) pure nothrow {
        _rotationAngle += rotation;
        if (_rotationAngle > 360 || _rotationAngle < -360)
            _rotationAngle %= 360;
        _notifyTransform();
    }

    /**
     * Returns the current rotation
     */
    @nogc
    float getRotation() const pure nothrow {
        return _rotationAngle;
    }
}