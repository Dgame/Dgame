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
	import Dgame.Internal.Unique;
	import Dgame.Internal.Unique;

	import Dgame.Math.Rect;
	import Dgame.Graphics.Color;
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

/**
 * A Texture is a 2 dimensional pixel reprasentation.
 * It is a wrapper of an OpenGL Texture.
 *
 * Author: rschuett
 */
class Texture {
public:
	/**
	 * Supported Texture Format
	 */
	enum Format {
		None = 0,							/// Take this if you want to declare that you give no Format.
		RGB = GL_RGB,						/// Alias for GL_RGB
		RGBA = GL_RGBA,					/// Alias for GL_RGBA
		BGR = GL_BGR,						/// Alias for GL_BGR
		BGRA = GL_BGRA,					/// Alias for GL_BGRA
		RGBA16 = GL_RGBA16,					/// 16 Bit RGBA Format
		RGBA8 = GL_RGBA8,					/// 8 Bit RGBA Format
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
		Fastest = GL_FASTEST, /// Fastest compression
		Nicest = GL_NICEST /// Nicest but slowest mode of compression
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
		const uint msize = tex.width * tex.height * (tex.depth / 8);
		unique_ptr!(void) mem = allocate_unique!(void)(msize);

		void[] memory = tex.getMemory(mem[0 .. msize]);
		enforce(memory !is null, "Cannot a texture with no memory.");
		this.loadFromMemory(&memory[0], tex.width, tex.height, tex.depth, t_fmt ? t_fmt : tex.getFormat());
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
			this.update(memory, null);
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
		const uint msize = this._width * this._height * (this._depth / 8);
		unique_ptr!(void) mem = allocate_unique!(void)(msize);
		void[] memory = this.getMemory(mem[0 .. msize]);
		enforce(memory !is null, "Cannot set a colorkey for an empty Texture.");
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
		
		this.update(&memory[0]);
	}
	
	/**
	 * Rvalue version
	 */
	void setColorkey(const Color colorkey) {
		this.setColorkey(colorkey);
	}
	
	/**
	 * Returns the pixel of this Texture or null if this Texture isn't valid.
	 * If memory is not null and has the same width and height as the Texture,
	 * it is used to store the pixel data.
	 * Otherwise it <b>allocates</b> GC memory.
	 */
	void[] getMemory(void[] memory = null) const {
		const uint msize = this._width * this._height * (this._depth / 8);
		if (msize == 0) {
			debug Log.info("@Texture.GetPixels: Null Pixel");

			return null;
		}
		
		this.bind();

		if (memory is null)
			memory = new void[msize];
		else if (memory.length < msize)
			throw new Exception("Your given memory is to short.");

		glGetTexImage(GL_TEXTURE_2D, 0, this._format, GL_UNSIGNED_BYTE, memory.ptr);
		
		return memory;
	}

	/**
	 * Rvalue version
	 */
	Texture subTexture(const ShortRect rect) const {
		return this.subTexture(rect);
	}

	/**
	 * Returns a subTexture of this Texture.
	 */
	Texture subTexture(ref const ShortRect rect) const in {
		assert(rect.x <= this._width, "rect.x is out of range.");
		assert(rect.y <= this._height, "rect.y is out of range.");
		assert(rect.width <= this._width, "rect.width is out of range.");
		assert(rect.height <= this._height, "rect.height is out of range.");
		assert(rect.x >= 0, "rect.x is negative");
		assert(rect.y >= 0, "rect.y is negative.");
		assert(rect.width >= 0, "rect.width is negative.");
		assert(rect.height >= 0, "rect.height is negative.");
	} body {
		if (this._format == Format.None)
			return null;

		const ubyte bits = this._depth / 8;
		const uint msize = this._width * this._height * bits;
		unique_ptr!(void) mem = allocate_unique!(void)(msize);
		void[] memory = this.getMemory(mem[0 .. msize]);

		const uint[2] pitch = [this._width * bits, rect.width * bits];
		const uint diff = pitch[0] - pitch[1];

		uint from = pitch[0] * rect.y + rect.x * bits;
		uint too = from + (rect.height * pitch[0]);

		unique_ptr!(ubyte) buffer = allocate_unique!(ubyte)(msize);
//		ubyte[] buffer = new ubyte[msize];
		for (uint i = from, j = 0; i < too - pitch[1]; i += pitch[1], j += pitch[1]) {
			buffer[j .. j + pitch[1]] = cast(ubyte[]) memory[i .. i + pitch[1]];
			i += diff;
		}

		Texture tex = new Texture();
		tex.loadFromMemory(buffer.ptr, rect.width, rect.height, 0, this._format);

		return tex;
	}

	/**
	 * Copy another Texture to this.
	 * The second parameter is a pointer to the destination rect.
	 * Is it is null this means the whole tex is copied.
	 */
	void copy(const Texture tex, const ShortRect* rect = null) const in {
		assert(tex !is null, "Cannot copy null Texture.");
		assert(this._width != 0 && this._height != 0, "width or height is 0.");
	} body {
		const ubyte bits = tex.depth / 8;
		const uint msize = tex.width * tex.height * bits;

		unique_ptr!(void) mem = allocate_unique!(void)(msize);
		void[] memory = tex.getMemory(mem[0 .. msize]);

		this.update(memory.ptr, rect, tex.getFormat());
	}
	
	/**
	 * Update the pixel data of this Texture.
	 * The second parameter is a pointer to the area which is updated.
	 * If it is null (default) the whole Texture will be updated.
	 * The third parameter is the format of the pixels.
	 */
	void update(const void* memory, const ShortRect* rect = null,  Format fmt = Format.None) const in {
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

		this.bind();
		
		glTexSubImage2D(GL_TEXTURE_2D, 0,
		                x, y, width, height,
		                (fmt == Format.None ? this._format : fmt),
		                GL_UNSIGNED_BYTE, memory);
	}
}