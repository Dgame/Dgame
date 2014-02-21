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
module Dgame.System.VertexArrayObject;

private import derelict.opengl3.gl;

/**
 * A Vertex Array stores informations of a Buffer object and restore them if you bind this.
 * This decrease the calls of the Buffer, because the last state is always stored and can be restored easily.
 *
 * Author: rschuett
 */
class VertexArrayObject {
private:
	GLuint _vid;
	
public:
final:
	/**
	 * CTor
	 */
	this() {
		glGenVertexArrays(1, &this._vid);
		
		this.bind();
		this.unbind();
	}
	
	/**
	 * DTor
	 */
	~this() {
		glDeleteVertexArrays(1, &this._vid);
	}
	
	/**
	 * Bind the Vertex Array
	 */
	void bind() const {
		glBindVertexArray(this._vid);
	}
	
	/**
	 * Unbind the Vertex array
	 */
	void unbind() const {
		glBindVertexArray(0);
	}
	
	/**
	 * Enable the usage of the Vertex array on the specific index
	 */
	void enable(ubyte index) const {
		glEnableVertexAttribArray(index);
	}
	
	/**
	 * Disable the usage
	 * 
	 * See: enable
	 */
	void disable(ubyte index) const {
		glDisableVertexAttribArray(index);
	}
	
	/**
	 * Bind, Enable and Point to the Vertex array on the specific index
	 * 
	 */
	void pointTo(ubyte index) const {
		this.bind();
		
		this.enable(index);
		scope(exit) this.disable(index);
		
		glVertexAttribPointer(index, 3, GL_FLOAT, GL_FALSE, 0, null);
	}
	
	/**
	 * Returns if this Vertex array is valid
	 */
	bool isValid() const {
		return glIsVertexArray(this._vid) == GL_TRUE;
	}
}