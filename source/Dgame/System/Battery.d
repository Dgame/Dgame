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
module Dgame.System.Battery;

private import derelict.sdl2.sdl;

/**
 * This structure provide support for battery lifetime if you are on a laptop etc.
 */
struct Battery {
    /**
     * The Power States
     */
    enum State {
        Unknown   = SDL_POWERSTATE_UNKNOWN, /// Cannot determine power status
        OnBattery = SDL_POWERSTATE_ON_BATTERY, /// Not plugged in, running on the battery
        NoBattery = SDL_POWERSTATE_NO_BATTERY, /// plugged in, no battery available
        Charging  = SDL_POWERSTATE_CHARGING, /// plugged in, charging battery
        Charged   = SDL_POWERSTATE_CHARGED, /// plugged in, battery charged
    }
    
    /**
     * Remaining time in seconds, or -1 if cannot determine power status
     */
    int seconds;
    /**
     * Remaining battery percent, or -1 if cannot determine power status
     */
    byte percent;
    /**
     * Battery state
     */
    State state;
}

/**
 * The System struct contains the Power struct,
 * which give information about your current battery
 * and several other informations about your system, like the available RAM.
 * 
 * Author: Randy Schuett (rswhite4@googlemail.com)k
 */
interface System {
    /**
     * Returns the PowerInfo structure with the currently power informations
     * 
     * See: PowerInfo struct
     */
    @nogc
    static Battery getBatteryInfo() nothrow {
        int secs, pct;
        SDL_PowerState state = SDL_GetPowerInfo(&secs, &pct);
        
        return Battery(secs, cast(byte) pct, cast(Battery.State) state);
    }
    
    /**
     * Returns the available RAM
     */
    @nogc
    static int getRAM() nothrow {
        return SDL_GetSystemRAM();
    }
}