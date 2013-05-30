module Dgame.Math.Vertex;

debug import std.stdio;

private import Dgame.Math.Vector2;

///version = Develop;

/**
 * The Vertex struct contains 3 components for x, y and z which are stored in a static float array.
 * Vertex is a minimalistic structure for coordinates, compared to Vector2 and Pixel.
 * 
 * Author: rschuett
 */
struct Vertex {
public:
	/**
	 * The Data
	 */
	float[3] data;
	
	/**
	 * CTor
	 */
	this(float x, float y, float z = 0f) {
		this.data[0] = x;
		this.data[1] = y;
		this.data[2] = z;
		
		debug writeln("CTor Vertex");
	}
	
	/**
	 * CTor
	 */
	this(ushort x, ushort y, ushort z = 0) {
		this(cast(float) x, cast(float) y, cast(float) z);
	}
	
	version(Develop)
	this(this) {
		writeln("Postblit Vertex");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref const Vertex v) {
		this.data = v.data;
	}
	
	version(Develop)
	~this() {
		writeln("DTor Vertex");
	}
	
	/**
	 * opEquals
	 */
	bool opEquals(ref const Vertex v) const pure nothrow {
		return this.data == v.data;
	}
	
	/**
	 * Convert the Vertex into a Vector2
	 * Means, that only the x and y coordinate are represented.
	 */
	Vector2f asVector() const {
		return Vector2f(this.data[0], this.data[1]);
	}
}