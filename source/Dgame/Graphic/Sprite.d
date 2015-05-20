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
module Dgame.Graphic.Sprite;

private:

import Dgame.Math.Rect;
import Dgame.Math.Vector2;
import Dgame.Math.Vertex;
import Dgame.Math.Geometry;

import Dgame.Graphic.Drawable;
import Dgame.Graphic.Transformable;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Color;

public:

/**
 * Sprite represents a drawable object and maintains a Texture
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
class Sprite : Transformable, Drawable {
protected:
    Texture* _texture;
    Rect _texRect;
    Vertex[4] _vertices;

    @nogc
    override void draw(ref const Window wnd) nothrow {
        wnd.draw(Geometry.TriangleStrip, super.getMatrix(), _texture, _vertices[]);
    }

    @nogc
    final void _updateVertices() pure nothrow {
        immutable float tx = float(_texRect.x) / _texture.width;
        immutable float ty = float(_texRect.y) / _texture.height;
        immutable float tw = float(_texRect.width) / _texture.width;
        immutable float th = float(_texRect.height) / _texture.height;

        immutable float tx_tw = tx + tw;
        immutable float ty_th = ty + th;

        _vertices[0].position = Vector2f(0, 0);
        _vertices[0].texCoord = Vector2f(tx, ty);

        _vertices[1].position = Vector2f(_texRect.width, 0);
        _vertices[1].texCoord = Vector2f(tx_tw, ty);

        _vertices[2].position = Vector2f(0, _texRect.height);
        _vertices[2].texCoord = Vector2f(tx, ty_th);

        _vertices[3].position = Vector2f(_texRect.width, _texRect.height);
        _vertices[3].texCoord = Vector2f(tx_tw, ty_th);
    }

    @nogc
    final void _adjustTextureRect() pure nothrow {
        _texRect.x = 0;
        _texRect.y = 0;
        _texRect.width = _texture.width;
        _texRect.height = _texture.height;
    }

public:
final:
    /**
     * CTor
     */
    @nogc
    this(ref Texture tex) pure nothrow {
        _texture = &tex;

        _adjustTextureRect();
        _updateVertices();

        this.setColor(Color4b.White);
    }

    /**
     * CTor
     */
    @nogc
    this(ref Texture tex, const Vector2f pos) pure nothrow {
        this(tex);

        super.setPosition(pos);
    }

    /**
     * Reset the Texture
     */
    @nogc
    void setTexture(ref Texture tex) pure nothrow {
        _texture = &tex;

        this.setColor(Color4b.White);

        _adjustTextureRect();
        _updateVertices();
    }

    /**
     * Returns a pointer to the current Texture
     */
    @nogc
    inout(Texture*) getTexture() inout pure nothrow {
        return _texture;
    }

    /**
     * Set a Color for the Sprite which is painted over the displayed Texture.
     */
    @nogc
    void setColor(const Color4b col) pure nothrow {
        foreach (ref Vertex v; _vertices) {
            v.color = Color4f(col);
        }
    }

    /**
     * Set the Texture Rect. With this you can define a specific view of the Texture,
     * so that only this specific view will be drawn.
     */
    @nogc
    void setTextureRect(const Rect texRect) pure nothrow {
        _texRect = texRect;
        _updateVertices();
    }

    /**
     * Returns the current Texture Rect
     */
    @nogc
    ref const(Rect) getTextureRect() const pure nothrow {
        return _texRect;
    }

    /**
     * Returns the Clip Rect.
     * The Sprite will notice if a Texture Rect is used or not and will therefore adapt the size of the view automatically
     */
    @nogc
    Rect getClipRect() const pure nothrow {
        uint w = 0, h = 0;
        if (_texRect.isEmpty()) {
            w = _texture.width;
            h = _texture.height;
        } else {
            w = _texRect.width;
            h = _texRect.height;
        }

        return Rect(cast(int) super.x, cast(int) super.y, w, h);
    }
}