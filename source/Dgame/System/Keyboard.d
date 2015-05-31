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
module Dgame.System.Keyboard;

private:

import derelict.sdl2.types;
import derelict.sdl2.functions;

public:

/**
 * Represent the Keyboard
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
interface Keyboard {
    /**
     * Returns if the given Keyboard.Code is pressed.
     * 
     * Examples:
     * ---
     * if (Keyboard.isPressed(Keyboard.Code.Escape))
     *     writeln("escape is pressed.");
     * ---
     */
    @nogc
    static bool isPressed(Code code) nothrow {
        immutable int scancode = SDL_GetScancodeFromKey(code);
        const ubyte* keys = SDL_GetKeyboardState(null);

        return keys[scancode] == 1;
    }
    
    /**
     * Returns the current Keyboard modifier.
     *
     * See: Mod enum
     */
    @nogc
    static Mod getModifier() nothrow {
        return cast(Mod) SDL_GetModState();
    }
    
    /**
     * Set the current Keyboard modifier.
     *
     * See: Mod enum
     */
    @nogc
    static void setModifier(Mod mod) nothrow {
        SDL_SetModState(mod);
    }
    
    /**
     * Returns if screen keyboard is supported.
     */
    @nogc
    static bool hasScreenSupport() nothrow {
        return SDL_HasScreenKeyboardSupport() == SDL_TRUE;
    }
    
    /**
     * All supported Keyboard modifiers.
     */
    enum Mod {
        None    = KMOD_NONE,    /// 0 (no modifier is applicable)
        LShift  = KMOD_LSHIFT,  /// the left Shift key is down
        RShift  = KMOD_RSHIFT,  /// the right Shift key is down
        LCtrl   = KMOD_LCTRL,   /// the left Ctrl (Control) key is down
        RCtrl   = KMOD_RCTRL,   /// the right Ctrl (Control) key is down
        LAlt    = KMOD_LALT,    /// the left Alt key is down
        RAlt    = KMOD_RALT,    /// the right Alt key is down
        LGui    = KMOD_LGUI,    /// the left GUI key (often the Windows key) is down
        RGui    = KMOD_RGUI,    /// the right GUI key (often the Windows key) is down
        Num     = KMOD_NUM,     /// the Num Lock key (may be located on an extended keypad) is down
        Caps    = KMOD_CAPS,    /// the Caps Lock key is down
        Mode    = KMOD_MODE,    /// the AltGr key is down
        
        Ctrl    = KMOD_CTRL,    /// (Mod.LCtrl|Mod.RCtrl)
        Shift   = KMOD_SHIFT,   /// (Mod.LShift|Mod.RShift)
        Alt     = KMOD_ALT,     /// (Mod.LAlt|Mod.RAlt)
        Gui     = KMOD_GUI,     /// (Mod.LGui|Mod.RGui)
    }

    /**
     * An alias
     */
    deprecated("Use 'Key' instead")
    alias Code = Key;
    
    /**
     * Supported Keyboard Codes.
     * These are all possible/supported keys.
     */
    enum Key {
        Unknown = SDLK_UNKNOWN, /// 
        
        Return = SDLK_RETURN, /// 
        Escape = SDLK_ESCAPE, /// 
        Backspace = SDLK_BACKSPACE, /// 
        Tab = SDLK_TAB, /// 
        Space = SDLK_SPACE, /// 
        Exclaim = SDLK_EXCLAIM, /// 
        Quotedbl = SDLK_QUOTEDBL, /// 
        Hash = SDLK_HASH, /// 
        Percent = SDLK_PERCENT, /// 
        Dollar = SDLK_DOLLAR, /// 
        Ampersand = SDLK_AMPERSAND, /// 
        Quote = SDLK_QUOTE, /// 
        Leftparen = SDLK_LEFTPAREN, /// 
        Rightparen = SDLK_RIGHTPAREN, /// 
        Asterisk = SDLK_ASTERISK, /// 
        Plus = SDLK_PLUS, /// 
        Comma = SDLK_COMMA, /// 
        Minus = SDLK_MINUS, /// 
        Period = SDLK_PERIOD, /// 
        Slash = SDLK_SLASH, /// 
        
        Dot = Period, /** Shortcut */
        Esc = Escape, /** Shortcut */
        
        Num0 = SDLK_0, /// 
        Num1 = SDLK_1, /// 
        Num2 = SDLK_2, /// 
        Num3 = SDLK_3, /// 
        Num4 = SDLK_4, /// 
        Num5 = SDLK_5, /// 
        Num6 = SDLK_6, /// 
        Num7 = SDLK_7, /// 
        Num8 = SDLK_8, /// 
        Num9 = SDLK_9, /// 
        
        Colon = SDLK_COLON, /// 
        Semicolon = SDLK_SEMICOLON, /// 
        Less = SDLK_LESS, /// 
        Equals = SDLK_EQUALS, /// 
        Greater = SDLK_GREATER, /// 
        Question = SDLK_QUESTION, /// 
        At = SDLK_AT, /// 
        
        Leftbracket = SDLK_LEFTBRACKET, /// 
        Backslash = SDLK_BACKSLASH, /// 
        Rightbracket = SDLK_RIGHTBRACKET, /// 
        Caret = SDLK_CARET, /// 
        Underscore = SDLK_UNDERSCORE, /// 
        Backquote = SDLK_BACKQUOTE, /// 
        
        A = SDLK_a, /// 
        B = SDLK_b, /// 
        C = SDLK_c, /// 
        D = SDLK_d, /// 
        E = SDLK_e, /// 
        F = SDLK_f, /// 
        G = SDLK_g, /// 
        H = SDLK_h, /// 
        I = SDLK_i, /// 
        J = SDLK_j, /// 
        K = SDLK_k, /// 
        L = SDLK_l, /// 
        M = SDLK_m, /// 
        N = SDLK_n, /// 
        O = SDLK_o, /// 
        P = SDLK_p, /// 
        Q = SDLK_q, /// 
        R = SDLK_r, /// 
        S = SDLK_s, /// 
        T = SDLK_t, /// 
        U = SDLK_u, /// 
        V = SDLK_v, /// 
        W = SDLK_w, /// 
        X = SDLK_x, /// 
        Y = SDLK_y, /// 
        Z = SDLK_z, /// 
        
        Capslock = SDLK_CAPSLOCK, /// 
        
        F1 = SDLK_F1, /// 
        F2 = SDLK_F2, /// 
        F3 = SDLK_F3, /// 
        F4 = SDLK_F4, /// 
        F5 = SDLK_F5, /// 
        F6 = SDLK_F6, /// 
        F7 = SDLK_F7, /// 
        F8 = SDLK_F8, /// 
        F9 = SDLK_F9, /// 
        F10 = SDLK_F10, /// 
        F11 = SDLK_F11, /// 
        F12 = SDLK_F12, /// 
        
        Printscreen = SDLK_PRINTSCREEN, /// 
        Scrolllock = SDLK_SCROLLLOCK, /// 
        Pause = SDLK_PAUSE, /// 
        Insert = SDLK_INSERT, /// 
        Home = SDLK_HOME, /// 
        PageUp = SDLK_PAGEUP, /// 
        Delete = SDLK_DELETE, /// 
        End = SDLK_END, /// 
        PageDown = SDLK_PAGEDOWN, /// 
        Right = SDLK_RIGHT, /// 
        Left = SDLK_LEFT, /// 
        Down = SDLK_DOWN, /// 
        Up = SDLK_UP, /// 
        
        NumLockClear = SDLK_NUMLOCKCLEAR, /// 
        KP_Divide = SDLK_KP_DIVIDE, /// 
        KP_Multiply = SDLK_KP_MULTIPLY, /// 
        KP_Minus = SDLK_KP_MINUS, /// 
        KP_Plus = SDLK_KP_PLUS, /// 
        KP_Enter = SDLK_KP_ENTER, /// 
        KP_1 = SDLK_KP_1, /// 
        KP_2 = SDLK_KP_2, /// 
        KP_3 = SDLK_KP_3, /// 
        KP_4 = SDLK_KP_4, /// 
        KP_5 = SDLK_KP_5, /// 
        KP_6 = SDLK_KP_6, /// 
        KP_7 = SDLK_KP_7, /// 
        KP_8 = SDLK_KP_8, /// 
        KP_9 = SDLK_KP_9, /// 
        KP_0 = SDLK_KP_0, /// 
        
        F13 = SDLK_F13, /// 
        F14 = SDLK_F14, /// 
        F15 = SDLK_F15, /// 
        F16 = SDLK_F16, /// 
        F17 = SDLK_F17, /// 
        F18 = SDLK_F18, /// 
        F19 = SDLK_F19, /// 
        F20 = SDLK_F20, /// 
        F21 = SDLK_F21, /// 
        F22 = SDLK_F22, /// 
        F23 = SDLK_F23, /// 
        F24 = SDLK_F24, /// 
        
        LCtrl = SDLK_LCTRL, /// 
        LShift = SDLK_LSHIFT, /// 
        LAlt = SDLK_LALT, /// 
        LGui = SDLK_LGUI, /// 
        RCtrl = SDLK_RCTRL, /// 
        RShift = SDLK_RSHIFT, /// 
        RAlt = SDLK_RALT, /// 
        RGui = SDLK_RGUI /// 
    }
}