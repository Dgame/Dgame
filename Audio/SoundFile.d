module Dgame.Audio.SoundFile;

private import std.file : exists;
package import core.stdc.stdio : FILE, fopen, fseek, fread, fclose, SEEK_SET;

/**
 * A helper struct for reading from a sound file.
 */
struct SoundFile {
public:
	char[4] type;		/** Sound type. e.g. 'wave', 'ogg' */
	string filename;	/** Sound filename */
	byte[] buffer;		/** Buffer */
	
	uint rate;			/** The sound rate */
	uint dataSize;		/** Total data size */
	
	int channels;	/** Number of channels */
	ubyte bits;		/** Number of bits */
	ubyte bytes;		/** Number of bytes */
	
	@disable
	this(this);
}

/**
 * All supported music types.
 */
enum MusicType : ubyte {
	None,	/** For invalid types */
	Wave,	/** Wave files */
	Mod,	/** Mod  -> TODO */
	Midi,	/** Midi -> TODO */
	Ogg,	/** Ogg or vorbis files. */
	Mp3		/** Mp3  -> TODO */
}

/**
 * The abstract basic class for sound file loading.
 *
 * Author: rschuett
 */
abstract class BaseSoundFile {
protected:
	SoundFile _sFile;
	
	abstract void _read(string filename);
	
public:
	/**
	 * CTor
	 */
	this(string filename) {
		if (!exists(filename)) {
			throw new Exception("File " ~ filename ~ " does not exists.");
		}
		
		this._read(filename);
	}
	
	/**
	 * Free/delete the memory buffer.
	 */
	final void freeBuffer() {
		.destroy(_sFile.buffer);
	}
	
	/**
	 * Returns the SoundFile struct.
	 *
	 * See: SoundFile struct
	 */
	final ref const(SoundFile) getData() const pure nothrow {
		return this._sFile;
	}
	
	/**
	 * Returns the filename of the loaded sound file.
	 */
	final string getFilename() const pure nothrow {
		return this._sFile.filename;
	}
	
	/**
	 * Returns the length of the sound in seconds.
	 */
	float getLength() const pure nothrow {
		return (8 * _sFile.dataSize) / (_sFile.bits * _sFile.rate * _sFile.channels);
	}
	
	/**
	 * abstract getType method.
	 */
	abstract MusicType getType() const pure nothrow;
	
	/**
	 * toString
	 */
	override string toString() const pure nothrow {
		return this.getFilename();
	}
}
