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

import Dgame.Internal.Error;

// @@ Fix for 2.066 @@ //
@nogc
bool exists(string filename) nothrow {
    import core.stdc.stdio : fopen, fclose;

    auto f = fopen(filename.ptr, "r");
    scope(exit) fclose(f);

    return f !is null;
}

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
    
    /**
     * Supported Color Masks
     */
    enum Mask : ubyte {
        Red   = 1, /// Red Mask
        Green = 2, /// Green Mask
        Blue  = 4, /// Blue Mask
        Alpha = 8  /// Alpha Mask
    }
    
    enum ubyte RMask = 0;
    enum ubyte GMask = 0;
    enum ubyte BMask = 0;
    
    version (LittleEndian)
        enum uint AMask = 0xff000000;
    else
        enum uint AMask = 0x000000ff;

private:
    SDL_Surface* _surface;

    @nogc
    static SDL_Surface* create(uint width, uint height, ubyte depth = 32) nothrow {
        assert(depth == 8 || depth == 16 || depth == 24 || depth == 32, "Invalid depth.");

        return SDL_CreateRGBSurface(0, width, height, depth, RMask, GMask, BMask, AMask);
    }
    
    @nogc
    static SDL_Surface* create(void* memory, uint width, uint height, ubyte depth = 32) nothrow {
        assert(memory, "Memory is empty.");
        assert(depth == 8 || depth == 16 || depth == 24 || depth == 32, "Invalid depth.");

        return SDL_CreateRGBSurfaceFrom(memory, width, height, depth, (depth / 8) * width, RMask, GMask, BMask, AMask);
    }

public:
    /**
     * CTor
     */
    @nogc
    this(SDL_Surface* srfc) pure nothrow {
        assert(srfc, "Invalid SDL_Surface.");
        assert(srfc.pixels, "Invalid pixel data.");

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
    this(uint width, uint height, ubyte depth = 32) nothrow {
        assert(depth == 8 || depth == 16 || depth == 24 || depth == 32, "Invalid depth.");

        _surface = Surface.create(width, height, depth);

        assert(_surface, "Invalid SDL_Surface.");
        assert(_surface.pixels, "Invalid pixel data.");
    }
    
    /**
     * Make an new Surface of the given memory, width, height and depth.
     */
    @nogc
    this(void* memory, uint width, uint height, ubyte depth = 32) nothrow {
        assert(depth == 8 || depth == 16 || depth == 24 || depth == 32, "Invalid depth.");

        _surface = Surface.create(memory, width, height, depth);

        assert(_surface, "Invalid SDL_Surface.");
        assert(_surface.pixels, "Invalid pixel data.");
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
        //import std.file : exists;
        import core.stdc.stdio : printf;

        immutable bool ex = exists(filename);
        if (!ex) {
            printf("File %s does not exists.\n", filename.ptr);
            return false;
        }

        SDL_FreeSurface(_surface); // free old surface

        _surface = IMG_Load(filename.ptr);
        if (!_surface) {
            printf("Could not load image %s. Error: %s.\n", filename.ptr, SDL_GetError());
            return false;
        }
        
        assert(_surface.pixels, "Invalid pixel data.");

        return true;
    }
    
    /**
     * Load from memory.
     */
    @nogc
    bool loadFromMemory(void* memory, ushort width, ushort height, ubyte depth = 32) nothrow {
        assert(memory, "Memory is empty.");
        assert(depth == 8 || depth == 16 || depth == 24 || depth == 32, "Invalid depth.");

        SDL_FreeSurface(_surface); // free old surface

        _surface = SDL_CreateRGBSurfaceFrom(memory, width, height, depth, (depth / 8) * width, RMask, GMask, BMask, AMask);
        if (!_surface) {
            import core.stdc.stdio : printf;

            printf("Could not load image. Error: %s.\n", SDL_GetError());
            return false;
        }
        
        assert(_surface.pixels, "Invalid pixel data.");

        return true;
    }
    
    /**
     * Save the current pixel data to the file.
     */
    @nogc
    bool saveToFile(string filename) nothrow {
        immutable int result = IMG_SavePNG(_surface, filename.ptr);
        if (result != 0) {
            import core.stdc.stdio : printf;

            printf("Could not save image %s. Error: %s.\n", filename.ptr, SDL_GetError());
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
    void fill()(auto ref const Color col, const Rect* rect = null) nothrow {
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
        if (_surface && SDL_LockSurface(_surface) == 0)
            return true;
        return false;
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
     * Works like <code>SDL_DisplayFormat</code>.
     */
    @nogc
    void adaptTo(ref Surface srfc) nothrow {
        assert(srfc.isValid(), "Could not adapt to invalid surface.");
        assert(this.isValid(), "Could not adapt a invalid surface.");

        this.adaptTo(srfc.format);
    }
    
    /**
     * Use this function to adapt the format of another Surface to this surface.
     * Works like <code>SLD_DisplayFormat</code>.
     */
    @nogc
    bool adaptTo(const SDL_PixelFormat* fmt) nothrow {
        if (!_surface)
            return false;

        assert(fmt, "Null format is invalid.");

        SDL_Surface* adapted = SDL_ConvertSurface(_surface, fmt, 0);
        if (adapted) {
            SDL_FreeSurface(_surface);
            _surface = adapted;

            return true;
        }

        import core.stdc.stdio : printf;
        printf("Image could not be adapted: %s\n", SDL_GetError());

        return false;
    }
    
    /**
     * Set the colorkey.
     */
    @nogc
    void setColorkey()(auto ref const Color4b col) nothrow {
        if (!_surface)
            return;

        immutable uint key = SDL_MapRGBA(_surface.format, col.red, col.green, col.blue, col.alpha);
        SDL_SetColorKey(_surface, SDL_TRUE, key);
    }
    
    /**
     * Returns the current colorkey.
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
    void setClipRect()(auto ref const Rect clip) nothrow {
        SDL_Rect a = void;
        if (_surface)
            SDL_SetClipRect(_surface, _transfer(clip, a));
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
     * Returns the PixelFormat
     */
    @property
    @nogc
    const(SDL_PixelFormat*) format() const pure nothrow {
        if (!_surface)
            return null;
        return _surface.format;
    }
    
    /**
     * Returns if the given color match the color of the given mask of the surface.
     *
     * See: Surface.Mask enum.
     */
    @nogc
    bool isMask()(Mask mask, auto ref const Color4b col) const nothrow {
        if (!_surface)
            return false;

        immutable uint map = SDL_MapRGBA(_surface.format, col.red, col.green, col.blue, col.alpha);

        return this.isMask(mask, map);
    }
    
    /**
     * Returns if the given converted color match the color of the given mask of the surface.
     *
     * See: Surface.Mask enum.
     */
    @nogc
    bool isMask(Mask mask, uint col) const pure nothrow {
        if (!_surface)
            return false;

        bool[4] result;
        ubyte index = 0;
        
        if (mask & Mask.Red)
            result[index++] = _surface.format.Rmask == col;
        if (mask & Mask.Green)
            result[index++] = _surface.format.Gmask == col;
        if (mask & Mask.Blue)
            result[index++] = _surface.format.Bmask == col;
        if (mask & Mask.Alpha)
            result[index++] = _surface.format.Amask == col;
        
        for (ubyte i = 0; i < index; ++i) {
            if (!result[i])
                return false;
        }
        
        return true;
    }
    
    /**
     * Returns the pixel at the given coordinates.
     */
    @nogc
    int getPixelAt()(auto ref const Vector2i pos) const nothrow {
        if (!_surface)
            return -1;

        immutable uint* pixels = cast(uint*) this.pixels;
        assert(pixels, "No pixel at this point.");
        
        return pixels[(pos.y * _surface.w) + pos.x];
    }
    
    /**
     * Put a new pixel at the given coordinates.
     */
    @nogc
    void putPixelAt()(auto ref const Vector2i pos, uint pixel) nothrow {
        if (!_surface)
            return;

        immutable uint* pixels = cast(uint*) this.pixels();
        assert(pixels, "No pixel at this point.");
        
        pixels[(pos.y * _surface.w) + pos.x] = pixel;
    }
    
    /**
     * Returns the color on the given position.
     */
    @nogc
    Color4b getColorAt()(auto ref const Vector2i pos) const nothrow {
        if (!_surface)
            return Color4b.Black;

        immutable uint len = this.width * this.height;
        if ((pos.x * pos.y) <= len) {
            immutable uint pixel = this.getPixelAt(pos);
            
            ubyte r, g, b, a;
            SDL_GetRGBA(pixel, _surface.format, &r, &g, &b, &a);
            
            return Color4b(r, g, b, a);
        }
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
        if (!result) {
            import core.stdc.stdio : printf;

            printf("Could not blit surface: %s\n", SDL_GetError());
        }

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
        if (!result) {
            import core.stdc.stdio : printf;

            printf("Could not blit surface: %s\n", SDL_GetError());
        }

        return result;
    }
    
    /**
     * Returns a subsurface from this surface. rect represents the viewport.
     * The subsurface is a separate Surface object.
     */
    @nogc
    Surface subSurface()(auto ref const Rect rect) nothrow {
        assert(!rect.isEmpty(), "Cannot take a empty subsurface.");
        assert(_surface, "Cannot take a subsurface from null.");

        SDL_Surface* sub = this.create(rect.width, rect.height);
        assert(sub, "Failed to construct a sub surface.");

        SDL_Rect clip = void;

        immutable int result = SDL_BlitSurface(_surface, _transfer(rect, clip), sub, null);
        assert_fmt(result != 0, "Could not blit Surface: %s\n", SDL_GetError());
        
        return Surface(sub);
    }

    @nogc
    /+package(Dgame)+/void setAsIconOf(SDL_Window* wnd) nothrow {
        assert(wnd, "Invalid SDL_Window");
        assert(_surface, "Invalid SDL_Surface");

        SDL_SetWindowIcon(wnd, _surface);
    }

    @nogc
    /+package(Dgame)+/SDL_Cursor* setAsCursorAt(int hx, int hy) nothrow {
        return SDL_CreateColorCursor(_surface, hx, hy);
    }
}
