module Dgame.Math.Geometry;

private:

import derelict.opengl3.deprecatedConstants;
import derelict.opengl3.constants;

public:

enum Geometry {
    Quad = GL_QUADS,            /** Declare that the stored vertices are Quads. */
    QuadStrip = GL_QUAD_STRIP,  /** Declare that the stored vertices are Quad Strips*/
    Triangle = GL_TRIANGLES,    /** Declare that the stored vertices are Triangles. */
    TriangleStrip = GL_TRIANGLE_STRIP,  /** Declare that the stored vertices are Triangles Strips */
    TriangleFan = GL_TRIANGLE_FAN,      /** Declare that the stored vertices are Triangles Fans. */
    Lines = GL_LINES,           /** Declare that the stored vertices are Lines. */
    LineStrip = GL_LINE_STRIP,  /** Declare that the stored vertices are Line Strips. */
    LineLoop = GL_LINE_LOOP,    /** Declare that the stored vertices are Line Loops. */
    Polygon = GL_POLYGON,       /** Declare that the stored vertices are Polygons. */
}