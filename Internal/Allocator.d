module Dgame.Internal.Allocator;

private {
	debug import std.stdio : writefln;
}

enum Init : ubyte {
	No,
	Yes
}

struct New(T, Init init = Init.No) if (!is(T : U[], U)) {
	static T* opIndex(size_t size) {
		import core.stdc.stdlib : malloc, calloc;
		
		static if (init == Init.Yes)
			T* ptr = cast(T*) calloc(size, T.sizeof);
		else
			T* ptr = cast(T*) malloc(size * T.sizeof);
		
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