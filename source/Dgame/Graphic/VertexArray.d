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

/**
 * A VertrexArray is a simple way to handle a performant textured shape.
 * It provides a simple API and maintains the necessary properties.
 * It is similar to a trimmed-down version of Shape, but does not contain possible unnecessary content.
 *
 * See: Shape, Vertex
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
class VertexArray : Drawable {
private:
    Vertex[] _vertices;
    Texture* _texture;

protected:
    @nogc
    override void draw(ref const Window wnd) nothrow {
        wnd.draw(this.geometry, _texture, _vertices);
    }

public:
    Geometry geometry;

final:
    /**
     * CTor
     */
    @nogc
    this(Geometry geometry, ref Texture texture) pure nothrow {
        this.geometry = geometry;
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
     * Reserve (additional) space for the internal Vertex array
     */
    void reserve(size_t size) pure nothrow {
        _vertices.reserve(size);
    }

    /**
     * Clear all Vertices but preserve the storage and capacity
     */
    void clear() nothrow {
        _vertices.length = 0;
        _vertices.assumeSafeAppend();
    }

    /**
     * Stores a Vertex
     */
    void append(ref const Vertex vertex) pure nothrow {
        _vertices ~= vertex;
    }

    /**
     * Stores a Vertex
     */
    void append(const Vector2f vec) pure nothrow {
        _vertices ~= Vertex(vec);
    }

    /**
     * Append a whole Quad.
     * This method provides a simple way to add a quadratic texture-view.
     * And this as easily as if you would work with a Sprite.
     *
     * Note: This method only works for Geometry.Quads.
     */
    void appendQuad(const Vector2f position, const Rect texRect) pure nothrow {
        assert(this.geometry == Geometry.Quads, "This method supports only Geometry.Quads");

        immutable float tx = float(texRect.x) / _texture.width;
        immutable float ty = float(texRect.y) / _texture.height;
        immutable float tw = float(texRect.width) / _texture.width;
        immutable float th = float(texRect.height) / _texture.height;

        immutable float tx_tw = tx + tw;
        immutable float ty_th = ty + th;
        immutable float cx_tw = position.x + texRect.width;
        immutable float cy_th = position.y + texRect.height;

        if ((_vertices.capacity - _vertices.length) < 4)
            _vertices.reserve(4);

        _vertices ~= Vertex(
            position,
            Vector2f(tx, ty),
            Color4b.White
        );

        _vertices ~= Vertex(
            Vector2f(cx_tw, position.y),
            Vector2f(tx_tw, ty),
            Color4b.White
        );

        _vertices ~= Vertex(
            Vector2f(cx_tw, cy_th),
            Vector2f(tx_tw, ty_th),
            Color4b.White
        );

        _vertices ~= Vertex(
            Vector2f(position.x, cy_th),
            Vector2f(tx, ty_th),
            Color4b.White
        );
    }

    /**
     * Returns all Vertices
     */
    @nogc
    inout(Vertex[]) getVertices() inout pure nothrow {
        return _vertices;
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