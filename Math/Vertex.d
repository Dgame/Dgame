module Dgame.Math.Vertex;

private:

import Dgame.Graphic.Color;
import Dgame.Math.Vector2;

public:

struct Vertex {
    Vector2f position;
    Vector2f texCoord;
    Color4f color = Color4f.Black;

    @nogc
    this()(auto ref const Vector2f pos, auto ref const Vector2f coords, auto ref const Color4f col) pure nothrow {
        this.position = pos;
        this.texCoord = coords;
        this.color = col;
    }

    @nogc
    this()(auto ref const Vector2f pos, auto ref const Vector2f coords, auto ref const Color4b col) pure nothrow {
        this(pos, coords, Color4f(col));
    }

    @nogc
    this()(auto ref const Vector2f pos) pure nothrow {
        this.position = pos;
    }

    @nogc
    this(float x, float y) pure nothrow {
        this.position.x = x;
        this.position.y = y;
    }
}