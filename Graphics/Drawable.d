module Dgame.Graphics.Drawable;

package import Dgame.Window.Window;

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
	void _render(const Window);
	
public: // TODO: package?
	final void render(const Window wnd) {
		this._render(wnd);
	}
}