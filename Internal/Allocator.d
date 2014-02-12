module Dgame.Internal.Allocator;

private import cstd = core.stdc.stdlib;

T* make(T)(ref T* p, size_t count = 1)
	if (!is(T : U[], U))
in {
	assert(p is null);
	assert(count > 0 && count < int.max);
} body {
	p = cast(T*) cstd.calloc(count, T.sizeof);
	return p;
}

T* make(T)(auto ref T value, ref T* p, size_t count = 1)
	if (!is(T : U[], U))
in {
	assert(p is null);
	assert(count > 0 && count < short.max);
} body {
	p = cast(T*) cstd.malloc(count * T.sizeof);
	
	for (size_t i = 0; i < count; i++) {
		p[i] = value;
	}
	
	return p;
}

T* alloc_new(T = void)(size_t count)
	if (!is(T : U[], U))
in {
	assert(count > 0);
} body {
	T* p;
	return make(p, count);
}

T* make_new(T = void)(auto ref T value, size_t count = 1)
	if (!is(T : U[], U))
in {
	assert(count > 0);
} body {
	T* p = alloc_new!(T)(count);
	*p = value;
	
	return p;
}

void unmake(T)(ref T* p)
	if (!is(T : U[], U))
{
	static if (!is(T == void))
		.destroy!T(*p);
	cstd.free(p);
	p = null;
}

T* remake(T)(ref T* p, size_t cap)
	if (!is(T : U[], U))
in {
	assert(p !is null);
	assert(cap > 0);
} body {
	p = cast(T*) cstd.realloc(p, cap * T.sizeof);
	
	return p;
}