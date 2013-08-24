module Dgame.Math.Rect;

private {
	debug import std.stdio;
	import std.traits : isNumeric;
	
	import derelict.sdl2.sdl;
	
	import Dgame.Core.Memory.Allocator;
	import Dgame.Math.Vector2;
}

///version = Develop;

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
		this.set(this.ptr.x, this.ptr.y, this.ptr.w, this.ptr.h);
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
	
	version(Develop)
	this(this) {
		writeln("Postblit Rect");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(U)(ref const Rect!U rhs) {
		debug writeln("opAssign Rect");
		this.set(rhs.x, rhs.y, rhs.width, rhs.height);
	}
	
	version(Develop)
	~this() {
		writeln("DTor Rect");
	}
	
	/**
	 * Returns a pointer to the inner SDL_Rect.
	 */
	@property
	SDL_Rect* ptr() const {
		const void* key = &this;
		
		int x = cast(int) this.x;
		int y = cast(int) this.y;
		int w = cast(int) this.width;
		int h = cast(int) this.height;
		
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
	Rect!T opBinary(string op, U)(ref const Rect!U rect) const pure nothrow {
		switch (op) {
			case "+":
				return Rect!T(cast(T)(this.x + rect.x),
				              cast(T)(this.y + rect.y),
				              cast(T)(this.width + rect.width),
				              cast(T)(this.height + rect.height));
			case "-":
				return Rect!T(cast(T)(this.x - rect.x),
				              cast(T)(this.y - rect.y),
				              cast(T)(this.width - rect.width),
				              cast(T)(this.height - rect.height));
			case "*":
				return Rect!T(cast(T)(this.x * rect.x),
				              cast(T)(this.y * rect.y),
				              cast(T)(this.width * rect.width),
				              cast(T)(this.height * rect.height));
			case "/":
				return Rect!T(cast(T)(this.x / rect.x),
				              cast(T)(this.y / rect.y),
				              cast(T)(this.width / rect.width),
				              cast(T)(this.height / rect.height));
			case "%":
				return Rect!T(cast(T)(this.x % rect.x),
				              cast(T)(this.y % rect.y),
				              cast(T)(this.width % rect.width),
				              cast(T)(this.height % rect.height));
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
		Rect!T union_rect = void;
		SDL_UnionRect(this.ptr, rect.ptr, union_rect.ptr);
		
		union_rect._adaptToPtr();
		
		return union_rect;
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool opBinaryRight(string op, U)(ref Vector2!U vec) const pure nothrow
		if (op == "in")
	{
		return this.contains(vec);
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool contains(U)(ref const Vector2!U vec) const pure nothrow {
		return this.contains(vec.x, vec.y);
	}
	
	/**
	 * Checks whether this Rect contains the given coordinates.
	 */
	bool contains(U)(U x, U y) const pure nothrow
		if (isNumeric!U)
	{
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
		return Rect!U(cast(U) this.x,
		              cast(U) this.y,
		              cast(U) this.width,
		              cast(U) this.height);
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
		SDL_Point* sdl_points = Memory.allocate!SDL_Point(points.length);
		scope(exit) Memory.deallocate(sdl_points);
		
		foreach (i, ref const Vector2!T p; points) {
			sdl_points[i] = SDL_Point(cast(int) p.x, cast(int) p.y);
		}
		
		Rect!T rect = void;
		SDL_EnclosePoints(sdl_points, points.length, null, rect.ptr);
		
		rect._adaptToPtr();
		
		return rect;
	}
	
	/**
	 * Replace current size.
	 */
	void setSize(U)(U width, U height) pure nothrow
		if (isNumeric!U)
	{
		this.width  = cast(T) width;
		this.height = cast(T) height;
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
	void increase(int width, int height) pure nothrow {
		this.width  += width;
		this.height += height;
	}
	
	/**
	 * Set a new position with a vector.
	 */
	void setPosition(U)(ref const Vector2!U position) pure nothrow {
		this.setPosition(position.x, position.y);
	}
	
	/**
	 * Set a new position with an array.
	 */
	void setPosition(U)(U[2] pos) pure nothrow
		if (isNumeric!U)
	{
		this.setPosition(pos[0], pos[1]);
	}
	
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(U)(U x, U y) pure nothrow
		if (isNumeric!U)
	{
		this.x = cast(T) x;
		this.y = cast(T) y;
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
	void move(U)(ref const Vector2!U vec) pure nothrow {
		this.move(vec.x, vec.y);
	}
	
	/**
	 * Move the object.
	 */
	void move(U)(U x, U y) pure nothrow
		if (isNumeric!U)
	{
		this.x += x;
		this.y += y;
	}
	
	/**
	 * The new coordinates <b>and</b> a new size.
	 */
	void set(U, V)(U x, U y, V w, V h) pure nothrow
		if (isNumeric!U && isNumeric!V)
	{
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