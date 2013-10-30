module Dgame.Audio.WaveFile;

private {
	debug import std.stdio : writefln;

	import derelict.openal.al;

	import Dgame.Audio.SoundFile;
}

/**
 * A Wave implementation of BaseSoundFile
 * Open a wave file and store the attributes from it's headers.
 *
 * Author: rschuett
 */
class WaveFile : BaseSoundFile {
protected:
	override void _read(string filename) {
		//scope(failure) throw new Exception("It seems that is not a valid wave file: " ~ to!string(alGetError()));
		
		super._sFile.filename = filename;
		
		FILE* fp = fopen(filename.ptr, "rb".ptr);
		
		char[4] buf;
		fread(&buf, char.sizeof, 4, fp);
		if (buf != "RIFF")
			throw new Exception("No Riff");
		
		fread(&buf, uint.sizeof, 1, fp);
		fread(&super._sFile.type, char.sizeof, 4, fp);
		
		if (super._sFile.type != "WAVE")
			throw new Exception("No WAVE");
		
		fread(&buf, char.sizeof, 4, fp);
		if (buf[0 .. 3] != "fmt")
			throw new Exception("No fmt");
		
		uint chunkSize;
		uint formatType;
		uint avgBytesPerSec;
		
		fread(&chunkSize, uint.sizeof, 1, fp);
		fread(&formatType, short.sizeof, 1, fp);
		fread(&super._sFile.channels, short.sizeof, 1, fp);
		fread(&super._sFile.rate, uint.sizeof, 1, fp);
		fread(&avgBytesPerSec, uint.sizeof, 1, fp);
		fread(&super._sFile.bytes, short.sizeof, 1, fp);
		fread(&super._sFile.bits, short.sizeof, 1, fp);
		
		fread(&buf, char.sizeof, 4, fp);
		if (buf != "data")
			throw new Exception("Missing DATA");
		
		fread(&super._sFile.dataSize, uint.sizeof, 1, fp);
		debug writefln("Allocate %d memory for Wave.", super._sFile.dataSize);
		super._sFile.buffer = new byte[super._sFile.dataSize];
		
		debug assert(super._sFile.buffer !is null);
		fread(super._sFile.buffer.ptr, byte.sizeof, super._sFile.dataSize, fp);
		debug assert(super._sFile.buffer !is null);
		
		fclose(fp);
		fp = null;
	}
	
public:
	/**
	 * CTor
	 */
	this(string filename) {
		super(filename);
	}
	
	/**
	 * Returns the music type. In this case: wave.
	 */
	override MusicType getType() const pure nothrow {
		return MusicType.Wave;
	}
}