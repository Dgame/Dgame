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
module Dgame.Window.DisplayMode;

private:

import core.stdc.stdio : printf;

import derelict.sdl2.sdl;

DisplayMode[][] modes;

static this() {
    immutable int nod = DisplayMode.numOfDisplays();
    modes = new DisplayMode[][](nod);
}

public:

/**
 * The DisplayMode struct contains informations about the current window video mode.
 * It is passed to Window which extract the informations and use them to build a window context.
 * 
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct DisplayMode {
    /**
     * The width of this video mode
     */
    uint width;
    /**
     * The height of this video mode
     */
    uint height;
    /**
     * The refresh rate of this video mode
     */
    ubyte refreshRate;
    
    /**
     * CTor
     */
    @nogc
    this(uint width, uint height, ubyte hz) pure nothrow {
        this.width  = width;
        this.height = height;
        this.refreshRate = hz;
    }
    
    /**
     * opEquals
     */
    @nogc
    bool opEquals(ref const DisplayMode dm) const pure nothrow {
        return dm.width == this.width && dm.height == this.height && dm.refreshRate == this.refreshRate;
    }
    
    /**
     * Returns: the desktop video mode
     */
    @nogc
    static DisplayMode getDesktopMode(ubyte display = 1) nothrow {
        SDL_DisplayMode mode = void;
        immutable int result = SDL_GetDesktopDisplayMode(display, &mode);
        if (result != 0)
            printf("An error occured: %s\n", SDL_GetError());
        
        return DisplayMode(mode.w, mode.h, cast(ubyte) mode.refresh_rate);
    }
    
    /**
     * Returns: the video mode on the given index
     */
    @nogc
    static DisplayMode getMode(uint index, ubyte display = 1) nothrow {
        SDL_DisplayMode mode = void;
        immutable int result = SDL_GetDisplayMode(display, index, &mode);
        if (result != 0)
            printf("An error occured: %s\n", SDL_GetError());
        
        return DisplayMode(mode.w, mode.h, cast(ubyte) mode.refresh_rate);
    }
    
    /**
     * Returns: A List of all valid supported video modes
     */
    static DisplayMode[] listModes(ubyte display = 1) nothrow {
        if (modes[display].length != 0)
            return modes[display];
        
        for (int i = 0; i < DisplayMode.numOfModes(display); ++i) {
            modes[display] ~= DisplayMode.getMode(i, display);
        }
        
        return modes[display];
    }
    
    /**
     * Returns how many valid display modes are supported
     */
    @nogc
    static int numOfModes(ubyte display = 1) nothrow {
        return SDL_GetNumDisplayModes(display);
    }
    
    /**
     * Returns how many display are available.
     */
    @nogc
    static int numOfDisplays() nothrow {
        return SDL_GetNumVideoDisplays();
    }
}