module Dgame.Graphic.Shader;

private:

import derelict.opengl3.gl;

import Dgame.Math.Vector2;
import Dgame.Math.Vector3;
import Dgame.Math.Matrix4x4;

import Dgame.Internal.m3;
import Dgame.Internal.d2c;
import Dgame.Internal.Error;

@nogc
char[] file_get_contents(string filename) nothrow {
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

struct Shader {
private:
    uint _shader;

public:
    enum Type {
        Vertex = GL_VERTEX_SHADER,
        Geometry = GL_GEOMETRY_SHADER,
        Fragment = GL_FRAGMENT_SHADER,
    }

    @nogc
    this(Type type, string filename = null) nothrow {
        glCreateShader(type);
        if (filename)
            this.loadFromFile(filename);
    }

    @disable
    this(this);

    @nogc
    ~this() nothrow {
        glDeleteShader(_shader);
    }

    @nogc
    @property
    uint ID() const pure nothrow {
        return _shader;
    }

    @nogc
    void loadFromFile(string filename) const nothrow {
        char[] buffer = file_get_contents(filename);
        scope(exit) unmake(buffer);

        this.loadFrom(buffer);
    }

    @nogc
    void loadFrom(char[] content) const nothrow {
        const char* ptr = content.ptr;
        glShaderSource(_shader, 1, &ptr, null);
    }

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

struct Program {
private:
    uint _program;

    @nogc
    void _init() nothrow {
        if (_program == 0)
            _program = glCreateProgram();
    }

public:
    @disable
    this(this);

    @nogc
    ~this() nothrow {
        glDeleteProgram(_program);
    }

    @nogc
    @property
    uint ID() const pure nothrow {
        return _program;
    }

    @nogc
    bool link(const Shader[] shaders...) nothrow {
        _init();

        // Attach the shaders
        foreach (ref const Shader shader; shaders) {
            glAttachShader(_program, shader.ID);
        }

        //Link our program
        glLinkProgram(_program);

        int isLinked = 0;
        glGetProgramiv(_program, GL_LINK_STATUS, &isLinked);
        if (isLinked == GL_FALSE) {
            int maxLength = 0;
            glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &maxLength);
            //The maxLength includes the NULL character
            char[] infoLog = make!(char[])(maxLength);
            scope(exit) unmake(infoLog);

            glGetProgramInfoLog(_program, maxLength, &maxLength, infoLog.ptr);
            //We don't need the program anymore.
            glDeleteProgram(_program);
         
            print_fmt("Shader-Program could not be compiled: %s\n", infoLog.ptr);

            return false;
        }

        // Always detach shaders after a successful link.
        foreach (ref const Shader shader; shaders) {
            glDetachShader(_program, shader.ID);
        }

        return true;
    }

    @nogc
    void bind() const nothrow {
        glUseProgram(_program);
    }

    @nogc
    void unbind() const nothrow {
        glUseProgram(0);
    }

    @nogc
    bool setParameter(string name, const float[] values...) const nothrow {
        immutable int loc = glGetUniformLocation(_program, toStringz(name));
        if (loc == -1) {
            print_fmt("No such variable %s\n", name.ptr);
            return false;
        }

        this.bind();

        switch (values.length) {
            case 1:
                glUniform1f(loc, values[0]);
            break;
            case 2:
                glUniform2f(loc, values[0], values[1]);
            break;
            case 3:
                glUniform3f(loc, values[0], values[1], values[2]);
            break;
            case 4:
                glUniform4f(loc, values[0], values[1], values[2], values[3]);
            break;
            default:
                assert(0, "Need between 1 and 4 floats");
        }

        return true;
    }

    @nogc
    bool setParameter()(string name, auto ref const Vector2f vec) const nothrow {
        return this.setParameter(name, vec.x, vec.y);
    }

    @nogc
    bool setParameter()(string name, auto ref const Vector3f vec) const nothrow {
        return this.setParameter(name, vec.x, vec.y, vec.z);
    }

    @nogc
    bool setParameter()(string name, auto ref const Color4f col) const nothrow {
        return this.setParameter(col.red, col.green, col.blue, col.alpha);
    }

    @nogc
    bool setParameter(string name, ref const Matrix4x4 mat) const nothrow {
        immutable int loc = glGetUniformLocation(_program, toStringz(name));
        if (loc == -1) {
            print_fmt("No such variable %s\n", name.ptr);
            return false;
        }

        this.bind();

        glUniformMatrix4fv(loc, 1, GL_FALSE, mat.getValues().ptr);

        return true;
    }
}