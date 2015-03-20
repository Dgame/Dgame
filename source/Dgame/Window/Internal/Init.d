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

import core.stdc.stdio : printf;

import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;
import derelict.sdl2.mixer;

import Dgame.Window.GLSettings;

shared static this() {
    DerelictSDL2.load();
    DerelictSDL2Image.load();
    DerelictSDL2ttf.load();
    DerelictSDL2Mixer.load();
    DerelictGL.load();
}

shared static ~this() {
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

public: /// @@ Replace with package(Dgame): @@

@nogc
void _initSDL() {
    if (_isSDLInited)
        return;

    scope(exit) _isSDLInited = true;

    // Initialize SDL2
    int result = SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
    if (result != 0) {
        printf("Error: SDL could not be initialized: %s\n", SDL_GetError());
        assert(0);
    }

    // Initialize SDL_image

    result = IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
    if (result == 0) {
        printf("Error: Failed to init the required jpg and png support: %s\n", IMG_GetError());
        assert(0);
    } else if ((result & IMG_INIT_JPG) == 0)
        printf("Warning: No jpg support: %s\n", IMG_GetError());
    else if ((result & IMG_INIT_PNG) == 0)
        printf("Warning: No png support: %s\n", IMG_GetError());

    // Initialize SDL_ttf
    result = TTF_Init();
    if (result != 0) {
        printf("Error: SDL_TTF could not be initialized: %s\n", Mix_GetError());
        assert(0);
    }

    // Initialize SDL_mixer
    result = Mix_Init(MIX_INIT_OGG | MIX_INIT_MP3);
    if (result == 0) {
        printf("Error: Failed to init the required ogg and mp3 support: %s\n", Mix_GetError());
        assert(0);
    } else if ((result & MIX_INIT_OGG) == 0)
        printf("Warning: No ogg support: %s\n", Mix_GetError());
    else if ((result & MIX_INIT_MP3) == 0)
        printf("Warning: No mp3 support: %s\n", Mix_GetError());

    result = Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096);

    // ignore this warning silently
    version (none) {
        if (result != 0)
            printf("Warning: Could not open Mix_OpenAudio: %s\n", Mix_GetError());
    }
    
    immutable int channels = Mix_AllocateChannels(256);
    if (channels < 256)
        printf("Warning: Could not reserve 256 channels, only %d. %s\n", channels, Mix_GetError());
}

@nogc
void _initGLAttr(ref GLSettings gl_settings) {
    // Mac does not allow deprecated functions / constants, so we have to set the version manually to 2.1
    version (OSX) {
        if (gl_settings.majorVersion == 0) {
            gl_settings.majorVersion = 2;
            gl_settings.minorVersion = 1;
        }
    }

    if (gl_settings.majorVersion != 0) {
        int result = SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, gl_settings.majorVersion);
        if (result != 0) {
            printf("Error by initializing OpenGL: %s\n", SDL_GetError());
            assert(0);
        }

        result = SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, gl_settings.minorVersion);
        if (result != 0) {
            printf("Error by initializing OpenGL: %s\n", SDL_GetError());
            assert(0);
        }
    }

    if (gl_settings.antiAliasLevel > 0) {
        int result = SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
        if (result != 0) {
            printf("Error by initializing OpenGL: %s\n", SDL_GetError());
            assert(0);
        }

        result = SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, gl_settings.antiAliasLevel);
        if (result != 0) {
            printf("Error by initializing OpenGL: %s\n", SDL_GetError());
            assert(0);
        }
    }

    int result = SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    if (result != 0) {
        printf("Error by initializing OpenGL: %s\n", SDL_GetError());
        assert(0);
    }
    result = SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
    if (result != 0) {
        printf("Error by initializing OpenGL: %s\n", SDL_GetError());
        assert(0);
    }
}

void _initGL() {
    if (_isGLInited)
        return;

    scope(exit) _isGLInited = true;

    immutable GLVersion glver = DerelictGL.reload();
    const char* glverstr = glGetString(GL_VERSION);
    debug printf("Derelict loaded GL version: %d (%d), available GL version: %s\n", DerelictGL.loadedVersion, glver, glverstr);
    
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

    glEnable(GL_MULTISAMPLE);

    //glShadeModel(GL_SMOOTH);
    //glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}