module Dgame.Graphics.RenderTarget;

private {
	import std.c.string : memcpy;
	
	import derelict.sdl2.sdl;
	
	import Dgame.Math.Rect;
	import Dgame.Graphics.Surface;
	import Dgame.Graphics.Color;
	import Dgame.Window.Window;
	import Dgame.Core.SmartPointer;
}

public import Dgame.Graphics.HwSurface;

/**
 * RenderTarget support (hardware) accelerated rendering.
 *
 * Author: rschuett
 */
struct RenderTarget {
public:
	/**
	 * Supported BlendModes
	 */
	enum BlendMode {
		None  = SDL_BLENDMODE_NONE,	/** no blending */
		Blend = SDL_BLENDMODE_BLEND,	/** dst = (src * A) + (dst * (1-A)) */
		Add   = SDL_BLENDMODE_ADD,		/** dst = (src * A) + dst */
		Mod   = SDL_BLENDMODE_MOD,		/** dst = src * dst */
	}
	
	/**
	 * Supported Flags
	 */
	enum Flags {
		Software = SDL_RENDERER_SOFTWARE,			/** the renderer is a software fallback */
		HwAccel  = SDL_RENDERER_ACCELERATED,		/** the renderer uses hardware acceleration */
		VSync    = SDL_RENDERER_PRESENTVSYNC,		/** present is synchronized with the refresh rate */
		TargetTexture = SDL_RENDERER_TARGETTEXTURE	/** the renderer supports rendering to texture */
	}
	
	/**
	 * Flags
	 */
	const Flags flags;
	
private:
	unique_ptr!(SDL_Renderer, SDL_DestroyRenderer) _target;
	
	ushort _width;
	ushort _height;
	
private:
	
	/**
	 * CTor
	 */
	this(SDL_Renderer* renderer, ushort w, ushort h) {
		assert(renderer !is null, "Null Renderer.");
		
		this._target = make_unique(renderer);
		this._width  = w;
		this._height = h;
	}
	
	/**
	 * Set a texture as the current rendering target.
	 */
	bool setTarget(SDL_Texture* tex, ushort w, ushort h) {
		this._width  = w;
		this._height = h;
		
		return SDL_SetRenderTarget(this._target, tex) == 0;
	}
	
public:
	
	/**
	 * Use this function to get the renderer associated with the window.
	 */
	static RenderTarget getFrom(Window win) {
		SDL_Window* window = SDL_GetWindowFromID(win.id);
		
		return RenderTarget(SDL_GetRenderer(window), win.width, win.height);
	}
	
	/**
	 * Use this function to get the number of 2D rendering drivers available for the current display.
	 */
	static int countDrivers() {
		return SDL_GetNumRenderDrivers();
	}
	
	/**
	 * Use this function to create a 2D rendering context for a window.
	 */
	this(Window win, Flags flags) {
		SDL_Window* window = SDL_GetWindowFromID(win.id);
		
		this(SDL_CreateRenderer(window, -1, flags), win.width, win.height);
		
		this.flags = flags;
	}
	
	/**
	 * Use this function to create a 2D software rendering context for a Surface.
	 */
	this(ref Surface srfc) {
		this(SDL_CreateSoftwareRenderer(srfc.ptr), srfc.width, srfc.height);
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref RenderTarget rhs) {
		this._target.reset(rhs._target);
		
		this._width = rhs._width;
		this._height = rhs._height;
	}
	
	/**
	 * opAssign
	 * Rvalue version
	 */
	void opAssign(RenderTarget rhs) {
		this.opAssign(rhs);
	}
	
	@disable
	this(this);
	
	/**
	 * Use this function to destroy the rendering context for a window and free associated textures.
	 */
	void free() {
		this._target.reset(null);
	}
	
	/**
	 * Returns the width
	 */
	@property
	ushort width() const pure nothrow {
		return this._width;
	}
	
	/**
	 * Returns the height
	 */
	@property
	ushort height() const pure nothrow {
		return this.height;
	}
	
	/**
	 * Use this function to update the screen with rendering performed.
	 */
	void present() {
		SDL_RenderPresent(this._target);
	}
	
	/**
	 * Use this function to set the blend mode for a texture, used by 'copy'.
	 */
	void setBlendMode(BlendMode bmode) {
		SDL_SetRenderDrawBlendMode(this._target, bmode);
	}
	
	/**
	 * Use this function to get the blend mode used for texture copy operations.
	 */
	BlendMode getBlendMode() {
		SDL_BlendMode blendMode;
		SDL_GetRenderDrawBlendMode(this._target, &blendMode);
		
		return cast(BlendMode) blendMode;
	}
	
	/**
	 * Use this function to set the color used for drawing operations (clear).
	 */
	void setDrawColor(ref const Color col) {
		this.setDrawColor(col.red, col.green, col.blue, col.alpha);
	}
	
	/**
	 * Rvalue version
	 */
	void setDrawColor(const Color col) {
		this.setDrawColor(col);
	}
	
	/**
	 * Use this function to set the color used for drawing operations (clear).
	 */
	void setDrawColor(ubyte r, ubyte g, ubyte b, ubyte a) {
		SDL_SetRenderDrawColor(this._target, r, g, b, a);
	}
	
	/**
	 * Use this function to create a texture for a rendering context.
	 */
	HwSurface createHwSurface(ushort width, ushort height, HwSurface.Access access) {
		enum format = SDL_PIXELFORMAT_UNKNOWN;
		
		SDL_Texture* tex = SDL_CreateTexture(this._target, format, access, width, height);
		
		return HwSurface(tex, access);
	}
	
	/**
	 * Use this function to create a texture from an existing surface.
	 */
	HwSurface createHwSurface(ref Surface srfc, bool release = false,
	                          HwSurface.Access access = HwSurface.Access.Static)
	{
		scope(exit) if (release) srfc.free();
		
		if (access & HwSurface.Access.Static) {
			SDL_Texture* tex = SDL_CreateTextureFromSurface(this._target, srfc.ptr);
			
			return HwSurface(tex, access);
		}
		
		HwSurface hw = this.createHwSurface(srfc.width, srfc.height, access);
		hw.update(srfc.getPixels(), null);
		
		return hw;
	}
	
	/**
	 * Rvalue version
	 */
	HwSurface createHwSurface(Surface srfc, bool release = false,
	                          HwSurface.Access access = HwSurface.Access.Static)
	{
		return this.createHwSurface(srfc, release, access);
	}
	
	/**
	 * Set a Surface as the current rendering target.
	 */
	bool setTarget(ref Surface srfc) {
		SDL_Texture* tex = SDL_CreateTextureFromSurface(this._target, srfc.ptr);
		
		return this.setTarget(tex, srfc.width, srfc.height);
	}
	
	/**
	 * Set a HwSurface as the current rendering target.
	 */
	bool setTarget(ref HwSurface hw) {
		return this.setTarget(hw.ptr, hw.width, hw.height);
	}
	
	/**
	 * Use this function to copy a portion of the texture to the current rendering target.
	 */
	bool copy(ref HwSurface hw, const ShortRect* src = null, const ShortRect *dst  = null) {
		const SDL_Rect* _src = src ? src.ptr : null;
		const SDL_Rect* _dst = dst ? dst.ptr : null;
		
		return SDL_RenderCopy(this._target, hw.ptr, _src, _dst) == 0;
	}
	
	/**
	 * Use this function to clear the current rendering target with the drawing color.
	 */
	void clear() {
		SDL_RenderClear(this._target);
	}
	
	/**
	 * Use this function to set the drawing area for rendering on the current target.
	 */
	void setViewport(ref const ShortRect view) {
		SDL_RenderSetViewport(this._target, view.ptr);
	}
	
	/**
	 * Rvalue version
	 */
	void setViewport(const ShortRect view) {
		this.setViewport(view);
	}
	
	/**
	 * Use this function to get the drawing area for the current target.
	 */
	ShortRect getViewport() {
		ShortRect rect;
		SDL_RenderGetViewport(this._target, rect.ptr);
		
		return rect;
	}
	
	/**
	 * Use this function to read pixels from the current rendering target.
	 * Warning: This is a very slow operation, and should not be used frequently.
	 * Warning: This method <b>allocate</b> memory.
	 *
	 * rect represents the area to read, or null for the entire render target
	 */
	void* readPixels(const ShortRect* rect) {
		void[] pixels = new void[rect.width * rect.height * 4];
		SDL_RenderReadPixels(this._target, rect ? rect.ptr : null, 0, &pixels[0], this._width * 4);
		
		return &pixels[0];
	}
}
