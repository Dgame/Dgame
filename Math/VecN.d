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
module Dgame.Math.VecN;

private import Dgame.Math.Vector2;

/**
 * VecN is a minimalistic structure for N dimensional coordinates
 * and without unnecessary functionality.
 * 
 * Author: rschuett
 */
struct VecN(T, const uint Dim) if (isNumeric!T) {
	/**
	 * Stores the vector values.
	 */
	T[Dim] values;
	
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