module Dgame.Audio.WaveFile;

private import Dgame.Audio.SoundFile;

/**
 * A Wave implementation of BaseSoundFile
 * Open a wave file and store the attributes from it's headers.
 *
 * Author: rschuett
 */
class WaveFile : BaseSoundFile {
protected:
	override void _read(string filename) {
		scope(failure) throw new Exception("It seems that is not a valid wave file.");
		
		_sFile.filename = filename;
		
		FILE* fp = fopen(filename.ptr, "rb");
		
		char[4] buf;
		fread(&buf, char.sizeof, 4, fp);
		if (buf != "RIFF")
			throw new Exception("No Riff");
		
		fread(&buf, uint.sizeof, 1, fp);
		fread(&_sFile.type, char.sizeof, 4, fp);
		
		if (_sFile.type != "WAVE")
			throw new Exception("No WAVE");
		
		fread(&buf, char.sizeof, 4, fp);
		if (buf[0 .. 3] != "fmt")
			throw new Exception("No fmt");
		
		uint chunkSize;
		uint formatType;
		uint avgBytesPerSec;
		
		fread(&chunkSize, uint.sizeof, 1, fp);
		fread(&formatType, short.sizeof, 1, fp);
		fread(&_sFile.channels, short.sizeof, 1, fp);
		fread(&_sFile.rate, uint.sizeof, 1, fp);
		fread(&avgBytesPerSec, uint.sizeof, 1, fp);
		fread(&_sFile.bytes, short.sizeof, 1, fp);
		fread(&_sFile.bits, short.sizeof, 1, fp);
		
		fread(&buf, char.sizeof, 4, fp);
		if (buf != "data")
			throw new Exception("Missing DATA");
		
		fread(&_sFile.dataSize, uint.sizeof, 1, fp);
		
		_sFile.buffer = new byte[_sFile.dataSize];
		
		assert(_sFile.buffer !is null);
		fread(_sFile.buffer.ptr, byte.sizeof, _sFile.dataSize, fp);
		assert(_sFile.buffer !is null);
		
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