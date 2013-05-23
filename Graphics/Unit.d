module Dgame.Graphics.Unit;

private {
	import Dgame.Graphics.Spritesheet;
	import Dgame.Graphics.Texture;
	import Dgame.Math.Vector2;
	import Dgame.Math.Rect;
}

/**
 * Unit extends Spritesheet and represent a Game unit, like a gaming piece.
 * It extends SpriteSheet of a speed and a direction value, which can be manipulated.
 * With this additional values the Uni can move with a specific speed in a specific direction
 * with a optional animation (the spritesheet).
 * 
 * Author: rschuett
 */
class Unit : Spritesheet {
protected:
	Vector2f _direction;
	
	float _speed  = 0.1f;
	float _update = 0f;
	
	enum Update = 1f;
	
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
	this(Texture tex, const FloatRect viewport) {
		super(tex, viewport);
	}
	
	/**
	 * Set a new speed
	 */
	void setSpeed(float speed) {
		this._speed = speed;
	}
	
	/**
	 * Returns the current speed (starting value is 0.1f)
	 */
	float getSpeed() const pure nothrow {
		return this._speed;
	}
	
	/**
	 * Set a new direction
	 */
	void setDirection(float x, float y) {
		this._direction.set(x, y);
	}
	
	/**
	 * Set a new direction
	 */
	void setDirection(ref const Vector2f vec) {
		this.setDirection(vec.x, vec.y);
	}
	
	/**
	 * Returns the current directon
	 */
	ref const(Vector2f) getDirection() const pure nothrow {
		return this._direction;
	}
	
	/**
	 * Slide/Move the Unit
	 */
	void slide() {
		if (this._speed <= 0f)
			return;
		
		this._update += this._speed;
		
		if (this._update < Update)
			return;
		
		float w = this._viewport.width;
		float h = this._viewport.height;
		
		while (this._update >= Update) {
			this._update -= Update;
			
			super.slideViewport();
			super.move(this._direction);
		}
	}
}