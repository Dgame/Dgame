module Dgame.System.Font;

private:

import derelict.sdl2.types;
import derelict.sdl2.ttf;

import Dgame.Graphic.Color;
import Dgame.Graphic.Surface;

public:

struct Font {
private:
    TTF_Font* _ttf;
    ubyte _fontSize;

public:
    enum ubyte DefaultSize = 10;

    enum Style {
        /*
        * Used to indicate regular, normal, plain rendering style.
        */
        Normal = TTF_STYLE_NORMAL,
        /*
        * Used to indicate bold rendering style.This is used in a bitmask along with other styles.
        */
        Bold = TTF_STYLE_BOLD,
        /*
        * Used to indicate italicized rendering style.This is used in a bitmask along with other styles.
        */
        Italic = TTF_STYLE_ITALIC,
        /*
        * Used to indicate underlined rendering style.This is used in a bitmask along with other styles.
        */
        Underline = TTF_STYLE_UNDERLINE,
        /*
        * Used to indicate strikethrough rendering style.This is used in a bitmask along with other styles.
        */
        StrikeThrough = TTF_STYLE_STRIKETHROUGH
    };

    enum Mode : ubyte {
        Solid,
        Shaded,
        Blended
    };

    @nogc
    this(string filename, ubyte fontSize) nothrow {
        this.loadFromFile(filename, fontSize);
    }
    
    @disable
    this(this);

    @nogc
    ~this() nothrow {
        TTF_CloseFont(_ttf);
    }

    @nogc
    bool loadFromFile(string filename, ubyte fontSize) nothrow {
        _fontSize = fontSize == 0 ? DefaultSize : fontSize;
        _ttf = TTF_OpenFont(filename.ptr, _fontSize);
        if (!_ttf) {
            printf("Error by loading TTF_Font: %s\n", TTF_GetError());
            return false;
        }

        return true;
    }

    @nogc
    void setStyle(Style style) nothrow {
        if (_ttf)
            TTF_SetFontStyle(_ttf, style);
    }

    @nogc
    Style getStyle() const nothrow {
        if (_ttf)
            return cast(Style) TTF_GetFontStyle(_ttf);
        return Style.Normal;
    }

    @nogc
    Surface render()(string text, auto ref const Color4b fg, auto ref const Color4b bg, Mode mode = Mode.Solid) nothrow {
        assert(_ttf, "Font is invalid");
        assert(text.length, "No text to render");

        SDL_Color a = void;
        SDL_Color b = void;

        _transfer(fg, a);
        _transfer(bg, b);

        SDL_Surface* srfc;
        final switch (mode) {
            case Mode.Solid:
                srfc = TTF_RenderUTF8_Solid(_ttf, text.ptr, a);
                break;
            case Mode.Shaded:
                srfc = TTF_RenderUTF8_Shaded(_ttf, text.ptr, a, b);
                break;
            case Mode.Blended:
                srfc = TTF_RenderUTF8_Blended(_ttf, text.ptr, a);
                break;
        }

        if (!srfc) {
            printf("Error by rendering text: %s\n", TTF_GetError());
            assert(0);
        }

        if (srfc.format.BitsPerPixel < 24) {
            SDL_PixelFormat fmt;
            fmt.BitsPerPixel = 24;
            
            Surface result = Surface(srfc);
            result.adaptTo(&fmt);

            return result;
        }

        return Surface(srfc);
    }
}