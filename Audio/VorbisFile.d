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
module Dgame.Audio.VorbisFile;

private {
	import std.string : toStringz;
	
	import derelict.ogg.ogg;
	import derelict.ogg.vorbis;
	import derelict.ogg.vorbisfile;
	import derelict.ogg.vorbisfiletypes;
	import derelict.ogg.vorbistypes;

	import Dgame.Internal.Log;
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
			Log.error(filename ~ " is no valid Vorbis file.");
		
		// Get some information about the OGG file
		vorbis_info* pInfo = ov_info(&oggFile, -1);
		
		super._sFile.rate  = pInfo.rate;
		super._sFile.bits  = 16;
		super._sFile.bytes = 2;
		super._sFile.dataSize = cast(uint) ov_pcm_total(&oggFile, -1) * super._sFile.bytes * pInfo.channels;
		super._sFile.channels = cast(ubyte) pInfo.channels;
		
		debug Log.info("Allocate %d memory for Vorbis file %s.", _sFile.dataSize, filename);
		super._buffer = new byte[super._sFile.dataSize];

		import Dgame.Internal.Allocator : auto_ptr, type_malloc;
		
		auto_ptr!(byte) tmpBuf = type_malloc!byte(ushort.max);

		uint inserted = 0;
		while (true) {
			// Read up to a buffer's worth of decoded sound data
			long bytes = ov_read(&oggFile, tmpBuf, ushort.max, 0, 2, 1, null);
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