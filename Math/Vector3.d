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

private {
	debug import std.stdio : writeln;
	import std.math : pow, sqrt;
	import std.traits : isNumeric;
}

/**
 * Vector3 is a structure that defines a two-dimensional point.
 *
 * Author: rschuett
 */
struct Vector3(T) if (isNumeric!T) {
	/**
	 * x coordinate
	 */
	T x = 0;
	/**
	 * y coordinate
	 */
	T y = 0;
	/**
	 * z coordinate
	 */
	T z = 0;
	
	/**
	 * CTor
	 */
	this(T x, T y, T z = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	/**
	 * CTor
	 */
	this(U)(U x, U y, U z = 0) if (isNumeric!U && !is(U : T)) {
		this(cast(T) x, cast(T) y, cast(T) z);
	}
	
	/**
	 * CTor
	 */
	this(U)(U[3] pos) if (isNumeric!U) {
		this(pos[0], pos[1], pos[2]);
	}
	
	/**
	 * CTor
	 */
	this(U)(ref const Vector3!U vec) {
		this(vec.x, vec.y, vec.z);
	}
	
	debug(Dgame)
	this(this) {
		writeln("Postblit Vector3");
	}
	
	/**
	 * Supported operation: +=, -=, *=, /= and %=
	 */
	ref Vector3 opOpAssign(string op)(ref const Vector3 vec) {
		switch (op) {
			case "+":
				this.x += vec.x;
				this.y += vec.y;
				this.z += vec.z;
				break;
			case "-":
				this.x -= vec.x;
				this.y -= vec.y;
				this.z -= vec.z;
				break;
			case "*":
				this.x *= vec.x;
				this.y *= vec.y;
				this.z *= vec.z;
				break;
			case "/":
				this.x /= vec.x;
				this.y /= vec.y;
				this.z /= vec.z;
				break;
			case "%":
				this.x %= vec.x;
				this.y %= vec.y;
				this.z %= vec.z;
				break;
			default: throw new Exception("Unsupported operator " ~ op);
		}
		
		return this;
	}
	
	/**
	 * Supported operation: +=, -=, *=, /= and %=
	 */
	ref Vector3 opOpAssign(string op)(T number) {
		switch (op) {
			case "+":
				this.x += number;
				this.y += number;
				this.z += number;
				break;
			case "-":
				this.x -= number;
				this.y -= number;
				this.z -= number;
				break;
			case "*":
				this.x *= number;
				this.y *= number;
				this.z *= number;
				break;
			case "/":
				this.x /= number;
				this.y /= number;
				this.z /= number;
				break;
			case "%":
				this.x %= number;
				this.y %= number;
				this.z %= number;
				break;
			default: throw new Exception("Unsupported operator " ~ op);
		}
		
		return this;
	}
	
	/**
	 * Supported operation: +, -, *, / and %
	 */
	Vector3 opBinary(string op)(ref const Vector3 vec) {
		switch (op) {
			case "+": return Vector3(vec.x + this.x, vec.y + this.y, vec.z + this.z);
			case "-": return Vector3(vec.x - this.x, vec.y - this.y, vec.z - this.z);
			case "*": return Vector3(vec.x * this.x, vec.y * this.y, vec.z * this.z);
			case "/": return Vector3(vec.x / this.x, vec.y / this.y, vec.z / this.z);
			case "%": return Vector3(vec.x % this.x, vec.y % this.y, vec.z % this.z);
			default: throw new Exception("Unsupported operator " ~ op);
		}
	}
	
	/**
	 * Supported operation: +, -, *, / and %
	 */
	Vector3 opBinary(string op)(T number) {
		switch (op) {
			case "+": return Vector3(number + this.x, number + this.y, number + this.z);
			case "-": return Vector3(number - this.x, number - this.y, number - this.z);
			case "*": return Vector3(number * this.x, number * this.y, number * this.z);
			case "/": return Vector3(number / this.x, number / this.y, number / this.z);
			case "%": return Vector3(number % this.x, number % this.y, number % this.z);
			default: throw new Exception("Unsupported operator " ~ op);
		}
	}
	
	/**
	 * Returns a negated copy of this Vector.
	 */
	Vector3 opNeg() const {
		return Vector3(-this.x, -this.y, -this.z);
	}
	
	/**
	 * Negate this Vector
	 */
	void negate() pure nothrow {
		this.x = -this.x;
		this.y = -this.y;
		this.z = -this.z;
	}
	
	/**
	 * Compares two vectors by checking whether the coordinates are equals.
	 */
	bool opEquals(ref const Vector3 vec) const pure nothrow {
		return vec.x == this.x && vec.y == this.y && vec.z == this.z;
	}
	
	/**
	 * opCast: cast this vector to another type.
	 */
	Vector3!U opCast(V : Vector3!U, U)() const {
		return Vector3!U(cast(U) this.x, cast(U) this.y, cast(U) this.z);
	}
	
	/**
	 * Checks if this vector is empty. This means that his coordinates are 0.
	 */
	bool isEmpty() const pure nothrow {
		return this.x == 0 && this.y == 0 && this.z == 0;
	}
	
	/**
	 * Calculate the scalar product.
	 */
	float scalar(ref const Vector3 vec) const pure nothrow {
		return this.x * vec.x + this.y * vec.y + this.z * vec.z;
	}
	
	/**
	 * alias for scalar
	 */
	alias dot = scalar;
	
	/**
	 * Calculate the length.
	 */
	@property
	float length() const pure nothrow {
		if (this.isEmpty())
			return 0f;
		
		return sqrt(pow(this.x, 2f) + pow(this.y, 2f) + pow(this.z, 2f));
	}
	
	/**
	 * Calculate the diff between two vectors.
	 */
	float diff(ref const Vector3 vec) const pure nothrow {
		return sqrt(pow(this.x - vec.x, 2f) + pow(this.y - vec.y, 2f) + pow(this.z - vec.z, 2f));
	}
	
	/**
	 * Returns the cross product of this and another Vector.
	 */
	Vector3 cross(ref const Vector3 vec) {
		return Vector3(this.y * vec.z - this.z * vec.y,
		               this.z * vec.x - this.x * vec.z,
		               this.x * vec.y - this.y * vec.x);
	}
	
	/**
	 * Set new coordinates.
	 */
	void set(T x, T y, T z) pure nothrow {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	/**
	 * Move the current coordinates.
	 */
	void move(T x, T y, T z) pure nothrow {
		this.x += x;
		this.y += y;
		this.z += z;
	}
	
	/**
	 * Returns the Vector as static array.
	 */
	T[3] asArray() const pure nothrow {
		return [this.x, this.y, this.z];
	}
}

/**
 * Alias for short Vector
 */
alias Vector3s = Vector3!short;
/**
 * Alias for float Vector
 */
alias Vector3f = Vector3!float;
/**
 * Alias for byte Vector
 */
alias Vector3b = Vector3!byte;
