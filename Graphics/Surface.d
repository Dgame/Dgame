module Dgame.Graphics.Surface;

private {
	debug import std.stdio;
	import std.string : format, toStringz;
	import std.file : exists;
	import std.conv : to;
	import std.algorithm : reverse;
	import std.c.string : memcpy;
	
	import derelict3.sdl2.sdl;
	import derelict3.sdl2.image;
	
	import Dgame.Math.Rect;
	import Dgame.Math.Vector2;
	import Dgame.Graphics.Color;
}

/**
 * Surface is a wrapper for a SDL_Surface.
 *
 * Author: rschuett
 */
struct Surface {
public:
	/**
	 * Supported BlendModes
	 */
	enum BlendMode {
		None   = SDL_BLENDMODE_NONE,	/** no blending */
		Blend  = SDL_BLENDMODE_BLEND,	/** dst = (src * A) + (dst * (1-A)) */
		Add    = SDL_BLENDMODE_ADD,		/** dst = (src * A) + dst */
		Mod    = SDL_BLENDMODE_MOD,		/** dst = src * dst */
	}
	
	/**
	 * Supported Color Masks
	 */
	enum Mask {
		Red   = 1,	/** Red Mask */
		Green = 2,	/** Green Mask */
		Blue  = 4,	/** Blue Mask */
		Alpha = 8	/** Alpha Mask */
	}
	
	version (none) {
		version (LittleEndian) {
			enum RMask = 0x000000ff; /** Default Red Mask. */
			enum GMask = 0x0000ff00; /** Default Green Mask. */
			enum BMask = 0x00ff0000; /** Default Blue Mask. */
			enum AMask = 0xff000000; /** Default Alpha Mask. */
		} else {
			enum RMask = 0xff000000; /** Default Red Mask. */
			enum GMask = 0x00ff0000; /** Default Green Mask. */
			enum BMask = 0x0000ff00; /** Default Blue Mask. */
			enum AMask = 0x000000ff; /** Default Alpha Mask. */
		}
	} else {
		enum RMask = 0; /** Default Red Mask. */
		enum GMask = 0; /** Default Green Mask. */
		enum BMask = 0; /** Default Blue Mask. */
		enum AMask = 0; /** Default Alpha Mask. */
	}
	
	/**
	 * Flip mode
	 */
	enum Flip {
		Vertical   = 1, /** Vertical Flip */
		Horizontal = 2  /** Horizontal Flip */
	}
	
private:
	SDL_Surface* _sdl_surface;
	
	string _filename;
	bool _isLocked;
	
private:
	void _clone(SDL_Surface* srfc) in {
		assert(srfc !is null, "Invalid SDL_Surface.");
		assert(srfc.pixels !is null, "Invalid pixel data.");
	} body {
		this.free(); /// Free old data
		/*
		 this._sdl_surface = SDL_CreateRGBSurfaceFrom(
		 srfc.pixels, 
		 srfc.w, srfc.h, 
		 srfc.format.BitsPerPixel,
		 srfc.format.BytesPerPixel * srfc.w, 
		 RMask, GMask, BMask, AMask);
		 */
		memcpy(this._sdl_surface, srfc, SDL_Surface.sizeof);
		
		if (this._sdl_surface is null)
			throw new Exception(
				format("Surface konnte nicht erstellt werden: %s", to!string(SDL_GetError())));
	}
	
public:
	/**
	 * CTor
	 */
	this(string filename) {
		debug writeln("CTor Surface : ", filename);
		this.loadFromFile(filename);
	}
	
	/**
	 * CTor
	 * If link is true, srfc is linked to this.
	 * Otherwise a copy is created.
	 */
	this(SDL_Surface* srfc, bool link) in {
		assert(srfc !is null, "Invalid SDL_Surface.");
		assert(srfc.pixels !is null, "Invalid pixel data.");
	} body {
		debug writeln("CTor Surface: ", link);
		
		if (!link)
			this._clone(srfc);
		else
			this._sdl_surface = srfc;
	}
	
	/**
	 * Postblit
	 */
	this(this) {
		this._sdl_surface.refcount++;
		debug writeln("Postblit Surface: ", this._sdl_surface.refcount, ':', this.filename);
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref Surface rhs) {
		debug writeln("op Assign lvalue");
		this._clone(rhs.ptr);
	}
	
	/**
	 * Rvalue version
	 */
	void opAssign(Surface rhs) {
		debug writeln("op Assign rvalue");
		this.opAssign(rhs);
	}
	
	/**
	 * DTor
	 */
	~this() {
		if (!this._sdl_surface)
			return;
		
		if (this._sdl_surface.refcount == 1) {
			debug writeln("DTor Surface", ':', this.filename);
			this.free();
		} else {
			this._sdl_surface.refcount--;
			debug writeln("Free Surface", ':', this.filename, ':', this._sdl_surface.refcount);
		}
	}
	
	/**
	 * Destroy the current Surface <b>and all, which are linked to this Surface</b>.
	 * This method is called from the DTor.
	 */
	void free() {
		if (this._sdl_surface) {
			SDL_FreeSurface(this._sdl_surface);
			
			this._sdl_surface = null;
		}
	}
	
	/**
	 * Returns the current use count
	 */
	uint useCount() const pure nothrow {
		return this._sdl_surface.refcount;
	}
	
	/**
	 * Make a new Surface of the given width, height and depth.
	 */
	static Surface make(ushort width, ushort height, ubyte depth = 32) {
		SDL_Surface* srfc = Surface.create(width, height, depth);
		
		if (srfc is null)
			throw new Exception(format("Surface konnte nicht erstellt werden: %s",
			                           to!string(SDL_GetError())));
		
		return Surface(srfc, true);
	}
	
	/**
	 * Create a new SDL_Surface* of the given width, height and depth.
	 */
	static SDL_Surface* create(ushort width, ushort height, ubyte depth = 32) in {
		assert(depth >= 8 && depth <= 32, "Invalid depth.");
	} body {
		return SDL_CreateRGBSurface(0, width, height, depth,
		                            RMask, GMask, BMask, AMask);
	}
	
	/**
	 * Make an new Surface of the given memory, width, height and depth.
	 */
	static Surface make(void* memory, ushort width, ushort height, ubyte depth = 32) {
		SDL_Surface* srfc = Surface.create(memory, width, height, depth);
		
		if (srfc is null)
			throw new Exception(
				format("Surface konnte nicht erstellt werden: %s", to!string(SDL_GetError())));
		
		return Surface(srfc, true);
	}
	
	/**
	 * Create a new SDL_Surface* of the given memory, width, height and depth.
	 */
	static SDL_Surface* create(void* memory, ushort width, ushort height, ubyte depth = 32) in {
		assert(memory !is null, "Memory is empty.");
		assert(depth >= 8 && depth <= 32, "Invalid depth.");
	} body {
		return SDL_CreateRGBSurfaceFrom(memory, width, height, depth,
		                                (depth / 8) * width,
		                                RMask, GMask, BMask, AMask);
	}
	
	/**
	 * Returns if the Surface is valid. Which means that the Surface has valid data.
	 */
	bool isValid() const pure nothrow {
		return this._sdl_surface !is null && this._sdl_surface.pixels !is null;
	}
	
	/**
	 * Returns the filename, if any
	 */
	@property
	string filename() const pure nothrow {
		return this._filename;
	}
	
	/**
	 * Load from filename. If any data is already stored, the data will be freed.
	 */
	void loadFromFile(string filename) {
		if (filename.length < 4 || !exists(filename))
			throw new Exception("Die Datei " ~ filename ~ " existiert nicht.");
		
		this.free(); /// free old surface data
		debug writefln("Load Image: %s, %s", filename, filename.ptr);
		
		try {
			this._sdl_surface = IMG_Load(toStringz(filename));
		} catch (Throwable e) {
			throw new Exception(
				format("Die Datei (%s) konnte nicht geladen werden: %s", filename, e.msg));
		}
		
		this._filename = filename;
		
		if (this._sdl_surface is null)
			throw new Exception(
				format("Something fails by loading the image: %s", to!string(SDL_GetError())));
	}
	
	/**
	 * Load from memory.
	 */
	void loadFromMemory(void* memory, ushort width, ushort height, ubyte depth = 32) in {
		assert(memory !is null, "Memory is empty.");
		assert(depth >= 8 && depth <= 32, "Invalid depth.");
	} body {
		this.free(); /// free old surface data
		
		this._sdl_surface = SDL_CreateRGBSurfaceFrom(
			memory, width, height, depth,
			(depth / 8) * width,
			RMask, GMask, BMask, AMask);
		
		if (this._sdl_surface is null)
			throw new Exception(
				format("Something fails by loading the image: %s", to!string(SDL_GetError())));
	}
	
	/**
	 * Save the current pixel data to the file.
	 */
	void saveToFile(string filename) {
		if (filename.length < 3)
			throw new Exception("Dateiname ist nicht zulässig.");
		
		try {
			SDL_SaveBMP(this.ptr, toStringz(filename));
		} catch (Throwable e) {
			string msg = format("Die Datei (%s) konnte nicht gespeichert werden: %s", filename, e.msg);
			throw new Exception(msg);
		}
	}
	
	/**
	 * Returns the width.
	 */
	@property
	ushort width() const pure nothrow {
		return this._sdl_surface !is null ? cast(ushort) this._sdl_surface.w : 0;
	}
	
	/**
	 * Returns the height.
	 */
	@property
	ushort height() const pure nothrow {
		return this._sdl_surface !is null ? cast(ushort) this._sdl_surface.h : 0;
	}
	
	/**
	 * Fills a specific area of the surface with the given color.
	 * The second parameter is a pointer to the area.
	 * If it's null, the whole Surface is filled.
	 */
	void fill(ref const Color col, const ShortRect* rect = null) {
		const SDL_Rect* ptr = rect ? rect.ptr : null;
		uint key = SDL_MapRGBA(this._sdl_surface.format, col.red, col.green, col.blue, col.alpha);
		
		SDL_FillRect(this._sdl_surface, ptr, key);
	}
	
	/**
	 * Rvalue version
	 */
	void fill(const Color col, const ShortRect* rect = null) {
		this.fill(col, rect);
	}
	
	/**
	 * Fills multiple areas of the Surface with the given color.
	 */
	void fillAreas(ref const Color col, const ShortRect[] rects) {
		const SDL_Rect* ptr = (rects.length > 0) ? rects[0].ptr : null;
		uint key = SDL_MapRGBA(this._sdl_surface.format, col.red, col.green, col.blue, col.alpha);
		
		SDL_FillRects(this._sdl_surface, ptr, rects.length, key);
	}
	
	/**
	 * Rvalue version
	 */
	void fillAreas(const Color col, const ShortRect[] rects) {
		this.fillAreas(col, rects);
	}
	
	/**
	 * Use this function to set the RLE acceleration hint for a surface.
	 * RLE (Run-Length-Encoding) is a way of compressing data.
	 * If RLE is enabled, color key and alpha blending blits are much faster, 
	 * but the surface must be locked before directly accessing the pixels.
	 *
	 * Returns: whether the call succeeded or not
	 */
	bool optimizeRLE(bool enable) {
		return SDL_SetSurfaceRLE(this._sdl_surface, enable) == 0;
	}
	
	/**
	 * Use this function to set up a surface for directly accessing the pixels.
	 *
	 * Returns: whether the call succeeded or not
	 */
	bool lock() {
		if (SDL_LockSurface(this._sdl_surface) == 0)
			this._isLocked = true;
		
		return this._isLocked;
	}
	
	/**
	 * Use this function to release a surface after directly accessing the pixels.
	 */
	void unlock() {
		this._isLocked = false;
		
		SDL_UnlockSurface(this._sdl_surface);
	}
	
	/**
	 * Returns whether this Surface is locked or not.
	 */
	bool isLocked() const pure nothrow {
		return this._isLocked;
	}
	
	/**
	 * Use this function to determine whether a surface must be locked for access.
	 */
	bool mustLock() {
		return SDL_MUSTLOCK(this._sdl_surface) == SDL_TRUE;
	}
	
	/**
	 * Use this function to adapt the format of another Surface to this surface.
	 * Works like <code>SDL_DisplayFormat</code>.
	 */
	void adaptTo(ref Surface srfc) in {
		assert(srfc.isValid(), "Could not adapt to invalid surface.");
		assert(this.isValid(), "Could not adapt a invalid surface.");
	} body {
		this.adaptTo(srfc.ptr.format);
	}
	
	/**
	 * Use this function to adapt the format of another Surface to this surface.
	 * Works like <code>SLD_DisplayFormat</code>.
	 */
	void adaptTo(SDL_PixelFormat* fmt) {
		assert(fmt !is null, "Null format is invalid.");
		
		SDL_Surface* adapted = SDL_ConvertSurface(this._sdl_surface, fmt, 0);
		assert(adapted !is null, "Could not adapt surface.");
		
		this.free(); /// free old surface
		this._sdl_surface = adapted;
	}
	
	/**
	 * Set the colorkey.
	 */
	void setColorkey(ref const Color col) {
		this.setColorkey(col.red, col.green, col.blue, col.alpha);
	}
	
	/**
	 * Rvalue version
	 */
	void setColorkey(const Color col) {
		this.setColorkey(col);
	}
	
	/**
	 * Set the colorkey.
	 */
	void setColorkey(ubyte red, ubyte green, ubyte blue, short alpha = -1) {
		uint key;
		
		if (alpha >= 0)
			key = SDL_MapRGBA(this._sdl_surface.format, red, green, blue, cast(ubyte) alpha);
		else
			key = SDL_MapRGB(this._sdl_surface.format, red, green, blue);
		
		SDL_SetColorKey(this._sdl_surface, SDL_TRUE, key);
	}
	
	/**
	 * Returns the current colorkey.
	 */
	Color getColorkey() {
		uint key;
		SDL_GetColorKey(this._sdl_surface, &key);
		
		ubyte r, g, b, a;
		SDL_GetRGBA(key, this._sdl_surface.format, &r, &g, &b, &a);
		
		return Color(r, g, b, a);
	}
	
	/**
	 * Set the Alpha mod.
	 */
	void setAlphaMod(ubyte alpha) {
		SDL_SetSurfaceAlphaMod(this._sdl_surface, alpha);
	}
	
	/**
	 * Returns the current Alpha mod.
	 */
	ubyte getAlphaMod() {
		ubyte alpha;
		SDL_GetSurfaceAlphaMod(this._sdl_surface, &alpha);
		
		return alpha;
	}
	
	/**
	 * Set the Blendmode.
	 */
	void setBlendMode(BlendMode mode) {
		SDL_SetSurfaceBlendMode(this._sdl_surface, mode);
	}
	
	/**
	 * Returns the current Blendmode.
	 */
	BlendMode getBlendMode() {
		SDL_BlendMode mode;
		SDL_GetSurfaceBlendMode(this._sdl_surface, &mode);
		
		return cast(BlendMode) mode;
	}
	
	/**
	 * Returns the clip rect of this surface.
	 * The clip rect is the area of the surface which is drawn.
	 */
	ShortRect getClipRect() {
		ShortRect rect;
		SDL_GetClipRect(this._sdl_surface, rect.ptr);
		
		return rect;
	}
	
	/**
	 * Set the clip rect.
	 */
	void setClipRect(ref const ShortRect clip) {
		SDL_SetClipRect(this._sdl_surface, clip.ptr);
	}
	
	/**
	 * Rvalue version
	 */
	void setClipRect(const ShortRect clip) {
		this.setClipRect(clip);
	}
	
	/**
	 * Returns the pixel data of this surface.
	 */
	inout(void*) getPixels() inout {
		return this._sdl_surface !is null ? this._sdl_surface.pixels : null;
	}
	
	/**
	 * Count the bits of this surface.
	 * Could be 32, 24, 16, 8, 0.
	 */
	ubyte countBits() const pure nothrow {
		return this._sdl_surface !is null ? this._sdl_surface.format.BitsPerPixel : 0;
	}
	
	/**
	 * Count the bytes of this surface.
	 * Could be 4, 3, 2, 1, 0. (countBits / 8)
	 */
	ubyte countBytes() const pure nothrow {
		return this._sdl_surface !is null ? this._sdl_surface.format.BytesPerPixel : 0;
	}
	
	/**
	 * Returns the Surface pitch or 0.
	 */
	int getPitch() const pure nothrow {
		return this._sdl_surface !is null ? this._sdl_surface.pitch : 0;
	}
	
	/**
	 * Returns the PixelFormat
	 */
	const(SDL_PixelFormat*) getPixelFormat() const pure nothrow {
		return this._sdl_surface.format;
	}
	
	/**
	 * Returns if the given color match the color of the given mask of the surface.
	 *
	 * See: Surface.Mask enum.
	 */
	bool isMask(Mask mask, ref const Color col) const {
		uint map = SDL_MapRGBA(this._sdl_surface.format, col.red, col.green, col.blue, col.alpha);
		
		return this.isMask(mask, map);
	}
	
	/**
	 * Rvalue version
	 */
	bool isMask(Mask mask, const Color col) const {
		return this.isMask(mask, col);
	}
	
	/**
	 * Returns if the given converted color match the color of the given mask of the surface.
	 *
	 * See: Surface.Mask enum.
	 */
	bool isMask(Mask mask, uint col) const /*pure nothrow */{
		bool result = false;
		
		if (mask & Mask.Red)
			result = this._sdl_surface.format.Rmask == col;
		if (mask & Mask.Green)
			result = result && this._sdl_surface.format.Gmask == col;
		if (mask & Mask.Blue)
			result = result && this._sdl_surface.format.Bmask == col;
		if (mask & Mask.Alpha)
			result = result && this._sdl_surface.format.Amask == col;
		
		return result;
	}
	
	/**
	 * Returns a pointer of the pixel at the given coordinates.
	 */
	ubyte* getPixelAt(ref const Vector2s pos) const {
		return this.getPixelAt(pos.x, pos.y);
	}
	
	/**
	 * Returns a pointer of the pixel at the given coordinates.
	 */
	ubyte* getPixelAt(ushort x, ushort y) const {
		ubyte* pixels = cast(ubyte*) this.getPixels();
		assert(pixels !is null);
		
		// pixels[(y * this.Width) + x];
		return pixels + y * this.getPitch() + x * this.countBytes();
	}
	
	/**
	 * Put a new pixel at the given coordinates.
	 */
	void putPixelAt(ref const Vector2s pos, ubyte pixel) {
		this.putPixelAt(pos.x, pos.y, pixel);
	}
	
	/**
	 * Put a new pixel at the given coordinates.
	 */
	void putPixelAt(ushort x, ushort y, ubyte pixel) {
		ubyte* p = this.getPixelAt(x, y);
		*p = pixel;
	}
	
	/**
	 * Returns the color on the given position.
	 */
	Color getColorAt(ref const Vector2s pos) const {
		return this.getColorAt(pos.x, pos.y);
	}
	
	/**
	 * Returns the color on the given position.
	 */
	Color getColorAt(ushort x, ushort y) const {
		const uint len = this.width * this.height;
		//assert(len > 0);
		
		if ((x * y) <= len) {
			ubyte* p = this.getPixelAt(x, y);
			
			ubyte r, g, b, a;
			//cast(uint*)
			SDL_GetRGBA(*p, this._sdl_surface.format, &r, &g, &b, &a);
			
			return Color(r, g, b, a);
		}
		
		throw new Exception("No color at this position.");
	}
	
	/**
	 * Returns a pointer of the SDL_Surface
	 */
	@property
	inout(SDL_Surface)* ptr() inout {
		return this._sdl_surface;
	}
	
	/**
	 * Use this function to perform a fast, low quality,
	 * stretch blit between two surfaces of the same pixel format.
	 * src is the a pointer to a Rect structure which represents the rectangle to be copied, 
	 * or null to copy the entire surface.
	 * dst is a pointer to a Rect structure which represents the rectangle that is copied into.
	 * null means, that the whole srfc is copied to (0|0).
	 */
	bool softStretch(ref Surface srfc, const ShortRect* src = null, const ShortRect* dst = null) {
		return this.softStretch(srfc.ptr, src, dst);
	}
	
	/**
	 * Same as above, but with a SDL_Surface* instead of a Surface.
	 */
	bool softStretch(SDL_Surface* srfc, const ShortRect* src = null, const ShortRect* dst = null) in {
		assert(srfc !is null, "Null surface cannot be blit.");
	} body {
		const SDL_Rect* src_ptr = src ? src.ptr : null;
		const SDL_Rect* dst_ptr = dst ? dst.ptr : null;
		
		return SDL_SoftStretch(srfc, src_ptr, this._sdl_surface, dst_ptr) == 0;
	}
	
	/**
	 * Use this function to perform a fast blit from the source surface to the this surface
	 */
	bool upperBlit(ref Surface srfc, const ShortRect* src = null, ShortRect* dst = null) {
		return this.upperBlit(srfc.ptr, src, dst);
	}
	
	/**
	 * Same as above, but with a SDL_Surface* instead of a Surface.
	 */
	bool upperBlit(SDL_Surface* srfc, const ShortRect* src = null, ShortRect* dst = null) in {
		assert(srfc !is null, "Null surface cannot be blit.");
	} body {
		const SDL_Rect* src_ptr = src ? src.ptr : null;
		SDL_Rect* dst_ptr = dst ? dst.ptr : null;
		
		return SDL_UpperBlit(srfc, src_ptr, this._sdl_surface, dst_ptr) == 0;
	}
	
	/**
	 * Use this function to perform low-level surface blitting only.
	 */
	bool lowerBlit(ref Surface srfc, ShortRect* src = null, ShortRect* dst = null) {
		return this.lowerBlit(srfc.ptr, src, dst);
	}
	
	/**
	 * Same as above, but with a SDL_Surface* instead of a Surface.
	 */
	bool lowerBlit(SDL_Surface* srfc, ShortRect* src = null, ShortRect* dst = null) in {
		assert(srfc !is null, "Null surface cannot be blit.");
	} body {
		SDL_Rect* src_ptr = src ? src.ptr : null;
		SDL_Rect* dst_ptr = dst ? dst.ptr : null;
		
		return SDL_LowerBlit(srfc, src_ptr, this._sdl_surface, dst_ptr) == 0;
	}
	
	/**
	 * Use this function to perform a fast blit from the source surface to the this surface.
	 * src is the a pointer to a Rect structure which represents the rectangle to be copied, 
	 * or null to copy the entire surface.
	 * dst is a pointer to a Rect structure which represents the rectangle that is copied into.
	 * null means, that the whole srfc is copied to (0|0).
	 */
	bool blit(ref Surface srfc, const ShortRect* src = null, ShortRect* dst = null) {
		return this.blit(srfc.ptr, src, dst);
	}
	
	/**
	 * Same as above, but with a SDL_Surface* instead of a Surface.
	 */
	bool blit(SDL_Surface* srfc, const ShortRect* src = null, ShortRect* dst = null) in {
		assert(srfc !is null, "Null surface cannot be blit.");
	} body {
		const SDL_Rect* src_ptr = src ? src.ptr : null;
		SDL_Rect* dst_ptr = dst ? dst.ptr : null;
		
		return SDL_BlitSurface(srfc, src_ptr, this._sdl_surface, dst_ptr) == 0;
	}
	
	/**
	 * Returns a subsurface from this surface. rect represents the viewport.
	 * The subsurface is a separate Surface object.
	 */
	Surface subSurface(ref const ShortRect rect) {
		SDL_Surface* sub = this.create(rect.width, rect.height);
		assert(sub !is null);
		
		if (SDL_BlitSurface(this._sdl_surface, rect.ptr, sub, null) != 0)
			throw new Exception("An error occured by blitting the subsurface.");
		
		return Surface(sub, true);
	}
	
	/**
	 * Rvalue version
	 */
	Surface subSurface(const ShortRect rect) {
		return this.subSurface(rect);
	}
	
	/**
	 * Returns an new flipped Surface
	 * The current Surface is not modified.
	 *
	 * Note: This function is slow
	 */
	Surface flip(Flip flip) {
		ubyte* pixels = cast(ubyte*) this.getPixels();
		scope(exit) delete pixels;
		
		const ubyte bytes = this.countBytes();
		const size_t memSize = this.width * this.height * bytes;
		
		ubyte[] newPixels = new ubyte[memSize];
		scope(exit) delete newPixels;
		
		final switch (flip) {
			case Flip.Vertical:
				const size_t rowSize = this.width * bytes;
				
				ubyte* source = &pixels[this.width * (this.height - 1) * bytes];
				ubyte* dest = &newPixels[0];
				
				for (ushort y = 0; y < this.height; ++y) {
					memcpy(dest, source, rowSize);
					//std.algorithm.reverse(dest[0 .. rowSize]);
					source -= rowSize;
					dest += rowSize;
				}
				break;
			case Flip.Horizontal:
				for (ushort y = 0; y < this.height; ++y) {
					ubyte* source = &pixels[y * this.width * bytes];
					ubyte* dest = &newPixels[(y + 1) * this.width * bytes - bytes];
					
					for (ushort x = 0; x < this.width; ++x) {
						dest[0] = source[0];
						dest[1] = source[1];
						dest[2] = source[2];
						if (bytes == 4)
							dest[3] = source[3];
						
						source += bytes;
						dest -= bytes;
					}
				}
				break;
			case Flip.Vertical | Flip.Horizontal:
				newPixels[] = pixels[0 .. memSize];
				reverse(newPixels);
				break;
		}
		
		return Surface.make(newPixels.ptr, this.width, this.height, this.countBits());
	}
}