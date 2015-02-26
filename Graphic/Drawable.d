module Dgame.Graphic.Drawable;

package import Dgame.Window.Window;

interface Drawable {
	@nogc
	void draw(ref const Window) nothrow;
}