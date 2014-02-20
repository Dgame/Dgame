module Dgame.Window.MessageBox;

private {
	import derelict.sdl2.sdl;
	
	import Dgame.Internal.Log;
	import Dgame.Graphics.Color;
}

private {
	SDL_MessageBoxColorScheme _asSDLColorScheme(in MessageBox.Color[] mcols) {
		SDL_MessageBoxColorScheme color_scheme;

		foreach (ref const MessageBox.Color mcol; mcols) {
			SDL_MessageBoxColor sdl_mcol = void;
			sdl_mcol.r = mcol.color.red;
			sdl_mcol.g = mcol.color.green;
			sdl_mcol.b = mcol.color.blue;
			
			color_scheme.colors[mcol.flag] = sdl_mcol;
		}
		
		return color_scheme;
	}
	
	SDL_MessageBoxButtonData[] _asSDLButton(in MessageBox.Button[] mbuttons) {
		SDL_MessageBoxButtonData[] buttons;
		buttons.reserve(mbuttons.length);
		
		foreach (ref const MessageBox.Button mbtn; mbuttons) {
			SDL_MessageBoxButtonData button_data = void;
			button_data.flags = mbtn.defKey;
			button_data.buttonid = mbtn.buttonId;
			button_data.text = mbtn.text.ptr;
			
			buttons ~= button_data;
		}
		
		return buttons;
	}
}

/**
 * A MessageBox is a short window which present a title and a message.
 * It is really helpfull to present Exceptions or Errors.
 * 
 * Author: rschuett
 */
struct MessageBox {
	static struct Color {
		.Color color = .Color.White;
		int flag;
		
		enum {
			Background = SDL_MESSAGEBOX_COLOR_BACKGROUND,
			Text = SDL_MESSAGEBOX_COLOR_TEXT,
			ButtonBorder = SDL_MESSAGEBOX_COLOR_BUTTON_BORDER,
			ButtonBackground = SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND,
			ButtonSelected = SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED
		}
	}
	
	static struct Button {
		enum DefaultKey {
			Return = SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT, /**< Marks the default button when return is hit */
			Escape = SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT, /**< Marks the default button when escape is hit */
		}
		
		DefaultKey defKey; /** The Default key */
		int buttonId = -1; /** User defined button id (value returned via SDL_ShowMessageBox) */
		char[16] text = void;  /** The UTF-8 button text */
	}
	
	/**
	 * The MessageBox states
	 */
	enum {
		Error = SDL_MESSAGEBOX_ERROR, /// An Error is thrown
		Warning = SDL_MESSAGEBOX_WARNING, /// A warning is thrown
		Information = SDL_MESSAGEBOX_INFORMATION, /// An information is thrown
		
		Default = Error /// Default is: Error
	}
	
	string title; /// The Title of the MessageBox
	string msg;   /// The Message of the MessageBox
	int flag;	  /// The MessageBox Flags. See: MessageBox states enum
	/**
	 * The Window id where the Error/Warning/Information comes from.
	 * Can be get by
	 * ----
	 * Window wnd = new Window(...);
	 * // A lot of code
	 * MessageBox(MessageBox.Error, "An Error", "You get an error!", wnd.id);
	 * ----
	 * Default is -1, which means that the MessageBox is not affiliated to any Window.
	 */
	int winId = -1;
	
	Color[] box_colors;
	Button[] box_buttons;
	
	/**
	 * CTor
	 */
	this(int flag, string title, string msg, int wndId = -1) {
		this.flag = flag;
		this.title = title;
		this.msg = msg;
		this.winId = wndId;
	}
	
	/**
	 * Show the MessageBox.
	 * 
	 * Example:
	 * ----
	 * MessageBox(MessageBox.Error, "An Error", "You get an error!").show();
	 * ----
	 * Or
	 * ----
	 * MessageBox msgbox = MessageBox(MessageBox.Error, "An Error", "You get an error!");
	 * // Some code...
	 * msgbox.show();
	 * ----
	 */
	void show() const {
		int flag = this.flag;
		if (flag < Error || flag > Information)
			flag = Default;
		
		SDL_Window* wnd = null;
		if (this.winId != -1)
			wnd = SDL_GetWindowFromID(this.winId);
		if (wnd is null)
			wnd = SDL_GL_GetCurrentWindow();
		
		int result = -1;
		if (this.box_buttons.length == 0 && this.box_colors.length == 0)
			result = SDL_ShowSimpleMessageBox(flag, this.title.ptr, this.msg.ptr, wnd);
		else {
			SDL_MessageBoxData mbd = void;
			
			mbd.flags = flag;
			mbd.window = wnd;
			mbd.title = this.title.ptr;
			mbd.message = this.msg.ptr;
			mbd.numbuttons = cast(int) this.box_buttons.length;
			
			if (this.box_buttons.length != 0)
				mbd.buttons = _asSDLButton(this.box_buttons).ptr;
			
			if (this.box_colors.length != 0) {
				SDL_MessageBoxColorScheme box_color_scheme = _asSDLColorScheme(this.box_colors);
				mbd.colorScheme = &box_color_scheme;
			}
			
			result = SDL_ShowMessageBox(&mbd, null);
		}
		
		if (result != 0)
			Log.info("MessageBox could not be displayed.");
	}
}