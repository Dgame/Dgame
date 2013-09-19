module Dgame.Graphics.Moveable;

private {
	import derelict.opengl3.gl;
	
	import Dgame.Math.Vector2;
}

abstract class Moveable {
protected:
	Vector2f _position;
	
protected:
	void _positionMoved(float dx, float dy) {
		
	}
	
	void _positionReset(float nx, float ny) {
		
	}
	
	void _applyTranslation() const {
		glTranslatef(this._position.x, this._position.y, 0f);
	}
	
public:
	void resetTranslation() {
		this.setPosition(0, 0);
	}
	
final:
	void setPosition(ref const Vector2f vec) {
		this._position = vec;
		
		this._positionReset(vec.x, vec.y);
	}
	
	void setPosition(float x, float y) {
		this._position.set(x, y);
		
		this._positionReset(x, y);
	}
	
	void setPosition(float[2] pos) {
		this.setPosition(pos[0], pos[1]);
	}
	
	ref const(Vector2f) getPosition() const pure nothrow {
		return this._position;
	}
	
	void move(ref const Vector2f vec) {
		this._position += vec;
		
		this._positionMoved(vec.x, vec.y);
	}
	
	void move(float x, float y) {
		this._position.move(x, y);
		
		this._positionMoved(x, y);
	}
	
	void move(float[2] pos) {
		this.move(pos[0], pos[1]);
	}
	
@property:
	float X() const pure nothrow {
		return this._position.x;
	}
	
	float Y() const pure nothrow {
		return this._position.y;
	}
	
	void X(float x) {
		this._position.x = x;
		
		this._positionReset(x, this._position.y);
	}
	
	void Y(float y) {
		this._position.y = y;
		
		this._positionReset(this._position.x, y);
	}
}