module Dgame.Graphics.Spritesheet;

private {
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Sprite;
	import Dgame.Math.Rect;
}

/**
 * SpriteSheet extends Sprite and has, besides the texture, 
 * even a viewport and acts as a Texture Atlas.
 * With slideViewport the viewport slides over the current row of the texture atlas.
 * With setRow the current row can be changed (increased, decreased).
 *
 * Author: rschuett
 */
class Spritesheet : Sprite {
protected:
	FloatRect _viewport;
	
	ubyte _row = 0;
	
public:
	/**
	 * CTor
	 */
	this(Texture tex) {
		super(tex);
	}
	
	/**
	 * CTor
	 */
	this(Texture tex, ref const FloatRect viewport) {
		this(tex);
		
		this.setViewport(viewport);
	}
	
	/**
	 * CTor
	 * 
	 * Rvalue version
	 */
	this(Texture tex, const FloatRect viewport) {
		this(tex, viewport);
	}
	
	/**
	 * Set or replace the current viewport.
	 * This Viewport is also set for the Texture.
	 */
	final void setViewport(ref const FloatRect viewport) {
		assert(this._tex !is null, "No Texture.");
		
		super._tex.setViewport(viewport);
		this._viewport = viewport;
	}
	
	/**
	 * Rvalue version
	 */
	final void setViewport(const FloatRect viewport) {
		this.setViewport(viewport);
	}
	
	/**
	 * Get access to the current Viewport.
	 */
	final ref const(FloatRect) getViewport() const {
		return this._viewport;
	}
	
	/**
	 * Get mutable access to the current Viewport.
	 */
	final inout(FloatRect)* fetchViewport() inout {
		return &this._viewport;
	}
	
	/**
	 * Reset the Viewport.
	 */
	void resetViewport() {
		float x = this._viewport.x;
		float y = this._viewport.y;/// + (this._viewport.height * this._row);
		
		FloatRect* rect = super._tex.fetchViewport();
		rect.setPosition(x, y);
	}
	
	/**
	 * Returns the current row (starting value is 0)
	 */
	final ubyte getRow() const pure nothrow {
		return this._row;
	}
	
	/**
	 * Set a new row
	 */
	final void setRow(ubyte row) {
		this._row = row;
	}
	
	/**
	 * Slide/move the current Viewport of the Texture.
	 * So the next area of the Texture atlas will be drawn.
	 */
	void slideViewport() {
		assert(this._tex !is null, "No Texture.");
		
		float w = this._viewport.width;
		float h = this._viewport.height;
		
		FloatRect* rect = super._tex.fetchViewport();
		assert(rect !is null);
		
		rect.y = this._row * h;
		if (rect.y >= super._tex.height)
			rect.y = 0f;
		
		if ((rect.x + w) < super._tex.width)
			rect.move(w, 0f);
		else
			rect.x = 0f;
	}
}