module Dgame.Window.MessageBox;

private {
	import derelict.sdl2.sdl;

	import Dgame.Graphics.Color;
}

struct MessageBox {
	static struct Color {
		.Color color = .Color.White;
		uint flag;

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
		int buttonid; /** User defined button id (value returned via SDL_ShowMessageBox) */
		char[16] text = void;  /** The UTF-8 button text */
	}

	enum {
		Error = SDL_MESSAGEBOX_ERROR,
		Warning = SDL_MESSAGEBOX_WARNING,
		Information = SDL_MESSAGEBOX_INFORMATION,

		Default = Error
	}

	string title;
	string msg;
	int flag;
	int winId;

	Color* box_color;
	Button* box_button;

	this(int flag, string title, string msg, int wndId = -1) {
		this.flag = flag;
		this.title = title;
		this.msg = msg;
		this.winId = wndId;
	}

	void show() const {
		int flag = this.flag;
		if (flag < Error || flag > Information)
			flag = Default;

		if (this.box_button is null && this.box_color is null) {
			SDL_Window* wnd = SDL_GetWindowFromID(this.winId);

			SDL_ShowSimpleMessageBox(flag, this.title.ptr, this.msg.ptr, wnd);
		}
	}
}