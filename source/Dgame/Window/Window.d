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
module Dgame.Window.Window;

private:

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import Dgame.Graphic.Color;
import Dgame.Graphic.Drawable;
import Dgame.Graphic.Masks;
import Dgame.Graphic.Surface;
import Dgame.Graphic.Texture;

import Dgame.Math.Vertex;
import Dgame.Math.Vector2;
import Dgame.Math.Matrix4x4;
import Dgame.Math.Rect;
import Dgame.Math.Geometry;

import Dgame.Window.Event;
import Dgame.Window.GLContextSettings;
import Dgame.Window.DisplayMode;
import Dgame.Window.Internal.Init;

import Dgame.Internal.Error;
import Dgame.Internal.m3;
import Dgame.Internal.d2c;

static if (!SDL_VERSION_ATLEAST(2, 0, 4)) {
    enum int SDL_WINDOW_MOUSE_CAPTURE = 0;
}

enum int DefPosX = 100;
enum int DefPosY = 100;

public:

/**
 * Window is the rendering window where all drawable objects are drawn.
 *
 * Note that the default clear-color is <code>Color.White</code> and the
 * default VerticalSync is <code>Window.VerticalSync.Disable</code>, which means the Applications runs with full FPS.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Window {
    /**
     * The Window syncronisation mode.
     * Default VerticalSyncronisation is <code>VerticalSync.Enable</code>.
     */
    enum VerticalSync : byte {
        Enable  = 1,    /// VerticalSync is enabled
        Disable = 0,    /// VerticalSync is disabled
        LateSwapTearing = -1    /// For late swap tearing
    }

    /**
     * The specific window styles
     */
    enum Style {
        Default = Shown, /// Default is Shown
        Fullscreen = SDL_WINDOW_FULLSCREEN, /// Window is fullscreened
        Desktop = SDL_WINDOW_FULLSCREEN_DESKTOP,    /// Window has Desktop Fullscreen
        Shown = SDL_WINDOW_SHOWN,   /// Show the Window immediately
        Hidden = SDL_WINDOW_HIDDEN, /// Hide the Window immediately
        Borderless = SDL_WINDOW_BORDERLESS, /// The Window has no border
        Resizeable = SDL_WINDOW_RESIZABLE,  /// Window is resizeable
        Maximized = SDL_WINDOW_MAXIMIZED,   /// Maximize the Window immediately
        Minimized = SDL_WINDOW_MINIMIZED,   /// Minimize the Window immediately
        InputGrabbed = SDL_WINDOW_INPUT_GRABBED,    /// Grab the input inside the window
        InputFocus = SDL_WINDOW_INPUT_FOCUS,    /// The Window has input (keyboard) focus
        MouseFocus = SDL_WINDOW_MOUSE_FOCUS,    /// The Window has mouse focus
        MouseCapture = SDL_WINDOW_MOUSE_CAPTURE, /// window has mouse captured (unrelated to InputGrabbed)
        AllowHighDPI = SDL_WINDOW_ALLOW_HIGHDPI, /// Window should be created in high-DPI mode if supported
    }

private:
    SDL_Window* _window;
    SDL_GLContext _glContext;

    static ushort _count = 0;

public:
    /**
     * The current projection Matrix
     *
     * Note: This is intended for advanced users only.
     *
     * See: Matrix4x4
     */
    Matrix4x4 projection;

    /**
     * CTor
     * Position of the Window is default 100x, 100y and the VerticalSync is disabled
     */
    this(uint width, uint height, string title, uint style = Style.Default, const GLContextSettings gl = GLContextSettings.init) {
        this(Rect(DefPosX, DefPosY, width, height), title, style, gl);
    }

    /**
    * CTor
    * Position is at 100x, 100y and the VerticalSync is enabled, if mode.refreshRate > 0
    */
    this(const DisplayMode mode, string title, uint style = Style.Default, const GLContextSettings gl = GLContextSettings.init) {
        this(Rect(DefPosX, DefPosY, mode.width, mode.height), title, style, gl);

        if (mode.refreshRate > 0)
            this.setVerticalSync(VerticalSync.Enable);
    }

    /**
     * CTor
     * Position is specifiable and the VerticalSync is disabled
     */
    this(const Rect view, string title, uint style = Style.Default, const GLContextSettings gl = GLContextSettings.init) {
        if (_count == 0)
            _initSDL();

        _initGLAttr(gl);
        
        _window = SDL_CreateWindow(
            toStringz(title),
            view.x, view.y,
            view.width, view.height,
            style | SDL_WINDOW_OPENGL
        );
        assert(_window, "SDL_Window could not be created.");

        _glContext = SDL_GL_CreateContext(_window);
        assert(_glContext, "SDL_GLContext could not be created.");
        assert(SDL_GL_MakeCurrent(_window, _glContext) == 0);

        _initGL();

        const Rect rect = Rect(0, 0, view.width, view.height);

        this.projection.ortho(rect);
        this.loadProjection();

        glViewport(rect.x, rect.y, rect.width, rect.height);

        this.setClearColor(Color4b.White);
        this.setVerticalSync(VerticalSync.Disable);

        _count++;
    }

    /**
     * Postblit is disabled
     */
    @disable
    this(this);
    
    /**
     * DTor
     */
    @nogc
    ~this() nothrow {
        SDL_GL_DeleteContext(_glContext);  
        SDL_DestroyWindow(_window);

        _count--;
    }

    /**
     * Load the projection Matrix, so that any change / transformation of the Matrix will now be visible
     */
    @nogc
    void loadProjection() const nothrow {
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(this.projection.getValues().ptr);
        glMatrixMode(GL_MODELVIEW);
    }

    /**
     * Set the color which this windows use to clear the buffer.
     * This is also the background color of the window.
     */
    @nogc
    void setClearColor(const Color4b col) const nothrow {
        immutable float[4] rgba = Color4f(col).asRGBA();
        glClearColor(rgba[0], rgba[1], rgba[2], rgba[3]);
    }

    /**
     * Clears the screen with the color you specified in setClearColor
     */
    @nogc
    void clear() const nothrow {
        glClear(GL_COLOR_BUFFER_BIT);
    }

    /**
     * Set the VerticalSyncronisation mode of this window.
     * Default VerticalSyncronisation is <code>VerticalSync.Enable</code>.
     *
     * See: VerticalSync enum
     *
     * Returns if the sync mode is supported.
     */
    @nogc
    bool setVerticalSync(VerticalSync sync) const nothrow {
        return SDL_GL_SetSwapInterval(sync) == 0;
    }

    /**
     * Returns the current syncronisation mode.
     *
     * See: VerticalSync enum
     */
    @nogc
    VerticalSync getVerticalSync() nothrow {
        return cast(VerticalSync) SDL_GL_GetSwapInterval();
    }

    /**
     * Capture the pixel data of the current window and
     * returns a Surface with this pixel data.
     * You can also alter the format of the pixel data.
     * Default is <code>Texture.Format.BGRA</code>.
     * This method is predestinated for screenshots.
     * 
     * Example:
     * ---
     * Window wnd = ...
     * ...
     * wnd.capture().saveToFile("samples/img/screenshot.png");
     * ---
     */
    @nogc
    Surface capture(Texture.Format fmt = Texture.Format.BGRA) nothrow {
        const Size size = this.getSize();
        Surface my_capture = Surface(size.width, size.height, 32, Masks.Zero);

        glReadBuffer(GL_FRONT);
        glReadPixels(0, 0, size.width, size.height, fmt, GL_UNSIGNED_BYTE, my_capture.pixels);
        
        immutable uint lineWidth = size.width * 4;
        immutable uint hlw = size.height * lineWidth;

        void[] tmpLine = make!(void[])(lineWidth);
        scope(exit) unmake(tmpLine);

        // Flip it
        for (uint i = 0; i < size.height / 2; ++i) {
            immutable uint tmpIdx1 = i * lineWidth;
            immutable uint tmpIdx2 = (i + 1) * lineWidth;
            
            immutable uint switchIdx1 = hlw - tmpIdx2;
            immutable uint switchIdx2 = hlw - tmpIdx1;
            
            tmpLine[0 .. lineWidth] = my_capture.pixels[tmpIdx1 .. tmpIdx2];
            void[] switchLine = my_capture.pixels[switchIdx1 .. switchIdx2];
            
            my_capture.pixels[tmpIdx1 .. tmpIdx2] = switchLine[];
            my_capture.pixels[switchIdx1 .. switchIdx2] = tmpLine[0 .. lineWidth];
        }
        
        return my_capture;
    }

    /**
     * Restore the size and position, if the Window is minimized or maximized.
     */
    @nogc
    void restore() nothrow {
        SDL_RestoreWindow(_window);
    }

    /**
     * Raises the Window above other Windows and set the input focus.
     */
    @nogc
    void raise() nothrow {
        SDL_RaiseWindow(_window);
    }

    /**
     *Make the window as large as possible.
     */
    @nogc
    void maximize() nothrow {
        SDL_MaximizeWindow(_window);
    }

    /**
     * Minimize the Window to an iconic representation.
     */
    @nogc
    void minimize() nothrow {
        SDL_MinimizeWindow(_window);
    }

    /**
     * Set the border state of the Window.
     */
    @nogc
    void setBorder(bool enable) nothrow {
        SDL_SetWindowBordered(_window, enable ? SDL_TRUE : SDL_FALSE);
    }

    /**
     * Returns if the keyboard focus is on this window.
     */
    @nogc
    bool hasKeyboardFocus() const nothrow {
        return SDL_GetKeyboardFocus() == _window;
    }
    
    /**
     * Returns if the mouse focus is on this window.
     */
    @nogc
    bool hasMouseFocus() const nothrow {
        return SDL_GetMouseFocus() == _window;
    }

    /**
     * Set a new position to this window
     */
    @nogc
    void setPosition(int x, int y) nothrow {
        SDL_SetWindowPosition(_window, x, y);
    }
    
    /**
     * Set a new position to this window
     */
    @nogc
    void setPosition(const Vector2i vec) nothrow {
        this.setPosition(vec.x, vec.y);
    }
    
    /**
     * Returns the current position of the window.
     */
    @nogc
    Vector2i getPosition() nothrow {
        int x, y;
        SDL_GetWindowPosition(_window, &x, &y);
        
        return Vector2i(x, y);
    }

    /**
     * Set a new size to this window
     */
    @nogc
    void setSize(uint width, uint height) nothrow {
        SDL_SetWindowSize(_window, width, height);
    }

    /**
     * Set a new size to this window
     */
    @nogc
    void setSize(const Size size) nothrow {
        this.setSize(size.width, size.height);
    }
    
    /**
     * Returns the size (width and height) of the Window
     */
    @nogc
    Size getSize() nothrow {
        int w, h;
        SDL_GetWindowSize(_window, &w, &h);
        
        return Size(w, h);
    }

    /**
     * Returns the size of the underlying drawable area (e.g. for use with glViewport).
     * This method may only differ from getSize if you are using High-DPI.
     */
    @nogc
    Size getDrawableSize() nothrow {
        int w, h;
        SDL_GL_GetDrawableSize(_window, &w, &h);

        return Size(w, h);
    }
    
    /**
     * Set the minimum Size for the Window
     */
    @nogc
    void setMinimumSize(uint width, uint height) nothrow {
        SDL_SetWindowMinimumSize(_window, width, height);
    }

    /**
     * Set the minimum Size for the Window
     */
    @nogc
    void setMinimumSize(const Size size) nothrow {
        this.setMinimumSize(size.width, size.height);
    }

    /**
     * Returns the minimum Size of the Window
     */
    @nogc
    Size getMinimumSize() nothrow {
        int w, h;
        SDL_GetWindowMinimumSize(_window, &w, &h);

        return Size(w, h);
    }

    /**
     * Set the maximum Size of the Window
     */
    @nogc
    void setMaximumSize(uint width, uint height) nothrow {
        SDL_SetWindowMaximumSize(_window, width, height);
    }

    /**
     * Set the maximum Size of the Window
     */
    @nogc
    void setMaximumSize(const Size size) nothrow {
        this.setMaximumSize(size.width, size.height);
    }

    /**
     * Returns the maximum Size of the Window
     */
    @nogc
    Size getMaximumSize() nothrow {
        int w, h;
        SDL_GetWindowMaximumSize(_window, &w, &h);

        return Size(w, h);
    }

    /**
     * Returns the Window Style.
     * 
     * See: Style enum
     */
    @nogc
    uint getStyle() nothrow {
        return SDL_GetWindowFlags(_window);
    }

    /**
     * Update the parameter event and set the data of the current event in it.
     * 
     * Returns: true, if there was a valid event and false if not.
     */
    @nogc
    bool poll(Event* event) const nothrow {
        assert(event, "No place to store the event");

        SDL_Event sdl_event;
        SDL_PollEvent(&sdl_event);

        return _translate(event, sdl_event);
    }

    /**
     * Waits for the given Event.
     * If the seconds parameter is greater then -1, it waits maximal timeout seconds.
     */
    @nogc
    bool wait(Event* event, int timeout = -1) const nothrow {
        SDL_Event sdl_event;
        int result;
        if (timeout < 0)
            result = SDL_WaitEvent(&sdl_event);
        else
            result = SDL_WaitEventTimeout(&sdl_event, timeout);
        
        if (result > 0)
            return _translate(event, sdl_event);
        
        return false; 
    }

    /**
     * Push an event of the given type inside the Event queue.
     * 
     * Returns: if the push was successfull or not.
     */
    @nogc
    bool push(Event.Type type) const nothrow {
        SDL_Event sdl_event;
        sdl_event.type = type;
        
        return SDL_PushEvent(&sdl_event) == 1;
    }

    /**
     * Returns: if inside of the Event Queue is an Event of the given type.
     */
    @nogc
    bool hasEvent(Event.Type type) const nothrow {
        return SDL_HasEvent(type) == SDL_TRUE;
    }

    /**
     * Returns: if the current Event queue has the Quit Event.
     */
    @nogc
    bool hasQuitEvent() const nothrow {
        return SDL_QuitRequested();
    }

    /**
     * Draw a drawable object on screen
     */
    @nogc
    void draw(Drawable d) const nothrow {
        if (d)
            d.draw(this);
    }

    /**
     * Make all changes visible on screen
     */
    @nogc
    void display() nothrow {
        if (_count > 1)
            SDL_GL_MakeCurrent(_window, _glContext);
        SDL_GL_SwapWindow(_window);
    }

    /**
     * Returns the current title of the window.
     */
    @nogc
    string getTitle() nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_GetWindowTitle(_window);
        if (!p)
            return null;

        return cast(immutable) p[0 .. strlen(p)];
    }
    
    /**
     * Set a new title to this window
     *
     * Returns: the old title
     */
    @nogc
    string setTitle(string title) nothrow {
        string old_title = this.getTitle();
        SDL_SetWindowTitle(_window, toStringz(title));
        
        return old_title;
    }

    /**
     * Set an icon for this window.
     */
    @nogc
    void setIcon(ref Surface srfc) {
        srfc.setAsIconOf(_window);
    }

    /**
     * Returns the index of the display which contains the center of the window
     *
     * Note: If something went wrong (e.g. your Window is invalid), a negative value is returned
     */
    @nogc
    int getDisplayIndex() nothrow {
        return SDL_GetWindowDisplayIndex(_window);
    }

    /**
     * Set the DisplayMode when the Window is visible at fullscreen.
     */
    @nogc
    void setDisplayMode(const DisplayMode mode) nothrow {
        SDL_DisplayMode sdl_mode = void;
        immutable int result = SDL_SetWindowDisplayMode(_window, _transfer(mode, sdl_mode));
        if (result != 0)
            print_fmt("Could not set the display mode: %s\n", SDL_GetError());
    }

    /**
     * Returns the DisplayMode when the Window is visible at fullscreen.
     */
    @nogc
    DisplayMode getDisplayMode() nothrow {
        SDL_DisplayMode mode = void;
        immutable int result = SDL_GetWindowDisplayMode(_window, &mode);
        if (result != 0)
            print_fmt("Could not get the display mode: %s\n", SDL_GetError());

        return DisplayMode(mode.w, mode.h, cast(ubyte) mode.refresh_rate);
    }

    enum uint FullScreenMask = Style.Fullscreen | Style.Desktop;

    /**
     * Use this function to (re)set Window's fullscreen states.
     *
     * style may be Style.Fullscreen for "real" fullscreen with a display mode change
     * or Style.Desktop for "fake" fullscreen that takes the size of the desktop
     * Use 0 for windowed mode.
     *
     * if adaptProjection is true (which is the default) the projection will automatically adapted.
     * set it to false if you want to specify your own projection afterwards.
     */
    @nogc
    bool setFullscreen(uint style, bool adaptProjection = true) nothrow {
        if (style & this.getStyle())
            return true;
        
        if (style & FullScreenMask || style == 0) {
            immutable int result = SDL_SetWindowFullscreen(this._window, style);
            if (result != 0) {
                print_fmt("Could not enable fullscreen: %s\n", SDL_GetError());
                return false;
            } else if (adaptProjection) {
                const Size size = this.getSize();

                this.projection.loadIdentity().ortho(Rect(0, 0, size.width, size.height));
                this.loadProjection();

                glViewport(0, 0, size.width, size.height);
            }

            return true;
        }

        return false;
    }
    
    /**
     * Toggle between Fullscreen and windowed mode, depending on the current state.
     *
     * if adaptProjection is true (which is the default) the projection will automatically adapted.
     * set it to false if you want to specify your own projection afterwards.
     */
    @nogc
    void toggleFullscreen(bool adaptProjection = true) nothrow {
        if (this.getStyle() & FullScreenMask)
            this.setFullscreen(0, adaptProjection);
        else
            this.setFullscreen(Style.Fullscreen, adaptProjection);
    }
    
    /**
     * Returns, if this Window is in fullscreen mode.
     */
    @nogc
    bool isFullscreen() nothrow {
        return (this.getStyle() & FullScreenMask) != 0;
    }

package(Dgame):
    @nogc
    void draw(Geometry geo, const Texture* texture, const Vertex[] vertices) const nothrow {
        if (vertices.length == 0)
            return;

        if (texture)
            texture.bind();

        glVertexPointer(2, GL_FLOAT, Vertex.sizeof, &vertices[0].position.x);
        glColorPointer(4, GL_FLOAT, Vertex.sizeof, &vertices[0].color.red);
        glTexCoordPointer(2, GL_FLOAT, Vertex.sizeof, &vertices[0].texCoord.x);

        // prevent 64 bit bug, because *.length is size_t and therefore on 64 bit platforms ulong
        glDrawArrays(geo, 0, cast(uint) vertices.length);

        if (texture)
            texture.unbind();
    }

    @nogc
    void draw(Geometry geo, ref const Matrix4x4 mat, const Texture* texture, const Vertex[] vertices) const nothrow {
        glPushMatrix();
        scope(exit) glPopMatrix();

        glLoadMatrixf(mat.getValues().ptr);

        this.draw(geo, texture, vertices);
    }
}