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

private {
	import derelict.sdl2.types;
	import derelict.sdl2.functions;
	
	import Dgame.Graphics.Surface;
}

/**
 * Represent the Mouse
 */
final abstract class Mouse {
public:
	/**
	 * Shorthand for SDL_Cursor*
	 */
	alias Cursor = SDL_Cursor*;
	
	/**
	 * Supported mouse buttons
	 */
	enum Button : ubyte {
		Left	= 1, /** */
		Middle 	= 2, /** */
		Right 	= 3, /** */
		X1 		= 4, /** */
		X2 		= 5, /** */
		Other /** */
	}
	
	/**
	 * Supported mouse states
	 */
	enum State : ubyte {
		Released, /** */
		Pressed /** */
	}
	
	/**
	 * Supported mouse motion states
	 */
	enum MotionStates : ubyte {
		LMask  = 0x1, /** */
		MMask  = 0x2, /** */
		RMask  = 0x4, /** */
		X1Mask = 0x8, /** */
		X2Mask = 0x10 /** */
	}
	
	/**
	 * Creates a cursor at the given positions with the given Surface.
	 */
	static Cursor create(ref Surface srfc, short x, short y) {
		return SDL_CreateColorCursor(srfc.ptr, x, y);
	}
	
	/**
	 * Creates a cursor from pixel data.
	 * 
	 * See: http://wiki.libsdl.org/moin.fcg/SDL_CreateCursor
	 */
	static Cursor create(const ubyte* data, const ubyte* mask,
	                     ushort width, ushort height, short x, short y)
	{
		return SDL_CreateCursor(data, mask, width, height, x, y);
	}
	
	/**
	 * Destroys the given cursor.
	 */
	static void destroyCursor(Cursor cursor) {
		SDL_FreeCursor(cursor);
	}
	
	/**
	 * Set a new cursor.
	 */
	static void setCursor(Cursor cursor) {
		SDL_SetCursor(cursor);
	}
	
	/**
	 * Returns the current cursor.
	 */
	static Cursor getCursor() {
		return SDL_GetCursor();
	}
	
	/**
	 * Returns the mouse state and (if y and y aren't null) the current position.
	 * 
	 * See: Mouse.State enum
	 */
	static uint getState(int* x = null, int* y = null) {
		return SDL_GetMouseState(x, y);
	}
	
	/**
	 * Returns the relative mouse state and (if y and y aren't null) the relative position.
	 * This means the difference of the positions since the last call of this method.
	 * 
	 * See: Mouse.RelativeState enum
	 */
	static uint getRelativeState(int* x = null, int* y = null) {
		return SDL_GetRelativeMouseState(x, y);
	}
	
	/**
	 * Returns if the given button is pressed.
	 * 
	 * See: Mouse.Button
	 */
	static bool hasState(Button btn) {
		return (Mouse.getState() & SDL_BUTTON(btn)) != 0;
	}
	
	/**
	 * 
	 */
	static bool hasRelativeState(Button btn) {
		return (Mouse.getState() & SDL_BUTTON(btn)) != 0;
	}
	
	/**
	 * Returns the cursor position as static array.
	 */
	static int[2] getCursorPosition() {
		int x, y;
		Mouse.getState(&x, &y);
		
		return [x, y];
	}
	
	/**
	 * Enable or disable that the cursor is shown on the window.
	 */
	static void showCursor(bool enable) {
		SDL_ShowCursor(enable);
	}
	
	/**
	 * Set the cursor position inside the window.
	 */
	static void setCursorPosition(short x, short y) {
		SDL_Window* wnd = SDL_GetMouseFocus();
		
		if (wnd !is null)
			SDL_WarpMouseInWindow(wnd, x, y);
	}
	
	/**
	 * Alias for setting cursor position
	 */
	alias warp = setCursorPosition;
	
	/**
	 * Returns if the Relative mouse mode is enabled/supported.
	 */
	static bool hasRelativeMouse() {
		return SDL_GetRelativeMouseMode() == SDL_TRUE;
	}
	
	/**
	 * Tries to enable/disable the relative mouse mode.
	 */
	static bool enableRelativeMouse(bool enable) {
		return SDL_SetRelativeMouseMode(enable) == 0;
	}
}