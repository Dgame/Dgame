module Dgame.System.Buffer;

private {
	debug import std.stdio;
	import std.conv : to;
	
	import derelict2.opengl.gltypes;
	import derelict2.opengl.glfuncs;
	
	import Dgame.Math.Vertex;
}

/**
 * Buffer is a object oriented wrapper for a Vertex Buffer Object.
 *
 * Author: rschuett
 */
final class Buffer {
public:
	/**
	 * Declare which Buffer Type is stored.
	 */
	enum Type {
		/** The currently bound buffer object stores vertex array data. */
		Array = GL_ARRAY_BUFFER,
		/** The currently bound buffer object stores index values ​​for vertex arrays. */
		Element = GL_ELEMENT_ARRAY_BUFFER
	}
	
	/**
	 * The access type.
	 */
	enum Access {
		Read  = GL_READ_ONLY,	/** Read only. */
		Write = GL_WRITE_ONLY,	/** Write only. */
		ReadWrite = GL_READ_WRITE /** Read and write. */
	}
	
	/**
	 * Stream usage
	 */
	enum Stream {
		/** 
		 * The contents of the data memory is determined once by the application
		 * and rarely used as the source for GL rendering command.
		 */
		Draw = GL_STREAM_DRAW,
		/**
		 * The contents of the data memory is determined once for reading data 
		 * and rarely queried by the application.
		 */
		Read = GL_STREAM_READ,
		/**
		 * The contents of the data memory is determined once for reading data 
		 * and rarely used as the source for GL rendering command.
		 */
		Copy = GL_STREAM_COPY,
	}
	
	/**
	 * Static usage.
	 */
	enum Static {
		/**
		 * The contents of the data memory is determined once by the application 
		 * and often used as a source for a GL rendering command.
		 */
		Draw = GL_STATIC_DRAW,
		/**
		 * The contents of the data memory is determined once for reading data 
		 * and often queried by the application.
		 */
		Read = GL_STATIC_READ,
		/**
		 * The contents of the data memory is determined once for reading data 
		 * and often used as a source for a GL rendering command.
		 */
		Copy = GL_STATIC_COPY,
	}
	
	/**
	 * Dynamic usage.
	 */
	enum Dynamic {
		/**
		 * The contents of the data memory is repeatedly determined by the application
		 * and often used as a source for a GL rendering command.
		 */
		Draw = GL_DYNAMIC_DRAW,
		/**
		 * The content of the data memory is repeatedly set for reading out data 
		 * and frequently requested by the application.
		 */
		Read = GL_DYNAMIC_READ,
		/**
		 * The contents of the data memory is set repeatedly for reading data 
		 * and often used as a source for a GL rendering command.
		 */
		Copy = GL_DYNAMIC_COPY,
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
	
public:
	const Type type;
	const Target targets;
	
private:
	GLuint[3] _vboId;
	
	Target _curTarget;
	
	const ubyte _targetNums;
	const ubyte[Target] _targetIds;
	
	bool[Target] _dataAssigned;
	
public:
	/**
	 * CTor
	 */
	this(Target trg, Type type = Type.Array) {
		if (trg == Target.None)
			throw new Exception("Invalid target.");
		
		this.type = type;
		this.targets = trg;
		
		ubyte num = 0;
		if (Target.Vertex & trg)
			this._targetIds[Target.Vertex] = num++;
		if (Target.Color & trg)
			this._targetIds[Target.Color] = num++;
		if (Target.TexCoords & trg)
			this._targetIds[Target.TexCoords] = num++;
		
		this._targetNums = num;
		this._curTarget = Target.None;
		
		glGenBuffers(num, &this._vboId[0]);
		
		foreach (Target id, _; this._targetIds) {
			this.bind(id);
			
			this._dataAssigned[id] = false;
		}
	}
	
	/**
	 * Binds the a specific VBO Target.
	 * Now the specific VBO can be used.
	 * 
	 * See: Target enum
	 */
	void bind(Target trg) {
		if (!(trg & this.targets))
			throw new Exception(to!string(trg) ~ " is not a valid target of this buffer");
		
		this._curTarget = trg;
		
		ubyte id = this._targetIds[trg];
		glBindBuffer(this.type, this._vboId[id]);
	}
	
	/**
	 * Returns the current Target
	 * 
	 * See: Target enum
	 */
	Target getBound() const pure nothrow {
		return this._curTarget;
	}
	
	/**
	 * Returns if some Target is currently bound
	 */
	bool isSomethingBound() const pure nothrow {
		return this._curTarget != Target.None;
	}
	
	/**
	 * Checks whether the current buffer has already content, or not
	 */
	bool isEmpty() const pure nothrow {
		return this._dataAssigned[this._curTarget] == false;
	}
	
	/**
	 * Reset the current buffer state
	 * 
	 * See: isEmpty
	 */
	void deplete() {
		this._dataAssigned[this._curTarget] = false;
	}
	
	/**
	 * Unbind the current VBO.
	 */
	void unbind() {
		this._curTarget = Target.None;
		
		glBindBuffer(this.type, 0);
	}
	
	/**
	 * Stores data in the current VBO.
	 * 
	 * See: glBufferData
	 */
	void cache(const void* ptr, size_t totalSize, uint usage = Static.Draw) {
		this._dataAssigned[this._curTarget] = true;
		
		ubyte id = this._targetIds[this._curTarget];
		
		glBufferData(this.type, totalSize, ptr, usage);
	}
	
	/**
	 * Stores vertex data
	 */
	void cache(const Vertex[] vertices, uint usage = Static.Draw) {
		const size_t len = vertices[0].data.length;
		
		this.cache(&vertices[0], len * vertices.length * float.sizeof, usage);
	}
	
	/**
	 * Modify existing buffer data
	 * 
	 * See: glBufferSubData
	 */
	void modify(const void* ptr, size_t totalSize, size_t offset = 0) const {
		glBufferSubData(this.type, offset, totalSize, ptr); 
	}
	
	/**
	 * The internal buffer memory is transferred to the memory of the client
	 * with a specific access.
	 * Before the buffer can be reused, <code>unmap</code> must be called.
	 * 
	 * See: Access enum
	 * See: glMapBuffer
	 */
	void* map(Access access) const {
		return glMapBuffer(this.type, access);
	}
	
	/**
	 * Allows other commands buffer access, in which it retrieves the memory from the client.
	 * 
	 * See: map method
	 */
	void unmap() const {
		glUnmapBuffer(this.type);
	}
	
	/**
	 * Points to the current VBO with a specific Target.
	 * 
	 * See: glVertexPointer
	 * See: glColorPointer
	 * See: glTexCoordPointer
	 * See: Target enum.
	 */
	void pointTo(Target trg) {
		this.bind(trg);
		this.enableState(trg);
		
		switch (trg) {
			case Target.None:
				assert(0, "Invalid Target");
			case Target.Vertex:
				glVertexPointer(3, GL_FLOAT, 0, null);
				break;
			case Target.Color:
				glColorPointer(4, GL_FLOAT, 0, null);
				break;
			case Target.TexCoords:
				glTexCoordPointer(2, GL_FLOAT, 0, null);
				break;
			default:
				assert(0, "Point to can only handle *one* pointer target.");
		}
	}
	
	/**
	 * Enable a specific client state (with glEnableClientState)
	 * like GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	 * with the corresponding Target.
	 */
	void enableState(Target trg) {
		if (trg & Target.None)
			assert(0, "Invalid Target");
		
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
	void enableAllStates() {
		this.enableState(Target.Vertex | Target.Color | Target.TexCoords);
	}
	
	/**
	 * Disable all client states
	 */
	void disableAllStates() {
		this.disableState(Target.Vertex | Target.Color | Target.TexCoords);
	}
	
	/**
	 * Disable a specific client state (with glDisableClientState)
	 */
	void disableState(Target trg) {
		if (trg & Target.None)
			assert(0, "Invalid Target");
		
		if (trg & Target.Vertex)
			glDisableClientState(GL_VERTEX_ARRAY);
		if (trg & Target.Color)
			glDisableClientState(GL_COLOR_ARRAY);
		if (trg & Target.TexCoords)
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices.
	 */
	void drawArrays(GLenum type, size_t count) const {
		glDrawArrays(type, 0, count);
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices and indices for the correct index per vertex.
	 */
	void drawElements(GLenum type, size_t count, int[] indices) const {
		if (indices.length == 0)
			return;
		
		glDrawElements(type, count, GL_UNSIGNED_INT, &indices[0]); 
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices and indices for the correct index per vertex.
	 */
	void drawRangeElements(GLenum type, size_t count, int[] indices) const {
		if (indices.length == 0)
			return;
		
		glDrawRangeElements(
			type,
			0,
			indices.length,
			count,
			GL_UNSIGNED_INT,
			&indices[0]);
	}
}