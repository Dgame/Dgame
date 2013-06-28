module Dgame.Core.core;

private {
	import std.string : format;
	import std.conv : to;
	
	import derelict.opengl3.gl;
}

/**
 * Current Version
 */
enum DgVersion {
	Major = 0,
	Minor = 9,
	PatchLevel = 9
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
void glCheck(lazy void Func, string filename = __FILE__, uint line_number = __LINE__) {
	try {
		Func();
	} catch (Throwable e) {
		GLCheckError(filename, line_number);
		throw e;
	}
}

/**
 *
 */
void GLCheckError(string filename, uint line_number) {
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
		
		throw new Exception(.format("An internal OpenGL call failed: %s -> %s in File %s in Line %d",
		                            Error, Desc, filename, line_number));
	}
}