module Dgame.Math.Vector2;

private {
	debug import std.stdio;
	import std.math : pow, sqrt;
	import std.traits : isNumeric;
	
	import Dgame.Core.Math;
}

//version = Develop;

@safe
private bool equals(T, U)(T a, U b) pure nothrow if (isNumeric!T) {
	static if (is(T == float) || is(T == double) || is(T == real))
		return fpEqual(a, cast(T) b);
	else
		return a == cast(T) b;
}

/**
 * Vector2 is a structure that defines a two-dimensional point.
 *
 * Author: rschuett
 */
struct Vector2(T) if (isNumeric!T) {
public:
	/**
	 * x coordinate
	 */
	T x = 0;
	/**
	 * y coordinate
	 */
	T y = 0;
	
	/**
	 * CTor
	 */
	this(T x, T y) {
		this.x = x;
		this.y = y;
	}
	
	static if (!is(T == int)) {
		/**
		 * CTor
		 */
		this(int x, int y) {
			this.x = cast(T) x;
			this.y = cast(T) y;
		}
	}
	
	version(Develop)
	this(this) {
		writeln("Postblit Vector2");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(U : T)(ref const Vector2!U rhs) {
		debug writeln("opAssign Vector2");
		this.set(rhs.x, rhs.y);
	}
	
	version(Develop)
	~this() {
		writeln("DTor Vector2");
	}
	
	/**
	 * Supported operation: +=, -=, *=, /= and %=
	 */
	ref Vector2!T opOpAssign(string op, U : T)(ref const Vector2!U vec) {
		switch (op) {
			case "+":
				this.x += vec.x;
				this.y += vec.y;
				break;
			case "-":
				this.x -= vec.x;
				this.y -= vec.y;
				break;
			case "*":
				this.x *= vec.x;
				this.y *= vec.y;
				break;
			case "/":
				this.x /= vec.x;
				this.y /= vec.y;
				break;
			case "%":
				this.x %= vec.x;
				this.y %= vec.y;
				break;
			default: throw new Exception("Unsupported operator " ~ op);
		}
		
		return this;
	}
	
	/**
	 * Supported operation: +=, -=, *=, /= and %=
	 */
	ref Vector2!T opOpAssign(string op, U : T)(U number) {
		switch (op) {
			case "+":
				this.x += number;
				this.y += number;
				break;
			case "-":
				this.x -= number;
				this.y -= number;
				break;
			case "*":
				this.x *= number;
				this.y *= number;
				break;
			case "/":
				this.x /= number;
				this.y /= number;
				break;
			case "%":
				this.x %= number;
				this.y %= number;
				break;
			default: throw new Exception("Unsupported operator " ~ op);
		}
		
		return this;
	}
	
	/**
	 * Supported operation: +, -, *, / and %
	 */
	Vector2!T opBinary(string op, U : T)(ref const Vector2!U vec) {
		switch (op) {
			case "+": return Vector2!T(vec.x + this.x, vec.y + this.y);
			case "-": return Vector2!T(vec.x - this.x, vec.y - this.y);
			case "*": return Vector2!T(vec.x * this.x, vec.y * this.y);
			case "/": return Vector2!T(vec.x / this.x, vec.y / this.y);
			case "%": return Vector2!T(vec.x % this.x, vec.y % this.y);
			default: throw new Exception("Unsupported operator " ~ op);
		}
	}
	
	/**
	 * Supported operation: +, -, *, / and %
	 */
	Vector2!T opBinary(string op, U : T)(U number) {
		switch (op) {
			case "+": return Vector2!T(this.x + number, this.y + number);
			case "-": return Vector2!T(this.x - number, this.y - number);
			case "*": return Vector2!T(this.x * number, this.y * number);
			case "/": return Vector2!T(this.x / number, this.y / number);
			case "%": return Vector2!T(this.x % number, this.y % number);
			default: throw new Exception("Unsupported operator " ~ op);
		}
	}
	
	/**
	 * Negation
	 */
	Vector2!T opNeg() const {
		return Vector2!T(-this.x, -this.y);
	}
	
	/**
	 * Negation
	 */
	void negate() pure nothrow {
		this.x = -this.x;
		this.y = -this.y;
	}
	
	/**
	 * Compares two vectors by checking whether the coordinates are equals.
	 */
	bool opEquals(ref const Vector2!T vec) const pure nothrow {
		return vec.x == this.x && vec.y == this.y;
	}
	
	/**
	 * opCast: cast this vector to another type.
	 */
	Vector2!U opCast(V : Vector2!U, U)() const if (!is(U == bool)) {
		return Vector2!U(cast(U) this.x, cast(U) this.y);
	}
	
	/**
	 * opCast: cast to bool
	 */
	bool opCast(U = bool)() const {
		return !this.isEmpty();
	}
	
	/**
	 * Compares two vectors by checking whether the coordinates are greater or less.
	 */
	int opCmp(ref const Vector2!T vec) const pure nothrow {
		if (this.x > vec.x && this.y > vec.y)
			return 1;
		
		if (this.x < vec.x && this.y < vec.y)
			return -1;
		
		return 0;
	}
	
	/**
	 * Checks if this vector is empty. This means that his coordinates are 0.
	 */
	bool isEmpty() const pure nothrow {
		return equals(this.x, 0) && equals(this.y, 0);
	}
	
	/**
	 * Check if this vector is a unit vector. That means that his length is 1.
	 */
	bool isUnit() const pure nothrow {
		return equals(this.length, 1);
	}
	
	/**
	 * Check if another vector is orthogonal to this.
	 */
	bool isOrtho(U)(ref const Vector2!U vec) const pure nothrow {
		return equals(this.scalar(vec), 0);
	}
	
	/**
	 * Calculate the scalar product.
	 */
	float scalar(U)(ref const Vector2!U vec) const pure nothrow {
		return this.x * vec.x + this.y * vec.y;
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
		
		return sqrt(pow(this.x, 2f) + pow(this.y, 2f));
	}
	
	/**
	 * Calculate the angle between two vectors.
	 * If the second paramter is true, the return value is converted to degrees.
	 * Otherwise, radiant is used.
	 */
	float angle(U)(ref const Vector2!U vec, bool degrees = true) const pure nothrow {
		float angle = acos(this.scalar(vec) / (this.length * vec.length));
		
		if (degrees)
			return angle * 180f / PI;
		
		return angle;
	}
	
	/**
	 * Calculate the diff between two vectors.
	 */
	float diff(U)(ref const Vector2!U vec) const pure nothrow {
		return sqrt(pow((this.x - vec.x), 2) + pow((this.y - vec.y), 2));
	}
	
	/**
	 * Normalize the vector in which the coordinates are divided by the length.
	 */
	ref Vector2!T normalize() {
		float len = this.length;
		
		if (len != 0) {
			this.x /= len;
			this.y /= len;
		}
		
		return this;
	}
	
	/**
	 * Set new coordinates.
	 */
	void set(U)(U x, U y) {
		this.x = cast(T) x;
		this.y = cast(T) y;
	}
	
	/**
	 * Move the current coordinates.
	 */
	void move(U)(U x, U y) {
		this.x += x;
		this.y += y;
	}
	
	T[2] asArray() const pure nothrow {
		return [this.x, this.y];
	}
}

/**
 * Alias for short Vector
 */
alias Vector2s = Vector2!short;
/**
 * Alias for float Vector
 */
alias Vector2f = Vector2!float;
/**
 * Alias for unsigned short Vector
 */
alias Vector2us = Vector2!ushort;
/**
 * Alias for byte Vector
 */
alias Vector2b = Vector2!byte;
/**
 * Alias for ubyte Vector
 */
alias Vector2ub = Vector2!ubyte;
