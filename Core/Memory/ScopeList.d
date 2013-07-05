module Dgame.Core.Memory.ScopeList;

private {
	debug import std.stdio;
	import core.memory : GC;
	import core.stdc.stdlib : calloc, realloc, free;
}

interface IAllocator(T) {
public:
	T* allocate(size_t length) const;
	void reallocate(ref ScopeList!T chunk, size_t extensionSize) const;
	void deallocate(ref ScopeList!T chunk) const;
}

class GCAllocator(T) : IAllocator!T {
public:
	T* allocate(size_t length) const {
		return cast(T*) GC.calloc(length, T.sizeof);
	}
	
	void reallocate(ref ScopeList!T chunk, size_t extensionSize) const {
		extensionSize += chunk.capacity;
		
		size_t u = GC.extend(chunk._ptr, extensionSize * T.sizeof, extensionSize * T.sizeof);
		if (u != 0)
			return chunk._ptr;
		
		chunk._ptr = cast(T*) GC.realloc(chunk._ptr, extensionSize);
		chunk._capacity = extensionSize;
	}
	
	void deallocate(ref ScopeList!T chunk) const {
		GC.free(chunk._ptr);
	}
}

class ManualAllocator(T) : IAllocator!T {
public:
	T* allocate(size_t length) const {
		return cast(T*) .calloc(length, T.sizeof);
	}
	
	void reallocate(ref ScopeList!T chunk, size_t extensionSize) const {
		extensionSize += chunk.capacity;
		
		chunk._ptr = cast(T*) .realloc(chunk._ptr, extensionSize * T.sizeof);
		chunk._capacity = extensionSize;
	}
	
	void deallocate(ref ScopeList!T chunk) const {
		.free(chunk._ptr);
	}
}

alias DefaultAllocator = ManualAllocator;

enum {
	InitSize = 3,
	DoublingLimit = 4000
}

size_t calculateLength(size_t cap, size_t insertSize) {
	if (cap < DoublingLimit)
		return cap;
	
	return cast(size_t)(cap * 0.45);
}

struct ScopeList(T) {
private:
	size_t _length;
	size_t _capacity;
	uint _reallocations;
	
	T* _ptr;
	
	IAllocator!T _allocator;
	size_t function(size_t cap, size_t insertSize) _determineLength;
	
	void _init(size_t cap) {
		if (this._allocator is null)
			this._allocator = new DefaultAllocator!T();
		
		if (this._determineLength is null)
			this._determineLength = &calculateLength;
		
		this._ptr = this._allocator.allocate(cap);
		this._capacity += cap;
	}
	
public:
	@disable
	this(typeof(null));
	
	this(IAllocator!T allocator) {
		assert(allocator !is null);
		
		this._allocator = allocator;
		
		this._ptr = null;
		this._capacity = 0;
		this._length = 0;
	}
	
	this(IAllocator!T allocator, size_t function(size_t cap, size_t insertSize) pure nothrow calcLength) {
		this(allocator);
		
		this._determineLength = calcLength;
	}
	
	@disable
	this(this); /// TODO: erlauben?
	
	~this() {
		this.reset();
	}
	
	void reserve(size_t cap) {
		debug writeln("Allocate Memory: ", cap);
		
		if (this._ptr !is null) {
			this._allocator.reallocate(this, cap);
			this._reallocations++;
		} else
			this._init(cap);
	}
	
	void reset() {
		if (this.isValid()) {
			debug writeln("Release Memory: ", this._capacity, '(', this._length, ')');
			static if (is(T == struct) || is(T == class)) {
				foreach (ref T item; this._ptr[0 .. this._length]) {
					.destroy!T(item);
				}
			}
		}
		
		this._allocator.deallocate(this);
		
		this._ptr = null;
		this._length = 0;
		this._capacity = 0;
		this._reallocations = 0;
	}
	
	ref typeof(this) opOpAssign(string op : "~", U : T)(auto ref U val) {
		if (this._ptr is null)
			this._init(InitSize + 1);
		
		if (this._length < this._capacity)
			this._ptr[this._length++] = val;
		else {
			this._allocator.reallocate(this, this._determineLength(this._capacity, 1));
			this._reallocations++;
			
			this._ptr[this._length++] = val;
		}
		
		return this;
	}
	
	ref typeof(this) opOpAssign(string op : "~", U)(U[] values) {
		if (this._ptr is null)
			this._init(InitSize + values.length);
		
		foreach (ref U val; values) {
			if (this._length < this._capacity)
				this._ptr[this._length++] = val;
			else {
				this._allocator.reallocate(this, this._determineLength(this._capacity, values.length));
				this._reallocations++;
				
				this._ptr[this._length++] = val;
			}
		}
		
		return this;
	}
	
	ref typeof(this) opOpAssign(string op : "~", U, uint N)(ref const U[N] values) {
		if (this._ptr is null)
			this._init(InitSize + values.length);
		
		foreach (ref const U val; values) {
			if (this._length < this._capacity)
				this._ptr[this._length++] = val;
			else {
				this._allocator.reallocate(this, this._determineLength(this._capacity, values.length));
				this._reallocations++;
				
				this._ptr[this._length++] = val;
			}
		}
		
		return this;
	}
	
	@property
	size_t length() const pure nothrow {
		return this._length;
	}
	
	@property
	size_t capacity() const pure nothrow {
		return this._capacity;
	}
	
	@property
	uint reallocations() const pure nothrow {
		return this._reallocations;
	}
	
	bool isValid() const pure nothrow {
		return this._ptr !is null;
	}
	
	@property
	inout(T[]) data() inout {
		return this._ptr[0 .. this._length];
	}
	
	alias data this;
}