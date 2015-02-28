module Dgame.Window.Window;

private:

import derelict.sdl2.sdl;
import derelict.opengl3.gl;

static import m3.m3;

import Dgame.Graphic.Color;
import Dgame.Graphic.Drawable;
import Dgame.Graphic.Surface;
import Dgame.Graphic.Texture;

import Dgame.Math.Vertex;
import Dgame.Math.Vector2;
import Dgame.Math.Matrix4;
import Dgame.Math.Rect;
import Dgame.Math.Geometry;

import Dgame.Window.Event;

import Dgame.Window.Internal.Init;

public:

struct Window {
    /**
     * The Window syncronisation mode.
     * Default Syncronisation is <code>Sync.Enable</code>.
     */
    enum Sync : byte {
        Enable  = 1,    /** Sync is enabled */
        Disable = 0,    /** Sync is disabled */
        LateSwapTearing = -1    /** For late swap tearing */
    }

    enum Style {
        Fullscreen = SDL_WINDOW_FULLSCREEN, /** Window is fullscreened */
        Desktop = SDL_WINDOW_FULLSCREEN_DESKTOP, /** Window has Desktop Fullscreen */
        OpenGL = SDL_WINDOW_OPENGL,  /** OpenGL support */
        Shown = SDL_WINDOW_SHOWN,        /** Show the Window immediately */
        Borderless = SDL_WINDOW_BORDERLESS, /** Hide the Window immediately */
        Resizeable = SDL_WINDOW_RESIZABLE,  /** Window is resizeable */
        Maximized = SDL_WINDOW_MAXIMIZED,  /** Maximize the Window immediately */
        Minimized = SDL_WINDOW_MINIMIZED,  /** Minimize the Window immediately */
        InputGrabbed = SDL_WINDOW_INPUT_GRABBED, /** Grab the input inside the window */
        InputFocus = SDL_WINDOW_INPUT_FOCUS, /** The Window has input (keyboard) focus */
        MouseFocus = SDL_WINDOW_MOUSE_FOCUS, /** The Window has mouse focus */
        HighDPI = SDL_WINDOW_ALLOW_HIGHDPI, /** Window should be created in high-DPI mode if supported (>= SDL 2.0.1) */
        Foreign = SDL_WINDOW_FOREIGN, /** The window was created by some other framework. */
        
        Default = Shown | OpenGL | HighDPI /** Default mode is Shown | OpenGL | HighDPI */
    }

private:
    SDL_Window* _window;
    SDL_GLContext _glContext;

    Matrix4 _projection;

    static ushort _count = 0;

public:
    this(uint width, uint height, string title, uint style = Style.Default, int x = 100, int y = 100) {
        // Mac does not allow deprecated functions / constants, so we have to set the version manually to 2.1
        version (OSX) {
            if (style & Style.OpenGL) {
                SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
                SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
            }
        }

        if (style & Style.OpenGL) {
            SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
            SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, 1);
        }

        _window = SDL_CreateWindow(title.ptr, x, y, width, height, style);
        assert(_window, "SDL_Window could not be created.");

        if (style & Style.OpenGL) {
            _glContext = SDL_GL_CreateContext(_window);
            assert(_glContext, "SDL_GLContext could not be created.");
            assert(SDL_GL_MakeCurrent(_window, _glContext) == 0);
     
            if (_count == 0)
                _initGL();

            _projection.ortho(Rect(0, 0, width, height));
            this.loadProjection();

            this.setClearColor(Color4b.White);
        }

        _count++;
    }

    this(Rect rect, string title, Style style = Style.Default) {
        this(rect.width, rect.height, title, style, rect.x, rect.y);
    }

    @disable
    this(this);
    
    @nogc
    ~this() nothrow {
        SDL_GL_DeleteContext(_glContext);  
        SDL_DestroyWindow(_window);

        _count--;
    }

    ref inout(Matrix4) getProjection() inout pure nothrow {
        return _projection;
    }

    void loadProjection() const {
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(_projection.getValues().ptr);
        glMatrixMode(GL_MODELVIEW);
    }

    /**
     * Set the color with which this windows clear his buffer.
     * This is also the background color of the window.
     */
    @nogc
    void setClearColor()(auto ref const Color4b col) const nothrow {
        immutable float[4] rgba = Color4f(col).asRGBA();
        glClearColor(rgba[0], rgba[1], rgba[2], rgba[3]);
    }

    @nogc
    void clear(uint flags = GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) const nothrow {
        glClear(flags);
    }

    /**
     * Set the Syncronisation mode of this window.
     * Default Syncronisation is <code>Sync.Enable</code>.
     *
     * See: Sync enum
     *
     * Returns if the sync mode is supported.
     */
    @nogc
    bool setVerticalSync(Sync sync) const nothrow {
        assert(sync == Sync.Enable || sync == Sync.Disable, "Unknown sync mode. Sync mode must be one of Sync.Enable / Sync.Disable.");

        return SDL_GL_SetSwapInterval(sync) == 0;
    }

    /**
     * Returns the current syncronisation mode.
     *
     * See: Sync enum
     */
    @nogc
    Sync getVerticalSync() nothrow {
        return cast(Sync) SDL_GL_GetSwapInterval();
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

        Surface mycapture = Surface(size.width, size.height);
        
        glReadBuffer(GL_FRONT);
        
        ubyte* pixels = cast(ubyte*) mycapture.pixels;
        glReadPixels(0, 0, size.width, size.height, fmt, GL_UNSIGNED_BYTE, pixels);
        
        immutable uint lineWidth = size.width * 4;
        immutable uint hlw = size.height * lineWidth;

        ubyte[] tmpLine = m3.m3.make!(ubyte[])(lineWidth);
        scope(exit) m3.m3.destruct(tmpLine);

        for (uint i = 0; i < size.height / 2; ++i) {
            immutable uint tmpIdx1 = i * lineWidth;
            immutable uint tmpIdx2 = (i + 1) * lineWidth;
            
            immutable uint switchIdx1 = hlw - tmpIdx2;
            immutable uint switchIdx2 = hlw - tmpIdx1;
            
            tmpLine[0 .. lineWidth] = pixels[tmpIdx1 .. tmpIdx2];
            ubyte[] switchLine = pixels[switchIdx1 .. switchIdx2];
            
            pixels[tmpIdx1 .. tmpIdx2] = switchLine[];
            pixels[switchIdx1 .. switchIdx2] = tmpLine[0 .. lineWidth];
        }
        
        return mycapture;
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
    void setPosition()(auto ref const Vector2i vec) nothrow {
        SDL_SetWindowPosition(_window, vec.x, vec.y);
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

    @nogc
    uint getStyle() nothrow {
        return SDL_GetWindowFlags(_window);
    }

    @nogc
    bool poll(Event* event) const nothrow {
        assert(event);

        SDL_Event sdl_event;
        SDL_PollEvent(&sdl_event);

        return _translate(event, sdl_event);
    }

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

    @nogc
    bool push(Event.Type type) const nothrow {
        SDL_Event sdl_event;
        sdl_event.type = type;
        
        return SDL_PushEvent(&sdl_event) == 1;
    }

    @nogc
    void draw(Drawable d) const nothrow {
        assert(d, "Drawable is null");

        d.draw(this);
    }

    @nogc
    void draw(Geometry geo, ref const Matrix4 mat, const Texture* texture, const Vertex* vertices, uint vCount) const nothrow {
        glPushMatrix();
        scope(exit) glPopMatrix();

        glLoadMatrixf(mat.getValues().ptr);

        if (texture) {
            glEnable(GL_TEXTURE_2D);
            texture.bind();
        }

        glVertexPointer(2, GL_FLOAT, Vertex.sizeof, &vertices[0].position.x);
        glColorPointer(4, GL_FLOAT, Vertex.sizeof, &vertices[0].color.red);
        if (texture)
            glTexCoordPointer(2, GL_FLOAT, Vertex.sizeof, &vertices[0].texCoord.x);
        glDrawArrays(geo, 0, vCount);

        if (texture) {
            texture.unbind();
            //glDisable(GL_TEXTURE_2D);
        }
    }

    @nogc
    void display() nothrow {
        immutable uint style = this.getStyle();
        if (style & Style.OpenGL) {
            if (_count > 1)
                SDL_GL_MakeCurrent(_window, _glContext);
            SDL_GL_SwapWindow(_window);
        } else
            SDL_UpdateWindowSurface(_window);
    }

    /**
     * Returns the current title of the window.
     */
    @nogc
    string getTitle() nothrow {
        import core.stdc.string : strlen;

        const char* p = SDL_GetWindowTitle(_window);

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
        SDL_SetWindowTitle(_window, title.ptr);
        
        return old_title;
    }
    
    /**
     * Set a new size to this window
     */
    @nogc
    void setSize(uint width, uint height) nothrow {
        SDL_SetWindowSize(_window, width, height);
    }
    
    @nogc
    Size getSize() nothrow {
        int w, h;
        SDL_GetWindowSize(_window, &w, &h);
        
        return Size(w, h);
    }

    @nogc
    void setIcon(ref Surface srfc) {
        srfc.setAsIconOf(_window);
    }
}