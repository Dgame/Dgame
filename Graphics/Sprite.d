module Dgame.Graphics.Sprite;

private {
	debug import std.stdio;
	
	import derelict.opengl3.gl;
	
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Transformable;
	import Dgame.Graphics.Texture;
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
	
	FloatRect _boundingBox;
	ShortRect _clipRect;
	ShortRect _texView;
	
protected:
	/**
	 * Possible observer method if a new position is set.
	 */
	override void _positionMoved(float nx, float ny) {
		this._boundingBox.setPosition(nx, ny);
	}
	
	/**
	 * Possible observer method if the position change.
	 */
	override void _positionReset(float dx, float dy) {
		this._boundingBox.move(dx, dy);
	}
	
protected:
	void _render() in {
		assert(this._tex !is null, "Sprite couldn't rendered, because the Texture is null.");
	} body {
		glPushMatrix();
		scope(exit) glPopMatrix();
		
		this._applyTranslation();

		this._tex._render(this._clipRect,
		                  this._texView.isEmpty() ? null : &this._texView);
	}
	
public:
	
	/**
	 * CTor
	 */
	this() {
		this._tex = null;
	}
	
	/**
	 * CTor
	 */
	this(Texture tex) {
		this.setTexture(tex);
	}
	
	/**
	 * Check whether the bounding box of this Sprite collide
	 * with the bounding box of another Sprite
	 */
	bool collideWith(const Sprite rhs) const {
		return this.collideWith(this.getBoundingBox());
	}
	
	/**
	 * Rvalue version
	 */
	bool collideWith(const FloatRect rect) const {
		return this.collideWith(rect);
	}
	
	/**
	 * Check whether the bounding box of this Sprite collide
	 * with the given Rect
	 */
	bool collideWith(ref const FloatRect rect) const {
		return this.getBoundingBox().intersects(rect);
	}
	
final:
	
	void setTextureRect(ref const ShortRect texView) {
		this._texView = texView;
		
		this._boundingBox.setSize(texView.width, texView.height);
		this._clipRect.setSize(texView.width, texView.height);
	}
	
	void setTextureRect(const ShortRect texView) {
		this.setTextureRect(texView);
	}
	
	bool hasTextureRect() const {
		return !this._texView.isEmpty();
	}
	
	void resetTextureRect() in {
		assert(this._tex !is null);
	} body {
		this._texView.collapse();
		
		this._boundingBox.setSize(this._tex.width, this._tex.height);
		this._clipRect.setSize(this._tex.width, this._tex.height);
	}
	
	ref const(ShortRect) getTextureRect() const pure nothrow {
		return this._texView;
	}
	
	/**
	 * Returns the clip rect, the area which will be drawn on the screen.
	 */
	ref const(FloatRect) getBoundingBox() const pure nothrow {
		return this._boundingBox;
	}
	
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
		
		this._boundingBox.setSize(tex.width, tex.height);
		this._clipRect.setSize(tex.width, tex.height);
	}
	
	/**
	 * Returns the current Texture or null if there is none.
	 */
	ref const(Texture) getTexture() const {
		return this._tex;
	}
}