module Dgame.Math.Vector2;

private {
	debug import std.stdio;
	import std.math : pow, sqrt, acos, PI;
	import std.traits : isNumeric;
	
	import Dgame.Core.Math : fpEqual;
}

//version = Develop;

@safe
private bool equals(T, U)(T a, U b) pure nothrow 
	if (isNumeric!T && isNumeric!U)
{
	static if (is(T == float) || is(T == double) || is(T == real))
		return fpEqual(a, cast(T) b);
	else
		return a == b;
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
	this()(T x, T y) { // TODO: Fixed in 2.064
		this.x = x;
		this.y = y;
	}
	
	/**
	 * CTor
	 */
	this(U)(U x, U y)
		if (isNumeric!U && !is(U : T))
	{
		this(cast(T) x, cast(T) y);
	}
	
	/**
	 * CTor
	 */
	this(U)(ref const Vector2!U vec) {
		this(vec.x, vec.y);
	}
	
	version(Develop)
	this(this) {
		writeln("Postblit Vector2");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref const Vector2!T rhs) {
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
	ref Vector2!T opOpAssign(string op)(ref const Vector2!T vec) {
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
	ref Vector2!T opOpAssign(string op)(T number) {
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
	Vector2!T opBinary(string op)(ref const Vector2!T vec) {
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
	Vector2!T opBinary(string op)(T number) {
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
	 * Returns a negated copy of this Vector.
	 */
	Vector2!T opNeg() const {
		return Vector2!T(-this.x, -this.y);
	}
	
	/**
	 * Negate this Vector
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
	Vector2!U opCast(V : Vector2!U, U)() const {
		return Vector2!U(cast(U) this.x, cast(U) this.y);
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
	bool isOrtho(ref const Vector2!T vec) const pure nothrow {
		return equals(this.scalar(vec), 0);
	}
	
	/**
	 * Calculate the scalar product.
	 */
	float scalar(ref const Vector2!T vec) const pure nothrow {
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
	float angle(ref const Vector2!T vec, bool degrees = true) const pure nothrow {
		float angle = acos(this.scalar(vec) / (this.length * vec.length));
		
		if (degrees)
			return angle * 180f / PI;
		
		return angle;
	}
	
	/**
	 * Calculate the diff between two vectors.
	 */
	float diff(ref const Vector2!T vec) const pure nothrow {
		return sqrt(pow((this.x - vec.x), 2f) + pow((this.y - vec.y), 2f));
	}
	
	/**
	 * Normalize the vector in which the coordinates are divided by the length.
	 */
	ref Vector2!T normalize() pure nothrow {
		float len = this.length;
		
		if (!fpEqual(len, 0f)) {
			this.x /= len;
			this.y /= len;
		}
		
		return this;
	}
	
	/**
	 * Set new coordinates.
	 */
	void set(T x, T y) pure nothrow {
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Move the current coordinates.
	 */
	void move(T x, T y) pure nothrow {
		this.x += x;
		this.y += y;
	}
	
	/**
	 * Returns the Vector as static array.
	 */
	T[2] asArray() const pure nothrow {
		return [this.x, this.y];
	}
} unittest {
	Vector2f vec;
	assert(vec.isEmpty());
	vec += 1;
	assert(vec.x == 1f && vec.y == 1f);
	assert(!vec.isEmpty());
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
 * Alias for byte Vector
 */
alias Vector2b = Vector2!byte;
