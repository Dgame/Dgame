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
module Dgame.Math.Rect;

private:

import derelict.sdl2.sdl;

import Dgame.Math.Vector2;

// @@ FIX @@
@nogc
bool SDL_RectEmpty(const SDL_Rect* X) pure nothrow {
    return !X || ( X.w <= 0 ) || ( X.h <= 0 );
}

// @@ FIX @@
@nogc
bool SDL_RectEquals(const SDL_Rect* A, const SDL_Rect* B) pure nothrow {
    return A && B &&
        (A.x == B.x) && (A.y == B.y) &&
        (A.w == B.w) && (A.h == B.h);
}

public:

@nogc
SDL_Rect* _transfer(ref const Rect rect, ref SDL_Rect to) pure nothrow {
    to.x = rect.x;
    to.y = rect.y;
    to.w = rect.width;
    to.h = rect.height;

    return &to;
}

struct Size {
    uint width;
    uint height;
}

/**
 * Rect defines a rectangle structure that contains the left upper corner and the width/height.
 *
 * Author: Randy Schuett
 */
struct Rect {
    enum Edge : ubyte {
        Top,
        Bottom,
        Left,
        Right,
        
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }

    /**
     * The x
     */
    int x = 0;
    /**
     * and y coordinates
     */
    int y = 0;
    /**
     * The width
     */
    uint width = 0;
    /**
     * and the height
     */
    uint height = 0;
    
    /**
     * CTor
     */
    @nogc
    this(int x, int y, uint width, uint height) pure nothrow {
        this.x = x;
        this.y = y;
        this.width  = width;
        this.height = height;
    }

    /**
     * Supported operations: +, -, *, /, %
     */
    @nogc
    Rect opBinary(string op)(ref const Rect rect) const pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Rect(this.x " ~ op ~ " rect.x,
                              this.y " ~ op ~ " rect.y,
                              this.width " ~ op ~ " rect.width,
                              this.height " ~ op ~ " rect.height);");
            default:
                assert(0, "Unsupported Operation: " ~ op);
        }
    }
    
    /**
     * Collapse this Rect. Means that the coordinates and the size is set to 0.
     */
    @nogc
    void collapse() pure nothrow {
        this.width = this.height = this.x = this.y = 0;
    }
    
    /**
     * Checks if this Rect is empty (if it's collapsed) with SDL_RectEmpty.
     */
    @nogc
    bool isEmpty() const pure nothrow {
        SDL_Rect a = void;
        return SDL_RectEmpty(_transfer(this, a)) == SDL_TRUE;
    }
    
    /**
     * Checks if all corners are zero.
     */
    @nogc
    bool isZero() const pure nothrow {
        return this.x == 0 && this.y == 0 && this.width == 0 && this.height == 0;
    }
    
    /**
     * Returns an union of the given and this Rect.
     */
    @nogc
    Rect getUnion(ref const Rect rect) const {
        SDL_Rect a = void;
        SDL_Rect b = void;
        SDL_Rect c = void;

        SDL_UnionRect(_transfer(this, a), _transfer(rect, b), &c);

        return Rect(c.x, c.y, c.w, c.h);
    }
    
    /**
     * Checks whether this Rect contains the given coordinates.
     */
    @nogc
    bool contains(ref const Vector2i vec) const pure nothrow {
        return this.contains(vec.x, vec.y);
    }
    
    /**
     * Checks whether this Rect contains the given coordinates.
     */
    @nogc
    bool contains(int x, int y) const pure nothrow {
        return (x >= this.x) && (x < this.x + this.width)
            && (y >= this.y) && (y < this.y + this.height);
    }
    
    /**
     * opEquals: compares two rectangles on their coordinates and their size (but not explicit type).
     */
    @nogc
    bool opEquals(ref const Rect rect) const pure nothrow {
        SDL_Rect a = void;
        SDL_Rect b = void;

        return SDL_RectEquals(_transfer(this, a), _transfer(rect, b));
    }
    
    /**
     * Checks whether this Rect intersects with an other.
     * If, and the parameter 'overlap' isn't null,
     * the colliding rectangle is stored there.
     */
    @nogc
    bool intersects(ref const Rect rect, Rect* overlap = null) const {
        SDL_Rect a = void;
        SDL_Rect b = void;

        if (overlap is null)
            return SDL_HasIntersection(_transfer(this, a), _transfer(rect, b)) == SDL_TRUE;

        SDL_Rect c = void;

        immutable bool intersects = SDL_IntersectRect(_transfer(this, a), _transfer(rect, b), &c) == SDL_TRUE;

        overlap.x = c.x;
        overlap.y = c.y;
        overlap.width = c.w;
        overlap.height = c.h;

        return intersects;
    }
    
    /**
     * Replace current size.
     */
    @nogc
    void setSize(uint width, uint height) pure nothrow {
        this.width  = width;
        this.height = height;
    }
    
    /**
     * Returns the current size as Vector2
     */
    @nogc
    Size getSize() const pure nothrow {
        return Size(this.width, this.height);
    }
    
    /**
     * Increase current size.
     */
    @nogc
    void increase(int width, int height) pure nothrow {
        this.width += width;
        this.height += height;
    }
    
    /**
     * Set a new position with coordinates.
     */
    @nogc
    void setPosition(int x, int y) pure nothrow {
        this.x = x;
        this.y = y;
    }
    
    /**
     * Set a new position with a vector.
     */
    @nogc
    void setPosition(ref const Vector2i position) pure nothrow {
        this.setPosition(position.x, position.y);
    }
    
    /**
     * Returns the current position as Vector2
     */
    @nogc
    Vector2i getPosition() const pure nothrow {
        return Vector2i(this.x, this.y);
    }
    
    /**
     * Move the object.
     */
    @nogc
    void move(ref const Vector2i vec) pure nothrow {
        this.move(vec.x, vec.y);
    }
    
    /**
     * Move the object.
     */
    @nogc
    void move(int x, int y) pure nothrow {
        this.x += x;
        this.y += y;
    }

    /**
     * Returns the position of the given Edge on this Rect.
     */
    @nogc
    Vector2i getEdgePosition(Edge edge) const pure nothrow {
        Vector2i pos;
        final switch (edge) {
            case Edge.Top:
                pos.x = this.x + (this.width / 2);
                pos.y = this.y;
            break;
            case Edge.Bottom:
                pos.x = this.x + (this.width / 2);
                pos.y = this.y + this.height;
            break;
            case Edge.Left:
                pos.x = this.x;
                pos.y = this.y + (this.height / 2);
            break;
            case Edge.Right:
                pos.x = this.x + this.width;
                pos.y = this.y + (this.height / 2);
            break;
            case Edge.TopLeft:
                pos.x = this.x;
                pos.y = this.y;
            break;
            case Edge.TopRight:
                pos.x = this.x + this.width;
                pos.y = this.y;
            break;
            case Edge.BottomLeft:
                pos.x = this.x;
                pos.y = this.y + this.height;
            break;
            case Edge.BottomRight:
                pos.x = this.x + this.width;
                pos.y = this.y + this.height;
            break;
        }

        return pos;
    }

    /**
     * Returns the center position of this Rect
     */
    @nogc
    Vector2i getCenter() const pure nothrow {
        return Vector2i(this.x + (this.width / 2), this.y + (this.height / 2));
    }
}