module Dgame.Audio.Music;

private:

import core.stdc.stdio : printf;

import derelict.sdl2.mixer;

public:

struct Music {
private:
    Mix_Music* _music;

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
        Mix_FreeMusic(_music);
    }

    @nogc
    bool loadFromFile(string filename) nothrow {
        _music = Mix_LoadMUS(filename.ptr);
        if (!_music) {
            printf("Could not load file: %s\n", Mix_GetError());
            return false;
        }

        return true;
    }

    @nogc
    void setVolume(ubyte volume) const nothrow {
        Mix_VolumeMusic(volume);
    }

    @nogc
    ubyte getVolume() const nothrow {
        return cast(ubyte) Mix_VolumeMusic(-1);
    }

    @nogc
    void play(byte loops = 1, short delay = -1) nothrow {
        if (_music) {
            loops = loops > 0 ? cast(byte)(loops - 1) : loops;
            Mix_FadeInMusic(_music, loops, delay);
        }
    }

    @nogc
    void pause() const nothrow {
        Mix_PauseMusic();
    }

    @nogc
    void resume() const nothrow {
        Mix_ResumeMusic();
    }

    @nogc
    void stop() const nothrow {
        Mix_HaltMusic();
    }

    @nogc
    void rewind() const nothrow {
        Mix_RewindMusic();
    }

    @nogc
    void setPosition(float seconds) const nothrow {
        Mix_SetMusicPosition(seconds);
    }

    @nogc
    bool isPlaying() const nothrow {
        return Mix_PlayingMusic() != 0;
    }

    @nogc
    bool isPaused() const nothrow {
        return Mix_PausedMusic() != 0;
    }
}