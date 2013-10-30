/**
 * @file 
 *
 * allocator class.
 */
module Dgame.Internal.Allocator;

private {
	debug import std.stdio;
	import core.stdc.stdlib : malloc, free;
}

struct Type(T, const size_t StackSize = 4096 / T.sizeof) {
	static {
		T[StackSize] StackBuffer = void;
		size_t StackLength;
	}

	/**
	 * This structure represents a Variable Length Array as you may known from C99.
	 *
	 * @author: Besitzer
	 * @date: 27.10.2013
	 */
	static struct Vala {
		T* ptr;
		const size_t length;
		const bool onHeap;

		@disable
		this(this);

		~this() {
			debug writeln("DTor Vala");
			debug writeln("StackLength: ", StackLength);

			if (!this.onHeap)
				StackLength -= this.length;
			else if (this.ptr !is null) {
				debug writefln("Deallocate %d elements.", this.length);

				.free(this.ptr);
			}
		}

		inout(T[]) opSlice() inout {
			return this.ptr[0 .. this.length];
		}

		void opSliceAssign(T item) {
			for (size_t i = 0; i < this.length; ++i) {
				this.ptr[i] = item;
			}
		}

		void opSliceAssign(T[] items) {
			const size_t len = this.length > items.length ? items.length : this.length;
			for (size_t i = 0; i < len; ++i) {
				this.ptr[i] = items[i];
			}
		}

		void opSliceOpAssign(string op)(T item) {
			for (size_t i = 0; i < this.length; ++i) {
				mixin("this.ptr[i] " ~ op ~ "= item;");
			}
		}

		alias ptr this;
	}

	/**
	 * This is the start method to initialize a Variable Length Array.
	 *
	 * @author: Besitzer
	 * @date: 27.10.2013
	 */
	static Vala opIndex(size_t N) {
		if ((StackLength + N) <= StackSize) {
			debug writefln("Allocate %d elements on the stack.", N);
			scope(exit) StackLength += N;

			return Vala(&StackBuffer[StackLength], N, false);
		}

		debug writefln("Allocate %d elements on the heap.", N);

		return Vala(cast(T*) .malloc(N * T.sizeof), N, true);
	}
}

unittest {
	int n = 128;
	auto t = Type!int[n];

	assert(t.length == n);
	assert(t.onHeap == false);

	int[] arr = t[];
	assert(arr.length == n);

	t[0] = 42;
	assert(arr[0] == t[0] && t[0] == 42);

	ushort w = 1024;
	ushort h = 640;

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

	assert(Type!int.StackLength == 640);

	auto test2 = Type!int[384];
	assert(test2.length == 384);
	assert(test2.onHeap == false);

	assert(test2[0] != 42 && test2[42] != 1337);

	auto test3 = Type!int[256];
	assert(test3.length == 256);
	assert(test3.onHeap == true);

	assert(test3[0] != 42 && test3[42] != 1337);
}