module Dgame.System.Touch;

private:

import derelict.sdl2.sdl;

public:

/**
 * The Finger structure
 */
struct Finger {
    /**
     * The Finger ID
     */
    long id; // TODO: change to (u)int?
    /**
     * The x coordinate in range of 0 .. 1
     * Multiply it with the width of the Window to get the real x coordinate
     */
    float x;
    /**
     * The y coordinate in range of 0 .. 1
     * Multiply it with the height of the Window to get the real y coordinate
     */
    float y;
    /**
     * The quantity of pressure applied in range of 0 .. 1
     */
    float pressure;
}

/**
 * Represent Touch-Events
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
interface Touch {
    /**
     * Returns of many Touch-Devices exist
     */
    @nogc
    static int getNumOfDevices() nothrow {
        return SDL_GetNumTouchDevices();
    }

    /**
     * Returns the Touch-ID of the Touch-Device with the given index
     */
    @nogc
    static long getDevice(int index) nothrow {
        return SDL_GetTouchDevice(index);
    }

    /**
     * Returns the amount of (supported) fingers for the Touch-Device with the given ID
     */
    @nogc
    static int getNumOfFingers(long touchId) nothrow {
        return SDL_GetNumTouchFingers(touchId);
    }

    /**
     * Returns the Finger with the given index of the Touch.Device with the given ID
     */
    @nogc
    static Finger getFinger(long touchId, int index) nothrow {
        const SDL_Finger* sdl_finger = SDL_GetTouchFinger(touchId, index);

        return Finger(sdl_finger.id, sdl_finger.x, sdl_finger.y, sdl_finger.pressure);
    }
}