module Dgame.Window.all;

private {
	debug import std.stdio;
	import std.conv : to;
	
	import derelict.sdl2.sdl;
	import derelict.sdl2.image;
	import derelict.sdl2.ttf;
	import derelict.opengl3.gl;
}

public {
	import Dgame.Window.EventHandler; // imports already Dgame.Window.Event
	import Dgame.Window.VideoMode;
	import Dgame.Window.Window;
}

private enum ImgFlags = IMG_INIT_JPG | IMG_INIT_PNG;

shared static this() {
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	DerelictSDL2ttf.load();
	DerelictGL.load();
	
	// Initialize SDL2
	if (SDL_Init(SDL_INIT_VIDEO) != 0)
		throw new Exception("SDL Error: " ~ to!string(SDL_GetError()));

	const int initted = IMG_Init(ImgFlags);
	if ((initted & ImgFlags) != ImgFlags)
		throw new Exception("IMG_Init: Failed to init required jpg and png support!\nIMG_Init: "
							~ to!string(IMG_GetError()));
	
	if (TTF_Init() < 0)
		throw new Exception("TTF konnte nicht gestartet werden.");
	
	assert(TTF_WasInit() == 1, "SDL TTF wurde nicht korrekt initialisiert.");
}

shared static ~this() {
	debug writeln("quit sdl");
	
	// unload the dynamically loaded image libraries
	IMG_Quit();
	// unload the TTF support
	TTF_Quit();
	// Uninitialize SDL2 and exit the program
	SDL_Quit();
}