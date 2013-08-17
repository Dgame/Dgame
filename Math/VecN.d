module Dgame.Math.VecN;

private import Dgame.Math.Vector2;

/**
 * VecN is a minimalistic structure for N dimensional coordinates
 * and without unnecessary functionality.
 * 
 * Author: rschuett
 */
struct VecN(T, const uint Dim) if (isNumeric!T) {
public:
	/**
	 * Stores the vector values.
	 */
	T[Dim] values = void;
	
	/// Alias
	alias values this;
	
	/**
	 * CTor
	 */
	this(U...)(U values)
		if (isNumeric!(U[0]))
	{
		uint idx = 0;
		foreach (val; values) {
			if (idx >= Dim)
				break;
			
			this.values[idx] = cast(T) val;
			
			idx++;
		}
		
		if (idx < Dim)
			this.values[idx .. Dim] = 0;
	}
	
	/**
	 * opDispatch for x, y, z, w, u, v components
	 */
	@property
	T opDispatch(string str)() const pure nothrow {
		static if (str[0] == 'x')
			return this.values[0];
		else static if (str[0] == 'y')
			return this.values[1];
		else static if (str[0] == 'z')
			return this.values[2];
		else static if (str[0] == 'w')
			return this.values[3];
		else static if (str[0] == 'u')
			return this.values[4];
		else static if (str[0] == 'v')
			return this.values[5];
		else
			return 0;
	}
	
	/**
	 * Returns a 2D Vector
	 */
	Vector2!T getAsVector2() const pure nothrow {
		return Vector2!T(this.x, this.y);
	}
	
	/**
	 * Returns the dimension
	 */
	uint getDim() const pure nothrow {
		return Dim;
	}
} unittest {
	vec3f v3 = vec3f(1, 2);
	assert(v3.x == 1);
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