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
module Dgame.Window.Event;

private:

import derelict.sdl2.sdl;

import Dgame.System.Mouse;
import Dgame.System.Keyboard;
import Dgame.System.Joystick;

public:

/**
 * Specific Window Events.
 */
enum WindowEventId : ubyte {
    None,   /// Nothing happens
    Shown,  /// Window has been shown
    Hidden, /// Window has been hidden
    Exposed,    /// Window has been exposed and should be redrawn
    Moved,  /// Window has been moved to data1, data2 
    Resized,    /// Window has been resized to data1Xdata2
    SizeChanged,    /// The window size has changed, 
                    /// either as a result of an API call or through 
                    /// the system or user changing the window size. */
    Minimized,  /// Window has been minimized.
    Maximized,  /// Window has been maximized.
    Restored,   /// Window has been restored to normal size and position.
    Enter,  /// Window has gained mouse focus.
    Leave,  /// Window has lost mouse focus.
    FocusGained,    /// Window has gained keyboard focus.
    FocusLost,  /// Window has lost keyboard focus.
    Closed  /// The window manager requests that the window be closed.
}

/**
 * States
 */
enum State : ubyte {
    Released, /// 
    Pressed /// 
}

/**
 * The Window Event structure.
 */
struct WindowEvent {
    /**
     * The Window Event id.
     */
    WindowEventId eventId;
}

/**
 * The Keyboard Event structure.
 */
struct KeyboardEvent {
    /**
     * State of the key
     *
     * See: State enum
     */
    State state;
    /**
     * The Key which is released or pressed.
     */
    Keyboard.Code code;
    /**
     * The Key modifier.
     */
    Keyboard.Mod mod;
    /**
     * true, if this is a key repeat.
     */
    bool repeat;

    /**
     * An alias
     */
    alias key = code;
}

/**
 * The Mouse button Event structure.
 */
struct MouseButtonEvent {
    /**
     * The mouse button which is pressed or released.
     */
    Mouse.Button button;
    /**
     * State of the button
     *
     * See: State enum
     */
    State state;
    /**
     * 1 for single-click, 2 for double-click, etc.
     */
    ubyte clicks;
    /**
     * Current x position.
     */
    int x;
    /**
     * Current y position.
     */
    int y;
}

/**
 * The Mouse motion Event structure.
 */
struct MouseMotionEvent {
    /**
     * State of the button
     *
     * See: State enum
     */
    State state;
    /**
     * Current x position.
     */
    int x;
    /**
     * Current y position.
     */
    int y;
    /**
     * Relative motion in the x direction.
     */
    int rel_x;
    /**
     * Relative motion in the y direction.
     */
    int rel_y;
}

/**
 * The Mouse wheel Event structure.
 */
struct MouseWheelEvent {
    /**
     * The amount scrolled horizontally, positive to the right and negative to the left
     */
    int x;
    /**
     * The amount scrolled vertically, positive away from the user and negative toward the user
     */
    int y;

static if (SDL_VERSION_ATLEAST(2, 0, 4)) {
    /**
     * If true, the values in x and y will be opposite. Multiply by -1 to change them back.
     */
    bool flipped;
}
}

/**
 * The Joystick axis motion Event structure
 */
struct JoyAxisEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
    /**
     * The index of the axis that changed
     * Typically 0 is the x axis, 1 is the y axis etc.
     */
    ubyte axis;
    /**
     * The current position of the axis (range: -32768 to 32767)
     */
    short value;
}

/**
 * The Joystick abutton Event structure
 */
struct JoyButtonEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
    /**
     * The index of the button that changed
     */
    ubyte button;
    /**
     * State of the button
     *
     * See: State enum
     */
    State state;
}

/**
 * The Joystick hat Event structure
 */
struct JoyHatEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
    /**
     * The index of the hat that changed
     */
    ubyte hat;
    /**
     * The new position of the hat
     *
     * See Joystick.Hat enum
     */
    Joystick.Hat value;
}

/**
 * The Joystick device Event structure
 */
struct JoyDeviceEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
}

/**
 * The Event structure.
 * Event defines a system event and it's parameters
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Event {
    /**
     * All supported Event Types.
     */
    enum Type {
        Quit = SDL_QUIT,    /// Quit Event. Time to close the window.
        Window  = SDL_WINDOWEVENT,  /// Something happens with the window.
        KeyDown = SDL_KEYDOWN,  /// A key is pressed.
        KeyUp = SDL_KEYUP,  /// A key is released.
        MouseMotion = SDL_MOUSEMOTION,  /// The mouse has moved.
        MouseButtonDown = SDL_MOUSEBUTTONDOWN,  /// A mouse button is pressed.
        MouseButtonUp = SDL_MOUSEBUTTONUP,  /// A mouse button is released.
        MouseWheel = SDL_MOUSEWHEEL,    /// The mouse wheel has scolled.
        JoyAxisMotion = SDL_JOYAXISMOTION, // A Joystick axis has moved
        JoyButtonDown = SDL_JOYBUTTONDOWN, // A Joystick button is pressed
        JoyButtonUp = SDL_JOYBUTTONUP,  // A Joystick button is released
        JoyHatMotion = SDL_JOYHATMOTION, // A Joystick hat has moved
        JoyDeviceAdded = SDL_JOYDEVICEADDED, // A Joystick was added
        JoyDeviceRemoved = SDL_JOYDEVICEREMOVED, // A Joystick was removed
    }

    /**
     * The type of the Event
     */
    Type type;
    /**
     * Milliseconds since the app is running
     */
    uint timestamp;
    /**
     * The window which has raised this event
     */
    uint windowId;

    /**
     * Mouse union
     */
    union MouseUnion {
        MouseButtonEvent button; /// Mouse button Event
        MouseMotionEvent motion; /// Mouse motion Event
        MouseWheelEvent  wheel; /// Mouse wheel Event
    }

    /**
     * JoyStick union
     */
    union JoystickUnion {
        JoyAxisEvent motion; /// Joystick motion Event
        JoyButtonEvent button; /// Joystick button Event
        JoyHatEvent hat; /// Joystick hat Event
        JoyDeviceEvent device; /// Joystick device Event
    }
    
    union {
        KeyboardEvent keyboard; /// Keyboard Event
        WindowEvent window; /// Window Event
        MouseUnion mouse; /// Mouse Events
        JoystickUnion joy; /// Joystick Events
    }
}

package:

@nogc
bool _translate(Event* event, ref const SDL_Event sdl_event) nothrow {
    assert(event, "Event is null");

    switch (sdl_event.type) {
        case Event.Type.KeyDown:
        case Event.Type.KeyUp:
            if (sdl_event.key.state == SDL_PRESSED)
                event.keyboard.state = State.Pressed;
            else
                event.keyboard.state = State.Released;

            event.type = sdl_event.type == Event.Type.KeyDown ? Event.Type.KeyDown : Event.Type.KeyUp;
            event.timestamp = sdl_event.key.timestamp;
            event.windowId = sdl_event.key.windowID;
            event.keyboard.code = cast(Keyboard.Code) sdl_event.key.keysym.sym;
            event.keyboard.repeat = sdl_event.key.repeat != 0;
            event.keyboard.mod = Keyboard.getModifier();

            return true;
        case Event.Type.Window:
            event.type = Event.Type.Window;
            event.windowId = sdl_event.window.windowID;
            event.timestamp = sdl_event.window.timestamp;
            event.window.eventId = cast(WindowEventId) sdl_event.window.event;
            
            return true;
        case Event.Type.Quit:
            event.type = Event.Type.Quit;
            
            return true;
        case Event.Type.MouseButtonDown:
        case Event.Type.MouseButtonUp:
            if (sdl_event.type == Event.Type.MouseButtonUp)
                event.type = Event.Type.MouseButtonUp;
            else
                event.type = Event.Type.MouseButtonDown;

            if (sdl_event.button.state == SDL_PRESSED)
                event.mouse.button.state = State.Pressed;
            else
                event.mouse.button.state = State.Released;
            
            event.timestamp = sdl_event.button.timestamp;
            event.windowId  = sdl_event.button.windowID;
            event.mouse.button.button = cast(Mouse.Button) sdl_event.button.button;
            event.mouse.button.clicks = sdl_event.button.clicks;
            event.mouse.button.x = sdl_event.button.x;
            event.mouse.button.y = sdl_event.button.y;
            
            return true;
        case Event.Type.MouseMotion:
                if (sdl_event.motion.state == SDL_PRESSED)
                event.mouse.motion.state = State.Pressed;
            else
                event.mouse.motion.state = State.Released;

            event.type = Event.Type.MouseMotion;
            event.timestamp = sdl_event.motion.timestamp;
            event.windowId  = sdl_event.motion.windowID;
            event.mouse.motion.x = sdl_event.motion.x;
            event.mouse.motion.y = sdl_event.motion.y;
            event.mouse.motion.rel_x = sdl_event.motion.xrel;
            event.mouse.motion.rel_y = sdl_event.motion.yrel;
            
            return true;
        case Event.Type.MouseWheel:
            event.type = Event.Type.MouseWheel;
            event.timestamp = sdl_event.wheel.timestamp;
            event.windowId  = sdl_event.wheel.windowID;
            event.mouse.wheel.x = sdl_event.wheel.x;
            event.mouse.wheel.y = sdl_event.wheel.y;

            static if (SDL_VERSION_ATLEAST(2, 0, 4)) {
                event.mouse.wheel.flipped = sdl_event.wheel.direction == SDL_MOUSEWHEEL_FLIPPED;
            }
            
            return true;
        case Event.Type.JoyAxisMotion:
            event.type = Event.Type.JoyAxisMotion;
            event.timestamp = sdl_event.jaxis.timestamp;
            event.joy.motion.which = sdl_event.jaxis.which;
            event.joy.motion.axis = sdl_event.jaxis.axis;
            event.joy.motion.value = sdl_event.jaxis.value;

            return true;
        case Event.Type.JoyButtonDown:
        case Event.Type.JoyButtonUp:
            if (sdl_event.type == Event.Type.JoyButtonUp)
                event.type = Event.Type.JoyButtonUp;
            else
                event.type = Event.Type.JoyButtonDown;

            if (sdl_event.jbutton.state == SDL_PRESSED)
                event.joy.button.state = State.Pressed;
            else
                event.joy.button.state = State.Released;

            event.timestamp = sdl_event.jbutton.timestamp;
            event.joy.button.which = sdl_event.jbutton.which;
            event.joy.button.button = sdl_event.jbutton.button;

            return true;
        case Event.Type.JoyHatMotion:
            event.type = Event.Type.JoyHatMotion;
            event.timestamp = sdl_event.jhat.timestamp;
            event.joy.hat.hat = sdl_event.jhat.hat;
            event.joy.hat.value = cast(Joystick.Hat) sdl_event.jhat.value;
            event.joy.hat.which = sdl_event.jhat.which;

            return true;
        case Event.Type.JoyDeviceAdded:
        case Event.Type.JoyDeviceRemoved:
            if (sdl_event.type == Event.Type.JoyDeviceAdded)
                event.type = Event.Type.JoyDeviceAdded;
            else
                event.type = Event.Type.JoyDeviceRemoved;

            event.timestamp = sdl_event.jdevice.timestamp;
            event.joy.device.which = sdl_event.jdevice.which;

            return true;
        default: break;
    }

    return false;
}