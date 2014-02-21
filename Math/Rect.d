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
module Dgame.Math.Rect;

private {
	debug import std.stdio;
	import std.traits : isNumeric;
	
	import derelict.sdl2.sdl;

	import Dgame.Math.Vector2;
	import Dgame.Internal.Unique;
}

SDL_Rect* transfer(T)(const Rect!(T)* rect, SDL_Rect* to) pure nothrow
in {
	assert(to !is null);
} body {
	if (rect is null)
		return null;

	rect.transferTo(to);

	return to;
}

/**
 * Rect defines a rectangle structure that contains the left upper corner and the width/height.
 *
 * Author: rschuett
 */
struct Rect(T) if (isNumeric!T) {
	/**
	 * The x
	 */
	T x = 0;
	/**
	 * and y coordinates
	 */
	T y = 0;
	/**
	 * The width
	 */
	T width = 0;
	/**
	 * and the height
	 */
	T height = 0;
	
	/**
	 * CTor
	 */
	this(T x, T y, T width, T height) pure nothrow {
		this.x = x;
		this.y = y;
		
		this.width  = width;
		this.height = height;
	}
	
	/**
	 * CTor
	 */
	this(ref const Vector2!(T) vec, T width, T height) pure nothrow {
		this(vec.x, vec.y, width, height);
	}
	
	/**
	 * CTor
	 */
	this(U)(ref const Rect!U rect) pure nothrow {
		static if (is(U : T)) {
			this(rect.x, rect.y, rect.width, rect.height);
		} else {
			this(cast(T) rect.x, cast(T) rect.y,
			     cast(T) rect.width, cast(T) rect.height);
		}
	}

	this(ref const SDL_Rect rect) {
		this(cast(T) rect.x, cast(T) rect.y,
		     cast(T) rect.w, cast(T) rect.h);
	}

//	debug(Dgame)
//	this(this) {
//		writeln("Postblit");
//	}
//	
//	debug(Dgame)
//	~this() {
//		debug writeln("DTor Rect");
//	}
	
	/**
	 * Transfer the internal data to the SDL_Rect.
	 */
	void transferTo(SDL_Rect* rect) const pure nothrow
	in {
		assert(rect !is null, "Cannot transfer anything to null.");
	} body {
		rect.x = cast(int) this.x;
		rect.y = cast(int) this.y;
		rect.w = cast(int) this.width;
		rect.h = cast(int) this.height;
	}
	
	/**
	 * Supported operations: +=, -=, *=, /=, %=
	 */
	Rect opBinary(string op)(ref const Rect rect) const pure nothrow {
		switch (op) {
			case "+":
				return Rect(this.x + rect.x,
				              this.y + rect.y,
				              this.width + rect.width,
				              this.height + rect.height);
			case "-":
				return Rect(this.x - rect.x,
				              this.y - rect.y,
				              this.width - rect.width,
				              this.height - rect.height);
			case "*":
				return Rect(this.x * rect.x,
				              this.y * rect.y,
				              this.width * rect.width,
				              this.height * rect.height);
			case "/":
				return Rect(this.x / rect.x,
				              this.y / rect.y,
				              this.width / rect.width,
				              this.height / rect.height);
			case "%":
				return Rect(this.x % rect.x,
				              this.y % rect.y,
				              this.width % rect.width,
				              this.height % rect.height);
			default:
				throw new Exception("Unsupported Operation: " ~ op);
		}
	}
	
	/**
	 * Collapse this Rect. Means that the coordinates and the size is set to 0.
	 */
	void collapse() pure nothrow {
		this.width = this.height = 0;
		this.x = this.y = 0;
	}
	
	/**
	 * Checks if this Rect is empty (if it's collapsed) with SDL_RectEmpty.
	 */
	bool isEmpty() const {
		SDL_Rect a = void;
		this.transferTo(&a);

		return SDL_RectEmpty(&a) == SDL_TRUE;
	}
	
	/**
	 * Checks if this Rect is collapsed, which means
	 * that the width and/or the height are <= 0.
	 * This is a pure and nothrow variant of isEmpty.
	 */
	bool isCollapsed() const pure nothrow {
		return this.width <= 0 || this.height <= 0;
	}
	
	/**
	 * Checks if all corners are zero.
	 */
	bool isZero() const pure nothrow {
		return this.x == 0 && this.y == 0 && this.width == 0 && this.height == 0;
	}
	
	/**
	 * Returns an union of the given and this Rect.
	 */
	Rect getUnion(ref const Rect rect) const {
		SDL_Rect a = void;
		SDL_Rect b = void;
		SDL_Rect c = void;

		this.transferTo(&a);
		rect.transferTo(&b);

		SDL_UnionRect(&a, &b, &c);

		return Rect(c);
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool opBinaryRight(string op : "in")(ref Vector2!(T) vec) const pure nothrow {
		return this.contains(vec);
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool contains(ref const Vector2!(T) vec) const pure nothrow {
		return this.contains(vec.x, vec.y);
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool contains(T x, T y) const pure nothrow {
		return (x >= this.x) && (x < this.x + this.width)
			&& (y >= this.y) && (y < this.y + this.height);
	}
	
	/**
	 * opEquals: compares two rectangles on their coordinates and their size (but not explicit type).
	 */
	bool opEquals(ref const Rect rect) const {
		SDL_Rect a = void;
		SDL_Rect b = void;

		this.transferTo(&a);
		rect.transferTo(&b);

		return SDL_RectEquals(&a, &b);
	}
	
	/**
	 * opCast to another Rect type.
	 */
	Rect!U opCast(V : Rect!U, U)() const pure nothrow {
		return Rect!U(cast(U) this.x, cast(U) this.y,
		              cast(U) this.width, cast(U) this.height);
	}
	
	/**
	 * Checks whether this Rect intersects with an other.
	 * If, and the parameter 'overlap' isn't null,
	 * the colliding rectangle is stored there.
	 */
	bool intersects(ref const Rect rect, Rect* overlap = null) const {
		SDL_Rect a = void;
		SDL_Rect b = void;

		this.transferTo(&a);
		rect.transferTo(&b);

		if (overlap is null)
			return SDL_HasIntersection(&a, &b) == SDL_TRUE;

		SDL_Rect c = void;

		const bool intersects = SDL_IntersectRect(&a, &b, &c) == SDL_TRUE;
		overlap.set(cast(T) c.x, cast(T) c.y,
		            cast(T) c.w, cast(T) c.h);

		return intersects;
	}
	
	/**
	 * Use this function to calculate a minimal rectangle enclosing a set of points.
	 */
	static Rect enclosePoints(in Vector2!(T)[] points) {
		unique_ptr!(SDL_Point) sdl_points = allocate_unique!(SDL_Point)(points.length);
//		SDL_Point[] sdl_points = new SDL_Point[points.length];

		foreach (i, ref const Vector2!(T) p; points) {
			sdl_points[i] = SDL_Point(cast(int) p.x, cast(int) p.y);
		}

		SDL_Rect a = void;
		SDL_EnclosePoints(&sdl_points[0], cast(uint) points.length, null, &a);

		return Rect(a);
	}
	
	/**
	 * Replace current size.
	 */
	void setSize(T width, T height) pure nothrow {
		this.width  = width;
		this.height = height;
	}
	
	/**
	 * Returns the current size as Vector2
	 */
	Vector2!(T) getSize() const pure nothrow {
		return Vector2!(T)(this.width, this.height);
	}
	
	/**
	 * Increase current size.
	 */
	void increase(T width, T height) pure nothrow {
		this.width += width;
		this.height += height;
	}
	
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(T x, T y) pure nothrow {
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Set a new position with a vector.
	 */
	void setPosition(ref const Vector2!(T) position) pure nothrow {
		this.setPosition(position.x, position.y);
	}
	
	/**
	 * Returns the current position as Vector2
	 */
	Vector2!(T) getPosition() const pure nothrow {
		return Vector2!(T)(this.x, this.y);
	}
	
	/**
	 * Move the object.
	 */
	void move(ref const Vector2!(T) vec) pure nothrow {
		this.move(vec.x, vec.y);
	}
	
	/**
	 * Move the object.
	 */
	void move(T x, T y) pure nothrow {
		this.x += x;
		this.y += y;
	}
	
	/**
	 * The new coordinates <b>and</b> a new size.
	 */
	void set(T x, T y, T w, T h) pure nothrow {
		this.setPosition(x, y);
		this.setSize(w, h);
	}

	/**
	 * Returns the coordinates as static array
	 */
	T[4] asArray() const pure nothrow {
		return [this.x, this.y, this.width, this.height];
	}
}

/**
 * alias for float
 */
alias FloatRect = Rect!(float);
/**
 * alias for short
 */
alias ShortRect = Rect!(short);