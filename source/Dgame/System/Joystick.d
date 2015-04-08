module Dgame.System.Joystick;

private:

import derelict.sdl2.sdl;

import Dgame.Math.Vector2;

import Dgame.Internal.Error;

public:

/**
 * Represent a Joystick
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Joystick {
private:
    SDL_Joystick* _joystick;
    bool _owned = false;

public:
    /**
     * The supported Hat positions
     */
    enum Hat {
        Centered = SDL_HAT_CENTERED, ///
        Up = SDL_HAT_UP, ///
        Right = SDL_HAT_RIGHT, ///
        Down = SDL_HAT_DOWN, ///
        Left = SDL_HAT_LEFT, ///
        RightUp = SDL_HAT_RIGHTUP, ///
        RightDown = SDL_HAT_RIGHTDOWN, ///
        LeftUp = SDL_HAT_LEFTUP, ///
        LeftDown = SDL_HAT_LEFTDOWN ///
    }

    @nogc
    package this(SDL_Joystick* joy) nothrow {
        _joystick = joy;
        _owned = true;
    }

    /**
     * CTor
     */
    @nogc
    this(int device) nothrow {
        _joystick = SDL_JoystickOpen(device);
        if (!_joystick)
            print_fmt("Warning: Unable to open joystick %d! Error: %s\n", device, SDL_GetError());
    }

    /**
     * Postblit is disabled
     */
    @disable
    this(this);

    /**
     * DTor
     */
    @nogc
    ~this() nothrow {
        if (_joystick && !_owned)
            SDL_JoystickClose(_joystick);
    }

    /**
     * Returns true if the Joystick has been opened, false if not
     */
    @nogc
    bool isAttached() nothrow {
        return SDL_JoystickGetAttached(_joystick) == SDL_TRUE;
    }

    /**
     * Returns the delta position of the given Ball index since the last call
     */
    @nogc
    Vector2i getBallDelta(int ball) nothrow {
        int x, y;
        SDL_JoystickGetBall(_joystick, ball, &x, &y);

        return Vector2i(x, y);
    }

    /**
     * Returns whether the given Button is pressed
     */
    @nogc
    bool isPressed(int btn) nothrow {
        return SDL_JoystickGetButton(_joystick, btn) == 1;
    }

    /**
     * Returns the value of the given Axis index in range of short.min .. short.max
     */
    @nogc
    short getAxisValue(int axis) nothrow {
        return SDL_JoystickGetAxis(_joystick, axis);
    }

    /**
     * Returns the position of the given Hat index
     *
     * See: Hat enum
     */
    @nogc
    Hat getHat(int hat) nothrow {
        return cast(Hat) SDL_JoystickGetHat(_joystick, hat);
    }

    /**
     * Returns the ID of the Joystick
     */
    @property
    @nogc
    int ID() nothrow {
        return SDL_JoystickInstanceID(_joystick);
    }

    /**
     * Returns the name of the Joystick
     */
    @nogc
    string getName() nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_JoystickName(_joystick);
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }

    /**
     * Returns the amount of Axes of this Joystick
     */
    @nogc
    int getNumOfAxes() nothrow {
        return SDL_JoystickNumAxes(_joystick);
    }

    /**
     * Returns the amount of Balls of this Joystick
     */
    @nogc
    int getNumOfBalls() nothrow {
        return SDL_JoystickNumBalls(_joystick);
    }

    /**
     * Returns the amount of Buttons of this Joystick
     */
    @nogc
    int getNumOfButtons() nothrow {
        return SDL_JoystickNumButtons(_joystick);
    }

    /**
     * Returns the amount of Hats of this Joystick
     */
    @nogc
    int getNumOfHats() nothrow {
        return SDL_JoystickNumHats(_joystick);
    }

    /**
     * Use this function to update the current state of the open joysticks.
     * This is called automatically by the event loop
     */
    @nogc
    static void update() nothrow {
        //SDL_JoystickUpdate();
    }

    /**
     *  Returns the name of the Joystick of the given device
     */
    @nogc
    static string getNameForIndex(int device) nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_JoystickNameForIndex(device);
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }

    /**
     * Returns the amount of plugged Joysticks
     */
    @nogc
    static int count() nothrow {
        return SDL_NumJoysticks();
    }
}