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

import derelict.sdl2.sdl;

import Dgame.Math.Rect;

import Dgame.Internal.Error;

// All modes
DisplayMode[][] modes;

package(Dgame):

@nogc
SDL_DisplayMode* _transfer(ref const DisplayMode mode, ref SDL_DisplayMode sdl_mode) pure nothrow {
    sdl_mode.w = mode.width;
    sdl_mode.h = mode.height;
    sdl_mode.refresh_rate = mode.refreshRate;

    return &sdl_mode;
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
    this(uint width, uint height, ubyte hz = 60) pure nothrow {
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
     * Returns the desktop video mode at the given display
     *
     * Note: There's a difference between this and getMode when your application runs in fullscreen 
     *       and has changed the resolution. In that case this function will return the previous
     *       native display mode, and not the current display mode.
     */
    @nogc
    static DisplayMode getDesktopMode(ubyte display = 0) nothrow {
        SDL_DisplayMode mode = void;
        immutable int result = SDL_GetDesktopDisplayMode(display, &mode);
        if (result != 0)
            print_fmt("An error occured: %s\n", SDL_GetError());
        
        return DisplayMode(mode.w, mode.h, cast(ubyte) mode.refresh_rate);
    }
    
    /**
     * Returns the video mode at the given index and display
     */
    @nogc
    static DisplayMode getMode(uint index, ubyte display = 0) nothrow {
        SDL_DisplayMode mode = void;
        immutable int result = SDL_GetDisplayMode(display, index, &mode);
        if (result != 0)
            print_fmt("An error occured: %s\n", SDL_GetError());
        
        return DisplayMode(mode.w, mode.h, cast(ubyte) mode.refresh_rate);
    }

    /**
     * Returns the current video mode at the given display
     */
    @nogc
    static DisplayMode getCurrentMode(ubyte display = 0) nothrow {
        SDL_DisplayMode mode = void;
        immutable int result = SDL_GetCurrentDisplayMode(display, &mode);
        if (result != 0)
            print_fmt("An error occured: %s\n", SDL_GetError());
        
        return DisplayMode(mode.w, mode.h, cast(ubyte) mode.refresh_rate);
    }
    
    /**
     * Returns a List of all valid supported video modes at the given display
     */
    static DisplayMode[] listModes(ubyte display = 0) nothrow {
        if (modes.length == 0) {
            immutable int nod = DisplayMode.getNumOfDisplays();
            modes = new DisplayMode[][](nod);
        }
        
        if (modes[display].length != 0)
            return modes[display];
        
        immutable int num = DisplayMode.getNumOfModes(display);
        modes[display] = new DisplayMode[](num);

        for (int i = 0; i < num; ++i) {
            modes[display][i] = DisplayMode.getMode(i, display);
        }
        
        return modes[display];
    }

    /**
     * Returns the desktop area represented by the given display, with the primary display located at 0|0.
     */
    @nogc
    static Rect getDisplayBounds(ubyte display = 0) nothrow {
        SDL_Rect rect = void;
        SDL_GetDisplayBounds(display, &rect);

        return Rect(rect.x, rect.y, rect.w, rect.h);
    }

    /**
     * Returns the name of the given display
     */
    @nogc
    static string getDisplayName(ubyte display = 0) nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_GetDisplayName(display);
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }
    
    /**
     * Returns how many valid display modes are supported at the given display
     */
    @nogc
    static int getNumOfModes(ubyte display = 0) nothrow {
        return SDL_GetNumDisplayModes(display);
    }
    
    /**
     * Returns how many display are available.
     */
    @nogc
    static int getNumOfDisplays() nothrow {
        return SDL_GetNumVideoDisplays();
    }

    /**
     * Returns how many video drivers are available.
     */
    @nogc
    static int getNumOfVideoDrivers() nothrow {
        return SDL_GetNumVideoDrivers();
    }

    /**
     * Returns the name of the current video driver.
     */
    @nogc
    static string getCurrentVideoDriver() nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_GetCurrentVideoDriver();
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }
}