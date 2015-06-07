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
module Dgame.Graphic.Texture;

private:

import derelict.opengl3.gl;

import Dgame.Math.Rect;

import Dgame.Graphic.Surface;
import Dgame.Graphic.Color;

import Dgame.Internal.m3;

public:

/**
 * A Texture is a 2 dimensional pixel reprasentation.
 * It is a wrapper of an OpenGL Texture.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Texture {
    /**
     * Supported Texture Format
     */
    enum Format {
        None = 0,   /// Take this if you want to declare that you give no Format.
        RGB = GL_RGB,   /// Alias for GL_RGB
        RGBA = GL_RGBA, /// Alias for GL_RGBA
        BGR = GL_BGR,   /// Alias for GL_BGR
        BGRA = GL_BGRA, /// Alias for GL_BGRA
        RGB8 = GL_RGB8,   /// 8 Bit RGB Format
        RGB16 = GL_RGB16, /// 16 Bit RGB Format
        RGBA8 = GL_RGBA8, /// 8 Bit RGBA Format
        RGBA16 = GL_RGBA16, /// 16 Bit RGBA Format
        Alpha = GL_ALPHA,   /// Alias for GL_ALPHA
        Luminance = GL_LUMINANCE,   /// Alias for GL_LUMINANCE
        LuminanceAlpha = GL_LUMINANCE_ALPHA /// Alias for GL_LUMINANCE_ALPHA
    }
    
private:
    uint _texId;
    
    uint _width;
    uint _height;
    ubyte _depth;
    
    bool _isSmooth;
    bool _isRepeated;
    
    Format _format;

    @nogc
    void _init() nothrow {
        if (_texId == 0) {
            glGenTextures(1, &_texId);
            this.bind();
        }
    }

public:
    /**
     * CTor
     */
    @nogc
    this(void* memory, uint width, uint height, Format fmt) nothrow {
        this.loadFromMemory(memory, width, height, fmt);
    }

    /**
     * CTor
     */
    @nogc
    this(const Surface srfc, Format fmt = Format.None) nothrow {
        this.loadFrom(srfc, fmt);
    }

    /**
     * Postblit is disabled
     */
    @disable
    this(this);
    
    /**
     * DTor
     */
    @nogc
    ~this() nothrow {
        if (_texId != 0)
            glDeleteTextures(1, &_texId);
    }
    
    /**
     * Returns the currently bound texture id.
     */
    @nogc
    static int currentlyBound() nothrow {
        int current;
        glGetIntegerv(GL_TEXTURE_BINDING_2D, &current);
        
        return current;
    }
    
    /**
     * Returns the Texture Id.
     */
    @property
    @nogc
    uint id() const pure nothrow {
        return _texId;
    }
    
    /**
     * Returns if the texture is used.
     */
    @nogc
    bool isValid() const pure nothrow {
        return _texId != 0;
    }
    
    /**
     * Returns the width of this Texture
     */
    @property
    @nogc
    uint width() const pure nothrow {
        return _width;
    }
    
    /**
     * Returns the height of this Texture.
     */
    @property
    @nogc
    uint height() const pure nothrow {
        return _height;
    }
    
    /**
     * Returns the depth. May often 24 or 32.
     */
    @property
    @nogc
    ubyte depth() const pure nothrow {
        return _depth;
    }
    
    /**
     * Returns the Format.
     *
     * See: Format enum.
     */
    @property
    @nogc
    Format format() const pure nothrow {
        return _format;
    }
    
    /**
     * Binds this Texture.
     * Means this Texture is now activated.
     */
    @nogc
    void bind() const nothrow {
        glBindTexture(GL_TEXTURE_2D, _texId);
    }
    
    /**
     * Binds this Texture.
     * Means this Texture is now deactivated.
     */
    @nogc
    void unbind() const nothrow {
        glBindTexture(GL_TEXTURE_2D, 0);
    }
    
    /**
     * Returns true, if this Texture is currently activated.
     */
    @nogc
    bool isCurrentlyBound() const nothrow {
        return Texture.currentlyBound() == _texId;
    }
    
    /**
     * Set smooth filter.
     */
    @nogc
    void setSmooth(bool smooth) nothrow {
        if (smooth != _isSmooth) {
            _isSmooth = smooth;
            
            if (_texId != 0) {
                this.bind();
                
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _isSmooth ? GL_LINEAR : GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _isSmooth ? GL_LINEAR : GL_NEAREST);
            }
        }
    }
    
    /**
     * Returns if smooth filter are activated.
     */
    @nogc
    bool isSmooth() const pure nothrow {
        return _isSmooth;
    }
    
    /**
     * Set repeating.
     **/
    @nogc
    void setRepeat(bool repeat) nothrow {
        if (repeat != _isRepeated) {
            _isRepeated = repeat;
            
            if (_texId != 0) {
                this.bind();
                
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
            }
        }
    }
    
    /**
     * Returns if repeating is enabled.
     */
    @nogc
    bool isRepeated() const pure nothrow {
        return _isRepeated;
    }

    /**
     * Load from Surface
     */
    @nogc
    void loadFrom(const Surface srfc, Format fmt = Format.None) nothrow {
        assert(srfc.isValid(), "Cannot load invalid Surface");

        if (fmt == Format.None) {
            fmt = bitsToFormat(srfc.bits);
            version (BigEndian) fmt = switchFormat(fmt);
        }

        this.loadFromMemory(srfc.pixels, srfc.width, srfc.height, fmt);
    }

    /**
     * Load from memory.
     */
    @nogc
    void loadFromMemory(const void* memory, uint width, uint height, Format fmt) nothrow {
        _init();

        assert(width != 0 && height != 0, "Width and height cannot be 0.");
        assert(fmt != Format.None, "Need a valid format.");

        _format = fmt == Format.None ? bitsToFormat(depth) : fmt;
        assert(_format != Format.None, "Need Texture.Format or depth > 24");

        if (width == _width && height == _height)
            this.update(memory);
        else {
            _depth = formatToBits(_format);
            
            this.bind();
            
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _isSmooth ? GL_LINEAR : GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _isSmooth ? GL_LINEAR : GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
            glTexImage2D(GL_TEXTURE_2D, 0, depth / 8, width, height, 0, _format, GL_UNSIGNED_BYTE, memory);

            _width  = width;
            _height = height;
        }
    }

    /**
     * Set a colorkey.
     */
    @nogc
    void setColorkey(const Color4b colorkey) nothrow {
        if (_texId == 0)
            return;

        // Get the pixel memory
        immutable size_t msize = this.getByteSize();
        void[] mem = make!(void[])(msize);
        scope(exit) unmake(mem);

        void[] memory = this.getPixels(mem[0 .. msize]);

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
        
        this.update(memory.ptr);
    }

    /**
     * Returns the byte size of the Texture
     */
    @nogc
    size_t getByteSize() const pure nothrow {
        if (_depth > 0)
            return _width * _height * (_depth / 8);
        return 0;
    }
    
    /**
     * Returns the pixel data of this Texture or null if this Texture isn't valid.
     * pixels is used to store the pixel data.
     */
    @nogc
    void[] getPixels(void[] pixels) const nothrow {
        immutable size_t msize = this.getByteSize();
        if (msize == 0)
            return null;

        assert(pixels.length >= msize, "Your given memory is too short.");

        this.bind();

        glGetTexImage(GL_TEXTURE_2D, 0, _format, GL_UNSIGNED_BYTE, pixels.ptr);

        return pixels;
    }

    /**
     * Returns the pixel of this Texture or null if this Texture isn't valid.
     *
     * Note: this method <b>allocates</b> GC memory.
     */
    void[] getPixels() const nothrow {
        immutable size_t msize = this.getByteSize();
        if (msize == 0)
            return null;

        void[] pixels = new void[msize];

        return this.getPixels(pixels);
    }

    /**
     * Update the pixel data of this Texture.
     * The second parameter is a pointer to the area which is updated.
     * If it is null (default) the whole Texture will be updated.
     * The third parameter is the format of the pixels.
     */
    @nogc
    void update(const void* memory, const Rect* rect = null, Format fmt = Format.None) const nothrow {
        if (_texId == 0)
            return;

        assert(memory, "Invalid memory");
        assert(_width != 0 && _height != 0, "width or height is 0.");

        fmt = fmt == Format.None ? _format : fmt;

        uint width = _width, height = _height;
        int x = 0, y = 0;
        
        if (rect) {
            assert(rect.width <= _width && rect.height <= _height, "Rect is greater as the Texture.");
            assert(rect.x < _width && rect.y < _height, "x or y of the Rect is greater as the Texture.");
            
            width  = rect.width;
            height = rect.height;
            
            x = rect.x;
            y = rect.y;
        }

        this.bind();
        
        glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, fmt, GL_UNSIGNED_BYTE, memory);
    }
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
@nogc
ubyte formatToBits(Texture.Format fmt) pure nothrow {
    switch (fmt) {
        case Texture.Format.RGB:
        case Texture.Format.BGR:
            return 24;
        case Texture.Format.RGBA:
        case Texture.Format.BGRA:
            return 32;
        case Texture.Format.RGBA16: return 16;
        case Texture.Format.RGBA8: return 8;
        default: return 0;
    }
}

unittest {
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
@nogc
Texture.Format bitsToFormat(ubyte bits, bool reverse = false) pure nothrow {
    switch (bits) {
        case 32: return !reverse ? Texture.Format.RGBA : Texture.Format.BGRA;
        case 24: return !reverse ? Texture.Format.RGB : Texture.Format.BGR;
        case 16: return Texture.Format.RGBA16;
        case  8: return Texture.Format.RGBA8;
        default: return Texture.Format.None;
    }
}

unittest {
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
@nogc
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
