module Dgame.Window.EventHandler;

private {
	debug import std.stdio;
	
	import derelict3.sdl2.types;
	import derelict3.sdl2.functions;
}

public import Dgame.Window.Event;

/**
 * These class handles incomming events and returns outcomming events.
 *
 * Author: rschuett
 */
final abstract class EventHandler {
public:
	enum State {
		Query   = SDL_QUERY,
		Ignore  = SDL_IGNORE,
		Disable = SDL_DISABLE,
		Enable  = SDL_ENABLE
	}
	
private:
	static bool _process(Event* event, ref const SDL_Event sdl_event) {
		if (event is null)
			throw new Exception("Null Event");
		
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
				
				version(none) {
					event.keyboard.capslock = (sdl_event.key.keysym.mod & KMOD_CAPS) != 0;
					event.keyboard.control  = (sdl_event.key.keysym.mod & KMOD_CTRL) != 0;
					event.keyboard.shift    = (sdl_event.key.keysym.mod & KMOD_SHIFT) != 0;
					event.keyboard.alt      = (sdl_event.key.keysym.mod & KMOD_ALT) != 0;
				}
				
				version(none)
					event.keyboard.mod = cast(Keyboard.Mod) sdl_event.key.keysym.mod;
				else
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
				
				event.mouseButton.button = cast(Mouse.Button) sdl_event.button.button;
				
				event.mouseButton.x = cast(short) sdl_event.button.x;
				event.mouseButton.y = cast(short) sdl_event.button.y;
				return true;
			case Event.Type.MouseMotion:
				event.type = Event.Type.MouseMotion;
				
				event.timestamp = sdl_event.motion.timestamp;
				event.windowId  = sdl_event.motion.windowID;
				
				if (sdl_event.button.state == SDL_PRESSED)
					event.mouseMotion.state = Mouse.State.Pressed;
				else
					event.mouseMotion.state = Mouse.State.Released;
				
				event.mouseMotion.x = cast(short) sdl_event.motion.x;
				event.mouseMotion.y = cast(short) sdl_event.motion.y;
				
				event.mouseMotion.rel_x = cast(short) sdl_event.motion.xrel;
				event.mouseMotion.rel_y = cast(short) sdl_event.motion.yrel;
				return true;
			case Event.Type.MouseWheel:
				event.type = Event.Type.MouseWheel;
				
				event.timestamp = sdl_event.wheel.timestamp;
				event.windowId  = sdl_event.wheel.windowID;
				
				event.mouseWheel.x = cast(short) sdl_event.wheel.x;
				event.mouseWheel.y = cast(short) sdl_event.wheel.y;
				
				event.mouseWheel.delta_x = cast(short) sdl_event.wheel.x;
				event.mouseWheel.delta_y = cast(short) sdl_event.wheel.y;
				return true;
			case Event.Type.TextEdit:
				event.type = Event.Type.TextEdit;
				
				event.timestamp = sdl_event.edit.timestamp;
				event.windowId  = sdl_event.edit.windowID;
				
				event.textEdit.text = sdl_event.edit.text;
				event.textEdit.start = cast(short) sdl_event.edit.start;
				event.textEdit.length = cast(ushort) sdl_event.edit.length;
				return true;
			case Event.Type.TextInput:
				event.type = Event.Type.TextInput;
				
				event.timestamp = sdl_event.text.timestamp;
				event.windowId  = sdl_event.text.windowID;
				
				event.textInput.text = sdl_event.text.text;
				return true;
			default: return false;
		}
	}
	
public:
	/**
	 * Update the parameter event and set the data of the current event in it.
	 * 
	 * Returns: true, if there was a valid event and false if not.
	 */
	static bool poll(Event* event) {
		SDL_Event sdl_event;
		SDL_PollEvent(&sdl_event);
		
		return EventHandler._process(event, sdl_event);
	}
	
	/**
	 * Push an event of the given type inside the Event queue.
	 * 
	 * Returns: if the push was successfull or not.
	 */
	static bool push(Event.Type type) {
		SDL_Event sdl_event;
		sdl_event.type = type;
		
		return SDL_PushEvent(&sdl_event) != 0;
	}
	
	/**
	 * Clear the Event queue.
	 */
	static void clear(Event.Type type) {
		SDL_FlushEvent(type);
	}
	
	/**
	 * Set a state for a Event.Type.
	 * 
	 * Returns: the previous type.
	 *
	 * See: State enum
	 */
	static State setState(Event.Type type, State state) {
		return cast(State) SDL_EventState(type, state);
	}
	
	/**
	 * Returns: if inside of the Event Queue is an Event of the given type.
	 */
	static bool hasEvent(Event.Type type) {
		return SDL_HasEvent(type) != 0;
	}
	
	/**
	 * Returns: if the current Event queue has the Quit Event.
	 */
	static bool hasQuitEvent() {
		return SDL_QuitRequested();
	}
	
	/**
	 * Waits for the given Event.
	 * If the seconds parameter is greater then -1, it waits maximal timeout seconds.
	 */
	static bool wait(Event* event, int timeout = -1) {
		int result;
		SDL_Event sdl_event;
		
		if (timeout < 0)
			result = SDL_WaitEvent(&sdl_event);
		else
			result = SDL_WaitEventTimeout(&sdl_event, timeout);
		
		EventHandler._process(event, sdl_event);
		
		return result > 0;
	}
}