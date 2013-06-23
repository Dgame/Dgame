module Dgame.System.Clock;

private {
	debug import std.stdio;
	
	import derelict.sdl2.functions;
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
	 * Returns the milliseconds since reset or the CTor was called.
	 */
	uint getElapsedTime() const {
		return SDL_GetTicks() - this._startTime;
	}
	
	/**
	 * Returns the milliseconds since the application was started.
	 */
	static uint getTicks() {
		return SDL_GetTicks();
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
	
	/**
	 * Returns the current framerate per seconds.
	 */
	uint getCurrentFps() {
		if (this.getElapsedTime() >= 1000) {
			this._currentFps = this._numFrames;
			
			this._numFrames = 0;
			this.reset();
		}
		
		this._numFrames++;
		
		return this._currentFps;
	}
}