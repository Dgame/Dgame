module Dgame.Graphic.Color;

struct Color4b {
    static immutable Color4b Black   = Color4b(0,     0,   0); /** Black Color (0, 0, 0) */
    static immutable Color4b White   = Color4b(255, 255, 255); /** White Color (255, 255, 255) */
    static immutable Color4b Red     = Color4b(255,   0,   0); /** Red Color (255, 0, 0) */
    static immutable Color4b Green   = Color4b(0,   255,   0); /** Green Color (0, 255, 0) */
    static immutable Color4b Blue    = Color4b(0,     0, 255); /** Blue Color (0, 0, 255) */
    static immutable Color4b Cyan    = Color4b(0,   255, 255); /** Cyan Color (0, 255, 255) */
    static immutable Color4b Yellow  = Color4b(255, 255,   0); /** Yellow Color (255, 255, 0)*/
    static immutable Color4b Magenta = Color4b(255,   0, 255); /** Magenta Color (255, 0, 255) */
    static immutable Color4b Gray    = Color4b(179, 179, 179); /** Gray Color (179, 179, 179) */
    
    /**
     * The color components
     */
    ubyte red, green, blue, alpha;
    
    /**
     * CTor
     */
    @nogc
    this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
        this.red   = red;
        this.green = green;
        this.blue  = blue;
        this.alpha = alpha;
    }
    
    /**
     * CTor
     * Expect that every component is in range 0.0 .. 1.0
     */
    @nogc
    this()(auto ref const Color4f col) pure nothrow
    in {
        assert(col.red   >= 0f && col.red   <= 1f);
        assert(col.green >= 0f && col.green <= 1f);
        assert(col.blue  >= 0f && col.blue  <= 1f);
        assert(col.alpha >= 0f && col.alpha <= 1f);
    } body {
        this.red   = cast(ubyte)(ubyte.max * col.red);
        this.green = cast(ubyte)(ubyte.max * col.green);
        this.blue  = cast(ubyte)(ubyte.max * col.blue);
        this.alpha = cast(ubyte)(ubyte.max * col.alpha);
    }

    @nogc
    Color4b withTransparency(ubyte alpha) const pure nothrow {
        return Color4b(this.red, this.green, this.blue, alpha);
    }

    /**
     * opEquals: compares two Colors.
     */
    @nogc
    bool opEquals(ref const Color4b col) const pure nothrow {
        return this.red == col.red &&
               this.green == col.green &&
               this.blue == col.blue &&
               this.alpha == col.alpha;
    }
    
    /**
     * Returns the RGBA color information as static array
     */
    @nogc
    ubyte[4] asRGBA() const pure nothrow {
        return [this.red, this.green, this.blue, this.alpha];
    }
    
    /**
     * Returns RGB the color information as static array
     */
     @nogc
    ubyte[3] asRGB() const pure nothrow {
        return [this.red, this.green, this.blue];
    }
}

struct Color4f {
    static immutable Color4f Black   = Color4f(0,     0,   0); /** Black Color (0, 0, 0) */
    static immutable Color4f White   = Color4f(255, 255, 255); /** White Color (255, 255, 255) */
    static immutable Color4f Red     = Color4f(255,   0,   0); /** Red Color (255, 0, 0) */
    static immutable Color4f Green   = Color4f(0,   255,   0); /** Green Color (0, 255, 0) */
    static immutable Color4f Blue    = Color4f(0,     0, 255); /** Blue Color (0, 0, 255) */
    static immutable Color4f Cyan    = Color4f(0,   255, 255); /** Cyan Color (0, 255, 255) */
    static immutable Color4f Yellow  = Color4f(255, 255,   0); /** Yellow Color (255, 255, 0)*/
    static immutable Color4f Magenta = Color4f(255,   0, 255); /** Magenta Color (255, 0, 255) */
    static immutable Color4f Gray    = Color4f(179, 179, 179); /** Gray Color (179, 179, 179) */
    
    /**
     * The color components
     */
    float red, green, blue, alpha;
    
    /**
     * CTor
     */
    @nogc
    this(ubyte red, ubyte green, ubyte blue, ubyte alpha = 255) pure nothrow {
        this.red   = red / 255f;
        this.green = green / 255f;
        this.blue  = blue / 255f;
        this.alpha = alpha / 255f;
    }

    /**
     * CTor
     */
    @nogc
    this(float red, float green, float blue, float alpha = 1) pure nothrow
    in {
        assert(red   >= 0f && red   <= 1f);
        assert(green >= 0f && green <= 1f);
        assert(blue  >= 0f && blue  <= 1f);
        assert(alpha >= 0f && alpha <= 1f);
    } body {
        this.red   = red;
        this.green = green;
        this.blue  = blue;
        this.alpha = alpha;
    }

    /**
     * CTor
     */
    @nogc
    this()(auto ref const Color4b col) pure nothrow {
        this(col.red, col.green, col.blue, col.alpha);
    }

    /**
     * opEquals: compares two Colors.
     */
    @nogc
    bool opEquals(ref const Color4f col) const pure nothrow {
        return this.red == col.red &&
               this.green == col.green &&
               this.blue == col.blue &&
               this.alpha == col.alpha;
    }
    
    /**
     * Returns the RGBA color information as static array
     */
    @nogc
    float[4] asRGBA() const pure nothrow {
        return [this.red, this.green, this.blue, this.alpha];
    }
    
    /**
     * Returns RGB the color information as static array
     */
     @nogc
    float[3] asRGB() const pure nothrow {
        return [this.red, this.green, this.blue];
    }
}