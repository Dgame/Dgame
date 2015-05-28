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
module Dgame.System.Mouse;

private:

import derelict.sdl2.types;
import derelict.sdl2.functions;

import Dgame.Graphic.Surface;
import Dgame.Math.Vector2;

public:

/**
 * Represent the Mouse
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
final abstract class Mouse {
public:
    /**
     * Supported mouse buttons
     */
    enum Button : ubyte {
        Left = 1, /// 
        Middle = 2, /// 
        Right = 3, /// 
        X1 = 4, /// 
        X2 = 5, /// 
        Other /// 
    }

    /**
     * Possible System cursors
     */
    enum SystemCursor {
        Arrow = SDL_SYSTEM_CURSOR_ARROW, /// 
        IBeam = SDL_SYSTEM_CURSOR_IBEAM, /// 
        Wait = SDL_SYSTEM_CURSOR_WAIT, /// 
        CrossHair = SDL_SYSTEM_CURSOR_CROSSHAIR, /// 
        WaitArrow = SDL_SYSTEM_CURSOR_WAITARROW, /// 
        SizeNWSE = SDL_SYSTEM_CURSOR_SIZENWSE, /// 
        SizeNESW = SDL_SYSTEM_CURSOR_SIZENESW, /// 
        SizeWE = SDL_SYSTEM_CURSOR_SIZEWE, /// 
        SizeNS = SDL_SYSTEM_CURSOR_SIZENS, /// 
        SizeAll = SDL_SYSTEM_CURSOR_SIZEALL, /// 
        None = SDL_SYSTEM_CURSOR_NO, /// 
        Hand = SDL_SYSTEM_CURSOR_HAND /// 
    }

    /**
     * The Cursor representation
     */
    alias Cursor = SDL_Cursor*;

    private static Cursor _cursor;

    @nogc
    static ~this() nothrow {
        if (_cursor)
            SDL_FreeCursor(_cursor);
    }
    
    /**
     * Returns if the given button is pressed.
     * 
     * See: Mouse.Button
     */
    @nogc
    static bool isPressed(Button btn) nothrow {
        return (SDL_GetMouseState(null, null) & SDL_BUTTON(btn)) != 0;
    }

    /**
     * Returns the current cursor position
     */
    @nogc
    static Vector2i getCursorPosition() nothrow {
        int x, y;
        SDL_GetMouseState(&x, &y);
        
        return Vector2i(x, y);
    }

    /**
     * Returns the relative cursor position.
     * x and y are set to the mouse deltas since the last call
     */
    @nogc
    static Vector2i getRelativeCursorPosition() nothrow {
        int x, y;
        SDL_GetRelativeMouseState(&x, &y);

        return Vector2i(x, y);
    }

static if (SDL_VERSION_ATLEAST(2, 0, 4)) {
    /**
     * Returns the global cursor position.
     * x and y will be reported relative to the top-left of the Desktop
     */
    @nogc
    static Vector2i getGlobalCursorPosition() nothrow {
        int x, y;
        SDL_GetGlobalMouseState(&x, &y);

        return Vector2i(x, y);
    }
}

    /**
     * Set the cursor position inside the window.
     *
     * Note: A call to this function generates a mouse motion event.
     */
    @nogc
    static void setCursorPosition(int x, int y) nothrow {
        SDL_Window* wnd = SDL_GetMouseFocus();
        if (wnd)
            SDL_WarpMouseInWindow(wnd, x, y);
    }

    /**
     * Set the cursor position inside the window.
     *
     * Note: A call to this function generates a mouse motion event.
     */
    @nogc
    static void setCursorPosition(const Vector2i pos) nothrow {
        Mouse.setCursorPosition(pos.x, pos.y);
    }

static if (SDL_VERSION_ATLEAST(2, 0, 4)) {
    /**
     * Set the cursor position in global screen space.
     *
     * Note: A call to this function generates a mouse motion event.
     */
    @nogc
    static void setGlobalCursorPosition(int x, int y) nothrow {
        SDL_WarpMouseGlobal(x, y);
    }

    /**
     * Set the cursor position in global screen space.
     *
     * Note: A call to this function generates a mouse motion event.
     */
    @nogc
    static void setGlobalCursorPosition(const Vector2i pos) nothrow {
        Mouse.setGlobalCursorPosition(pos.x, pos.y);
    }
}

    /**
     * Returns if the Relative mouse mode is enabled/supported.
     */
    @nogc
    static bool hasRelativeMouse() nothrow {
        return SDL_GetRelativeMouseMode() == SDL_TRUE;
    }
    
    /**
     * Tries to enable/disable the relative mouse mode.
     * While the mouse is in relative mode, the cursor is hidden,
     * and the driver will try to report continuous motion in the current Window.
     * Only relative motion events will be delivered, the mouse position will not change.
     */
    @nogc
    static bool enableRelativeMouse(bool enable) nothrow {
        return SDL_SetRelativeMouseMode(enable) == 0;
    }
    
    /**
     * Enable or disable that the cursor is shown on the window.
     */
    @nogc
    static void showCursor(bool enable) nothrow {
        SDL_ShowCursor(enable);
    }

static if (SDL_VERSION_ATLEAST(2, 0, 4)) {
    /**
     * Capture the mouse and track input outside of an Window.
     */
    @nogc
    static void captureCursor(bool enable) nothrow {
        SDL_CaptureMouse(enable);
    }
}

    /**
     * Create a Surface cursor.
     */
    @nogc
    static Cursor createCursor(ref Surface srfc, int hx, int hy) nothrow {
        Cursor my_cursor = srfc.setAsCursorAt(hx, hy);
        if (my_cursor && _cursor) {
            SDL_FreeCursor(_cursor);
            _cursor = my_cursor;
        }

        return _cursor;
    }

    /**
     * Create a system cursor.
     */
    @nogc
    static Cursor createCursor(SystemCursor cursor) nothrow {
        Cursor my_cursor = SDL_CreateSystemCursor(cursor);
        if (my_cursor && _cursor) {
            SDL_FreeCursor(_cursor);
            _cursor = my_cursor;
        }

        return _cursor;
    }

    /**
     * Set the active cursor.
     */
    @nogc
    static void setCursor(Cursor cursor) nothrow {
        SDL_SetCursor(cursor);
    }

    /**
     * Returns the active cursor.
     */
    @nogc
    static Cursor getCursor() nothrow {
        return SDL_GetCursor();
    }

    /**
     * Get the default cursor.
     */
    @nogc
    static Cursor getDefaultCursor() nothrow {
        return SDL_GetDefaultCursor();
    }
}