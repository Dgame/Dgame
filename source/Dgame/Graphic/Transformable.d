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
import Dgame.Math.Matrix4;

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
protected:
    Vector2f _local_center;
    Vector2f _position;

    float _scale = 1;
    float _rotation = 0;

    @nogc
    final void _notifyTransform() pure nothrow {
        _was_transformed = true;
    }

    @nogc
    final bool _wasTransformed() const pure nothrow {
        return _was_transformed;
    }

private:
    Matrix4 _matrix;
    bool _was_transformed = true;

public:
final:
    /**
     * Returns the current matrix.
     * If any transformations was made, the matrix is updated before
     */
    @nogc
    ref const(Matrix4) getMatrix() pure nothrow {
        if (_wasTransformed()) {
            const Vector2f global_center = _position + _local_center;
            _matrix.loadIdentity().rotate(_rotation, global_center).scale(_scale, global_center).translate(_position);
            _was_transformed = false;
        }

        return _matrix;
    }

    /**
     * Set the position
     */
    @nogc
    void setPosition(float x, float y) pure nothrow {
        _position.x = x;
        _position.y = y;
        _notifyTransform();
    }

    /**
     * Set the position
     */
    @nogc
    void setPosition(ref const Vector2f pos) pure nothrow {
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
     * Move the position by offset
     */
    @nogc
    void move(ref const Vector2f offset) pure nothrow {
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
     * Set the center position
     */
    @nogc
    void setCenter(float x, float y) pure nothrow {
        _local_center.x = x;
        _local_center.y = y;
        _notifyTransform();
    }

    /**
     * Set the center position
     */
    @nogc
    void setCenter(ref const Vector2f center) pure nothrow {
        _local_center = center;
        _notifyTransform();
    }

    /**
     * Returns the current center position
     */
    @nogc
    ref const(Vector2f) getCenter() const  pure nothrow {
        return _local_center;
    }

    /**
     * Set the scaling (for both, x and y)
     */
    @nogc
    void setScale(float scale) pure nothrow  {
        _scale = scale;
        _notifyTransform();
    }

    /**
     * Inc-/Decrease the scaling
     */
    @nogc
    void scale(float scale) pure nothrow {
        _scale += scale;
        _notifyTransform();
    }

    /**
     * Returns the current scaling
     */
    @nogc
    float getScale() const pure nothrow {
        return _scale;
    }

    /**
     * Set the rotation angle. If not in range of 0 .. 360 it will be set to 0.
     */
    @nogc
    void setRotation(float rotation) pure nothrow {
        _rotation = rotation;
        if (_rotation < 0 || _rotation > 360)
            _rotation = 0;
        _notifyTransform();
    }

    /**
     * Inc-/Decrease the rotation.
     * If the rotation is <b>after</b> that not in range of 0 .. 360 it will be set to 0.
     */
    @nogc
    void rotate(float rotation) pure nothrow {
        _rotation += rotation;
        if (_rotation < 0 || _rotation > 360)
            _rotation = 0;
        _notifyTransform();
    }

    /**
     * Returns the current rotation
     */
    @nogc
    float getRotation() const pure nothrow {
        return _rotation;
    }
}