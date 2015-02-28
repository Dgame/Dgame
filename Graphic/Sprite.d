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

class Sprite : Transformable, Drawable {
protected:
    Texture* _texture;
    Rect _texRect;
    Vertex[4] _vertices;

    @nogc
    override void draw(ref const Window wnd) nothrow {
        wnd.draw(Geometry.TriangleStrip, super.getMatrix(), _texture, _vertices.ptr, 4);
    }

    @nogc
    final void _updateVertices() pure nothrow {
        float tx = 0, ty = 0, tw = 1, th = 1;

        if (!_texRect.isEmpty()) {
            tx = float(_texRect.x) / _texture.width;
            ty = float(_texRect.y) / _texture.height;
            tw = float(_texRect.width) / _texture.width;
            th = float(_texRect.height) / _texture.height;
        }

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
    @nogc
    this(ref Texture tex) pure nothrow {
        _texture = &tex;

        _adjustTextureRect();
        _updateVertices();

        this.setColor(Color4b.White);
    }

    @nogc
    void setTexture(ref Texture tex) pure nothrow {
        _texture = &tex;

        this.setColor(Color4b.White);

        _adjustTextureRect();
        _updateVertices();
    }

    @nogc
    inout(Texture*) getTexture() inout pure nothrow {
        return _texture;
    }

    @nogc
    void setColor()(auto ref const Color4b col) pure nothrow {
        foreach (ref Vertex v; _vertices) {
            v.color = Color4f(col);
        }
    }

    @nogc
    void setTextureRect()(auto ref const Rect texRect) {
        _texRect = texRect;
        _updateVertices();
    }

    @nogc
    ref const(Rect) getTextureRect() const pure nothrow {
        return _texRect;
    }

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

        return Rect(cast(int) _position.x, cast(int) _position.y, w, h);
    }
}