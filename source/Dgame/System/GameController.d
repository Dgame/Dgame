module Dgame.System.GameController;

private:

import derelict.sdl2.sdl;

import Dgame.System.Joystick;

import Dgame.Internal.Error;

public:

/**
 * Represent a Game Controller
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct GameController {
private:
    SDL_GameController* _controller;

public:
    /**
     * Supported Game Controller Axis
     */
    enum Axis {
        Invalid = SDL_CONTROLLER_AXIS_INVALID, ///
        LeftX = SDL_CONTROLLER_AXIS_LEFTX, ///
        LeftY = SDL_CONTROLLER_AXIS_LEFTY, ///
        RightX = SDL_CONTROLLER_AXIS_RIGHTX, ///
        RightY = SDL_CONTROLLER_AXIS_RIGHTY, ///
        TriggerLeft = SDL_CONTROLLER_AXIS_TRIGGERLEFT, ///
        TriggerRight = SDL_CONTROLLER_AXIS_TRIGGERRIGHT ///
    }

    /**
     * Supported Game Controller Buttons
     */
    enum Button {
        Invalid = SDL_CONTROLLER_BUTTON_INVALID, ///
        A = SDL_CONTROLLER_BUTTON_A, ///
        B = SDL_CONTROLLER_BUTTON_B, ///
        X = SDL_CONTROLLER_BUTTON_X, ///
        Y = SDL_CONTROLLER_BUTTON_Y, ///
        Back = SDL_CONTROLLER_BUTTON_BACK, ///
        Guide = SDL_CONTROLLER_BUTTON_GUIDE, ///
        Start = SDL_CONTROLLER_BUTTON_START, ///
        LeftStick = SDL_CONTROLLER_BUTTON_LEFTSTICK, ///
        RightStick = SDL_CONTROLLER_BUTTON_RIGHTSTICK, ///
        LeftShoulder = SDL_CONTROLLER_BUTTON_LEFTSHOULDER, ///
        RightShoulder = SDL_CONTROLLER_BUTTON_RIGHTSHOULDER, ///
        DPadUp = SDL_CONTROLLER_BUTTON_DPAD_UP, ///
        DPadDown = SDL_CONTROLLER_BUTTON_DPAD_DOWN, ///
        DPadLeft = SDL_CONTROLLER_BUTTON_DPAD_LEFT, ///
        DPadRight = SDL_CONTROLLER_BUTTON_DPAD_RIGHT ///
    }

    /**
     * CTor
     */
    @nogc
    this(int device) nothrow {
        _controller = SDL_GameControllerOpen(device);
        if (!_controller)
            print_fmt("Warning: Unable to open game controller %d! Error: %s\n", device, SDL_GetError());
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
        if (_controller)
            SDL_GameControllerClose(_controller);
    }

    /**
     * Returns if the GameController has been opened and is currently connected.
     */
    @nogc
    bool isAttached() nothrow {
        return SDL_GameControllerGetAttached(_controller) == SDL_TRUE;
    }

    /**
     * Returns the value of the given Axis.
     * The value is in range of short.min .. short.max
     *
     * See: Axis enum
     */
    @nogc
    short getAxisValue(Axis axis) nothrow {
        return SDL_GameControllerGetAxis(_controller, axis);
    }

    /**
     * Returns whether the given Button is pressed
     */
    @nogc
    bool isPressed(Button btn) nothrow {
        return SDL_GameControllerGetButton(_controller, btn) == 1;
    }

    /**
     * Returns the name of the GameController
     */
    @nogc
    string getName() nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_GameControllerName(_controller);
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }

    /**
     * Returns the mapping of the GameController
     */
    @nogc
    string getMapping() nothrow {
        import core.stdc.string : strlen;

        const char* p =  SDL_GameControllerMapping(_controller);
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }

    /**
     * Returns the Joystick interface of the GameController
     */
    @nogc
    Joystick getJoystick() nothrow {
        SDL_Joystick* joy = SDL_GameControllerGetJoystick(_controller);

        return Joystick(joy);
    }

    /**
     * Use this function to update the current state of the open GameController.
     * This function is called automatically by the event loop
     */
    @nogc
    static void update() nothrow {
        SDL_GameControllerUpdate();
    }

    /**
     * Returns the name of the GameController of the given device
     */
    @nogc
    static string getNameForIndex(int device) nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_GameControllerNameForIndex(device);
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }

    /**
     * Returns if the given device (e.g. a Joystick) is supported by the GameController interface.
     *
     * Note: Only if this method returns true, the device can be handled with the GameController struct
     */
    @nogc
    static bool isGameController(int device) nothrow {
        return SDL_IsGameController(device) == SDL_TRUE;
    }
}