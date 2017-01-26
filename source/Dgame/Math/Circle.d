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
module Dgame.Math.Circle;

private:

import derelict.sdl2.sdl;

import Dgame.Math.Vector2;

import std.math: sqrt;


public:

/**
 * Circle defines a circle structure.
 *
 * Author: Leonardo Tada
 */
struct Circle {

    /**
     * The x coordinate
     */
    int x = 0;
    /**
     * The y coordinates
     */
    int y = 0;
    /**
     * The radius
     */
    uint radius;

    /**
     * CTor
     */
    @nogc
    this(int x, int y, uint radius) pure nothrow {
        this.x = x;
        this.y = y;
        this.radius  = radius;
    }

    /**
     * Supported operations: +, -, *, /, %
     */
    @nogc
    Circle opBinary(string op)(const Circle circle) const pure nothrow {
        switch (op) {
            case "+":
            case "-":
            case "*":
            case "/":
            case "%":
                mixin("return Circle(this.x " ~ op ~ " circle.x,
                              this.y " ~ op ~ " circle.y,
                              this.radius " ~ op ~ " circle.radius;");
            default:
                assert(0, "Unsupported Operation: " ~ op);
        }
    }

    /**
     * Collapse this Circle. Means that the radius is set to 0.
     */
    @nogc
    void collapse() pure nothrow {
        this.radius = 0;
    }

    /**
     * Checks if this Circle is empty (if it's collapsed) with SDL_RectEmpty.
     */
    @nogc
    bool isEmpty() const pure nothrow {
        return this.radius == 0;
    }

    // /**
    //  * Checks whether this Circle contains the given coordinates.
    //  */
    // @nogc
    // bool contains(const Vector2i vec) const pure nothrow {
    //     return this.contains(vec.x, vec.y);
    // }

    // /**
    //  * Checks whether this Circle contains the given coordinates.
    //  */
    // @nogc
    // bool contains(int x, int y) const pure nothrow {
    //     // TODO
    // }

    /**
     * opEquals: compares two rectangles on their coordinates and their size (but not explicit type).
     */
    @nogc
    bool opEquals(const Circle circle) const pure nothrow {
        return this.x == circle.x && this.y == circle.y && this.radius == circle.radius;
    }

    /**
     * Checks whether this Circle intersects with an other.
     * If, and the parameter 'overlap' isn't null,
     * the colliding circle is stored there.
     */
    @nogc
    bool intersects(const Circle circle, Circle* overlap = null) const {
        immutable Vector2i center1 = getCenter();
        immutable Vector2i center2 = circle.getCenter();
        immutable int dx = center1.x - center2.x;
        immutable int dy = center1.y - center2.y;
        immutable float distance = sqrt(cast(float)dx * dx + dy * dy);

        return distance < this.radius + circle.radius;
        // TODO stored
    }

    /**
     * Replace the current size.
     */
    @nogc
    void setRadius(uint radius) pure nothrow {
        this.radius = radius;
    }

    /**
     * Returns the current radius
     */
    @nogc
    uint getRadius() const pure nothrow {
        return this.radius;
    }

    /**
     * Increase current size.
     */
    @nogc
    void increase(int radius) pure nothrow {
        this.radius += radius;
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
    void setPosition(const Vector2i position) pure nothrow {
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
    void move(const Vector2i vec) pure nothrow {
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
     * Returns the center position of this Circle
     */
    @nogc
    Vector2i getCenter() const pure nothrow {
        return Vector2i(this.x + this.radius, this.y + this.radius);
    }
}
