module Dgame.Core.Memory.Allocator;

private import core.stdc.stdlib : /*alloca, */malloc, free;

/*
@property @trusted
T[] stack_alloc(T, alias N)(void* ptr = .alloca(N * T.sizeof)) {
	return (cast(T*) ptr)[0 .. N];
}
*/

/// dyn(amic) c alloc(ation)
@trusted
T[] dync_alloc(T)(size_t N) {
	return (cast(T*) .malloc(T.sizeof * N))[0 .. N];
}

/// dyn(amic) c free
@trusted
void dync_free(T)(ref T[] arr) {
	static if (is(T == struct)) {
		foreach (ref T val; arr) {
			.destroy!T(val);
		}
	}
	
	.free(arr.ptr);
	arr = null;
}