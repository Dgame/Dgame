module Dgame.Audio.Sound;

private:

import core.stdc.stdio : printf;

import derelict.sdl2.mixer;

public:

struct Sound {
private:
    Mix_Chunk* _chunk;
    ushort _channel;

    static ushort ChannelCount = 0;

public:
    @nogc
    this(string filename, ubyte volume = 128) nothrow {
        this.loadFromFile(filename);
        this.setVolume(volume);
    }
    
    @disable
    this(this);

    @nogc
    ~this() nothrow {
        Mix_FreeChunk(_chunk);
    }

    @nogc
    ushort getChannel() const pure nothrow {
        return _channel;
    }

    @nogc
    bool loadFromFile(string filename) nothrow {
        _chunk = Mix_LoadWAV(filename.ptr);
        if (!_chunk) {
            printf("Could not load file: %s\n", Mix_GetError());
            return false;
        }

        return true;
    }

    @nogc
    void setVolume(ubyte volume) nothrow {
        if (_chunk)
            Mix_VolumeChunk(_chunk, volume);
    }

    @nogc
    ubyte getVolume() nothrow {
        if (_chunk)
            return cast(ubyte) Mix_VolumeChunk(_chunk, -1);
        return 0;
    }

    @nogc
    bool play(byte loops = 1, short delay = -1) nothrow {
        if (_chunk) {
            loops = loops > 0 ? cast(byte)(loops - 1) : loops;
            Mix_PlayChannelTimed(_channel, _chunk, loops, delay);

            return true;
        }

        return false;
    }
    
    @nogc
    void resume() const nothrow {
        Mix_Resume(_channel);
    }

    @nogc   
    void stop() const nothrow {
        Mix_HaltChannel(_channel);
    }
    
    @nogc
    void pause() const nothrow {
        Mix_Pause(_channel);
    }
    
    @nogc
    void expire(ushort ticks) const nothrow {
        Mix_ExpireChannel(_channel, ticks);
    }
    
    @nogc
    bool isPlaying() const nothrow {
        return Mix_Playing(_channel) != 0;
    }
    
    @nogc
    bool isPaused() const nothrow {
        return Mix_Paused(_channel) == 0;
    }
}