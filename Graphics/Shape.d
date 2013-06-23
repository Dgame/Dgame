module Dgame.Graphics.Shape;

private {
	debug import std.stdio;
	import std.math : sin, cos, PI;
	import std.algorithm : remove;
	
	import std.c.string : memcpy;
	
	import derelict2.opengl.gltypes;
	import derelict2.opengl.glfuncs;
	
	import Dgame.Core.Allocator;
	import Dgame.Core.Math;
	
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Interface.Transformable;
	import Dgame.Graphics.Interface.Blendable;
	import Dgame.Math.Pixel;
	import Dgame.System.Buffer;
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
	 * s.update(Shape.Update.Pixel | Shape.Update.Color);
	 * ----
	 * 
	 * or you can use 'Both'
	 *  ----
	 * Shape s = ...;
	 * s.update(Shape.Update.Both);
	 * ----
	 */
	enum Update {
		None   = 0, /// No buffer
		Vertex = 1, /// Only the Vertex Buffer
		Color  = 2, /// Only the Color Buffer
		Both   = 3  /// Both, Vertex and Color Buffer
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
	bool _shouldFill;
	bool _autoUpdate;
	
	Type _type;
	SmoothTarget _smoothTarget;
	SmoothHint	 _smoothHint;
	Update _update;
	
	Pixel[] _pixels;
	Buffer _buf;
	
	enum {
		DefMode = Type.LineLoop,
		VCount  = 3,
		CCount  = 4
	}
	
	//protected:
	void _updateVertexCache() {
		const uint vSize = this._pixels.length * VCount;
		debug {
			const uint cSize = this._pixels.length * CCount;
			writefln("Type: %s, Vertices: %d, vSize: %d, cSize: %d", this._type, this._pixels.length, vSize, cSize);
		}
		
		auto vecData = Memory.allocate!float(vSize, Mode.AutoFree);
		
		foreach (ref const Pixel px; this._pixels) {
			vecData ~= px.getPositionData();
		}
		
		this._buf.bind(Buffer.Target.Vertex);
		
		if (!this._buf.isCurrentEmpty())
			this._buf.modify(&vecData[0], vSize * float.sizeof);
		else
			this._buf.cache(&vecData[0], vSize * float.sizeof, Buffer.Dynamic.Draw);
		
		this._buf.unbind();
	}
	
	void _updateColorCache() {
		const uint cSize = this._pixels.length * CCount;
		
		auto colData = Memory.allocate!float(cSize, Mode.AutoFree);
		
		foreach (ref const Pixel px; this._pixels) {
			colData ~= px.getColorData();
		}
		
		this._buf.bind(Buffer.Target.Color);
		
		if (!this._buf.isCurrentEmpty())
			this._buf.modify(&colData[0], cSize * float.sizeof);
		else
			this._buf.cache(&colData[0], cSize * float.sizeof, Buffer.Dynamic.Draw);
		
		this._buf.unbind();
	}
	
	override void _render() {
		assert(this._buf !is null);
		
		if (this._update & Update.Vertex)
			this._updateVertexCache();
		
		if (this._update & Update.Color)
			this._updateColorCache();
		
		this._update = Update.None;
		
		if (this._buf.isEmpty(Buffer.Target.Vertex) || this._buf.isEmpty(Buffer.Target.Color))
			return;
		
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		glPushAttrib(GL_CURRENT_BIT | GL_COLOR_BUFFER_BIT | GL_ENABLE_BIT
		             | GL_HINT_BIT  | GL_LINE_BIT | GL_POINT_BIT);
		scope(exit) glPopAttrib();
		
		if (this._smoothTarget != SmoothTarget.None) {
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
			glRotatef(this._rotAngle, this._rotation.x, this._rotation.y, 1f);
		
		glTranslatef(super._position.x, super._position.y, 0f);
		
		if (!fpEqual(this._scale.x, 1f) && !fpEqual(this._scale.y, 1f))
			glScalef(this._scale.x, this._scale.y, 0f);
		
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
	
final:
	
	/**
	 * CTor
	 */
	this(Type type) {
		this._buf = new Buffer(Buffer.Target.Vertex | Buffer.Target.Color);
		
		this.update(Update.Both);
		this._lineWidth = 2;
		
		this._type = type;
		this._smoothTarget = SmoothTarget.None;
		this._smoothHint   = SmoothHint.Fastest;
		
		this._scale.set(1f, 1f);
	}
	
	/**
	 * DTor
	 */
	~this() {
		this._pixels = null;
	}
	
	/**
	 * Activate 'autoUpdate'.
	 * This means that which every append* or remove* method an update call is sended.
	 * This spare you the manual call of update, but if you have many calls which cause an update call and 'autoUpdate' is activated
	 * it could be more performant to disable this and handle the update call(s) by yourself.
	 * 
	 * Note: Default this is disabled.
	 * Note: Methods that do not need to update call, have a  brief note.
	 */
	void setAutoUpdate(bool val) {
		this._autoUpdate = val;
	}
	
	/**
	 * Returns if 'autoUpdate' is enabled.
	 * Default is disabled.
	 */
	bool isAutoUpdate() const pure nothrow {
		return this._autoUpdate;
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
	 * The current shape will be updated.
	 * If 'autoUpdate' is activated, this happens automatically,
	 * otherwise you should use this.
	 */
	void update(Update val) {
		if (this._update == Update.None)
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
	 * 
	 * Note: This method does not need an update call.
	 */
	void setPixelColor(ref const Color col) {
		//if (this._autoUpdate)
		this.update(Update.Color);
		
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
	 * 
	 * Note: This method does not need an update call.
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
	 * 
	 * Note: This method does not need an update call.
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
	void appendVector(ref const Vector2f vec) {
		if (this._autoUpdate)
			this.update(Update.Vertex);
		
		this._pixels ~= Pixel(vec);
	}
	
	/**
	 * Rvalue version
	 */
	void appendVector(const Vector2f vec) {
		this.appendVector(vec);
	}
	
	/**
	 * Stores a Pixel for this Shape.
	 */
	void appendPixel(ref const Pixel vx) {
		if (this._autoUpdate)
			this.update(Update.Vertex | Update.Color);
		
		this._pixels ~= vx;
	}
	
	/**
	 * Stores multiple Vertices for this Shape.
	 */
	void appendPixels(const Pixel[] pixels) {
		if (this._autoUpdate)
			this.update(Update.Vertex | Update.Color);
		
		this._pixels ~= pixels;
	}
	
	/**
	 * Stores multiple Pixel coordinates for this Shape.
	 */
	void appendVectors(const Vector2f[] vec) {
		if (this._autoUpdate)
			this.update(Update.Vertex);
		
		foreach (ref const Vector2f v; vec) {
			this.appendVector(v);
		}
	}
	
	/**
	 * Remove the Pixel on the specific index.
	 * If vp is not null, the droped Pixel is stored there.
	 */
	void remove(uint index, Pixel* vp = null) {
		if (this._autoUpdate)
			this.update(Update.Vertex);
		
		if (index >= this._pixels.length)
			return;
		
		if (vp)
			memcpy(vp, &this._pixels[index], Pixel.sizeof);
		
		this._pixels = .remove(this._pixels, index);
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
		
		for (uint i = 0; i < vec.length; ++i) {
			qs.appendVector(vec[i]);
		}
		
		return qs;
	}
	
	/**
	 * Make a new Shape object with the given type and vertices.
	 */
	static Shape make(Type type, const Pixel[] pixels) {
		Shape qs = new Shape(type);
		
		foreach (ref const Pixel px; pixels) {
			qs.appendPixel(px);
		}
		
		return qs;
	}
	
	/**
	 * Make a new Shape object as Circle.
	 */
	static Shape makeCircle(float radius, ref const Vector2f center, ubyte vecNum = 30) {
		assert(vecNum >= 10, "Need at least 10 vectors for a circle.");
		
		const float Deg2Rad = (PI * 2) / vecNum;
		
		Shape qs = new Shape(Type.LineLoop);
		
		for (ubyte i = 0; i < vecNum; i++) {
			float degInRad = i * Deg2Rad;
			
			float x = center.x + cos(degInRad) * radius;
			float y = center.y + sin(degInRad) * radius;
			
			qs.appendVector(Vector2f(x, y));
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