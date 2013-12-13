module Dgame.Internal.Allocator;

private {
	debug import std.stdio : writefln;
}

struct New(T) if (!is(T : U[], U)) {
	static T* opIndex(size_t size) {
		import core.stdc.stdlib : calloc;

		T* ptr = cast(T*) calloc(size, T.sizeof);
		debug writefln(" :: Allocate %d %s's. ptr = %x", size, T.stringof, ptr);

		return ptr;
	}
}

struct Delete {
	static void opCall(void* ptr) {
		import core.stdc.stdlib : free;
		
		debug writefln(" :: Free ptr = %x", ptr);
		
		free(ptr);
		ptr = null;
	}
}