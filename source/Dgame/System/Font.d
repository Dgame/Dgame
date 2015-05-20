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
module Dgame.System.Font;

private:

import derelict.sdl2.types;
import derelict.sdl2.ttf;

import Dgame.Graphic.Color;
import Dgame.Graphic.Surface;

import Dgame.Internal.Error;
import Dgame.Internal.d2c;

enum ubyte MinDepth = 24;

public:

/**
 * Font is the low-level class for loading and manipulating character fonts.
 * This class is meant to be used by Dgame.Graphic.Text.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Font {
private:
    TTF_Font* _ttf;
    ubyte _fontSize;

public:
    /**
     * The default size of every Font is 10
     */
    enum ubyte DefaultSize = 10;

    /**
     * Available Font styles
     */
    enum Style {
        Normal = TTF_STYLE_NORMAL, /// Used to indicate regular, normal, plain rendering style.
        Bold = TTF_STYLE_BOLD, /// Used to indicate bold rendering style.This is used in a bitmask along with other styles.
        Italic = TTF_STYLE_ITALIC, /// Used to indicate italicized rendering style.This is used in a bitmask along with other styles.
        Underline = TTF_STYLE_UNDERLINE, /// Used to indicate underlined rendering style.This is used in a bitmask along with other styles.
        StrikeThrough = TTF_STYLE_STRIKETHROUGH /// Used to indicate strikethrough rendering style.This is used in a bitmask along with other styles.
    }

    /**
     * Available Font modes
     */
    enum Mode : ubyte {
        Solid, /// Solid
        Shaded, /// Shaded
        Blended /// Blended
    }

    /**
     * CTor
     */
    @nogc
    this(string filename, ubyte fontSize) nothrow {
        this.loadFromFile(filename, fontSize);
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
        TTF_CloseFont(_ttf);
    }

    /**
     * Load the font from a file.
     * Returns if the loading was successful.
     * If not, an error message is shown, which describes the problem.
     * If the second parameter isn't 0, the current font size will be replaced with that.
     * If the current size is also 0, the DefaultSize (10) will be used.
     *
     * See: DefaultSize
     */
    @nogc
    bool loadFromFile(string filename, ubyte fontSize) nothrow {
        _fontSize = fontSize == 0 ? DefaultSize : fontSize;
        _ttf = TTF_OpenFont(toStringz(filename), _fontSize);
        if (!_ttf) {
            print_fmt("Error by loading TTF_Font %s: %s\n", toStringz(filename), TTF_GetError());
            return false;
        }

        return true;
    }

    /**
     * Set the Font style.
     *
     * See: Font.Style enum
     */
    @nogc
    void setStyle(Style style) nothrow {
        if (_ttf)
            TTF_SetFontStyle(_ttf, style);
    }

    /**
     * Returns the current Font style.
     *
     * See: Font.Style enum
     */
    @nogc
    Style getStyle() const nothrow {
        if (_ttf)
            return cast(Style) TTF_GetFontStyle(_ttf);
        return Style.Normal;
    }

    /**
     * Draws the text on a Surface by using this Font and the given Mode (default is Mode.Solid)
     * The text (and the Surface) is colorized by fg / bg Color.
     *
     * Note: The background color is ignored if your mode is not Font.Mode.Shaded
     *
     * Returns a Surface with the text or throws an Error
     */
    @nogc
    Surface render(string text, const Color4b fg, const Color4b bg, Mode mode = Mode.Solid) nothrow {
        assert(_ttf, "Font is invalid");

        SDL_Color a = void;
        SDL_Color b = void;

        _transfer(fg, a);
        _transfer(bg, b);

        SDL_Surface* sdl_srfc;
        final switch (mode) {
            case Mode.Solid:
                sdl_srfc = TTF_RenderUTF8_Solid(_ttf, toStringz(text), a);
                break;
            case Mode.Shaded:
                sdl_srfc = TTF_RenderUTF8_Shaded(_ttf, toStringz(text), a, b);
                break;
            case Mode.Blended:
                sdl_srfc = TTF_RenderUTF8_Blended(_ttf, toStringz(text), a);
                break;
        }

        assert_fmt(sdl_srfc, "Error by rendering text: %s", TTF_GetError());

        Surface srfc = Surface(sdl_srfc);
        if (srfc.bits < MinDepth)
            srfc.adaptTo(MinDepth);

        return srfc;
    }
}