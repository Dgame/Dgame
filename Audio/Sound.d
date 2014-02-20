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
module Dgame.Audio.Sound;

private {
	import std.algorithm : endsWith;
	import std.exception : enforce;
	
	import derelict.openal.al;
	
	import Dgame.Internal.Log;
	import Dgame.Math.Vector3;
	import Dgame.Audio.SoundFile;
	import Dgame.Audio.VorbisFile;
	import Dgame.Audio.WaveFile;
}

@safe
private char toLower(char ch) pure nothrow { 
	return ch | 32; 
}

@safe
private string toLower(string str) pure nothrow {
	char[] s = new char[str.length];
	
	for (uint i = 0; i < str.length; i++) {
		s[i] = toLower(str[i]);
	}
	
	return s;
}

/**
 * Channel struct which stores the channel information.
 */
struct Channel {
	/**
	 * The channel type. Mono or Stereo.
	 */
	enum Type : ubyte {
		Mono,	/** Channel type is Mono */
		Stereo	/** Channel type is Stereo */
	}

	ubyte bits;	/** How many bits has this channel */
	Type type;	/** Which type is this channel */
	
	/**
	 * CTor
	 */
	this(ubyte bits, Type type) {
		this.bits = bits;
		this.type = type;
	}
	
	/**
	 * Short set function.
	 *
	 * Example:
	 * ---
	 * Channel ch;
	 * ch(8, Channel.Type.Stereo); // set bits and type for this channel.
	 * ---
	 */
	void opCall(ubyte bits, Type type) {
		this.bits = bits;
		this.type = type;
	}
}

private struct ALChunk {
	ALuint source;
	ALuint buffer;
	
	/**
	 * Create and initialize the buffers
	 */
	void init() {
		alGenBuffers(1, &this.buffer);
		alGenSources(1, &this.source);
	}
	
	/**
	 * Free / Release the source and buffer of the Sound
	 */
	void free() {
		if (this.source && this.buffer) {
			alDeleteSources(1, &this.source);
			alDeleteBuffers(1, &this.buffer);
		}
	}
	
	@disable
	this(this);
}

private ALChunk*[] _ALFinalizer;

static ~this() {
	debug Log.info("Finalize Sound (%d)", _ALFinalizer.length);
	
	for (size_t i = 0; i < _ALFinalizer.length; i++) {
		if (_ALFinalizer[i]) {
			debug Log.info(" -> Sound finalized: %d", i);
			_ALFinalizer[i].free();
		}
	}
	
	_ALFinalizer = null;
	
	debug Log.info(" >> Sound Finalized");
}

/**
 * Sound represents the functionality to manipulate loaded sounds.
 * That means with this class you can get informations about the sound or
 * you can play, stop or pause it.
 *
 * Author: rschuett
 */
class Sound {
	/**
	 * Represents the current status.
	 */
	enum Status : ubyte {
		None,	 /** No information */
		Stopped, /** Sound is stopped */
		Paused,	 /** Sound is paused */
		Playing  /** Sound is playing */
	}

private:
	ALChunk _alChunk;
	ALenum _format;
	
	uint _frequency;
	float _volume;
	bool _looping;
	
	Vector3f _sourcePos;
	Vector3f _sourceVel;
	
	Status _status;
	Channel _channel;
	
	BaseSoundFile _soundfile;
	
private:
	static Sound[string] _soundInstances;
	
public:
final:
	/**
	 * CTor
	 */
	this() {
		this._alChunk.init();
		this._status = Status.None;
		
		_ALFinalizer ~= &this._alChunk;
	}
	
	/**
	 * CTor
	 */
	this(BaseSoundFile soundfile) {
		this();
		this.loadFromFile(soundfile);
	}
	
	/**
	 * CTor
	 */
	this(string filename) {
		this();
		this.loadFromFile(filename);
	}
	
	/**
	 * Free / Release the source and buffer of the Sound
	 */
	void free() {
		this._alChunk.free();
	}
	
	/**
	 * Load a soundfile and stores the sound object in a static field.
	 * Then returns the sound object.
	 * If you try to load the same file on more time, you get the same sound object as before.
	 */
	static Sound loadOnce(BaseSoundFile soundfile) in {
		assert(soundfile !is null, "Soundfile is null.");
	} body {
		return Sound.loadOnce(soundfile.getFilename());
	}
	
	/**
	 * Load a soundfile from his path and stores the sound object in a static field.
	 * Then returns the sound object.
	 * If you try to load the same file on more time, you get the same sound object as before.
	 */
	static Sound loadOnce(string filename) {
		if (Sound* s = filename in _soundInstances)
			return *s;
		
		Sound s = new Sound(filename);
		_soundInstances[filename] = s;
		
		return s;
	}
	
	/**
	 * Load from a soundfile.
	 *
	 * Example:
	 * ---
	 * Sound s1 = new Sound();
	 * s1.loadFromFile(new VorbisFile("samples/audio/orchestral.ogg"));
	 * ---
	 *
	 * See: BaseSoundFile
	 * See: VorbisFile
	 * See: WaveFile
	 */
	void loadFromFile(BaseSoundFile soundfile) in {
		assert(soundfile !is null, "Soundfile is null.");
	} body {
		const SoundFile* sFile = &soundfile.getData();
		this._soundfile = soundfile;
		
		/// Load
		Channel ch = void;
		switch (sFile.bits) {
			case 8:
				if (sFile.channels == 1)
					ch(8, Channel.Type.Mono);
				else
					ch(8, Channel.Type.Stereo);
				break;
				
			case 16:
				if (sFile.channels == 1)
					ch(16, Channel.Type.Mono);
				else
					ch(16, Channel.Type.Stereo);
				break;
				
			default: 
				debug Log.info("Bits: %d", sFile.bits);
				Log.error("Switch error.");
		}
		
		this.loadFromMemory(soundfile.getBuffer().ptr, sFile.dataSize, sFile.rate, ch);
	}
	
	/**
	 * Load a soundfile from his path.
	 *
	 * Example:
	 * ---
	 * Sound s1 = new Sound();
	 * if (s1.loadFromFile("samples/audio/orchestral.ogg") is null)
	 *	throw new Exception("Could not load file.");
	 * ---
	 *
	 * See: BaseSoundFile
	 * See: VorbisFile
	 * See: WaveFile
	 */
	BaseSoundFile loadFromFile(string filename) {
		enforce(exists(filename), "Soundfile " ~ filename ~ " does not exist.");

		BaseSoundFile sFile;
		
	Lagain:
		if (filename.endsWith(".ogg") || filename.endsWith(".vorbis"))
			sFile = new VorbisFile(filename);
		else if (filename.endsWith(".wav") || filename.endsWith(".wave"))
			sFile = new WaveFile(filename);
		else {
			const string lower = toLower(filename); // for e.g. *.WAVE
			if (lower != filename) {
				filename = lower;
				goto Lagain;
			}
		}
		
		if (sFile !is null)
			this.loadFromFile(sFile);
		
		return sFile;
	}
	
	/**
	 * Load from memory.
	 */
	void loadFromMemory(const void* buffer, uint dataSize, uint frequency, ref const Channel ch) in {
		assert(buffer !is null, "Buffer is null.");
	} body {
		switch (ch.bits) {
			case 8:
				if (ch.type == Channel.Type.Mono)
					this._format = AL_FORMAT_MONO8;
				else
					this._format = AL_FORMAT_STEREO8;
				break;

			case 16:
				if (ch.type == Channel.Type.Mono)
					this._format = AL_FORMAT_MONO16;
				else
					this._format = AL_FORMAT_STEREO16;
				break;
			default: Log.error("Switch error.");
		}
		
		this._frequency = frequency;
		this._channel = ch;
		
		alBufferData(this._alChunk.buffer, this._format, buffer, dataSize, this._frequency);
		
		this._sourcePos = Vector3f(0, 0, 0);
		this._sourceVel = Vector3f(0, 0, 0);
		
		this._looping = false;
		this._volume  = 1f;
		this._status  = Status.None;
		
		const float[3] pos = this._sourcePos.asArray();
		const float[3] vel = this._sourceVel.asArray();
		
		// Source
		alSourcei(this._alChunk.source, AL_BUFFER, this._alChunk.buffer);
		alSourcef(this._alChunk.source, AL_PITCH, 1.0);
		alSourcef(this._alChunk.source, AL_GAIN, this._volume);
		alSourcefv(this._alChunk.source, AL_POSITION, &pos[0]);
		alSourcefv(this._alChunk.source, AL_VELOCITY, &vel[0]);
		alSourcei(this._alChunk.source, AL_LOOPING, this._looping);
	}
	
	/**
	 * Returns the interal Soundfile which contains the filename, the music type and the length in seconds.
	 */
	BaseSoundFile getSoundFile() pure nothrow {
		return this._soundfile;
	}
	
	/**
	 * Returns the current filename.
	 */
	string getFilename() const pure nothrow {
		return this._soundfile !is null ? this._soundfile.getFilename() : null;
	}
	
	/**
	 * Returns the length in seconds.
	 */
	float getLength() const pure nothrow {
		return this._soundfile !is null ? this._soundfile.getLength() : 0f;
	}
	
	/**
	 * Returns the music type.
	 */
	MusicType getType() const pure nothrow {
		return this._soundfile !is null ? this._soundfile.getType() : MusicType.None;
	}
	
	/**
	 * Returns the Format.
	 */
	ALenum getFormat() const pure nothrow {
		return this._format;
	}
	
	/**
	 * Returns the current status.
	 *
	 * See: Status enum
	 */
	Status getStatus() const pure nothrow {
		return this._status;
	}
	
	/**
	 * Returns the current Channel.
	 *
	 * See: Channel struct
	 */
	ref const(Channel) getChannel() const pure nothrow {
		return this._channel;
	}
	
	/**
	 * Returns the current frequency.
	 */
	uint getFreqeuency() const pure nothrow {
		return this._frequency;
	}
	
	/**
	 * Set the volume.
	 */
	void setVolume(float volume) {
		this._volume = volume;
		
		alSourcef(this._alChunk.source, AL_GAIN, this._volume);
	}
	
	/**
	 * Set the volume.
	 */
	void setVolume(ubyte volume) {
		this.setVolume(volume / 255f);
	}
	
	/**
	 * Returns the current volume.
	 */
	ubyte getVolume() const pure nothrow {
		return cast(ubyte)(this._volume * ubyte.max);
	}
	
	/**
	 * Enable looping.
	 */
	void setLooping(bool enable) {
		this._looping = enable;
		
		alSourcei(this._alChunk.source, AL_LOOPING, this._looping);
	}
	
	/**
	 * Returns if the looping is enabled or not.
	 */
	bool getLooping() const pure nothrow {
		return this._looping;
	}
	
	/**
	 * Activate the playing.
	 * If enable is true, the looping is also activated.
	 */
	void play(bool enable) {
		this.setLooping(enable);
		this.play();
	}
	
	/**
	 * Activate the playing.
	 */
	void play() {
		alSourcePlay(this._alChunk.source);
		this._status = Status.Playing;
	}
	
	/**
	 * Stop current playing.
	 */
	void stop() {
		alSourceStop(this._alChunk.source);
		this._status = Status.Stopped;
	}
	
	/**
	 * Rewind playing.
	 */
	void rewind() {
		alSourceRewind(this._alChunk.source);
		this._status = Status.Playing;
	}
	
	/**
	 * Pause playing.
	 */
	void pause() {
		alSourcePause(this._alChunk.source);
		this._status = Status.Paused;
	}
	
	/**
	 * Set the position.
	 */
	void setPosition(ref const Vector3f vpos) {
		this._sourcePos = vpos;
		this._updatePosition();
	}
	
	/**
	 * Set the position.
	 */
	void setPosition(float x, float y, float z = 0) {
		this._sourcePos.set(x, y, z);
		this._updatePosition();
	}
	
	private void _updatePosition() const {
		const float[3] pos = this._sourcePos.asArray();

		alSourcefv(this._alChunk.source, AL_POSITION, &pos[0]);
	}
	
	/**
	 * Returns the current position.
	 */
	ref const(Vector3f) getPosition() const pure nothrow {
		return this._sourcePos;
	}
	
	/**
	 * Set the velocity.
	 */
	void setVelocity(ref const Vector3f vvel) {
		this._sourceVel = vvel;
		this._updateVelocity();
	}
	
	/**
	 * Set the velocity.
	 */
	void setVelocity(float x, float y, float z = 0) {
		this._sourceVel.set(x, y, z);
		this._updateVelocity();
	}
	
	private void _updateVelocity() const {
		const float[3] vel = this._sourceVel.asArray();

		alSourcefv(this._alChunk.source, AL_VELOCITY, &vel[0]);
	}
	
	/**
	 * Returns the current velocity.
	 */
	ref const(Vector3f) getVelocity() const pure nothrow {
		return this._sourceVel;
	}
}