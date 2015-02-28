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
module Dgame.Math.Matrix4;

private:

static import std.math;

import Dgame.Math.Vector3;
import Dgame.Math.Vector2;
import Dgame.Math.Rect;

@nogc
bool feq(float a, float b) pure nothrow {
    return std.math.fabs(a - b) > float.epsilon;
}

@nogc
ref Matrix4 merge(ref Matrix4 lhs, ref const Matrix4 rhs) pure nothrow {
    lhs = Matrix4(
        lhs[0] * rhs[0] + lhs[4] * rhs[1] + lhs[12] * rhs[3],
        lhs[0] * rhs[4] + lhs[4] * rhs[5] + lhs[12] * rhs[7],
        lhs[0] * rhs[12] + lhs[4] * rhs[13] + lhs[12] * rhs[15],
        lhs[1] * rhs[0] + lhs[5] * rhs[1] + lhs[13] * rhs[3],
        lhs[1] * rhs[4] + lhs[5] * rhs[5] + lhs[13] * rhs[7],
        lhs[1] * rhs[12] + lhs[5] * rhs[13] + lhs[13] * rhs[15],
        lhs[3] * rhs[0] + lhs[7] * rhs[1] + lhs[15] * rhs[3],
        lhs[3] * rhs[4] + lhs[7] * rhs[5] + lhs[15] * rhs[7],
        lhs[3] * rhs[12] + lhs[7] * rhs[13] + lhs[15] * rhs[15]);

    return lhs;
}

public:

/**
 * A Matrix is a structure which may describe different transformation.
 * Note: Matrix.init is the identity Matrix.
 *
 * Author: Randy Schuett
 */
struct Matrix4 {
    float[16] _values = [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    ];

public:
    /**
     * CTor
     */
    @nogc
    this(float a00, float a01, float a02,
        float a10, float a11, float a12,
        float a20, float a21, float a22) pure nothrow
    {
        _values[0] = a00; _values[4] = a01; _values[8] = 0; _values[12] = a02;
        _values[1] = a10; _values[5] = a11; _values[9] = 0; _values[13] = a12;
        _values[2] = 0; _values[6] = 0; _values[10] = 1; _values[14] = 0;
        _values[3] = a20; _values[7] = a21; _values[11] = 0; _values[15] = a22;
    }

    /**
     * Returns the inverse Matrix of the current.
     * If the current matrix has a determinant of approximately zero, the identity Matrix (.init) is returned.
     */
    @nogc
    Matrix4 getInverse() const pure nothrow {
        immutable float my_det = this.det();

        if (!feq(my_det, 0)) {
            return Matrix4((_values[15] * _values[5] - _values[7] * _values[13]) / my_det,
                          -(_values[15] * _values[4] - _values[7] * _values[12]) / my_det,
                          (_values[13] * _values[4] - _values[5] * _values[12]) / my_det,
                          -(_values[15] * _values[1] - _values[3] * _values[13]) / my_det,
                          (_values[15] * _values[0] - _values[3] * _values[12]) / my_det,
                          -(_values[13] * _values[0] - _values[1] * _values[12]) / my_det,
                          (_values[7] * _values[1] - _values[3] * _values[5]) / my_det,
                          -(_values[7] * _values[0] - _values[3] * _values[4]) / my_det,
                          (_values[5] * _values[0] - _values[1] * _values[4]) / my_det);
        }

        return Matrix4.init;
    }

    /**
     * Reset the current Matrix to the identity Matrix
     */
    @nogc
    ref Matrix4 loadIdentity() pure nothrow {
        _values[0] = 1.0f; _values[4] = 0.0f; _values[8] = 0.0f; _values[12] = 0.0f;
        _values[1] = 0.0f; _values[5] = 1.0f; _values[9] = 0.0f; _values[13] = 0.0f;
        _values[2] = 0.0f; _values[6] = 0.0f; _values[10] = 1.0f; _values[14] = 0.0f;
        _values[3] = 0.0f; _values[7] = 0.0f; _values[11] = 0.0f; _values[15] = 1.0f;

        return this;
    }

    /**
     * Calculate the determinant
     */
    @nogc
    float det() const pure nothrow {
        return _values[0] * (_values[15] * _values[5] - _values[7] * _values[13]) -
            _values[1] * (_values[15] * _values[4] - _values[7] * _values[12]) +
            _values[3] * (_values[13] * _values[4] - _values[5] * _values[12]);
    }

    /**
     * Translate the Matrix
     */
    @nogc
    ref Matrix4 translate()(auto ref const Vector2f vec) pure nothrow {
        const Matrix4 translation = Matrix4(1, 0, vec.x,
                                            0, 1, vec.y,
                                            0, 0, 1);
        return merge(this, translation);
    }

    /**
     * Rotate the Matrix about angle (in degree!)
     */
    @nogc
    ref Matrix4 rotate(float angle) pure nothrow {
        immutable float rad = angle * std.math.PI / 180f;
        immutable float cos = std.math.cos(rad);
        immutable float sin = std.math.sin(rad);

        const Matrix4 rotation = Matrix4(cos, -sin, 0,
                                        sin, cos, 0,
                                        0, 0, 1);
        return merge(this, rotation);
    }

    /**
     * Rotate the Matrix about angle (in degree!) about the given center position
     */
    @nogc
    ref Matrix4 rotate()(float angle, auto ref const Vector2f center) pure nothrow {
        immutable float rad = angle * std.math.PI / 180f;
        immutable float cos = std.math.cos(rad);
        immutable float sin = std.math.sin(rad);

        const Matrix4 rotation = Matrix4(cos, -sin, center.x * (1 - cos) + center.y * sin,
                                         sin, cos, center.y * (1 - cos) - center.x * sin,
                                         0, 0, 1);
        return merge(this, rotation);
    }

    /**
     * Scale the Matrix about factor scale
     */
    @nogc
    ref Matrix4 scale(float scale) pure nothrow {
        const Matrix4 scaling = Matrix4(scale, 0, 0,
                       0, scale, 0,
                       0, 0, 1);

        return merge(this, scaling);
    }

    /**
     * Scale the Matrix about factor scale about the given center position
     */
    @nogc
    ref Matrix4 scale()(float scale, auto ref const Vector2f center) pure nothrow {
        const Matrix4 scaling = Matrix4(scale, 0, center.x * (1 - scale),
                                        0, scale, center.y * (1 - scale),
                                        0, 0, 1);
        return merge(this, scaling);
    }

    /**
     * Calculates a View-Matrix
     *
     * See: http://3dgep.com/understanding-the-view-matrix/#Look_At_Camera
     */
    @nogc
    void lookAt()(auto ref const Vector3f eye, auto ref const Vector3f look, auto ref const Vector3f up) pure nothrow {
        const Vector3f dir = (look - eye).normalize();
        const Vector3f right = dir.cross(up).normalize();
        const Vector3f up2 = right.cross(dir).normalize();

        Matrix4 mat;
        mat.values[0] = right.x;
        mat.values[4] = right.y;
        mat.values[8] = right.z;
        mat.values[12] = -right.dot(eye);

        mat.values[1] = up2.x;
        mat.values[5] = up2.y;
        mat.values[9] = up2.z;
        mat.values[13] = -up2.dot(eye);

        mat.values[2] = -dir.x;
        mat.values[6] = -dir.y;
        mat.values[10] = -dir.z;
        mat.values[14] = dir.dot(eye);

        mat.values[3] = 0;
        mat.values[7] = 0;
        mat.values[11] = 0;
        mat.values[15] = 1;

        merge(this, mat);
    }

    /**
     * Calculate a perspective projection
     *
     * See: http://www.songho.ca/opengl/gl_projectionmatrix.html#perspective
     */
    @nogc
    void perspective(float fov, float ratio, float nearp, float farp) pure nothrow {
        immutable float f = 1f / std.math.tan(fov * (std.math.PI / 360f));

        Matrix4 mat;
        mat[0] = f / ratio;
        mat[5] = f;
        mat[10] = (farp + nearp) / (nearp - farp);
        mat[11] = -1;
        mat[14] = (2 * farp * nearp) / (nearp - farp);
        mat[15] = 0;

        merge(this, mat);
    }

    /**
     * Calculate a prthographic projection
     *
     * See: http://www.songho.ca/opengl/gl_projectionmatrix.html#ortho
     */
    @nogc
    bool ortho()(auto ref const Rect rect, float zNear = 1, float zFar = -1)/* pure nothrow */{
        if (!rect.isEmpty()) {
            immutable float inv_z = 1.0 / (zFar - zNear);
            immutable float inv_y = 1.0 / (cast(float) rect.x - rect.height);
            immutable float inv_x = 1.0 / (cast(float) rect.width - rect.y);

            Matrix4 mat;
            // first column
            mat[0] = 2.0 * inv_x;
            // second
            mat[5] = 2.0 * inv_y;
            // third
            mat[10] = -2.0 * inv_z;
            // fourth
            mat[12] = -(cast(float) rect.width + rect.y) * inv_x;
            mat[13] = -(cast(float) rect.x + rect.height) * inv_y;
            mat[14] = -(zFar + zNear) * inv_z;

            merge(this, mat);

            return true;
        }

        return false;
    }

    /**
     * Returns the 16 values of the Matrix by ref
     */
    @nogc
    ref inout(float[16]) getValues() inout pure nothrow {
        return _values;
    }

    /**
     * Returns a specific value by index
     */
    @nogc
    ref inout(float) opIndex(ubyte index) inout pure nothrow {
        return _values[index];
    }

    /**
     * Supported operations: only *
     */
    @nogc
    Matrix4 opBinary(string op : "*")(ref const Matrix4 mat) const pure nothrow {
        Matrix4 cpy = this;
        merge(cpy, mat);

        return cpy;
    }

    /**
     * Supported operations: only *=
     */
    @nogc
    ref Matrix4 opOpAssign(string op : "*")(ref const Matrix4 math) pure nothrow {
        return merge(this, math);
    }

    /**
     * Compares two Matrices approximately
     */
    @nogc
    bool opEqual(ref const Matrix4 mat) const pure nothrow {
        for (ubyte i = 0; i < 16; i++) {
            if (!feq(mat[i], _values[i]))
                return false;
        }

        return true;
    }
}