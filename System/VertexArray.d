module Dgame.System.VertexArray;

private import derelict.opengl3.gl;

final class VertexArray {
private:
	GLuint _vid;
	
public:
	this() {
		glGenVertexArrays(1, &this._vid);
		
		this.bind();
	}
	
	~this() {
		glDeleteVertexArrays(1, &this._vid);
	}
	
	void bind() const {
		glBindVertexArray(this._vid);
	}
	
	void unbind() const {
		glBindVertexArray(0);
	}
	
	void enable(ubyte index) const {
		glEnableVertexAttribArray(index);
	}
	
	void disable(ubyte index) const {
		glDisableVertexAttribArray(index);
	}
	
	void pointTo(ubyte index) const {
		this.bind();
		
		this.enable(index);
		scope(exit) this.disable(index);
		
		glVertexAttribPointer(index, 3, GL_FLOAT, GL_FALSE, 0, null);
	}
	
	bool isValid() const {
		return glIsVertexArray(this._vid) == GL_TRUE;
	}
}