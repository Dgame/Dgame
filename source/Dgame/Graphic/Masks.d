module Dgame.Graphic.Masks;

/**
 * The RGBA-Mask are the bitmasks used to extract that color from a pixel.
 * It is used to e.g. define the background of a newly created Surface.
 * Using zeros for the RGB-Masks sets a default value, based on the depth
 * But using zero for the Aalpha-Mask results in an Alpha-Mask of 0.
 * By default Surfaces with an Alpha-Mask are set up for blending.
 * You can change the blend mode with Surface.setBlendMode.
 */
struct Masks {
    /**
     * The RGBA-Masks are zero.
     * Using zeros for the RGB-Masks sets a default value, based on the given depth.
     * Using zero for the Alpha-Mask results in an Alpha-Mask of 0.
     */
    static immutable Masks Zero = Masks(0, 0, 0, 0);

    version (LittleEndian) {
        uint red = 0x000000ff; /// the red mask, default is 0x000000ff
        uint green = 0x0000ff00; /// the green mask, default is 0x0000ff00
        uint blue = 0x00ff0000; /// the blue mask, default is 0x00ff0000
        uint alpha = 0xff000000; /// the alpha mask, default is 0xff000000
    } else {
        uint red = 0xff000000; /// the red mask, default is 0xff000000
        uint green = 0x00ff0000; /// the green mask, default is 0x00ff0000
        uint blue = 0x0000ff00; /// the blue mask, default is 0x0000ff00
        uint alpha = 0x000000ff; /// the alpha mask, default is 0x000000ff
    }

    /**
     * CTor
     */
    @nogc
    this(uint red, uint green, uint blue, uint alpha) pure nothrow {
        this.red = red;
        this.green = green;
        this.blue = blue;
        this.alpha = alpha;
    }
}
