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
module Dgame.Internal.core;

private {
	import std.string : format;
	
	import derelict.opengl3.gl;
}

/**
 * Current Version
 */
enum DgVersion : ubyte {
	Major = 0,
	Minor = 3,
	PatchLevel = 2
}

/**
 * Returns a readable version number.
 */
string getDgVersion() {
	return format("%d.%d.%d", DgVersion.Major, DgVersion.Minor, DgVersion.PatchLevel);
}

/**
 *
 */
void glCheck(lazy void Func, string filename = __FILE__, size_t line_number = __LINE__) {
	Func();
	scope(exit) GLCheckError(filename, line_number);
}

/**
 *
 */
void GLCheckError(string filename, size_t line_number) {
	// Get the last error
	GLenum ErrorCode = glGetError();
	
	if (ErrorCode != GL_NO_ERROR) {
		string Error = "unknown error";
		string Desc  = "no description";
		
		// Decode the error code
		switch (ErrorCode) {
			case GL_INVALID_ENUM:
				Error = "GL_INVALID_ENUM";
				Desc  = "an unacceptable value has been specified for an enumerated argument";
				break;
				
			case GL_INVALID_VALUE:
				Error = "GL_INVALID_VALUE";
				Desc  = "a numeric argument is out of range";
				break;
				
			case GL_INVALID_OPERATION:
				Error = "GL_INVALID_OPERATION";
				Desc  = "the specified operation is not allowed in the current state";
				break;
				
			case GL_STACK_OVERFLOW:
				Error = "GL_STACK_OVERFLOW";
				Desc  = "this command would cause a stack overflow";
				break;
				
			case GL_STACK_UNDERFLOW:
				Error = "GL_STACK_UNDERFLOW";
				Desc  = "this command would cause a stack underflow";
				break;
				
			case GL_OUT_OF_MEMORY:
				Error = "GL_OUT_OF_MEMORY";
				Desc  = "there is not enough memory left to execute the command";
				break;
				/*
				 case GL_INVALID_FRAMEBUFFER_OPERATION:
				 Error = "GL_INVALID_FRAMEBUFFER_OPERATION_EXT";
				 Desc  = "the object bound to FRAMEBUFFER_BINDING_EXT is not 
				 \"framebuffer complete\"";
				 break;
				 */
			default: break;
		}
		
		throw new Exception(.format("An internal OpenGL call failed: %s -> %s in file %s on line %d",
		                            Error, Desc, filename, line_number));
	}
}