module Dgame.Math.Pixel;

public {
	debug import std.stdio : writeln;
	
	import Dgame.Math.Vector2;
	import Dgame.Graphics.Color;
}

/**
 * A Pixel has coordinates (position) and a color.
 * It defines a basic component for shapes.
 *
 * Author: rschuett
 */
struct Pixel {
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
	 * Disable default CTor
	 */
	@disable
	this();
	
	/**
	 * CTor
	 */
	this(float x, float y) {
		debug writeln("CTor Pixel");
		this.setPosition(x, y);
	}
	
	/**
	 * CTor
	 */
	this(ref const Vector2f position) {
		debug writeln("CTor Pixel");
		this.setPosition(position);
	}
	
	/**
	 * CTor
	 */
	this(ref const Vector2f position, ref const Color col) {
		debug writeln("CTor Pixel");
		this.set(position, col);
	}
	
	/**
	 * Set both, a (new) position and a (new) color.
	 */
	void set(ref const Vector2f position, ref const Color col) pure nothrow {
		this.setPosition(position);
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
	 * Create a Color from the color data
	 */
	Color getAsColor() const {
		return Color(this.r, this.g, this.b, this.a);
	}
	
	/**
	 * Create a Vector2f from the position data (the z coordinate is ignored).
	 */
	Vector2f getAsVector() const pure nothrow {
		return Vector2f(this.x, this.y);
	}
}