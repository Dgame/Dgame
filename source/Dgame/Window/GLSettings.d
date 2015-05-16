module Dgame.Window.GLSettings;

/**
 * The GLSettings structure defines a way to tell OpenGL important user settings,
 * like the desired major / minor version or the anti aliasing level.
 *
 * Note: if anti aliasing is activated you will notice a drastic reduction of your framerate.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct GLSettings {
    /**
     * The profile of the OpenGL Context
     */
    enum Profile : ubyte {
        Compatibility, /// OpenGL compatibility profile - deprecated functions are allowed (default)
        Core, /// OpenGL core profile - deprecated functions are disabled
        ES, /// OpenGL ES profile - only a subset of the base OpenGL functionality is available
        None, /// profile depends on platform
    }

    /**
     * Major Version of OpenGL. 0 means highest possible.
     */
    ubyte majorVersion = 0;
    /**
     * Minor Version of OpenGL. 0 means highest possible.
     */
    ubyte minorVersion = 0;
    /**
     * Anti aliasing level. 0 means deactivated.
     * 
     * Note: A too high value may crash your application at the beginning
     *       because your driver does not support it.
     *
     * Typical values are 2, 4 or 8
     */
    ubyte antiAliasLevel = 0;
    /**
     * The OpenGL Context profile. Default is Profile.Compatibility
     */
    Profile profile = Profile.Compatibility;

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