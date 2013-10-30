module Dgame.Audio.Internal.core;

package {
	import derelict.openal.al;
	
	import derelict.ogg.ogg;
	import derelict.ogg.vorbis;
	import derelict.ogg.vorbisfile;
}

private struct AL {
private:
	ALCdevice* device;
	ALCcontext* context;
}

private {
	debug import std.stdio : writeln;
	
	AL _myAl = void;

	void _alError(string msg) {
		debug switch (alcGetError(_myAl.device)) {
			case ALC_INVALID_DEVICE:
				writeln("Invalid device");
				break;
			case ALC_INVALID_CONTEXT:
				writeln("Invalid context");
				break;
			case ALC_INVALID_ENUM:
				writeln("Invalid enum");
				break;
			case ALC_INVALID_VALUE:
				writeln("Invalid value");
				break;
			case ALC_OUT_OF_MEMORY:
				writeln("Out of memory");
				break;
			case ALC_NO_ERROR:
				writeln("No error");
				break;
			default: break;
		}

		throw new Exception(msg);
	}
}

static this() {
	// Init openAL
	debug writeln("init openAL");
	
	DerelictAL.load();
	DerelictOgg.load();
	DerelictVorbis.load();
	DerelictVorbisFile.load();
	
	_myAl.device = alcOpenDevice(null);
	if (_myAl.device is null)
		_alError("Device is null");
	
	_myAl.context = alcCreateContext(_myAl.device, null);
	if (_myAl.context is null)
		_alError("Context is null.");
	
	alcMakeContextCurrent(_myAl.context);
}

static ~this() {
	alcMakeContextCurrent(null);
	alcDestroyContext(_myAl.context);
	alcCloseDevice(_myAl.device);
	
	DerelictVorbis.unload();
	DerelictVorbisFile.unload();
	DerelictOgg.unload();
	DerelictAL.unload();
}

