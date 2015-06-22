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
module Dgame.Window.Internal.Init;

private:

import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;
import derelict.sdl2.mixer;

import Dgame.Window.GLContextSettings;
import Dgame.Internal.Error;

shared static this() {
    DerelictSDL2.load();
    DerelictSDL2Image.load();
    DerelictSDL2ttf.load();
    DerelictSDL2Mixer.load();
    DerelictGL.load();
}

shared static ~this() {
    if (SDL_WasInit(SDL_INIT_JOYSTICK) != 0)
        SDL_QuitSubSystem(SDL_INIT_JOYSTICK);
    if (SDL_WasInit(SDL_INIT_GAMECONTROLLER) != 0)
        SDL_QuitSubSystem(SDL_INIT_GAMECONTROLLER);

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
bool _isSDLInited = false;

package(Dgame):

void _initSDL() {
    if (_isSDLInited)
        return;

    debug {
        SDL_version sdlver = void;
        SDL_GetVersion(&sdlver);

        print_fmt("SDL version: %d.%d.%d\n", sdlver.major, sdlver.minor, sdlver.patch);
    }

    scope(exit) _isSDLInited = true;

    // Initialize SDL2
    int result = SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
    assert_fmt(result == 0, "Error: SDL could not be initialized: %s\n", SDL_GetError());

    if (SDL_InitSubSystem(SDL_INIT_JOYSTICK) != 0)
        print_fmt("Warning: No Joystick support\n");
    if (SDL_InitSubSystem(SDL_INIT_GAMECONTROLLER) != 0)
        print_fmt("Warning: No GameController support\n");

    // Initialize SDL_image
    result = IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
    assert_fmt(result != 0, "Error: Failed to init the required jpg and png support: %s\n", IMG_GetError());
    
    if ((result & IMG_INIT_JPG) == 0)
        print_fmt("Warning: No jpg support: %s\n", IMG_GetError());
    else if ((result & IMG_INIT_PNG) == 0)
        print_fmt("Warning: No png support: %s\n", IMG_GetError());

    // Initialize SDL_ttf
    result = TTF_Init();
    assert_fmt(result == 0, "Error: SDL_TTF could not be initialized: %s\n", Mix_GetError());

    // Initialize SDL_mixer
    result = Mix_Init(MIX_INIT_OGG | MIX_INIT_MP3);
    assert_fmt(result != 0, "Error: Failed to init the required ogg and mp3 support: %s\n", Mix_GetError());
    
    if ((result & MIX_INIT_OGG) == 0)
        print_fmt("Warning: No ogg support: %s\n", Mix_GetError());
    else if ((result & MIX_INIT_MP3) == 0)
        print_fmt("Warning: No mp3 support: %s\n", Mix_GetError());

    result = Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096);
    assert_fmt(result == 0, "Warning: Could not open Mix_OpenAudio: %s\n", Mix_GetError());

    SDL_ClearError(); // Ignore XAudio2 error: http://redmine.audacious-media-player.org/issues/346
    
    immutable int channels = Mix_AllocateChannels(256);
    if (channels < 256)
        print_fmt("Warning: Could not reserve 256 channels, only %d. %s\n", channels, Mix_GetError());
}

@nogc
void _initGLAttr(const GLContextSettings gl) {
    ubyte majorVersion, minorVersion;

    if (gl.vers == GLContextSettings.Version.Default) {
        version (OSX) {
            majorVersion = 2;
            minorVersion = 1;
        }
    } else {
        majorVersion = gl.vers / 10;
        minorVersion = gl.vers % 10;
    }

    if (majorVersion != 0) {
        int result = SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, majorVersion);
        assert_fmt(result == 0, "Error by initializing OpenGL: %s\n", SDL_GetError());

        result = SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, minorVersion);
        assert_fmt(result == 0, "Error by initializing OpenGL: %s\n", SDL_GetError());

        debug print_fmt("OpenGL Context created in OpenGL version %d.%d\n", majorVersion, minorVersion);
    }

    final switch (gl.profile) {
        case GLContextSettings.Profile.Default:
            break;
        case GLContextSettings.Profile.Core:
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
            break;
        case GLContextSettings.Profile.Compatibility:
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
            break;
        case GLContextSettings.Profile.ES:
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
            break;
    }

    if (gl.antiAlias > 0) {
        debug print_fmt("Set %d as anti alias level\n", gl.antiAlias);

        int result = SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
        if (result != 0)
            print_fmt("Could not enable Anti-Alias: %s\n", SDL_GetError());

        result = SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, gl.antiAlias);
        if (result != 0)
            print_fmt("Could not enable Anti-Alias Level %d: %s\n", gl.antiAlias, SDL_GetError());
    }

    int result = SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    assert_fmt(result == 0, "Error by initializing OpenGL: %s\n", SDL_GetError());

    result = SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
    assert_fmt(result == 0, "Error by initializing OpenGL: %s\n", SDL_GetError());
}

void _initGL() {
    if (_isGLInited)
        return;

    scope(exit) _isGLInited = true;

    immutable GLVersion glver = DerelictGL.reload();
    const char* glverstr = glGetString(GL_VERSION);
    debug print_fmt("Derelict loaded GL version: %d (%d), available GL version: %s\n", DerelictGL.loadedVersion, glver, glverstr);
    
    version (OSX)
        enum GLVersion NEEDED_GL_VERSION = GLVersion.GL21;
    else
        enum GLVersion NEEDED_GL_VERSION = GLVersion.GL30;

    assert_fmt(glver >= NEEDED_GL_VERSION, "Your OpenGL version (%d) is too low. Need at least OpenGL 3.0.", glver);

    glDisable(GL_DITHER);
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_ALPHA_TEST);

    glEnable(GL_TEXTURE_2D);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);

    glEnable(GL_MULTISAMPLE);

    //glShadeModel(GL_SMOOTH);
    //glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}