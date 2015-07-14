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
module Dgame.System.StopWatch;

private import derelict.sdl2.functions;

/**
 * Convert the Clock milliseconds to seconds
 */
@nogc
float asSeconds(uint n) pure nothrow {
    return n >= 1000 ? (n / 1000) : 0;
}

/**
 * Convert the Clock milliseconds to minutes
 */
@nogc
float asMinutes(uint n) pure nothrow {
    immutable float secs = asSeconds(n);
    
    return secs >= 60 ? (secs / 60) : 0;
}

/**
 * Convert the Clock milliseconds to hours
 */
@nogc
uint asHours(uint n) pure nothrow {
    immutable float mins = asMinutes(n);
    
    return mins >= 60 ? cast(uint)(mins / 60) : 0;
}

/**
* Returns the given seconds in milliseconds
*
* Example:
* ----
* int n = 5.seconds; // n is 5000 because 5 seconds are 5000 milliseconds
* ----
*
* ----
* StopWatch sw;
* sw.wait(5.seconds);
* ----
*/
@property
@nogc
uint seconds(uint n) pure nothrow {
    return n * 1000;
}

/**
* Returns the given minutes in milliseconds
*
* Example:
* ----
* int n = 5.minutes; // n is 300_000 because 5 minutes are 300 seconds are 300_000 milliseconds
* ----
*
* ----
* StopWatch sw;
* sw.wait(5.minutes);
* ----
*/
@property
@nogc
uint minutes(uint n) pure nothrow {
    return (n * 60).seconds;
}

/**
 * The Time struct converts ticks to msecs, seconds, minutes and hours.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Time {
    /**
     * Milliseconds = Ticks
     */
    uint msecs;
    /**
     * Seconds = Milliseconds / 1000
     */
    float seconds;
    /**
     * Minutes = Seconds / 60
     */
    float minutes;
    /**
     * Hours = Minutes / 60
     */
    uint hours;

    /**
     * CTor
     */
    @nogc
    this(uint msecs) pure nothrow {
        this.msecs   = msecs;
        this.seconds = asSeconds(msecs);
        this.minutes = asMinutes(msecs);
        this.hours   = asHours(msecs);
    }

    /**
     * Calculate the <b>remaining</b> time.
     */
    @nogc
    static Time remain(Time time) pure nothrow {
        import std.math : floor;

        immutable float min = time.minutes;
        immutable float sec = time.seconds;

        time.minutes -= floor(float(time.hours)) * 60;
        time.minutes = floor(time.minutes);
        time.seconds -= floor(min) * 60;
        time.msecs -= cast(uint)(floor(sec) * 1000);

        return time;
    }
}

unittest {
    Time time = Time(65_000);

    assert(time.msecs == 65_000);
    assert(time.seconds == 65);
    assert(time.minutes >= 1.08f && time.minutes <= 1.09f);

    time = Time.remain(time);

    assert(time.msecs == 0f);
    assert(time.seconds == 5f);
    assert(time.minutes == 1f);
}

/**
 * This class handles timer functions and 
 * the window class use these class to calculate the current fps.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct StopWatch {
private:
    uint _startTime;
    uint _numFrames;
    uint _currentFps;
    
public:
    /**
     * Reset the clock time
     */
    @nogc
    void reset() nothrow {
        _startTime = SDL_GetTicks();
    }
    
    /**
     * Returns the elapsed Time since the last reset.
     */
    @nogc
    Time getElapsedTime() const nothrow {
        return Time(this.getElapsedTicks());
    }
    
    /**
     * Returns only the milliseconds since the last reset.
     */
    @nogc
    uint getElapsedTicks() const nothrow {
        return SDL_GetTicks() - _startTime;
    }
    
    /**
     * Returns the current framerate per seconds.
     * If frame_ms is not null, the average ms per frame is stored there
     */
    @nogc
    uint getCurrentFPS(uint* frame_ms = null) nothrow {
        immutable uint elapsed_ticks = this.getElapsedTicks();
        if (elapsed_ticks >= 1000) {
            _currentFps = _numFrames;
            _numFrames = 0;
            this.reset();
        }

        if (frame_ms)
            *frame_ms = elapsed_ticks / _numFrames;
        
        _numFrames++;
        
        return _currentFps;
    }

    /**
     * Returns the milliseconds since the application was started.
     */
    @nogc
    static uint getTicks() nothrow {
        return SDL_GetTicks();
    }
    
    /**
     * Returns the Time since the application was started.
     */
    @nogc
    static Time getTime() nothrow {
        return Time(StopWatch.getTicks());
    }
    
    /**
     * Wait for msecs milliseconds, which means that the application freeze for this time.
     */
    @nogc
    static void wait(uint msecs) nothrow {
        SDL_Delay(msecs);
    }
}
