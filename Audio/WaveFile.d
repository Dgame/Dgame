/*
*******************************************************************************************
* Dgame (a D game framework) - Copyright (c) Randy Schütt
* 
* This software is provided 'as-is', without any express or implied warranty.
* In no event will the authors be held liable for any damages arising from
* the use of this software.
* 
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 
* 1. The origin of this software must not be misrepresented; you must not claim
*    that you wrote the original software. If you use this software in a product,
*    an acknowledgment in the product documentation would be appreciated but is
*    not required.
* 
* 2. Altered source versions must be plainly marked as such, and must not be
*    misrepresented as being the original software.
* 
* 3. This notice may not be removed or altered from any source distribution.
*******************************************************************************************
*/
module Dgame.Audio.WaveFile;

private {
	import std.string : toStringz;

	import derelict.openal.al;

	import Dgame.Internal.Log;
	import Dgame.Internal.Allocator;
	import Dgame.Audio.SoundFile;
}

struct Header {
	// RIFF - CHUNK
	char[4] riff; // Enthält den Namen "RIFF"
	uint riff_length;  // Enthält Länge des Riffchunks
	char[4] wave;  // Hier steht "WAVE"
	// FMT - CHUNK
	char[4] fmt;   // Enthält "FMT"
	uint fmt_length;    // Länge des fmt-chunks
	ushort format;    // 0 = Mono, 1 = Stereo
	ushort channels;	// Anz. der benutzten Kanäle
	uint sample_rate;	// Sample-Rate in Herz
	uint byte_rate;
	ushort block_align;
	ushort bits_per_sample;
	char[4] data;
	uint data_size;
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
		FILE* fp = fopen(toStringz(filename), toStringz("rb"));
		scope(exit) {
			fclose(fp);
			fp = null;
		}

		Header header = void;
		fread(&header, Header.sizeof, 1, fp);

		debug Log.info("Allocate %d memory for Wave.", header.data_size);

		super._buffer = new byte[header.data_size];
		fread(super._buffer.ptr, byte.sizeof, header.data_size, fp);

		super._sFile.rate = header.sample_rate;
		super._sFile.dataSize = header.data_size;
		super._sFile.channels = cast(ubyte) header.channels;
		super._sFile.bits = cast(ubyte) header.bits_per_sample;
		super._sFile.bytes = cast(ubyte)(header.bits_per_sample / 8);
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