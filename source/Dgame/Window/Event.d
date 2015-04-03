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
     * Keyboard State. See: Dgame.Input.Keyboard.
     */
    Keyboard.State state;
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
     * Mouse State. See: Dgame.Input.Mouse.
     */
    Mouse.State state;
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
     * Mouse State. See: Dgame.Input.Mouse.
     */
    Mouse.State state;
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
    
    union {
        KeyboardEvent keyboard; /// Keyboard Event
        WindowEvent window; /// Window Event
        MouseUnion mouse; /// Mouse Events
    }
}

package:

@nogc
bool _translate(Event* event, ref const SDL_Event sdl_event) nothrow {
    assert(event, "Event is null");

    switch (sdl_event.type) {
        case Event.Type.KeyDown:
        case Event.Type.KeyUp:
            event.type = sdl_event.type == Event.Type.KeyDown ? Event.Type.KeyDown : Event.Type.KeyUp;
            
            event.timestamp = sdl_event.key.timestamp;
            event.windowId = sdl_event.key.windowID;
            
            event.keyboard.code = cast(Keyboard.Code) sdl_event.key.keysym.sym;
            
            event.keyboard.repeat = sdl_event.key.repeat != 0;
            event.keyboard.state = cast(Keyboard.State) sdl_event.key.state;
            
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
            
            event.timestamp = sdl_event.button.timestamp;
            event.windowId  = sdl_event.button.windowID;

            if (sdl_event.button.state == SDL_PRESSED)
                event.mouse.button.state = Mouse.State.Pressed;
            else
                event.mouse.button.state = Mouse.State.Released;
            
            event.mouse.button.button = cast(Mouse.Button) sdl_event.button.button;
            event.mouse.button.clicks = sdl_event.button.clicks;
            
            event.mouse.button.x = sdl_event.button.x;
            event.mouse.button.y = sdl_event.button.y;
            
            return true;
        case Event.Type.MouseMotion:
            event.type = Event.Type.MouseMotion;
            
            event.timestamp = sdl_event.motion.timestamp;
            event.windowId  = sdl_event.motion.windowID;
            
            if (sdl_event.motion.state == SDL_PRESSED)
                event.mouse.motion.state = Mouse.State.Pressed;
            else
                event.mouse.motion.state = Mouse.State.Released;
            
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
        default:
            return false;
    }
}