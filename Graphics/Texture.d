module Dgame.Graphics.Texture;

private {
	debug import std.stdio : writefln, writeln;
	
	import derelict.opengl3.gl;
	
	import Dgame.Math.Rect;
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Template.Blendable;
	import Dgame.System.VertexRenderer;
}

public import Dgame.Graphics.Template.Blendable : BlendMode;

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

private GLuint*[] _TexFinalizer;

static ~this() {
	debug writefln("Finalize Texture (%d)", _TexFinalizer.length);
	
	for (size_t i = 0; i < _TexFinalizer.length; i++) {
		if (_TexFinalizer[i] && *_TexFinalizer[i] != 0) {
			debug writefln(" -> Texture finalized: %d", i);
			
			glDeleteTextures(1, _TexFinalizer[i]);
		}
	}
	
	_TexFinalizer = null;
	
	debug writeln(" >> Texture Finalized");
}

package struct Render {
public:
	enum Mode {
		Normal,
		Reverse
	}

	const ShortRect* dest;
	const ShortRect* viewport;

	const Mode mode;

	@disable
	this();

	this(const ShortRect* dest, const ShortRect* viewport, Mode mode = Mode.Normal) {
		this.dest = dest;
		this.viewport = viewport;
		this.mode = mode;
	}
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
		None  = 0, /** Take this if you want to declare that you give no Format. */
		RGB   = GL_RGB,		/** Alias for GL_RGB */
		RGBA  = GL_RGBA,	/** Alias for GL_RGBA */
		BGR   = GL_BGR,		/** Alias for GL_BGR */
		BGRA  = GL_BGRA,	/** Alias for GL_BGRA */
		Alpha = GL_ALPHA,	/** Alias for GL_ALPHA */
		Luminance = GL_LUMINANCE, /** Alias for GL_LUMINANCE */
		LuminanceAlpha = GL_LUMINANCE_ALPHA /** Alias for GL_LUMINANCE_ALPHA */
	}

private:
	GLuint _texId;
	
	ushort _width, _height;
	ubyte _depth;
	
	bool _isSmooth;
	bool _isRepeated;
	
	Format _format;
	
package:
	void _render(const Render* render) const {
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);

		float tx = 0f;
		float ty = 0f;
		float tw = 1f;
		float th = 1f;

		if (render !is null && render.viewport !is null) {
			tx = (0f + render.viewport.x) / this._width;
			ty = (0f + render.viewport.y) / this._height;
			tw = (0f + render.viewport.width) / this._width;
			th = (0f + render.viewport.height) / this._height;
		}

		glPushAttrib(GL_CURRENT_BIT | GL_COLOR_BUFFER_BIT);
		scope(exit) glPopAttrib();

		// apply blending
		this._applyBlending();

		const Render.Mode mode = render !is null ? render.mode : Render.Mode.Normal;

		float[8] texCoords = void;
		final switch (mode) {
			case Render.Mode.Normal:
				texCoords = [tx,      ty,
							 tx + tw, ty,
							 tx + tw, ty + th,
							 tx,      ty + th];
				break;
			case Render.Mode.Reverse:
				texCoords = [tx,      ty + th,
							 tx + tw, ty + th,
							 tx + tw, ty,
							 tx,      ty];
				break;
		}

		float dx = 0f;
		float dy = 0f;
		float dw = this._width;
		float dh = this._height;

		if (render !is null && render.dest !is null) {
			dx = render.dest.x;
			dy = render.dest.y;
			dw = render.dest.width;
			dh = render.dest.height;
		}

		float[12] vertices = [dx,	   dy,      0f,
							  dx + dw, dy,      0f,
							  dx + dw, dy + dh, 0f,
							  dx,      dy + dh, 0f];

		VertexRenderer.pointTo(Primitive.Target.Vertex, &vertices[0]);
		VertexRenderer.pointTo(Primitive.Target.TexCoords, &texCoords[0]);

		scope(exit) {
			VertexRenderer.disableAllStates();

			this.unbind();
		}

		this.bind();

		VertexRenderer.drawArrays(Primitive.Type.Quad, vertices.length);
	}

	void _render(ref const Render render) const {
		this._render(&render);
	}

	void _render(const Render render) const {
		this._render(&render);
	}
	
public:
	/// mixin blendable functionality
	mixin TplBlendable;
	
final:
	/**
	 * CTor
	 */
	this() {
		glGenTextures(1, &this._texId);
		
		_TexFinalizer ~= &this._texId;
		
		this.bind();
	}

	this(GLuint t_id, ushort width, ushort height, ubyte depth, Format t_fmt = Format.None) {
		assert(depth != 0 || t_fmt != Format.None);

		this._texId = t_id;

		this._width  = width;
		this._height = height;
		this._depth  = depth == 0 ? formatToBits(t_fmt) : depth;
		this._format = t_fmt == Format.None ? bitsToFormat(depth) : t_fmt;

		this._isSmooth = false;
		this._isRepeated = false;
	}
	
	/**
	 * Postblit
	 */
	this(ref const Texture tex, Format t_fmt = Format.None) {
		this.loadFromMemory(tex.getMemory(),
		                    tex.width, tex.height, tex.depth,
		                    t_fmt ? t_fmt : tex.getFormat());
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
	@property
	GLuint Id() const pure nothrow {
		return this._texId;
	}

	/**
	 * Returns if the texture is used.
	 */
	bool isValid() const pure nothrow {
		return this._texId != 0;
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
	 * Set smooth filter for the (next) load.
	 */
	void setSmooth(bool enable) {
		this._isSmooth = enable;
	}
	
	/**
	 * Returns if smooth filter are activated.
	 */
	bool isSmooth() const pure nothrow {
		return this._isSmooth;
	}
	
	/**
	 * Set repeating for the (next) load.
	 **/
	void setRepeat(bool repeat) {
		if (repeat != this._isRepeated) {
			this._isRepeated = repeat;

			if (this._texId != 0) {
				this.bind();

				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
								this._isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
				glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
								this._isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
			}
		}
	}
	
	/**
	 * Returns if repeating is enabled.
	 */
	bool isRepeated() const pure nothrow {
		return this._isRepeated;
	}
	
	/**
	 * Load from memory.
	 */
	void loadFromMemory(void* memory, ushort width, ushort height,
						ubyte depth, Format fmt = Format.None)
	in {
		assert(width != 0 && height != 0, "Width and height cannot be 0.");
	} body {
		/// Possible speedup because 'glTexSubImage2D'
		/// is often faster than 'glTexImage2D'.
		if (width == this.width && height == this.height) {
			if (!fmt || fmt == this._format) {
				this.updateMemory(memory, null);
				
				return;
			}
		}
		
		this._format = !fmt ? bitsToFormat(depth) : fmt;
		assert(this._format != Format.None, "Missing format.");

		this.bind();
		
		glTexImage2D(GL_TEXTURE_2D, 0, depth / 8, width, height, 0, this._format, GL_UNSIGNED_BYTE, memory);
		glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, true);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
		                this._isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
		                this._isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
		                this._isSmooth ? GL_LINEAR : GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
		                this._isSmooth ? GL_LINEAR : GL_NEAREST);
		
		this._width  = width;
		this._height = height;
		this._depth  = depth;
	}
	
	/**
	 * Set a colorkey.
	 */
	void setColorkey(ref const Color colorkey) {
		// Get the pixel memory
		void* memory = this.getMemory();
		assert(memory !is null);

		if (this._depth < 8)
			return;

		const uint size = this._width * this._height * (this._depth / 8);
		// Go through pixels
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
	 * Note: This method <b>allocates</b> GC memory.
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
		
		//		GLuint previous_texture = Texture.currentlyBound();
		//		scope(exit) Texture._reBind(previous_texture);
		
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
		
		//		GLuint previous_texture = Texture.currentlyBound();
		//		scope(exit) Texture._reBind(previous_texture);
		
		Texture tex = new Texture();
		debug writeln("Format switch: ", .switchFormat(this._format, true));
		tex.loadFromMemory(null, rect.width, rect.height,
		                   this._depth, this._format.switchFormat(true));
		
		int[4] vport;
		glGetIntegerv(GL_VIEWPORT, &vport[0]);
		
		glPushAttrib(GL_VIEWPORT_BIT);
		scope(exit) glPopAttrib();
		
		glViewport(0, 0, rect.width, rect.height);
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		const ShortRect dest = ShortRect(0, 0, cast(ushort) vport[2], cast(ushort) vport[3]);
		this._render(Render(&dest, &rect, Render.Mode.Reverse));
		
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
	void copy(const Texture tex, const ShortRect* rect = null) in {
		assert(tex !is null, "Cannot copy null Texture.");
		assert(this._width != 0 && this._height != 0, "width or height is 0.");
	} body {
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
		
		const ShortRect dest = ShortRect(0, 0, cast(ushort) vport[2], cast(ushort) vport[3]);
		tex._render(Render(&dest, rect, Render.Mode.Reverse));
		
		this.bind();
		
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, rx, ry, 0, 0, rw, rh);
	}
	
	/**
	 * Update the pixel data of this Texture.
	 * The second parameter is a pointer to the area which is updated.
	 * If it is null (default) the whole Texture will be updated.
	 * The third parameter is the format of the pixels.
	 */
	void updateMemory(const void* memory, const ShortRect* rect = null,
	                  Format fmt = Format.None)
	in {
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
		
		//		GLuint previous_texture = Texture.currentlyBound();
		//		scope(exit) Texture._reBind(previous_texture);
		
		this.bind();
		
		glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height,
		                (fmt == Format.None ? this._format : fmt),
		                GL_UNSIGNED_BYTE, memory);
	}
}