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
module Dgame.Graphic.Blend;

import derelict.opengl3.gl;

/**
 * The Blending struct enables the use of OpenGl Blending
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Blend {
    /**
     * Both Factors (destination and source) are Factor.One
     */
    static immutable Blend One     = Blend(Factor.One, Factor.One);
    /**
     * Both Factors (destination and source) are Factor.Zero
     */
    static immutable Blend Zero    = Blend(Factor.Zero, Factor.Zero);
    /**
     * source is Factor.SrcAlpha and destination is Factor.OneMinusSrcAlpha
     * This is the default Blending in Dgame
     */
    static immutable Blend Default = Blend(Factor.SrcAlpha, Factor.OneMinusSrcAlpha);

    /**
     * The Factor enum
     */
    enum Factor {
        Zero = GL_ZERO, ///
        One = GL_ONE, ///
        SrcColor = GL_SRC_COLOR, ///
        OneMinusSrcColor = GL_ONE_MINUS_SRC_COLOR, ///
        DstColor = GL_DST_COLOR, ///
        OneMinusDstColor = GL_ONE_MINUS_DST_COLOR, ///
        SrcAlpha = GL_SRC_ALPHA, ///
        OneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA, ///
        DstAlpha = GL_DST_ALPHA, ///
        OneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA ///
    }

    /**
     * The source color Factor
     */
    Factor srcColor = Factor.One;
    /**
     * The destination color Factor
     */
    Factor dstColor = Factor.Zero;

    /**
     * Apply the Blending
     */
    @nogc
    void apply() const nothrow {
        glBlendFunc(this.srcColor, this.dstColor);
    }
}