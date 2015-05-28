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
module Dgame.Graphic.Surface;

private:

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import Dgame.Math.Rect;
import Dgame.Math.Vector2;

import Dgame.Graphic.Color;
import Dgame.Graphic.Masks;

import Dgame.Internal.Error;
import Dgame.Internal.d2c;

public:

/**
 * Surface is a wrapper for a SDL_Surface and can load and save images.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Surface {
    /**
     * Supported BlendModes
     */
    enum BlendMode : ubyte {
        None   = SDL_BLENDMODE_NONE,  /// no blending
        Blend  = SDL_BLENDMODE_BLEND, /// dst = (src * A) + (dst * (1-A))
        Add    = SDL_BLENDMODE_ADD,   /// dst = (src * A) + dst
        Mod    = SDL_BLENDMODE_MOD    /// dst = src * dst
    }

private:
    SDL_Surface* _surface;

    @nogc
    static SDL_Surface* create(ref const Masks masks, uint width, uint height, ubyte depth, void* memory) nothrow {
        SDL_Surface* surface;
        if (memory) {
            surface = SDL_CreateRGBSurfaceFrom(
                memory,
                width, height, depth, 
                (depth / 8) * width,
                masks.red, masks.green, masks.blue, masks.alpha
            );
        } else {
            surface = SDL_CreateRGBSurface(
                0,
                width, height, depth,
                masks.red, masks.green, masks.blue, masks.alpha
            );
        }

        assert_fmt(surface, "Invalid SDL_Surface. Error: %s\n", SDL_GetError());
        assert_fmt(surface.pixels, "Invalid pixel data. Error: %s\n", SDL_GetError());

        return surface;
    }

public:
    /**
     * CTor
     */
    @nogc
    this(SDL_Surface* srfc) nothrow {
        assert_fmt(srfc, "Invalid SDL_Surface. Error: %s\n", SDL_GetError());
        assert_fmt(srfc.pixels, "Invalid pixel data. Error: %s\n", SDL_GetError());

        _surface = srfc;
    }

    /**
     * CTor
     */
    @nogc
    this(string filename) nothrow {
        this.loadFromFile(filename);
    }

    /**
     * Make a new Surface of the given width, height and depth.
     */
    @nogc
    this(uint width, uint height, ubyte depth = 32, const Masks masks = Masks.init) nothrow {
        _surface = Surface.create(masks, width, height, depth, null);
    }
    
    /**
     * Make an new Surface of the given memory, width, height and depth.
     */
    @nogc
    this(void* memory, uint width, uint height, ubyte depth = 32, const Masks masks = Masks.init) nothrow {
        _surface = Surface.create(masks, width, height, depth, memory);
    }
    
    /**
     * Postblit is allowed and increases the internal ref count
     */
    @nogc
    this(this) nothrow {
        if (_surface)
            _surface.refcount++;
    }
    
    /**
     * DTor
     */
    @nogc
    ~this() nothrow {
        SDL_FreeSurface(_surface);
    }

    /**
     * Returns the current ref count / usage
     */
    @property
    @nogc
    int refCount() const pure nothrow {
        return _surface ? _surface.refcount : 0;
    }
    
    /**
     * Returns if the Surface is valid. Which means that the Surface has valid data.
     */
    @nogc
    bool isValid() const pure nothrow {
        return _surface && _surface.pixels;
    }
    
    /**
     * Load from filename. If any data is already stored, the data will be freed.
     */
    @nogc
    bool loadFromFile(string filename) nothrow {
        import std.file : exists;

        immutable bool ex = exists(filename);
        if (!ex) {
            print_fmt("File %s does not exists.\n", toStringz(filename));
            return false;
        }

        SDL_FreeSurface(_surface); // free old surface

        _surface = IMG_Load(toStringz(filename));
        if (!_surface) {
            print_fmt("Could not load image %s. Error: %s.\n", toStringz(filename), SDL_GetError());
            return false;
        }
        
        assert(_surface.pixels, "Invalid pixel data.");

        return true;
    }
    
    /**
     * Load from memory.
     */
    @nogc
    bool loadFromMemory(void* memory, ushort width, ushort height, ubyte depth = 32, const Masks masks = Masks.init) nothrow {
        SDL_FreeSurface(_surface); // free old surface
        _surface = Surface.create(masks, width, height, depth, memory);

        return true;
    }
    
    /**
     * Save the current pixel data to the file.
     */
    @nogc
    bool saveToFile(string filename) nothrow {
        immutable int result = IMG_SavePNG(_surface, toStringz(filename));
        if (result != 0) {
            print_fmt("Could not save image %s. Error: %s.\n", toStringz(filename), SDL_GetError());
            return false;
        }

        return true;
    }
    
    /**
     * Fills a specific area of the surface with the given color.
     * The second parameter is a pointer to the area.
     * If it's null, the whole Surface is filled.
     */
    @nogc
    void fill(const Color4b col, const Rect* rect = null) nothrow {
        if (!_surface)
            return;

        SDL_Rect a = void;
        const SDL_Rect* ptr = rect ? _transfer(*rect, a) : null;

        immutable uint key = SDL_MapRGBA(_surface.format, col.red, col.green, col.blue, col.alpha);
        SDL_FillRect(_surface, ptr, key);
    }
    
    /**
     * Use this function to set the RLE acceleration hint for a surface.
     * RLE (Run-Length-Encoding) is a way of compressing data.
     * If RLE is enabled, color key and alpha blending blits are much faster, 
     * but the surface must be locked before directly accessing the pixels.
     *
     * Returns: whether the call succeeded or not
     */
    @nogc
    bool optimizeRLE(bool enable) nothrow {
        if (!_surface)
            return false;
        return SDL_SetSurfaceRLE(_surface, enable) == 0;
    }
    
    /**
     * Use this function to set up a surface for directly accessing the pixels.
     *
     * Returns: whether the call succeeded or not
     */
    @nogc
    bool lock() nothrow {
        return _surface && SDL_LockSurface(_surface) == 0;
    }
    
    /**
     * Use this function to release a surface after directly accessing the pixels.
     */
    @nogc
    void unlock() nothrow {
        if (_surface)
            SDL_UnlockSurface(_surface);
    }
    
    /**
     * Returns whether this Surface is locked or not.
     */
    @nogc
    bool isLocked() const pure nothrow {
        return _surface ? _surface.locked != 0 : false;
    }
    
    /**
     * Use this function to determine whether a surface must be locked for access.
     */
    @nogc
    bool mustLock() nothrow {
        if (!_surface)
            return false;
        return SDL_MUSTLOCK(_surface) == SDL_TRUE;
    }
    
    /**
     * Use this function to adapt the format of another Surface to this surface.
     */
    @nogc
    bool adaptTo(ref Surface srfc) nothrow {
        return this.adaptTo(srfc.bits);
    }
    
    /**
     * Use this function to adapt the format of another Surface depth to this surface.
     */
    @nogc
    bool adaptTo(ubyte depth) nothrow {
        if (!_surface)
            return false;

        SDL_PixelFormat fmt;
        fmt.BitsPerPixel = depth;

        SDL_Surface* adapted = SDL_ConvertSurface(_surface, &fmt, 0);
        if (adapted) {
            SDL_FreeSurface(_surface);
            _surface = adapted;

            return true;
        }

        print_fmt("Image could not be adapted: %s\n", SDL_GetError());

        return false;
    }
    
    /**
     * Set the colorkey.
     */
    @nogc
    void setColorkey(const Color4b col) nothrow {
        if (!_surface)
            return;

        immutable uint key = SDL_MapRGBA(_surface.format, col.red, col.green, col.blue, col.alpha);
        SDL_SetColorKey(_surface, SDL_TRUE, key);
    }
    
    /**
     * Returns the current colorkey,
     * or Color4b.Black, if the Surface is invalid
     */
    @nogc
    Color4b getColorkey() nothrow {
        if (!_surface)
            return Color4b.Black;

        uint key = 0;
        SDL_GetColorKey(_surface, &key);
        
        ubyte r, g, b, a;
        SDL_GetRGBA(key, _surface.format, &r, &g, &b, &a);
        
        return Color4b(r, g, b, a);
    }
    
    /**
     * Set the Alpha mod.
     */
    @nogc
    void setAlphaMod(ubyte alpha) nothrow {
        if (_surface)
            SDL_SetSurfaceAlphaMod(_surface, alpha);
    }
    
    /**
     * Returns the current Alpha mod.
     */
    @nogc
    ubyte getAlphaMod() nothrow {
        ubyte alpha;
        if (_surface)
            SDL_GetSurfaceAlphaMod(_surface, &alpha);
        return alpha;
    }
    
    /**
     * Set the Blendmode.
     */
    @nogc
    void setBlendMode(BlendMode mode) nothrow {
        if (_surface)
            SDL_SetSurfaceBlendMode(_surface, mode);
    }
    
    /**
     * Returns the current Blendmode.
     */
    @nogc
    BlendMode getBlendMode() nothrow {
        SDL_BlendMode mode;
        if (_surface)
            SDL_GetSurfaceBlendMode(_surface, &mode);
        return cast(BlendMode) mode;
    }
    
    /**
     * Returns the clip rect of this surface.
     * The clip rect is the area of the surface which is drawn.
     */
    @nogc
    Rect getClipRect() nothrow {
        SDL_Rect clip;
        if (_surface)
            SDL_GetClipRect(_surface, &clip);
        return Rect(clip.x, clip.y, clip.w, clip.h);
    }
    
    /**
     * Set the clip rect.
     */
    @nogc
    void setClipRect(const Rect clip) nothrow {
        if (_surface) {
            SDL_Rect a = void;
            SDL_SetClipRect(_surface, _transfer(clip, a));
        }
    }
    
    /**
     * Returns the width.
     */
    @property
    @nogc
    int width() const pure nothrow {
        return _surface ? _surface.w : 0;
    }
    
    /**
     * Returns the height.
     */
    @property
    @nogc
    int height() const pure nothrow {
        return _surface ? _surface.h : 0;
    }
    
    /**
     * Returns the pixel data of this surface.
     */
    @property
    @nogc
    inout(void*) pixels() inout pure nothrow {
        return _surface ? _surface.pixels : null;
    }
    
    /**
     * Count the bits of this surface.
     * Could be 32, 24, 16, 8, 0.
     */
    @property
    @nogc
    ubyte bits() const pure nothrow {
        return _surface ? _surface.format.BitsPerPixel : 0;
    }
    
    /**
     * Count the bytes of this surface.
     * Could be 4, 3, 2, 1, 0. (countBits / 8)
     */
    @property
    @nogc
    ubyte bytes() const pure nothrow {
        return _surface ? _surface.format.BytesPerPixel : 0;
    }
    
    /**
     * Returns the Surface pitch or 0.
     */
    @property
    @nogc
    int pitch() const pure nothrow {
        return _surface ? _surface.pitch : 0;
    }

    /**
     * Returns the Surface color Masks
     */
    @nogc
    Masks getMasks() const pure nothrow {
        if (!_surface)
            return Masks.Zero;

        return Masks(
            _surface.format.Rmask,
            _surface.format.Gmask,
            _surface.format.Bmask,
            _surface.format.Amask
        );
    }

    /**
     * Returns the pixel at the given coordinates.
     */
    @nogc
    int getPixelAt(int x, int y) const nothrow {
        if (!_surface)
            return -1;

        uint* pixels = cast(uint*) this.pixels;
        assert(pixels, "No pixel at this point.");
        
        return pixels[(y * _surface.w) + x];
    }
    
    /**
     * Returns the pixel at the given coordinates.
     */
    @nogc
    int getPixelAt(const Vector2i pos) const nothrow {
        return this.getPixelAt(pos.x, pos.y);
    }
    
    /**
     * Put a new pixel at the given coordinates.
     */
    @nogc
    void putPixelAt(const Vector2i pos, uint pixel) nothrow {
        if (!_surface)
            return;

        uint* pixels = cast(uint*) this.pixels();
        assert(pixels, "No pixel at this point.");
        
        pixels[(pos.y * _surface.w) + pos.x] = pixel;
    }

    /**
     * Returns the color on the given position,
     * or Color4b.Black if the position is out of range.
     */
    @nogc
    Color4b getColorAt(int x, int y) const nothrow {
        if (!_surface)
            return Color4b.Black;

        immutable uint len = this.width * this.height;
        if ((x * y) <= len) {
            immutable uint pixel = this.getPixelAt(x, y);
            
            ubyte r, g, b, a;
            SDL_GetRGBA(pixel, _surface.format, &r, &g, &b, &a);
            
            return Color4b(r, g, b, a);
        }

        return Color4b.Black;
    }
    
    /**
     * Returns the color on the given position.
     */
    @nogc
    Color4b getColorAt(const Vector2i pos) const nothrow {
        return this.getColorAt(pos.x, pos.y);
    }
    
    /**
     * Use this function to perform a fast, low quality,
     * stretch blit between two surfaces of the same pixel format.
     * src is the a pointer to a Rect structure which represents the rectangle to be copied, 
     * or null to copy the entire surface.
     * dst is a pointer to a Rect structure which represents the rectangle that is copied into.
     * null means, that the whole srfc is copied to (0|0).
     */
    @nogc
    bool blitScaled(ref Surface srfc, const Rect* src = null, Rect* dst = null) nothrow {
        if (!srfc.isValid())
            return false;

        SDL_Rect a = void;
        SDL_Rect b = void;

        const SDL_Rect* src_ptr = src ? _transfer(*src, a) : null;
        SDL_Rect* dst_ptr = dst ? _transfer(*dst, b) : null;
        
        immutable bool result = SDL_BlitScaled(srfc._surface, src_ptr, _surface, dst_ptr) == 0;
        if (!result)
            print_fmt("Could not blit surface: %s\n", SDL_GetError());

        return result;
    }
    
    /**
     * Use this function to perform a fast blit from the source surface to the this surface.
     * src is the a pointer to a Rect structure which represents the rectangle to be copied, 
     * or null to copy the entire surface.
     * dst is a pointer to a Rect structure which represents the rectangle that is copied into.
     * null means, that the whole srfc is copied to (0|0).
     */
    @nogc
    bool blit(ref Surface srfc, const Rect* src = null, Rect* dst = null) nothrow {
        if (!srfc.isValid())
            return false;

        SDL_Rect a = void;
        SDL_Rect b = void;

        const SDL_Rect* src_ptr = src ? _transfer(*src, a) : null;
        SDL_Rect* dst_ptr = dst ? _transfer(*dst, b) : null;
        
        immutable bool result = SDL_BlitSurface(srfc._surface, src_ptr, _surface, dst_ptr) == 0;
        if (!result)
            print_fmt("Could not blit surface: %s\n", SDL_GetError());

        return result;
    }
    
    /**
     * Returns a subsurface from this surface. rect represents the viewport.
     * The subsurface is a separate Surface object.
     */
    @nogc
    Surface subSurface(const Rect rect) nothrow {
        assert(!rect.isEmpty(), "Cannot take a empty subsurface.");
        assert(_surface, "Cannot take a subsurface from null.");

        SDL_Surface* sub = this.create(Masks.Zero, rect.width, rect.height, 32, null);
        assert(sub, "Failed to construct a sub surface.");

        SDL_Rect clip = void;

        immutable int result = SDL_BlitSurface(_surface, _transfer(rect, clip), sub, null);
        assert_fmt(result != 0, "Could not blit Surface: %s\n", SDL_GetError());
        
        return Surface(sub);
    }
    
    @nogc
    package(Dgame) void setAsIconOf(SDL_Window* wnd) nothrow {
        assert(wnd, "Invalid SDL_Window");
        assert(_surface, "Invalid SDL_Surface");

        SDL_SetWindowIcon(wnd, _surface);
    }

    @nogc
    package(Dgame) SDL_Cursor* setAsCursorAt(int hx, int hy) nothrow {
        return SDL_CreateColorCursor(_surface, hx, hy);
    }
}
