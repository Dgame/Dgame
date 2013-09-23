module Dgame.Graphics.Drawable;

/**
 * Drawable is the base class for objects which can be drawn.
 * 
 * Author: rschuett
 */
interface Drawable {
protected:
	/**
	 * Render method
	 */
	void _render();
	
public: // TODO: package?
	final void render() {
		this._render();
	}
}