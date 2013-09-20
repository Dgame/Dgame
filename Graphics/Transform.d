module Dgame.Graphics.Transform;

private {
	debug import std.stdio;
	
	import derelict.opengl3.gl;
	
	import Dgame.Graphics.Transformable;
	import Dgame.Window.Window;
	import Dgame.Math.Rect;
}

/**
 * An object for the transformation of e.g. TileMaps.
 *
 * Author: rschuett
 */
final class Transform : Transformable {
private:
	ShortRect _view;
	
	int[2] _winSize;
	bool _isActive;
	
public:
	/**
	 * CTor
	 */
	this() {
		this.update();
		
		this._isActive = true;
	}
	
	/**
	 * CTor
	 */
	this(ref const ShortRect view) {
		this();
		
		this._view = view;
	}
	
	/**
	 * CTor
	 */
	this(const ShortRect view) {
		this(view);
	}
	
	/**
	 * Apply the viewport. The view is recalulcated by the given View Rectangle.
	 */
	void applyViewport() const {
		const bool noView = !this._isActive || this._view.isEmpty();
		if (!noView) {
			if (!glIsEnabled(GL_SCISSOR_TEST))
				glEnable(GL_SCISSOR_TEST);
			
			const int vx = this._view.x + cast(short)(super._position.x);
			const int vy = this._view.y + this._view.height + cast(short)(super._position.y);
			
			glScissor(vx, this._winSize[1] - vy, this._view.width, this._view.height);
		}
	}
	
	/**
	 * Apply the translation.
	 */
	void applyTranslation() const {
		super._applyTranslation();
	}
	
	/**
	 * Update should be called if the window is resized.
	 */
	void update() {
		int[4] viewport;
		glGetIntegerv(GL_VIEWPORT, &viewport[0]);
		
		this._winSize[] = viewport[2 .. 4];
	}
	
	/**
	 * Activate/Deactivate the usage of the viewport.
	 */
	void activate(bool active) {
		this._isActive = active;
	}
	
	/**
	 * Returns, if the viewport usage is activated or not.
	 */
	bool isActive() const pure nothrow {
		return this._isActive;
	}
	
	/**
	 * Fetch the viewport pointer so that it can modified outside.
	 */
	inout(ShortRect*) fetchView() inout {
		return &this._view;
	}
	
	/**
	 * Set a new view.
	 */
	void setView(short x, short y, short w, short h) {
		this._view.set(x, y, w, h);
	}
	
	/**
	 * Set a new view.
	 */
	void setView(ref const ShortRect view) {
		this._view = view;
	}
	
	/**
	 * Rvalue version.
	 */
	void setView(const ShortRect view) {
		this.setView(view);
	}
	
	/**
	 * Reset the viewport.
	 */
	void resetView() {
		this._view.collapse();
	}
}