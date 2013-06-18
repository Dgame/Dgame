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
 * With this additional values the Unit can move with a specific speed in a specific direction
 * with a optional animation (the spritesheet).
 * 
 * Author: rschuett
 */
class Unit : Spritesheet {
protected:
	Vector2f _direction;
	
	float _speed  = 1f;
	float _update = 0f;
	
	bool _move = true;
	
	enum Update = 10f;
	
public:
final:
	
	/**
	 * CTor
	 */
	this(Texture tex) {
		super(tex);
	}
	
	/**
	 * CTor
	 */
	this(Texture tex, ref const FloatRect viewport) {
		super(tex, viewport);
	}
	
	/**
	 * CTor
	 * 
	 * Rvalue version
	 */
	this(Texture tex, const FloatRect viewport) {
		this(tex, viewport);
	}
	
	/**
	 * Returns if the Unit moves.
	 */
	bool isMoving() const pure nothrow {
		return this._move;
	}
	
	/**
	 * Stop movement of the Unit.
	 * Reset the viewport
	 */
	void stop() {
		this._move = false;
		
		super.resetViewport();
	}
	
	/**
	 * Continue movement
	 */
	void resume() {
		this._move = true;
	}
	
	/**
	 * Set a new speed
	 */
	void setSpeed(float speed) {
		this._speed = speed;
	}
	
	/**
	 * Returns the current speed (starting value is 1f)
	 */
	float getSpeed() const pure nothrow {
		return this._speed;
	}
	
	/**
	 * Set a new direction
	 * The direction is the amount of pixels which is added to the current position.
	 * 
	 * See: slide
	 */
	void setDirection(float x, float y) {
		this._direction.set(x, y);
	}
	
	/**
	 * Set a new direction.
	 * The direction is the amount of pixels which is added to the current position.
	 * 
	 * See: slide
	 */
	void setDirection(ref const Vector2f vec) {
		this.setDirection(vec.x, vec.y);
	}
	
	/**
	 * Reverse the direction
	 */
	void reverseDirection() {
		this._direction.negate();
	}
	
	/**
	 * Returns the current directon
	 */
	ref const(Vector2f) getDirection() const pure nothrow {
		return this._direction;
	}
	
	/**
	 * Returns only the x coordinate of the current direction
	 */
	@property
	float dirX() const pure nothrow {
		return this._direction.x;
	}
	
	/**
	 * Returns only the y coordinate of the current direction
	 */
	@property
	float dirY() const pure nothrow {
		return this._direction.y;
	}
	
	/**
	 * Set only the x coordinate of the current direction
	 */
	@property
	void dirX(float dx) {
		this._direction.x = dx;
	}
	
	/**
	 * Set only the y coordinate of the current direction
	 */
	@property
	void dirY(float dy) {
		this._direction.y = dy;
	}
	
	/**
	 * Slide/Move the Unit
	 * Every time this method is called the current speed is added to an internal update property.
	 * If this property reaches 10f or more, the direction is added to the current position 
	 * and the slideViewport method from Spritesheet ist called.
	 * Also the update property is decreased about 10f.
	 */
	void slide() {
		if (!this._move || this._speed <= 0f)
			return;
		
		this._update += this._speed;
		
		if (this._update < Update)
			return;
		
		this._update -= Update;
		
		super.slideViewport();
		super.move(this._direction);
	}
}