module Dgame.Graphic.Transformable;

private:

import Dgame.Math.Vector2;
import Dgame.Math.Matrix4;

public:

class Transformable {
protected:
    Vector2f _local_center;
    Vector2f _position;

    float _scale = 1;
    float _rotation = 0;

    @nogc
    void _notifyTransform() pure nothrow {
        _was_transformed = true;
    }

    @nogc
    bool _wasTransformed() const pure nothrow {
        return _was_transformed;
    }

private:
    Matrix4 _matrix;
    bool _was_transformed = true;

public:
final:
    @nogc
    ref const(Matrix4) getMatrix() pure nothrow {
        if (_wasTransformed()) {
            const Vector2f global_center = _position + _local_center;
            _matrix.loadIdentity().rotate(_rotation, global_center).scale(_scale, global_center).translate(_position);
            _was_transformed = false;
        }

        return _matrix;
    }

    @nogc
    void setPosition(float x, float y) pure nothrow {
        _position.x = x;
        _position.y = y;
        _notifyTransform();
    }

    @nogc
    void setPosition(ref const Vector2f pos) pure nothrow {
        _position = pos;
        _notifyTransform();
    }

    @nogc
    void move(float x, float y) pure nothrow {
        _position.x += x;
        _position.y += y;
        _notifyTransform();
    }

    @nogc
    void move(ref const Vector2f offset) pure nothrow {
        _position += offset;
        _notifyTransform();
    }

    @nogc
    ref const(Vector2f) getPosition() const pure nothrow{
        return _position;
    }

    @nogc
    void setCenter(float x, float y) pure nothrow {
        _local_center.x = x;
        _local_center.y = y;
        _notifyTransform();
    }

    @nogc
    void setCenter(ref const Vector2f center) pure nothrow {
        _local_center = center;
        _notifyTransform();
    }

    @nogc
    ref const(Vector2f) getCenter() const  pure nothrow {
        return _local_center;
    }

    @nogc
    void setScale(float scale) pure nothrow  {
        _scale = scale;
        _notifyTransform();
    }

    @nogc
    void scale(float scale) pure nothrow {
        _scale += scale;
        _notifyTransform();
    }

    @nogc
    float getScale() const pure nothrow {
        return _scale;
    }

    @nogc
    void setRotation(float rotation) pure nothrow {
        _rotation = rotation;
        if (_rotation < 0 || _rotation > 360)
            _rotation = 0;
        _notifyTransform();
    }

    @nogc
    void rotate(float rotation) pure nothrow {
        _rotation += rotation;
        if (_rotation < 0 || _rotation > 360)
            _rotation = 0;
        _notifyTransform();
    }

    @nogc
    float getRotation() const pure nothrow {
        return _rotation;
    }
}