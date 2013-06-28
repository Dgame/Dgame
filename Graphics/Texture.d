module Dgame.Graphics.Texture;

private {
	debug import std.stdio;
	
	import derelict.opengl3.gl;
	
	import Dgame.Math.Rect;
	import Dgame.Graphics.Color;
}

public import Dgame.Graphics.Interface.Blendable;

/**
 * Format a Texture.Format into the related bit count.
 * If the format is not supported, it returns 0.
 *
 * Examples:
 * ---
 * assert(formatToBits(Texture.Format.RGBA) == 32);
 * assert(formatToBits(Texture.Format.RGB) == 24);
 * assert(formatToBits(Texture.Format.BGRA) == 32);
 * assert(formatToBits(Texture.Format.BGR) == 24);
 * ---
 */
ubyte formatToBits(Texture.Format fmt) pure {
	switch (fmt) {
		case Texture.Format.RGB:
		case Texture.Format.BGR:
			return 24;
		case Texture.Format.RGBA:
		case Texture.Format.BGRA:
			return 32;
		default: return 0;
	}
} unittest {
	assert(Texture.Format.RGB.formatToBits() == 24);
	assert(Texture.Format.BGR.formatToBits() == 24);
	assert(Texture.Format.RGBA.formatToBits() == 32);
	assert(Texture.Format.BGRA.formatToBits() == 32);
}

/**
 * Format a bit count into the related Texture.Format.
 * If no bit count is supported, it returns Texture.Format.None.
 *
 * Examples:
 * ---
 * assert(bitsToFormat(32) == Texture.Format.RGBA);
 * assert(bitsToFormat(24) == Texture.Format.RGB);
 * assert(bitsToFormat(32, true) == Texture.Format.BGRA);
 * assert(bitsToFormat(24, true) == Texture.Format.BGR);
 * ---
 */
Texture.Format bitsToFormat(ubyte bits, bool reverse = false) pure {
	switch (bits) {
		case 32: return !reverse ? Texture.Format.RGBA : Texture.Format.BGRA;
		case 24: return !reverse ? Texture.Format.RGB : Texture.Format.BGR;
		default: return Texture.Format.None;
	}
} unittest {
	assert(bitsToFormat(24) == Texture.Format.RGB);
	assert(bitsToFormat(32) == Texture.Format.RGBA);
	assert(bitsToFormat(24, true) == Texture.Format.BGR);
	assert(bitsToFormat(32, true) == Texture.Format.BGRA);
}

/**
 * Switch/Reverse Texture.Format.
 *
 * Examples:
 * ---
 * assert(switchFormat(Texture.Format.RGB) == Texture.Format.BGR);
 * assert(switchFormat(Texture.Format.RGB, true) == Texture.Format.BGRA);
 * assert(switchFormat(Texture.Format.RGBA) == Texture.Format.BGRA);
 * assert(switchFormat(Texture.Format.RGBA, true) == Texture.Format.BGRA);
 * ---
 */
Texture.Format switchFormat(Texture.Format fmt, bool alpha = false) pure {
	switch (fmt) {
		case Texture.Format.RGB:
			if (alpha) goto case Texture.Format.RGBA;
			return Texture.Format.BGR;
		case Texture.Format.BGR:
			if (alpha) goto case Texture.Format.BGRA;
			return Texture.Format.RGB;
		case Texture.Format.RGBA: return Texture.Format.BGRA;
		case Texture.Format.BGRA: return Texture.Format.RGBA;
		default: return fmt;
	}
}

private GLuint*[] _finalizer;

void _finalizeTexture() {
	debug writefln("Finalize Texture (%d)", _finalizer.length);
	
	for (uint i = 0; i < _finalizer.length; i++) {
		if (_finalizer[i] && *_finalizer[i] != 0) {
			debug writefln(" -> Texture finalized: %d", i);
			
			glDeleteTextures(1, _finalizer[i]);
			
			*_finalizer[i] = 0;
		}
	}
	
	_finalizer = null;
	
	debug writeln(" >> Texture Finalized");
}

/**
 * A Texture is a 2 dimensional pixel reprasentation.
 * It is a wrapper of an OpenGL Texture.
 *
 * Author: rschuett
 */
class Texture : Blendable {
public:
	/**
	 * Supported Texture Format
	 */
	enum Format {
		RGB   = GL_RGB,		/** Alias for GL_RGB */
		RGBA  = GL_RGBA,	/** Alias for GL_RGBA */
		BGR   = GL_BGR,		/** Alias for GL_BGR */
		BGRA  = GL_BGRA,	/** Alias for GL_BGRA */
		Alpha = GL_ALPHA,	/** Alias for GL_ALPHA */
		Luminance = GL_LUMINANCE, /** Alias for GL_LUMINANCE */
		LuminanceAlpha = GL_LUMINANCE_ALPHA, /** Alias for GL_LUMINANCE_ALPHA */
		None /** Take this if you want to declare that you give no Format. */
	}
	
private:
	GLuint _texId;
	
	ushort _width, _height;
	ubyte _depth;
	
	bool _smoothEnabled;
	bool _hasMemory;
	
	Format _format;
	
	FloatRect _viewport;
	
private:
	enum RenderMode {
		Normal,
		Reverse
	}
	
	static void _reBind(GLuint previousTexId) {
		glBindTexture(GL_TEXTURE_2D, previousTexId);
	}
	
package:
	void _render(ref const ShortRect dst, RenderMode mode = RenderMode.Normal) const {
		GLuint previous_texture = Texture.currentlyBound();
		scope(exit) Texture._reBind(previous_texture);
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		float tx = 0f;
		float ty = 0f;
		float tw = 1f;
		float th = 1f;
		
		if (this.hasViewport()) {
			tx = this._viewport.x / this._width;
			ty = this._viewport.y / this._height;
			tw = this._viewport.width / this._width;
			th = this._viewport.height / this._height;
		}
		
		this.bind();
		
		// |GL_CURRENT_BIT -> if we use glColor4f instead of glBlendColor in Blendable
		glPushAttrib(GL_COLOR_BUFFER_BIT);
		scope(exit) glPopAttrib();
		
		// use blending
		this._processBlendMode();
		
		final switch (mode) {
			case RenderMode.Normal:
				glBegin(GL_QUADS);
				glTexCoord2f(tx, ty);			glVertex2f(dst.x, dst.y);
				glTexCoord2f(tx + tw, ty);		glVertex2f(dst.x + dst.width, dst.y);
				glTexCoord2f(tx + tw, ty + th); glVertex2f(dst.x + dst.width, dst.y + dst.height);
				glTexCoord2f(tx, ty + th);		glVertex2f(dst.x, dst.y + dst.height);
				glEnd();
				break;
			case RenderMode.Reverse:
				glBegin(GL_QUADS);
				glTexCoord2f(tx, ty + th);		glVertex2f(dst.x, dst.y);
				glTexCoord2f(tx + tw, ty + th);	glVertex2f(dst.x + dst.width, dst.y);
				glTexCoord2f(tx + tw, ty);		glVertex2f(dst.x + dst.width, dst.y + dst.height);
				glTexCoord2f(tx, ty);			glVertex2f(dst.x, dst.y + dst.height);
				glEnd();
				break;
		}
	}
	
	/**
	 * Rvalue version
	 */
	void _render(const ShortRect dst, RenderMode mode = RenderMode.Normal) const {
		this._render(dst, mode);
	}
	
public:
	/// mixin blendable functionality
	mixin TBlendable;
	
final:
	
	/**
	 * CTor
	 */
	this() {
		glGenTextures(1, &this._texId);
		
		_finalizer ~= &this._texId;
		
		this.bind();
	}
	
	/**
	 * Postblit
	 */
	this(ref const Texture tex) {
		this.loadFromMemory(tex.getMemory(), tex.width, tex.height, tex.depth, tex.getFormat());
	}
	
	/**
	 * DTor
	 */
	~this() {
		this.free();
	}
	
	/**
	 * Free / Delete the Texture & Memory
	 * After this call, the Pixel data is invalid.
	 */
	void free() {
		if (this._texId != 0) {
			debug writeln("Destroy texture");
			glDeleteTextures(1, &this._texId);
			
			this._texId = 0;
			this._format = Format.None;
		}
	}
	
	/**
	 * Returns the currently bound texture id.
	 */
	static GLint currentlyBound() {
		GLint current;
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &current);
		
		return current;
	}
	
	/**
	 * Returns the Texture Id.
	 */
	GLuint getId() const pure nothrow {
		return this._texId;
	}
	
	/**
	 * Returns the width of this Texture
	 */
	@property
	ushort width() const pure nothrow {
		return this._width;
	}
	
	/**
	 * Returns the height of this Texture.
	 */
	@property
	ushort height() const pure nothrow {
		return this._height;
	}
	
	/**
	 * Returns the depth. May often 24 or 32.
	 */
	@property
	ubyte depth() const pure nothrow {
		return this._depth;
	}
	
	/**
	 * Returns the Format.
	 *
	 * See: Format enum.
	 */
	Format getFormat() const pure nothrow {
		return this._format;
	}
	
	/**
	 * Binds this Texture.
	 * Means this Texture is now activated.
	 */
	void bind() const {
		glBindTexture(GL_TEXTURE_2D, this._texId);
	}
	
	/**
	 * Binds this Texture.
	 * Means this Texture is now deactivated.
	 */
	void unbind() const {
		glBindTexture(GL_TEXTURE_2D, 0);
	}
	
	/**
	 * Returns true, if this Texture is currently activated.
	 */
	bool isCurrentlyBound() const {
		return Texture.currentlyBound() == this._texId;
	}
	
	/**
	 * Enable smothing texture filter by the next load.
	 */
	void enableSmooth(bool enable) {
		this._smoothEnabled = enable;
	}
	
	/**
	 * Check if smoth texture filter are activated.
	 */
	bool hasSmooth() const pure nothrow {
		return this._smoothEnabled;
	}
	
	/**
	 * Check if this Texture has a Viewport.
	 */
	bool hasViewport() const {
		return !this._viewport.isEmpty();
	}
	
	/**
	 * Set a Viewport to this Texture.
	 * A Viewport is a ClipRect that is shorter as the whole Texture.
	 * If this Texture is drawn only the specific Viewport will be drawn.
	 */
	void setViewport(ref const FloatRect viewport) {
		this._viewport = viewport;
	}
	
	/**
	 * Rvalue version
	 */
	void setViewport(const FloatRect viewport) {
		this.setViewport(viewport);
	}
	
	/**
	 * Remove/Collapse the current Viewport.
	 */
	void unsetViewport() {
		this._viewport.collapse();
	}
	
	/**
	 * Get const access to the current Viewport.
	 */
	ref const(FloatRect) getViewport() const pure nothrow {
		return this._viewport;
	}
	
	/**
	 * Get mutable access to the current Viewport.
	 */
	inout(FloatRect)* fetchViewport() inout {
		return &this._viewport;
	}
	
	/**
	 * Link this Texture to another.
	 * This Texture points now to the other Texture and his data.
	 */
	void link(const Texture tex) {
		this._texId = tex.getId();
		
		this._format = tex.getFormat();
		this._width  = tex.width;
		this._height = tex.height;
		this._depth  = tex.depth;
		//this.bind();
	}
	
	/**
	 * Returns a new Texture object which rested partial of these Texture.
	 * If you pass as second parameter true, the whole Texture will be copied
	 * with the postblit CTor and then a viewport is set.
	 * If you pass false (default), nothing is copied, but the new Object points (link)
	 * to these. Then a viewport is set also.
	 *
	 * See: postblit CTor
	 * See: link
	 */
	Texture partial(ref const FloatRect viewport, bool copy = false) const {
		if (!copy) {
			Texture tex = new Texture();
			tex.link(this);
			tex.setViewport(viewport);
			
			return tex;
		}
		
		Texture tex = new Texture(this);
		tex.setViewport(viewport);
		
		return tex;
	}
	
	/**
	 * Rvalue version
	 */
	Texture partial(const FloatRect viewport, bool copy = false) const {
		return this.partial(viewport, copy);
	}
	
	/**
	 * Load from memory.
	 */
	void loadFromMemory(void* memory, ushort width, ushort height, ubyte depth = 32, Format fmt = Format.None) in {
		assert(width != 0 && height != 0, "Width and height cannot be 0.");
	} body {
		/// Possible speedup because 'glTexSubImage2D' is often faster than 'glTexImage2D'.
		if (this._hasMemory && width == this.width && height == this.height) {
			if (fmt == Format.None || fmt == this._format) {
				this.updateMemory(memory, null);
				
				return;
			}
		}
		
		this._format = (fmt == Format.None) ? bitsToFormat(depth) : fmt;
		assert(this._format != Format.None, "Missing format.");
		
		GLuint previous_texture = Texture.currentlyBound();
		scope(exit) Texture._reBind(previous_texture);
		
		this.bind();
		
		glTexImage2D(GL_TEXTURE_2D, 0, depth / 8, width, height, 0, this._format, GL_UNSIGNED_BYTE, memory);
		
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, true);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, this._smoothEnabled ? GL_LINEAR : GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, this._smoothEnabled ? GL_LINEAR : GL_NEAREST);
		
		this._width  = width;
		this._height = height;
		this._depth  = depth;
		
		this._hasMemory = true;
	}
	
	/**
	 * Load from memory with a colorkey.
	 */
	void setColorkey(ref const Color colorkey) {
		// Go through pixels
		void* memory = this.getMemory();
		scope(exit) delete memory;
		
		uint size = this._width * this._height;
		for (uint i = 0; i < size; ++i) {
			// Get pixel colors
			ubyte* colors = cast(ubyte*) &memory[i];
			
			// Color matches
			if (colors[0] == colorkey.red
			    && colors[1] == colorkey.green
			    && colors[2] == colorkey.blue
			    && (0 == colorkey.alpha || colors[3] == colorkey.alpha))
			{
				// Make transparent
				colors[0] = 255;
				colors[1] = 255;
				colors[2] = 255;
				colors[3] = 0;
			}
		}
		
		this.updateMemory(memory);
	}
	
	/**
	 * Rvalue version
	 */
	void setColorkey(const Color colorkey) {
		this.setColorkey(colorkey);
	}
	
	/**
	 * Returns the pixel of this Texture or null if this Texture isn't valid.
	 *
	 * Note: This method <b>allocates</b> memory.
	 */
	void* getMemory() const {
		if (this._format == Format.None
		    || (this._depth < 24 || this._height == 0 || this._width == 0)) 
		{
			debug writeln("@Texture.GetPixels: Null Pixel");
			return null;
		}
		
		const uint msize = this._width * this._height * (this._depth / 8);
		void[] memory = new void[msize];
		
		GLuint previous_texture = Texture.currentlyBound();
		scope(exit) Texture._reBind(previous_texture);
		
		this.bind();
		
		glGetTexImage(GL_TEXTURE_2D, 0, this._format, GL_UNSIGNED_BYTE, memory.ptr);
		
		return memory.ptr;
	}
	
	/**
	 * Returns a subTexture of this Texture.
	 * This isn't similar to partial.
	 */
	Texture subTexture(ref const ShortRect rect) {
		if (this._format == Format.None)
			return null;
		
		GLuint previous_texture = Texture.currentlyBound();
		scope(exit) Texture._reBind(previous_texture);
		
		Texture tex = new Texture();
		debug writeln("Format switch: ", .switchFormat(this._format, true));
		tex.loadFromMemory(null, rect.width, rect.height, this._depth, this._format.switchFormat(true));
		
		int[4] vport;
		glGetIntegerv(GL_VIEWPORT, &vport[0]);
		
		glPushAttrib(GL_VIEWPORT_BIT);
		scope(exit) glPopAttrib();
		
		FloatRect tex_viewport = this._viewport;
		this.setViewport(cast(FloatRect) rect);
		scope(exit) this.setViewport(tex_viewport);
		
		glViewport(0, 0, rect.width, rect.height);
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		this._render(ShortRect(0, 0, cast(ushort) vport[2], cast(ushort) vport[3]),
		             RenderMode.Reverse);
		
		tex.bind();
		
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, rect.width, rect.height);
		
		return tex;
	}
	
	/**
	 * Rvalue version
	 */
	Texture subTexture(const ShortRect rect) {
		return this.subTexture(rect);
	}
	
	/**
	 * Copy another Texture to this.
	 * The second parameter is a pointer to the destination rect.
	 * Is it is null this means the whole tex is copied.
	 */
	void copy(const Texture tex, ShortRect* rect = null)
	in {
		assert(tex !is null, "Cannot copy null Texture.");
		assert(this._width != 0 && this._height != 0, "width or height is 0.");
	} body {
		GLuint previous_texture = Texture.currentlyBound();
		scope(exit) Texture._reBind(previous_texture);
		
		short rx = 0, ry = 0;
		ushort rw = tex.width, rh = tex.height;
		
		if (rect !is null) {
			rx = rect.x;
			ry = rect.y;
			rw = rect.width;
			rh = rect.height;
		}
		
		int[4] vport;
		glGetIntegerv(GL_VIEWPORT, &vport[0]);
		
		///
		glPushAttrib(GL_VIEWPORT_BIT);
		scope(exit) glPopAttrib();
		
		glViewport(0, 0, rw, rh);
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		tex._render(ShortRect(0, 0, cast(ushort) vport[2], cast(ushort) vport[3]), RenderMode.Reverse);
		
		this.bind();
		
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, rx, ry, 0, 0, rw, rh);
	}
	
	/**
	 * Update the pixel data of this Texture.
	 * The second parameter is a pointer to the area which is updated.
	 * If it is null (default) the whole Texture will be updated.
	 * The third parameter is the format of the pixels.
	 */
	void updateMemory(const void* memory, ShortRect* rect = null, Format fmt = Format.None) in {
		assert(memory !is null, "Pixels is null.");
		assert(this._width != 0 && this._height != 0, "width or height is 0.");
	} body {
		ushort width, height;
		short x, y;
		
		if (rect !is null) {
			assert(rect.width <= this._width && rect.height <= this._height, 
			       "Rect is greater as the Texture.");
			assert(rect.x < this._width && rect.y < this._height, 
			       "x or y of the Rect is greater as the Texture.");
			
			width  = rect.width;
			height = rect.height;
			
			x = rect.x;
			y = rect.y;
		} else {
			width  = this._width;
			height = this._height;
			
			x = y = 0;
		}
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		GLuint previous_texture = Texture.currentlyBound();
		scope(exit) Texture._reBind(previous_texture);
		
		this.bind();
		
		glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height,
		                (fmt == Format.None ? this._format : fmt),
		                GL_UNSIGNED_BYTE, memory);
	}
}