module Dgame.Audio.Core.core;

package {
	import derelict.openal.al;
	
	import derelict.ogg.ogg;
	import derelict.ogg.vorbis;
	import derelict.ogg.vorbisfile;
}

private {
	debug import std.stdio;
	import std.string : format;
	
	ALCdevice*  my_aldevice;
	ALCcontext* my_alcontext;
}

static this() {
	// Init openAL
	debug writeln("init openAL");
	
	DerelictAL.load();
	DerelictOgg.load();
	DerelictVorbis.load();
	DerelictVorbisFile.load();
	
	my_aldevice = alcOpenDevice(null);
	if (!my_aldevice)
		throw new Exception("Device is null.");
	
	my_alcontext = alcCreateContext(my_aldevice, null);
	if (!my_alcontext)
		throw new Exception("Context is null.");
	
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

