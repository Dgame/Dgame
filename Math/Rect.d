module Dgame.Math.Rect;

private {
	debug import std.stdio;
	import std.traits : isNumeric;
	
	import derelict3.sdl2.sdl;
	
	import Dgame.Math.Vector2;
}

///version = Develop;

/**
 * Rect defines a rectangle structure that contains the left upper corner and the width/height.
 *
 * Author: rschuett
 */
struct Rect(T) if (isNumeric!T) {
private:
	SDL_Rect _sdl_rect;
	
public:
	/**
	 * The x and y coordinates
	 */
	T x, y;
	/**
	 * The width and the height
	 */
	T width, height;
	
	void update() {
		this._sdl_rect.x = cast(int) this.x;
		this._sdl_rect.y = cast(int) this.y;
		this._sdl_rect.w = cast(int) this.width;
		this._sdl_rect.h = cast(int) this.height;
	}
	
public:
	/**
	 * CTor
	 */
	this(T x, T y, T width, T height) {
		this.x = x;
		this.y = y;
		
		this.width  = width;
		this.height = height;
		
		this.update();
	}
	
	static if (!is(T == int)) {
		/**
		 * CTor
		 */
		this(int x, int y, int width, int height) {
			this.x = cast(T) x;
			this.y = cast(T) y;
			
			this.width  = cast(T) width;
			this.height = cast(T) height;
			
			this.update();
		}
	}
	
	/**
	 * CTor
	 */
	this(ref const Vector2!T vec, T width, T height) {
		this(vec.x, vec.y, width, height);
	}
	
	version(Develop)
	this(this) {
		writeln("Postblit Rect");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(U : T)(ref const Rect!U rhs) {
		debug writeln("opAssign Rect");
		this.set(rhs.x, rhs.y, rhs.width, rhs.height);
	}
	
	version(Develop)
	~this() {
		writeln("DTor Rect");
	}
	
	/**
	 * Supported operations: +=
	 */
	Rect!T opBinary(string op, U)(ref const Rect!U rect) const {
		switch (op) {
			case "+":
				return Rect!T(cast(T)(this.x + rect.x),
				              cast(T)(this.y + rect.y),
				              cast(T)(this.width + rect.width),
				              cast(T)(this.height + rect.height));
			default: throw new Exception("Unsupported Operation: " ~ op);
		}
	}
	
	/**
	 * Collapse this Rect. Means that the coordinates and the size is set to 0.
	 */
	void collapse() {
		this.width = this.height = 0;
		this.x = this.y = 0;
		
		this.update();
	}
	
	/**
	 * Checks if this Rect is empty (if it's collapsed).
	 */
	bool isEmpty() const {
		return SDL_RectEmpty(this.ptr);
	}
	
	/**
	 * Returns an union of the given and this Rect.
	 */
	Rect!T getUnion(U)(ref const Rect!U rect) const {
		Rect!T union_rect;
		SDL_UnionRect(this.ptr, rect.ptr, union_rect.ptr);
		
		return union_rect;
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool contains(U)(ref const Vector2!U vec) const {
		return this.contains(vec.x, vec.y);
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool contains(U)(U x, U y) const {
		return (x >= this.x) && (x < this.x + this.width) && 
			(y >= this.y) && (y < this.y + this.height);
	}
	
	/**
	 * opEquals: compares two rectangles on their coordinates and their size (but not explicit type).
	 */
	bool opEquals(U)(ref const Rect!U rect) const {
		if (rect is this)
			return true;
		
		return SDL_RectEquals(this.ptr, rect.ptr);
	}
	
	/**
	 * opCast to another Rect type.
	 */
	Rect!U opCast(V : Rect!U, U)() const if (!is(U == bool)) {
		return Rect!U(cast(U) this.x,
		              cast(U) this.y,
		              cast(U) this.width,
		              cast(U) this.height);
	}
	
	/**
	 * opCast for bool
	 */
	bool opCast(U = bool)() const {
		return !this.isEmpty();
	}
	
	/**
	 * Checks whether this Rect intersects with an other.
	 * If, and the parameter 'intersection' isn't null,
	 * the colliding rectangle is stored there.
	 */
	bool intersects(U)(ref const Rect!U rect, ShortRect* intersection = null) const {
		if (SDL_HasIntersection(this.ptr, rect.ptr)) {
			if (intersection !is null)
				SDL_IntersectRect(this.ptr, rect.ptr, intersection.ptr);
			
			return true;
		}
		
		return false;
		
	}
	
	/**
	 * Returns a pointer to an SDL_Rect.
	 */
	@property
	inout(SDL_Rect)* ptr() inout {
		return &this._sdl_rect;
	}
	
	/**
	 * Replace current size.
	 */
	void setSize(U)(U width, U height) {
		this.width  = cast(T) width;
		this.height = cast(T) height;
		
		this.update();
	}
	
	/**
	 * Increase current size.
	 */
	void increase(U)(U width, U height) {
		this.width  += width;
		this.height += height;
		
		this.update();
	}
	
	/**
	 * Set a new position vector.
	 */
	void setPosition(U)(ref const Vector2!U position) {
		this.setPosition(position.x, position.y);
	}
	
	void setPosition(U)(U[2] pos) {
		this.setPosition(pos[0], pos[1]);
	}
	
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(U)(U x, U y) {
		this.x = cast(T) x;
		this.y = cast(T) y;
		
		this.update();
	}
	
	/**
	 * Returns the current position.
	 */
	Vector2!T getPosition() const {
		return Vector2!T(this.x, this.y);
	}
	
	/**
	 * Move the object.
	 */
	void move(U)(ref const Vector2!U vec) {
		this.move(vec.x, vec.y);
	}
	
	/**
	 * Move the object.
	 */
	void move(U)(U x, U y) {
		this.x += x;
		this.y += y;
		
		this.update();
	}
	
	/**
	 * The new coordinates <b>and</b> a new size.
	 */
	void set(U, V)(U x, U y, V w, V h) {
		this.x = x;
		this.y = y;
		
		this.setSize(w, h); // calls 'update'
	}
	
	T[4] asArray() const pure nothrow {
		return [this.x, this.y, this.width, this.height];
	}
}

/**
 * alias for float
 */
alias FloatRect = Rect!float;
/**
 * alias for short
 */
alias ShortRect = Rect!short;