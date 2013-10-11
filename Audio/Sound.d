module Dgame.Audio.Sound;

private {
	debug import std.stdio : writeln, writefln;
	import std.algorithm : endsWith;
	import std.string : toLower;
	
	import derelict.openal.al;
	
	//import Dgame.Core.AutoRef;
	
	import Dgame.Audio.SoundFile;
	import Dgame.Audio.VorbisFile;
	import Dgame.Audio.WaveFile;
	import Dgame.Math.VecN;
}

/**
 * Represents the current status.
 */
enum Status : ubyte {
	Stopped, /** Sound is stopped */
	Paused,	 /** Sound is paused */
	Playing, /** Sound is playing */
	None	 /** No information */
}

/**
 * The channel type. Mono or Stereo.
 */
enum ChannelType : ubyte {
	Mono,	/** Channel type is Mono */
	Stereo	/** Channel type is Stereo */
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
	void opCall(ubyte bits, ChannelType type) {
		this.bits = bits;
		this.type = type;
	}
}

struct ALChunk {
public:
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
	debug writefln("Finalize Sound (%d)", _ALFinalizer.length);
	
	for (size_t i = 0; i < _ALFinalizer.length; i++) {
		if (_ALFinalizer[i]) {
			debug writefln(" -> Sound finalized: %d", i);
			_ALFinalizer[i].free();
		}
	}
	
	_ALFinalizer = null;
	
	debug writeln(" >> Sound Finalized");
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
	ALChunk _alChunk;
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
		const string filename = soundfile.getFilename();
		
		if (Sound* s = filename in _soundInstances)
			return *s;
		
		Sound s = new Sound(soundfile);
		_soundInstances[filename] = s;
		
		return s;
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
		else if (filename.endsWith(".wav") || filename.endsWith(".wave"))
			sFile = new WaveFile(filename);
		else {
			const string lower = toLower(filename); // for e.g. *.WAVE
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
		
		alBufferData(this._alChunk.buffer, this._format, buffer, dataSize, this._frequency);
		
		this._sourcePos = vec3f(0, 0, 0);
		this._sourceVel = vec3f(0, 0, 0);
		
		this._looping = false;
		this._volume  = 1.0;
		this._status  = Status.None;
		
		// Source
		alSourcei(this._alChunk.source, AL_BUFFER, this._alChunk.buffer);
		alSourcef(this._alChunk.source, AL_PITCH, 1.0);
		alSourcef(this._alChunk.source, AL_GAIN, this._volume);
		alSourcefv(this._alChunk.source, AL_POSITION, &this._sourcePos[0]);
		alSourcefv(this._alChunk.source, AL_VELOCITY, &this._sourceVel[0]);
		alSourcei(this._alChunk.source, AL_LOOPING, this._looping);
	}
	
	/**
	 * Returns the soundfile.
	 */
	final ref BaseSoundFile getSoundFile() {
		return this._soundfile;
	}
	
	/**
	 * Returns the Format.
	 */
	final ALenum getFormat() const pure nothrow {
		return this._format;
	}
	
	/**
	 * Returns the current status.
	 *
	 * See: Status enum
	 */
	final Status getStatus() const pure nothrow {
		return this._status;
	}
	
	/**
	 * Returns the current Channel.
	 *
	 * See: Channel struct
	 */
	final ref const(Channel) getChannel() const pure nothrow {
		return this._channel;
	}
	
	/**
	 * Returns the current frequency.
	 */
	final uint getFreqeuency() const pure nothrow {
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
		this.setVolume(volume / 255.0);
	}
	
	/**
	 * Returns the current volume.
	 */
	final ubyte getVolume() const pure nothrow {
		return cast(ubyte)(this._volume * ubyte.max);
	}
	
	/**
	 * Enable looping.
	 */
	final void setLooping(bool enable) {
		this._looping = enable;
		
		alSourcei(this._alChunk.source, AL_LOOPING, this._looping);
	}
	
	/**
	 * Returns if the looping is enabled or not.
	 */
	final bool getLooping() const pure nothrow {
		return this._looping;
	}
	
	/**
	 * Activate the playing.
	 * If enable is true, the looping is also activated.
	 */
	final void play(bool enable) {
		this.setLooping(enable);
		
		this.play();
	}
	
	/**
	 * Activate the playing.
	 */
	final void play() {
		alSourcePlay(this._alChunk.source);
		
		this._status = Status.Playing;
	}
	
	/**
	 * Stop current playing.
	 */
	final void stop() {
		alSourceStop(this._alChunk.source);
		
		this._status = Status.Stopped;
	}
	
	/**
	 * Rewind playing.
	 */
	final void rewind() {
		alSourceRewind(this._alChunk.source);
		
		this._status = Status.Playing;
	}
	
	/**
	 * Pause playing.
	 */
	final void pause() {
		alSourcePause(this._alChunk.source);
		
		this._status = Status.Paused;
	}
	
	/**
	 * Set the position.
	 */
	void setPosition(const vec3f pos) {
		this._sourcePos = pos;
		
		alSourcefv(this._alChunk.source, AL_POSITION, &pos[0]);
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
	final ref const(vec3f) getPosition() const pure nothrow {
		return this._sourcePos;
	}
	
	/**
	 * Set the velocity.
	 */
	void setVelocity(const vec3f vel) {
		this._sourceVel = vel;
		
		alSourcefv(this._alChunk.source, AL_VELOCITY, &vel[0]);
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
	final ref const(vec3f) getVelocity() const pure nothrow {
		return this._sourceVel;
	}
}