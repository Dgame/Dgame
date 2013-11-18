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

	byte _speed = 1;
	byte _swap = 1;
	byte _update = 0;

	static immutable ubyte Update = 10;

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
	this(Texture tex, ref const ShortRect viewport) {
		super(tex, viewport);
	}

	/**
	* CTor
	* 
	* Rvalue version
	*/
	this(Texture tex, const ShortRect viewport) {
		this(tex, viewport);
	}

	/**
	* Returns if the Unit is moving.
	* This is proven with a check if speed is > 0f.
	*/
	bool isMoving() const pure nothrow {
		return this._speed != 0f;
	}

	/**
	* Stop the Unit.
	* Reset the viewport and the direction
	*/
	void stop() {
		super.resetTextureRect();

		this.resetDirection();
	}

	/**
	* Set a new swap value (starting value is 1)
	* The swap value affect how fast the Spritesheet pictures are swapped.
	* The Update value is 10 and every frame the current swap/update counter is increased by the swap value.
	* If Update (10) is reached, the next picture comes.
	*/
	void setSwap(byte swap) {
		this._swap = swap;
	}

	/**
	* Returns the current swap value (starting value is 1)
	*/
	byte getSwap() const pure nothrow {
		return this._swap;
	}

	/**
	* Set a new speed
	*/
	void setSpeed(byte speed) {
		this._speed = speed;
	}

	/**
	* Returns the current speed (starting value is 1)
	*/
	byte getSpeed() const pure nothrow {
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
	* Set the direction to 0|0
	*/
	void resetDirection() {
		this._direction.set(0, 0);
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

	@property {
		/**
		* Returns only the x coordinate of the current direction
		*/
		float dirX() const pure nothrow {
			return this._direction.x;
		}

		/**
		* Returns only the y coordinate of the current direction
		*/
		float dirY() const pure nothrow {
			return this._direction.y;
		}

		/**
		* Set only the x coordinate of the current direction
		*/
		void dirX(float dx) {
			this._direction.x = dx;
		}

		/**
		* Set only the y coordinate of the current direction
		*/
		void dirY(float dy) {
			this._direction.y = dy;
		}
	}

	/**
	* Slide/Move the Unit
	* Every time this method is called the current speed is added to an internal update property.
	* If this property reaches 10 or more, the direction is added to the current position 
	* and the slideViewport method from Spritesheet ist called.
	* Also the update property is decreased about 10.
	*/
	void slide() {
		if (this._speed == 0 || this._swap == 0)
			return;

		this._update += this._swap;

		if (this._update < Update)
			return;

		this._update -= Update;

		super.slideTextureRect();

		if (this._speed == 1)
			super.move(this._direction);
		else {
			const Vector2f mulDirection = this._direction * this._speed;
			super.move(mulDirection);
		}
	}
}