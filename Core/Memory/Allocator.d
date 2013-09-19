module Dgame.Core.Memory.Allocator;

private import core.stdc.stdlib : malloc, realloc, free;

final abstract class Memory {
public:
	static T* allocate(T)(size_t capacity) {
		return cast(T*) Memory.rawAllocate!T(capacity);
	}
	
	static void* rawAllocate(T)(size_t capacity) {
		return .malloc(capacity * T.sizeof);
	}
	
	static T* reallocate(T)(T* ptr, size_t capacity) {
		ptr = cast(T*) .realloc(ptr, capacity * T.sizeof);
		if (!ptr)
			assert(0, "Out of memory");
		
		return ptr;
	}
	
	static void deallocate(T)(ref T* ptr) {
		.free(ptr);
		
		ptr = null;
	}
}