module Dgame.Core.Allocator;

private {
	debug import std.stdio;
	
	import core.stdc.stdlib : calloc, realloc, free;
}

struct Chunk(T) {
private:
	uint _length;
	uint _capacity;
	
public:
	T* data;
	const Memory.Mode mode;
	
public:
	@disable
	this(typeof(null));
	
	this(T* data, uint cap, Memory.Mode mode) {
		debug writeln("Allocate Memory: ", cap, ":", mode);
		
		assert(data !is null);
		
		this.data = data;
		this._capacity = cap;
		this._length = 0;
		
		this.mode = mode;
	}
	
	@disable
	this(this);
	
	~this() {
		if (this.mode != Memory.Mode.DontFree && this.isValid()) {
			debug writeln("Release Memory");
			Memory.deallocate(this.data);
		}
	}
	
	ref typeof(this) opOpAssign(string op : "~", U : T)(auto ref U val) {
		if (this._length < this._capacity)
			this.data[this._length++] = val;
		else
			assert(0, "Out of memory");
		
		return this;
	}
	
	ref typeof(this) opOpAssign(string op : "~", U)(U[] values) {
		foreach (ref U val; values) {
			if (this._length < this._capacity)
				this.data[this._length++] = val;
			else
				assert(0, "Out of memory");
		}
		
		return this;
	}
	
	ref typeof(this) opOpAssign(string op : "~", U, uint N)(ref const U[N] values) {
		foreach (ref const U val; values) {
			if (this._length < this._capacity)
				this.data[this._length++] = val;
			else
				assert(0, "Out of memory");
		}
		
		return this;
	}
	
	@property
	uint length() const pure nothrow {
		return this._length;
	}
	
	@property
	uint capacity() const pure nothrow {
		return this._capacity;
	}
	
	bool isValid() const pure nothrow {
		return this.data !is null;
	}
	
	@property
	inout(T[]) get() inout pure nothrow {
		return this.data[0 .. this._length];
	}
	
	alias get this;
}

final abstract class Memory {
public:
	enum Mode {
		AutoFree,
		DontFree
	}
	
	static Chunk!T allocate(T)(uint length, Mode mode) {
		T* mem = cast(T*) calloc(length, T.sizeof);
		if (!mem)
			assert(0, "Out of memory");
		
		return Chunk!T(mem, length, mode);
	}
	
	static ref Chunk!T extend(T)(ref Chunk!T st, uint length, bool* inPlace = null) {
		if ((st.capacity - st.length) >= length)
			return st;
		
		st._capacity += length;
		
		T* data = cast(T*) .realloc(st.data, st.capacity * T.sizeof);
		if (!data)
			assert(0, "Out of memory");
		
		if (inPlace)
			*inPlace = data is st.data;
		
		st.data = data;
		
		return st;
	}
	
	static void deallocate(T)(ref Chunk!T st) {
		Memory.deallocate(st.data);
	}
	
	static void deallocate(T)(ref T* ptr) {
		free(ptr);
		ptr = null;
	}
} unittest {
	auto mem = Memory.allocate!float(12, Memory.Mode.DontFree);
	
	assert(mem.length == 0);
	assert(mem.capacity == 12);
	assert(mem == []);
	
	mem ~= 42;
	
	assert(mem.length == 1);
	assert(mem.capacity == 12);
	assert(mem == [42]);
	
	mem ~= [1, 2, 3];
	
	assert(mem.length == 4);
	assert(mem.capacity == 12);
	assert(mem == [42, 1, 2, 3]);
	
	float[3] v = [4, 5, 6];
	mem ~= v;
	
	assert(mem.length == 7);
	assert(mem.capacity == 12);
	assert(mem == [42, 1, 2, 3, 4, 5, 6]);
	
	Memory.deallocate(mem);
	
	assert(!mem.isValid());
}