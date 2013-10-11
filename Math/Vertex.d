module Dgame.Math.Vertex;

public {
	debug import std.stdio : writeln;
	
	import Dgame.Math.Vector2;
	import Dgame.Graphics.Color;
}

/**
 * A Vertex has coordinates, a color and texture coordinates
 *
 * Author: rschuett
 */
struct Vertex {
public:
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
	this(float x, float y, float z) {
		this.setPosition(x, y, z);
		this.setTexCoord(0, 0);
		this.setColor(Color.White);
	}
	
	/**
	 * CTor
	 */
	this(float x, float y, float z, float tx, float ty) {
		this.setPosition(x, y, z);
		this.setTexCoord(tx, ty);
		this.setColor(Color.White);
	}
	
	/**
	 * CTor
	 */
	this(ref const Vector2f position, ref const Vector2f texcoord) {
		debug writeln("CTor Pixel");
		this.setPosition(position);
		this.setTexCoord(texcoord);
		this.setColor(Color.White);
	}
	
	/**
	 * CTor
	 */
	this(ref const Vector2f position, ref const Color col, ref const Vector2f texcoord) {
		debug writeln("CTor Pixel");
		this.set(position, col, texcoord);
	}
	
	/**
	 * Set a (new) position, a (new) color and (new) texcoords.
	 */
	void set(ref const Vector2f position, ref const Color col, ref const Vector2f texcoord) pure nothrow {
		this.setPosition(position);
		this.setTexCoord(texcoord);
		this.setColor(col);
	}
	
	/**
	 * Set a (new) position
	 */
	void setPosition(ref const Vector2f position) pure nothrow {
		this.setPosition(position.x, position.y);
	}
	
	/**
	 * Set a (new) position
	 */
	void setPosition(float px, float py, float pz = 0f) pure nothrow {
		this.x = px;
		this.y = py;
		this.z = pz;
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
		this.setTexCoord(texcoord.x, texcoord.y);
	}
	
	/**
	 * Set (new) texcoords
	 */
	void setTexCoord(float tx, float ty) pure nothrow {
		this.tx = tx;
		this.ty = ty;
	}
	
	/**
	 * Create a Color from the color data
	 */
	Color getAsColor() const {
		return Color(this.r, this.g, this.b, this.a);
	}
	
	/**
	 * Create a Vector2f from the position data (the z coordinate is ignored).
	 */
	Vector2f getPositionAsVector() const pure nothrow {
		return Vector2f(this.x, this.y);
	}
	
	/**
	 * Create a Vector2f from the position data (the z coordinate is ignored).
	 */
	Vector2f getTexCoordAsVector() const pure nothrow {
		return Vector2f(this.tx, this.ty);
	}
}