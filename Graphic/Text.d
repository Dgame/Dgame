module Dgame.Graphic.Text;

private:

import Dgame.Graphic.Drawable;
import Dgame.Graphic.Transformable;
import Dgame.Graphic.Surface; // Temp
import Dgame.Graphic.Texture;
import Dgame.Graphic.Color;

import Dgame.Math.Vertex;
import Dgame.Math.Geometry;

import Dgame.System.Font;

public:

class Text : Transformable, Drawable {
private:
    Vertex[4] _vertices;

    Texture _texture; // TODO: make it a Texture*? Is it guaranteed that the DTor is called?
    Font* _font;

    string _text;
    bool _redraw = true;

protected:
    @nogc
    override void draw(ref const Window wnd) nothrow {
        import core.stdc.stdio : printf;

        if (_text.length && (_redraw || _wasTransformed())) {
            assert(_font, "No font given");

            _redraw = false;

            Surface srfc = _font.render(_text, this.foreground, this.background, this.mode);
            _texture.loadFrom(srfc);

            // Update Vertices
            immutable uint tw = _texture.width;
            immutable uint th = _texture.height;

            // #2
            _vertices[1].position.x = tw;
            // #3
            _vertices[2].position.y = th;
            // #4
            _vertices[3].position.x = tw;
            _vertices[3].position.y = th;
        }

        wnd.draw(Geometry.TriangleStrip, super.getMatrix(), &_texture, _vertices.ptr, 4);
    }

    @nogc
    final void _init() pure nothrow {
        // #2
        _vertices[1].texCoord.x = 1;
        // #3
        _vertices[2].texCoord.y = 1;
        // #4
        _vertices[3].texCoord.x = 1;
        _vertices[3].texCoord.y = 1;

        foreach (ref Vertex v; _vertices) {
            v.color = Color4f.White;
        }
    }

public:
    Color4b foreground = Color4b.Black;
    Color4b background = Color4b.White;
    Font.Mode mode = Font.Mode.Solid;

final:
    @nogc
    this(ref Font fnt, string str = "") pure nothrow {
        _font = &fnt;
        _text = str;

        _init();
    }

    void format(Args...)(string text, Args args) pure {
        import std.string : format;

        string formated = format(text, args);
        
        if (formated != _text) {
            _text = formated;
            _redraw = true;
        }
    }

    void setData(T)(T data) pure nothrow {
        import std.conv : to;

        string text = to!string(data);

        if (text != _text) {
            _text = text;
            _redraw = true;
        }
    }

    @nogc
    void clear() pure nothrow {
        _text = "";
        _redraw = true;
    }

    /**
     * Concatenate the current string with another.
     *
     * Examples:
     * ---
     * Font fnt = new Font("samples/font/arial.ttf", 12);
     * Text t = new Text(font);
     * t("My new string");
     * t ~= "is great!"; // t draws now 'My new string is great' on screen.
     * ---
     * The example above is the same as if you do:
     * ---
     * t += "is great!";
     * ---
     * Both operators (~ and +) are allowed.
     */
    Text opBinary(string op)(string text) pure nothrow
        if (op == "~" || op == "+")
    {
        _text ~= text;
        _redraw = true;
        
        return this;
    }

    @nogc
    string getText() const pure nothrow {
        return _text;
    }

    @nogc
    void setFont(ref Font fnt) pure nothrow {
        _font = &fnt;
        _redraw = true;
    }

    @nogc
    inout(Font*) getFont() inout pure nothrow {
        return _font;
    }
}