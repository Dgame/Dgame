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
	ShortRect _texView;
	
	Viewport _tview;
	
protected:
	void _render() const in {
		assert(this._tex !is null, "Sprite couldn't rendered, because the Texture is null.");
	} body {
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		super._applyTranslation();
		
		this._tex._render(&this._tview);
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
		
		this._tview = Viewport(&this._clipRect, &this._texView);
	}
	
	/**
	 * Calculate, store and return the center point.
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
	 * Set a Texture Rect.
	 * This indicates which area of the Texture is drawn.
	 */
	void setTextureRect(ref const ShortRect texView) {
		this._texView = texView;
		
		this._clipRect.setSize(texView.width, texView.height);
	}
	
	/**
	 * Rvalue version
	 */
	void setTextureRect(const ShortRect texView) {
		this.setTextureRect(texView);
	}
	
	/**
	 * Returns if this Texture has a Texture Rect
	 */
	bool hasTextureRect() const {
		return !this._texView.isEmpty();
	}
	
	/**
	 * Reset the current Texture Rect with a call to Rect.collapse
	 */
	void resetTextureRect() in {
		assert(this._tex !is null);
	} body {
		this._texView.collapse();
		
		this._clipRect.setSize(this._tex.width, this._tex.height);
	}
	
	/**
	 * Returns the current Texture Rect
	 */
	ref const(ShortRect) getTextureRect() const pure nothrow {
		return this._texView;
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