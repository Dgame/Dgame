module Dgame.Graphics.Sprite;

private {
	debug import std.stdio;
	
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Texture;
	import Dgame.Math.Rect;
}

/**
 * Sprite represents a drawable object and maintains a texture and his position.
 *
 * Author: rschuett
 */
class Sprite : Drawable {
protected:
	Texture _tex;
	ShortRect _clip;
	
protected:
	override void _positionChanged(float dx, float dy) {
		this._clip.move(dx, dy);
	}
	
	override void _render() {
		if (this._tex is null) {
			debug writeln("Texture couldn't rendered, because it's null.");
			return;
		}
		
		float w = this._tex.hasViewport() ? this._tex.getViewport().width : this._tex.width;
		float h = this._tex.hasViewport() ? this._tex.getViewport().height : this._tex.height;
		
		this._clip.setPosition(super._position);
		this._clip.setSize(w, h);
		
		this._tex._render(this._clip);
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
	 * Returns the clip rect, the area which will be drawn on the screen.
	 */
	final ref const(ShortRect) getClipRect() const pure nothrow {
		return this._clip;
	}
	
	/**
	 * Check if the current Sprite has already a Texture/Image.
	 * If not, nothing can be drawn.
	 * But it does not check if the current Texture is valid.
	 */
	final bool hasTexture() const pure nothrow {
		return this._tex !is null;
	}
	
	/**
	 * Set or replace the current Texture.
	 */
	void setTexture(Texture tex) in {
		assert(tex !is null, "Cannot set a null Texture.");
	} body {
		this._tex = tex;
	}
	
	/**
	 * Returns the current Texture or null if there is none.
	 */
	final ref const(Texture) getTexture() const {
		return this._tex;
	}
	
	/**
	 * Check whether the bounding box of this Sprite collide
	 * with the bounding box of another Sprite
	 */
	bool collideWith(const Sprite rhs) const {
		return this.collideWith(rhs.getClipRect());
	}
	
	/**
	 * Check whether the bounding box of this Sprite collide
	 * with the given Rect
	 */
	bool collideWith(ref const ShortRect rect) const {
		return this._clip.intersects(rect);
	}
}