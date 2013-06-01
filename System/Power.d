module Dgame.System.Power;

private import derelict3.sdl2.sdl;

/**
 * This structure provide support for battery lifetime if you are on a laptop etc.
 * 
 * author: rschuett
 */
struct PowerInfo {
public:
	/**
	 * Power states
	 */
	enum State {
		Unknown   = SDL_POWERSTATE_UNKNOWN,    /** Cannot determine power status */
		OnBattery = SDL_POWERSTATE_ON_BATTERY, /** Not plugged in, running on the battery */
		NoBattery = SDL_POWERSTATE_NO_BATTERY, /** plugged in, no battery available */
		Charging  = SDL_POWERSTATE_CHARGING,   /** plugged in, charging battery */
		Charged   = SDL_POWERSTATE_CHARGED,    /** plugged in, battery charged **/
	}
	
public:
	/**
	 * Remaining time in seconds, or -1 if cannot determine power status
	 */
	int seconds;
	/**
	 * Remaining battery percent, or -1 if cannot determine power status
	 */
	byte percent;
	/**
	 * Battery state
	 */
	State state;
	
	/**
	 * Returns the PowerInfo structure with the currently power informations
	 * 
	 * See: PowerInfo struct
	 */
	static PowerInfo getInfo() {
		int secs, pct;
		SDL_PowerState state = SDL_GetPowerInfo(&secs, &pct);
		
		return PowerInfo(secs, cast(byte) pct, cast(PowerInfo.State) state);
	}
}