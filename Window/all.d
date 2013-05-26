module Dgame.Window.all;

private {
	debug import std.stdio;
	import std.string : format;
	import std.conv : to;
	
	import derelict3.sdl2.sdl;
	import derelict3.sdl2.image;
	import derelict3.sdl2.ttf;
	import derelict.opengl.gl;
}

public {
	import Dgame.Window.EventHandler; // imports already Dgame.Window.Event
	import Dgame.Window.VideoMode;
	import Dgame.Window.Window;
}

static this() {
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	DerelictSDL2ttf.load();
	DerelictGL.load();
	
	// Initialize SDL2
	SDL_Init(SDL_INIT_VIDEO);
	
	uint flags = /*IMG_INIT_JPG | */IMG_INIT_PNG;
	int initted = IMG_Init(flags);
	if ((initted & flags) != flags) {
		string err = "IMG_Init: Failed to init required jpg and png support!\nIMG_Init: %s";
		
		throw new Exception(.format(err, to!string(IMG_GetError())));
	}
	
	if (TTF_Init() < 0) {
		throw new Exception("TTF konnte nicht gestartet werden.");
	}
	
	assert(TTF_WasInit() == 1, "SDL TTF wurde nicht korrekt initialisiert.");
}

static ~this() {
	debug writeln("quit sdl");
	
	// unload the dynamically loaded image libraries
	IMG_Quit();
	// unload the TTF support
	TTF_Quit();
	// Uninitialize SDL2 and exit the program
	SDL_Quit();
}