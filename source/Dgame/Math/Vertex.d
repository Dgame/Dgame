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
module Dgame.Math.Vertex;

private:

import Dgame.Graphic.Color;
import Dgame.Math.Vector2;

public:

/**
 * A Vertex is a coordinate, a color and a coordinate to the Texture
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Vertex {
    /**
     * The position
     */
    Vector2f position;
    /**
     * The Texture coordinates, if any
     */ 
    Vector2f texCoord;
    /**
     * The current Color. Default is Color4f.Black
     */
    Color4f color = Color4f.Black;

    /**
     * CTor
     */
    @nogc
    this(const Vector2f pos, const Vector2f coords, const Color4b col) pure nothrow {
        this(pos, coords);

        this.color = col;
    }

    /**
     * CTor
     */
    @nogc
    this(const Vector2f pos, const Vector2f coords) pure nothrow {
        this.position = pos;
        this.texCoord = coords;
    }

    /**
     * CTor
     */
    @nogc
    this(const Vector2f pos) pure nothrow {
        this.position = pos;
    }

    /**
     * CTor
     */
    @nogc
    this(float x, float y) pure nothrow {
        this.position.x = x;
        this.position.y = y;
    }
}