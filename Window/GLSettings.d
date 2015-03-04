module Dgame.Window.GLSettings;

/**
 * The GLSettings structure defines a way to tell OpenGL important user settings,
 * like the desired major / minor version or the anti aliasing level.
 *
 * Note: if anti aliasing is activated you will notice a drastic reduction of your framerate.
 *
 * Author: randy schuett
 */
struct GLSettings {
	/// Major Version of OpenGL. 0 means highest possible.
	ubyte majorVersion = 0;
	/// Minor Version of OpenGL. 0 means highest possible.
	ubyte minorVersion = 0;
	/// Anti aliasing level. 0 means deactivated.
	ubyte antiAliasLevel = 0;

	/**
	 * CTor
	 */
	@nogc
	this(ubyte major, ubyte minor, ubyte antiAlias) pure nothrow {
		this.majorVersion = major;
		this.minorVersion = minor;
		this.antiAliasLevel = antiAlias;
	}
}