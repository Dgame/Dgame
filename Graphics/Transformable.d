module Dgame.Graphics.Transformable;

private {
	debug import std.stdio;
	import std.math : isNaN;
	
	import derelict.opengl3.gl;
	
	import Dgame.Core.Math : fpEqual;
	import Dgame.Graphics.Moveable;
}

abstract class Transformable : Moveable {
protected:
	short _rotAngle;
	float _zoom;
	
protected:
	override void _applyTranslation() const {
		super._applyTranslation();
		
		if (this._rotAngle != 0)
			glRotatef(this._rotAngle, 0f, 0f, 1f);
		
		if (!isNaN(this._zoom) && !fpEqual(this._zoom, 1f))
			glScalef(this._zoom, this._zoom, 0f);
	}
	
public:
	override void resetTranslation() {
		super.resetTranslation();
		
		this.setRotation(0);
		this.setScale(1);
	}
	
final:
	void setRotation(short rotAngle) {
		this._rotAngle = rotAngle;
		
		if (this._rotAngle > 360 || this._rotAngle < -360)
			this._rotAngle = 0;
	}
	
	void rotate(short rotAngle) {
		this._rotAngle += rotAngle;
	}
	
	short getRotation() const pure nothrow {
		return this._rotAngle;
	}
	
	void setScale(float zoom) {
		this._zoom = zoom;
	}
	
	void scale(float zoom) {
		if (isNaN(this._zoom))
			return this.setScale(zoom);
		
		this._zoom += zoom;
	}
	
	float getScale() const pure nothrow {
		return this._zoom;
	}
}