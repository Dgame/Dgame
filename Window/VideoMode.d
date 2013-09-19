module Dgame.Window.VideoMode;

private {
	debug import std.stdio;
	
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
	ushort width;	/** The width of this video mode */
	ushort height;	/** The height of this video mode */
	ubyte refreshRate;	/** The refresh rate of this video mode */
	
private:
	this(int width, int height, int hz) {
		this.width  = cast(ushort) width;
		this.height = cast(ushort) height;
		this.refreshRate = cast(ubyte) hz;
	}
	
public:
	/**
	 * CTor
	 */
	this(ushort width, ushort height) {
		this(width, height, 0);
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
		
		return VideoMode(mode.w, mode.h, mode.refresh_rate);
	}
	
	/**
	 * Returns: the video mode on the given index
	 */
	static VideoMode getMode(uint index, ubyte display = 1) {
		SDL_DisplayMode mode;
		int result = SDL_GetDisplayMode(display, index, &mode);
		
		return VideoMode(mode.w, mode.h, mode.refresh_rate);
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
