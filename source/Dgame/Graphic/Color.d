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

mixin template Colors(T) {
    static immutable T Aliceblue            = T(240, 248, 255);
    static immutable T Antiquewhite         = T(250, 235, 215);
    static immutable T Aquamarine           = T(127, 255, 212);
    static immutable T Azure                = T(240, 255, 255);
    static immutable T Beige                = T(245, 245, 220);
    static immutable T Bisque               = T(255, 228, 196);
    static immutable T Black                = T(  0,   0,   0);
    static immutable T Blanchedalmond       = T(255, 235, 205);
    static immutable T Blue                 = T(  0,   0, 255);
    static immutable T Blueviolet           = T(138,  43, 226);
    static immutable T Brown                = T(165,  42,  42);
    static immutable T Burlywood            = T(222, 184, 135);
    static immutable T Cadetblue            = T( 95, 158, 160);
    static immutable T Chartreuse           = T(127, 255,   0);
    static immutable T Chocolate            = T(210, 105,  30);
    static immutable T Coral                = T(255, 127,  80);
    static immutable T Cornflowerblue       = T(100, 149, 237);
    static immutable T Cornsilk             = T(255, 248, 220);
    static immutable T Cyan                 = T(  0, 255, 255);
    static immutable T Darkblue             = T(  0,   0, 139);
    static immutable T Darkcyan             = T(  0, 139, 139);
    static immutable T Darkgoldenrod        = T(184, 134,  11);
    static immutable T Darkgray             = T(169, 169, 169);
    static immutable T Darkgreen            = T(  0, 100,   0);
    static immutable T Darkkhaki            = T(189, 183, 107);
    static immutable T Darkmagenta          = T(139,   0, 139);
    static immutable T Darkolivegreen       = T( 85, 107,  47);
    static immutable T Darkorange           = T(255, 140,   0);
    static immutable T Darkorchid           = T(153,  50, 204);
    static immutable T Darkred              = T(139,   0,   0);
    static immutable T Darksalmon           = T(233, 150, 122);
    static immutable T Darkseagreen         = T(143, 188, 143);
    static immutable T Darkslateblue        = T( 72,  61, 139);
    static immutable T Darkslategray        = T( 47,  79,  79);
    static immutable T Darkturquoise        = T(  0, 206, 209);
    static immutable T Darkviolet           = T(148,   0, 211);
    static immutable T Deeppink             = T(255,  20, 147);
    static immutable T Deepskyblue          = T(  0, 191, 255);
    static immutable T Dimgray              = T(105, 105, 105);
    static immutable T Dodgerblue           = T( 30, 144, 255);
    static immutable T Firebrick            = T(178,  34,  34);
    static immutable T Floralwhite          = T(255, 250, 240);
    static immutable T Forestgreen          = T( 34, 139,  34);
    static immutable T Gainsboro            = T(220, 220, 220);
    static immutable T Ghostwhite           = T(248, 248, 255);
    static immutable T Gold                 = T(255, 215,   0);
    static immutable T Goldenrod            = T(218, 165,  32);
    static immutable T Green                = T(  0, 255,   0);
    static immutable T Greenyellow          = T(173, 255,  47);
    static immutable T Honeydew             = T(240, 255, 240);
    static immutable T Hotpink              = T(255, 105, 180);
    static immutable T Indianred            = T(205,  92,  92);
    static immutable T Ivory                = T(255, 255, 240);
    static immutable T Khaki                = T(240, 230, 140);
    static immutable T Lavender             = T(230, 230, 250);
    static immutable T Lavenderblush        = T(255, 240, 245);
    static immutable T Lawngreen            = T(124, 252,   0);
    static immutable T Lemonchiffon         = T(255, 250, 205);
    static immutable T Lightblue            = T(173, 216, 230);
    static immutable T Lightcoral           = T(240, 128, 128);
    static immutable T Lightcyan            = T(224, 255, 255);
    static immutable T Lightgoldenrod       = T(238, 221, 130);
    static immutable T Lightgoldenrodyellow = T(250, 250, 210);
    static immutable T Lightgray            = T(211, 211, 211);
    static immutable T Lightgreen           = T(144, 238, 144);
    static immutable T Lightpink            = T(255, 182, 193);
    static immutable T Lightsalmon          = T(255, 160, 122);
    static immutable T Lightseagreen        = T( 32, 178, 170);
    static immutable T Lightskyblue         = T(135, 206, 250);
    static immutable T Lightslateblue       = T(132, 112, 255);
    static immutable T Lightslategray       = T(119, 136, 153);
    static immutable T Lightsteelblue       = T(176, 196, 222);
    static immutable T Lightyellow          = T(255, 255, 224);
    static immutable T Limegreen            = T( 50, 205,  50);
    static immutable T Linen                = T(250, 240, 230);
    static immutable T Magenta              = T(255,   0, 255);
    static immutable T Maroon               = T(176,  48,  96);
    static immutable T Mediumaquamarine     = T(102, 205, 170);
    static immutable T Mediumblue           = T(  0,   0, 205);
    static immutable T Mediumorchid         = T(186,  85, 211);
    static immutable T Mediumpurple         = T(147, 112, 219);
    static immutable T Mediumseagreen       = T( 60, 179, 113);
    static immutable T Mediumslateblue      = T(123, 104, 238);
    static immutable T Mediumspringgreen    = T(  0, 250, 154);
    static immutable T Mediumturquoise      = T( 72, 209, 204);
    static immutable T Mediumvioletred      = T(199,  21, 133);
    static immutable T Midnightblue         = T( 25,  25, 112);
    static immutable T Mintcream            = T(245, 255, 250);
    static immutable T Mistyrose            = T(255, 228, 225);
    static immutable T Moccasin             = T(255, 228, 181);
    static immutable T Navajowhite          = T(255, 222, 173);
    static immutable T Navy                 = T(  0,   0, 128);
    static immutable T Navyblue             = T(  0,   0, 128);
    static immutable T Oldlace              = T(253, 245, 230);
    static immutable T Olivedrab            = T(107, 142,  35);
    static immutable T Orange               = T(255, 165,   0);
    static immutable T Orangered            = T(255,  69,   0);
    static immutable T Orchid               = T(218, 112, 214);
    static immutable T Palegoldenrod        = T(238, 232, 170);
    static immutable T Palegreen            = T(152, 251, 152);
    static immutable T Paleturquoise        = T(175, 238, 238);
    static immutable T Palevioletred        = T(219, 112, 147);
    static immutable T Papayawhip           = T(255, 239, 213);
    static immutable T Peachpuff            = T(255, 218, 185);
    static immutable T Peru                 = T(205, 133,  63);
    static immutable T Pink                 = T(255, 192, 203);
    static immutable T Plum                 = T(221, 160, 221);
    static immutable T Powderblue           = T(176, 224, 230);
    static immutable T Purple               = T(160,  32, 240);
    static immutable T Red                  = T(255,   0,   0);
    static immutable T Rosybrown            = T(188, 143, 143);
    static immutable T Royalblue            = T( 65, 105, 225);
    static immutable T Saddlebrown          = T(139,  69,  19);
    static immutable T Salmon               = T(250, 128, 114);
    static immutable T Sandybrown           = T(244, 164,  96);
    static immutable T Seagreen             = T( 46, 139,  87);
    static immutable T Seashell             = T(255, 245, 238);
    static immutable T Sienna               = T(160,  82,  45);
    static immutable T Skyblue              = T(135, 206, 235);
    static immutable T Slateblue            = T(106,  90, 205);
    static immutable T Slategray            = T(112, 128, 144);
    static immutable T Snow                 = T(255, 250, 250);
    static immutable T Springgreen          = T(  0, 255, 127);
    static immutable T Steelblue            = T( 70, 130, 180);
    static immutable T Tan                  = T(210, 180, 140);
    static immutable T Thistle              = T(216, 191, 216);
    static immutable T Tomato               = T(255,  99,  71);
    static immutable T Turquoise            = T( 64, 224, 208);
    static immutable T Violet               = T(238, 130, 238);
    static immutable T Violetred            = T(208,  32, 144);
    static immutable T Wheat                = T(245, 222, 179);
    static immutable T White                = T(255, 255, 255);
    static immutable T Whitesmoke           = T(245, 245, 245);
    static immutable T Yellow               = T(255, 255,   0);
    static immutable T Yellowgreen          = T(154, 205,  50);
}

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
    mixin Colors!Color4b;

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
    mixin Colors!Color4f;

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
