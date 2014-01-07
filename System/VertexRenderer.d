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
module Dgame.System.VertexRenderer;

private {
	import derelict.opengl3.gl;
	
	import Dgame.Internal.Log;
	import Dgame.Graphics.Shape;
}

/**
 * Declare which data is stored. Possible are Vertices, Colors or Texture coordinates.
 */
enum Target {
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
final abstract class VertexRenderer {
public:
	/**
	 * Points to a specific Target.
	 * 
	 * See: glVertexPointer
	 * See: glColorPointer
	 * See: glTexCoordPointer
	 * See: Target enum.
	 */
	static void pointTo(Target trg, void* ptr = null, ubyte stride = 0, ubyte offset = 0) {
		VertexRenderer.enableState(trg);
		
		if (ptr !is null)
			ptr += offset;
		else if (offset != 0)
			ptr = cast(void*)(offset);
		
		final switch (trg) {
			case Target.None:
				Log.error("Invalid Target");
				break;
			case Target.Vertex:
				glVertexPointer(3, GL_FLOAT, stride, ptr);
				break;
			case Target.Color:
				glColorPointer(4, GL_FLOAT, stride, ptr);
				break;
			case Target.TexCoords:
				glTexCoordPointer(2, GL_FLOAT, stride, ptr);
				break;
		}
	}
	
	/**
	 * Enable a specific client state (with glEnableClientState)
	 * like GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	 * with the corresponding Target.
	 */
	static void enableState(Target trg) {
		if (trg & Target.None)
			Log.error("Invalid Target");
		
		if (trg & Target.Vertex)
			glEnableClientState(GL_VERTEX_ARRAY);
		
		if (trg & Target.Color)
			glEnableClientState(GL_COLOR_ARRAY);
		
		if (trg & Target.TexCoords)
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/**
	 * Enable all client states
	 */
	static void enableAllStates() {
		VertexRenderer.enableState(Target.Vertex | Target.Color | Target.TexCoords);
	}
	
	/**
	 * Disable all client states
	 */
	static void disableAllStates() {
		VertexRenderer.disableState(Target.Vertex | Target.Color | Target.TexCoords);
	}
	
	/**
	 * Disable a specific client state (with glDisableClientState)
	 */
	static void disableState(Target trg) {
		if (trg & Target.None)
			Log.error("Invalid Target");
		
		if (trg & Target.Vertex)
			glDisableClientState(GL_VERTEX_ARRAY);
		
		if (trg & Target.Color)
			glDisableClientState(GL_COLOR_ARRAY);
		
		if (trg & Target.TexCoords)
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/**
	 * Draw Shapes of a specific type from the data which is addressed through 'pointTo'.
	 * It will use count vertices.
	 *
	 * See: pointTo
	 */
	static void drawArrays(Shape.Type ptype, size_t count, size_t start = 0) {
		glDrawArrays(ptype, cast(uint) start, cast(uint) count);
	}
	
	/**
	 * Draw Shapes of a specific type from the data which is addressed through 'pointTo'.
	 * It will use count vertices and indices for the correct index per vertex.
	 * 
	 * See: pointTo
	 */
	static void drawElements(Shape.Type ptype, size_t count, uint[] indices) {
		if (indices.length == 0)
			return;
		
		glDrawElements(ptype, cast(uint) count, GL_UNSIGNED_INT, &indices[0]); 
	}
	
	/**
	 * Draw Shapes of a specific type from the data which is addressed through 'pointTo'.
	 * It will use count vertices and indices for the correct index per vertex.
	 * 
	 * Note: If start or end are -1 or below, 0 and indices.length are used.
	 * 
	 * See: pointTo
	 */
	static void drawRangeElements(Shape.Type ptype, size_t count, uint[] indices, uint start = 0, uint end = 0) {
		if (indices.length == 0)
			return;
		
		glDrawRangeElements(ptype, start, end != 0 ? end : cast(uint) indices.length, cast(uint) count, GL_UNSIGNED_INT, &indices[0]);
	}
}