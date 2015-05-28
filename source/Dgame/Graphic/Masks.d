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
module Dgame.Graphic.Masks;

/**
 * The RGBA-Mask are the bitmasks used to extract that color from a pixel.
 * It is used to e.g. define the background of a newly created Surface.
 * Using zeros for the RGB-Masks sets a default value, based on the depth
 * But using zero for the Aalpha-Mask results in an Alpha-Mask of 0.
 * By default Surfaces with an Alpha-Mask are set up for blending.
 * You can change the blend mode with Surface.setBlendMode.
 */
struct Masks {
    /**
     * The RGBA-Masks are zero.
     * Using zeros for the RGB-Masks sets a default value, based on the given depth.
     * Using zero for the Alpha-Mask results in an Alpha-Mask of 0.
     */
    static immutable Masks Zero = Masks(0, 0, 0, 0);

    version (LittleEndian) {
        uint red = 0x000000ff; /// the red mask, default is 0x000000ff
        uint green = 0x0000ff00; /// the green mask, default is 0x0000ff00
        uint blue = 0x00ff0000; /// the blue mask, default is 0x00ff0000
        uint alpha = 0xff000000; /// the alpha mask, default is 0xff000000
    } else {
        uint red = 0xff000000; /// the red mask, default is 0xff000000
        uint green = 0x00ff0000; /// the green mask, default is 0x00ff0000
        uint blue = 0x0000ff00; /// the blue mask, default is 0x0000ff00
        uint alpha = 0x000000ff; /// the alpha mask, default is 0x000000ff
    }

    /**
     * CTor
     */
    @nogc
    this(uint red, uint green, uint blue, uint alpha) pure nothrow {
        this.red = red;
        this.green = green;
        this.blue = blue;
        this.alpha = alpha;
    }
}
