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
module Dgame.Audio.Sound;

private:

import derelict.sdl2.mixer;

import Dgame.Internal.Error;

public:

/**
* Sound represents the functionality to load and play sound files.
* 
* Note: Sound is designed to load and play <b>short</b> music files, e.g. sounds for some noises.
*       If you want to play larger music, use Music.
* Note: Each Sound is played in his own channel, which means, that the number of simultaneously existing Sounds is limited to 256.
*       This limit will be increased if necessary.
*
* Supported formats are .wav, .mp3, .vorbis, .ogg, .midi
*
* Author: Randy Schuett (rswhite4@googlemail.com)
*/
struct Sound {
private:
    Mix_Chunk* _chunk;
    ushort _channel;

    static ushort ChannelCount = 0;

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
        Mix_FreeChunk(_chunk);
    }

    /**
     * Returns the current channel in which this Sound plays. Should be in range of 1 .. 256
     */
    @nogc
    ushort getChannel() const pure nothrow {
        return _channel;
    }

    /**
     * Load the sound file (filename).
     * Returns if the loading was successful.
     * If not, an error message is showed which describes what the problem is.
     */
    @nogc
    bool loadFromFile(string filename) nothrow {
        _chunk = Mix_LoadWAV(filename.ptr);
        if (!_chunk) {
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
    ubyte setVolume(ubyte volume) nothrow {
        if (_chunk)
            return cast(ubyte) Mix_VolumeChunk(_chunk, volume);
        return 0;
    }

    /**
     * Returns the current volume.
     */
    @nogc
    ubyte getVolume() nothrow {
        if (_chunk)
            return cast(ubyte) Mix_VolumeChunk(_chunk, -1);
        return 0;
    }

    /**
     * Plays the sound.
     * loops describe how often the sound shall be played.
     * A value of -1 indicated, that the sound plays forever,
     * a value of 0 means, that the sound plays zero times.
     * delay is the time in ms to fade in.
     * Any previous sound will be halted.
     */
    @nogc
    bool play(byte loops = 1, short delay = -1) nothrow {
        if (_chunk) {
            loops = loops > 0 ? cast(byte)(loops - 1) : loops;
            Mix_PlayChannelTimed(_channel, _chunk, loops, delay);

            return true;
        }

        return false;
    }

    /**
     * Resume the sound playback
     *
     * See: pause
     * See: stop
     */
    @nogc
    void resume() const nothrow {
        Mix_Resume(_channel);
    }

    /**
     * Stop/Halt the sound playback
     *
     * See: resume
     */
    @nogc   
    void stop() const nothrow {
        Mix_HaltChannel(_channel);
    }

    /**
     * Pause the sound playback
     *
     * See: resume
     */
    @nogc
    void pause() const nothrow {
        Mix_Pause(_channel);
    }

    /**
     * Stop sound playback after ms milliseconds.
     */
    @nogc
    void expire(ushort ms) const nothrow {
        Mix_ExpireChannel(_channel, ms);
    }

    /**
     * Returns if the sound is currently playing
     */
    @nogc
    bool isPlaying() const nothrow {
        return Mix_Playing(_channel) != 0;
    }

    /**
     * Returns if the sound is currently paused
     */
    @nogc
    bool isPaused() const nothrow {
        return Mix_Paused(_channel) == 0;
    }
}