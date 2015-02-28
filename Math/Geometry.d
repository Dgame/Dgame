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
module Dgame.Math.Geometry;

private:

import derelict.opengl3.deprecatedConstants;
import derelict.opengl3.constants;

public:

/**
 * Geometry describes different geometric representations.
 */
enum Geometry {
    Quad = GL_QUADS,            /** Declare that the stored vertices are Quads. */
    QuadStrip = GL_QUAD_STRIP,  /** Declare that the stored vertices are Quad Strips */
    Triangle = GL_TRIANGLES,    /** Declare that the stored vertices are Triangles. */
    TriangleStrip = GL_TRIANGLE_STRIP,  /** Declare that the stored vertices are Triangles Strips */
    TriangleFan = GL_TRIANGLE_FAN,      /** Declare that the stored vertices are Triangles Fans. */
    Lines = GL_LINES,           /** Declare that the stored vertices are Lines. */
    LineStrip = GL_LINE_STRIP,  /** Declare that the stored vertices are Line Strips. */
    LineLoop = GL_LINE_LOOP,    /** Declare that the stored vertices are Line Loops. */
    Polygon = GL_POLYGON,       /** Declare that the stored vertices are Polygons. */
}