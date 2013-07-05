module Dgame.System.StaticBuffer;

private {
	debug import std.stdio;
	
	import derelict.opengl3.gl;
}

/**
 * Primitive Types for the draw methods
 */
enum Primitive {
	Quad		= GL_QUADS,				/** Declare that the stored vertices are Quads. */
	QuadStrip	= GL_QUAD_STRIP,		/** Declare that the stored vertices are Quad Strips*/
	Triangle	= GL_TRIANGLES,			/** Declare that the stored vertices are Triangles. */
	TriangleStrip = GL_TRIANGLE_STRIP,	/** Declare that the stored vertices are Triangles Strips */
	TriangleFan = GL_TRIANGLE_FAN,		/** Declare that the stored vertices are Triangles Fans. */
	Lines		= GL_LINES,				/** Declare that the stored vertices are Lines. */
	LineStrip	= GL_LINE_STRIP,		/** Declare that the stored vertices are Line Strips. */
	LineLoop	= GL_LINE_LOOP,			/** Declare that the stored vertices are Line Loops. */
	Polygon		= GL_POLYGON			/** Declare that the stored vertices are Polygons. */
}

/**
 * Declare which data is stored. Possible are Vertices, Colors or Texture coordinates.
 */
enum PointerTarget {
	None   = 0,		/** Declare that the data consist of nothing relevant. */
	Vertex = 1, 	/** Declare that the data consist of vertices. */
	Color  = 2, 	/** Declare that the data consist of colors. */
	TexCoords = 4 	/** Declare that the data consist of texture coordinates. */
}

/**
 * Buffer is a wrapper for a static Vertex Array.
 * <b>It has nothing to do with the class VertexArray</b>
 *
 * Author: rschuett
 */
final abstract class StaticBuffer {
public:
	/**
	 * Points to the current VBO with a specific PointerTarget.
	 * 
	 * See: glVertexPointer
	 * See: glColorPointer
	 * See: glTexCoordPointer
	 * See: PointerTarget enum.
	 */
	static void pointTo(PointerTarget trg, const void* ptr = null, ubyte stride = 0) {
		StaticBuffer.enableState(trg);
		
		switch (trg) {
			case PointerTarget.None:
				assert(0, "Invalid PointerTarget");
			case PointerTarget.Vertex:
				glVertexPointer(3, GL_FLOAT, stride, ptr);
				break;
			case PointerTarget.Color:
				glColorPointer(4, GL_FLOAT, stride, ptr);
				break;
			case PointerTarget.TexCoords:
				glTexCoordPointer(2, GL_FLOAT, stride, ptr);
				break;
			default:
				assert(0, "Point to can only handle *one* pointer PointerTarget.");
		}
	}
	
	/**
	 * Enable a specific client state (with glEnableClientState)
	 * like GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	 * with the corresponding PointerTarget.
	 */
	static void enableState(PointerTarget trg) {
		if (trg & PointerTarget.None)
			assert(0, "Invalid PointerTarget");
		
		if (trg & PointerTarget.Vertex)
			glEnableClientState(GL_VERTEX_ARRAY);
		
		if (trg & PointerTarget.Color)
			glEnableClientState(GL_COLOR_ARRAY);
		
		if (trg & PointerTarget.TexCoords)
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/**
	 * Enable all client states
	 */
	static void enableAllStates() {
		StaticBuffer.enableState(PointerTarget.Vertex | PointerTarget.Color | PointerTarget.TexCoords);
	}
	
	/**
	 * Disable all client states
	 */
	static void disableAllStates() {
		StaticBuffer.disableState(PointerTarget.Vertex | PointerTarget.Color | PointerTarget.TexCoords);
	}
	
	/**
	 * Disable a specific client state (with glDisableClientState)
	 */
	static void disableState(PointerTarget trg) {
		if (trg & PointerTarget.None)
			assert(0, "Invalid PointerTarget");
		
		if (trg & PointerTarget.Vertex)
			glDisableClientState(GL_VERTEX_ARRAY);
		if (trg & PointerTarget.Color)
			glDisableClientState(GL_COLOR_ARRAY);
		if (trg & PointerTarget.TexCoords)
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices.
	 */
	static void drawArrays(Primitive type, size_t count, uint start = 0) {
		glDrawArrays(type, start, count);
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices and indices for the correct index per vertex.
	 */
	static void drawElements(Primitive type, size_t count, int[] indices) {
		if (indices.length == 0)
			return;
		
		glDrawElements(type, count, GL_UNSIGNED_INT, &indices[0]); 
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices and indices for the correct index per vertex.
	 * 
	 * Note: If start or end are -1 or below, 0 and indices.length are used.
	 */
	static void drawRangeElements(Primitive type, size_t count, int[] indices, int start = -1, int end = -1) {
		if (indices.length == 0)
			return;
		
		glDrawRangeElements(
			type,
			start ? start : 0,
			end ? end : indices.length,
			count,
			GL_UNSIGNED_INT,
			&indices[0]);
	}
}