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
import Dgame.Math.Geometry;

public:

/**
 * Shape defines a drawable geometric shape.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
class Shape : Transformable, Drawable {
public:
    /**
     * Defines how the Shape should be filled.
     */
    enum Fill : ubyte {
        Full, /// Full / Complete fill
        Point, /// Show only the points
        Line  /// Show only the lines
    }

private:
    Texture* _texture;
    Vertex[] _vertices;

protected:
    @nogc
    override void draw(ref const Window wnd) nothrow {
        if (this.lineWidth != 1)
            glLineWidth(this.lineWidth);

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
    /**
     * The geometric type of the shape
     *
     * See: Geometric enum
     */
    Geometry geometry;
    /**
     * Fill option. Default is Fill.Full
     */
    Fill fill = Fill.Full;
    /**
     * Option for the line width. Default is 1
     */
    ubyte lineWidth = 1;
    /**
     * Optional anti-alias for lines thicker than 1. Default is false.
     *
     * Note: this is redundant if you have already enabled anti-aliasing
     */
    bool antiAliasing = false;

final:
    /**
     * CTor
     */
    @nogc
    this(Geometry geo) pure nothrow {
        this.geometry = geo;
    }

    /**
     * CTor
     */
    this(Geometry geo, Vertex[] vertices) pure nothrow {
        this(geo);

        _vertices ~= vertices;
    }

    /**
     * CTor for circles
     */
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

    /**
     * Stores a Vertex
     */
    void append()(auto ref const Vertex vertex) pure nothrow {
        _vertices ~= vertex;
    }

    /**
     * Stores multiple Vertices
     */
    void append(Vertex[] vertices) pure nothrow {
        _vertices.reserve(vertices.length);
        _vertices ~= vertices;
    }

    /**
     * Set or reset a Texture
     */
    @nogc
    void setTexture(Texture* texture) pure nothrow {
        _texture = texture;

        if (texture)
            this.setTextureRect(Rect(0, 0, texture.width, texture.height));
    }

    /**
     * Set (or reset) a Texture and set the corresponding Rect
     */
    @nogc
    void setTexture()(Texture* texture, auto ref const Rect rect) pure nothrow {
        _texture = texture;

        if (texture)
            this.setTextureArea(rect);
    }

    /**
     * Returns the current texture or null
     */
    @nogc
    inout(Texture*) getTexture() inout pure nothrow {
        return _texture;
    }

    /**
     * Set the corresponding Texture Rect
     */
    @nogc
    void setTextureRect()(auto ref const Rect rect) pure nothrow {
        assert(_texture, "No texture defined");

        const Rect clip = this.getClipRect();
        foreach (ref Vertex v; _vertices) {
            immutable float xratio = clip.width > 0 ? (v.position.x - clip.x) / clip.width : 0;
            immutable float yratio = clip.height > 0 ? (v.position.y - clip.y) / clip.height : 0;

            v.texCoord.x = (rect.x + rect.width * xratio) / _texture.width;
            v.texCoord.y = (rect.y + rect.height * yratio) / _texture.height;
        }
    }

    /**
     * Returns the clip Rect
     */
    @nogc
    Rect getClipRect() const pure nothrow {
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

        immutable int l = cast(int) left;
        immutable int t = cast(int) top;
        immutable uint w = cast(uint)(right - left);
        immutable uint h = cast(uint)(bottom - top);

        return Rect(l, t, w, h);
    }

    /**
     * Returns all Vertices
     */
    @nogc
    inout(Vertex[]) getVertices() inout pure nothrow {
        return _vertices;
    }

    /**
     * Set the color of <b>all</b> Vertices
     *
     * Note: If you only want to set specific Vertices to a specific color, you should use getVertices()
     *       and adapt the specific entries.
     */
    @nogc
    void setColor()(auto ref const Color4b col) pure nothrow {
        foreach (ref Vertex v; _vertices) {
            v.color = Color4f(col);
        }
    }
}