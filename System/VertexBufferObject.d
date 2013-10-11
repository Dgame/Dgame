module Dgame.System.VertexBufferObject;

private {
	import std.conv : to;
	
	import derelict.opengl3.gl;
	
	import Dgame.Core.core;
	import Dgame.Graphics.Texture;
}

/// package import of VertexRenderer
package import Dgame.System.VertexRenderer;

/**
 * Usage methods
 */
final abstract class Usage {
public:
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
}

/**
 * Buffer is a object oriented wrapper for a Vertex Buffer Object.
 * VertexRenderer is public imported. See there for more details, like PointerTarget.
 *
 * Author: rschuett
 */
final class VertexBufferObject {
public:
	/**
	 * The access type.
	 */
	enum Access {
		Read  = GL_READ_ONLY,	/** Read only. */
		Write = GL_WRITE_ONLY,	/** Write only. */
		ReadWrite = GL_READ_WRITE /** Read and write. */
	}
	
	/**
	 * Declare which Buffer Type is stored.
	 */
	enum Type {
		/** The currently bound buffer object stores vertex array data. */
		Array = GL_ARRAY_BUFFER,
		/** The currently bound buffer object stores index values ​​for vertex arrays. */
		Element = GL_ELEMENT_ARRAY_BUFFER
	}
	
public:
	const Type type;
	const Primitive.Target targets;
	
private:
	uint[3] _vboId;
	
	Primitive.Target _curTarget;
	
	const ubyte _targetNums;
	const ubyte[Primitive.Target] _targetIds;
	
	bool[Primitive.Target] _dataAssigned;
	
public:
	/**
	 * CTor
	 */
	this(Primitive.Target trg, Type type = Type.Array) {
		if (trg == Primitive.Target.None)
			throw new Exception("Invalid PointerTarget.");
		
		this.type = type;
		this.targets = trg;
		
		ubyte num = 0;
		if (Primitive.Target.Vertex & trg)
			this._targetIds[Primitive.Target.Vertex] = num++;
		if (Primitive.Target.Color & trg)
			this._targetIds[Primitive.Target.Color] = num++;
		if (Primitive.Target.TexCoords & trg)
			this._targetIds[Primitive.Target.TexCoords] = num++;
		
		this._targetNums = num;
		this._curTarget = Primitive.Target.None;
		
		glGenBuffers(num, &this._vboId[0]);
		
		foreach (Primitive.Target id, _; this._targetIds) {
			this.bind(id);
			
			this._dataAssigned[id] = false;
		}
		
		this.unbind();
	}
	
	/**
	 * Binds the a specific VBO PointerTarget.
	 * If the target is invalid (because no such buffer exist)
	 * nothing happens.
	 * 
	 * See: PointerTarget enum
	 */
	void bind(Primitive.Target trg) {
		if ((trg & this.targets) == 0)
			return;
		
		this._curTarget = trg;
		
		ubyte id = this._targetIds[trg];
		glBindBuffer(this.type, this._vboId[id]);
	}
	
	/**
	 * Unbind the current VBO.
	 */
	void unbind() {
		this._curTarget = Primitive.Target.None;
		
		glBindBuffer(this.type, 0);
	}
	
	/**
	 * Returns the current PointerTarget
	 * 
	 * See: PointerTarget enum
	 */
	Primitive.Target getBound() const pure nothrow {
		return this._curTarget;
	}
	
	/**
	 * Returns if some PointerTarget is currently bound
	 */
	bool isSomethingBound() const pure nothrow {
		return this._curTarget != Primitive.Target.None;
	}
	
	/**
	 * Checks whether the current buffer has already content, or not
	 */
	bool isCurrentEmpty() const pure nothrow {
		if (!this.isSomethingBound())
			return false;
		
		return this._dataAssigned[this._curTarget] == false;
	}
	
	/**
	 * Checks whether a specific buffer has already content, or not.
	 * If the target is invalid (because no such buffer exist)
	 * an Exception is thrown.
	 */
	bool isEmpty(Primitive.Target trg) const {
		if ((trg & this.targets) == 0)
			throw new Exception(to!string(trg) ~ " is not a valid target of this buffer");
		
		return this._dataAssigned[trg] == false;
	}
	
	/**
	 * Reset the current buffer state
	 * 
	 * See: isEmpty
	 */
	void deplete() {
		if (!this.isSomethingBound())
			return;
		
		this._dataAssigned[this._curTarget] = false;
	}
	
	/**
	 * Reset all buffer states
	 * 
	 * See: isEmpty
	 */
	void depleteAll() {
		foreach (Primitive.Target id, _; this._targetIds) {
			this.bind(id);
			this.deplete();
		}
	}
	
	/**
	 * Stores data in the current VBO.
	 * 
	 * See: glBufferData
	 */
	void cache(const void* ptr, size_t totalSize, uint usage = Usage.Static.Draw) {
		this._dataAssigned[this._curTarget] = true;
		
		ubyte id = this._targetIds[this._curTarget];
		
		glBufferData(this.type, totalSize, ptr, usage);
	}
	
	/**
	 * Modify existing buffer data
	 * 
	 * See: glBufferSubData
	 */
	void modify(const void* ptr, size_t totalSize, uint offset = 0) const {
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
	 * Points to the current VBO with a specific PointerTarget.
	 * 
	 * See: glVertexPointer
	 * See: glColorPointer
	 * See: glTexCoordPointer
	 * See: PointerTarget enum.
	 */
	void pointTo(Primitive.Target trg, ubyte stride = 0, ubyte offset = 0) {
		this.bind(trg);
		
		VertexRenderer.pointTo(trg, null, stride, offset);
	}
	
	/**
	 * Enable a specific client state (with glEnableClientState)
	 * like GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	 * with the corresponding PointerTarget.
	 */
	void enableState(Primitive.Target trg) const {
		VertexRenderer.enableState(trg);
	}
	
	/**
	 * Enable all client states
	 */
	void enableAllStates() const {
		VertexRenderer.enableAllStates();
	}
	
	/**
	 * Disable all client states
	 */
	void disableAllStates() const {
		VertexRenderer.disableAllStates();
	}
	
	/**
	 * Disable a specific client state (with glDisableClientState)
	 */
	void disableState(Primitive.Target trg) const {
		VertexRenderer.disableState(trg);
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices.
	 */
	void drawArrays(Primitive.Type ptype, size_t count, uint start = 0) const {
		VertexRenderer.drawArrays(ptype, count, start);
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices and indices for the correct index per vertex.
	 */
	void drawElements(Primitive.Type ptype, size_t count, uint[] indices) const {
		VertexRenderer.drawElements(ptype, count, indices);
	}
	
	/**
	 * Draw shapes of the specific type from the current VBO data.
	 * It will use count vertices and indices for the correct index per vertex.
	 *
	 * Note: If start or end are -1 or below, 0 and indices.length are used.
	 */
	void drawRangeElements(Primitive.Type ptype, size_t count, uint[] indices, int start = -1, int end = -1) const {
		VertexRenderer.drawRangeElements(ptype, count, indices, start, end);
	}
	
	/**
	 * Bind a texture to this Buffer.
	 * It's a shortcut for:
	 * ----
	 * buf.pointTo(Primitive.Target.TexCoords);
	 * buf.pointTo(Primitive.Target.Vertex);
	 * 
	 * tex.bind();
	 * ----
	 * 
	 * Note: You should clean up with:
	 * tex.unbind(); and buf.disableAllStates();
	 */
	void bindTexture(const Texture tex) {
		this.pointTo(Primitive.Target.TexCoords);
		this.pointTo(Primitive.Target.Vertex);
		
		tex.bind();
	}
}