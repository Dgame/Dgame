module Dgame.Graphics.VertexArray;

private {
	debug import std.stdio;
	
	import derelict.opengl3.gl;
	
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Drawable;
	import Dgame.Math.Vertex;
	import Dgame.System.VertexRenderer;
}

public import Dgame.System.VertexRenderer : Primitive;

/**
 * A VertexArray is a user defined OpenGL primitive.
 * It's like Shape, but it is not transformable.
 * It use Vertices and not Pixels.
 * Also it does not use a VBO and is therefore not that performant as a Shape.
 * A VertexArray can use indices and, unlike shape, a texture can be bound.
 * 
 * Author: rschuett
 */
class VertexArray : Drawable {
protected:
	override void _render(const Window wnd) in {
		assert(this._tex !is null);
	} body {
		if (this._vertices.length == 0)
			return;
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		Vertex* ptr = &this._vertices[0];
		
		VertexRenderer.pointTo(Primitive.Target.Vertex,    ptr, Vertex.sizeof,  0);
		VertexRenderer.pointTo(Primitive.Target.Color,     ptr, Vertex.sizeof, 12);
		VertexRenderer.pointTo(Primitive.Target.TexCoords, ptr, Vertex.sizeof, 28);
		
		this._tex.bind();
		
		scope(exit) {
			this._tex.unbind();
			
			VertexRenderer.disableAllStates();
		}
		
		if (this._indices.length == 0)
			VertexRenderer.drawArrays(this._type, this._vertices.length);
		else
			VertexRenderer.drawElements(this._type, this._vertices.length, this._indices);	
	}
	
private:
	Vertex[] _vertices;
	uint[] _indices;
	
	Texture _tex;
	Primitive.Type _type = Primitive.Type.Quad;
	
public:
final:
	/**
	 * CTor
	 */
	this() { }
	
	/**
	 * CTor
	 */
	this(Texture tex) {
		this._tex = tex;
	}
	
	/**
	 * CTor
	 */
	this(Texture tex, Primitive.Type type) {
		this._tex  = tex;
		this._type = type;
	}
	
	/**
	 * Set new indices
	 */
	void setIndices(uint[] indices) {
		this._indices = indices;
	}
	
	/**
	 * Fetch the existing indices to mutate them.
	 */
	inout(uint*) fetchIndices() inout {
		return this._indices.ptr;
	}
	
	/**
	 * Bind (or unbind) a Texture.
	 */
	void bindTexture(Texture tex) {
		this._tex = tex;
	}
	
	/**
	 * Set a primitive type. The default type is a Quad.
	 */
	void setType(Primitive.Type type) {
		this._type = type;
	}
	
	/**
	 * Append 9 floats as vertices and 6 as texels
	 * to map a texture on a Triangle.
	 */
	void append(float[9] vertices, float[6] texels) {
		for (ubyte i = 0, j = 0; i < 6; i += 2, j += 3) {
			const float vx = vertices[j],
				vy = vertices[j + 1], vz = vertices[j + 2];
			const float tx = texels[i],
				ty = texels[i + 1];
			
			this.appendVertex(Vertex(vx, vy, vz, tx, ty));
		}
	}
	
	/**
	 * Append 12 floats as vertices and 8 as texels
	 * to map a texture on a Quad.
	 */
	void append(float[12] vertices, float[8] texels) {
		for (ubyte i = 0, j = 0; i < 8; i += 2, j += 3) {
			const float vx = vertices[j],
				vy = vertices[j + 1], vz = vertices[j + 2];
			const float tx = texels[i],
				ty = texels[i + 1];
			
			this.appendVertex(Vertex(vx, vy, vz, tx, ty));
		}
	}
	
	/**
	 * Add a new Vertex.
	 */
	void appendVertex(ref const Vertex vec) {
		this._vertices ~= vec;
	}
	
	/**
	 * Rvalue version.
	 */
	void appendVertex(const Vertex vec) {
		this.appendVertex(vec);
	}
	
	/**
	 * Add an array of vertices.
	 */
	void appendVertices(const Vertex[] vertices) {
		foreach (ref const Vertex vec; vertices) {
			this.appendVertex(vec);
		}
	}
	
	/**
	 * Reset all Vertices.
	 */
	void resetVertices() {
		this._vertices = null;
	}
	
	/**
	 * Set a (new) Color for all vertices.
	 */
	void setColor(ref const Color col) {
		foreach (ref Vertex vec; this._vertices) {
			vec.setColor(col);
		}
	}
	
	/**
	 * Rvalue version.
	 */
	void setColor(const Color col) {
		this.setColor(col);
	}
}