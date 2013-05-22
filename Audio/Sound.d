module Dgame.Audio.Sound;

private {
	debug import std.stdio;
	import std.algorithm : endsWith;
	import std.string : toLower;
	
	//import Dgame.Core.AutoRef;
	import Dgame.Audio.Core.core;
	
	import Dgame.Audio.SoundFile;
	import Dgame.Audio.VorbisFile;
	import Dgame.Audio.WaveFile;
	import Dgame.Audio.Listener;
}

/**
 * Represents the current status.
 */
enum Status {
	Stopped, /** Sound is stopped */
	Paused,	 /** Sound is paused */
	Playing, /** Sound is playing */
	None	 /** No information */
}

/**
 * The channel type. Mono or Stereo.
 */
enum ChannelType {
	Mono   = 1,	/** Channel type is Mono (1) */
	Stereo = 2	/** Channel type is Stereo (2) */
}

/**
 * Channel struct which stores the channel information.
 */
struct Channel {
public:
	ubyte bits;			/** How many bits has this channel */
	ChannelType type;	/** Which type is this channel */
	
	/**
	 * CTor
	 */
	this(ubyte bits, ChannelType type) {
		this.bits = bits;
		this.type = type;
	}
	
	/**
	 * Short set function.
	 *
	 * Example:
	 * ---
	 * Channel ch;
	 * ch(8, ChannelType.Stereo); // set bits and type for this channel.
	 * ---
	 */
	ref Channel opCall(ubyte bits, ChannelType type) {
		this.bits = bits;
		this.type = type;
		
		return this;
	}
}

/**
 * Sound represents the functionality to manipulate loaded sounds.
 * That means with this class you can get informations about the sound or
 * you can play, stop or pause it.
 *
 * Author: rschuett
 */
class Sound {
private:
	ALuint _source;
	ALuint _buffer;
	
	ALenum _format;
	
	uint _frequency;
	float _volume;
	bool _looping;
	
	vec3f _sourcePos;
	vec3f _sourceVel;
	
	Status _status;
	Channel _channel;
	
	BaseSoundFile _soundfile;
	
private:
	static Sound[string] _soundInstances;
	
public:
	/**
	 * CTor
	 */
	this() {
		// Create the buffers
		alGenBuffers(1, &this._buffer);
		alGenSources(1, &this._source);
		
		this._status = Status.None;
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
	
	~this() {
		//alDeleteSources(1, &this._source);
		//alDeleteBuffers(1, &this._buffer);
	}
	
	final void release() const {
		alDeleteSources(1, &this._source);
		alDeleteBuffers(1, &this._buffer);
	}
	
	static ~this() {
		foreach (string filename, ref Sound s; _soundInstances) {
			s = null;
		}
	}
	
	/**
	 * Load a soundfile and stores the sound object in a static field.
	 * Then returns the sound object.
	 * If you try to load the same file on more time, you get the same sound object as before.
	 */
	static Sound loadOnce(BaseSoundFile soundfile) in {
		assert(soundfile !is null, "Soundfile is null.");
	} body {
		string filename = soundfile.getFilename();
		
		if (filename !in _soundInstances) {
			Sound s = new Sound();
			s.loadFromFile(soundfile);
			
			_soundInstances[filename] = s;
		}
		
		return _soundInstances[filename];
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
		const SoundFile sFile = soundfile.getData();
		
		this._soundfile = soundfile;
		
		// Load
		Channel ch;
		switch (sFile.bits) {
			case 8:
				if (sFile.channels == 1)
					ch(8, ChannelType.Mono);
				else
					ch(8, ChannelType.Stereo);
				break;
				
			case 16:
				if (sFile.channels == 1)
					ch(16, ChannelType.Mono);
				else
					ch(16, ChannelType.Stereo);
				break;
				
			default: 
				debug writefln("Bits: %d", sFile.bits);
				throw new Exception("Switch error.");
		}
		
		this.loadFromMemory(sFile.buffer.ptr, sFile.dataSize, sFile.rate, ch);
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
		BaseSoundFile sFile;
		
		if (filename.endsWith(".ogg") || filename.endsWith(".vorbis"))
			sFile = new VorbisFile(filename);
		else if(filename.endsWith(".wav") || filename.endsWith(".wave"))
			sFile = new WaveFile(filename);
		else {
			string lower = toLower(filename);
			if (lower != filename)
				this.loadFromFile(lower);
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
				if (ch.type == ChannelType.Mono)
					this._format = AL_FORMAT_MONO8;
				else
					this._format = AL_FORMAT_STEREO8;
				break;
			case 16:
				if (ch.type == ChannelType.Mono)
					this._format = AL_FORMAT_MONO16;
				else
					this._format = AL_FORMAT_STEREO16;
				break;
			default: throw new Exception("Switch error.");
		}
		
		this._frequency = frequency;
		this._channel = ch;
		
		alBufferData(this._buffer, this._format, buffer, dataSize, this._frequency);
		
		this._sourcePos = vec3f(0, 0, 0);
		this._sourceVel = vec3f(0, 0, 0);
		
		this._looping = false;
		this._volume  = 1.0;
		this._status  = Status.None;
		
		// Source
		alSourcei(this._source, AL_BUFFER, this._buffer);
		alSourcef(this._source, AL_PITCH, 1.0);
		alSourcef(this._source, AL_GAIN, this._volume);
		alSourcefv(this._source, AL_POSITION, &this._sourcePos[0]);
		alSourcefv(this._source, AL_VELOCITY, &this._sourceVel[0]);
		alSourcei(this._source, AL_LOOPING, this._looping);
	}
	
	/**
	 * Returns the soundfile.
	 */
	ref BaseSoundFile getSoundFile() {
		return this._soundfile;
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
		
		alSourcef(this._source, AL_GAIN, this._volume);
	}
	
	/**
	 * Set the volume.
	 */
	void setVolume(ubyte volume) {
		this.setVolume(volume / 255.0);
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
		
		alSourcei(this._source, AL_LOOPING, this._looping);
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
		alSourcePlay(this._source);
		
		this._status = Status.Playing;
	}
	
	/**
	 * Stop current playing.
	 */
	void stop() {
		alSourceStop(this._source);
		
		this._status = Status.Stopped;
	}
	
	/**
	 * Rewind playing.
	 */
	void rewind() {
		alSourceRewind(this._source);
		
		this._status = Status.Playing;
	}
	
	/**
	 * Pause playing.
	 */
	void pause() {
		alSourcePause(this._source);
		
		this._status = Status.Paused;
	}
	
	/**
	 * Set the position.
	 */
	void setPosition(const vec3f pos) {
		this._sourcePos = pos;
		
		alSourcefv(this._source, AL_POSITION, &pos[0]);
	}
	
	/**
	 * Set the position.
	 */
	void setPosition(float x, float y, float z = 0) {
		this.setPosition(vec3f(x, y, z));
	}
	
	/**
	 * Returns the current position.
	 */
	ref const(vec3f) getPosition() const pure nothrow {
		return this._sourcePos;
	}
	
	/**
	 * Set the velocity.
	 */
	void setVelocity(const vec3f vel) {
		this._sourceVel = vel;
		
		alSourcefv(this._source, AL_VELOCITY, &vel[0]);
	}
	
	/**
	 * Set the velocity.
	 */
	void setVelocity(float x, float y, float z = 0) {
		this.setVelocity(vec3f(x, y, z));
	}
	
	/**
	 * Returns the current velocity.
	 */
	ref const(vec3f) getVelocity() const pure nothrow {
		return this._sourceVel;
	}
}