module Dgame.Core.Memory.Allocator;

private {
	import core.memory : GC;
	import core.stdc.stdlib : alloca, malloc, free;
}

@property @trusted
T[] stack_alloc(T, alias N)(void* ptr = .alloca(N * T.sizeof)) {
	return (cast(T*) ptr)[0 .. N];
}

@trusted
T[] heap_alloc(T)(size_t N) {
	return (cast(T*) .malloc(T.sizeof * N))[0 .. N];
}

@trusted
void heap_free(T)(ref T[] arr) {
	static if (is(T == struct)) {
		foreach (ref T val; arr) {
			.destroy!T(val);
		}
	}
	
	.free(arr.ptr);
	arr = null;
}

enum {
	GC_Collect = 1,
	GC_Minimize = 2
}

void gc_free(T)(ref T[] arr, uint mode = 0) {
	static if (is(T == struct)) {
		foreach (ref T val; arr) {
			.destroy!T(val);
		}
	}
	
	GC.free(arr.ptr);
	arr = null;
	
	if (mode & GC_Collect)
		GC.collect();
	
	if (mode & GC_Minimize)
		GC.minimize();
}