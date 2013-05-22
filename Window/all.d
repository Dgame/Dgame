module Dgame.Window.all;

debug import std.stdio;

private {
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
	
	if (TTF_Init() < 0) {
		throw new Exception("TTF konnte nicht gestartet werden.");
	}
	
	assert(TTF_WasInit() == 1, "SDL TTF wurde nicht korrekt initialisiert.");
}

static ~this() {
	debug writeln("quit sdl");
	
	TTF_Quit();
	// Uninitialize SDL2 and exit the program
	SDL_Quit();
}