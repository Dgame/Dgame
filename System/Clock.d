module Dgame.System.Clock;

private import derelict.sdl2.functions;

/**
* To convert the Clock milliseconds to seconds
*/
float asSeconds(uint n) pure nothrow {
	return n >= 1000 ? (n / 1000f) : 0f;
}

/**
* To convert the Clock milliseconds to minutes
*/
float asMinutes(uint n) pure nothrow {
	immutable float secs = asSeconds(n);

	return secs >= 60 ? (secs / 60f) : 0f;
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
const struct Time {
public:
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
	this(uint msecs) pure {
		this.msecs   = msecs;
		this.seconds = asSeconds(msecs);
		this.minutes = asMinutes(msecs);
		this.hours   = asHours(msecs);
	}
}

/**
 * This class handles timer functions and 
 * the window class use these class to calculate the current fps.
 *
 * Author: rschuett
 */
final class Clock {
private:
	uint _startTime;
	uint _numFrames;
	uint _currentFps;
	
public:
	/**
	 * CTor
	 */
	this() {
		this.reset();
		
		this._currentFps = 0;
	}
	
	/**
	 * Reset the clock time
	 */
	void reset() {
		this._startTime = SDL_GetTicks();
	}
	
	/**
	 * Returns the elapsed Time since the last reset or the CTor was called.
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
		if (this.getElapsedTicks() >= 1000) {
			this._currentFps = this._numFrames;

			this._numFrames = 0;
			this.reset();
		}

		this._numFrames++;

		return this._currentFps;
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