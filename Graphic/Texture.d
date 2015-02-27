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
static import m3.m3;

import Dgame.Math.Rect;

import Dgame.Graphic.Surface;
import Dgame.Graphic.Color;

public:

/**
 * A Texture is a 2 dimensional pixel reprasentation.
 * It is a wrapper of an OpenGL Texture.
 *
 * Author: rschuett
 */
struct Texture {
    /**
     * Supported Texture Format
     */
    enum Format {
        None = 0,                           /// Take this if you want to declare that you give no Format.
        RGB = GL_RGB,                       /// Alias for GL_RGB
        RGBA = GL_RGBA,                 /// Alias for GL_RGBA
        BGR = GL_BGR,                       /// Alias for GL_BGR
        BGRA = GL_BGRA,                 /// Alias for GL_BGRA
        RGBA16 = GL_RGBA16,                 /// 16 Bit RGBA Format
        RGBA8 = GL_RGBA8,                   /// 8 Bit RGBA Format
        Alpha = GL_ALPHA,                   /// Alias for GL_ALPHA
        Luminance = GL_LUMINANCE,           /// Alias for GL_LUMINANCE
        LuminanceAlpha = GL_LUMINANCE_ALPHA, /// Alias for GL_LUMINANCE_ALPHA
        CompressedRGB = GL_COMPRESSED_RGB,  /// Compressed RGB
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
    uint _texId;
    
    uint _width;
    uint _height;
    ubyte _depth;
    
    bool _isSmooth;
    bool _isRepeated;
    
    Format _format;
    Compression _comp;

    @nogc
    void _init() nothrow {
        if (_texId == 0) {
            glGenTextures(1, &_texId);
            this.bind();
        }
    }

public:
    @nogc
    this(void* memory, uint  width, uint height, ubyte depth, Format fmt = Format.None) nothrow {
        this.loadFromMemory(memory, width, height, depth, fmt);
    }

    @nogc
    this()(auto ref const Surface srfc) nothrow {
        this.loadFrom(srfc);
    }

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
    uint ID() const pure nothrow {
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
    @nogc
    Format getFormat() const pure nothrow {
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
     * Set smooth filter for the (next) load.
     */
    @nogc
    void setSmooth(bool enable) pure nothrow {
        _isSmooth = enable;
    }
    
    /**
     * Returns if smooth filter are activated.
     */
    @nogc
    bool isSmooth() const pure nothrow {
        return _isSmooth;
    }
    
    /**
     * Set repeating for the (next) load.
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
     * (Re)Set the compression mode.
     * 
     * See: Compression enum
     */
    @nogc
    void setCompression(Compression comp) pure nothrow {
        _comp = comp;
    }
    
    /**
     * Returns the current Compression mode.
     *
     * See: Compression enum
     */
    @nogc
    Compression getCompression() const pure nothrow {
        return _comp;
    }
    
    /**
     * Checks whether the current Texture is compressed or not.
     */
    @nogc
    bool isCompressed() const nothrow {
        this.bind();
        
        GLint compressed;
        glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_COMPRESSED, &compressed);
        
        return compressed != 1;
    }

    /**
     * Load from Surface
     */
    @nogc
    void loadFrom()(auto ref const Surface srfc, Format fmt = Format.None) nothrow {
        this.loadFromMemory(srfc.pixels, srfc.width, srfc.height, fmt == Format.None ? srfc.bits : 0, fmt);
    }

    /**
     * Load from memory.
     */
    @nogc
    void loadFromMemory(void* memory, uint width, uint height, ubyte depth, Format fmt = Format.None) nothrow {
        _init();

        assert(width != 0 && height != 0, "Width and height cannot be 0.");
        assert(depth >= 8 || fmt != Format.None, "Need a depth or a format.");

        _format = fmt == Format.None ? bitsToFormat(depth) : fmt;
        assert(_format != Format.None, "Need Texture.Format or depth > 24");
        depth = depth < 8 ? formatToBits(_format) : depth;
        
        this.bind();
        
        Format format = Format.None;
        // Compression
        if (_comp != Compression.None) {
          glHint(GL_TEXTURE_COMPRESSION_HINT, _comp);
          format = compressFormat(_format);
        }
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _isRepeated ? GL_REPEAT : GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _isSmooth ? GL_LINEAR : GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _isSmooth ? GL_LINEAR : GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
        glTexImage2D(GL_TEXTURE_2D, 0, format == Format.None ? depth / 8 : format, width, height, 0, _format, GL_UNSIGNED_BYTE, memory);

        _width  = width;
        _height = height;
        _depth  = depth;
    }

    /**
     * Set a colorkey.
     */
    @nogc
    void setColorkey()(auto ref const Color4b colorkey) nothrow {
        if (_texId == 0)
            return;

        // Get the pixel memory
        immutable uint msize = _width * _height * (_depth / 8);
        void[] mem = m3.m3.make!(void[])(msize);
        scope(exit) m3.m3.destruct(mem);

        void[] memory = this.getMemory(mem[0 .. msize]);
        assert(memory.length, "Cannot set a colorkey for an empty Texture.");

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
     * Returns the pixel of this Texture or null if this Texture isn't valid.
     * If memory is not null and has the same width and height as the Texture,
     * it is used to store the pixel data.
     * Otherwise it <b>allocates</b> GC memory.
     */
    @nogc
    void[] getMemory(void[] memory) const nothrow {
        immutable uint msize = _width * _height * (_depth / 8);
        if (msize == 0)
            return null;

        assert(memory.length < msize, "Your given memory is too short.");

        this.bind();

        glGetTexImage(GL_TEXTURE_2D, 0, _format, GL_UNSIGNED_BYTE, memory.ptr);

        return memory;
    }

    /**
     * Returns the pixel of this Texture or null if this Texture isn't valid.
     * If memory is not null and has the same width and height as the Texture,
     * it is used to store the pixel data.
     * Otherwise it <b>allocates</b> GC memory.
     */
    void[] getMemory() const nothrow {
        immutable uint msize = _width * _height * (_depth / 8);
        if (msize == 0)
            return null;
        
        this.bind();

        void[] memory = new void[msize];
        glGetTexImage(GL_TEXTURE_2D, 0, _format, GL_UNSIGNED_BYTE, memory.ptr);
        
        return memory;
    }

    /**
     * Returns a subTexture of this Texture.
     */
    @nogc
    Texture subTexture()(auto ref const Rect rect) const nothrow {
        assert(_texId != 0, "Texture is not initialized.");
        assert(rect.x <= _width, "rect.x is out of range.");
        assert(rect.y <= _height, "rect.y is out of range.");
        assert(rect.width <= _width, "rect.width is out of range.");
        assert(rect.height <= _height, "rect.height is out of range.");
        assert(rect.x >= 0, "rect.x is negative");
        assert(rect.y >= 0, "rect.y is negative.");
        assert(_format != Format.None, "Invalid format");

        immutable ubyte bits = _depth / 8;
        immutable uint msize = _width * _height * bits;

        void[] mem = m3.m3.make!(void[])(msize);
        ubyte[] buf = m3.m3.make!(ubyte[])(msize);

        scope(exit) {
            m3.m3.destruct(mem);
            m3.m3.destruct(buf);
        }

        void[] memory = this.getMemory(mem[0 .. msize]);

        immutable uint[2] pitch = [_width * bits, rect.width * bits];
        immutable uint diff = pitch[0] - pitch[1];

        immutable uint from = pitch[0] * rect.y + rect.x * bits;
        immutable uint too = from + (rect.height * pitch[0]);

        for (uint i = from, j = 0; i < too - pitch[1]; i += pitch[1], j += pitch[1]) {
            buffer[j .. j + pitch[1]] = cast(ubyte[]) memory[i .. i + pitch[1]];
            i += diff;
        }

        return Texture(buffer.ptr, rect.width, rect.height, 0, _format);
    }

    /**
     * Copy another Texture to this.
     * The second parameter is a pointer to the destination rect.
     * Is it is null this means the whole tex is copied.
     */
    @nogc
    void copy(ref const Texture tex, const Rect* rect = null) const nothrow {
        assert(_texId != 0, "Texture must be initialized for copying");
        assert(_width != 0 && _height != 0, "width or height is 0.");

        immutable ubyte bits = tex.depth / 8;
        immutable uint msize = tex.width * tex.height * bits;

        void[] mem = m3.m3.make!(void[])(msize);
        scope(exit) m3.m3.destruct(mem);

        void[] memory = tex.getMemory(mem[0 .. msize]);

        this.update(memory.ptr, rect, tex.getFormat());
    }

    /**
     * Update the pixel data of this Texture.
     * The second parameter is a pointer to the area which is updated.
     * If it is null (default) the whole Texture will be updated.
     * The third parameter is the format of the pixels.
     */
    @nogc
    void update(const void* memory, const Rect* rect = null,  Format fmt = Format.None) const nothrow {
        if (_texId == 0)
            return;

        assert(memory, "Pixels is null.");
        assert(_width != 0 && _height != 0, "width or height is 0.");

        uint width, height;
        int x, y;
        
        if (rect !is null) {
            assert(rect.width <= _width && rect.height <= _height, 
                    "Rect is greater as the Texture.");
            assert(rect.x < _width && rect.y < _height, 
                    "x or y of the Rect is greater as the Texture.");
            
            width  = rect.width;
            height = rect.height;
            
            x = rect.x;
            y = rect.y;
        } else {
            width  = _width;
            height = _height;
            
            x = y = 0;
        }

        this.bind();
        
        glTexSubImage2D(GL_TEXTURE_2D, 0, x, y, width, height, (fmt == Format.None ? _format : fmt), GL_UNSIGNED_BYTE, memory);
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

/**
 * Choose the right compress format for the given Texture.Format.
 *
 * See: Texture.Format enum
 */
@nogc
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