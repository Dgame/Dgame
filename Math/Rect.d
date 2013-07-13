module Dgame.Math.Rect;

private {
	debug import std.stdio;
	import std.traits : isNumeric;
	
	import derelict.sdl2.sdl;
	
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
	this(T x, T y, T width, T height) {
		this.x = x;
		this.y = y;
		
		this.width  = width;
		this.height = height;
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
		
		if (key !in _RectStore)
			_RectStore[key] = SDL_Rect(x, y, w, h);
		else {
			_RectStore[key].x = x;
			_RectStore[key].y = y;
			_RectStore[key].w = w;
			_RectStore[key].h = h;
		}
		
		return &_RectStore[key];
	}
	
	/**
	 * Supported operations: +=, -=, *=, /=, %=
	 */
	Rect!T opBinary(string op, U)(ref const Rect!U rect) const {
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
	void collapse() {
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
	bool contains(U)(U x, U y) const if (isNumeric!U) {
		return (x >= this.x) && (x < this.x + this.width)
			&& (y >= this.y) && (y < this.y + this.height);
	}
	
	/**
	 * opEquals: compares two rectangles on their coordinates and their size (but not explicit type).
	 */
	bool opEquals(U)(ref const Rect!U rect) const {
		return SDL_RectEquals(this.ptr, rect.ptr);
	}
	
	/**
	 * opCast to another Rect type.
	 */
	Rect!U opCast(V : Rect!U, U)() const {
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
	 * Replace current size.
	 */
	void setSize(U)(U width, U height) if (isNumeric!U) {
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
	void increase(U)(U width, U height) if (isNumeric!U) {
		this.width  += width;
		this.height += height;
	}
	
	/**
	 * Set a new position with a vector.
	 */
	void setPosition(U)(ref const Vector2!U position) {
		this.setPosition(position.x, position.y);
	}
	
	/**
	 * Set a new position with an array.
	 */
	void setPosition(U)(U[2] pos) if (isNumeric!U) {
		this.setPosition(pos[0], pos[1]);
	}
	
	/**
	 * Set a new position with coordinates.
	 */
	void setPosition(U)(U x, U y) if (isNumeric!U) {
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
	void move(U)(U x, U y) if (isNumeric!U) {
		this.x += x;
		this.y += y;
	}
	
	/**
	 * The new coordinates <b>and</b> a new size.
	 */
	void set(U, V)(U x, U y, V w, V h) if (isNumeric!U && isNumeric!V) {
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