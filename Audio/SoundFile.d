module Dgame.Audio.SoundFile;

private import std.file : exists;
package import core.stdc.stdio : FILE, fopen, fseek, fread, fclose, SEEK_SET;

/**
 * A helper struct for reading from a sound file.
 */

struct SoundFile {
	uint rate;			/** The sound rate */
	uint dataSize;		/** Total data size */
	
	ubyte channels;	/** Number of channels */
	ubyte bits;			/** Number of bits */
	ubyte bytes;		/** Number of bytes */
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
	SoundFile _sFile = void;

	string _filename;
	byte[] _buffer;
	
	abstract void _read(string filename);
	
public:
	/**
	 * CTor
	 */
	this(string filename) {
		if (!exists(filename))
			throw new Exception("File " ~ filename ~ " does not exists.");
		
		this._read(filename);
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
	 * Returns the Sound Buffer
	 */
	final const(byte[]) getBuffer() const pure nothrow {
		return this._buffer;
	}
	
	/**
	 * Returns the filename of the loaded sound file.
	 */
	final string getFilename() const pure nothrow {
		return this._filename;
	}
	
	/**
	 * Returns the length of the sound in seconds.
	 */
	float getLength() const pure nothrow {
		return (8 * this._sFile.dataSize) / (this._sFile.bits * this._sFile.rate * this._sFile.channels);
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
