module Dgame.Graphics.Transform;

private {
	debug import std.stdio;
	
	import derelict.opengl3.gl;
	
	import Dgame.Graphics.Transformable;
	import Dgame.Window.Window;
	import Dgame.Math.Rect;
}

final class Transform : Transformable {
private:
	ShortRect _view;
	
	int[2] _winSize;
	bool _isActive;
	
public:
	this() {
		this.update();
		
		this._isActive = true;
	}
	
	this(ref const ShortRect view) {
		this();
		
		this._view = view;
	}
	
	this(const ShortRect view) {
		this(view);
	}
	
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
	
	void applyTranslation() const {
		super._applyTranslation();
	}
	
	void update() {
		int[4] viewport;
		glGetIntegerv(GL_VIEWPORT, &viewport[0]);
		
		this._winSize[] = viewport[2 .. 4];
	}
	
	void activate(bool active) {
		this._isActive = active;
	}
	
	bool isActive() const pure nothrow {
		return this._isActive;
	}
	
	inout(ShortRect*) fetchView() inout {
		return &this._view;
	}
	
	void setView(short x, short y, short w, short h) {
		this._view.set(x, y, w, h);
	}
	
	void setView(ref const ShortRect view) {
		this._view = view;
	}
	
	void setView(const ShortRect view) {
		this.setView(view);
	}
	
	void resetView() {
		this._view.collapse();
	}
}