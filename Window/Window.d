module Dgame.Window.Window;

private {
	debug import std.stdio;
	
	import derelict.sdl2.sdl;
	import derelict2.opengl.gl;
	
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Drawable;
	import Dgame.Graphics.Surface;
	import Dgame.Graphics.Texture;
	import Dgame.Graphics.RenderTarget;
	import Dgame.Graphics.TileMap;
	import Dgame.Math.Vector2;
	import Dgame.Window.VideoMode;
	
	import Dgame.Core.Allocator;
	import Dgame.Core.Finalizer;
}

public import Dgame.System.Clock;

/**
 * Window is a rendering window where all drawable objects are drawn.
 *
 * Note that the default clear-color is <code>Color.White</code> and the
 * default Sync is <code>Window.Sync.Enable</code>.
 *
 * Author: rschuett
 */
class Window {
public:
	/**
	 * The Window syncronisation mode.
	 * Default Syncronisation is <code>Sync.Enable</code>.
	 */
	enum Sync {
		Enable  = 1,	/** Sync is enabled. */
		Disable = 0,	/** Sync is disabled. */
		None	= -1	/** Unknown State. */
	}
	
	/**
	 * Window VideoMode's
	 */
	const VideoMode vMode;
	
private:
	/// Defaults
	enum {
		DefaultTitle = "App",
		DefaultXPos  = 25,
		DefaultYPos  = 50
	}
	
protected:
	SDL_Window* _window;
	SDL_GLContext _glContext;
	
	Color _clearColor = Color.White;
	
	string _title;
	bool _open;
	bool _fullscreen;
	ubyte _fpsLimit;
	
	static int _winCount;
	
	Clock _clock;
	
public:
final:
	
	/**
	 * CTor
	 */
	this(VideoMode vMode) {
		this(vMode, DefaultXPos, DefaultYPos);
	}
	
	/**
	 * CTor
	 */
	this(VideoMode vMode, string title) {
		this(vMode, DefaultXPos, DefaultYPos, title);
	}
	
	/**
	 * CTor
	 */
	this(VideoMode vMode, short x, short y, string title = DefaultTitle) {
		/// Create an application window with the following settings:
		this._window = SDL_CreateWindow(title.ptr,		///    const char* title
		                                x,				///    int x: initial x position
		                                y,				///    int y: initial y position
		                                vMode.width,	///    int w: width, in pixels
		                                vMode.height,	///    int h: height, in pixels
		                                vMode.flag		///    Uint32 flags: window options, see below
		                                );
		/// Check that the window was successfully made
		assert(this._window !is null, "Error by creating a SDL2 window.");
		
		if (vMode.flag & VideoMode.OpenGL) {
			SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
			SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
			SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
			SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
			SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
			SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
			
			this._glContext = SDL_GL_CreateContext(this._window);
			assert(this._glContext !is null, "Error while creating gl context.");
			
			GLVersion glver = DerelictGL.loadExtendedVersions(DerelictGL.maxVersion()); 
			//DerelictGL.loadExtensions();
			debug writeln("GLVersion: ", glver); /// which gl version
			
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			
			glEnable(GL_CULL_FACE);
			glCullFace(GL_FRONT);
			
			glDisable(GL_DITHER);
			
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			
			glOrtho(0, vMode.width, vMode.height, 0, 1, -1);
			
			this.setVerticalSync(Sync.Enable);
			
			SDL_GL_MakeCurrent(this._window, this._glContext);
			
			this.initClearColor();
		}
		
		this._title = title;
		this.vMode = vMode;
		
		this._open = true;
		this._fullscreen = vMode.flag & VideoMode.Fullscreen;
		
		_winCount += 1;
	}
	
	/**
	 * Close and destroy this window.
	 */
	void close() {
		/// Once finished with OpenGL functions, the SDL_GLContext can be deleted.
		SDL_GL_DeleteContext(this._glContext);  
		/// Close and destroy the window
		SDL_DestroyWindow(this._window);
		
		this._open = false;
		
		_winCount--;
		if (!_winCount)
			terminate(); /// finalize all remaining sensible SDL memory
	}
	
	/**
	 * Returns how many windows exist
	 */
	static uint count() {
		return _winCount;
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
	 */
	void setVerticalSync(Sync sync) const {
		if (sync == Sync.Enable || sync == Sync.Disable) {
			int supported = SDL_GL_SetSwapInterval(sync);
			debug if (supported != 0) writeln("Sync mode is not supported.");
		} else
			throw new Exception("Unknown sync mode. Sync mode must be one of Sync.Enable, Sync.Disable.");
	}
	
	/**
	 * Returns the current syncronisation mode.
	 *
	 * See: Sync enum
	 */
	Sync getVerticalSync() const {
		int result = SDL_GL_GetSwapInterval();
		
		return cast(Sync) result;
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
		Surface temp = Surface.make(this.vMode.width, this.vMode.height);
		
		const size_t psize = 4 * this.vMode.width * this.vMode.height;
		auto pixels = Memory.alloc!ubyte(psize, Mode.AutoFree);
		
		glReadPixels(0, 0, this.vMode.width, this.vMode.height, fmt, GL_UNSIGNED_BYTE, pixels.ptr);
		
		void* temp_pixels = temp.getPixels();
		
		for (ushort i = 0 ; i < this.vMode.height ; i++) {
			memcpy(temp_pixels + temp.getPitch() * i, 
			       pixels.ptr + 4 * this.vMode.width * (this.vMode.height - i - 1), 
			       this.vMode.width * 4);
		}
		
		return temp;
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
	 * Returns the window clock. You can freeze the application or get the current framerate.
	 * 
	 * See: Dgame.System.Clock
	 */
	ref Clock getClock() {
		if (this._clock !is null)
			return this._clock;
		
		this._clock = new Clock();
		
		return this._clock;
	}
	
	/**
	 * Set the framerate limit for this window.
	 */
	void setFpsLimit(ubyte fps) {
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
		return this._open;
	}
	
	/**
	 * Init the current clear color.
	 */
	void initClearColor() const {
		glClearColor(this._clearColor.red, this._clearColor.green, 
		             this._clearColor.blue, this._clearColor.alpha);
	}
	
	/**
	 * Set the color with which this windows clear his buffer.
	 * This is also the background color of the window.
	 */
	void setClearColor(ref const Color col) {
		if (this._clearColor != col) {
			this._clearColor = col;
			
			float[4] rgba = col.convertToGL();
			
			glClearColor(rgba[0], rgba[1], rgba[2], rgba[3]);
		}
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
		this._clearColor.set(red, green, blue, alpha);
		
		glClearColor(red, green, blue, alpha);
	}
	
	/**
	 * Returns the current clear color.
	 */
	ref const(Color) getClearColor() const pure nothrow {
		return this._clearColor;
	}
	
	/**
	 * Clears the buffer.
	 */
	void clear() const {
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	
	/**
	 * Draw a drawable object on screen.
	 */
	void draw(Drawable draw) in {
		assert(draw !is null, "Drawable object is null.");
	} body {
		draw.render();
	}
	
	/**
	 * Draw a Render Target on screen.
	 */
	void draw(ref RenderTarget rtarget) {
		rtarget.present();
	}
	
	/**
	 * Make all changes visible on screen.
	 * If the framerate limit is not 0, it waits for (1000 / framerate limit) milliseconds.
	 */
	void display() {
		if (!this._open)
			return;
		
		if (this._fpsLimit)
			this.getClock().wait(1000 / this._fpsLimit);
		
		if (this.vMode.flag & VideoMode.OpenGL)
			SDL_GL_SwapWindow(this._window);
		else
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
	void fetchPosition(int* x, int* y) {
		assert(x !is null && y !is null, "x or y pointer is null.");
		
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
	 * Returns the width.
	 */
	@property
	ushort width() const pure nothrow {
		return this.vMode.width;
	}
	
	/**
	 * Returns the height.
	 */
	@property
	ushort height() const pure nothrow {
		return this.vMode.height;
	}
	
	/**
	 * Set a new size to this window
	 * if width or height is zero, the old width/height is used.
	 */
	void setSize(ushort width, ushort height) {
		width = width > 0 ? width : this.vMode.width;
		height = height > 0 ? height : this.vMode.height;
		
		SDL_SetWindowSize(this._window, width, height);
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
	
	/**
	 * Enable or disable Fullscreen mode.
	 */
	void setFullscreen(bool enable) {
		if (enable == this._fullscreen)
			return;
		
		if (SDL_SetWindowFullscreen(this._window, enable) == 0)
			this._fullscreen = enable;
	}
	
	/**
	 * Check whether this Window is currently windowed, or not.
	 */
	bool isFullscreen() const pure nothrow {
		return this._fullscreen;
	}
	
	/**
	 * Set an icon for this window.
	 */
	void setIcon(ref Surface icon) {
		SDL_SetWindowIcon(this._window, icon.ptr);
	}
}