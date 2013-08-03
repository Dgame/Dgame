module Dgame.Graphics.Color;

private {
	debug import std.stdio;
	
	import derelict.sdl2.sdl;
}

///version = Develop;

private SDL_Color[void*] _ColorStore;

static ~this() {
	_ColorStore = null;
}

/**
 * Color defines a structure which contains 4 ubyte values, each for red, green, blue and alpha.
 * Alpha is default 255 (1.0).
 *
 * Author: rschuett
 */
struct Color {
public:
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
	this(float red, float green, float blue, float alpha = 1f) pure nothrow {
		this.red   = cast(ubyte)(ubyte.max * red);
		this.green = cast(ubyte)(ubyte.max * green);
		this.blue  = cast(ubyte)(ubyte.max * blue);
		this.alpha = cast(ubyte)(ubyte.max * alpha);
	}
	
	version(Develop)
	this(this) {
		writeln("Postblit Color");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref const Color rhs) {
		debug writeln("opAssign Color (L)");
		
		this.red   = rhs.red;
		this.green = rhs.green;
		this.blue  = rhs.blue;
		this.alpha = rhs.alpha;
	}
	
	/**
	 * Rvalue version
	 */
	void opAssign(const Color rhs) {
		this.opAssign(rhs);
	}
	
	version(Develop)
	~this() {
		writeln("DTor Color");
	}
	
	/**
	 * Returns a SDL_Color pointer.
	 */
	@property
	SDL_Color* ptr() const {
		const void* key = &this;
		
		if (SDL_Color* _ptr = key in _ColorStore) {
			_ptr.r = this.red;
			_ptr.g = this.green;
			_ptr.b = this.blue;
			_ptr.unused = this.alpha;
			
			return _ptr;
		} else
			_ColorStore[key] = SDL_Color(this.red, this.green, this.blue, this.alpha);
		
		return &_ColorStore[key];
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
	 */
	void set(float red, float green, float blue, float alpha = 1f) pure nothrow {
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
		return [this.red > 1 ? this.red / 255f : this.red,
		        this.green > 1 ? this.green / 255f : this.green,
		        this.blue > 1 ? this.blue / 255f : this.blue,
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