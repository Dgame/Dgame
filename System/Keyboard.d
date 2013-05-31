module Dgame.System.Keyboard;

private {
	debug import std.stdio;
	
	import derelict3.sdl2.functions;
	import derelict3.sdl2.types;
	
	import Dgame.Math.Rect;
}

/**
 * Represent the Keyboard
 */
final abstract class Keyboard {
private:
	static ubyte* _Keys;
	
public:
	/**
	 * Returns the pointer to the Keyboard state.
	 * With that you can check if some key is pressed without using a event queue.
	 * 
	 * Note: The state is probably not up to date. If you want the current state, 
	 * you should take a look at the update method.
	 *
	 * Examples:
	 * ---
	 * ubyte* keyStates = Keyboard.getState();
	 * if (keyStates[Keyboard.ScanCode.Escape])
	 *     writeln("escape is pressed.");
	 * ---
	 */
	static ubyte* getState() {
		return _Keys;
	}
	
	/**
	 * Update the current Keyboard state
	 * and returns a pointer to the current state.
	 */
	static ubyte* update() {
		_Keys = SDL_GetKeyboardState(null);
		
		return _Keys;
	}
	
	/**
	 * Use this function to start accepting Unicode text input events
	 */
	static void startTextInput() {
		SDL_StartTextInput();
	}
	
	/**
	 * Use this function to stop receiving any text input events.
	 */
	static void stopTextInput() {
		SDL_StopTextInput();
	}
	
	/**
	 * Use this function to set the rectangle used to type Unicode text inputs.
	 */
	static void setTextInputRect(ref ShortRect rect) {
		SDL_SetTextInputRect(rect.ptr);
	}
	
	/**
	 * Rvalue version
	 */
	static void setTextInputRect(ShortRect rect) {
		Keyboard.setTextInputRect(rect);
	}
	
	/**
	 * Returns if the given Keyboard.Code is pressed.
	 * If update is true, the keyboard state is updated before the check is executed.
	 *
	 * Examples:
	 * ---
	 * if (Keyboard.isPressed(Keyboard.Code.Escape))
	 *     writeln("escape is pressed.");
	 * ---
	 */
	static bool isPressed(Code code, bool update = false) {
		if (update)
			Keyboard.update();
		
		int scancode = SDL_GetScancodeFromKey(code);
		
		return _Keys[scancode] == 1;
	}
	
	/**
	 * Returns if the given Keyboard.ScanCode is pressed.
	 * If update is true, the keyboard state is updated before the check is executed.
	 *
	 * Examples:
	 * ---
	 * if (Keyboard.isPressed(Keyboard.ScanCode.Escape))
	 *     writeln("escape is pressed.");
	 * ---
	 */
	static bool isPressed(ScanCode scancode, bool update = false) {
		if (update)
			Keyboard.update();
		
		return _Keys[scancode] == 1;
	}
	
	/**
	 * Returns the current Keyboard modifier.
	 *
	 * See: Mod enum
	 */
	static Mod getModifier() {
		return cast(Mod) SDL_GetModState();
	}
	
	/**
	 * Set the current Keyboard modifier.
	 *
	 * See: Mod enum
	 */
	static void setModifier(Mod mod) {
		SDL_SetModState(mod);
	}
	
	/**
	 * Supported Keyboard States
	 */
	enum State {
		Pressed  = SDL_PRESSED, /** Key is pressed. */
		Released = SDL_RELEASED /** Key is released. */
	}
	
	/**
	 * All supported Keyboard modifiers.
	 */
	enum Mod {
		None 	= KMOD_NONE,	/** 0 (no modifier is applicable) */
		LShift 	= KMOD_LSHIFT,	/** the left Shift key is down */
		RShift 	= KMOD_RSHIFT,	/** the right Shift key is down */
		LCtrl 	= KMOD_LCTRL,	/** the left Ctrl (Control) key is down */
		RCtrl 	= KMOD_RCTRL,	/** the right Ctrl (Control) key is down */
		LAlt 	= KMOD_LALT,	/** the left Alt key is down */
		RAlt 	= KMOD_RALT,	/** the right Alt key is down */
		LGui 	= KMOD_LGUI,	/** the left GUI key (often the Windows key) is down */
		RGui 	= KMOD_RGUI,	/** the right GUI key (often the Windows key) is down */
		Num 	= KMOD_NUM,		/** the Num Lock key (may be located on an extended keypad) is down */
		Caps 	= KMOD_CAPS,	/** the Caps Lock key is down */
		Mode 	= KMOD_MODE,	/** the AltGr key is down */
		
		Ctrl 	= KMOD_CTRL, 	/** (Mod.LCtrl|Mod.RCtrl) */
		Shift 	= KMOD_SHIFT, 	/** (Mod.LShift|Mod.RShift) */
		Alt 	= KMOD_ALT, 	/** (Mod.LAlt|Mod.RAlt) */
		Gui 	= KMOD_GUI, 	/** (Mod.LGui|Mod.RGui) */
	}
	
	/**
	 * Supported Keyboard Codes.
	 * This are all possible keys.
	 */
	enum Code {
		Unknown = SDLK_UNKNOWN, /** */
		
		Return = SDLK_RETURN, /** */
		Escape = SDLK_ESCAPE, /** */
		Backspace = SDLK_BACKSPACE, /** */
		Tab = SDLK_TAB, /** */
		Space = SDLK_SPACE, /** */
		Exclaim = SDLK_EXCLAIM, /** */
		Quotedbl = SDLK_QUOTEDBL, /** */
		Hash = SDLK_HASH, /** */
		Percent = SDLK_PERCENT, /** */
		Dollar = SDLK_DOLLAR, /** */
		Ampersand = SDLK_AMPERSAND, /** */
		Quote = SDLK_QUOTE, /** */
		Leftparen = SDLK_LEFTPAREN, /** */
		Rightparen = SDLK_RIGHTPAREN, /** */
		Asterisk = SDLK_ASTERISK, /** */
		Plus = SDLK_PLUS, /** */
		Comma = SDLK_COMMA, /** */
		Minus = SDLK_MINUS, /** */
		Period = SDLK_PERIOD, /** */
		Slash = SDLK_SLASH, /** */
		
		Esc = Escape, /** Shortcut */
		
		Num0 = SDLK_0, /** */
		Num1 = SDLK_1, /** */
		Num2 = SDLK_2, /** */
		Num3 = SDLK_3, /** */
		Num4 = SDLK_4, /** */
		Num5 = SDLK_5, /** */
		Num6 = SDLK_6, /** */
		Num7 = SDLK_7, /** */
		Num8 = SDLK_8, /** */
		Num9 = SDLK_9, /** */
		
		Colon = SDLK_COLON, /** */
		Semicolon = SDLK_SEMICOLON, /** */
		Less = SDLK_LESS, /** */
		Equals = SDLK_EQUALS, /** */
		Greater = SDLK_GREATER, /** */
		Question = SDLK_QUESTION, /** */
		At = SDLK_AT, /** */
		
		Leftbracket = SDLK_LEFTBRACKET, /** */
		Backslash = SDLK_BACKSLASH, /** */
		Rightbracket = SDLK_RIGHTBRACKET, /** */
		Caret = SDLK_CARET, /** */
		Underscore = SDLK_UNDERSCORE, /** */
		Backquote = SDLK_BACKQUOTE, /** */
		
		A = SDLK_a, /** */
		B = SDLK_b, /** */
		C = SDLK_c, /** */
		D = SDLK_d, /** */
		E = SDLK_e, /** */
		F = SDLK_f, /** */
		G = SDLK_g, /** */
		H = SDLK_h, /** */
		I = SDLK_i, /** */
		J = SDLK_j, /** */
		K = SDLK_k, /** */
		L = SDLK_l, /** */
		M = SDLK_m, /** */
		N = SDLK_n, /** */
		O = SDLK_o, /** */
		P = SDLK_p, /** */
		Q = SDLK_q, /** */
		R = SDLK_r, /** */
		S = SDLK_s, /** */
		T = SDLK_t, /** */
		U = SDLK_u, /** */
		V = SDLK_v, /** */
		W = SDLK_w, /** */
		X = SDLK_x, /** */
		Y = SDLK_y, /** */
		Z = SDLK_z, /** */
		
		Capslock = SDLK_CAPSLOCK, /** */
		
		F1 = SDLK_F1, /** */
		F2 = SDLK_F2, /** */
		F3 = SDLK_F3, /** */
		F4 = SDLK_F4, /** */
		F5 = SDLK_F5, /** */
		F6 = SDLK_F6, /** */
		F7 = SDLK_F7, /** */
		F8 = SDLK_F8, /** */
		F9 = SDLK_F9, /** */
		F10 = SDLK_F10, /** */
		F11 = SDLK_F11, /** */
		F12 = SDLK_F12, /** */
		
		Printscreen = SDLK_PRINTSCREEN, /** */
		Scrolllock = SDLK_SCROLLLOCK, /** */
		Pause = SDLK_PAUSE, /** */
		Insert = SDLK_INSERT, /** */
		Home = SDLK_HOME, /** */
		PageUp = SDLK_PAGEUP, /** */
		Delete = SDLK_DELETE, /** */
		End = SDLK_END, /** */
		PageDown = SDLK_PAGEDOWN, /** */
		Right = SDLK_RIGHT, /** */
		Left = SDLK_LEFT, /** */
		Down = SDLK_DOWN, /** */
		Up = SDLK_UP, /** */
		
		NumLockClear = SDLK_NUMLOCKCLEAR, /** */
		KP_Divide = SDLK_KP_DIVIDE, /** */
		KP_Multiply = SDLK_KP_MULTIPLY, /** */
		KP_Minus = SDLK_KP_MINUS, /** */
		KP_Plus = SDLK_KP_PLUS, /** */
		KP_Enter = SDLK_KP_ENTER, /** */
		KP_1 = SDLK_KP_1, /** */
		KP_2 = SDLK_KP_2, /** */
		KP_3 = SDLK_KP_3, /** */
		KP_4 = SDLK_KP_4, /** */
		KP_5 = SDLK_KP_5, /** */
		KP_6 = SDLK_KP_6, /** */
		KP_7 = SDLK_KP_7, /** */
		KP_8 = SDLK_KP_8, /** */
		KP_9 = SDLK_KP_9, /** */
		KP_0 = SDLK_KP_0, /** */
		
		F13 = SDLK_F13, /** */
		F14 = SDLK_F14, /** */
		F15 = SDLK_F15, /** */
		F16 = SDLK_F16, /** */
		F17 = SDLK_F17, /** */
		F18 = SDLK_F18, /** */
		F19 = SDLK_F19, /** */
		F20 = SDLK_F20, /** */
		F21 = SDLK_F21, /** */
		F22 = SDLK_F22, /** */
		F23 = SDLK_F23, /** */
		F24 = SDLK_F24, /** */
		
		LCtrl = SDLK_LCTRL, /** */
		LShift = SDLK_LSHIFT, /** */
		LAlt = SDLK_LALT, /** */
		LGui = SDLK_LGUI, /** */
		RCtrl = SDLK_RCTRL, /** */
		RShift = SDLK_RSHIFT, /** */
		RAlt = SDLK_RALT, /** */
		RGui = SDLK_RGUI /** */
	}
	
	/**
	 * Supported Keyboard ScanCodes.
	 * This are all possible keys.
	 */
	enum ScanCode {
		Unknown = SDL_SCANCODE_UNKNOWN, /** */
		
		Return = SDL_SCANCODE_RETURN, /** */
		Escape = SDL_SCANCODE_ESCAPE, /** */
		Backspace = SDL_SCANCODE_BACKSPACE, /** */
		Tab = SDL_SCANCODE_TAB, /** */
		Space = SDL_SCANCODE_SPACE, /** */
		Comma = SDL_SCANCODE_COMMA, /** */
		Minus = SDL_SCANCODE_MINUS, /** */
		Period = SDL_SCANCODE_PERIOD, /** */
		Slash = SDL_SCANCODE_SLASH, /** */
		
		Esc = Escape, /** Shortcut */
		
		Num0 = SDL_SCANCODE_0, /** */
		Num1 = SDL_SCANCODE_1, /** */
		Num2 = SDL_SCANCODE_2, /** */
		Num3 = SDL_SCANCODE_3, /** */
		Num4 = SDL_SCANCODE_4, /** */
		Num5 = SDL_SCANCODE_5, /** */
		Num6 = SDL_SCANCODE_6, /** */
		Num7 = SDL_SCANCODE_7, /** */
		Num8 = SDL_SCANCODE_8, /** */
		Num9 = SDL_SCANCODE_9, /** */
		
		Semicolon = SDL_SCANCODE_SEMICOLON, /** */
		Equals = SDL_SCANCODE_EQUALS, /** */
		
		Leftbracket = SDL_SCANCODE_LEFTBRACKET, /** */
		Backslash = SDL_SCANCODE_BACKSLASH, /** */
		Rightbracket = SDL_SCANCODE_RIGHTBRACKET, /** */
		
		A = SDL_SCANCODE_A, /** */
		B = SDL_SCANCODE_B, /** */
		C = SDL_SCANCODE_C, /** */
		D = SDL_SCANCODE_D, /** */
		E = SDL_SCANCODE_E, /** */
		F = SDL_SCANCODE_F, /** */
		G = SDL_SCANCODE_G, /** */
		H = SDL_SCANCODE_H, /** */
		I = SDL_SCANCODE_I, /** */
		J = SDL_SCANCODE_J, /** */
		K = SDL_SCANCODE_K, /** */
		L = SDL_SCANCODE_L, /** */
		M = SDL_SCANCODE_M, /** */
		N = SDL_SCANCODE_N, /** */
		O = SDL_SCANCODE_O, /** */
		P = SDL_SCANCODE_P, /** */
		Q = SDL_SCANCODE_Q, /** */
		R = SDL_SCANCODE_R, /** */
		S = SDL_SCANCODE_S, /** */
		T = SDL_SCANCODE_T, /** */
		U = SDL_SCANCODE_U, /** */
		V = SDL_SCANCODE_V, /** */
		W = SDL_SCANCODE_W, /** */
		X = SDL_SCANCODE_X, /** */
		Y = SDL_SCANCODE_Y, /** */
		Z = SDL_SCANCODE_Z, /** */
		
		Capslock = SDL_SCANCODE_CAPSLOCK, /** */
		
		F1 = SDL_SCANCODE_F1, /** */
		F2 = SDL_SCANCODE_F2, /** */
		F3 = SDL_SCANCODE_F3, /** */
		F4 = SDL_SCANCODE_F4, /** */
		F5 = SDL_SCANCODE_F5, /** */
		F6 = SDL_SCANCODE_F6, /** */
		F7 = SDL_SCANCODE_F7, /** */
		F8 = SDL_SCANCODE_F8, /** */
		F9 = SDL_SCANCODE_F9, /** */
		F10 = SDL_SCANCODE_F10, /** */
		F11 = SDL_SCANCODE_F11, /** */
		F12 = SDL_SCANCODE_F12, /** */
		
		Printscreen = SDL_SCANCODE_PRINTSCREEN, /** */
		Scrolllock = SDL_SCANCODE_SCROLLLOCK, /** */
		Pause = SDL_SCANCODE_PAUSE, /** */
		Insert = SDL_SCANCODE_INSERT, /** */
		Home = SDL_SCANCODE_HOME, /** */
		PageUp = SDL_SCANCODE_PAGEUP, /** */
		Delete = SDL_SCANCODE_DELETE, /** */
		End = SDL_SCANCODE_END, /** */
		PageDown = SDL_SCANCODE_PAGEDOWN, /** */
		Right = SDL_SCANCODE_RIGHT, /** */
		Left = SDL_SCANCODE_LEFT, /** */
		Down = SDL_SCANCODE_DOWN, /** */
		Up = SDL_SCANCODE_UP, /** */
		
		NumLockClear = SDL_SCANCODE_NUMLOCKCLEAR, /** */
		KP_Divide = SDL_SCANCODE_KP_DIVIDE, /** */
		KP_Multiply = SDL_SCANCODE_KP_MULTIPLY, /** */
		KP_Minus = SDL_SCANCODE_KP_MINUS, /** */
		KP_Plus = SDL_SCANCODE_KP_PLUS, /** */
		KP_Enter = SDL_SCANCODE_KP_ENTER, /** */
		KP_1 = SDL_SCANCODE_KP_1, /** */
		KP_2 = SDL_SCANCODE_KP_2, /** */
		KP_3 = SDL_SCANCODE_KP_3, /** */
		KP_4 = SDL_SCANCODE_KP_4, /** */
		KP_5 = SDL_SCANCODE_KP_5, /** */
		KP_6 = SDL_SCANCODE_KP_6, /** */
		KP_7 = SDL_SCANCODE_KP_7, /** */
		KP_8 = SDL_SCANCODE_KP_8, /** */
		KP_9 = SDL_SCANCODE_KP_9, /** */
		KP_0 = SDL_SCANCODE_KP_0, /** */
		
		F13 = SDL_SCANCODE_F13, /** */
		F14 = SDL_SCANCODE_F14, /** */
		F15 = SDL_SCANCODE_F15, /** */
		F16 = SDL_SCANCODE_F16, /** */
		F17 = SDL_SCANCODE_F17, /** */
		F18 = SDL_SCANCODE_F18, /** */
		F19 = SDL_SCANCODE_F19, /** */
		F20 = SDL_SCANCODE_F20, /** */
		F21 = SDL_SCANCODE_F21, /** */
		F22 = SDL_SCANCODE_F22, /** */
		F23 = SDL_SCANCODE_F23, /** */
		F24 = SDL_SCANCODE_F24, /** */
		
		LCtrl = SDL_SCANCODE_LCTRL, /** */
		LShift = SDL_SCANCODE_LSHIFT, /** */
		LAlt = SDL_SCANCODE_LALT, /** */
		LGui = SDL_SCANCODE_LGUI, /** */
		RCtrl = SDL_SCANCODE_RCTRL, /** */
		RShift = SDL_SCANCODE_RSHIFT, /** */
		RAlt = SDL_SCANCODE_RALT, /** */
		RGui = SDL_SCANCODE_RGUI /** */
	}
}