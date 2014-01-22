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

T* construct(T, Args...)(Args args) {
	T* ptr = type_calloc!T(1);
	
	static if (Args.length != 0) {
		static if (!is(T == struct))
			static assert(0, "Can only construct structs.");
		
		import core.stdc.string : memcpy;
		
		T temp = T(args);
		memcpy(ptr, &temp, T.sizeof);
	}
	
	return ptr;
}