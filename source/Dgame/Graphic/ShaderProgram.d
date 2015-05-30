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
module Dgame.Graphic.ShaderProgram;

import derelict.opengl3.gl;

import Dgame.Graphic.Color;
import Dgame.Graphic.Shader;

import Dgame.Math.Vector2;
import Dgame.Math.Vector3;
import Dgame.Math.Matrix4x4;

import Dgame.Internal.m3;
import Dgame.Internal.d2c;
import Dgame.Internal.Error;

/**
 * The Program struct manages a OpenGL-Shader-Program. Multiple Shaders can be attached to it.
 * The Program links the attached Shaders and then they can be used.
 *
 * Author: Randy Schuett (rswhite4@googlemail.com)
 */
struct ShaderProgram {
private:
    uint _program;

    @nogc
    void _init() nothrow {
        if (_program == 0)
            _program = glCreateProgram();
    }

public:
    /**
     * CTor
     * Takes multiple Shader instances and links them together
     *
     * Note: The shaders must be already compiled.
     */
    @nogc
    this(const Shader[] shaders...) nothrow {
        this.link(shaders);
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
        glDeleteProgram(_program);
    }

    /**
     * Returns the internal Program ID
     */
    @nogc
    @property
    uint ID() const pure nothrow {
        return _program;
    }

    /**
     * Links multiple Shaders together.
     *
     * Note: The shaders must be already compiled.
     */
    @nogc
    bool link(const Shader[] shaders...) nothrow {
        _init();

        // Attach the shaders
        foreach (ref const Shader shader; shaders) {
            glAttachShader(_program, shader.id);
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
            glDetachShader(_program, shader.id);
        }

        return true;
    }

    /**
     * Bind and use the current program
     */
    @nogc
    void bind() const nothrow {
        glUseProgram(_program);
    }

    /**
     * Unbind the current program. It is no longer used.
     */
    @nogc
    void unbind() const nothrow {
        glUseProgram(0);
    }

    /**
     * Set between 1 and 4 parameter and binds them to variables of the Shaders
     */
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

    /**
     * Bind a Vector2f to a specific variable name of the Shaders
     */
    @nogc
    bool setParameter(string name, const Vector2f vec) const nothrow {
        return this.setParameter(name, vec.x, vec.y);
    }

    /**
     * Bind a Vector3f to a specific variable name of the Shaders
     */
    @nogc
    bool setParameter(string name, const Vector3f vec) const nothrow {
        return this.setParameter(name, vec.x, vec.y, vec.z);
    }

    /**
     * Bind a Color4b to a specific variable name of the Shaders
     */
    @nogc
    bool setParameter(string name, const Color4b color) const nothrow {
        const Color4f col = color;
        return this.setParameter(name, col.red, col.green, col.blue, col.alpha);
    }

    /**
     * Bind a Matrix4x4 to a specific variable name of the Shaders
     */
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