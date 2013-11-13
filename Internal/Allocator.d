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
module Dgame.Internal.Allocator;

private {
	debug import std.stdio;
	import core.stdc.stdlib : malloc, calloc, realloc, free;
}

struct Memory {
	void*[void*] _pool;

	@disable
	this(this);

	~this() {
		foreach (void* ptr; this._pool) {
			if (ptr !is null)
				this.free(ptr);
		}
	}

	void* malloc(size_t N) {
		void* ptr = .malloc(N);
		this._pool[ptr] = ptr;

		return ptr;
	}

	void* calloc(size_t N, size_t sizeOf) {
		void* ptr = .calloc(N, sizeOf);
		this._pool[ptr] = ptr;

		return ptr;
	}

	T* allocate(T)(size_t N) {
		static if (is(T == void))
			return cast(T*) this.malloc(N);
		else
			return cast(T*) this.calloc(N, T.sizeof);
	}

	void* realloc(void* ptr, size_t N) {
		void* iptr = ptr in this._pool;
		if (iptr is null) {
			if (ptr !is null)
				throw new Exception("This pointer does not belong to this memory pool.");

			ptr = this.malloc(N);
			return ptr;
		}

		ptr = .realloc(ptr, N);
		if (ptr is null)
			return null;

		if (ptr !is iptr) {
			this.deselect(iptr);
			this._pool[ptr] = ptr;
		}

		return ptr;
	}

	void* realloc(void* ptr, size_t N, size_t sizeOf) {
		return this.realloc(ptr, N * sizeOf);
	}

	T* reallocate(T)(T* ptr, size_t N) {
		return cast(T*) this.realloc(ptr, N, T.sizeof);
	}

	void free(void* ptr) {
		if (ptr !in this._pool)
			throw new Exception("This pointer does not belong to this memory pool.");

		.free(ptr);

		this._pool[ptr] = null;
		ptr = null;
	}

	static void copy(T)(T* dst, T* src, size_t sizeOf = 1) {
		assert(sizeOf > 0);

		.memcpy(dst, src, T.sizeof * sizeOf);
	}

	T* copy(T)(T* src, size_t sizeOf = 1) {
		assert(sizeOf > 0);

		T* dst = this.allocate!T(sizeOf);
		.memcpy(dst, src, T.sizeof * sizeOf);

		return dst;
	}

	void deselect(void* ptr) {
		if (ptr !in this._pool)
			throw new Exception("This pointer does not belong to this memory pool.");

		this._pool[ptr] = null;
	}
}

struct Array(T) {
	Memory* mem;
	Stack* stack;

	@disable
	this();

	@disable
	this(typeof(null));

	@disable
	this(this);

	this(Memory* mem, Stack* stack = null) {
		this.mem = mem;
		this.stack = stack;
	}

	this(TypeAlloc* ta) {
		this.mem = &ta.mem;
		this.stack = &ta.stack;
	}

	T[] of(size_t N) {
		if (this.stack !is null) {
			void[] arr = this.stack.take(N, T.sizeof);
			debug if (arr.length != 0)
				writeln("Alloc on stack");
			if (arr !is null)
				return cast(T[]) arr;
		}

		debug writeln("Alloc on heap");

		if (this.mem is null)
			return null;

		T* ptr = this.mem.allocate!T(N);
		return ptr[0 .. N];
	}

	T[] opIndex(size_t N) {
		return this.of(N);
	}
}

enum StackSize = 8192;

struct Stack {
	void[StackSize] buffer = void;
	size_t usage = 0;

	@disable
	this(this);

	void[] take(size_t N) {
		if (this.remain() >= N) {
			scope(exit) this.usage += N;

			return this.buffer[this.usage .. this.usage + N];
		}

		return null;
	}

	void[] take(size_t N, size_t sizeOf) {
		return this.take(N * sizeOf);
	}

	size_t remain() const pure nothrow {
		return StackSize - this.usage;
	}

	void reset() {
		this.usage = 0;
	}
}

struct TypeAlloc {
	Memory mem;
	Stack stack;

	@disable
	this(this);
}

struct Indexer(T) {
private:
	T[] _storage;
	size_t _length = 0;

public:
	this(T[] store) {
		this._storage = store;
	}

	this(T* ptr, size_t length) {
		this(ptr[0 .. length]);
	}

	void set(T[] store) {
		assert(this._storage.length == 0);

		this._storage = store;
	}

	void set(T* ptr, size_t length) {
		this.set(ptr[0 .. length]);
	}

	void append(T elem) {
		this.append(elem);
	}

	void append(ref T elem) {
		if (this.remain() > 0)
			this._storage[this._length++] = elem;
	}

	void opOpAssign(string op : "~")(T elem) {
		this.append(elem);
	}

	void opOpAssign(string op : "~")(ref T elem) {
		this.append(elem);
	}

	size_t remain() const pure nothrow {
		return this.capacity() - this._length;
	}

	@property
	inout(T[]) ptr() inout pure nothrow {
		return this._storage;
	}

	@property
	size_t length() const pure nothrow {
		return this._length;
	}

	@property
	size_t capacity() const pure nothrow {
		return this._storage.length;
	}
}

unittest {
	Memory mem;
	Stack s;

	void* ptr = mem.malloc(128);
	assert(mem._pool.length == 1);
	assert(ptr in mem._pool);
	assert(ptr is mem._pool[ptr]);

	int[] arr1 = Array!int(&mem, &s).of(128);
	assert(mem._pool.length == 1);
	assert(s.usage == 128 * int.sizeof);

	int[] arr2 = Array!int(&mem, &s)[512];
	assert(mem._pool.length == 1);
	assert(s.usage == 128 * int.sizeof + 512 * int.sizeof);

	{
		int[] arr3 = Array!int(&mem, &s)[arr1.length];
		assert(mem._pool.length == 1);
		assert(s.usage == 2 * 128 * int.sizeof + 512 * int.sizeof);
	}

	assert(mem._pool.length == 1);
	assert(s.usage == 2 * 128 * int.sizeof + 512 * int.sizeof);

	{
		TypeAlloc ta;
		int[] arr4 = Array!int(&ta)[arr1.length];

		assert(ta.stack.usage == arr1.length * int.sizeof);
		assert(ta.mem._pool.length == 0);

		assert(mem._pool.length == 1);
		assert(s.usage == 2 * 128 * int.sizeof + 512 * int.sizeof);
	}

	assert(mem._pool.length == 1);
	assert(s.usage == 2 * 128 * int.sizeof + 512 * int.sizeof);

	import Dgame.Internal.util : list;

	int a, b, c, d;
	list(a, b, c, d) = arr1[0 .. 4];
	//writeln(a, "::", b, "::", c, "::", d);
	assert(a == 0
		   && b == 0
		   && c == 0
		   && d == 0);

	auto indexer = Indexer!int(arr1);
	indexer.append(1);
	indexer.append(2);
	indexer.append(3);
	indexer.append(4);

	list(a, b, c, d) = arr1[0 .. 4];
	//writeln(a, "::", b, "::", c, "::", d);
	assert(a == 1
		   && b == 2
		   && c == 3
		   && d == 4);
}