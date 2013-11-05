module Dgame.Audio.VorbisFile;

private {
	debug import std.stdio : writefln;
	import std.string : toStringz;

	import derelict.ogg.ogg;
	import derelict.ogg.vorbis;
	import derelict.ogg.vorbisfile;
	import derelict.ogg.vorbisfiletypes;
	import derelict.ogg.vorbistypes;

	import Dgame.Audio.SoundFile;
}

/**
* An alias for VorbisFile
*/
alias OggFile = VorbisFile;

/**
* An Ogg/Vorbis implementation of BaseSoundFile
* Open an ogg/vorbis file and store the attributes from it's headers.
*
* Author: rschuett
*/
class VorbisFile : BaseSoundFile {
protected:
	override void _read(string filename) {
		super._filename = filename;

		OggVorbis_File oggFile = void;
		scope(exit) ov_clear(&oggFile);

		if (ov_fopen(toStringz(filename), &oggFile) < 0)
			throw new Exception(filename ~ " is no valid Vorbis file.");

		// Get some information about the OGG file
		vorbis_info* pInfo = ov_info(&oggFile, -1);

		super._sFile.rate  = pInfo.rate;
		super._sFile.bits  = 16;
		super._sFile.bytes = 2;
		super._sFile.dataSize = cast(uint) ov_pcm_total(&oggFile, -1) * super._sFile.bytes * pInfo.channels;
		super._sFile.channels = cast(ubyte) pInfo.channels;

		debug writefln("Allocate %d memory for Vorbis.", _sFile.dataSize);
		super._buffer = new byte[super._sFile.dataSize];

		uint inserted = 0;
		byte[ushort.max] tmpBuf = void;

		while (true) {
			// Read up to a buffer's worth of decoded sound data
			long bytes = ov_read(&oggFile, &tmpBuf[0], ushort.max, 0, 2, 1, null);
			if (bytes <= 0)
				break;
			// Append to end of buffer
			uint bytes_read = cast(uint) bytes;

			super._buffer[inserted .. inserted  + bytes_read] = tmpBuf[0 .. bytes_read];

			inserted += bytes;
		}
	}

public:
	/**
	* CTor
	*/
	this(string filename) {
		super(filename);
	}

	/**
	* Returns the music type. In this case: Ogg.
	*/
	override MusicType getType() const pure nothrow {
		return MusicType.Ogg;
	}
}