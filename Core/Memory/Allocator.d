module Dgame.Core.Memory.Allocator;

private {
	debug import std.stdio : writefln;
	import core.stdc.stdlib : malloc, free;
}

struct LimitedAllocator(const ushort Limit) if (Limit > 0) {
private:
	void*[Limit] _memory;

	int _counter;

public:
	@disable
	this(this);

	~this() {
		/// TODO: if I call collect I get an linker error. I have no idea why...
		version(none) {
			this.collect();
		} else {
			for (size_t i = 0; i < this._memory.length; ++i) {
				if (this._memory[i] is null)
					continue;

				free(this._memory[i]);
				this._memory[i] = null;
			}

			this._counter = 0;
		}
	}

	void collect() {
		debug writefln("Collect all (%d objects)", this._counter);

		for (size_t i = 0; i < this._memory.length; ++i) {
			if (this._memory[i] is null)
				continue;

			free(this._memory[i]);
			this._memory[i] = null;
		}

		this._counter = 0;
	}

	T[] allocate(T = void)(size_t N) {
		debug writefln("Allocate the %d object with N = %d.", this._counter, N);

		if (this.remain() == 0)
			throw new Exception("Reached MemoryPool limit.");
		
		this._memory[this._counter] = malloc(N * T.sizeof);
		scope(exit) this._counter++;

		return (cast(T*) this._memory[this._counter])[0 .. N];
	}

	alias alloc = allocate;

	bool deallocate(ref void* ptr) {
		debug writefln("Deallocate an object (%d remain)", this._counter);

		size_t i = 0;
		for ( ; i < Limit; ++i) {
			if (this._memory[i] == ptr) {
				free(this._memory[i]);

				this._memory[i] = null;
				ptr = null;

				this._counter--;

				if (i != this._counter && this._counter >= 0) {
					auto tmp = this._memory[this._counter];
					this._memory[i] = tmp;
					this._memory[this._counter] = null;
				}

				break;
			}
		}

		if (i < this._memory.length) {
			debug writefln("\tDeallocated the %d object.", i);

			return true;
		}

		return false;
	}

	int count() const pure nothrow {
		return this._counter;
	}

	ushort remain() const pure nothrow {
		// to avoid a cast...
		ushort max = Limit;
		max -= this._counter;

		return max;
	}
}

alias Mallocator = LimitedAllocator!(8);

struct LimitlessAllocator {
private:
	void*[] _memory;

public:
	@disable
	this(this);

	~this() {
		this.collect();
	}

	void collect() {
		debug writefln("Collect all (%d objects)", this._memory.length);

		for (size_t i = 0; i < this._memory.length; ++i) {
			if (this._memory[i] is null)
				continue;

			free(this._memory[i]);
			this._memory[i] = null;
		}
	}

	T[] allocate(T = void)(size_t N) {
		debug writefln("Allocate the %d object with N = %d.", this._memory.length, N);

		if (this.remain() == 0)
			throw new Exception("Reached MemoryPool limit.");

		this._memory ~= malloc(N * T.sizeof);

		return (cast(T*) this._memory[$ - 1])[0 .. N];
	}

	alias alloc = allocate;

	bool deallocate(ref void* ptr) {
		debug writefln("Deallocate an object (%d remain)", this._memory.length);

		size_t i = 0;
		for ( ; i < this._memory.length; ++i) {
			if (this._memory[i] == ptr) {
				free(this._memory[i]);

				this._memory[i] = null;
				ptr = null;

				if (i != this._memory.length) {
					void* tmp = this._memory[$ - 1];

					this._memory[i] = tmp;
					this._memory[$ - 1] = null;
				}

				break;
			}
		}

		if (i < this._memory.length) {
			debug writefln("\tDeallocated the %d object.", i);

			return true;
		}

		return false;
	}

	int count() const pure nothrow {
		return this._memory.length;
	}
}