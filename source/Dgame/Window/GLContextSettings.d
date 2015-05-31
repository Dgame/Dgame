module Dgame.Window.GLContextSettings;

/**
 * The GLContextSettings structure defines a way to tell OpenGL important user settings,
 * like the desired major / minor version or the anti aliasing level.
 *
 * Note: if anti aliasing is activated you will notice a drastic reduction of your framerate.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct GLContextSettings {
    /**
     * The profile of the OpenGL Context
     */
    enum Profile : ubyte {
        Default, /// profile depends on platform
        Compatibility, /// OpenGL compatibility profile - deprecated functions are allowed (default)
        Core, /// OpenGL core profile - deprecated functions are disabled
        ES, /// OpenGL ES profile - only a subset of the base OpenGL functionality is available
    }

    /**
     * The supported OpenGL Versions
     */
    enum Version : ubyte {
        GLXX = 0,  /// Highest supported version
        GL21 = 21, ///
        GL30 = 30, ///
        GL31 = 31, ///
        GL32 = 32, ///
        GL33 = 33, ///
        GL40 = 40, ///
        GL41 = 41, ///
        GL42 = 42, ///
        GL43 = 43, ///
        GL44 = 44, ///
        GL45 = 45, ///
    }

    /**
     * Anti aliasing level. 0 means deactivated.
     * 
     * Note: A too high value may crash your application at the beginning
     *       because your driver does not support it.
     *
     * Typical values are 2, 4 or 8
     */
    ubyte antiAlias = 0;
    /**
     * The OpenGL Version. Default is the highest supported version.
     */
    Version vers = Version.GLXX;
    /**
     * The OpenGL Context profile. Default is Profile.Compatibility
     */
    Profile profile = Profile.Compatibility;

    /**
     * CTor
     */
    @nogc
    this(ubyte antiAlias, Version vers = Version.GLXX, Profile profile = Profile.Compatibility) pure nothrow {
        this.antiAlias = antiAlias;
        this.vers = vers;
        this.profile = profile;
    }
}