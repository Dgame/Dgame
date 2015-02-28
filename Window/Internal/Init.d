module Dgame.Window.Internal.Init;

private:

import core.stdc.stdio : printf;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

shared static this() {
    import derelict.sdl2.ttf;
    import derelict.sdl2.image;
    import derelict.sdl2.mixer;

    DerelictSDL2.load();
    DerelictSDL2Image.load();
    DerelictSDL2ttf.load();
    DerelictSDL2Mixer.load();
    DerelictGL.load();

    // Initialize SDL2
    int result = SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
    bool wasInited = result == 0;

    if (!wasInited) {
        printf("SDL init error: %s\n", SDL_GetError());
        assert(0);
    }

    // Initialize SDL_image
    enum uint IMG_FLAGS = IMG_INIT_JPG | IMG_INIT_PNG;
    
    result = IMG_Init(IMG_FLAGS);
    wasInited = (result & IMG_FLAGS) == IMG_FLAGS;

    if (!wasInited) {
        printf("Failed to init the required jpg and png support: %s\n", IMG_GetError());
        assert(0);
    }

    // Initialize SDL_ttf
    wasInited = TTF_Init() == 0;
    assert(wasInited, "SDL_TTF could not be initialized");

    // Initialize SDL_mixer
    enum uint MIX_FLAGS = MIX_INIT_OGG | MIX_INIT_MP3;
    result = Mix_Init(MIX_FLAGS);
    wasInited = (result & MIX_FLAGS) == MIX_FLAGS;
 
    if (!wasInited) {
        printf("Failed to init the required ogg and mp3 support: %s\n", Mix_GetError());
        assert(0);
    }

    wasInited = Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096) != 0;
/+
    if (!wasInited) {
        printf("Could not open Mix_OpenAudio: %s\n", Mix_GetError());
        assert(0);
    }
+/
    immutable int channels = Mix_AllocateChannels(256);
    if (channels < 256)
        printf("Could not reserve 256 channels, only %d. %s\n", channels, Mix_GetError());
}

shared static ~this() {
    import derelict.sdl2.ttf;
    import derelict.sdl2.image;
    import derelict.sdl2.mixer;

    // quit SDL_image
    IMG_Quit();
    // quit SDL_ttf
    TTF_Quit();
    // quit SDL_mixer
    Mix_ReserveChannels(0);
    Mix_CloseAudio();
    Mix_Quit();
    // quit SDL
    SDL_Quit();

    DerelictSDL2Image.unload();
    DerelictSDL2ttf.unload();
    DerelictSDL2Mixer.unload();
    DerelictSDL2.unload();
    DerelictGL.unload();
}

bool _isGLInited = false;

public:

void _initGL() {
    if (_isGLInited)
        return;

    _isGLInited = true;

    immutable GLVersion glver = DerelictGL.reload();
    debug printf("Derelict loaded GL version: %d (%d), available GL version: %s\n", DerelictGL.loadedVersion, glver, glGetString(GL_VERSION));
    
    version (OSX)
        enum GLVersion NEEDED_GL_VERSION = GLVersion.GL21;
    else
        enum GLVersion NEEDED_GL_VERSION = GLVersion.GL30;

    immutable bool glValidateVersion = glver >= NEEDED_GL_VERSION;
    if (!glValidateVersion) {
        printf("Your OpenGL version (%d) is too low.", glver);
        assert(0);
    }

    glDisable(GL_DITHER);
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_ALPHA_TEST);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);

    //glShadeModel(GL_SMOOTH);
    //glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}