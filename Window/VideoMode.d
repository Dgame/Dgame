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
module Dgame.Window.VideoMode;

private {
	import std.conv : to;
	
	import derelict.sdl2.sdl;
	
	import Dgame.Internal.Log;
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
	
public:
	/**
	 * CTor
	 */
	this(uint width, uint height, uint hz = 0) {
		this.width  = cast(ushort) width;
		this.height = cast(ushort) height;
		
		this.refreshRate = cast(ubyte) hz;
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
		if (result != 0)
			Log.error(to!string(SDL_GetError()));
		
		return VideoMode(mode.w, mode.h, mode.refresh_rate);
	}
	
	/**
	 * Returns: the video mode on the given index
	 */
	static VideoMode getMode(uint index, ubyte display = 1) {
		SDL_DisplayMode mode;
		int result = SDL_GetDisplayMode(display, index, &mode);
		if (result != 0)
			Log.error(to!string(SDL_GetError()));
		
		return VideoMode(mode.w, mode.h, mode.refresh_rate);
	}
	
	/**
	 * Returns: A List of all valid supported video modes
	 */
	static VideoMode[] listModes(ubyte display = 1) {
		VideoMode[] displayModes;
		
		for (int i = 0; i < VideoMode.countModes(); ++i) {
			displayModes ~= VideoMode.getMode(i, display);
		}
		
		return displayModes;
	}
	
	/**
	 * Returns how many valid video modes are supported
	 */
	static int countModes(ubyte display = 1) {
		return SDL_GetNumDisplayModes(display);
	}
	
	/**
	 * Returns how many display are available.
	 */
	static int countDisplays() {
		return SDL_GetNumVideoDisplays();
	}
}
