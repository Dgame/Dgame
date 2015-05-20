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
module Dgame.Graphic.Color;

private:

import derelict.sdl2.types;

package(Dgame):

@nogc
SDL_Color* _transfer(ref const Color4b src, ref SDL_Color dst) pure nothrow {
    dst.r = src.red;
    dst.g = src.green;
    dst.b = src.blue;
    dst.a = src.alpha;

    return &dst;
}

public:

/**
 * Color4b defines a structure which contains 4 ubyte values, each for red, green, blue and alpha.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Color4b {
    static immutable Color4b Black   = Color4b(0,     0,   0); /// Black Color (0, 0, 0)
    static immutable Color4b White   = Color4b(255, 255, 255); /// White Color (255, 255, 255)
    static immutable Color4b Red     = Color4b(255,   0,   0); /// Red Color (255, 0, 0)
    static immutable Color4b Green   = Color4b(0,   255,   0); /// Green Color (0, 255, 0)
    static immutable Color4b Blue    = Color4b(0,     0, 255); /// Blue Color (0, 0, 255)
    static immutable Color4b Cyan    = Color4b(0,   255, 255); /// Cyan Color (0, 255, 255)
    static immutable Color4b Yellow  = Color4b(255, 255,   0); /// Yellow Color (255, 255, 0)
    static immutable Color4b Magenta = Color4b(255,   0, 255); /// Magenta Color (255, 0, 255)
    static immutable Color4b Gray    = Color4b(179, 179, 179); /// Gray Color (179, 179, 179)
    
    /**
     * The color components
     */
    ubyte red, green, blue, alpha;
    
    /**
     * CTor
     */
    @nogc
    this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
        this.red   = red;
        this.green = green;
        this.blue  = blue;
        this.alpha = alpha;
    }

    /**
     * CTor
     */
    @nogc
    this(uint hexValue) pure nothrow {
        version (LittleEndian) {
            this.alpha = (hexValue >> 24) & 0xff;
            this.blue  = (hexValue >> 16) & 0xff;
            this.green = (hexValue >>  8) & 0xff;
            this.red   = hexValue & 0xff;
        } else {
            this.red   = (hexValue >> 24) & 0xff;
            this.green = (hexValue >> 16) & 0xff;
            this.blue  = (hexValue >>  8) & 0xff;
            this.alpha = hexValue & 0xff;
        }
    }
    
    /**
     * CTor
     *
     * Expect that every component is in range 0.0 .. 1.0
     */
    @nogc
    this(ref const Color4f col) pure nothrow
    in {
        assert(col.red   >= 0f && col.red   <= 1f);
        assert(col.green >= 0f && col.green <= 1f);
        assert(col.blue  >= 0f && col.blue  <= 1f);
        assert(col.alpha >= 0f && col.alpha <= 1f);
    } body {
        this.red   = cast(ubyte)(ubyte.max * col.red);
        this.green = cast(ubyte)(ubyte.max * col.green);
        this.blue  = cast(ubyte)(ubyte.max * col.blue);
        this.alpha = cast(ubyte)(ubyte.max * col.alpha);
    }

    /**
     * Returns a copy of the current Color with a given transpareny.
     */
    @nogc
    Color4b withTransparency(ubyte alpha) const pure nothrow {
        return Color4b(this.red, this.green, this.blue, alpha);
    }

    /**
     * opEquals: compares two Colors.
     */
    @nogc
    bool opEquals(ref const Color4b col) const pure nothrow {
        return this.red   == col.red &&
               this.green == col.green &&
               this.blue  == col.blue &&
               this.alpha == col.alpha;
    }
    
    /**
     * Returns the RGBA color information as static array
     */
    @nogc
    ubyte[4] asRGBA() const pure nothrow {
        return [this.red, this.green, this.blue, this.alpha];
    }
    
    /**
     * Returns RGB the color information as static array
     */
     @nogc
    ubyte[3] asRGB() const pure nothrow {
        return [this.red, this.green, this.blue];
    }

    /**
     * Returns the RGBA color information as hex value
     */
    @nogc
    uint asHex() const pure nothrow {
        version (LittleEndian)
            return ((this.alpha & 0xff) << 24) + ((this.blue & 0xff) << 16) + ((this.green & 0xff) << 8) + (this.red & 0xff);
        else
            return ((this.red & 0xff) << 24) + ((this.green & 0xff) << 16) + ((this.blue & 0xff) << 8) + (this.alpha & 0xff);
    }
}

unittest {
    const Color4b red_col = Color4b.Red;
    immutable uint hex_red = red_col.asHex();

    assert(hex_red == 0xff0000ff);
    assert(Color4b(hex_red) == red_col);
}

/**
 * Color4f defines a structure which contains 4 floats values, each for red, green, blue and alpha.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Color4f {
    static immutable Color4f Black   = Color4f(0,     0,   0); /// Black Color (0, 0, 0)
    static immutable Color4f White   = Color4f(255, 255, 255); /// White Color (255, 255, 255)
    static immutable Color4f Red     = Color4f(255,   0,   0); /// Red Color (255, 0, 0)
    static immutable Color4f Green   = Color4f(0,   255,   0); /// Green Color (0, 255, 0)
    static immutable Color4f Blue    = Color4f(0,     0, 255); /// Blue Color (0, 0, 255)
    static immutable Color4f Cyan    = Color4f(0,   255, 255); /// Cyan Color (0, 255, 255)
    static immutable Color4f Yellow  = Color4f(255, 255,   0); /// Yellow Color (255, 255, 0)
    static immutable Color4f Magenta = Color4f(255,   0, 255); /// Magenta Color (255, 0, 255)
    static immutable Color4f Gray    = Color4f(179, 179, 179); /// Gray Color (179, 179, 179)
    
    /**
     * The color components
     */
    float red, green, blue, alpha;
    
    /**
     * CTor
     */
    @nogc
    this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
        this.red   = red   > 0 ? red   / 255f : 0;
        this.green = green > 0 ? green / 255f : 0;
        this.blue  = blue  > 0 ? blue  / 255f : 0;
        this.alpha = alpha > 0 ? alpha / 255f : 0;
    }

    /**
     * CTor
     * Expect that every component is in range 0.0 .. 1.0
     */
    @nogc
    this(float red, float green, float blue, float alpha = 1) pure nothrow
    in {
        assert(red   >= 0f && red   <= 1f);
        assert(green >= 0f && green <= 1f);
        assert(blue  >= 0f && blue  <= 1f);
        assert(alpha >= 0f && alpha <= 1f);
    } body {
        this.red   = red;
        this.green = green;
        this.blue  = blue;
        this.alpha = alpha;
    }

    /**
     * CTor
     */
    @nogc
    this(ref const Color4b col) pure nothrow {
        this(col.red, col.green, col.blue, col.alpha);
    }

    /**
     * opEquals: compares two Colors.
     */
    @nogc
    bool opEquals(ref const Color4f col) const pure nothrow {
        return this.red   == col.red &&
               this.green == col.green &&
               this.blue  == col.blue &&
               this.alpha == col.alpha;
    }
    
    /**
     * Returns the RGBA color information as static array
     */
    @nogc
    float[4] asRGBA() const pure nothrow {
        return [this.red, this.green, this.blue, this.alpha];
    }
    
    /**
     * Returns RGB the color information as static array
     */
     @nogc
    float[3] asRGB() const pure nothrow {
        return [this.red, this.green, this.blue];
    }
}