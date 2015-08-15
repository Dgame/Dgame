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
module Dgame.Graphic.Text;

private:

import Dgame.Graphic.Drawable;
import Dgame.Graphic.Transformable;
import Dgame.Graphic.Surface;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Color;

import Dgame.Math.Vertex;
import Dgame.Math.Geometry;

import Dgame.System.Font;

public:

/**
 * Text defines a graphical 2D text, that can be drawn on screen.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
class Text : Transformable, Drawable {
private:
    Vertex[4] _vertices;

    Texture _texture;
    Font* _font;

    string _text;

    bool _redraw = true;

protected:
    @nogc
    override void draw(ref const Window wnd) nothrow {
        this.update();

        if (_text.length != 0)
            wnd.draw(Geometry.TriangleStrip, super.getMatrix(), &_texture, _vertices[]);
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
    /**
     * The foreground color. Default is Color4b.Black.
     */
    Color4b foreground = Color4b.Black;
    /**
     * The background color. Default is Color4b.White.
     *
     * Note: The background color is ignored if your mode is not Font.Mode.Shaded
     */
    Color4b background = Color4b.White;
    /**
     * The Font mode which is default Font.Mode.Solid.
     */
    Font.Mode mode = Font.Mode.Solid;

final:
    /**
     * CTor
     */
    @nogc
    this(ref Font fnt, string str = null) pure nothrow {
        _font = &fnt;
        _text = str;

        _init();
    }

    /**
     * Update the Texture and redraw the text, if necessary.
     * This method is called automatically if the Text is drawn onto the Window.
     * But if you need specific informations (e.g. width/height) before the draw call,
     * you can call the method by yourself.
     */
    @nogc
    void update() nothrow {
        if (_text.length != 0 && _redraw) {
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
    }

    /**
     * Returns the width
     */
    @property
    @nogc
    uint width() const pure nothrow {
        return _texture.width;
    }
    
    /**
     * Returns the height
     */
    @property
    @nogc
    uint height() const pure nothrow {
        return _texture.height;
    }

    /**
     * Returns the used Texture which contains the last rendered Text
     */
    @nogc
    inout(Texture*) getTexture() inout pure nothrow {
        return &_texture;
    }

    /**
     * Format a given string by using std.string.format.
     * Therefore the formating pattern is identical.
     */
    void format(Args...)(string text, Args args) pure {
        import std.string : format;

        immutable string formated = text.length != 0 ? format(text, args) : null;
        if (formated != _text) {
            _text = formated;
            _redraw = true;
        }
    }

    /**
     * Set or reset the current text by using std.conv.to!(string) if the data is not a string
     */
    void setData(T)(T data) pure nothrow {
        static if (is(T == string))
            immutable string text = data;
        else static if (is(T == typeof(null)))
            immutable string text = null;
        else {
            import std.conv : to;

            immutable string text = to!string(data);
        }

        if (text != _text) {
            _text = text;
            _redraw = true;
        }
    }

    /**
     * Concatenate the current string with another.
     *
     * Examples:
     * ---
     * Font fnt = new Font("samples/font/arial.ttf", 12);
     * Text t = new Text(font);
     * t.setData("My new string");
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

    /**
     * Returns the current text
     */
    @nogc
    string getText() const pure nothrow {
        return _text;
    }

    /**
     * Set or reset the current Font
     */
    @nogc
    void setFont(ref Font fnt) pure nothrow {
        _font = &fnt;
        _redraw = true;
    }

    /**
     * Returns a pointer to the current Font
     */
    @nogc
    inout(Font*) getFont() inout pure nothrow {
        return _font;
    }
}