module Dgame.Graphic.Spritesheet;

private:

import Dgame.Graphic.Texture;
import Dgame.Graphic.Sprite;

import Dgame.Math.Rect;

import Dgame.System.StopWatch;

public:

class Spritesheet : Sprite {
protected:
    uint _lastUpdate = 0;
    uint _execCount = 0;

public:
    uint timeout = 0;
    int numOfExecutions = -1;

final:
    @nogc
    this(ref Texture tex) pure nothrow {
        super(tex);
    }

    @nogc
    this()(ref Texture tex, auto ref Rect texRect) pure nothrow {
        this(tex);

        super.setTextureRect(texRect);
    }

    @property
    @nogc
    uint lastUpdate() const pure nothrow {
        return _lastUpdate;
    }

    @property
    @nogc
    uint executionCounter() const pure nothrow {
        return _execCount;
    }

    @nogc
    void moveTextureRect(int x, int y) pure nothrow {
        _texRect.move(x, y);
        _updateVertices();
    }

    @nogc
    void slideTextureRect() nothrow {
        if (this.numOfExecutions >= 0 && _execCount >= this.numOfExecutions)
            return;

        if ((_lastUpdate + this.timeout) > StopWatch.getTicks())
            return;

        _lastUpdate = StopWatch.getTicks();

        if ((_texRect.x + _texRect.width) < _texture.width)
            _texRect.x += _texRect.width;
        else {
            _texRect.x = 0;

            if ((_texRect.y + _texRect.height) < _texture.height)
                _texRect.y += _texRect.height;
            else {
                _texRect.y = 0;
                _execCount++;
            }
        }

        _updateVertices();
    }
}