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
module Dgame.Math.Vector2;

private:

import std.traits : isNumeric;
static import std.math;

public:

/**
 * Vector2 is a structure that defines a two-dimensional point.
 *
 * Author: Randy Schuett <rswhite4@googlemail.com>
 */
struct Vector2(T) if (isNumeric!(T)) {
    /**
     * The x coordinate
     */
    T x = 0;
    /**
     * The y coordinate
     */
    T y = 0;
    
    /**
     * CTor
     */
    @nogc
    this(T x, T y) pure nothrow {
        this.x = x;
        this.y = y;
    }
    
    /**
     * CTor
     */
    @nogc
    this(U)(U x, U y) pure nothrow if (isNumeric!(U) && !is(U : T)) {
        this(cast(T) x, cast(T) y);
    }
    
    /**
     * CTor
     */
    @nogc
    this(U)(ref const Vector2!(U) vec) pure nothrow if (!is(U : T)) {
        this(vec.x, vec.y);
    }
    
    /**
     * Supported operation: +=, -=, *=, /= and %=
     */
    @nogc
    ref Vector2!(T) opOpAssign(string op)(ref const Vector2!(T) vec) pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("this.x " ~ op ~ "= vec.x;");
                mixin("this.y " ~ op ~ "= vec.y;");
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
    ref Vector2!(T) opOpAssign(string op)(T num) pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("this.x " ~ op ~ "= num;");
                mixin("this.y " ~ op ~ "= num;");
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
    Vector2!(T) opBinary(string op)(ref const Vector2!(T) vec) const pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Vector2(vec.x " ~ op ~ " this.x, vec.y " ~ op ~ " this.y);");
            default:
                assert(0, "Unsupported operator " ~ op);
        }
    }
    
    /**
     * Supported operation: +, -, *, / and %
     */
    @nogc
    Vector2!(T) opBinary(string op)(T num) const pure {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Vector2(num " ~ op ~ " this.x, num " ~ op ~ " this.y);");
            default:
                assert(0, "Unsupported operator " ~ op);
        }
    }
    
    /**
     * Returns a negated copy of this Vector.
     */
    @nogc
    Vector2!(T) opNeg() const pure nothrow {
        return Vector2!(T)(-this.x, -this.y);
    }
    
    /**
     * Compares two vectors by checking whether the coordinates are equals.
     */
    @nogc
    bool opEquals(ref const Vector2!(T) vec) const pure nothrow {
        return vec.x == this.x && vec.y == this.y;
    }

    /**
     * Checks if this vector is empty. This means that his coordinates are 0.
     */
    @nogc
    bool isEmpty() const pure nothrow {
        return this.x == 0 && this.y == 0;
    }
    
    /**
     * Calculate the scalar product.
     */
    @nogc
    float scalar(ref const Vector2!(T) vec) const pure nothrow {
        return this.x * vec.x + this.y * vec.y;
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
        return std.math.sqrt(std.math.pow(this.x, 2f) + std.math.pow(this.y, 2f));
    }
    
    /**
     * Calculate the angle between two vectors.
     * If the second paramter is true, the return value is converted to degrees.
     * Otherwise, radiant is used.
     */
    @nogc
    float angle(ref const Vector2!(T) vec, bool degrees = true) const pure nothrow {
        immutable float angle = std.math.acos(this.scalar(vec) / (this.length * vec.length));
        if (degrees)
            return angle * 180f / std.math.PI;
        
        return angle;
    }
    
    /**
     * Calculate the diff between two vectors.
     */
    @nogc
    float diff(ref const Vector2!(T) vec) const pure nothrow {
        return std.math.sqrt(std.math.pow(this.x - vec.x, 2f) + std.math.pow(this.y - vec.y, 2f));
    }
    
    /**
     * Normalize the vector in which the coordinates are divided by the length.
     */
    @nogc
    ref Vector2!(T) normalize() pure nothrow {
        immutable float len = this.length;
        if (len != 0) {
            this.x /= len;
            this.y /= len;
        }
        
        return this;
    }
}

alias Vector2f = Vector2!(float); /// A float representation
alias Vector2i = Vector2!(int);  /// An int representation

@nogc
unittest {
    Vector2i vec;

    assert(vec.x == 0);
    assert(vec.y == 0);
    assert(vec.isEmpty());

    vec = Vector2i(20, 30);

    assert(vec.x == 20);
    assert(vec.y == 30);
    assert(!vec.isEmpty());

    vec += 42;

    assert(vec.x == 62);
    assert(vec.y == 72);
    assert(!vec.isEmpty());

    Vector2i vec2 = vec * 3;

    assert(vec2.x == 3 * vec.x);
    assert(vec2.y == 3 * vec.y);

    Vector2i vec3 = vec2 + vec;

    assert(vec3.x == vec.x + vec2.x);
    assert(vec3.y == vec.y + vec2.y);

    assert(vec == vec);
    assert(vec2 != vec3);

    Vector2i vec4 = -vec;

    assert(vec4.x == -62);
    assert(vec4.y == -72);
}