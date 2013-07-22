module Dgame.Math.Pixel;

public {
	debug import std.stdio;
	
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
	 * Coordinates
	 */
	Vector2f position;
	/**
	 * Color. Default is Color.Black (0, 0, 0)
	 */
	Color color;
	
	/**
	 * CTor
	 */
	this(ref const Vector2f position, ref const Color col) {
		debug writeln("CTor Pixel");
		this.position = position;
		this.color = col;
	}
	/**
	 * CTor
	 */
	this(ref const Vector2f position) {
		debug writeln("CTor Pixel");
		this.position = position;
	}
	
	/*
	 * Postblit
	 */
	this(this) {
		debug writeln("Vertex postblit");
		
		this.position = position;
		this.color = color;
	}
	
	/**
	 * Returns position as 3d coordinates. z is 0.0.
	 */
	float[3] getPositionData() const pure nothrow {
		return [this.position.x, this.position.y, 0f];
	}
	
	/**
	 * Returns color components as static float array.
	 * The components are converted into OpenGL style, means
	 * red, green, blue and alpha are in range of 0.0 .. 1.0
	 */
	float[4] getColorData() const pure nothrow {
		return this.color.asGLColor();
	}
	
	/**
	 * opEquals: compares two Vertices.
	 */
	bool opEquals(ref const Pixel px) const pure nothrow {
		return this.position == px.position && this.color == px.color;
	}
	
	// TODO: empty opCall?
	// TODO: opCmp
	// TODO: opHash?
}