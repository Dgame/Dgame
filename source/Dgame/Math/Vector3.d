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
module Dgame.Math.Vector3;

private:

import std.traits : isNumeric;
static import std.math;

public:

/**
 * Vector3 is a structure that defines a three-dimensional point.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Vector3(T) if (isNumeric!(T)) {
    T x = 0; /// The x coordinate
    T y = 0; /// The y coordinate
    T z = 0; /// The z coordinate

    /**
     * CTor
     */
    @nogc
    this(T x, T y, T z = 0) pure nothrow {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    /**
     * CTor
     */
    @nogc
    this(U)(U x, U y, U z = 0) pure nothrow if (isNumeric!(U) && !is(U == T)) {
        this(cast(T) x, cast(T) y, cast(T) z);
    }
    
    /**
     * CTor
     */
    @nogc
    this(U)(const Vector3!(U) vec) pure nothrow if (!is(U == T)) {
        this(vec.x, vec.y, vec.z);
    }

    /**
     * Compares two vectors by checking whether the coordinates are equals.
     */
    @nogc
    bool opEquals(const Vector3!(T) vec) const pure nothrow {
        return vec.x == this.x && vec.y == this.y && vec.z == this.z;
    }

    /**
     * Checks if this vector is empty. This means that his coordinates are 0.
     */
    @nogc
    bool isEmpty() const pure nothrow {
        return this.x == 0 && this.y == 0 && this.z == 0;
    }
    
    /**
     * Calculate the scalar product.
     */
    @nogc
    float scalar(const Vector3!(T) vec) const pure nothrow {
        return this.x * vec.x + this.y * vec.y + this.z * vec.z;
    }
    
    /**
     * alias for scalar
     */
    alias dot = scalar;
    
    /**
     * Calculate the length.
     */
    @nogc
    @property
    float length() const pure nothrow {
        if (this.isEmpty())
            return 0f;
        return std.math.sqrt(std.math.pow(this.x, 2f) + std.math.pow(this.y, 2f) + std.math.pow(this.z, 2f));
    }
    
    /**
     * Calculate the diff between two vectors.
     */
    @nogc
    float diff(const Vector3!(T) vec) const pure nothrow {
        return std.math.sqrt(std.math.pow(this.x - vec.x, 2f) + std.math.pow(this.y - vec.y, 2f) + std.math.pow(this.z - vec.z, 2f));
    }

    /**
     * Supported operation: +=, -=, *=, /= and %=
     */
    @nogc
    ref Vector3!(T) opOpAssign(string op)(const Vector3!(T) vec) pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("this.x " ~ op ~ "= vec.x;");
                mixin("this.y " ~ op ~ "= vec.y;");
                mixin("this.z " ~ op ~ "= vec.z;");
            break;
            default:
                assert(0, "Unsupported operator " ~ op);
        }
        
        return this;
    }
    
    /**
     * Supported operation: +=, -=, *=, /= and %=
     */
    @nogc
    ref Vector3!(T) opOpAssign(string op)(float num) pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("this.x = cast(T)(this.x " ~ op ~ " num);");
                mixin("this.y = cast(T)(this.y " ~ op ~ " num);");
                mixin("this.z = cast(T)(this.z " ~ op ~ " num);");
            break;
            default:
                assert(0, "Unsupported operator " ~ op);
        }
        
        return this;
    }

    /**
     * Supported operation: +, -, *, / and %
     */
    @nogc
    Vector3!(T) opBinary(string op)(const Vector3!(T) vec) const pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Vector3!(T)(this.x " ~ op ~ " vec.x, this.y " ~ op ~ " vec.y, this.z " ~ op ~ " vec.y);");
            default:
                assert(0, "Unsupported operator " ~ op);
        }
    }
    
    /**
     * Supported operation: +, -, *, / and %
     */
    @nogc
    Vector3!(T) opBinary(string op)(float num) const pure {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Vector3!(T)(cast(T)(this.x " ~ op ~ " num), cast(T)(this.y " ~ op ~ " num), cast(T)(this.z " ~ op ~ " num));");
            default:
                assert(0, "Unsupported operator " ~ op);
        }
    }

    /**
     * Returns the cross product of this and another Vector.
     */
    @nogc
    Vector3!(T) cross(const Vector3!(T) vec) const pure nothrow {
        return Vector3!(T)(this.y * vec.z - this.z * vec.y, this.z * vec.x - this.x * vec.z, this.x * vec.y - this.y * vec.x);
    }

    /**
     * Normalize the vector in which the coordinates are divided by the length.
     */
    Vector3!(T) normalize() pure nothrow {
        immutable float len = this.length;
        if (len > 0)
            return this / len;
        return this;
    }

    /**
     * Rotate the current Vector by an angle and rotation Vector and returns the result
     */
    Vector3!(T) rotate(float angle, const Vector3!(T) rot) const pure nothrow {
        immutable float len1 = this.length;
        immutable float len2 = rot.length;

        assert(len1 > 0 && len2 > 0);

        const Vector3!(T) norm1 = this / len1;
        const Vector3!(T) norm2 = rot / len2;

        immutable float rho_rad = angle / 180 * std.math.PI;
        immutable float c = std.math.cos(rho_rad);
        immutable float s = std.math.sin(rho_rad);
        immutable float t = 1 - c;

        immutable float norm_final_x = norm1.x * (t * norm2.x * norm2.x + c) + norm1.y * (t * norm2.x * norm2.y - s * norm2.z) + norm1.z * (t * norm2.x * norm2.z + s * norm2.y);
        immutable float norm_final_y = norm1.x * (t * norm2.x * norm2.y + s * norm2.z) + norm1.y * (t * norm2.y * norm2.y + c) + norm1.z * (t * norm2.y * norm2.z - s * norm2.x);
        immutable float norm_final_z = norm1.x * (t * norm2.x * norm2.z - s * norm2.y) + norm1.y * (t * norm2.y * norm2.z + s * norm2.x) + norm1.z * (t * norm2.z * norm2.z + c);

        Vector3!(T) final_norm = Vector3!(T)(norm_final_x, norm_final_y, norm_final_z);
        final_norm *= this.length;

        return final_norm;
    }
}

alias Vector3f = Vector3!(float); /// A float representation
alias Vector3i = Vector3!(int); /// An int representation
