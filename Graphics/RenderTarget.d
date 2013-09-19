module Dgame.Graphics.RenderTarget;

private {
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Color;
}

class RenderTarget {
private:
	Texture _tex;
	
public:
	/**
	 * Texture coordinates
	 */
	float[8]  texels = void;
	/*
	 * Positions on the screen
	 */
	float[12] vertices = void;
	/**
	 * Color (optional)
	 */
	float[16] colors = void;
	
public:
final:
	this(Texture tex, ref float[8] texels, ref float[12] vertices) in {
		assert(tex !is null);
	} body {
		this._tex = tex;
		
		this.texels = texels;
		this.vertices = vertices;
	}
	
	this(Texture tex, float[8] texels, float[12] vertices) {
		this(tex, texels, vertices );
	}
	
	void setTexture(Texture tex) in {
		assert(tex !is null);
	} body {
		this._tex = tex;
	}
	
	@property
	inout(Texture) texture() inout pure nothrow {
		return this._tex;
	}
	
	void bind() const {
		this._tex.bind();
	}
	
	void unbind() const {
		this._tex.unbind();
	}
	
	void setColor(ref const Color col) pure nothrow {
		const float[4] glCol = col.asGLColor();
		
		for (ubyte i = 0; i < this.colors.length; i += 4) {
			this.colors[i .. i + 4] = glCol[];
		}
	}
	
	void setColor(const Color col) pure nothrow {
		this.setColor(col);
	}
	
	void addColors(ref const Color[4] cols) pure nothrow {
		for (ubyte i = 0, j = 0; i < this.colors.length; i += 4, j++) {
			this.colors[i .. i + 4] = cols[j].asGLColor()[];
		}
	}
	
	void addColors(const Color[4] cols) pure nothrow {
		this.addColors(cols);
	}
}