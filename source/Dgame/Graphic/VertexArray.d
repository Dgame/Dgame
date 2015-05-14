module Dgame.Graphic.VertexArray;

private:

import Dgame.Graphic.Drawable;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Color;

import Dgame.Math.Vertex;
import Dgame.Math.Vector2;
import Dgame.Math.Rect;
import Dgame.Math.Geometry;

import Dgame.Window.Window;

public:

class VertexArray : Drawable {
private:
    Vertex[] _vertices;
    Texture* _texture;

protected:
    @nogc
    override void draw(ref const Window wnd) nothrow {
        wnd.draw(Geometry.TriangleStrip, _texture, _vertices);
    }

public:
final:
    /**
     * CTor
     */
    @nogc
    this(ref Texture texture) pure nothrow {
        this.setTexture(texture);
    }

    /**
     * Set or reset a Texture
     */
    @nogc
    void setTexture(ref Texture texture) pure nothrow {
        _texture = &texture;
    }

    /**
     * Returns the current texture or null
     */
    @nogc
    inout(Texture)* getTexture() inout pure nothrow {
        return _texture;
    }

    /**
     * Clear all Vertices but preserve the storage and capacity
     */
    void clear() nothrow {
        _vertices.length = 0;
        _vertices.assumeSafeAppend();
    }

    /**
     * Appends four Vertices arounds the given position with the given texture coordinates
     */
    void append()(auto ref const Vector2f position) pure nothrow {
        this.append(position, Rect(0, 0, _texture.width, _texture.height));
    }

    /**
     * Appends four Vertices arounds the given position with the given texture coordinates
     */
    void append()(auto ref const Vector2f position, auto ref const Rect texRect) pure nothrow {
        immutable float tx = float(texRect.x) / _texture.width;
        immutable float ty = float(texRect.y) / _texture.height;
        immutable float tw = float(texRect.width) / _texture.width;
        immutable float th = float(texRect.height) / _texture.height;

        immutable float tx_tw = tx + tw;
        immutable float ty_th = ty + th;
        immutable float cx_tw = position.x + texRect.width;
        immutable float cy_th = position.y + texRect.height;

        _vertices.reserve(4);

        _vertices ~= Vertex(
            position,
            Vector2f(tx, ty),
            Color4f.White
        );

        _vertices ~= Vertex(
            Vector2f(cx_tw, position.y),
            Vector2f(tx_tw, ty),
            Color4f.White
        );

        _vertices ~= Vertex(
            Vector2f(position.x, cy_th),
            Vector2f(tx, ty_th),
            Color4f.White
        );

        _vertices ~= Vertex(
            Vector2f(cx_tw, cy_th),
            Vector2f(tx_tw, ty_th),
            Color4f.White
        );
    }

    /**
     * Stores a Vertex
     */
    void append()(auto ref const Vertex vertex) pure nothrow {
        _vertices ~= vertex;
    }

    /**
     * Returns all Vertices
     */
    @nogc
    ref inout(Vertex) opIndex(size_t index) inout pure nothrow {
        assert(index < _vertices.length);
        return _vertices[index];
    }

    /**
     * Returns the current amount of stored Vertices
     */
    @nogc
    @property
    size_t length() const pure nothrow {
        return _vertices.length;
    }
}