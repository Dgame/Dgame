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
	import std.math : sin, cos, abs;
	import std.algorithm : remove, min, max;
	import core.stdc.string : memcpy;
	
	import derelict.opengl3.gl;
	
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Transformable;
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Blend;
	import Dgame.Math.Vertex;
	import Dgame.Math.Rect;
	import Dgame.System.VertexRenderer;
}

enum PIx2 = 3.14f * 2;

/**
 * Smooth wrapper
 */
struct Smooth {
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
	
	Target target; /// The Target
	Mode mode; /// The Mode
	GLenum hint; /// The GL Hint (is automatically set)
	
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

private struct Range {
	float min, max;
}

private struct RangePoint {
	Range x;
	Range y;
}

private RangePoint min_max(const Vertex[] vertices) pure nothrow {
	RangePoint rpoint = RangePoint(Range(vertices[0].x, vertices[0].x),
	                               Range(vertices[0].y, vertices[0].y));

	for (size_t i = 1; i < vertices.length; i++) {
		rpoint.x.min = min(rpoint.x.min, vertices[i].x);
		rpoint.x.max = max(rpoint.x.max, vertices[i].x);
		rpoint.y.min = min(rpoint.y.min, vertices[i].y);
		rpoint.y.max = max(rpoint.y.max, vertices[i].y);
	}

	return rpoint;
}

/**
 * Shape defines a drawable convex shape.
 * It also defines helper functions to draw simple shapes like lines, rectangles, circles, etc.
 *
 * Author: rschuett
 */
class Shape : Transformable, Drawable, Blendable {
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
	bool _isFilled = true;
	bool _needUpdate;
	
	Type _type;
	Smooth _smooth;
	
	Vertex[] _vertices;
	Texture _tex;
	ShortRect _texRect;
	Blend _blend;
	
protected:
	void _render() {
		if (this._vertices.length == 0)
			return;
		
		glPushAttrib(GL_ENABLE_BIT | GL_CURRENT_BIT | GL_COLOR_BUFFER_BIT);
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
		
		if (this._needUpdate 
		    && this._tex !is null)
		{
			this._needUpdate = false;
			this._updateTexCoords();
		}

		Vertex* vptr = &this._vertices[0];
		VertexRenderer.pointTo(Target.Vertex,    vptr, Vertex.sizeof,  0);
		VertexRenderer.pointTo(Target.Color,     vptr, Vertex.sizeof, 12);
		VertexRenderer.pointTo(Target.TexCoords, vptr, Vertex.sizeof, 28);
		
		if (this._tex !is null)
			this._tex.bind();

		if (this._blend !is null)
			this._blend.applyBlending();

		scope(exit) {
			if (this._tex !is null)
				this._tex.unbind();
			
			VertexRenderer.disableAllStates();
		}
		
		super._applyTranslation();
		
		const Type type = !this.isFilled() && this._tex is null ? Type.Unfilled : this._type;
		VertexRenderer.drawArrays(type, this._vertices.length);
	}
	
	final void _updateTexCoords() pure nothrow {
		if (this._vertices.length == 0)
			return;

		RangePoint rpoint = min_max(this._vertices);

		const float diff_x = abs(rpoint.x.min - rpoint.x.max);
		const float diff_y = abs(rpoint.y.min - rpoint.y.max);

		foreach (ref Vertex v; this._vertices) {
			v.tx = ((v.x - rpoint.x.min) / diff_x);
			v.ty = ((v.y - rpoint.y.min) / diff_y);
		}
		
		if (!this._texRect.isCollapsed()) {
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
	 * Calculate, store and return the center point.
	 */
	override ref const(Vector2s) calculateCenter() pure nothrow {
		const RangePoint rpoint = min_max(this._vertices);
		super.setCenter(cast(short)(rpoint.x.max / 2), cast(short)(rpoint.y.max / 2));

		return super.getCenter();
	}

	/**
	 * Set (or reset) the current Blend instance.
	 */
	void setBlend(Blend blend) pure nothrow {
		this._blend = blend;
	}

	/**
	 * Returns the current Blend instance, or null.
	 */
	inout(Blend) getBlend() inout pure nothrow {
		return this._blend;
	}
	
	/**
	* Bind (or unbind) a Texture.
	*/
	void bindTexture(Texture tex) {
		this.setColor(Color.White);
		
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
	 * Set target and mode of smoothing.
	 */
	void setSmooth(ref const Smooth smooth) pure nothrow {
		this.setSmooth(smooth.target, smooth.mode);
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
	void setColor(ref const Color col) {
		foreach (ref Vertex v; this._vertices) {
			v.setColor(col);
		}
	}
	
	/**
	 * Rvalue version
	 */
	void setColor(const Color col) {
		this.setColor(col);
	}
	
	/**
	 * Activate fill mode.
	 * This means the whole shape is drawn and not only the outlines.
	 * 
	 * Note: This method does not need an update call.
	 */
	void fill(bool fill) pure nothrow {
		this._isFilled = fill;
		if (this._type == Type.LineLoop)
			this._type = Type.Polygon;
	}
	
	/**
	 * Returns if the fill mode is active or not.
	 */
	bool isFilled() const pure nothrow {
		return this._isFilled;
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
	 * or throws an exception, if the index is out of rpoint.
	 */
	ref const(Vertex) getVertexAt(uint idx) const {
		if (idx < this._vertices.length)
			return this._vertices[idx];
		
		throw new Exception("No Vertex at this index.");
	}
	
	/**
	 * Returns a pointer of the Vertex at the given index
	 * or null if the index is out of rpoint.
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