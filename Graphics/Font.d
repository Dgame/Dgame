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
module Dgame.Graphics.Font;

private {
	debug import std.stdio : writeln;
	import std.file : exists;
	import std.conv : to;
	import std.string : toStringz;
	
	import derelict.sdl2.ttf;
	
	import Dgame.Internal.Shared;
	import Dgame.Internal.Log;
}

/**
 * Font is the low-level class for loading and manipulating character fonts.
 * This class is meant to be used by Dgame.Graphics.Text.
 *
 * Author: rschuett
 */
struct Font {
	/**
	 * Font styles
	 */
	enum Style : ubyte {
		Bold      = TTF_STYLE_BOLD,			/** Makes the text bold */
		Italic    = TTF_STYLE_ITALIC,		/** Makes the text italic */
		Underline = TTF_STYLE_UNDERLINE,	/** Underline the text */
		Crossed   = TTF_STYLE_STRIKETHROUGH, /** Cross the text */
		Normal    = TTF_STYLE_NORMAL		/** Normal text without any style. */
	}
	
	/**
	 * Font Hints
	 */
	enum Hint : ubyte {
		Normal = TTF_HINTING_NORMAL, /** Normal (default) Hint */
		Light  = TTF_HINTING_LIGHT,  /** */
		Mono   = TTF_HINTING_MONO,   /** */
		None   = TTF_HINTING_NONE    /** No Hint */
	}
	
	/**
	 * Font mode
	 */
	enum Mode : ubyte {
		Solid,  /** Solid mode is dirty but fast. */
		Shaded, /** Blended is optimized but still fast. */
		Blended /** Nicest but slowest mode. */
	}
	
private:
	shared_ptr!(TTF_Font) _target;
	string _filename;
	
	ubyte _fontSize;
	Mode _mode;
	Style _style;
	Hint _hint;
	
public:
	/**
	 * CTor
	 */
	this(string filename, ubyte size, Mode mode = Mode.Solid, Style style = Style.Normal) {
		this._mode  = mode;
		this._style = style;
		
		this.loadFromFile(filename, size);
	}
	
	/**
	 * Postblit
	 */
	debug(Dgame)
	this(this) {
		debug Log.info("Font Postblit");
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref Font fnt) {
		debug Log.info("Font opAssign");
		
		this._fontSize = fnt._fontSize;
		
		this._mode = fnt._mode;
		this._style = fnt._style;
		this._hint = fnt._hint;
		
		this._target = fnt._target;
	}
	
	/**
	 * Rvalue version
	 */
	void opAssign(Font fnt) {
		this.opAssign(fnt);
	}
	
	/**
	 * DTor
	 */
	debug(Dgame)
	~this() {
		debug Log.info("Close Font");
	}
	
	/**
	 * Close and release the current font <b>and all</b> which are linked to this Font.
	 */
	void free() {
		this._target.dissolve();
	}
	
	/**
	 * Load the font from a file.
	 * If the second parameter isn't 0, the current font size will be replaced with that.
	 * If both are 0, an exception is thrown.
	 */
	void loadFromFile(string fontFile, ubyte fontSize = 0) {
		this._filename = fontFile;
		
		this._fontSize = fontSize == 0 ? this._fontSize : fontSize;
		assert(this._fontSize != 0, "No size for this font.");
		
		if (!exists(fontFile))
			Log.error("Font File does not exists.");
		
		TTF_Font* font = TTF_OpenFont(toStringz(fontFile), this._fontSize);
		if (font is null) {
			Log.error("Could not load font " ~ fontFile ~ ". TTF Error: " ~ to!(string)(TTF_GetError()));
		}
		
		this._target = make_shared(font, (TTF_Font* ttf) => (TTF_CloseFont(ttf)));
	}
	
	/**
	 * Returns the current filename, if any
	 */
	@property
	string filename() const pure nothrow {
		return this._filename;
	}
	
	/**
	 * Set the font style.
	 *
	 * See: Font.Style enum
	 */
	void setStyle(Style style) {
		TTF_SetFontStyle(this._target, style);
	}
	
	/**
	 * Returns the current font style.
	 *
	 * See: Font.Style enum
	 */
	Style getStyle() const {
		return cast(Style) TTF_GetFontStyle(this._target);
	}
	
	/**
	 * Set the font mode.
	 *
	 * See: Font.Mode enum
	 */
	void setMode(Mode mode) {
		this._mode = mode;
	}
	
	/**
	 * Returns the current font mode.
	 *
	 * See: Font.Mode enum
	 */
	Mode getMode() const pure nothrow {
		return this._mode;
	}
	
	/**
	 * Set a hint for the Font
	 * 
	 * See: Hint enum
	 */
	void setHint(Hint hint) {
		this._hint = hint;
		
		TTF_SetFontHinting(this._target, hint);
	}
	
	/**
	 * Returns the current hint
	 */
	Hint getHint() const pure nothrow {
		return this._hint;
	}
	
	/**
	 * Returns the current font size.
	 */
	ubyte getSize() const pure nothrow {
		return this._fontSize;
	}
	
	/**
	 * Returns a TTFthis._target pointer.
	 */
	@property
	inout(TTF_Font)* ptr() inout {
		return this._target.ptr;
	}
	
	/**
	 * Returns the current use count
	 */
	int useCount() const pure nothrow {
		return this._target.usage;
	}
} unittest {
	writeln("<Font unittest>");
	
	{
		Font f1 = Font("samples/font/arial.ttf", 14);
		
		assert(f1.useCount() == 1, to!string(f1.useCount()));
		{
			Font f2 = f1;
			
			assert(f1.useCount() == 2, to!string(f1.useCount()));
			assert(f2.useCount() == 2, to!string(f2.useCount()));
			
			f2 = f1;
			
			assert(f1.useCount() == 2, to!string(f1.useCount()));
			assert(f2.useCount() == 2, to!string(f2.useCount()));
			
			{
				Font f3 = f2;
				
				assert(f1.useCount() == 3, to!string(f1.useCount()));
				assert(f2.useCount() == 3, to!string(f2.useCount()));
				assert(f3.useCount() == 3, to!string(f3.useCount()));
			}
			
			assert(f1.useCount() == 2, to!string(f1.useCount()));
			assert(f2.useCount() == 2, to!string(f2.useCount()));
		}
		assert(f1.useCount() == 1, to!string(f1.useCount()));
	}
	
	writeln("</Font unittest>");
}