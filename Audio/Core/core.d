module Dgame.Audio.Core.core;

package {
	import derelict3.openal.al;
	
	import derelict3.ogg.ogg;
	import derelict3.ogg.vorbis;
	import derelict3.ogg.vorbisfile;
}

private {
	import std.string : format;
	import std.stdio;
	
	ALCdevice*  my_aldevice;
	ALCcontext* my_alcontext;
}

static this() {
	// Init openAL
	writeln("init openAL");
	DerelictAL.load();
	DerelictOgg.load();
	DerelictVorbis.load();
	DerelictVorbisFile.load();
	
	my_aldevice = alcOpenDevice(null);
	if (!my_aldevice) {
		throw new Exception("Device is null.");
	}
	
	my_alcontext = alcCreateContext(my_aldevice, null);
	if (!my_alcontext) {
		throw new Exception("Context is null.");
	}
	
	alcMakeContextCurrent(my_alcontext);
}

static ~this() {
	alcMakeContextCurrent(null);
	alcDestroyContext(my_alcontext);
	alcCloseDevice(my_aldevice);
	
	DerelictVorbis.unload();
	DerelictVorbisFile.unload();
	DerelictOgg.unload();
	DerelictAL.unload();
}

