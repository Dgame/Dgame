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
module Dgame.Graphics.Color;

private {
	debug import std.stdio : writeln;
	
	import derelict.sdl2.sdl;
	
	import Dgame.Internal.util : CircularBuffer;
}

private struct ColorCBuffer {
	CircularBuffer!(SDL_Color) _buf;
	
	SDL_Color* put(ref const Color col) pure nothrow {
		SDL_Color* pcol = this._buf.get();
		
		pcol.r = col.red;
		pcol.g = col.green;
		pcol.b = col.blue;
		pcol.unused = col.alpha;
		
		return pcol;
	}
}

static ColorCBuffer _cbuf;

/**
 * Color defines a structure which contains 4 ubyte values, each for red, green, blue and alpha.
 * Alpha is default 255 (1.0).
 *
 * Author: rschuett
 */
struct Color {
	static const Color Black   = Color(0,     0,   0); /** Black Color (0, 0, 0) */
	static const Color White   = Color(255, 255, 255); /** White Color (255, 255, 255) */
	static const Color Red     = Color(255,   0,   0); /** Red Color (255, 0, 0) */
	static const Color Green   = Color(0,   255,   0); /** Green Color (0, 255, 0) */
	static const Color Blue    = Color(0,     0, 255); /** Blue Color (0, 0, 255) */
	static const Color Cyan    = Color(0,   255, 255); /** Cyan Color (0, 255, 255) */
	static const Color Yellow  = Color(255, 255,   0); /** Yellow Color (255, 255, 0)*/
	static const Color Magenta = Color(255,   0, 255); /** Magenta Color (255, 0, 255) */
	static const Color Gray    = Color(0.7f, 0.7f, 0.7f); /** Gray Color (0.7, 0.7, 0.7) */
	
	/**
	 * The color components
	 */
	ubyte red, green, blue, alpha;
	
	/**
	 * CTor
	 */
	this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
		this.red   = red;
		this.green = green;
		this.blue  = blue;
		this.alpha = alpha;
	}
	
	/**
	 * CTor
	 * Expect that every component is in range 0.0 .. 1.0
	 */
	this(float red, float green, float blue, float alpha = 1f) pure nothrow
	in {
		assert(red   >= 0f && red   <= 1f);
		assert(green >= 0f && green <= 1f);
		assert(blue  >= 0f && blue  <= 1f);
		assert(alpha >= 0f && alpha <= 1f);
	} body {
		this.red   = cast(ubyte)(ubyte.max * red);
		this.green = cast(ubyte)(ubyte.max * green);
		this.blue  = cast(ubyte)(ubyte.max * blue);
		this.alpha = cast(ubyte)(ubyte.max * alpha);
	}
	
	debug(Dgame)
	this(this) {
		debug writeln("Postblit Color");
	}
	
	debug(Dgame)
	~this() {
		debug writeln("DTor Color");
	}
	
	/**
	 * Returns a copy of the current Color with a given transpareny.
	 * 
	 * Example:
	 * ----
	 * Color(current.red, current.green, current.blue, alpha);
	 * ----
	 */
	Color withTransparency(ubyte alpha = 0) const {
		return Color(this.red, this.green, this.blue, alpha);
	}
	
	/**
	 * Returns a SDL_Color pointer.
	 */
	@property
	SDL_Color* ptr() const {
		return _cbuf.put(this);
	}
	
	/**
	 * Set all color components to new values
	 */
	void set(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
		this.red   = red;
		this.green = green;
		this.blue  = blue;
		this.alpha = alpha;
	}
	
	/**
	 * Set all color components to new values
	 * Expect that every component is in range 0.0 .. 1.0
	 */
	void set(float red, float green, float blue, float alpha = 1f) pure nothrow
	in {
		assert(red   >= 0f && red   <= 1f);
		assert(green >= 0f && green <= 1f);
		assert(blue  >= 0f && blue  <= 1f);
		assert(alpha >= 0f && alpha <= 1f);
	} body {
		this.red   = cast(ubyte)(ubyte.max * red);
		this.green = cast(ubyte)(ubyte.max * green);
		this.blue  = cast(ubyte)(ubyte.max * blue);
		this.alpha = cast(ubyte)(ubyte.max * alpha);
	}
	
	/**
	 * opEquals: compares two Colors.
	 */
	bool opEquals(ref const Color col) const pure nothrow {
		return this.red == col.red && this.green == col.green
			&& this.blue == col.blue && this.alpha == col.alpha;
	}
	
	/**
	 * Returns a static float array with all color components.
	 * Every component is converted into OpenGL style.
	 * Means every component is in range 0.0 .. 1.0
	 */
	float[4] asGLColor() const pure nothrow {
		return [this.red   > 1 ? this.red   / 255f : this.red,
			this.green > 1 ? this.green / 255f : this.green,
			this.blue  > 1 ? this.blue  / 255f : this.blue,
			this.alpha > 1 ? this.alpha / 255f : this.alpha];
	}
	
	/**
	 * Returns the RGBA color information as static array
	 */
	ubyte[4] asRGBA() const pure nothrow {
		return [this.red, this.green, this.blue, this.alpha];
	}
	
	/**
	 * Returns RGB the color information as static array
	 */
	ubyte[3] asRGB() const pure nothrow {
		return [this.red, this.green, this.blue];
	}
}