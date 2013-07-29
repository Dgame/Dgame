module Dgame.Graphics.Shape;

private {
	debug import std.stdio;
	import std.math : sin, cos, PI;
	import std.algorithm : remove;
	import core.stdc.string : memcpy;
	
	import derelict.opengl3.gl;
	import derelict.sdl2.sdl;
	
	import Dgame.Core.Math : fpEqual;
	import Dgame.Core.Memory.Allocator;
	
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Interface.Transformable;
	import Dgame.Graphics.Interface.Blendable;
	import Dgame.Math.Pixel;
	import Dgame.System.Buffer;
	import Dgame.System.VertexArray;
}

/**
 * Smooth wrapper
 */
struct Smooth {
public:
	/**
	 * Supported smooth targets.
	 */
	enum Target {
		None,					 /** No smooth (default). */
		Point = GL_POINT_SMOOTH, /** Enable smooth for points. */
		Line  = GL_LINE_SMOOTH   /** Enable smooth for lines. */
	}
	
	/**
	 * Smooth Hints to determine
	 * which kind of smoothing is made.
	 */
	enum Hint {
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
	
protected:
	ubyte _lineWidth;
	
	bool _shouldFill;
	bool _autoUpdate;
	bool _update;
	
	Type _type;
	Smooth _smooth = void;;
	
	Pixel[] _pixels;
	
	Buffer _buf;
	VertexArray _vab;
	
private:
	
	enum {
		DefaultType = Type.LineLoop,
		VCount  = 3,
		CCount  = 4,
		VCCount = VCount + CCount
	}
	
	void _updateVertexCache() {
		this._buf.bind(Primitive.Target.Vertex);
		scope(exit) this._buf.unbind();
		
		if (!this._buf.isCurrentEmpty())
			this._buf.modify(&this._pixels[0], this._pixels.length * Pixel.sizeof);
		else
			this._buf.cache(&this._pixels[0], this._pixels.length * Pixel.sizeof, Usage.Static.Draw);
	}
	
	void _checkForUpdate() {
		if (this._update) {
			this._vab.bind();
			scope(exit) this._vab.unbind();
			
			this._updateVertexCache();
			scope(exit) this._buf.unbind();
			
			this._buf.pointTo(Primitive.Target.Vertex, VCCount * float.sizeof);
			this._buf.pointTo(Primitive.Target.Color, VCCount * float.sizeof, VCount * float.sizeof);
			
			this._update = false;
		}
	}
	
protected:
	
	override void _render() in {
		assert(this._buf !is null);
	} body {
		/// Update caches
		this._checkForUpdate();
		
		glPushMatrix();
		scope(exit) glPopMatrix();
		glPushAttrib(GL_CURRENT_BIT 
		             | GL_COLOR_BUFFER_BIT
		             | GL_ENABLE_BIT
		             | GL_HINT_BIT
		             | GL_LINE_BIT
		             | GL_POINT_BIT);
		scope(exit) glPopAttrib();
		
		if (this._smooth.target != Smooth.Target.None) {
			glEnable(this._smooth.target);
			
			final switch (this._smooth.target) {
				case Smooth.Target.Point:
					glHint(GL_POINT_SMOOTH_HINT, this._smooth.hint);
					break;
				case Smooth.Target.Line:
					glHint(GL_LINE_SMOOTH_HINT, this._smooth.hint);
					break;
				case Smooth.Target.None:
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
		
		/// use blending
		this._processBlendMode();
		
		this._vab.bind();
		scope(exit) this._vab.unbind();
		
		Type type = !this.shouldFill() ? DefaultType : this._type;
		this._buf.drawArrays(shapeToPrimitive(type), this._pixels.length);
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
		this._buf = new Buffer(Primitive.Target.Vertex/* | Primitive.Target.Color*/);
		this._vab = new VertexArray();
		
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
	 * Activate 'autoUpdate'.
	 * This means that which every append* or remove* method an update call is sended.
	 * This spare you the manual call of update, but if you have many calls which cause an update call and 'autoUpdate' is activated
	 * it could be more performant to disable this and handle the update call(s) by yourself.
	 * 
	 * Note: Default this is disabled.
	 * Note: Methods that do not need to update call, have a  brief note.
	 */
	void setAutoUpdate(bool val) pure nothrow {
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
		if (this._autoUpdate)
			this.update(true);
		
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
		this.update(this._autoUpdate);
		
		this._pixels ~= vx;
	}
	
	/**
	 * Stores multiple Vertices for this Shape.
	 */
	void appendPixels(const Pixel[] pixels) {
		this.update(this._autoUpdate);
		
		this._pixels ~= pixels;
	}
	
	/**
	 * Stores multiple Pixel coordinates for this Shape.
	 */
	void appendVectors(const Vector2f[] vec) {
		this.update(this._autoUpdate);
		
		foreach (ref const Vector2f v; vec) {
			this.appendVector(v);
		}
	}
	
	/**
	 * Remove the Pixel on the specific index.
	 * If vp is not null, the droped Pixel is stored there.
	 */
	void remove(uint index, Pixel* vp = null) {
		this.update(this._autoUpdate);
		
		if (index >= this._pixels.length)
			return;
		
		if (vp)
			memcpy(vp, &this._pixels[index], Pixel.sizeof);
		
		this._pixels = .remove(this._pixels, index);
	}
	
	/**
	 * Returns all Pixel of this Shape.
	 */
	ref inout(Pixel[]) getPixels() inout pure nothrow {
		return this._pixels;
	}
	
	/**
	 * Returns a reference of the Pixel on the given index
	 * or fail if the index is out of range.
	 */
	inout(Pixel)* getPixelAt(uint idx) inout {
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
	static Shape makeCircle(float radius, ref const Vector2f center, ubyte vecNum = 30) in {
		assert(vecNum >= 10, "Need at least 10 vectors for a circle.");
	} body {
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