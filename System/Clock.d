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
module Dgame.System.Clock;

private import derelict.sdl2.functions;

/**
 * To convert the Clock milliseconds to seconds
 */
float asSeconds(uint n) pure nothrow {
	return n >= 1000 ? (n / 1000) : 0;
}

/**
 * To convert the Clock milliseconds to minutes
 */
float asMinutes(uint n) pure nothrow {
	immutable float secs = asSeconds(n);
	
	return secs >= 60 ? (secs / 60) : 0;
}

/**
 * To convert the Clock milliseconds to hours
 */
ushort asHours(uint n) pure nothrow {
	immutable float mins = asMinutes(n);
	
	return mins >= 60 ? cast(ushort)(mins / 60) : 0;
}

/**
 * The Time struct converts ticks to msecs, seconds, minutes and hours.
 */
struct Time {
	/// Milliseconds = Ticks
	uint msecs;
	/// Seconds = Milliseconds / 1000
	float seconds;
	//// Minutes = Seconds / 60
	float minutes;
	/// Hours = Minutes / 60
	ushort hours;

	/**
	 * CTor
	 */
	this(uint msecs) pure nothrow {
		this.msecs   = msecs;
		this.seconds = asSeconds(msecs);
		this.minutes = asMinutes(msecs);
		this.hours   = asHours(msecs);
	}

	/**
	 * Calculate the <b>remaining</b> time.
	 */
	static Time remain(Time time) pure nothrow {
		import std.math : floor;

		const float min = time.minutes;
		const float sec = time.seconds;

		time.minutes -= floor(time.hours) * 60;
		time.minutes = floor(time.minutes);
		time.seconds -= floor(min) * 60;
		time.msecs -= floor(sec) * 1000;

		return time;
	}
} unittest {
	import std.stdio;

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
 * Author: rschuett
 */
struct Clock {
private:
	uint _startTime;
	uint _numFrames;
	uint _currentFps;
	float _fpsTime;
	
public:
	/**
	 * Reset the clock time
	 */
	void reset() {
		this._startTime = SDL_GetTicks();
	}
	
	/**
	 * Returns the elapsed Time since the last reset.
	 */
	Time getElapsedTime() const {
		return Time(this.getElapsedTicks());
	}
	
	/**
	 * Returns only the milliseconds since the last reset.
	 */
	uint getElapsedTicks() const {
		return SDL_GetTicks() - this._startTime;
	}
	
	/**
	 * Returns the current framerate per seconds.
	 */
	uint getCurrentFps() {
		const uint elapsed_ticks = this.getElapsedTicks();

		if (elapsed_ticks >= 1000) {
			this._currentFps = this._numFrames;
			this._fpsTime = (0f + elapsed_ticks) / this._numFrames;
			
			this._numFrames = 0;
			this.reset();
		}
		
		this._numFrames++;
		
		return this._currentFps;
	}

	/**
	 * Returns the Time since the last Frame.
	 */
	float getFpsTime() const pure nothrow {
		return this._fpsTime;
	}

	/**
	 * Returns the milliseconds since the application was started.
	 */
	static uint getTicks() {
		return SDL_GetTicks();
	}
	
	/**
	 * Returns the Time since the application was started.
	 */
	static Time getTime() {
		return Time(Clock.getTicks());
	}
	
	/**
	 * Wait for msecs milliseconds, which means that the application freeze for this time.
	 */
	static void wait(uint msecs) {
		SDL_Delay(msecs);
	}
	
	/**
	 * Use this function to get the 
	 * current value of the high resolution counter.
	 */
	static ulong getPerformanceCounter() {
		return SDL_GetPerformanceCounter();
	}
	
	/**
	 * Use this function to get the 
	 * count per second of the high resolution counter.
	 */
	static ulong getPerformanceFrequency() {
		return SDL_GetPerformanceFrequency();
	}
}