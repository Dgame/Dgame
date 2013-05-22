module Dgame.Window.Event;

private import derelict3.sdl2.types;

public {
	import Dgame.System.Keyboard;
	import Dgame.System.Mouse;
}

/**
 * Specific Window Events.
 */
enum WindowEventId {
	None,           /** Never used */
	Shown,          /** Window has been shown */
	Hidden,         /** Window has been hidden */
	Exposed,        /** Window has been exposed and should be redrawn */
	Moved,          /** Window has been moved to data1, data2  */
	Resized,        /** Window has been resized to data1xdata2 */
	SizeChanged,    /** The window size has changed, 
	                 either as a result of an API call or through 
	                 the system or user changing the window size. */
	Minimized,      /** Window has been minimized. */
	Maximized,      /** Window has been maximized. */
	Restored,       /** Window has been restored to normal size and position. */
	Enter,          /** Window has gained mouse focus. */
	Leave,          /** Window has lost mouse focus. */
	FocusGained,    /** Window has gained keyboard focus. */
	FocusLost,      /** Window has lost keyboard focus. */
	Close           /** The window manager requests that the window be closed. */
}

enum TextSize = 32;

/**
 * The Event structure.
 * Event defines a system event and it's parameters
 *
 * Author: rschuett
 */
struct Event {
public:
	/**
	 * All supported Event Types.
	 */
	enum Type {
		Quit		= SDL_QUIT,			/** Quit Event. Time to close the window. */
		Window		= SDL_WINDOWEVENT,	/** Something happens with the window. */
		KeyDown		= SDL_KEYDOWN,		/** A key is pressed. */
		KeyUp		= SDL_KEYUP,		/** A key is released. */
		MouseMotion = SDL_MOUSEMOTION,	/** The mouse has moved. */
		MouseButtonDown = SDL_MOUSEBUTTONDOWN,	/** A mouse button is pressed. */
		MouseButtonUp = SDL_MOUSEBUTTONUP,	/** A mouse button is released. */
		MouseWheel	  = SDL_MOUSEWHEEL,		/** The mouse wheel has scolled. */
		TextEdit	  = SDL_TEXTEDITING,            /**< Keyboard text editing (composition) */
		TextInput	  = SDL_TEXTINPUT              /**< Keyboard text input */
	}
	
public:
	Type type; /** The Event Type. */
	
	size_t timestamp; /** Milliseconds since the app is running. */
	uint windowId;   /** The window which has raised this event. */
	
	/**
	 * The Keyboard Event structure.
	 */
	struct KeyboardEvent {
		Keyboard.State	state;	/** Keyboard State. See: Dgame.Input.Keyboard. */
		Keyboard.Code	key;	/** The Key which is released or pressed. */
		Keyboard.Mod	mod;	/** The Key modifier. */
		
		bool repeat;	/** true, if this is a key repeat. */
		
		version(none) {
			bool capslock;	/** true, if capslock is pressed. */
			bool control;	/** true, if control/cmd is pressed. */
			bool shift;		/** true, if shift is pressed. */
			bool alt;		/** true, if alt is pressed. */
		}
	}
	
	/**
	 * Keyboard text editing event structure
	 */
	struct TextEditEvent {
		char[TextSize] text;    /**< The editing text */
		short start;            /**< The start cursor of selected editing text */
		ushort length;          /**< The length of selected editing text */
	}
	
	/**
	 * Keyboard text input event structure
	 */
	struct TextInputEvent {
		char[TextSize] text;	/**< The input text */
	}
	
	/**
	 * The Window Event structure.
	 */
	struct WindowEvent {
		WindowEventId eventId;
	}
	
	/**
	 * The Mouse button Event structure.
	 */
	struct MouseButtonEvent {
		Mouse.Button button; /** The mouse button which is pressed or released. */
		
		short x; /** Current x position. */
		short y; /** Current y position. */
	}
	
	/**
	 * The Mouse motion Event structure.
	 */
	struct MouseMotionEvent {
		Mouse.State state; /** Mouse State. See: Dgame.Input.Mouse. */
		
		short x; /** Current x position. */
		short y; /** Current y position. */
		
		short rel_x; /** Relative motion in the x direction. */
		short rel_y; /** Relative motion in the y direction. */
	}
	
	/**
	 * The Mouse wheel Event structure.
	 */
	struct MouseWheelEvent {
		short x; /** Current x position. */
		short y; /** Current y position. */
		
		short delta_x; /** The amount scrolled horizontally. */
		short delta_y; /** The amount scrolled vertically. */
	}
	
	union {
		KeyboardEvent keyboard; /** Keyboard Event. */
		WindowEvent	  window;	/** Window Event. */
		MouseButtonEvent mouseButton; /** Mouse button Event. */
		MouseMotionEvent mouseMotion; /** Mouse motion Event. */
		MouseWheelEvent  mouseWheel;  /** Mouse wheel Event. */
		TextEditEvent	 textEdit;	  /** Text edit Event. */
		TextInputEvent	 textInput;	  /** Text input Event. */
	}
}