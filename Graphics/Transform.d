module Dgame.Graphics.Transform;

private {
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
	bool _viewActive = true;
	int[2] _winSize;
	
public:
	/**
	 * CTor
	 */
	this() {
		this.updateWindowSize();
	}
	
	/**
	 * CTor
	 */
	this(ref const ShortRect view) {
		this();
		
		this._view = view;
	}
	
	/**
	 * Rvalue version
	 */
	this(const ShortRect view) {
		this(view);
	}
	
	/**
	 * Apply the viewport. The view is recalulcated by the given View Rectangle.
	 */
	void applyViewport() const {
		if (this._viewActive && !this._view.isEmpty()) {
			if (!glIsEnabled(GL_SCISSOR_TEST))
				glEnable(GL_SCISSOR_TEST);
			
			const int vx = this._view.x + cast(int) super.X;
			const int vy = this._view.y + this._view.height + cast(int) super.Y;
			
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
	void updateWindowSize() {
		int[4] viewport;
		glGetIntegerv(GL_VIEWPORT, &viewport[0]);
		
		this._winSize[] = viewport[2 .. 4];
	}
	
	/**
	 * Activate/Deactivate the usage of the viewport.
	 */
	void activateView(bool vActive) {
		this._viewActive = vActive;
	}
	
	/**
	 * Returns, if the viewport usage is activated or not.
	 */
	bool isViewActive() const pure nothrow {
		return this._viewActive;
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

	/**
	 * Adjust the viewport.
	 * The position is shifted about <code>view.x * -1</code> and <code>view.y - 1</code>
	 * so that the left upper corner of the current view is in the left upper corner of the Window.
	 */
	void adjustView() {
		super.setPosition(this._view.x * -1, this._view.y * -1);
	}
}