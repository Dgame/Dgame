module Dgame.Audio.VorbisFile;

private {
	debug import std.stdio : writefln;
	
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
		scope(failure) throw new Exception("It seems that is not a valid ogg/vorbis file.");
		
		_sFile.filename = filename;
		
		FILE* fp = fopen(filename.ptr, "rb");
		fread(&_sFile.type, char.sizeof, 4, fp);
		
		if (_sFile.type != "OggS")
			throw new Exception("Missing OggS");
		
		fseek(fp, 0, SEEK_SET); // Set to the file beginning
		
		OggVorbis_File oggFile;
		
		if (ov_open(fp, &oggFile, null, 0) < 0)
			throw new Exception(filename ~ " is no valid Vorbis file.");
		
		// Get some information about the OGG file
		vorbis_info* pInfo = ov_info(&oggFile, -1);
		
		_sFile.rate  = pInfo.rate;
		_sFile.bits  = 16;
		_sFile.bytes = 2;
		_sFile.dataSize = cast(uint) ov_pcm_total(&oggFile, -1) * _sFile.bytes * pInfo.channels;
		_sFile.channels = pInfo.channels;
		debug writefln("Allocate %d memory for Vorbis.", _sFile.dataSize);
		_sFile.buffer = new byte[_sFile.dataSize];
		
		uint current = 0;
		int endian   = 0; // 0 for Little-Endian, 1 for Big-Endian
		int bitStream;
		
		long bytes;
		while (current < _sFile.dataSize) { // because it may take several requests to fill our buffer
			bytes = ov_read(&oggFile,
			                _sFile.buffer[current .. $].ptr,
			_sFile.dataSize - current, endian, 2, 1, &bitStream);
			
			current += bytes;
		}
		
		ov_clear(&oggFile);
		
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
	 * Returns the music type. In this case: Ogg.
	 */
	override MusicType getType() const pure nothrow {
		return MusicType.Ogg;
	}
}