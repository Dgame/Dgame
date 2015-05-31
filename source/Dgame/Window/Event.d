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
     * All supported Window Event Types
     */
    enum Type {
        Shown = SDL_WINDOWEVENT_SHOWN,  /// Window has been shown
        Hidden = SDL_WINDOWEVENT_HIDDEN, /// Window has been hidden
        Exposed = SDL_WINDOWEVENT_EXPOSED,    /// Window has been exposed and should be redrawn
        Moved = SDL_WINDOWEVENT_MOVED,  /// Window has been moved
        Resized = SDL_WINDOWEVENT_RESIZED,    /// Window has been resized
        SizeChanged = SDL_WINDOWEVENT_SIZE_CHANGED, /// Window size has changed; this event is followed by Type.Resized
        Minimized = SDL_WINDOWEVENT_MINIMIZED,  /// Window has been minimized
        Maximized = SDL_WINDOWEVENT_MAXIMIZED,  /// Window has been maximized
        Restored = SDL_WINDOWEVENT_RESTORED,   /// Window has been restored to normal size and position
        Enter = SDL_WINDOWEVENT_ENTER,  /// Window has gained mouse focus
        Leave = SDL_WINDOWEVENT_LEAVE,  /// Window has lost mouse focus
        FocusGained = SDL_WINDOWEVENT_FOCUS_GAINED,    /// Window has gained keyboard focus
        FocusLost = SDL_WINDOWEVENT_FOCUS_LOST,  /// Window has lost keyboard focus
        Close = SDL_WINDOWEVENT_CLOSE /// The window manager requests that the window be closed
    }

    /**
     * The Type of the Window Event
     */
    Type event;

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
     * true, if the key is pressed
     */
    bool isPressed;
    /**
     * The Key which is released or pressed.
     */
    Keyboard.Key key;
    /**
     * The Key modifier.
     */
    Keyboard.Mod mod;
    /**
     * true, if this is a key repeat.
     */
    bool isRepeat;
    /**
     * An alias
     */
    deprecated("Use 'key' instead")
    alias code = key;
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
     * true, if the button is pressed
     */
    bool isPressed;
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
     * true, if the button is pressed
     */
    bool isPressed;
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
    bool isFlipped;
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
     * true, if the button is pressed
     */
    bool isPressed;
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
     * true, if the button is pressed
     */
    bool isPressed;
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
 * The Finger Touch Event structure
 */
struct TouchFingerEvent {
    /**
     * The id of the touch device
     */
    long touchId;
    /**
     * The id of the finger who touched the device
     */
    long fingerId;
    /**
     * The x coordinate of the touch event, in range of 0 .. 1
     * Multiply it with the width if the Window to get the real x coordinate
     */
    float x;
    /**
     * The y coordinate of the touch event, in range of 0 .. 1
     * Multiply it with the height if the Window to get the real y coordinate
     */
    float y;
    /**
     * The distance of the x coordinate (since the last event) in range of 0 .. 1
     */
    float dx;
    /**
     * The distance of the y coordinate (since the last event) in range of 0 .. 1
     */
    float dy;
    /**
     * The quantity of pressure applied in range of 0 .. 1
     */
    float pressure;
}

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

        JoystickAxisMotion = SDL_JOYAXISMOTION, /// A Joystick axis has moved
        JoystickButtonDown = SDL_JOYBUTTONDOWN, /// A Joystick button is pressed
        JoystickButtonUp = SDL_JOYBUTTONUP,  /// A Joystick button is released
        JoystickHatMotion = SDL_JOYHATMOTION, /// A Joystick hat has moved
        JoystickDeviceAdded = SDL_JOYDEVICEADDED, /// A Joystick was added
        JoystickDeviceRemoved = SDL_JOYDEVICEREMOVED, /// A Joystick was removed
        
        ControllerAxisMotion = SDL_CONTROLLERAXISMOTION, /// A GameController axis has moved
        ControllerButtonDown = SDL_CONTROLLERBUTTONDOWN, /// A GameController button is pressed
        ControllerButtonUp = SDL_CONTROLLERBUTTONUP,  /// A GameController button is released
        ControllerDeviceAdded = SDL_CONTROLLERDEVICEADDED, /// A GameController was added
        ControllerDeviceRemoved = SDL_CONTROLLERDEVICEREMOVED, /// A GameController was removed
        ControllerDeviceMapped = SDL_CONTROLLERDEVICEREMAPPED, /// A GameController was mapped

        FingerMotion = SDL_FINGERMOTION, /// A finger was moved onto the touch device
        FingerDown = SDL_FINGERDOWN, /// A finger is pressed onto the touch device
        FingerUp = SDL_FINGERUP, /// A finger is released of the touch device
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
    
    union {
        KeyboardEvent keyboard; /// Keyboard Event
        WindowEvent window; /// Window Event
        MouseUnion mouse; /// Mouse Events
        JoystickUnion joystick; /// Joystick Events
        ControllerUnion controller; /// Controller Events
        TouchFingerEvent fingerTouch; /// Finger-Touch Events
    }
}

package:

@nogc
bool _translate(Event* event, ref const SDL_Event sdl_event) nothrow {
    assert(event, "Event is null");

    switch (sdl_event.type) {
        case Event.Type.KeyDown:
        case Event.Type.KeyUp:
            event.type = cast(Event.Type) sdl_event.type;
            event.timestamp = sdl_event.key.timestamp;
            event.windowId = sdl_event.key.windowID;
            event.keyboard.isPressed = sdl_event.key.state == SDL_PRESSED;
            event.keyboard.key = cast(Keyboard.Key) sdl_event.key.keysym.sym;
            event.keyboard.isRepeat = sdl_event.key.repeat != 0;
            event.keyboard.mod = Keyboard.getModifier();

            return true;
        case Event.Type.Window:
            event.type = Event.Type.Window;
            event.windowId = sdl_event.window.windowID;
            event.timestamp = sdl_event.window.timestamp;
            
            switch (sdl_event.window.event) {
                case WindowEvent.Type.Moved:
                    event.window.motion.x = sdl_event.window.data1;
                    event.window.motion.y = sdl_event.window.data2;

                    break;
                case WindowEvent.Type.Resized:
                    event.window.size.width = sdl_event.window.data1;
                    event.window.size.height = sdl_event.window.data2;

                    break;
                default: break;
            }

            event.window.event = cast(WindowEvent.Type) sdl_event.window.event;
            
            return true;
        case Event.Type.Quit:
            event.type = Event.Type.Quit;
            
            return true;
        case Event.Type.MouseButtonDown:
        case Event.Type.MouseButtonUp:
            event.type = cast(Event.Type) sdl_event.type;
            event.timestamp = sdl_event.button.timestamp;
            event.windowId  = sdl_event.button.windowID;
            event.mouse.button.isPressed = sdl_event.button.state == SDL_PRESSED;
            event.mouse.button.button = cast(Mouse.Button) sdl_event.button.button;
            event.mouse.button.clicks = sdl_event.button.clicks;
            event.mouse.button.x = sdl_event.button.x;
            event.mouse.button.y = sdl_event.button.y;
            
            return true;
        case Event.Type.MouseMotion:
            event.type = Event.Type.MouseMotion;
            event.timestamp = sdl_event.motion.timestamp;
            event.windowId  = sdl_event.motion.windowID;
            event.mouse.motion.isPressed = sdl_event.motion.state == SDL_PRESSED;
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
                event.mouse.wheel.isFlipped = sdl_event.wheel.direction == SDL_MOUSEWHEEL_FLIPPED;
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
            event.type  = cast(Event.Type) sdl_event.type;
            event.timestamp = sdl_event.jbutton.timestamp;
            event.joystick.button.isPressed = sdl_event.jbutton.state == SDL_PRESSED;
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
            event.type = cast(Event.Type) sdl_event.type;
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
            event.type = cast(Event.Type) sdl_event.type;
            event.timestamp = sdl_event.cbutton.timestamp;
            event.controller.button.isPressed = sdl_event.cbutton.state == SDL_PRESSED;
            event.controller.button.which = sdl_event.cbutton.which;
            event.controller.button.button = cast(GameController.Button) sdl_event.cbutton.button;

            return true;
        case Event.Type.ControllerDeviceAdded:
        case Event.Type.ControllerDeviceRemoved:
        case Event.Type.ControllerDeviceMapped:
            event.timestamp = sdl_event.cdevice.timestamp;
            event.type = cast(Event.Type) sdl_event.cdevice.type;
            event.controller.device.which = sdl_event.cdevice.which;

            return true;
        case Event.Type.FingerMotion:
        case Event.Type.FingerDown:
        case Event.Type.FingerUp:
            event.timestamp = sdl_event.tfinger.timestamp;
            event.type = cast(Event.Type) sdl_event.tfinger.type;
            event.fingerTouch.touchId = sdl_event.tfinger.touchId;
            event.fingerTouch.fingerId = sdl_event.tfinger.fingerId;
            event.fingerTouch.x = sdl_event.tfinger.x;
            event.fingerTouch.y = sdl_event.tfinger.y;
            event.fingerTouch.dx = sdl_event.tfinger.dx;
            event.fingerTouch.dy = sdl_event.tfinger.dy;
            event.fingerTouch.pressure = sdl_event.tfinger.pressure;

            return true;
        default: break;
    }

    return false;
}