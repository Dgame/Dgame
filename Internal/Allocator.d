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

void type_free(void* ptr) {
	import core.stdc.stdlib : free;

	free(ptr);
	ptr = null;
}

struct auto_ptr(T)
	if (!is(T : U*, U) && !is(T == class) && !is(T : U[], U))
{
	T* ptr;
	void function(T*) t_del;
	void function(void*) uni_del;

	this(T* ptr, void function(T*) del) {
		this.ptr = ptr;
		this.t_del = del;
	}

	this(T* ptr, void function(void*) del = &type_free) {
		this.ptr = ptr;
		this.uni_del = del;
	}

	@disable {
		this();
		this(this);
		this(typeof(null));
		void opAssign(T*);
	}

	~this() {
		if (this.uni_del !is null)
			this.uni_del(this.ptr);
		else if (this.t_del !is null)
			this.t_del(this.ptr);

		this.ptr = null;
	}

	alias ptr this;
}