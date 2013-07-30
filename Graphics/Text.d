module Dgame.Graphics.Text;

private {
	debug import std.stdio;
	import std.string : format, toStringz;
	
	import derelict.sdl2.sdl; // because of SDL_Surface and SDL_FreeSurface
	import derelict.sdl2.ttf;
	
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Color;
	import Dgame.Math.Rect;
	import Dgame.Graphics.Font;
	import Dgame.Graphics.Texture;
}

/**
 * Text defines a graphical 2D text, that can be drawn on screen.
 *	- The default foreground color is <code>Color.Black</code>
 *	- The default background color is <code>Color.White</code>
 *
 * Author: rschuett
 */
class Text : Drawable, Blendable {
protected:
	string _text;
	bool _shouldUpdate;
	
	Color _fg = Color.Black;
	Color _bg = Color.White;
	
	ShortRect _clip;
	
	Font _font = void;
	Texture _tex;
	
private:
	void _storePixel(SDL_Surface* rhs, Texture.Format fmt) in {
		assert(this._tex !is null, "No Texture!");
		assert(rhs !is null, "No Surface!");
	} body {
		ushort width  = cast(ushort) rhs.w;
		ushort height = cast(ushort) rhs.h;
		
		this._tex.loadFromMemory(rhs.pixels, width, height, rhs.format.BitsPerPixel, fmt);
	}
	
	/// TODO: Improve
	void _update() in {
		assert(this._tex !is null, "No Texture!");
	} body {
		this._shouldUpdate = false;
		
		SDL_Surface* srfc;
		scope(exit) SDL_FreeSurface(srfc);
		
		immutable char* cstr = toStringz(this._text);
		
		SDL_Color* fg = this._fg.ptr;
		SDL_Color* bg = this._bg.ptr;
		
		final switch (this._font.getMode()) {
			case Font.Mode.Solid:
				srfc = TTF_RenderUTF8_Solid(this._font.ptr, cstr, *fg);
				break;
			case Font.Mode.Shaded:
				srfc = TTF_RenderUTF8_Shaded(this._font.ptr, cstr, *fg, *bg);
				break;
			case Font.Mode.Blended:
				srfc = TTF_RenderUTF8_Blended(this._font.ptr, cstr, *fg);
				break;
		}
		
		assert(srfc !is null, "Surface is null.");
		
		if (this._font.getMode() != Font.Mode.Blended) {
			/// Adapt PixelFormat
			SDL_PixelFormat fmt;
			fmt.BitsPerPixel = 24;
			
			SDL_Surface* opt = SDL_ConvertSurface(srfc, &fmt, 0);
			scope(exit) SDL_FreeSurface(opt);
			
			assert(opt !is null, "Optimized is null.");
			assert(opt.pixels !is null, "Optimized pixels is null.");
			
			Texture.Format t_fmt = Texture.Format.None;
			if (opt.format.Rmask != 0x000000ff)
				t_fmt = opt.format.BitsPerPixel == 24 ? Texture.Format.BGR : Texture.Format.BGRA;
			
			this._storePixel(opt, t_fmt);
		} else {
			Texture.Format t_fmt = Texture.Format.None;
			if (srfc.format.Rmask != 0x000000ff)
				t_fmt = srfc.format.BitsPerPixel == 24 ? Texture.Format.BGR : Texture.Format.BGRA;
			
			this._storePixel(srfc, t_fmt);
		}
		
		this._clip.setPosition(super._position);
		this._clip.setSize(this._tex.width, this._tex.height);
	}
	
protected:
	override void _positionChanged(float dx, float dy) {
		if (!this._shouldUpdate)
			this._clip.move(dx, dy);
	}
	
	override void _render() in {
		assert(this._tex !is null, "No valid Texture.");
	} body {
		if (this._shouldUpdate)
			this._update();
		
		this._tex._render(this._clip);
	}
	
public:
final:
	
	/**
	 * CTor
	 */
	this(ref const Font font, string text = "") {
		this._font = font;
		
		this._text = text;
		this._shouldUpdate = true;
		
		this._tex = new Texture();
	}
	
	/**
	 * CTor: Rvalue version
	 */
	this(const Font font, string text = "") {
		this(font, text);
	}
	
	/**
	 * Enable or Disable blending
	 */
	void useBlending(bool enable) {
		this._tex.useBlending(enable);
	}
	
	/**
	 * Returns if Blending is enabled
	 */
	bool isBlendingEnabled() const pure nothrow {
		return this._tex.isBlendingEnabled();
	}
	
	
	/**
	 * Set the Blendmode.
	 */
	void setBlendMode(BlendMode mode) {
		this._tex.setBlendMode(mode);
	}
	
	/**
	 * Returns the current Blendmode.
	 */
	BlendMode getBlendMode() const pure nothrow {
		return this._tex.getBlendMode();
	}
	
	/**
	 * Set the Blend Color.
	 */
	void setBlendColor(ref const Color col) {
		this._tex.setBlendColor(col);
	}
	
	/**
	 * Rvalue version
	 */
	void setBlendColor(const Color col) {
		this.setBlendColor(col);
	}
	
	/**
	 * Returns the current Blend Color.
	 */
	ref const(Color) getBlendColor() const pure nothrow {
		return this._tex.getBlendColor();
	}
	
	/**
	 * Activate or deactivate the using of the Blend color.
	 */
	void useBlendColor(bool use) {
		this._tex.useBlendColor(use);
	}
	
	/**
	 * Returns, if using blend color is activated, or not.
	 */
	bool usingBlendColor() const pure nothrow {
		return this._tex.usingBlendColor();
	}
	
	/**
	 * Replace the current Font.
	 */
	void replaceFont(ref const Font font) {
		this._font = font;
		this._shouldUpdate = true;
	}
	
	/**
	 * Rvalue version
	 */
	void replaceFont(const Font font) {
		this.replaceFont(font);
	}
	
	/**
	 * Get the image containing the rendered characters.
	 */
	inout(Texture) getTexture() inout pure nothrow {
		return this._tex;
	}
	
	/**
	 * Returns the current Font object.
	 */
	ref inout(Font) getFont() inout pure nothrow {
		return this._font;
	}
	
	/**
	 * Activate an update.
	 * The current image will be updated.
	 * In most cases, this happens automatically,
	 * but sometimes it is usefull.
	 */
	void update() {
		this._shouldUpdate = true;
	}
	
	/**
	 * Format a given string and draw it then on the image
	 */
	void format(Args...)(string text, Args args) {
		string formated = .format(text, args);
		
		if (formated != this._text) {
			this._text = formated;
			this._shouldUpdate = true;
		}
	}
	
	/**
	 * Replace the current string.
	 * 
	 * Examples:
	 * ---
	 * Font fnt = new Font("samples/font/arial.ttf", 12);
	 * Text t = new Text(font);
	 * t("My new string");
	 * ---
	 */
	void opCall(string text) {
		if (text != this._text) {
			this._text = text;
			this._shouldUpdate = true;
		}
	}
	
	/**
	 * Replace the current string.
	 * 
	 * Examples:
	 * ---
	 * Font fnt = new Font("samples/font/arial.ttf", 12);
	 * Text t1 = new Text(font);
	 * Text t2 = new Text(font);
	 * t1("My new string");
	 * t2(t1); // now both t's draw 'My new string' on screen.
	 * ---
	 */
	void opCall(ref const Text t) {
		return this.opCall(t.getString());
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
	ref Text opBinary(string op)(string text) if (op == "~" || op == "+") {
		this._text ~= text;
		this._shouldUpdate = true;
		
		return this;
	}
	
	/**
	 * Concatenate the current string with another.
	 */
	ref Text opBinary(string op)(ref const Text t) if (op == "~" || op == "+") {
		return this.opBinary!(op)(t.getString());
	}
	
	/**
	 * Returns the current string.
	 */
	string getString() const pure nothrow {
		return this._text;
	}
	
	/**
	 * Set the (foreground) color.
	 */
	void setColor(ref const Color col) {
		this._shouldUpdate = true;
		this._fg = col;
	}
	
	/**
	 * Rvalue version
	 */
	void setColor(const Color col) {
		this.setColor(col);
	}
	
	/**
	 * Returns the (foreground) color.
	 */
	ref const(Color) getColor() const pure nothrow {
		return this._fg;
	}
	
	/**
	 * Set the background color.
	 * Only needed if your Font.Mode is not Font.Mode.Solid.
	 */
	void setBackgroundColor(ref const Color col) {
		this._shouldUpdate = true;
		this._bg = col;
	}
	
	/**
	 * Rvalue version
	 */
	void setBackgroundColor(const Color col) {
		this.setBackgroundColor(col);
	}
	
	/**
	 * Returns the background color.
	 */
	ref const(Color) getBackgroundColor() const pure nothrow {
		return this._bg;
	}
}