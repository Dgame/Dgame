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
module Dgame.Graphics.Shape;

private {
	import std.math : sin, cos;
	import std.algorithm : remove;
	import core.stdc.string : memcpy;
	
	import derelict.opengl3.gl;

	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Transformable;
	import Dgame.Graphics.Texture;
	import Dgame.Math.Vertex;
	import Dgame.Math.Rect;
	import Dgame.System.VertexRenderer;
}

struct MinMax {
	float min, max;
}

float abs(float a) pure nothrow {
	if (a >= 0)
		return a;

	return a * -1;
}

float min(float a, float b) pure nothrow {
	return a < b ? a : b;
}

float max(float a, float b) pure nothrow {
	return a > b ? a : b;
}

MinMax[2] minmax(const Vertex[] vertices) pure nothrow {
	MinMax[2] mm = void;
	mm[0] = MinMax(vertices[0].x, vertices[0].x);
	mm[1] = MinMax(vertices[0].y, vertices[0].y);

	for (size_t i = 1; i < vertices.length; i++) {
		mm[0].min = min(mm[0].min, vertices[i].x);
		mm[0].max = max(mm[0].max, vertices[i].x);

		mm[1].min = min(mm[1].min, vertices[i].y);
		mm[1].max = max(mm[1].max, vertices[i].y);
	}

	return mm;
}

enum PIx2 = 3.14f * 2;

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
		Line  = GL_LINE_SMOOTH,   /** Enable smooth for lines. */
		Polygon = GL_POLYGON_SMOOTH /** Enable smooth for polygons. */
	}
	
	/**
	 * The smooth mode
	 */
	enum Mode {
		DontCare = GL_DONT_CARE, /** The OpenGL implementation decide on their own. */
		Fastest = GL_FASTEST,    /** Fastest kind of smooth (default). */
		Nicest  = GL_NICEST	     /** Nicest but slowest kind of smooth. */
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
	* Return the current mode
	*/
	Mode getMode() const pure nothrow {
		return this.mode;
	}
	
private:
	Target target;
	Mode mode;
	GLenum hint;
	
	this(Target trg, Mode mode) {
		this.target = target;
		this.mode = mode;

		final switch (this.target) {
			case Target.None: break;
			case Target.Point:
				this.hint = GL_POINT_SMOOTH_HINT;
				break;
			case Target.Line:
				this.hint = GL_LINE_SMOOTH_HINT;
				break;
			case Target.Polygon:
				this.hint = GL_POLYGON_SMOOTH_HINT;
				break;
		}
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
		Quad = GL_QUADS,			/** Declare that the stored vertices are Quads. */
		QuadStrip = GL_QUAD_STRIP,	/** Declare that the stored vertices are Quad Strips*/
		Triangle = GL_TRIANGLES,	/** Declare that the stored vertices are Triangles. */
		TriangleStrip = GL_TRIANGLE_STRIP,	/** Declare that the stored vertices are Triangles Strips */
		TriangleFan = GL_TRIANGLE_FAN,		/** Declare that the stored vertices are Triangles Fans. */
		Lines = GL_LINES,			/** Declare that the stored vertices are Lines. */
		LineStrip = GL_LINE_STRIP,	/** Declare that the stored vertices are Line Strips. */
		LineLoop = GL_LINE_LOOP,	/** Declare that the stored vertices are Line Loops. */
		Polygon = GL_POLYGON,		/** Declare that the stored vertices are Polygons. */

		Unfilled = LineLoop,		/** Unfilled Type. It is identical to LineLoop. */
		Circle = TriangleFan		/** Circle Type. It is identical to TriangleFan. */
	}
	
protected:
	ubyte _lineWidth;
	bool _filled = true;
	bool _needUpdate = false;
	
	Type _type;
	Smooth _smooth;
	
	Vertex[] _vertices;
	Texture _tex;
	ShortRect _texRect;

protected:
	void _render() {
		if (this._vertices.length == 0)
			return;

		glPushAttrib(GL_ENABLE_BIT);
		scope(exit) glPopAttrib();

		const bool texEnabled = glIsEnabled(GL_TEXTURE_2D) == GL_TRUE;

		if (this._tex is null && texEnabled)
			glDisable(GL_TEXTURE_2D);
		else if (this._tex !is null && !texEnabled)
			glEnable(GL_TEXTURE_2D);

		if (this._smooth.target != Smooth.Target.None) {
			if (!glIsEnabled(this._smooth.target))
				glEnable(this._smooth.target);
			
			glHint(this._smooth.hint, this._smooth.mode);
		}

		if (this._lineWidth > 1)
			glLineWidth(this._lineWidth);
		
		glPushMatrix();
		scope(exit) glPopMatrix();

		if (this._needUpdate && this._tex !is null) {
			this._needUpdate = false;

			this._updateTexCoords();
		}

		Vertex* ptr = &this._vertices[0];

		VertexRenderer.pointTo(Primitive.Target.Vertex,    ptr, Vertex.sizeof,  0);
		VertexRenderer.pointTo(Primitive.Target.Color,     ptr, Vertex.sizeof, 12);
		VertexRenderer.pointTo(Primitive.Target.TexCoords, ptr, Vertex.sizeof, 28);

		if (this._tex !is null)
			this._tex.bind();
		
		scope(exit) {
			if (this._tex !is null)
				this._tex.unbind();

			VertexRenderer.disableAllStates();
		}
		
		super.applyTranslation();
		
		Type type = !this.filled() && this._tex is null ? Type.Unfilled : this._type;
		VertexRenderer.drawArrays(shapeToPrimitive(type), this._vertices.length);
	}

	override int[2] _getAreaSize() const pure nothrow {
		const MinMax[2] mm = minmax(this._vertices);

		return [cast(int) mm[0].max, cast(int) mm[1].max];
	}

	final void _updateTexCoords() pure nothrow {
		if (this._vertices.length == 0)
			return;

		const MinMax[2] mm = minmax(this._vertices);

		//debug writefln("min_x = %f, max_x = %f", mm[0].min, mm[0].max);
		//debug writefln("min_y = %f, max_y = %f", mm[1].min, mm[1].max);

		const float diff_x = abs(mm[0].min - mm[0].max);
		const float diff_y = abs(mm[1].min - mm[1].max);

		//debug writefln("diff_x = %f, diff_y = %f", diff_x, diff_y);

		foreach (ref Vertex v; this._vertices) {
			v.tx = ((v.x - mm[0].min) / diff_x);
			v.ty = ((v.y - mm[1].min) / diff_y);
		}

		if (!this._texRect.hasArea()) {
			const float tx = (0f + this._texRect.x) / this._tex.width;
			const float ty = (0f + this._texRect.y) / this._tex.height;
			const float tw = (0f + this._texRect.width) / this._tex.width;
			const float th = (0f + this._texRect.height) / this._tex.height;

			foreach (ref Vertex v; this._vertices) {
				v.tx = (v.tx * tw) + tx;
				v.ty = (v.ty * th) + ty;
			}
		}
	}
	
public:
final:
	/**
	 * CTor
	 */
	this(Type type, Texture tex = null) {
		this._type = type;
		this._smooth = Smooth(Smooth.Target.None, Smooth.Mode.Fastest);

		this.bindTexture(tex);
	}

	/**
	* Bind (or unbind) a Texture.
	*/
	void bindTexture(Texture tex) {
		this._tex = tex;

		if (tex !is null && this._type == Type.LineLoop)
			this._type = Type.Polygon;
	}

	/**
	 * Set a Texture Rect
	 */
	void setTextureRect(ref const ShortRect texRect) {
		this._texRect = texRect;
	}

	/**
	 * Rvalue version
	 */
	void setTextureRect(const ShortRect texRect) {
		this.setTextureRect(texRect);
	}

	/**
	 * Returns a pointer to the Texture Rect.
	 * With this you can change the existing Rect without setting a new one.
	 * You can e.g. collapse the Rect with this method.
	 * Example:
	 * ---
	 * Shape s = Shape.make(...);
	 * // A lot of code
	 * s.fetchTextureRect().collapse();
	 * ---
	 */
	inout(ShortRect*) fetchTextureRect() inout pure nothrow {
		return &this._texRect;
	}

	/**
	 * Set target and mode of smoothing.
	 */
	void setSmooth(Smooth.Target sTarget, Smooth.Mode sMode = Smooth.Mode.Fastest) pure nothrow {
		this._smooth.target = sTarget;
		this._smooth.mode = sMode;
	}
	
	/**
	 * Return the current smooth
	 */
	ref const(Smooth) getSmooth() const pure nothrow {
		return this._smooth;
	}
	
	/**
	 * The current shape will be updated.
	 */
	void forceUpdate() pure nothrow {
		this._needUpdate = true;
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
	void setVertexColor(ref const Color col) {
		foreach (ref Vertex v; this._vertices) {
			v.setColor(col);
		}
	}
	
	/**
	 * Rvalue version
	 */
	void setVertexColor(const Color col) {
		this.setVertexColor(col);
	}
	
	/**
	 * Activate fill mode.
	 * This means the whole shape is drawn and not only the outlines.
	 * 
	 * Note: This method does not need an update call.
	 */
	void fill(bool fill) pure nothrow {
		this._filled = fill;

		if (this._type == Type.LineLoop)
			this._type = Type.Polygon;
	}
	
	/**
	 * Returns if the fill mode is active or not.
	 */
	bool filled() const pure nothrow {
		return this._filled;
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
	 * Stores a Vertex for this Shape.
	 */
	void append(ref const Vertex vx) {
		this._needUpdate = true;

		this._vertices ~= vx;
	}

	/**
	 * Rvalue version.
	 */
	void append(const Vertex vec) {
		this.append(vec);
	}
	
	/**
	 * Stores multiple Vertices for this Shape.
	 */
	void append(const Vertex[] vertices) {
		this._needUpdate = true;

		this._vertices ~= vertices;
	}
	
	/**
	 * Remove the Vertex on the specific index.
	 * If vp is not null, the droped Vertex is stored there.
	 */
	void remove(uint index, Vertex* vp = null) {
		if (index >= this._vertices.length)
			return;

		this._needUpdate = true;

		if (vp !is null)
			.memcpy(vp, &this._vertices[index], Vertex.sizeof);
		
		this._vertices = .remove(this._vertices, index);
	}
	
	/**
	 * Returns all Vertex of this Shape.
	 */
	const(Vertex[]) getVertices() const pure nothrow {
		return this._vertices;
	}
	
	/**
	 * Returns the Vertex at the given index
	 * or throws an exception, if the index is out of range.
	 */
	ref const(Vertex) getVertexAt(uint idx) const {
		if (idx < this._vertices.length)
			return this._vertices[idx];
		
		throw new Exception("No Vertex at this index.");
	}
	
	/**
	 * Returns a pointer of the Vertex at the given index
	 * or null if the index is out of range.
	 */
	inout(Vertex)* fetchVertexAt(uint idx) inout {
		return idx < this._vertices.length ? &this._vertices[idx] : null;
	}

	/**
	* Add an array of floats
	* Note that 3 dimensional coordinate components are expected.
	*/
	static Shape make(Type type, const float[] mat) {
		Shape s = new Shape(type);

		const size_t size = mat.length % 3 == 0 ? mat.length : mat.length - (mat.length % 3);
		for (size_t i = 0; i < size; i += 3) {
			s.append(Vertex(mat[i], mat[i + 1], mat[i + 2]));
		}

		return s;
	}

	/**
	 * Make a new Shape object with the given type and vertices.
	 */
	static Shape make(Type type, const Vertex[] vertices) {
		Shape qs = new Shape(type);
		
		foreach (ref const Vertex v; vertices) {
			qs.append(v);
		}
		
		return qs;
	}

	/**
	 * Make a new Shape object as Circle.
	 */
	static Shape makeCircle(ubyte radius, const Vector2f center, ubyte vecNum = 30) in {
		assert(vecNum >= 10, "Need at least 10 vectors for a circle.");
	} body {
		const float Deg2Rad = PIx2 / vecNum;
		
		Shape s = new Shape(Type.Circle);

		for (ubyte i = 0; i < vecNum; i++) {
			const float degInRad = i * Deg2Rad;
			
			float x = center.x + cos(degInRad) * radius;
			float y = center.y + sin(degInRad) * radius;

			s.append(Vertex(x, y));
		}

		return s;
	}
}