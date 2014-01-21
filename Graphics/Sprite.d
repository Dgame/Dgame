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
module Dgame.Graphics.Sprite;

private {
	import derelict.opengl3.gl;
	
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Transformable;
	import Dgame.Graphics.Texture;
	import Dgame.Math.Vector2;
	import Dgame.Math.Rect;
	import Dgame.Graphics.Shape;
	import Dgame.System.VertexRenderer;
}

/**
 * Sprite represents a drawable object and maintains a texture and his position.
 *
 * Author: rschuett
 */
class Sprite : Transformable, Drawable {
protected:
	Texture _tex;
	ShortRect _clipRect;

protected:
	void _render() const in {
		assert(this._tex !is null, "Sprite couldn't rendered, because the Texture is null.");
	} body {
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		super._applyTranslation();
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		glPushAttrib(GL_CURRENT_BIT | GL_COLOR_BUFFER_BIT);
		scope(exit) glPopAttrib();
		
		float dx = this._clipRect.x;
		float dy = this._clipRect.y;
		float dw = this._clipRect.width  == 0 ? this._tex.width  : this._clipRect.width;
		float dh = this._clipRect.height == 0 ? this._tex.height : this._clipRect.height;
		
		float[12] vertices = [
			dx,	     dy,      0f,	
			dx + dw, dy,      0f,
			dx + dw, dy + dh, 0f,
			dx,      dy + dh, 0f
		];
		
		float[8] texCoords = this._calculateTextureCoordinates();

		VertexRenderer.pointTo(Target.Vertex, &vertices[0]);
		VertexRenderer.pointTo(Target.TexCoords, &texCoords[0]);
		
		scope(exit) {
			VertexRenderer.disableAllStates();
			this._tex.unbind();
		}
		
		this._tex.bind();
		
		VertexRenderer.drawArrays(Shape.Type.TriangleFan, vertices.length);
	}

	float[8] _calculateTextureCoordinates() const pure nothrow {
		return [0f, 0f, 1f, 0f, 1f, 1f, 0f, 1f];
	}
	
public:
	/**
	 * CTor
	 */
	this() {
		this(null);
	}
	
	/**
	 * CTor
	 */
	this(Texture tex) {
		this.setTexture(tex);
	}
	
	/**
	 * Calculate, store and return the center point.
	 * Usefull for e.g. rotate.
	 */
	override ref const(Vector2s) calculateCenter() pure nothrow {
		super.setCenter(this._clipRect.width / 2, this._clipRect.height / 2);
		
		return super.getCenter();
	}
	
	/**
	 * Check whether the bounding box of this Sprite collide
	 * with the bounding box of another Sprite
	 */
	bool collideWith(const Sprite rhs) const {
		return this.collideWith(this._clipRect);
	}
	
	/**
	 * Check whether the bounding box of this Sprite collide
	 * with the given Rect
	 */
	bool collideWith(ref const ShortRect rect) const {
		return this._clipRect.intersects(rect);
	}
	
	/**
	 * Rvalue version
	 */
	bool collideWith(const ShortRect rect) const {
		return this.collideWith(rect);
	}

final:
	/**
	 * Returns the current width (the width of the current texture).
	 */
	@property
	ushort width() const in {
		assert(this._tex !is null);
	} body {
		return this._tex.width;
	}

	/**
	 * Returns the current height (the height of the current texture).
	 */
	@property
	ushort height() const in {
		assert(this._tex !is null);
	} body {
		return this._tex.height;
	}

	/**
	 * Returns the clip rect, the area which will be drawn on the screen.
	 */
	ref const(ShortRect) getClipRect() const pure nothrow {
		return this._clipRect;
	}
	
	/**
	 * Check if the current Sprite has already a Texture/Image.
	 * If not, nothing can be drawn.
	 * But it does not check if the current Texture is valid.
	 */
	bool hasTexture() const pure nothrow {
		return this._tex !is null;
	}
	
	/**
	 * Set or replace the current Texture.
	 */
	void setTexture(Texture tex) in {
		assert(tex !is null, "Cannot set a null Texture.");
	} body {
		this._tex = tex;
		this._clipRect.setSize(tex.width, tex.height);
	}
	
	/**
	 * Returns the current Texture or null if there is none.
	 */
	inout(Texture) getTexture() inout {
		return this._tex;
	}
}