module Dgame.Graphics.Font;

private {
	debug import std.stdio;
	import std.file : exists;
	import std.conv : to;
	import std.string : toStringz;

	import derelict.sdl2.ttf;

	import Dgame.Core.Memory.SmartPointer.Shared;
}

///version = Develop;

/**
* Font is the low-level class for loading and manipulating character fonts.
* This class is meant to be used by Dgame.Graphics.Text.
*
* Author: rschuett
*/
struct Font {
public:
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
	shared_ptr!(TTF_Font, TTF_CloseFont) _target;

	ubyte _fontSize;
	string _filename;

	Mode _mode;
	Style _style;
	Hint _hint;

public:
	/**
	* CTor
	*/
	this(string filename, ubyte size,
		 Mode mode = Mode.Solid, Style style = Style.Normal)
	{
		this._mode  = mode;
		this._style = style;

		this.loadFromFile(filename, size);
	}

	/**
	* Postblit
	*/
	version(Develop)
	this(this) {
		debug writeln("Font Postblit");
	}

	/**
	* opAssign
	*/
	void opAssign(ref Font fnt) {
		debug writeln("Font opAssign");

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
	version(Develop)
	~this() {
		writeln("Close Font");
	}

	/**
	* Close and release the current font.
	* This function is called from the DTor
	*/
 	void free() {
		this._target.release();
	}

	/**
	* Load the font from a file.
	* If the second parameter isn't 0, the current font size will be replaced with that.
	* If both are 0, an exception is thrown.
	*/
	void loadFromFile(string fontFile, ubyte fontSize = 0) {
		this._filename = fontFile;

		this._fontSize = fontSize == 0 ? this._fontSize : fontSize;
		debug assert(this._fontSize != 0, "No size for this font.");

		if (!exists(fontFile))
			throw new Exception("Font File does not exists.");

		TTF_Font* font = TTF_OpenFont(toStringz(fontFile), this._fontSize);
		if (font is null) {
			throw new Exception("Could not load font " ~ fontFile ~ ". TTF Error: "
								~ to!(string)(TTF_GetError()));
		}

		this._target.reset(font);
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
		TTF_SetFontStyle(this._target.ptr, style);
	}

	/**
	* Returns the current font style.
	*
	* See: Font.Style enum
	*/
	Style getStyle() const {
		return cast(Style) TTF_GetFontStyle(this._target.ptr);
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

		TTF_SetFontHinting(this._target.ptr, hint);
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
	uint useCount() const pure nothrow {
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