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
module Dgame.Math.Vertex;

public {
	debug import std.stdio : writeln;
	
	import Dgame.Math.Vector2;
	import Dgame.Math.Vector3;
	import Dgame.Graphics.Color;
}

/**
 * A Vertex has coordinates, a color and texture coordinates
 *
 * Author: rschuett
 */
struct Vertex {
	/**
	 * The coordinates
	 */
	float x, y, z;
	/**
	 * The color components
	 */
	float r, g, b, a;
	/**
	 * The texcoords
	 */
	float tx, ty;
	
	/**
	 * Disable default CTor
	 */
	@disable
	this();
	
	/**
	 * CTor
	 */
	this(float x, float y, float z = 0f, float tx = 0f, float ty = 0f) {
		this.x = x;
		this.y = y;
		this.z = z;

		this.tx = tx;
		this.ty = ty;

		this.setColor(Color.White);
	}

	/**
	 * CTor
	 */
	this(ref const Vector2f position) {
		this(position.x, position.y);
	}
	
	/**
	 * CTor
	 */
	this(ref const Vector2f position, ref const Vector2f texcoord, ref const Color col) {
		this.setPosition(position);
		this.setTexCoord(texcoord);
		this.setColor(col);
	}

	/**
	 * CTor
	 */
	this(ref const Vector2f position, ref const Color col) {
		this.setPosition(position);
		this.setColor(col);

		this.tx = 0f;
		this.ty = 0f;
	}

	/**
	 * Set a (new) position
	 */
	void setPosition(ref const Vector2f position) pure nothrow {
		this.x = position.x;
		this.y = position.y;
		this.z = 0f;
	}
	
	/**
	 * Set a (new) color
	 */
	void setColor(ref const Color col) pure nothrow {
		const float[4] rgba = col.asGLColor();
		
		this.r = rgba[0];
		this.g = rgba[1];
		this.b = rgba[2];
		this.a = rgba[3];
	}
	
	/**
	 * Set (new) texcoords
	 */
	void setTexCoord(ref const Vector2f texcoord) pure nothrow {
		this.tx = texcoord.x;
		this.ty = texcoord.y;
	}

	/**
	 * Create a Color from the color data
	 */
	Color getAsColor() const {
		return Color(this.r, this.g, this.b, this.a);
	}
	
	/**
	 * Create a Vector3f from the position data.
	 */
	Vector3f getPositionAsVector() const pure nothrow {
		return Vector3f(this.x, this.y, this.z);
	}
	
	/**
	 * Create a Vector2f from the position data (the z coordinate is ignored).
	 */
	Vector2f getTexCoordAsVector() const pure nothrow {
		return Vector2f(this.tx, this.ty);
	}
}