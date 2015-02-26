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
    Rect _clipRect;
    Vertex[4] _vertices;

    @nogc
    override void draw(ref const Window wnd) nothrow {
        wnd.draw(Geometry.TriangleStrip, super.getMatrix(), _texture, _vertices.ptr, 4);
    }

    @nogc
    void _updateVertices() pure nothrow {
        float tx = 0, ty = 0, tw = 1, th = 1;

        if (!_clipRect.isEmpty()) {
            tx = float(_clipRect.x) / _texture.width;
            ty = float(_clipRect.y) / _texture.height;
            tw = float(_clipRect.width) / _texture.width;
            th = float(_clipRect.height) / _texture.height;
        }

        immutable float tx_tw = tx + tw;
        immutable float ty_th = ty + th;

        _vertices[0].position = Vector2f(0, 0);
        _vertices[0].texCoord = Vector2f(tx, ty);

        _vertices[1].position = Vector2f(_clipRect.width, 0);
        _vertices[1].texCoord = Vector2f(tx_tw, ty);

        _vertices[2].position = Vector2f(0, _clipRect.height);
        _vertices[2].texCoord = Vector2f(tx, ty_th);

        _vertices[3].position = Vector2f(_clipRect.width, _clipRect.height);
        _vertices[3].texCoord = Vector2f(tx_tw, ty_th);
    }

    @nogc
    void _adjustClipRect() pure nothrow {
        _clipRect.x = 0;
        _clipRect.y = 0;
        _clipRect.width = _texture.width;
        _clipRect.height = _texture.height;
    }

public:
final:
    @nogc
    this(ref Texture tex) pure nothrow {
        _texture = &tex;

        _adjustClipRect();
        _updateVertices();

        this.setColor(Color4b.White);
    }

    @nogc
    void setTexture(ref Texture tex) pure nothrow {
        _texture = &tex;

        this.setColor(Color4b.White);

        _adjustClipRect();
        _updateVertices();
    }

    @nogc
    const(Texture*) getTexture() const pure nothrow {
        return _texture;
    }

    @nogc
    void setColor()(auto ref const Color4b col) pure nothrow {
        foreach (ref Vertex v; _vertices) {
            v.color = Color4f(col);
        }
    }

    @nogc
    void setClipRect()(auto ref const Rect clipRect) {
        _clipRect = clipRect;
        _updateVertices();
    }

    @nogc
    ref const(Rect) getClipRect() const pure nothrow {
        return _clipRect;
    }
}