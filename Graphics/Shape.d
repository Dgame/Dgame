module Dgame.Graphics.Shape;

private {
	debug import std.stdio;
	import std.math : sin, cos, PI;
	import std.algorithm : remove;
	
	import std.c.string : memcpy;
	
	import derelict.opengl.gltypes;
	import derelict.opengl.glfuncs;
	
	import Dgame.Core.Allocator;
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Math.Pixel;
	import Dgame.System.Buffer;
	import Dgame.Graphics.Interface.Transformable;
	import Dgame.Graphics.Interface.Blendable;
}

/**
 * Shape defines a drawable convex shape.
 * It also defines helper functions to draw simple shapes like lines, rectangles, circles, etc.
 *
 * Author: rschuett
 */
class Shape : Drawable, Transformable, Blendable {
public:
	/**
	 * Supported shape types.
	 */
	enum Type {
		Quad		= GL_QUADS,				/** Declare that the stored vertices are Quads. */
		QuadStrip	= GL_QUAD_STRIP,		/** Declare that the stored vertices are Quad Strips*/
		Triangle	= GL_TRIANGLES,			/** Declare that the stored vertices are Triangles. */
		TriangleStrip = GL_TRIANGLE_STRIP,	/** Declare that the stored vertices are Triangles Strips */
		TriangleFan = GL_TRIANGLE_FAN,		/** Declare that the stored vertices are Triangles Fans. */
		Lines		= GL_LINES,				/** Declare that the stored vertices are Lines. */
		LineStrip	= GL_LINE_STRIP,		/** Declare that the stored vertices are Line Strips. */
		LineLoop	= GL_LINE_LOOP,			/** Declare that the stored vertices are Line Loops. */
		Polygon		= GL_POLYGON			/** Declare that the stored vertices are Polygons. */
	}
	
	/**
	 * Which Buffer should updated.
	 * Can be ORed together:
	 * ----
	 * Shape s = ...;
	 * s.update(Shape.Cache.Pixel | Shape.Cache.Color);
	 * ----
	 */
	enum Cache {
		None   = 0, /// No buffer
		Pixel  = 1, /// Only the Pixel Buffer
		Color  = 2  /// Only the Color Buffer
	}
	
	/**
	 * Supported smooth targets.
	 */
	enum SmoothTarget {
		None,					 /** No smooth (default). */
		Point = GL_POINT_SMOOTH, /** Enable smooth for points. */
		Line  = GL_LINE_SMOOTH  /** Enable smooth for lines. */
	}
	
	/**
	 * Smooth Hints to determine
	 * which kind of smoothing is made.
	 */
	enum SmoothHint {
		Fastest = GL_FASTEST, /** Fastest kind of smooth (default). */
		Nicest  = GL_NICEST	  /** Nicest but lowest kind of smooth. */
	}
	
protected:
	ubyte _lineWidth;
	Cache _update;
	bool _shouldFill;
	
	Type _type;
	SmoothTarget _smoothTarget;
	SmoothHint	 _smoothHint;
	
	Pixel[] _pixels;
	Buffer _buf;
	
	enum {
		DefMode = Type.LineLoop,
		VCount  = 3,
		CCount  = 4
	}
	
protected:
	void _updatePixelCache() {
		const size_t vSize = this._pixels.length * VCount;
		debug {
			const size_t cSize = this._pixels.length * CCount;
			writefln("Type: %s, Vertices: %d, vSize: %d, cSize: %d", this._type, this._pixels.length, vSize, cSize);
		}
		
		auto vecData = Memory.alloc!float(vSize);
		scope(exit) Memory.free(vecData);
		
		foreach (ref const Pixel px; this._pixels) {
			vecData ~= px.getPositionData();
		}
		
		this._buf.bind(Buffer.Target.Vertex);
		
		if (!this._buf.isEmpty())
			this._buf.modify(&vecData[0], vSize * float.sizeof);
		else
			this._buf.cache(&vecData[0], vSize * float.sizeof, Buffer.Dynamic.Draw);
		
		this._buf.unbind();
	}
	
	void _updateColorCache() {
		const size_t cSize = this._pixels.length * CCount;
		
		auto colData = Memory.alloc!float(cSize);
		scope(exit) Memory.free(colData);
		
		foreach (ref const Pixel px; this._pixels) {
			colData ~= px.getColorData();
		}
		
		this._buf.bind(Buffer.Target.Color);
		
		if (!this._buf.isEmpty())
			this._buf.modify(&colData[0], cSize * float.sizeof);
		else
			this._buf.cache(&colData[0], cSize * float.sizeof, Buffer.Dynamic.Draw);
		
		this._buf.unbind();
	}
	
	override void _render() {
		assert(this._buf !is null);
		
		if (this._update & Cache.Pixel)
			this._updatePixelCache();
		
		if (this._update & Cache.Color)
			this._updateColorCache();
		
		this._update = Cache.None;
		
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		glPushAttrib(GL_CURRENT_BIT | GL_COLOR_BUFFER_BIT | GL_ENABLE_BIT
		             | GL_HINT_BIT  | GL_LINE_BIT | GL_POINT_BIT);
		scope(exit) glPopAttrib();
		
		bool smoothEnabled = false;
		if (this._smoothTarget != SmoothTarget.None) {
			smoothEnabled = true;
			
			glEnable(this._smoothTarget);
			
			final switch (this._smoothTarget) {
				case SmoothTarget.Point:
					glHint(GL_POINT_SMOOTH_HINT, this._smoothHint);
					break;
				case SmoothTarget.Line:
					glHint(GL_LINE_SMOOTH_HINT, this._smoothHint);
					break;
				case SmoothTarget.None:
					assert(0);
			}
		}
		
		if (this._rotAngle != 0)
			glRotatef(this._rotAngle, this._rotation.x, this._rotation.y, 1);
		
		glTranslatef(super._position.x, super._position.y, 0);
		
		if (!this._scale.x != 1.0 && this._scale.y != 1.0)
			glScalef(this._scale.x, this._scale.y, 0);
		
		if (glIsEnabled(GL_TEXTURE_2D))
			glDisable(GL_TEXTURE_2D);
		
		glLineWidth(this._lineWidth);
		
		this._buf.pointTo(Buffer.Target.Color);
		this._buf.pointTo(Buffer.Target.Vertex);
		/// use blending
		this._processBlendMode();
		
		this._buf.drawArrays(!this.shouldFill() ? DefMode : this._type, this._pixels.length);
		
		this._buf.disableAllStates();
		this._buf.unbind();
	}
	
public:
	/// mixin blendable functionality
	mixin TBlendable;
	/// mixin transformable functionality
	mixin TTransformable;
	
	/**
	 * CTor
	 */
	this(Type type) {
		this._buf = new Buffer(Buffer.Target.Vertex | Buffer.Target.Color);
		
		this.update(Cache.Pixel | Cache.Color);
		
		this._lineWidth = 2;
		
		this._type = type;
		this._smoothTarget = SmoothTarget.None;
		this._smoothHint   = SmoothHint.Fastest;
		
		this._scale.set(1, 1);
	}
	
	/**
	 * DTor
	 */
	~this() {
		this._pixels = null;
	}
	
	/**
	 * Set target and hint of smoothing.
	 */
	void setSmooth(SmoothTarget sTarget, SmoothHint sHint = SmoothHint.Fastest) {
		this._smoothTarget = sTarget;
		this._smoothHint = sHint;
	}
	
	/**
	 * Return smooth target;
	 */
	SmoothTarget getSmoothTarget() const pure nothrow {
		return this._smoothTarget;
	}
	
	/**
	 * Returns smooth hint.
	 */
	SmoothHint getSmoothHint() const pure nothrow {
		return this._smoothHint;
	}
	
	/**
	 * Activate an update.
	 * The current shape will be updated.
	 * In most cases, this happens automatically,
	 * but sometimes it is usefull.
	 */
	void update(Cache val) {
		if (this._update == Cache.None)
			this._update = val;
		else if (!(val & this._update))
			this._update |= val;
	}
	
	/**
	 * Set or replace the current Shape type.
	 * 
	 * See: Shape.Type enum.
	 */
	void setType(Type type) {
		this._type = type;
	}
	
	/**
	 * Returns the Shape Type.
	 * 
	 * See: Shape.Type enum.
	 */
	Type getType() const pure nothrow {
		return this._type;
	}
	
	/**
	 * Set for <b>all</b> vertices a (new) color.
	 */
	void setPixelColor(ref const Color col) {
		this.update(Cache.Color);
		
		foreach (ref Pixel v; this._pixels) {
			v.color = col;
		}
	}
	
	/**
	 * Rvalue version
	 */
	void setPixelColor(const Color col) {
		this.setPixelColor(col);
	}
	
	/**
	 * Activate fill mode.
	 * This means the whole shape is drawn and not only the outlines.
	 */
	void enableFill(bool fill) {
		this._shouldFill = fill;
	}
	
	/**
	 * Returns if the fill mode is active or not.
	 */
	bool shouldFill() const pure nothrow {
		return this._shouldFill;
	}
	
	/**
	 * Set the line width.
	 */
	void setLineWidth(ubyte width) {
		this._lineWidth = width;
	}
	
	/**
	 * Returns the line width.
	 */
	ubyte getLineWidth() const pure nothrow {
		return this._lineWidth;
	}
	
	/**
	 * Stores Pixel coordinates for this Shape.
	 */
	void addVector(ref const Vector2f vec) {
		this._pixels ~= Pixel(vec);
	}
	
	/**
	 * Rvalue version
	 */
	void addVector(const Vector2f vec) {
		this.addVector(vec);
	}
	
	/**
	 * Stores a Pixel for this Shape.
	 */
	void addPixel(ref const Pixel vx) {
		this._pixels ~= vx;
	}
	
	/**
	 * Stores multiple Vertices for this Shape.
	 */
	void addPixels(const Pixel[] pixels) {
		this._pixels ~= pixels;
	}
	
	/**
	 * Stores multiple Pixel coordinates for this Shape.
	 */
	void addVectors(const Vector2f[] vec) {
		foreach (ref const Vector2f v; vec) {
			this.addVector(v); // unnecessary copies
		}
	}
	
	/**
	 * Drop the Pixel on the specific index.
	 * If vp is not null, the droped Pixel is stored there.
	 */
	void dropPixel(size_t index, Pixel* vp = null) {
		if (index >= this._pixels.length)
			return;
		
		if (vp)
			memcpy(vp, &this._pixels[index], Pixel.sizeof);
		
		this._pixels = this._pixels.remove(index);
	}
	
	/**
	 * Returns all Pixel of this Shape.
	 */
	ref const(Pixel[]) getPixels() const pure nothrow {
		return this._pixels;
	}
	
	/**
	 * Returns a reference of the Pixel on the given index
	 * or fail if the index is out of range.
	 */
	ref inout(Pixel) getPixelAt(uint idx) inout {
		assert(idx < this._pixels.length, "Out of bounds.");
		
		return this._pixels[idx];
	}
	
	/**
	 * Returns a reference of the Pixel coordinates on the given index
	 * or fail if the index is out of range.
	 */
	ref inout(Vector2f) getVectorAt(uint idx) inout {
		return this.getPixelAt(idx).position;
	}
	
	/**
	 * Returns a reference of the Pixel color on the given index
	 * or fail if the index is out of range.
	 */
	ref inout(Color) getColorAt(uint idx) inout {
		return this.getPixelAt(idx).color;
	}
	
	/**
	 * Make a new Shape object with the given type and vertices.
	 */
	static Shape make(Type type, const Vector2f[] vec) {
		Shape qs = new Shape(type);
		
		for (size_t i = 0; i < vec.length; ++i) {
			qs.addVector(vec[i]);
		}
		
		return qs;
	}
	
	/**
	 * Make a new Shape object with the given type and vertices.
	 */
	static Shape make(Type type, const Pixel[] pixels) {
		Shape qs = new Shape(type);
		
		foreach (ref const Pixel px; pixels) {
			qs.addPixel(px);
		}
		
		return qs;
	}
	
	/**
	 * Make a new Shape object as Circle.
	 */
	static Shape makeCircle(float radius, ref const Vector2f center, ubyte vecNum = 30) {
		assert(vecNum >= 10, "Need at least 10 vectors for a circle.");
		
		const Deg2Rad = (PI * 2) / vecNum;
		
		Shape qs = new Shape(Type.LineLoop);
		
		for (ubyte i = 0; i < vecNum; i++) {
			float degInRad = i * Deg2Rad;
			
			float x = center.x + cos(degInRad) * radius;
			float y = center.y + sin(degInRad) * radius;
			
			qs.addVector(Vector2f(x, y));
		}
		
		return qs;
	}
	
	/**
	 * Rvalue version
	 */
	static Shape makeCircle(float radius, const Vector2f center, ubyte vecNum = 30) {
		return Shape.makeCircle(radius, center, vecNum);
	}
}