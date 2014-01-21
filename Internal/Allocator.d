module Dgame.Internal.Allocator;

private {
	debug import std.stdio : writefln;
}

T* type_malloc(T = void)(size_t count) {
	import core.stdc.stdlib : malloc;
	
	return cast(T*) malloc(T.sizeof * count);
}

T* type_calloc(T = void)(size_t count) {
	import core.stdc.stdlib : calloc;
	
	return cast(T*) calloc(T.sizeof, count);
}

void type_free(void* ptr) {
	import core.stdc.stdlib : free;

	free(ptr);
	ptr = null;
}