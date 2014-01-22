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
module Dgame.Window.Window;

private {
	import derelict.sdl2.sdl;
	import derelict.opengl3.gl;

	import Dgame.Internal.Log;
	
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Surface;
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.Renderer;
	import Dgame.Graphics.TileMap;
	import Dgame.Math.Vector2;
	import Dgame.Window.VideoMode;
	import Dgame.System.Clock;
}

private Window[] _WndFinalizer;

static ~this() {
	debug Log.info("Close open Windows.");
	
	for (size_t i = 0; i < _WndFinalizer.length; ++i) {
		if (_WndFinalizer[i])
			_WndFinalizer[i].close();
	}
	
	debug Log.info("Open Windows closed.");
	
	_WndFinalizer = null;
}

/**
 * Window is a rendering window where all drawable objects are drawn.
 *
 * Note that the default clear-color is <code>Color.White</code> and the
 * default Sync is <code>Window.Sync.Enable</code>.
 *
 * Author: rschuett
 */
final class Window {
public:
	/**
	 * The Window syncronisation mode.
	 * Default Syncronisation is <code>Sync.Enable</code>.
	 */
	enum Sync : byte {
		Enable  = 1,	/** Sync is enabled */
		Disable = 0,	/** Sync is disabled */
		LateSwapTearing = -1	/** For late swap tearing */
	}
	
	/**
	 * The specific window styles
	 */
	enum Style {
		Fullscreen = SDL_WINDOW_FULLSCREEN, /** Window is fullscreened */
		Desktop = SDL_WINDOW_FULLSCREEN_DESKTOP, /** Window has Desktop Fullscreen */
		OpenGL	= SDL_WINDOW_OPENGL,	 /** OpenGL support */
		Shown	= SDL_WINDOW_SHOWN,		 /** Show the Window immediately */
		Borderless = SDL_WINDOW_BORDERLESS, /** Hide the Window immediately */
		Resizeable = SDL_WINDOW_RESIZABLE,  /** Window is resizeable */
		Maximized = SDL_WINDOW_MAXIMIZED,  /** Maximize the Window immediately */
		Minimized = SDL_WINDOW_MINIMIZED,  /** Minimize the Window immediately */
		InputGrabbed = SDL_WINDOW_INPUT_GRABBED, /** Grab the input inside the window */
		InputFocus = SDL_WINDOW_INPUT_FOCUS, /** The Window has input (keyboard) focus */
		MouseFocus = SDL_WINDOW_MOUSE_FOCUS, /** The Window has mouse focus */
		HighDPI = SDL_WINDOW_ALLOW_HIGHDPI, /** Window should be created in high-DPI mode if supported (>= SDL 2.0.1) */
		Foreign = SDL_WINDOW_FOREIGN, /** The window was created by some other framework. */
		
		Default = Shown | OpenGL | HighDPI /** Default mode is Shown | OpenGL | HighDPI */
	}
	
private:
	SDL_Window* _window;
	SDL_GLContext _glContext;
	
	VideoMode _vMode = void;
	Style _style;
	
	string _title;
	ubyte _fpsLimit;
	
	static int _winCount;
	
public:
final:
	static immutable string DefaultTitle = "App";
	enum DefaultXPos = SDL_WINDOWPOS_CENTERED;
	enum DefaultYPos = SDL_WINDOWPOS_CENTERED;
	
	/**
	 * CTor
	 */
	this(VideoMode vMode, string title = DefaultTitle,
	     Style style = Style.Default,
	     int x = DefaultXPos, int y = DefaultYPos)
	{
		// Create an application window with the following settings:
		this._window = SDL_CreateWindow(title.ptr,	// const char* title
		                                x,	// int x: initial x position
		                                y,	// int y: initial y position
		                                vMode.width,	// int w: width, in pixels
		                                vMode.height,	// int h: height, in pixels
		                                style);	// Uint32 flags: window options
		
		if (this._window is null)
			Log.error("Error by creating a SDL2 window: " ~ to!string(SDL_GetError()));
		
		if (style & Style.OpenGL) {
			this._glContext = SDL_GL_CreateContext(this._window);
			if (this._glContext is null)
				Log.error("Error while creating gl context: " ~ to!string(SDL_GetError()));
			
			const GLVersion glver = DerelictGL.reload();
			debug Log.info("Derelict loaded GL version: %s (%s), available GL version: %s",
			               DerelictGL.loadedVersion, glver, to!(string)(glGetString(GL_VERSION)));
			if (glver < GLVersion.GL30)
				Log.error("Your OpenGL version (%d) is too low. Need at least GL 3.0.", glver);
			
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			
			glEnable(GL_CULL_FACE);
			glCullFace(GL_FRONT);
			
			glShadeModel(GL_FLAT);
			glDisable(GL_DITHER);
			
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			
			glDisable(GL_DEPTH_TEST);
			
			// Hints
			glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
			glHint(GL_GENERATE_MIPMAP_HINT, GL_FASTEST);
			glHint(GL_TEXTURE_COMPRESSION_HINT, GL_FASTEST);
			
			glOrtho(0, vMode.width, vMode.height, 0, 1, -1);
			
			this.setVerticalSync(Sync.Enable);
			this.setClearColor(Color.White);
			
			SDL_GL_MakeCurrent(this._window, this._glContext);
		}
		
		this._title = title;
		this._vMode = vMode;
		this._style = style;
		
		_WndFinalizer ~= this;
		
		_winCount += 1;
	}
	
	/**
	 * Close and destroy this window.
	 */
	void close() {
		// Once finished with OpenGL functions, the SDL_GLContext can be deleted.
		SDL_GL_DeleteContext(this._glContext);  
		// Close and destroy the window
		SDL_DestroyWindow(this._window);
		
		this._glContext = null;
		this._window = null;
		
		_winCount--;
	}
	
	/**
	 * Returns how many windows exist
	 */
	static int count() {
		return _winCount;
	}
	
	/**
	 * Returns the current VideoMode which hold the current width, the current height and the refresh rate.
	 * The first two can also be accessed with the 'width' and 'height' property.
	 */
	ref const(VideoMode) getVideoMode() const {
		return this._vMode;
	}
	
	/**
	 * Every window has an unique Id.
	 * This method returns this Id.
	 */
	@property
	uint id() {
		return SDL_GetWindowID(this._window);
	}
	
	/**
	 * Set the Syncronisation mode of this window.
	 * Default Syncronisation is <code>Sync.Enable</code>.
	 *
	 * See: Sync enum
	 *
	 * Returns if the sync mode is supported.
	 */
	bool setVerticalSync(Sync sync) const {
		if (sync == Sync.Enable || sync == Sync.Disable)
			return SDL_GL_SetSwapInterval(sync) == 0;
		else
			Log.error("Unknown sync mode. Sync mode must be one of Sync.Enable, Sync.Disable.");
		
		return false;
	}

	/**
	 * Returns the current syncronisation mode.
	 *
	 * See: Sync enum
	 */
	Sync getVerticalSync() {
		return cast(Sync) SDL_GL_GetSwapInterval();
	}
	
	/**
	 * Returns the Window Style.
	 * 
	 * See: Style enum
	 */
	Style getStyle() const pure nothrow {
		return this._style;
	}
	
	/**
	 * Capture the pixel data of the current window and
	 * returns a Surface with this pixel data.
	 * You can also alter the format of the pixel data.
	 * Default is <code>Texture.Format.BGRA</code>.
	 * This method is predestinated for screenshots.
	 * 
	 * Example:
	 * ---
	 * Window wnd = ...
	 * ...
	 * wnd.capture().saveToFile("samples/img/screenshot.png");
	 * ---
	 * 
	 * If you want to use the Screenshot more than only to save it,
	 * it could be better to wrap it into an Image.
	 * 
	 * Example:
	 * ----
	 * Window wnd = ...
	 * ...
	 * Image screen = new Image(wnd.capture());
	 * ----
	 */
	Surface capture(Texture.Format fmt = Texture.Format.BGRA) const {
		Surface mycapture = Surface.make(this.width, this.height);
		
		glReadBuffer(GL_FRONT);
		
		ubyte* pixels = cast(ubyte*) mycapture.pixels;
		glReadPixels(0, 0, this.width, this.height, fmt, GL_UNSIGNED_BYTE, pixels);
		
		const uint lineWidth = this.width * 4;
		const uint hlw = this.height * lineWidth;

		import Dgame.Internal.Allocator : type_malloc, type_free;

		ubyte* tmpLine = type_malloc!ubyte(lineWidth);
		scope(exit) type_free(tmpLine);

		for (ushort i = 0; i < this.height / 2; ++i) {
			const uint tmpIdx1 = i * lineWidth;
			const uint tmpIdx2 = (i + 1) * lineWidth;
			
			const uint switchIdx1 = hlw - tmpIdx2;
			const uint switchIdx2 = hlw - tmpIdx1;
			
			tmpLine[0 .. lineWidth] = pixels[tmpIdx1 .. tmpIdx2];
			ubyte[] switchLine = pixels[switchIdx1 .. switchIdx2];
			
			pixels[tmpIdx1 .. tmpIdx2] = switchLine[];
			pixels[switchIdx1 .. switchIdx2] = tmpLine[0 .. lineWidth];
		}
		
		return mycapture;
	}
	
	/**
	 * Returns if the keyboard focus is on this window.
	 */
	bool hasKeyboardFocus() const {
		return SDL_GetKeyboardFocus() == this._window;
	}
	
	/**
	 * Returns if the mouse focus is on this window.
	 */
	bool hasMouseFocus() const {
		return SDL_GetMouseFocus() == this._window;
	}
	
	/**
	 * Set the framerate limit for this window.
	 */
	void setFpsLimit(ubyte fps) pure nothrow {
		this._fpsLimit = fps;
	}
	
	/**
	 * Returns the framerate limit for this window.
	 */
	ubyte getFpsLimit() const pure nothrow {
		return this._fpsLimit;
	}
	
	/**
	 * Check if this window is still opened.
	 */
	@property
	bool isOpen() const pure nothrow {
		return this._window !is null;
	}
	
	/**
	 * Set the color with which this windows clear his buffer.
	 * This is also the background color of the window.
	 */
	void setClearColor(ref const Color col) {
		const float[4] rgba = col.asGLColor();
		glClearColor(rgba[0], rgba[1], rgba[2], rgba[3]);
	}
	
	/**
	 * Rvalue version
	 */
	void setClearColor(const Color col) {
		this.setClearColor(col);
	}
	
	/**
	 * Set the color with which this windows clear his buffer.
	 * This is also the background color of the window.
	 */
	void setClearColor(float red, float green, float blue, float alpha = 0.0) {
		glClearColor(red, green, blue, alpha);
	}
	
	/**
	 * Clears the buffer.
	 */
	void clear() const {
		glClear(GL_COLOR_BUFFER_BIT/* | GL_DEPTH_BUFFER_BIT*/);
	}
	
	/**
	 * Draw a drawable object on screen.
	 */
	void draw(Drawable draw) const in {
		assert(draw !is null, "Drawable object is null.");
	} body {
		draw.render();
	}
	
	/**
	 * Draw a Renderer on the screen.
	 */
	void draw(ref Renderer rtarget) const {
		rtarget.present();
	}
	
	/**
	 * Make all changes visible on screen.
	 * If the framerate limit is not 0, it waits for (1000 / framerate limit) milliseconds.
	 */
	void display() {
		if (!this.isOpen())
			return;
		
		if (this._fpsLimit != 0 && this.getVerticalSync() != Sync.Enable)
			Clock.wait(1000 / this._fpsLimit);

		if (this._style & Style.OpenGL) {
			if (_winCount > 1)
				SDL_GL_MakeCurrent(this._window, this._glContext);
			SDL_GL_SwapWindow(this._window);
		} else
			SDL_UpdateWindowSurface(this._window);
	}
	
	/**
	 * Set a new position to this window
	 */
	void setPosition(short x, short y) {
		SDL_SetWindowPosition(this._window, x, y);
	}
	
	/**
	 * Set a new position to this window
	 */
	void setPosition(ref const Vector2s vec) {
		this.setPosition(vec.x, vec.y);
	}
	
	/**
	 * Returns the current position of the window.
	 */
	Vector2s getPosition() {
		int x, y;
		this.fetchPosition(&x, &y);
		
		return Vector2s(x, y);
	}
	
	/**
	 * Fetch the current position if this window.
	 * The position is stored inside of the pointer.
	 * The pointer don't have to be null.
	 */
	void fetchPosition(int* x, int* y) in {
		assert(x !is null && y !is null, "x or y pointer is null.");
	} body {
		SDL_GetWindowPosition(this._window, x, y);
	}
	
	/**
	 * Returns the current title of the window.
	 */
	string getTitle() const pure nothrow {
		return this._title; /// SDL_GetWindowTitle(this._window);
	}
	
	/**
	 * Set a new title to this window
	 *
	 * Returns: the old title
	 */
	string setTitle(string title) {
		string old_title = this.getTitle();
		SDL_SetWindowTitle(this._window, title.ptr);
		
		return old_title;
	}
	
	/**
	 * Set a new size to this window
	 */
	void setSize(ushort width, ushort height) {
		SDL_SetWindowSize(this._window, width, height);
		
		this._vMode.width  = width;
		this._vMode.height = height;
	}
	
	void fetchSize(int* w, int* h) in {
		assert(w !is null && h !is null, "w or h pointer is null.");
	} body {
		SDL_GetWindowSize(this._window, w, h);
	}
	
	int[2] getSize() {
		int[2] size = void;
		this.fetchSize(&size[0], &size[1]);
		
		return size;
	}
	
	@property
	ushort width() const pure nothrow {
		return this._vMode.width;
	}
	
	@property
	ushort height() const pure nothrow {
		return this._vMode.height;
	}
	
	/**
	 * Raise the window.
	 * The window has after this call focus.
	 */
	void raise() {
		SDL_RaiseWindow(this._window);
	}
	
	/**
	 * Restore the window.
	 */
	void restore() {
		SDL_RestoreWindow(this._window);
	}
	
	/**
	 * Enable or Disable the screen saver.
	 */
	void setScreenSaver(bool enable) {
		if (enable)
			SDL_EnableScreenSaver();
		else
			SDL_DisableScreenSaver();
	}
	
	/**
	 * Returns if the screen saver is currently enabled, or not.
	 */
	bool isScreenSaverEnabled() const {
		return SDL_IsScreenSaverEnabled() == SDL_TRUE;
	}
	
	/**
	 * Show or hide the window.
	 * true shows, false hides.
	 */
	void show(bool show) {
		if (show)
			SDL_ShowWindow(this._window);
		else
			SDL_HideWindow(this._window);
	}
	
	/**
	 * When input is grabbed the mouse is confined to the window.
	 */
	void setGrabbed(bool enable) {
		SDL_SetWindowGrab(this._window, enable ? SDL_TRUE : SDL_FALSE);
	}
	
	/**
	 * Returns true, if input is grabbed.
	 */
	bool isGrabbed() {
		return SDL_GetWindowGrab(this._window) == SDL_TRUE;
	}
	
	/**
	 * Returns the brightness (gamma correction) for the window
	 * where 0.0 is completely dark and 1.0 is normal brightness.
	 */
	float getBrightness() {
		return SDL_GetWindowBrightness(this._window);
	}
	
	/**
	 * Set the brightness (gamma correction) for the window.
	 */
	bool setBrightness(float bright) {
		return SDL_SetWindowBrightness(this._window, bright) == 0;
	}
	
	enum FullScreenMask = Style.Fullscreen | Style.Desktop;
	
	/**
	 * Use this function to (re)set Window's fullscreen states.
	 * style may be Style.Fullscreen for "real" fullscreen with a videomode change
	 * or Style.Desktop for "fake" fullscreen that takes the size of the desktop
	 * Set 0 for windowed mode.
	 */
	void setFullscreen(int style) {
		if (style & this._style)
			return;
		
		if (style & FullScreenMask || style == 0) {
			if (SDL_SetWindowFullscreen(this._window, style) == 0) {
				this._style &= ~FullScreenMask;
				if (style != 0)
					this._style |= style;
			}
		}
	}
	
	/**
	 * Toggle between Fullscreen and windowed mode, depending on the current state.
	 */
	void toggleFullscreen() {
		if (this._style & FullScreenMask)
			this.setFullscreen(0);
		else
			this.setFullscreen(Style.Fullscreen);
	}
	
	/**
	 * Returns, if this Window is in fullscreen mode.
	 */
	bool isFullscreen() const pure nothrow {
		return (this._style & FullScreenMask) != 0;
	}
	
	/**
	 * Set an icon for this window.
	 */
	void setIcon(ref Surface icon) {
		SDL_SetWindowIcon(this._window, icon.ptr);
	}
}