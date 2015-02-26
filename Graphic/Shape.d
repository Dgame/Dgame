module Dgame.Graphic.Shape;

private:

static import std.math;

import derelict.opengl3.gl;

import Dgame.Graphic.Drawable;
import Dgame.Graphic.Transformable;
import Dgame.Graphic.Texture;

import Dgame.Math.Vertex;
import Dgame.Math.Vector2;
import Dgame.Math.Rect;
import Dgame.Graphic.Color;
public import Dgame.Math.Geometry;

public:

class Shape : Transformable, Drawable {
public:
    enum Fill : ubyte {
        Full,
        Point,
        Line
    }

private:
    Texture* _texture;
    Vertex[] _vertices;

protected:
    @nogc
    override void draw(ref const Window wnd) nothrow {
        if (this.lineWidth != 1)
            glLineWidth(this.lineWidth);

        if (this.useAntiAlias) {
            if (!glIsEnabled(GL_LINE_SMOOTH))
                glEnable(GL_LINE_SMOOTH);
            glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
        }
        
        final switch (this.fill) {
            case Fill.Full:
                glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            break;

            case Fill.Line:
                glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            break;

            case Fill.Point:
                glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
            break;
        }

        // prevent 64 bit bug, because *.length is size_t and therefore on 64 bit platforms ulong
        wnd.draw(this.geometry, super.getMatrix(), _texture, _vertices.ptr, cast(uint) _vertices.length);
    }

public:
    Geometry geometry;

    Fill fill = Fill.Full;
    bool useAntiAlias = false;
    ubyte lineWidth = 1;

final:
    @nogc
    this(Geometry geo) pure nothrow {
        this.geometry = geo;
    }

    this(Geometry geo, Vertex[] vertices) pure nothrow {
        this(geo);

        _vertices ~= vertices;
    }

    this()(size_t radius, auto ref const Vector2f center, size_t vecNum = 30) pure nothrow {
        assert(vecNum >= 10, "Too few edges for a circle");

        this(Geometry.TriangleFan);

        enum real PIx2 = std.math.PI * 2;
        immutable float Deg2Rad = PIx2 / vecNum;

        _vertices.reserve(vecNum);
        
        for (size_t i = 0; i < vecNum; i++) {
            immutable float degInRad = i * Deg2Rad;
            
            immutable float x = center.x + std.math.cos(degInRad) * radius;
            immutable float y = center.y + std.math.sin(degInRad) * radius;
            
            this.append(Vertex(x, y));
        }
    }

    void append()(auto ref const Vertex vertex) pure nothrow {
        _vertices ~= vertex;
    }

    @nogc
    void setTexture(Texture* texture) pure nothrow {
        _texture = texture;

        if (texture)
            this.setTextureRect([0, 0, texture.width, texture.height]);
    }

    /**
     * texArea = [x, y, w, h]
     */
    @nogc
    void setTexture(Texture* texture, const float[4] texArea) pure nothrow {
        _texture = texture;

        if (texture)
            this.setTextureRect(texArea);
    }

    @nogc
    inout(Texture*) getTexture() inout pure nothrow {
        return _texture;
    }

    @nogc
    void setTextureRect(const float[4] texArea) pure nothrow {
        assert(_texture, "No texture defined");

        immutable float[4] bounds = this.getBoundingArea();
        foreach (ref Vertex v; _vertices) {
            immutable float xratio = bounds[2] > 0 ? (v.position.x - bounds[0]) / bounds[2] : 0;
            immutable float yratio = bounds[3] > 0 ? (v.position.y - bounds[1]) / bounds[3] : 0;

            v.texCoord.x = (texArea[0] + texArea[2] * xratio) / _texture.width;
            v.texCoord.y = (texArea[1] + texArea[3] * yratio) / _texture.height;
        }
    }

    @nogc
    float[4] getBoundingArea() const pure nothrow {
        assert(_vertices.length > 0, "No vertices");

        float left = _vertices[0].position.x;
        float top = _vertices[0].position.y;
        float right = _vertices[0].position.x;
        float bottom = _vertices[0].position.y;

        foreach (ref const Vertex v; _vertices) {
            // Update left and right
            if (v.position.x < left)
                left = v.position.x;
            else if (v.position.x > right)
                right = v.position.x;
            // Update top and bottom
            if (v.position.y < top)
                top = v.position.y;
            else if (v.position.y > bottom)
                bottom = v.position.y;
        }

        return [left, top, right - left, bottom - top];
    }

    @nogc
    inout(Vertex[]) getVertices() inout pure nothrow {
        return _vertices;
    }

    @nogc
    void setColor()(auto ref const Color4b col) pure nothrow {
        foreach (ref Vertex v; _vertices) {
            v.color = Color4f(col);
        }
    }
}