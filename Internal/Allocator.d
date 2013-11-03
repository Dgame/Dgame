module Dgame.Internal.Allocator;

private {
	debug import std.stdio;

	import core.memory : GC;
	import core.stdc.stdlib : malloc, free;
}

enum DefaultSize = 8192;

struct Type(T, ushort StackSize = DefaultSize / T.sizeof) {
	static StackBuffer!(T, StackSize) _Buffer;

	struct Vala {
		T* ptr;
		size_t length;
		bool onHeap;

		this(T* ptr, size_t length, bool onHeap) {
			this.ptr = ptr;
			this.length = length;
			this.onHeap = onHeap;
		}

		@disable
		this(this);

		~this() {
			if (this.onHeap && this.ptr !is null)
				.free(this.ptr);
		}

		T* move() {
			scope(exit) this.ptr = null;

			return this.ptr;
		}

		alias ptr this;

		inout(T[]) opSlice() inout {
			if (this.ptr is null)
				return null;

			return this.ptr[0 .. this.length];
		}

		inout(T[]) opSlice(size_t i1, size_t i2) inout {
			return this.ptr[i1 .. i2];
		}

		void opSliceAssign(T item) {
			if (this.ptr is null)
				return;

			this.ptr[0 .. this.length] = item;
		}

		void opSliceOpAssign(string op)(T item) {
			if (this.ptr is null)
				return;

			mixin("this.ptr[0 .. this.length] " ~ op ~ "= item;");
		}

		void opSliceAssign(T[] items) {
			if (this.ptr is null)
				return;

			this.ptr[0 .. items.length] = items;
		}
	}

	static int remain() {
		return _Buffer.remain();
	}

	static Vala opIndex(size_t N) {
		T* ptr = null;
		bool onHeap = false;

		T[] buf = _Buffer[N];

		if (buf.length != 0)
			ptr = &buf[0];
		else {
			ptr = cast(T*) .malloc(N * T.sizeof);
			onHeap = true;
		}

		return Vala(ptr, N, onHeap);
	}
}

struct Stack(T, ushort StackSize = DefaultSize / T.sizeof) {
	alias Limit = StackSize;

	static T[Limit] Buffer = void;
	static ushort StackUsage;

	static T[] opIndex(size_t N) {
		if (N <= (Limit - StackUsage)) {
			scope(exit) StackUsage += N;

			return Buffer[StackUsage .. StackUsage + N];
		}

		return null;
	}
}

struct StackBuffer(T, ushort StackSize = DefaultSize / T.sizeof) {
	alias Limit = StackSize;

	T[Limit] Buffer = void;
	ushort stackUsage;

	int remain() const pure nothrow {
		return Limit - this.stackUsage;
	}

	T[] opIndex(size_t N) {
		if (N <= this.remain()) {
			scope(exit) this.stackUsage += N;

			return Buffer[this.stackUsage .. this.stackUsage + N];
		}

		return null;
	}
}

unittest {
	import std.conv : to;

	int n = 128;
	auto t = Type!int[n];

	assert(t.length == n);
	assert(t.onHeap == false);

	int[] arr = t[];
	assert(arr.length == n);

	t[0] = 42;
	assert(arr[0] == t[0] && t[0] == 42);

	ushort w = 1920;
	ushort h = 1080;

	auto foo1 = Type!ubyte[w * h * 4];
	assert(foo1.length == w * h * 4);
	assert(foo1.onHeap == true);

	auto foo2 = Type!ubyte[w * 4];
	assert(foo2.length == w * 4);
	assert(foo2.onHeap == false);

	auto test1 = Type!int[512];
	assert(test1.length == 512);
	assert(test1.onHeap == false);
	assert(test1[0] != 42);

	test1[42] = 1337;

	assert(Type!int.remain() == 384);

	auto test2 = Type!int[384];
	assert(test2.length == 384);
	assert(test2.onHeap == false);

	assert(test2[0] != 42 && test2[42] != 1337);

	auto test3 = Type!int[256];
	assert(test3.length == 256);
	assert(test3.onHeap == true);

	assert(test3[0] != 42 && test3[42] != 1337);
}

enum Memory {
	C,
	GC
}

T* heap_alloc(T = void)(size_t N, Memory mem = Memory.C) {
	final switch (mem) {
		case Memory.C: return cast(T*) .malloc(N * T.sizeof);
		case Memory.GC: return cast(T*) GC.malloc(N * T.sizeof);
	}
}

void heap_free(void* ptr, Memory mem = Memory.C) {
	final switch (mem) {
		case Memory.C: free(ptr); break;
		case Memory.GC: GC.free(ptr); break;
	}
}