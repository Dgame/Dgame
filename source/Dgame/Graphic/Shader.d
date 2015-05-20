module Dgame.Graphic.Shader;

private:

import derelict.opengl3.gl;
import Dgame.Internal.m3;

import Dgame.Internal.Error;

@nogc
char[] file_get_contents(string filename) nothrow {
    import Dgame.Internal.d2c : toStringz;
    import core.stdc.stdio;

    FILE* f = fopen(toStringz(filename), "rb");
    if (f) {
        scope(exit) fclose(f);

        fseek(f, 0, SEEK_END);
        immutable size_t length = ftell(f);
        fseek(f, 0, SEEK_SET);

        char[] buffer = make!(char[])(length * char.sizeof);
        if (buffer.length)
            fread(buffer.ptr, char.sizeof, length, f);

        return buffer;
    }

    return null;
}

public:

/**
 * The Shader struct manages a OpenGL Shader instance
 * The Shader can be loaded and compiled. But to use it, you must pass the Shader to the Program (see below).
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct Shader {
private:
    uint _shader;

public:
    /**
     * The supported Shader-Types
     */
    enum Type {
        Vertex = GL_VERTEX_SHADER, /// To use as a Vertex-Shader
        Geometry = GL_GEOMETRY_SHADER, /// To use as a Geometry-Shader
        Fragment = GL_FRAGMENT_SHADER, /// To use as a Fragment-Shader
    }

    /**
     * CTor
     */
    @nogc
    this(Type type, string filename = null) nothrow {
        glCreateShader(type);
        if (filename)
            this.loadFromFile(filename);
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
        glDeleteShader(_shader);
    }

    /**
     * Returns the internal Shader ID
     */
    @nogc
    @property
    uint ID() const pure nothrow {
        return _shader;
    }

    /**
     * Load the Shader-Source from a file.
     *
     * Note: The Shader will not be automatically compiled, use compile to do that by yourself
     */
    @nogc
    void loadFromFile(string filename) const nothrow {
        char[] buffer = file_get_contents(filename);
        scope(exit) unmake(buffer);

        this.loadFrom(buffer);
    }

    /**
     * Load the Shader-Source from a slice
     *
     * Note: The Shader will not be automatically compiled, use compile to do that by yourself
     */
    @nogc
    void loadFrom(char[] content) const nothrow {
        const char* ptr = content.ptr;
        glShaderSource(_shader, 1, &ptr, null);
    }

    /**
     * Compiles the Shader
     *
     * Returns if the compilation was successful
     */
    @nogc
    bool compile() const nothrow {
        glCompileShader(_shader);

        int isCompiled = 0;
        glGetShaderiv(_shader, GL_COMPILE_STATUS, &isCompiled);
        if (isCompiled == GL_FALSE) {
            int maxLength = 0;
            glGetShaderiv(_shader, GL_INFO_LOG_LENGTH, &maxLength);
            
            //The maxLength includes the NULL character
            char[] infoLog = make!(char[])(maxLength);
            scope(exit) unmake(infoLog);

            glGetShaderInfoLog(_shader, maxLength, &maxLength, infoLog.ptr);
            
            print_fmt("Shader could not be compiled: %s\n", infoLog.ptr);

            return false;
        }

        return true;
    }
}