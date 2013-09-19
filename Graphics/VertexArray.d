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
	this() { }
	
	this(Texture tex) {
		this._tex = tex;
	}
	
	this(Texture tex, Primitive.Type type) {
		this._tex  = tex;
		this._type = type;
	}
	
	void setIndices(uint[] indices) {
		this._indices = indices;
	}
	
	inout(uint*) getIndices() inout {
		return this._indices.ptr;
	}
	
	void bindTexture(Texture tex) {
		this._tex = tex;
	}
	
	void setType(Primitive.Type type) {
		this._type = type;
	}
	
	void append(ref const float[12] vertices, ref const float[8] texels) {
		for (ubyte i = 0, j = 0; i < 8; i += 2, j += 3) {
			const float vx = vertices[j],
				vy = vertices[j + 1], vz = vertices[j + 2];
			const float tx = texels[i],
				ty = texels[i + 1];
			
			this.appendVertex(Vertex(vx, vy, vz, tx, ty));
		}
	}
	
	void appendVertex(ref const Vertex vec) {
		this._vertices ~= vec;
	}
	
	void appendVertex(const Vertex vec) {
		this.appendVertex(vec);
	}
	
	void appendVertices(const Vertex[] vertices) {
		foreach (ref const Vertex vec; vertices) {
			this.appendVertex(vec);
		}
	}
	
	void resetVertices() {
		this._vertices = null;
	}
	
	void setColor(ref const Color col) {
		foreach (ref Vertex vec; this._vertices) {
			vec.setColor(col);
		}
	}
	
	void setColor(const Color col) {
		this.setColor(col);
	}
}