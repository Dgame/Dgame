module Dgame.Math.Rect;

private {
	debug import std.stdio : writeln;
	import std.traits : isNumeric;
	
	import derelict.sdl2.sdl;
	
	import Dgame.Core.Memory.Allocator;

	import Dgame.Math.Vector2;
}

private SDL_Rect[void*] _RectStore;

static ~this() {
	_RectStore = null;
}

/**
 * Rect defines a rectangle structure that contains the left upper corner and the width/height.
 *
 * Author: rschuett
 */
struct Rect(T) if (isNumeric!T) {
private:
	void _adaptToPtr() {
		this.set(cast(T) this.ptr.x,
		         cast(T) this.ptr.y,
		         cast(T) this.ptr.w,
		         cast(T) this.ptr.h);
	}
	
public:
	/**
	 * The x and y coordinates
	 */
	T x = 0;
	T y = 0;
	/**
	 * The width and the height
	 */
	T width = 0;
	T height = 0;
	
public:
	/**
	 * CTor
	 */
	this()(T x, T y, T width, T height) { // TODO: Fixed in 2.064
		this.x = x;
		this.y = y;
		
		this.width  = width;
		this.height = height;
	}
	
	/**
	 * CTor
	 */
	this()(ref const Vector2!T vec, T width, T height) { // TODO: Fixed in 2.064
		this(vec.x, vec.y, width, height);
	}
	
	/**
	 * CTor
	 */
	this(U)(ref const Rect!U rect) {
		this(cast(T) rect.x, cast(T) rect.y,
		     cast(T) rect.width, cast(T) rect.height);
	}
	
	this(this) {
		debug writeln("Postblit Rect");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref const Rect!T rhs) {
		debug writeln("opAssign Rect");
		this.set(rhs.x, rhs.y, rhs.width, rhs.height);
	}
	
	~this() {
		debug writeln("DTor Rect");
		
		_RectStore.remove(&this);
	}
	
	/**
	 * Returns a pointer to the inner SDL_Rect.
	 */
	@property
	SDL_Rect* ptr() const {
		const void* key = &this;
		
		/// TODO: Issue 11064
		const int x = cast(int) this.x;
		const int y = cast(int) this.y;
		const int w = cast(int) this.width;
		const int h = cast(int) this.height;
		
		if (SDL_Rect* _ptr = key in _RectStore) {
			_ptr.x = x;
			_ptr.y = y;
			_ptr.w = w;
			_ptr.h = h;
			
			return _ptr;
		} else
			_RectStore[key] = SDL_Rect(x, y, w, h);
		
		return &_RectStore[key];
	}
	
	/**
	 * Supported operations: +=, -=, *=, /=, %=
	 */
	Rect!T opBinary(string op)(ref const Rect!T rect) const pure nothrow {
		switch (op) {
			case "+":
				return Rect!T(this.x + rect.x,
				              this.y + rect.y,
				              this.width + rect.width,
				              this.height + rect.height);
			case "-":
				return Rect!T(this.x - rect.x,
				              this.y - rect.y,
				              this.width - rect.width,
				              this.height - rect.height);
			case "*":
				return Rect!T(this.x * rect.x,
				              this.y * rect.y,
				              this.width * rect.width,
				              this.height * rect.height);
			case "/":
				return Rect!T(this.x / rect.x,
				              this.y / rect.y,
				              this.width / rect.width,
				              this.height / rect.height);
			case "%":
				return Rect!T(this.x % rect.x,
				              this.y % rect.y,
				              this.width % rect.width,
				              this.height % rect.height);
			default: throw new Exception("Unsupported Operation: " ~ op);
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
	 * Checks if this Rect is empty (if it's collapsed).
	 */
	bool isEmpty() const {
		return SDL_RectEmpty(this.ptr);
	}
	
	/**
	 * Returns an union of the given and this Rect.
	 */
	Rect!T getUnion(ref const Rect!T rect) const {
		Rect!T union_rect;
		SDL_UnionRect(this.ptr, rect.ptr, union_rect.ptr);
		
		union_rect._adaptToPtr();
		
		return union_rect;
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool opBinaryRight(string op)(ref Vector2!T vec) const pure nothrow
		if (op == "in")
	{
		return this.contains(vec);
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool contains(ref const Vector2!T vec) const pure nothrow {
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
	bool opEquals(ref const Rect!T rect) const {
		return SDL_RectEquals(this.ptr, rect.ptr);
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
	bool intersects(ref const Rect!T rect, Rect!short* overlap = null) const {
		if (SDL_HasIntersection(this.ptr, rect.ptr)) {
			if (overlap !is null) {
				SDL_IntersectRect(this.ptr, rect.ptr, overlap.ptr);
				
				overlap._adaptToPtr();
			}
			
			return true;
		}
		
		return false;
	}
	
	/**
	 * Use this function to calculate a minimal rectangle enclosing a set of points.
	 */
	static Rect!T enclosePoints(const Vector2!T[] points) {
		Allocator m;
		SDL_Point[] sdl_points = m.alloc!SDL_Point(points.length);
		
		foreach (i, ref const Vector2!T p; points) {
			sdl_points[i] = SDL_Point(cast(int) p.x, cast(int) p.y);
		}
		
		Rect!T rect = void;
		SDL_EnclosePoints(sdl_points.ptr, cast(int)(points.length), null, rect.ptr);
		
		rect._adaptToPtr();
		
		return rect;
	}
	
	/**
	 * Replace current size.
	 */
	void setSize(T width, T height) pure nothrow {
		this.width  = width;
		this.height = height;
	}
	
	/**
	 * Returns the size (width and height) as static array.
	 */
	T[2] getSizeAsArray() const pure nothrow {
		return [this.x, this.y];
	}
	
	/**
	 * Increase current size.
	 */
	void increase(T width, T height) pure nothrow {
		this.width  += width;
		this.height += height;
	}
	
	/**
	 * Set a new position with a vector.
	 */
	void setPosition(ref const Vector2!T position) pure nothrow {
		this.setPosition(position.x, position.y);
	}
	
	/**
	 * Set a new position with an array.
	 */
	void setPosition(T[2] pos) pure nothrow {
		this.setPosition(pos[0], pos[1]);
	}
	
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(T x, T y) pure nothrow {
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Returns the position as static array.
	 */
	T[2] getPositionAsArray() const pure nothrow {
		return [this.x, this.y];
	}
	
	/**
	 * Creates a Vector2!T and returns thereby the current position.
	 */
	Vector2!T getPositionAsVector() const pure nothrow {
		return Vector2!T(this.x, this.y);
	}
	
	/**
	 * Move the object.
	 */
	void move(ref const Vector2!T vec) pure nothrow {
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
alias FloatRect = Rect!float;
/**
 * alias for short
 */
alias ShortRect = Rect!short;