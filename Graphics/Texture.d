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
module Dgame.Graphics.Texture;

private {
	import std.exception : enforce;
	
	import derelict.opengl3.gl;
	
	import Dgame.Internal.Log;
	import Dgame.Math.Rect;
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Blend;
	import Dgame.Graphics.Shape;
	import Dgame.System.VertexRenderer;
}

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
ubyte formatToBits(Texture.Format fmt) pure nothrow {
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
Texture.Format bitsToFormat(ubyte bits, bool reverse = false) pure nothrow {
	switch (bits) {
		case 32: return !reverse ? Texture.Format.RGBA : Texture.Format.BGRA;
		case 24: return !reverse ? Texture.Format.RGB : Texture.Format.BGR;
		case 16: return Texture.Format.RGBA16;
		case  8: return Texture.Format.RGBA8;
		default: return Texture.Format.None;
	}
} unittest {
	assert(bitsToFormat(8) == Texture.Format.RGBA8);
	assert(bitsToFormat(16) == Texture.Format.RGBA16);
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
Texture.Format switchFormat(Texture.Format fmt, bool alpha = false) pure nothrow {
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

/**
 * Choose the right compress format for the given Texture.Format.
 *
 * See: Texture.Format enum
 */
Texture.Format compressFormat(Texture.Format fmt) pure nothrow {
	switch (fmt) {
		case Texture.Format.RGB:  return Texture.Format.CompressedRGB;
		case Texture.Format.RGBA: return Texture.Format.CompressedRGBA;
		case Texture.Format.CompressedRGB:
		case Texture.Format.CompressedRGBA:
			return fmt;
		default: return Texture.Format.None;
	}
}

private GLuint*[] _TexFinalizer;

static ~this() {
	debug Log.info("Finalize Texture (%d)", _TexFinalizer.length);
	
	for (size_t i = 0; i < _TexFinalizer.length; i++) {
		if (_TexFinalizer[i] && *_TexFinalizer[i] != 0) {
			debug Log.info(" -> Texture finalized: %d", i);
			
			glDeleteTextures(1, _TexFinalizer[i]);
		}
	}
	
	_TexFinalizer = null;
	
	debug Log.info(" >> Texture Finalized");
}

struct Viewport {
	enum Mode : ubyte {
		Normal,
		Reverse
	}
	
	const Mode mode;
	const(ShortRect)* dest;
	const(ShortRect)* view;
	
	@disable
	this();
	
	this(const(ShortRect)* dest, const(ShortRect)* view, Mode mode = Mode.Normal) {
		this.dest = dest;
		this.view = view;
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
		None  = 0,							/// Take this if you want to declare that you give no Format.
		RGB   = GL_RGB,						/// Alias for GL_RGB
		RGBA  = GL_RGBA,					/// Alias for GL_RGBA
		BGR   = GL_BGR,						/// Alias for GL_BGR
		BGRA  = GL_BGRA,					/// Alias for GL_BGRA
		RGBA16 = GL_RGBA16,
		RGBA8  = GL_RGBA8,
		Alpha = GL_ALPHA,					/// Alias for GL_ALPHA
		Luminance = GL_LUMINANCE,			/// Alias for GL_LUMINANCE
		LuminanceAlpha = GL_LUMINANCE_ALPHA, /// Alias for GL_LUMINANCE_ALPHA
		CompressedRGB = GL_COMPRESSED_RGB,	/// Compressed RGB
		CompressedRGBA = GL_COMPRESSED_RGBA /// Compressed RGBA
	}
	
	/**
	 * Compression modes
	 */
	enum Compression {
		None, /// No compression
		DontCare = GL_DONT_CARE, /// The OpenGL implementation decide on their own
		Fastest  = GL_FASTEST, /// Fastest compression
		Nicest   = GL_NICEST /// Nicest but slowest mode of compression
	}
	
private:
	GLuint _texId;
	
	ushort _width;
	ushort _height;
	ubyte _depth;
	
	bool _isSmooth;
	bool _isRepeated;
	
	Format _format;
	Compression _comp;
	
	Blend _blend;
	
package:
	void _render(const Viewport* vp) const {
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		float tx = 0f;
		float ty = 0f;
		float tw = 1f;
		float th = 1f;
		
		if (vp !is null && vp.view !is null && !vp.view.isZero()) {
			tx = (0f + vp.view.x) / this._width;
			ty = (0f + vp.view.y) / this._height;
			
			if (!vp.view.isEmpty()) {
				tw = (0f + vp.view.width) / this._width;
				th = (0f + vp.view.height) / this._height;
			}
		}
		
		glPushAttrib(GL_CURRENT_BIT | GL_COLOR_BUFFER_BIT);
		scope(exit) glPopAttrib();
		
		//		// apply blending
		if (this._blend !is null)
			this._blend.applyBlending();
		
		const Viewport.Mode mode = vp !is null ? vp.mode : Viewport.Mode.Normal;
		
		float[8] texCoords = void;
		final switch (mode) {
			case Viewport.Mode.Normal:
				texCoords = [
					tx,      ty,
					tx + tw, ty,
					tx + tw, ty + th,
					tx,      ty + th
				];
				break;
			case Viewport.Mode.Reverse:
				texCoords = [
					tx,      ty + th,
					tx + tw, ty + th,
					tx + tw, ty,
					tx,      ty
				];
				break;
		}
		
		float dx = 0f;
		float dy = 0f;
		float dw = this._width;
		float dh = this._height;
		
		if (vp !is null && vp.dest !is null) {
			dx = vp.dest.x;
			dy = vp.dest.y;
			
			if (!vp.dest.isEmpty()) {
				dw = vp.dest.width;
				dh = vp.dest.height;
			}
		}
		
		float[12] vertices = [
			dx,	     dy,      0f,
			dx + dw, dy,      0f,
			dx + dw, dy + dh, 0f,
			dx,      dy + dh, 0f
		];
		
		VertexRenderer.pointTo(Target.Vertex, &vertices[0]);
		VertexRenderer.pointTo(Target.TexCoords, &texCoords[0]);
		
		scope(exit) {
			VertexRenderer.disableAllStates();
			this.unbind();
		}
		
		this.bind();
		
		VertexRenderer.drawArrays(Shape.Type.TriangleFan, vertices.length);
	}
	
	void _render(ref const Viewport vp) const {
		this._render(&vp);
	}
	
	void _render(const Viewport vp) const {
		this._render(&vp);
	}
	
public:
final:
	/**
	 * CTor
	 */
	this() {
		glGenTextures(1, &this._texId);
		
		_TexFinalizer ~= &this._texId;
		
		this.bind();
	}
	
	/**
	 * Postblit
	 */
	this(const Texture tex, Format t_fmt = Format.None) {
		void[] mem = tex.getMemory();
		enforce(mem !is null, "Cannot a texture with no memory.");
		this.loadFromMemory(&mem[0], tex.width, tex.height, tex.depth, t_fmt ? t_fmt : tex.getFormat());
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
			debug Log.info("Destroy texture");
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
	void setSmooth(bool enable) pure nothrow {
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
	 * (Re)Set the compression mode.
	 * 
	 * See: Compression enum
	 */
	void setCompression(Compression comp) pure nothrow {
		this._comp = comp;
	}
	
	/**
	 * Returns the current Compression mode.
	 *
	 * See: Compression enum
	 */
	Compression getCompression() const pure nothrow {
		return this._comp;
	}
	
	/**
	 * Checks whether the current Texture is compressed or not.
	 */
	bool isCompressed() const {
		this.bind();
		
		GLint compressed;
		glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_COMPRESSED, &compressed);
		
		return compressed != 1;
	}
	
	/**
	 * Set (or reset) the current Blend instance.
	 */
	void setBlend(Blend blend) pure nothrow {
		this._blend = blend;
	}
	
	/**
	 * Returns the current Blend instance
	 */
	inout(Blend) getBlend() inout pure nothrow {
		return this._blend;
	}
	
	/**
	 * Checks whether this Texture has a Blend instance.
	 */
	bool hasBlend() const pure nothrow {
		return this._blend !is null;
	}
	
	/**
	 * Load from memory.
	 */
	void loadFromMemory(void* memory, ushort width, ushort height, ubyte depth, Format fmt = Format.None) in {
		assert(width != 0 && height != 0, "Width and height cannot be 0.");
		assert(depth >= 8 || fmt != Format.None, "Need a depth or a format.");
	} body {
		/// Possible speedup because 'glTexSubImage2D'
		/// is often faster than 'glTexImage2D'.
		if (width == this.width
		    && height == this.height
		    && (fmt == Format.None || fmt == this._format))
		{
			this.updateMemory(memory, null);
			return;
		}
		
		this._format = fmt == Format.None ? bitsToFormat(depth) : fmt;
		enforce(this._format != Format.None, "Need Texture.Format or depth > 24");
		depth = depth < 8 ? formatToBits(this._format) : depth;
		
		this.bind();
		
		Format format = Format.None;
		// Compression
		if (this._comp != Compression.None) {
			glHint(GL_TEXTURE_COMPRESSION_HINT, this._comp);
			format = compressFormat(this._format);
		}
		
		glTexImage2D(GL_TEXTURE_2D, 0, format == Format.None ? depth / 8 : format,
		             width, height, 0, this._format, GL_UNSIGNED_BYTE, memory);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
		                this._isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
		                this._isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
		                this._isSmooth ? GL_LINEAR : GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
		                this._isSmooth ? GL_LINEAR : GL_NEAREST);
		glGenerateMipmap(GL_TEXTURE_2D); // We want MipMaps
		
		debug {
			if (format != Format.None) {
				if (!this.isCompressed())
					Log.info("\tTexture wurde nicht komprimiert : %s : %s", cast(Format) format, this._format);
			}
		}
		
		this._width  = width;
		this._height = height;
		this._depth  = depth;
	}
	
	/**
	 * Set a colorkey.
	 */
	void setColorkey(ref const Color colorkey) {
		// Get the pixel memory
		void[] memory = this.getMemory();
		enforce(memory !is null, "Cannot set a colorkey for an empty Texture.");
		
		//const uint size = this._width * this._height * (this._depth / 8);
		// Go through pixels
		for (uint i = 0; i < memory.length; ++i) {
			// Get pixel colors
			uint* color = cast(uint*) &memory[i];
			// Color matches
			if (color[0] == colorkey.red
			&& color[1] == colorkey.green
			&& color[2] == colorkey.blue
			&& (0 == colorkey.alpha || color[3] == colorkey.alpha))
			{
				// Make transparent
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
				color[3] = 0;
			}
		}
		
		this.updateMemory(&memory[0]);
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
	void[] getMemory() const {
		const uint msize = this._width * this._height * (this._depth / 8);
		if (msize == 0) {
			debug Log.info("@Texture.GetPixels: Null Pixel");
			return null;
		}
		
		this.bind();
		
		void[] memory = new void[msize];
		glGetTexImage(GL_TEXTURE_2D, 0, this._format, GL_UNSIGNED_BYTE, memory.ptr);
		
		return memory;
	}
	
	/**
	 * Returns a subTexture of this Texture.
	 * This isn't similar to partial.
	 */
	Texture subTexture(ref const ShortRect rect) {
		if (this._format == Format.None)
			return null;
		
		Texture tex = new Texture();
		debug Log.info("Format switch: %s.", .switchFormat(this._format, true));
		tex.loadFromMemory(null, rect.width, rect.height, this._depth, this._format.switchFormat(true));
		
		int[4] vport = void;
		glGetIntegerv(GL_VIEWPORT, &vport[0]);
		
		glPushAttrib(GL_VIEWPORT_BIT);
		scope(exit) glPopAttrib();
		
		glViewport(0, 0, rect.width, rect.height);
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		const ShortRect dest = ShortRect(0, 0, cast(ushort) vport[2], cast(ushort) vport[3]);
		this._render(Viewport(&dest, &rect, Viewport.Mode.Reverse));
		
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
		
		int[4] vport = void;
		glGetIntegerv(GL_VIEWPORT, &vport[0]);
		
		///
		glPushAttrib(GL_VIEWPORT_BIT);
		scope(exit) glPopAttrib();
		
		glViewport(0, 0, rw, rh);
		
		if (!glIsEnabled(GL_TEXTURE_2D))
			glEnable(GL_TEXTURE_2D);
		
		const ShortRect dest = ShortRect(0, 0, cast(ushort) vport[2], cast(ushort) vport[3]);
		tex._render(Viewport(&dest, rect, Viewport.Mode.Reverse));
		
		this.bind();
		
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, rx, ry, 0, 0, rw, rh);
	}
	
	/**
	 * Update the pixel data of this Texture.
	 * The second parameter is a pointer to the area which is updated.
	 * If it is null (default) the whole Texture will be updated.
	 * The third parameter is the format of the pixels.
	 */
	void updateMemory(const void* memory, const ShortRect* rect = null,  Format fmt = Format.None) in {
		assert(memory !is null, "Pixels is null.");
		assert(this._width != 0 && this._height != 0, "width or height is 0.");
	} body {
		ushort width, height;
		short x, y;
		
		if (rect !is null) {
			enforce(rect.width <= this._width && rect.height <= this._height, 
			        "Rect is greater as the Texture.");
			enforce(rect.x < this._width && rect.y < this._height, 
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
		
		this.bind();
		
		glTexSubImage2D(GL_TEXTURE_2D, 0,
		                x, y, width, height,
		                (fmt == Format.None ? this._format : fmt),
		                GL_UNSIGNED_BYTE, memory);
	}
}