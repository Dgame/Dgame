/*
 *******************************************************************************************
 * Dgame (a D game framework) - Copyright (c) Randy Schütt
 * 
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not claim
 *    that you wrote the original software. If you use this software in a product,
 *    an acknowledgment in the product documentation would be appreciated but is
 *    not required.
 * 
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source distribution.
 *******************************************************************************************
 */
module Dgame.Internal.Unique;

debug import std.stdio;
private import Dgame.Internal.Allocator;
private import cstd = core.stdc.stdlib;

@property
string idOf(T)() {
	static if (__traits(compiles, { string s = T.stringof; }))
		return T.stringof;
	else
		return __traits(identifier, T);
}

void _def_del(T = void)(T* p) {
	cstd.free(p);
}

struct unique_ptr(T) {
	T* ptr;
	void function(T*) del_func;
	
	this(T* p, void function(T*) df = &_def_del!(T)) {
		this.ptr = p;
		this.del_func = df;
	}
	
	this(ref T* p, void function(T*) df = &_def_del!(T)) {
		this.ptr = p;
		this.del_func = df;
		
		p = null;
	}
	
	@disable
	this(this);
	
	~this() {
		if (this.del_func is null || this.ptr is null) {
			return;
		}

		debug writeln("Terminate unique ", idOf!(T));

		this.del_func(this.ptr);
	}
	
	T* release() pure nothrow {
		scope(exit) this.ptr = null;
		return this.ptr;
	}

	bool isValid() const pure nothrow {
		return this.ptr !is null;
	}

	alias ptr this;
}

unique_ptr!(T) move(T)(ref unique_ptr!(T) uniq) {
	return unique_ptr!(T)(uniq.release(), uniq.del_func);
}

unique_ptr!(T) make_unique(T)(auto ref T value, void function(T*) df = &_def_del!(T)) if (!is(T : U*, U)) {
	T* p;
	make(value, p);
	
	return make_unique(p, df);
}

unique_ptr!(T) make_unique(T, Args...)(void function(T*) df, Args args) {
	import std.conv : emplace;
	
	T* p = alloc_new!(T)(1);
	emplace(p, args);
	
	return make_unique(p, df);
}

unique_ptr!(T) make_unique(T, Args...)(Args args) {
	import std.conv : emplace;
	
	T* p = alloc_new!(T)(1);
	emplace(p, args);
	
	return make_unique(p);
}

unique_ptr!(T) make_unique(T)(auto ref T* p, void function(T*) df = &_def_del!(T)) {
	return unique_ptr!(T)(p, df);
}

unique_ptr!(T) allocate_unique(T)(size_t count, void function(T*) df = &_def_del!(T)) {
	T* p = alloc_new!(T)(count);
	
	return make_unique(p, df);
}

unittest {
	struct A {
		int id;
	}
	
	unique_ptr!(A) test(unique_ptr!(A) rhs) {
		assert(rhs.isValid());
		assert(rhs.id == 42);
		
		return move(rhs);
	}
	
	unique_ptr!(A) as = new A(42);
	
	assert(as.isValid());
	assert(as.id == 42);
	
	unique_ptr!(A) as2 = move(as);
	
	assert(!as.isValid());
	assert(as2.isValid());
	assert(as2.id == 42);
	
	unique_ptr!(A) as3 = test(move(as2));
	
	assert(!as2.isValid());
	assert(as3.isValid());
	assert(as3.id == 42);
}
