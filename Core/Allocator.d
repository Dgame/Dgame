module Dgame.Core.Allocator;

private {
	debug import std.stdio;
	
	import std.c.stdlib : calloc, realloc, free;
}

enum Mode {
	AutoFree,
	DontFree
}

struct Storage(T) {
public:
	T* data;
	size_t length;
	
	const size_t capacity;
	const Mode mode;
	
	this(T* data, size_t cap, Mode mode) {
		assert(data !is null);
		
		this.data = data;
		this.capacity = cap;
		this.length = 0;
		
		this.mode = mode;
	}
	
	~this() {
		if (this.mode != Mode.DontFree)
			Memory.free(this.data);
	}
	
	ref typeof(this) opOpAssign(string op : "~", U : T)(auto ref U val) {
		if (this.length < this.capacity)
			this.data[this.length++] = val;
		else
			assert(0, "Out of memory");
		
		return this;
	}
	
	ref typeof(this) opOpAssign(string op : "~", U)(U[] values) {
		foreach (ref U val; values) {
			if (this.length < this.capacity)
				this.data[this.length++] = val;
			else
				assert(0, "Out of memory");
		}
		
		return this;
	}
	
	ref typeof(this) opOpAssign(string op : "~", U, size_t N)(ref const U[N] values) {
		foreach (ref const U val; values) {
			if (this.length < this.capacity)
				this.data[this.length++] = val;
			else
				assert(0, "Out of memory");
		}
		
		return this;
	}
	
	@property
	inout(T[]) get() inout {
		return this.data[0 .. this.length];
	}
	
	alias get this;
}

final abstract class Memory {
public:
	static Storage!T alloc(T)(size_t length, Mode mode = Mode.DontFree) {
		T* mem = cast(T*) .calloc(length, T.sizeof);
		if (!mem)
			assert(0, "Out of memory");
		
		return Storage!T(mem, length, mode);
	}
	
	static ref Storage!T extend(T)(ref Storage!T st, size_t length) {
		if ((st.capacity - st.length) >= length)
			return st;
		
		const size_t old_length = st.length;
		
		T* data = cast(T*) .realloc(st.data, length * T.sizeof);
		if (!data)
			assert(0, "Out of memory");
		
		st.data = data;
		
		return st;
	}
	
	static void free(T)(ref Storage!T st) {
		.free(st.data);
	}
	
	static void free(T)(T* ptr) {
		.free(ptr);
	}
} unittest {
	auto mem = Memory.alloc!float(12);
	scope(exit) Memory.free(mem);
	
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
}