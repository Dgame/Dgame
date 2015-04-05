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
import Dgame.System.GameController;

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
 * The Window move Event structure.
 */
struct WindowMoveEvent {
    /**
     * The new x position
     */
    int x;
    /**
     * The new y position
     */
    int y;
}

/**
 * The Window size Event structure.
 */
struct WindowSizeEvent {
    /**
     * The new width
     */
    int width;
    /**
     * The new height
     */
    int height;
}

/**
 * The Window Event structure.
 */
struct WindowEvent {
    /**
     * The Window Event id.
     */
    WindowEventId eventId;

    union {
        WindowSizeEvent size; /// Size Event
        WindowMoveEvent motion; /// Motion Event
    }
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
struct JoystickAxisEvent {
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
 * The Joystick button Event structure
 */
struct JoystickButtonEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
    /**
     * The index of the button which is pressed or released
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
struct JoystickHatEvent {
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
struct JoystickDeviceEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
}

/**
 * The Game Controller axis Event structure
 */
struct ControllerAxisEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
    /**
     * The index of the axis that changed
     * Typically 0 is the x axis, 1 is the y axis etc.
     */
    GameController.Axis axis;
    /**
     * The current position of the axis (range: -32768 to 32767)
     */
    short value;
}

/**
 * The Game Controller button Event structure
 */
struct ControllerButtonEvent {
    /**
     * The instance id of the joystick which reported the event
     */
    int which;
    /**
     * The GameController button which is pressed or released
     */
    GameController.Button button;
    /**
     * State of the button
     *
     * See: State enum
     */
    State state;
}

/**
 * The Game Controller device Event structure
 */
struct ControllerDeviceEvent {
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

        Window = SDL_WINDOWEVENT,  /// Something happens with the window.

        KeyDown = SDL_KEYDOWN,  /// A key is pressed.
        KeyUp = SDL_KEYUP,  /// A key is released.

        MouseMotion = SDL_MOUSEMOTION,  /// The mouse has moved.
        MouseButtonDown = SDL_MOUSEBUTTONDOWN,  /// A mouse button is pressed.
        MouseButtonUp = SDL_MOUSEBUTTONUP,  /// A mouse button is released.
        MouseWheel = SDL_MOUSEWHEEL,    /// The mouse wheel has scolled.

        JoystickAxisMotion = SDL_JOYAXISMOTION, // A Joystick axis has moved
        JoystickButtonDown = SDL_JOYBUTTONDOWN, // A Joystick button is pressed
        JoystickButtonUp = SDL_JOYBUTTONUP,  // A Joystick button is released
        JoystickHatMotion = SDL_JOYHATMOTION, // A Joystick hat has moved
        JoystickDeviceAdded = SDL_JOYDEVICEADDED, // A Joystick was added
        JoystickDeviceRemoved = SDL_JOYDEVICEREMOVED, // A Joystick was removed
        
        ControllerAxisMotion = SDL_CONTROLLERAXISMOTION, // A GameController axis has moved
        ControllerButtonDown = SDL_CONTROLLERBUTTONDOWN, // A GameController button is pressed
        ControllerButtonUp = SDL_CONTROLLERBUTTONUP,  // A GameController button is released
        ControllerDeviceAdded = SDL_CONTROLLERDEVICEADDED, // A GameController was added
        ControllerDeviceRemoved = SDL_CONTROLLERDEVICEREMOVED, // A GameController was removed
        ControllerDeviceMapped = SDL_CONTROLLERDEVICEREMAPPED, // A GameController was mapped
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
     * Joystick union
     */
    union JoystickUnion {
        JoystickAxisEvent motion; /// Joystick motion Event
        JoystickButtonEvent button; /// Joystick button Event
        JoystickHatEvent hat; /// Joystick hat Event
        JoystickDeviceEvent device; /// Joystick device Event
    }

    /**
     * Game Controller union
     */
    union ControllerUnion {
        ControllerAxisEvent motion; /// Controller motion Event
        ControllerButtonEvent button; /// Controller button Event
        ControllerDeviceEvent device; /// Controller device Event
    }
    
    union {
        KeyboardEvent keyboard; /// Keyboard Event
        WindowEvent window; /// Window Event
        MouseUnion mouse; /// Mouse Events
        JoystickUnion joystick; /// Joystick Events
        ControllerUnion controller; /// Controller Events
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
            
            switch (sdl_event.window.event) {
                case SDL_WINDOWEVENT_MOVED:
                    event.window.motion.x = sdl_event.window.data1;
                    event.window.motion.y = sdl_event.window.data2;

                    break;
                case SDL_WINDOWEVENT_RESIZED:
                    event.window.size.width = sdl_event.window.data1;
                    event.window.size.height = sdl_event.window.data2;

                    break;
                default: break;
            }
            
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
        case Event.Type.JoystickAxisMotion:
            event.type = Event.Type.JoystickAxisMotion;
            event.timestamp = sdl_event.jaxis.timestamp;
            event.joystick.motion.which = sdl_event.jaxis.which;
            event.joystick.motion.axis = sdl_event.jaxis.axis;
            event.joystick.motion.value = sdl_event.jaxis.value;

            return true;
        case Event.Type.JoystickButtonDown:
        case Event.Type.JoystickButtonUp:
            if (sdl_event.type == Event.Type.JoystickButtonUp)
                event.type = Event.Type.JoystickButtonUp;
            else
                event.type = Event.Type.JoystickButtonDown;

            if (sdl_event.jbutton.state == SDL_PRESSED)
                event.joystick.button.state = State.Pressed;
            else
                event.joystick.button.state = State.Released;

            event.timestamp = sdl_event.jbutton.timestamp;
            event.joystick.button.which = sdl_event.jbutton.which;
            event.joystick.button.button = sdl_event.jbutton.button;

            return true;
        case Event.Type.JoystickHatMotion:
            event.type = Event.Type.JoystickHatMotion;
            event.timestamp = sdl_event.jhat.timestamp;
            event.joystick.hat.hat = sdl_event.jhat.hat;
            event.joystick.hat.value = cast(Joystick.Hat) sdl_event.jhat.value;
            event.joystick.hat.which = sdl_event.jhat.which;

            return true;
        case Event.Type.JoystickDeviceAdded:
        case Event.Type.JoystickDeviceRemoved:
            if (sdl_event.type == Event.Type.JoystickDeviceAdded)
                event.type = Event.Type.JoystickDeviceAdded;
            else
                event.type = Event.Type.JoystickDeviceRemoved;

            event.timestamp = sdl_event.jdevice.timestamp;
            event.joystick.device.which = sdl_event.jdevice.which;

            return true;
        case Event.Type.ControllerAxisMotion:
            event.type = Event.Type.ControllerAxisMotion;
            event.timestamp = sdl_event.caxis.timestamp;
            event.controller.motion.which = sdl_event.caxis.which;
            event.controller.motion.axis = cast(GameController.Axis) sdl_event.caxis.axis;
            event.controller.motion.value = sdl_event.caxis.value;

            return true;
        case Event.Type.ControllerButtonDown:
        case Event.Type.ControllerButtonUp:
            event.timestamp = sdl_event.cbutton.timestamp;

            if (sdl_event.type == Event.Type.ControllerButtonUp)
                event.type = Event.Type.ControllerButtonUp;
            else
                event.type = Event.Type.ControllerButtonDown;

            if (sdl_event.cbutton.state == SDL_PRESSED)
                event.controller.button.state = State.Pressed;
            else
                event.controller.button.state = State.Released;

            event.controller.button.which = sdl_event.cbutton.which;
            event.controller.button.button = cast(GameController.Button) sdl_event.cbutton.button;

            return true;
        case Event.Type.ControllerDeviceAdded:
        case Event.Type.ControllerDeviceRemoved:
        case Event.Type.ControllerDeviceMapped:
            event.timestamp = sdl_event.cdevice.timestamp;

            if (sdl_event.type == Event.Type.ControllerDeviceAdded)
                event.type = Event.Type.ControllerDeviceAdded;
            else if (sdl_event.type == Event.Type.ControllerDeviceRemoved)
                event.type = Event.Type.ControllerDeviceRemoved;
            else
                event.type = Event.Type.ControllerDeviceMapped;

            event.controller.device.which = sdl_event.cdevice.which;

            return true;
        default: break;
    }

    return false;
}