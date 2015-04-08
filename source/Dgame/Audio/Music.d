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
module Dgame.Audio.Music;

private:

import derelict.sdl2.mixer;

import Dgame.Internal.Error;

public:

/**
* Music represents the functionality to load and play music files.
*
* Note: Music is designed to load and play <b>larger</b> music files, e.g. background music
*       If you just want to play short sounds, use Sound.
*
* Supported formats are .wav, .mp3, .vorbis, .ogg, .midi
*
* Author: Randy Schuett (rswhite4@googlemail.com)
*/
struct Music {
private:
    Mix_Music* _music;

public:
    /**
     * CTor
     */
    @nogc
    this(string filename, ubyte volume = 128) nothrow {
        this.loadFromFile(filename);
        this.setVolume(volume);
    }
    
    /**
     * Postblit is disabled
     */
    @disable
    this(this);

    /**
     * DTor
     */
    @nogc
    ~this() nothrow {
        Mix_FreeMusic(_music);
    }

    /**
     * Load the music file (filename).
     * Returns if the loading was successful.
     * If not, an error message is showed which describes what the problem is.
     */
    @nogc
    bool loadFromFile(string filename) nothrow {
        _music = Mix_LoadMUS(filename.ptr);
        if (!_music) {
            print_fmt("Could not load file: %s\n", Mix_GetError());
            return false;
        }

        return true;
    }

    /**
     * Set the volume, max. is 128, min. is 0
     * If the value is above 128, the max. will be assumed.
     * Returns the previous volume.
     */
    @nogc
    ubyte setVolume(ubyte volume) const nothrow {
        return cast(ubyte) Mix_VolumeMusic(volume);
    }

    /**
     * Returns the current volume
     */
    @nogc
    ubyte getVolume() const nothrow {
        return cast(ubyte) Mix_VolumeMusic(-1);
    }

    /**
     * Plays the music.
     * loops describe how often the music shall be played.
     * A value of -1 indicated, that the music plays forever,
     * a value of 0 means, that the music plays zero times.
     * delay is the time in ms to fade in.
     * Any previous music will be halted.
     */
    @nogc
    void play(byte loops = 1, short delay = -1) nothrow {
        if (_music) {
            loops = loops > 0 ? cast(byte)(loops - 1) : loops;
            Mix_FadeInMusic(_music, loops, delay);
        }
    }

    /**
     * Resume the music playback
     *
     * See: pause
     * See: stop
     */
    @nogc
    void resume() const nothrow {
        Mix_ResumeMusic();
    }

    /**
     * Stop/Halt the music playback
     *
     * See: resume
     */
    @nogc
    void stop() const nothrow {
        Mix_HaltMusic();
    }

    /**
     * Pause the music playback
     *
     * See: resume
     */
    @nogc
    void pause() const nothrow {
        Mix_PauseMusic();
    }

    /**
     * Rewind the music to the start
     *
     * Note: This function only works for .ogg, .vorbis, .mp3, .midi
     */
    @nogc
    void rewind() const nothrow {
        Mix_RewindMusic();
    }

    /**
     * Fade out the music. The music will be stopped in ms milliseconds.
     */
    @nogc
    void fadeOut(ushort ms) nothrow {
        Mix_FadeOutMusic(ms);
    }

    /**
     * Set the position of the currently playing music.
     * The position takes different meanings for different music sources.
     * 
     * <b>.ogg / .vorbis:</b>
     *   Jumps to position seconds from the beginning of the song.
     * <b>mp3:</b>
     *    Jumps to position seconds from the current position in the stream.
     *    So you may want to call rewind before.
     *    <b>Does not go in reverse: negative values do nothing.</b>
     * 
     * Note: This only works for.ogg, .vorbis and .mp3
     */
    @nogc
    void setPosition(float seconds) const nothrow {
        Mix_SetMusicPosition(seconds);
    }

    /**
     * Returns if the music is currently playing
     */
    @nogc
    bool isPlaying() const nothrow {
        return Mix_PlayingMusic() != 0;
    }

    /**
     * Returns if the music is currently paused
     */
    @nogc
    bool isPaused() const nothrow {
        return Mix_PausedMusic() != 0;
    }
}