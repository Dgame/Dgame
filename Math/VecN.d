module Dgame.Math.VecN;

private import Dgame.Math.Vector2;

/**
 * A little helper struct to define
 * an N dimensional vector without unnecessary funcitonality.
 */
struct VecN(T, const uint Dim) if (isNumeric!T) {
public:
	/**
	 * Stores the vector values.
	 */
	T[Dim] values;
	
	/// Alias
	alias values this;
	
	/**
	 * CTor
	 */
	this(U...)(U values) {
		foreach (uint idx, val; values) {
			if (idx >= Dim)
				break;
			
			this.values[idx] = cast(T) val;
		}
	}
	
	/**
	 * Returns a 2D Vector
	 */
	Vector2!T asVector2() const pure nothrow {
		return Vector2!T(this.values[0], this.values[1]);
	}
	
	/**
	 * Returns the dimension
	 */
	uint getDim() const pure nothrow {
		return Dim;
	}
}

/**
 * Alias for a two dimensional vector.
 */
alias vec2f = VecN!(float, 2);
/**
 * Alias for a three dimensional vector.
 */
alias vec3f = VecN!(float, 3);
/**
 * Alias for a four dimensional vector.
 */
alias vec4f = VecN!(float, 4);
/**
 * Alias for a six dimensional vector.
 */
alias vec6f = VecN!(float, 6);