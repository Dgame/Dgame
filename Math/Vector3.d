module Dgame.Math.Vector3;

private:

import std.traits : isNumeric;
static import std.math;

public:

struct Vector3(T) if (isNumeric!(T)) {
    T x = 0;
    T y = 0;
    T z = 0;

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
    this(U)(U x, U y, U z = 0) pure nothrow if (isNumeric!(U) && !is(U : T)) {
        this(cast(T) x, cast(T) y, cast(T) z);
    }
    
    /**
     * CTor
     */
    @nogc
    this(U)(ref const Vector3!(U) vec) pure nothrow if (!is(U : T)) {
        this(vec.x, vec.y, vec.z);
    }

    /**
     * Compares two vectors by checking whether the coordinates are equals.
     */
    @nogc
    bool opEquals(ref const Vector3!(T) vec) const pure nothrow {
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
    float scalar(ref const Vector3!(T) vec) const pure nothrow {
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
    float diff(ref const Vector3!(T) vec) const pure nothrow {
        return std.math.sqrt(std.math.pow(this.x - vec.x, 2f) + std.math.pow(this.y - vec.y, 2f) + std.math.pow(this.z - vec.z, 2f));
    }

    /**
     * Supported operation: +=, -=, *=, /= and %=
     */
    @nogc
    ref Vector3!(T) opOpAssign(string op)(ref const Vector3!(T) vec) pure nothrow {
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
    ref Vector3!(T)opOpAssign(string op)(T num) pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("this.x " ~ op ~ "= num;");
                mixin("this.y " ~ op ~ "= num;");
                mixin("this.z " ~ op ~ "= num;");
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
    Vector3!(T) opBinary(string op)(ref const Vector3!(T) vec) const pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Vector3(vec.x " ~ op ~ " this.x, vec.y " ~ op ~ " this.y, vec.z " ~ op ~ " this.z);");
            default:
                assert(0, "Unsupported operator " ~ op);
        }
    }
    
    /**
     * Supported operation: +, -, *, / and %
     */
    @nogc
    Vector3!(T) opBinary(string op)(T num) const pure {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Vector3(num " ~ op ~ " this.x, num " ~ op ~ " this.y, num " ~ op ~ " this.z);");
            default:
                assert(0, "Unsupported operator " ~ op);
        }
    }

    /**
     * Returns the cross product of this and another Vector.
     */
    @nogc
    Vector3!(T) cross(ref const Vector3!(T) vec) const pure nothrow {
        return Vector3!(T)(this.y * vec.z - this.z * vec.y,
                       this.z * vec.x - this.x * vec.z,
                       this.x * vec.y - this.y * vec.x);
    }

    Vector3f normalize() const pure nothrow {
        immutable float len = this.length;
        if (len > 0)
            return this / len;
        return this;
    }

    Vector3f rotate(float angle, ref const Vector3!(T) rot) const pure nothrow {
        const Vector3!(T) norm1 = this.normalize();
        const Vector3!(T) norm2 = rot.normalize();

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

alias Vector3f = Vector3!(float);