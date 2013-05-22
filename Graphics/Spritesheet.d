module Dgame.Graphics.Spritesheet;

private {
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Sprite;
	import Dgame.Math.Rect;
}

/**
* Sprite Sheet extends Sprite. 
* Sprite Sheet has, besides the texture, 
* even a viewport and acts as a Texture Atlas.
*
* Author: rschuett
*/
class Spritesheet : Sprite {
protected:
	FloatRect _viewport;

public:
	/**
	* CTor
	*/
	this() {
		super();
	}

	/**
	* CTor
	*/
	this(Texture tex) {
		super(tex);
	}

	/**
	* CTor
	*/
	this(Texture tex, const FloatRect viewport) {
		super(tex);

		this.setViewport(viewport);
	}

	/**
	* Set or replace the current viewport.
	* This Viewport is also set for the Texture.
	*/
	void setViewport(ref const FloatRect viewport) {
		assert(this._tex !is null, "No Texture.");

		super._tex.setViewport(viewport);
		this._viewport = viewport;
	}

	/**
	* Rvalue version
	*/
	void setViewport(const FloatRect viewport) {
		this.setViewport(viewport);
	}

	/**
	* Get mutable access to the current Viewport.
	*/
	inout(FloatRect)* fetchViewport() inout {
		return &this._viewport;
	}

	/**
	* Get const access of the current Viewport.
	*/
	ref const(FloatRect) getViewport() const pure nothrow {
		return this._viewport;
	}

	/**
	* Slides/moves the current Viewport of the Texture.
	* So the next area of the Texture atlas will be drawn.
	* With the optional parameter another Viewport as the current will be used.
	* Returns the coordinates and size of the new area as static array.
	*/
	float[4] slideViewport(FloatRect* viewport = null) {
		assert(this._tex !is null, "No Texture.");

		float w = viewport is null ? this._viewport.width : viewport.width;
		float h = viewport is null ? this._viewport.height : viewport.height;

		FloatRect* rect = super._tex.fetchViewport();

		if ((super._tex.getViewport().x + w) < super._tex.width) {
			rect.move(w, 0f);
		} else if ((super._tex.getViewport().y + h) < super._tex.height) {
			rect.x = 0;
			rect.move(0f, h);
		} else {
			rect.x = 0;
			rect.y = 0;
		}

		return [rect.x, rect.y, w, h];
	}
}