module Dgame.Internal.Allocator;

private {
	debug import std.stdio : writefln;
}

T* type_malloc(T)(size_t count) {
	import core.stdc.stdlib : malloc;
	
	return cast(T*) malloc(T.sizeof * count);
}

T* type_calloc(T)(size_t count) {
	import core.stdc.stdlib : calloc;
	
	return cast(T*) calloc(T.sizeof, count);
}

void type_free(T)(T* ptr) {
	import core.stdc.stdlib : free;

	free(ptr);
}

enum Init : ubyte {
	No,
	Yes
}