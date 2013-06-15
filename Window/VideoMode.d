module Dgame.Window.VideoMode;

private {
	debug import std.stdio;
	import std.c.string : memcpy;
	
	import derelict.sdl2.sdl;
}

/**
 * The VideoMode struct contains informations about the current window video mode.
 * It is passed to Window which extract the informations and use them to build a window context.
 * 
 * Author: rschuett
 */
struct VideoMode {
public:
	/**
	 * The specific video modes
	 */
	enum {
		Fullscreen	= SDL_WINDOW_FULLSCREEN, /** Window is fullscreened */
		OpenGL		= SDL_WINDOW_OPENGL,	 /** OpenGL support */
		Shown		= SDL_WINDOW_SHOWN,		 /** Show the Window immediately */
		Borderless	= SDL_WINDOW_BORDERLESS, /** Hide the Window immediately */
		Resizeable	= SDL_WINDOW_RESIZABLE,  /** Window is resizeable */
		Maximized	= SDL_WINDOW_MAXIMIZED,  /** Maximize the Window immediately */
		Minimized	= SDL_WINDOW_MINIMIZED,  /** Minimize the Window immediately */
		InputGrabbed = SDL_WINDOW_INPUT_GRABBED, /* Grab the input inside the window */
		
		Default = Shown|OpenGL /** Default mode is Shown|OpenGL */
	}
	
	/**
	 * The real video mode
	 * 
	 * See: video mode enum
	 */
	const uint flag;
	const ushort width;			/** The width of this video mode */
	const ushort height;		/** The height of this video mode */
	const ubyte refreshRate; 	/** The refresh rate of this video mode */
	
private:
	this(int width, int height, uint flag, int hz) {
		this.width  = cast(ushort) width;
		this.height = cast(ushort) height;
		this.flag   = flag;
		this.refreshRate = cast(ubyte) hz;
	}
	
public:
	/**
	 * CTor
	 */
	this(ushort width, ushort height, uint flag) {
		this(width, height, flag, 0);
	}
	
	/**
	 * Returns: if the this video mode is valid which means, if it is listed from the OS
	 */
	bool isValid(ubyte display = 1) const {
		foreach (ref const VideoMode vm; VideoMode.listModes(display)) {
			if (vm == this)
				return true;
		}
		
		return false;
	}
	
	/**
	 * Checks whether this VideoMode has the given Flag
	 */
	bool hasFlag(uint flag) const pure nothrow {
		return cast(bool) this.flag & flag;
	}
	
	/**
	 * opEquals
	 */
	bool opEquals(ref const VideoMode vm) const pure nothrow {
		return vm.width == this.width && vm.height == this.height;
	}
	
	/**
	 * Returns: the desktop video mode
	 */
	static VideoMode getDesktopMode(ubyte display = 1) {
		SDL_DisplayMode mode;
		int result = SDL_GetDesktopDisplayMode(display, &mode);
		
		return VideoMode(mode.w, mode.h, VideoMode.Default, mode.refresh_rate);
	}
	
	/**
	 * Returns: the video mode on the given index
	 */
	static VideoMode getMode(uint index, ubyte display = 1) {
		SDL_DisplayMode mode;
		int result = SDL_GetDisplayMode(display, index, &mode);
		
		return VideoMode(mode.w, mode.h, VideoMode.Default, mode.refresh_rate);
	}
	
	/**
	 * Returns: A List of all valid supported video modes
	 */
	static VideoMode[] listModes(ubyte display = 1) {
		VideoMode[] displayModes;
		
		for (int i = 0; i < VideoMode.countModes(); ++i) {
			VideoMode vm = VideoMode.getMode(i, display);
			displayModes ~= vm;
		}
		
		return displayModes;
	}
	
	/**
	 * Returns: how much valid video modes are supported
	 */
	static int countModes(ubyte display = 1) {
		return SDL_GetNumDisplayModes(display);
	}
}
