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
module Dgame.Graphic.Spritesheet;

private:

import Dgame.Graphic.Texture;
import Dgame.Graphic.Sprite;

import Dgame.Math.Vector2;
import Dgame.Math.Rect;

import Dgame.System.StopWatch;

public:

/**
 * SpriteSheet extends Sprite and act like a Texture Atlas.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
class Spritesheet : Sprite {
protected:
    uint _lastUpdate = 0;
    uint _execCount = 0;

public:
    /**
     * The timeout between the slides
     */
    uint timeout = 0;
    /**
     * The amount of executions of the <b>whole</b> slide
     * -1 or less means infinite sliding
     */
    int numOfExecutions = -1;

final:
    /**
     * CTor
     */
    @nogc
    this(ref Texture tex) pure nothrow {
        super(tex);
    }

    /**
     * CTor
     */
    @nogc
    this(ref Texture tex, const Rect texRect) pure nothrow {
        this(tex);

        super.setTextureRect(texRect);
    }

    /**
     * Returns the last update which means the last happened slide
     */
    @nogc
    uint lastUpdate() const pure nothrow {
        return _lastUpdate;
    }

    /**
     * Returns the current execution count
     */
    @nogc
    uint executionCounter() const pure nothrow {
        return _execCount;
    }

    /**
     * Returns if the execution is completed
     */
    @nogc
    bool isCompleted() const pure nothrow {
        return this.numOfExecutions >= 0 && _execCount >= this.numOfExecutions;
    }

    /**
     * Slide / move the current view of the Texture,
     * so that the next view of the Texture will be drawn.
     * This happens by moving the Texture Rect.
     *
     * Note: If you reached the end of the Texture, the procedure starts from scratch.
     */
    @nogc
    void slideTextureRect() nothrow {
        if (this.isCompleted())
            return;

        if ((_lastUpdate + this.timeout) > StopWatch.getTicks())
            return;

        _lastUpdate = StopWatch.getTicks();

        _texRect.x += _texRect.width;
        if (_texRect.x >= _texture.width) {
            _texRect.x = 0;
            _texRect.y += _texRect.height;
            if (_texRect.y >= _texture.height) {
                _texRect.y = 0;
                _execCount++;
            }
        }

        // show the last frame if the execution is completed
        if (this.isCompleted()) {
            _texRect.x = _texture.width - _texRect.width;
            _texRect.y = _texture.height - _texRect.height;
        }

        _updateVertices();
    }

    /**
     * Selects a specific frame and adapts the position of the texture rect.
     * The index starts at 0 and line by line.
     *
     * Note: The size of your Texture and the size of your Texture-Rect should be divisible without a rest.
     */
    @nogc
    void selectFrame(ubyte index) pure nothrow {
        immutable uint nof = this.numOfFrames();
        if (index >= nof)
            index = index % nof;

        int sum = index * _texRect.width;
     
        int x = 0, y = 0;
        while (sum >= _texRect.width) {
            x += _texRect.width;
            if (x >= _texture.width) {
                x = 0;
                y += _texRect.height;
            }
     
            sum -= _texRect.width;
        }

        _texRect.x = x;
        _texRect.y = y;

        _updateVertices();
    }

    /**
     * Returns how many frames this Spritesheet has.
     * The width / height of the current Texture is divided through
     * the corresponding width / height of the current Texture-Rect and both values are being multiplied.
     */
    @nogc
    uint numOfFrames() const pure nothrow {
        return (_texture.width / _texRect.width) * (_texture.height / _texRect.height);
    }
}