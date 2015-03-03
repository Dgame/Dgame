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

public import Dgame.System.Mouse;
public import Dgame.System.Keyboard;

public:

/**
 * The Keyboard Event structure.
 */
struct KeyboardEvent {
    Keyboard.State state;   /** Keyboard State. See: Dgame.Input.Keyboard. */
    Keyboard.Code code; /** The Key which is released or pressed. */
    Keyboard.ScanCode scancode; /** The Key which is released or pressed. */
    Keyboard.Mod mod;   /** The Key modifier. */
    
    alias key = code; /** An alias */
    
    bool repeat;    /** true, if this is a key repeat. */
}

/**
 * Specific Window Events.
 */
enum WindowEventId : ubyte {
    None,           /** Nothing happens */
    Shown,          /** Window has been shown */
    Hidden,         /** Window has been hidden */
    Exposed,        /** Window has been exposed and should be redrawn */
    Moved,          /** Window has been moved to data1, data2  */
    Resized,        /** Window has been resized to data1Xdata2 */
    SizeChanged,    /** The window size has changed, 
                     * either as a result of an API call or through 
                     * the system or user changing the window size. */
    Minimized,      /** Window has been minimized. */
    Maximized,      /** Window has been maximized. */
    Restored,       /** Window has been restored to normal size and position. */
    Enter,          /** Window has gained mouse focus. */
    Leave,          /** Window has lost mouse focus. */
    FocusGained,    /** Window has gained keyboard focus. */
    FocusLost,      /** Window has lost keyboard focus. */
    Close           /** The window manager requests that the window be closed. */
}

/**
 * The Window Event structure.
 */
struct WindowEvent {
    WindowEventId eventId; /** < The Window Event id. */
}

/**
 * The Mouse button Event structure.
 */
struct MouseButtonEvent {
    Mouse.Button button; /** The mouse button which is pressed or released. */
    
    int x; /** Current x position. */
    int y; /** Current y position. */
}

/**
 * The Mouse motion Event structure.
 */
struct MouseMotionEvent {
    Mouse.State state; /** Mouse State. See: Dgame.Input.Mouse. */
    
    int x; /** Current x position. */
    int y; /** Current y position. */
    
    int rel_x; /** Relative motion in the x direction. */
    int rel_y; /** Relative motion in the y direction. */
}

/**
 * The Mouse wheel Event structure.
 */
struct MouseWheelEvent {
    int x; /** Current x position. */
    int y; /** Current y position. */
    
    int delta_x; /** The amount scrolled horizontally. */
    int delta_y; /** The amount scrolled vertically. */
}

/**
 * The Event structure.
 * Event defines a system event and it's parameters
 *
 * Author: rschuett
 */
struct Event {
    /**
     * All supported Event Types.
     */
    enum Type {
        Quit = SDL_QUIT,            /** Quit Event. Time to close the window. */
        Window  = SDL_WINDOWEVENT,  /** Something happens with the window. */
        KeyDown = SDL_KEYDOWN,      /** A key is pressed. */
        KeyUp = SDL_KEYUP,      /** A key is released. */
        MouseMotion = SDL_MOUSEMOTION,  /** The mouse has moved. */
        MouseButtonDown = SDL_MOUSEBUTTONDOWN,  /** A mouse button is pressed. */
        MouseButtonUp = SDL_MOUSEBUTTONUP,  /** A mouse button is released. */
        MouseWheel = SDL_MOUSEWHEEL,        /** The mouse wheel has scolled. */
        //TextEdit   = SDL_TEXTEDITING,            /**< Keyboard text editing (composition) */
        //TextInput  = SDL_TEXTINPUT              /**< Keyboard text input */
    }

    Type type; /// The type of the Event

    uint timestamp; /** Milliseconds since the app is running */
    uint windowId;  /** The window which has raised this event */

    /**
     * Mouse union
     */
    union MouseUnion {
        MouseButtonEvent button; /** Mouse button Event */
        MouseMotionEvent motion; /** Mouse motion Event */
        MouseWheelEvent  wheel;  /** Mouse wheel Event */
    }
    
    union {
        KeyboardEvent keyboard; /** Keyboard Event */
        WindowEvent   window;   /** Window Event */
        
        MouseUnion mouse; /** Mouse Events */
    }
}

package:

@nogc
bool _translate(Event* event, ref const SDL_Event sdl_event) nothrow {
    assert(event);

    switch (sdl_event.type) {
        case Event.Type.KeyDown:
        case Event.Type.KeyUp:
            event.type = sdl_event.type == Event.Type.KeyDown ? Event.Type.KeyDown : Event.Type.KeyUp;
            
            event.timestamp = sdl_event.key.timestamp;
            event.windowId = sdl_event.key.windowID;
            
            event.keyboard.code = cast(Keyboard.Code) sdl_event.key.keysym.sym;
            event.keyboard.scancode = cast(Keyboard.ScanCode) sdl_event.key.keysym.scancode;
            
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
            
            event.mouse.button.button = cast(Mouse.Button) sdl_event.button.button;
            
            event.mouse.button.x = sdl_event.button.x;
            event.mouse.button.y = sdl_event.button.y;
            
            return true;
        case Event.Type.MouseMotion:
            event.type = Event.Type.MouseMotion;
            
            event.timestamp = sdl_event.motion.timestamp;
            event.windowId  = sdl_event.motion.windowID;
            
            if (sdl_event.button.state == SDL_PRESSED)
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
            
            event.mouse.wheel.delta_x = sdl_event.wheel.x;
            event.mouse.wheel.delta_y = sdl_event.wheel.y;
            
            return true;
        /+
        case Event.Type.TextEdit:
            event.type = Event.Type.TextEdit;
            
            event.timestamp = sdl_event.edit.timestamp;
            event.windowId  = sdl_event.edit.windowID;
            
            event.textEdit.text = sdl_event.edit.text;
            event.textEdit.start = sdl_event.edit.start;
            event.textEdit.length = sdl_event.edit.length;
            
            return true;
        case Event.Type.TextInput:
            event.type = Event.Type.TextInput;
            
            event.timestamp = sdl_event.text.timestamp;
            event.windowId  = sdl_event.text.windowID;
            
            event.textInput.text = sdl_event.text.text;
            
            return true;
        +/
        default:
            return false;
    }
}