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
module Dgame.Graphics.Transform;

private {
	import derelict.opengl3.gl;
	
	import Dgame.Window.Window;
	import Dgame.Graphics.Transformable;
	import Dgame.Math.Rect;
}

/**
 * Formable for attaching to Transform
 *
 * Author: rschuett
 */
interface Formable {
	/// Returns the Area size
	int[2] getAreaSize() const pure nothrow;
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
	
	Formable _child;
	
protected:
	override int[2] _getAreaSize() const pure nothrow {
		if (this._child !is null)
			return this._child.getAreaSize();
		
		return super._getAreaSize();
	}
	
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
	 * Attach a Formable to observe it.
	 */
	void attach(Formable f) {
		this._child = f;
	}
	
	/**
	 * Apply the viewport. The view is recalculated by the given View Rectangle.
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
	 * Update should be called if the window is resized.
	 */
	void updateWindowSize() {
		int[4] viewport = void;
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