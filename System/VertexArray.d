module Dgame.System.VertexArray;

private import derelict.opengl3.gl;

/**
 * A Vertex Array stores informations of a Buffer object and restore them if you bind this.
 * This decrease the calls of the Buffer, because the last state is always stored and can be restored easily.
 *
 * Author: rschuett
 */
final class VertexArray {
private:
	GLuint _vid;
	
public:
	/**
	 * CTor
	 */
	this() {
		glGenVertexArrays(1, &this._vid);
		
		this.bind();
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