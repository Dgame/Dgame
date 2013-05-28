module Dgame.System.Mouse;

private {
	import derelict3.sdl2.types;
	import derelict3.sdl2.functions;
}

/**
 *
 */
final abstract class Mouse {
private:
	template getMouseMotionMask(int x) {
		enum getMouseMotionMask = 1 << (x - 1);
	}
	
public:
	/**
	 *
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
	 *
	 */
	enum State : ubyte {
		Released, /** */
		Pressed /** */
	}
	
	/**
	 *
	 */
	enum MotionStates : ubyte {
		LMask  = getMouseMotionMask!(Button.Left), /** */
		MMask  = getMouseMotionMask!(Button.Middle), /** */
		RMask  = getMouseMotionMask!(Button.Right), /** */
		X1Mask = getMouseMotionMask!(Button.X1), /** */
		X2Mask = getMouseMotionMask!(Button.X2) /** */
	}
	
	/**
	 *
	 */
	static SDL_Cursor* create(SDL_Surface* surface, short x, short y) {
		return SDL_CreateColorCursor(surface, x, y);
	}
	
	/**
	 *
	 */
	static SDL_Cursor* create(const ubyte* data, const ubyte* mask, ushort width, ushort height, short x, short y) {
		return SDL_CreateCursor(data, mask, width, height, x, y);
	}
	
	/**
	 *
	 */
	static void destroyCursor(SDL_Cursor* cursor) {
		SDL_FreeCursor(cursor);
	}
	
	/**
	 *
	 */
	static void setCursor(SDL_Cursor* cursor) {
		SDL_SetCursor(cursor);
	}
	
	/**
	 *
	 */
	static SDL_Cursor* getCursor() {
		return SDL_GetCursor();
	}
	
	/**
	 *
	 */
	static uint getState() {
		return SDL_GetMouseState(null, null);
	}
	
	/**
	 *
	 */
	static bool hasState(Button btn) {
		return (Mouse.getState() & SDL_BUTTON(btn)) > 0;
	}
	
	/**
	 *
	 */
	static void fetchCursorPosition(int* x, int* y) {
		SDL_GetMouseState(x, y);
	}
	
	/**
	 *
	 */
	static int[2] getCursorPosition() {
		int x, y;
		Mouse.fetchCursorPosition(&x, &y);
		
		return [x, y];
	}
	
	/**
	 *
	 */
	static void showCursor(bool enable) {
		SDL_ShowCursor(enable);
	}
	
	/**
	 *
	 */
	static void setCursorPosition(short x, short y) {
		SDL_Window* wnd = SDL_GetMouseFocus();
		if (wnd !is null)
			SDL_WarpMouseInWindow(wnd, x, y);
	}
	
	/**
	 *
	 */
	alias warp = setCursorPosition;
}