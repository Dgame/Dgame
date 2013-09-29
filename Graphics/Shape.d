module Dgame.Graphics.Shape;

private {
	debug import std.stdio;
	import std.math : sin, cos, PI;
	import std.algorithm : remove;
	import core.stdc.string : memcpy;
	
	import derelict.opengl3.gl;
	
	import Dgame.Core.Memory.Allocator;
	
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Transformable;
	
	import Dgame.Math.Pixel;
	
	import Dgame.System.VertexBufferObject;
	import Dgame.System.VertexArrayObject;
}

/**
 * Smooth wrapper
 */
struct Smooth {
public:
	/**
	 * Supported smooth targets.
	 */
	enum Target : ushort {
		None,					 /** No smooth (default). */
		Point = GL_POINT_SMOOTH, /** Enable smooth for points. */
		Line  = GL_LINE_SMOOTH,   /** Enable smooth for lines. */
		Polygon = GL_POLYGON_SMOOTH_HINT /** Enable smooth for polygons. */
	}
	
	/**
	 * Smooth Hints to determine
	 * which kind of smoothing is made.
	 */
	enum Hint : ushort {
		DontCare = GL_DONT_CARE, /** The OpenGL implementation decide on their own. */
		Fastest = GL_FASTEST,    /** Fastest kind of smooth (default). */
		Nicest  = GL_NICEST	     /** Nicest but lowest kind of smooth. */
	}
	
	@disable
	this();
	
	@disable
	this(this);
	
	/**
	 * Returns the current target
	 */
	Target getTarget() const pure nothrow {
		return this.target;
	}
	
	/**
	 * Return the current hint
	 */
	Hint getHint() const pure nothrow {
		return this.hint;
	}
	
private:
	Target target;
	Hint hint;
	
	this(Target trg, Hint h) {
		this.target = target;
		this.hint = h;
	}
}

/**
 * Converts a PrimitiveType of the StaticBuffer into a valid Shape Type.
 * 
 * See: Shape.Type enum
 * See: PrimitiveType enum in StaticBuffer
 */
@safe
Shape.Type primitiveToShape(Primitive.Type ptype) pure nothrow {
	final switch (ptype) with (Primitive.Type) {
		case Quad:
			return Shape.Type.Quad;
		case QuadStrip:
			return Shape.Type.QuadStrip;
		case Triangle:
			return Shape.Type.Triangle;
		case TriangleStrip:
			return Shape.Type.TriangleStrip;
		case TriangleFan:
			return Shape.Type.TriangleFan;
		case Lines:
			return Shape.Type.Lines;
		case LineStrip:
			return Shape.Type.LineStrip;
		case LineLoop:
			return Shape.Type.LineLoop;
		case Polygon:
			return Shape.Type.Polygon;
	}
}

/**
 * Converts a Shape Type into a valid PrimitiveType of the StaticBuffer 
 * 
 * See: Shape.Type enum
 * See: PrimitiveType enum in StaticBuffer
 */
@safe
Primitive.Type shapeToPrimitive(Shape.Type stype) pure nothrow {
	final switch (stype) with (Shape.Type) {
		case Quad:
			return Primitive.Type.Quad;
		case QuadStrip:
			return Primitive.Type.QuadStrip;
		case Triangle:
			return Primitive.Type.Triangle;
		case TriangleStrip:
			return Primitive.Type.TriangleStrip;
		case TriangleFan:
			return Primitive.Type.TriangleFan;
		case Lines:
			return Primitive.Type.Lines;
		case LineStrip:
			return Primitive.Type.LineStrip;
		case LineLoop:
			return Primitive.Type.LineLoop;
		case Polygon:
			return Primitive.Type.Polygon;
	}
}

/**
 * Shape defines a drawable convex shape.
 * It also defines helper functions to draw simple shapes like lines, rectangles, circles, etc.
 *
 * Author: rschuett
 */
class Shape : Transformable, Drawable {
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
	
protected:
	ubyte _lineWidth;
	
	bool _shouldFill;
	bool _update;
	
	Type _type;
	Smooth _smooth = void;
	
	Pixel[] _pixels;
	
	VertexBufferObject _vbo;
	VertexArrayObject _vao;
	
private:
	enum DefaultType = Type.LineLoop;
	enum V_Count  = 3;
	enum C_Count  = 4;
	enum VC_Count = V_Count + C_Count;
	
private:
	void _updateVertexCache() {
		this._vbo.bind(Primitive.Target.Vertex);
		scope(exit) this._vbo.unbind();
		
		if (!this._vbo.isCurrentEmpty())
			this._vbo.modify(&this._pixels[0], this._pixels.length * Pixel.sizeof, Usage.Dynamic.Draw);
		else
			this._vbo.cache(&this._pixels[0], this._pixels.length * Pixel.sizeof, Usage.Dynamic.Draw);
	}
	
	void _checkForUpdate() {
		if (!this._update)
			return;
		
		scope(exit) {
			this._vbo.unbind();
			this._vao.unbind();
		}
		
		this._vao.bind();
		
		this._updateVertexCache();
		
		this._vbo.pointTo(Primitive.Target.Vertex, Pixel.sizeof);
		this._vbo.pointTo(Primitive.Target.Color,  Pixel.sizeof, V_Count * float.sizeof);
		
		this._update = false;
	}
	
protected:
	void _render() in {
		assert(this._vbo !is null);
	} body {
		glPushAttrib(GL_ENABLE_BIT);
		scope(exit) glPopAttrib();
		
		/// Update cache
		this._checkForUpdate();
		
		if (this._smooth.target != Smooth.Target.None) {
			if (!glIsEnabled(this._smooth.target))
				glEnable(this._smooth.target);
			
			glHint(this._smooth.target, this._smooth.hint);
		}
		
		if (glIsEnabled(GL_TEXTURE_2D))
			glDisable(GL_TEXTURE_2D);
		
		glLineWidth(this._lineWidth);
		
		this._vao.bind();
		scope(exit) this._vao.unbind();
		
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		super._applyTranslation();
		
		Type type = !this.shouldFill() ? DefaultType : this._type;
		this._vbo.drawArrays(shapeToPrimitive(type), this._pixels.length);
	}
	
public:
final:
	/**
	 * CTor
	 */
	this(Type type) {
		this._vbo = new VertexBufferObject(Primitive.Target.Vertex);
		this._vao = new VertexArrayObject();
		
		this._update = true;
		this._lineWidth = 2;
		
		this._type = type;
		this._smooth = Smooth(Smooth.Target.None, Smooth.Hint.Fastest);
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
	void setSmooth(Smooth.Target sTarget, Smooth.Hint sHint = Smooth.Hint.Fastest) pure nothrow {
		this._smooth.target = sTarget;
		this._smooth.hint = sHint;
	}
	
	/**
	 * Return the current smooth
	 */
	ref const(Smooth) getSmooth() const pure nothrow {
		return this._smooth;
	}
	
	/**
	 * The current shape will be updated.
	 * If 'autoUpdate' is activated, this happens automatically,
	 * otherwise you should use this.
	 */
	void update(bool update = true) pure nothrow {
		this._update = update;
	}
	
	/**
	 * Set or replace the current Shape type.
	 * 
	 * See: Shape.Type enum.
	 */
	void setType(Type type) pure nothrow {
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
		this.update(true);
		
		foreach (ref Pixel v; this._pixels) {
			v.setColor(col);
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
	void enableFill(bool fill) pure nothrow {
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
	void setLineWidth(ubyte width) pure nothrow {
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
		this._pixels ~= Pixel(vec, Color.Black);
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
		this._pixels ~= vx;
	}
	
	/**
	 * Stores multiple Vertices for this Shape.
	 */
	void appendPixels(const Pixel[] pixels) {
		this._pixels ~= pixels;
	}
	
	/**
	 * Stores multiple Pixel coordinates for this Shape.
	 */
	void appendVectors(const Vector2f[] vec) {
		foreach (ref const Vector2f v; vec) {
			this.appendVector(v);
		}
	}
	
	/**
	 * Remove the Pixel on the specific index.
	 * If vp is not null, the droped Pixel is stored there.
	 */
	void remove(uint index, Pixel* vp = null) {
		if (index >= this._pixels.length)
			return;
		
		if (vp)
			.memcpy(vp, &this._pixels[index], Pixel.sizeof);
		
		this._pixels = .remove(this._pixels, index);
	}
	
	/**
	 * Returns all Pixel of this Shape.
	 */
	const(Pixel[]) getPixels() const pure nothrow {
		return this._pixels;
	}
	
	/**
	 * Returns the Pixel at the given index
	 * or throws an exception, if the index is out of range.
	 */
	ref const(Pixel) getPixelAt(uint idx) const {
		if (idx < this._pixels.length)
			return this._pixels[idx];
		
		throw new Exception("No Pixel at this index.");
	}
	
	/**
	 * Returns a pointer of the Pixel at the given index
	 * or null if the index is out of range.
	 */
	inout(Pixel)* fetchPixelAt(uint idx) inout {
		return idx < this._pixels.length ? &this._pixels[idx] : null;
	}
	
	/**
	 * Make a new Shape object with the given type and vertices.
	 */
	static Shape make(Type type, const Vector2f[] vec) {
		Shape qs = new Shape(type);
		
		for (size_t i = 0; i < vec.length; ++i) {
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
	static Shape makeCircle(ubyte radius, ref const Vector2f center, ubyte vecNum = 30) in {
		assert(vecNum >= 10, "Need at least 10 vectors for a circle.");
	} body {
		enum PIx2 = PI * 2;
		const float Deg2Rad = PIx2 / vecNum;
		
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
	static Shape makeCircle(ubyte radius, const Vector2f center, ubyte vecNum = 30) {
		return Shape.makeCircle(radius, center, vecNum);
	}
}