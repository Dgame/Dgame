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
module Dgame.Internal.Shared;

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

struct shared_ptr(T) {
	T* ptr;
	int* rc;
	void function(T*) del_func;
	
	this(T* p, void function(T*) df = &_def_del!(T)) {
		this.ptr = p;
		this.del_func = df;
		
		this.retain();
	}
	
	this(this) {
		this.retain();
	}
	
	~this() {
		this.release();
	}
	
	void retain() {
		import core.stdc.stdlib : calloc;
		
		if (this.rc is null)
			this.rc = alloc_new!(int)(1);
		(*this.rc)++;
		
		debug writeln("Retain: ", this.usage(), "::", idOf!(T));
	}
	
	void release() {
		if (this.rc is null)
			return;
		(*this.rc)--;

		debug writeln("Release: ", this.usage(), "::", idOf!(T));

		if (this.usage() <= 0) {
			this.terminate();
		}
	}

	void terminate() {
		if (this.del_func is null || this.ptr is null) {
			return;
		}

		debug writeln("Terminate shared ", idOf!(T));

		this.del_func(this.ptr);
		unmake(this.rc);
		this.ptr = null;
	}
	
	int usage() const pure nothrow {
		if (this.rc is null)
			return 0;
		return *this.rc;
	}

	bool isValid() const pure nothrow {
		return this.ptr !is null;
	}
	
	alias ptr this;
}

shared_ptr!(T) make_shared(T)(auto ref T value, void function(T*) df = &_def_del!(T)) if (!is(T : U*, U)) {
	T* p;
	make(value, p);
	
	return make_shared(p);
}

shared_ptr!(T) make_shared(T, Args...)(void function(T*) df, Args args) {
	T* p = alloc_new!(int)(1);
	emplace(p, args);

	return make_shared(p, df);
}

shared_ptr!(T) make_shared(T, Args...)(Args args) {
	T* p = alloc_new!(int)(1);
	emplace(p, args);
	
	return make_shared(p);
}

shared_ptr!(T) make_shared(T)(T* p, void function(T*) df = &_def_del!(T)) {
	return shared_ptr!(T)(p, df);
}

shared_ptr!(T) allocate_shared(T)(size_t count, void function(T*) df = &_def_del!(T)) {
	T* p = alloc_new!(T)(count);
	
	return make_shared(p, df);
}

unittest {
	import std.conv : to;
	
	struct A {
		int id;
	}
	
	{
		void test(shared_ptr!(A) rhs) {
			//assert(rhs.isCopy);
			assert(rhs.id == 42);
			assert(rhs.isValid());
			assert(rhs.usage == 2);
		}
		
		shared_ptr!(A) as = new A(42);
//		assert(_refCount == 1, to!string(_refCount));
		
		assert(as.id == 42);
		assert(as.usage == 1);
		assert(as.isValid());
		//assert(!as.isCopy);
		
		test(as);
		
		assert(as.id == 42);
		assert(as.usage == 1);
		assert(as.isValid());
		//assert(!as.isCopy);
		
		shared_ptr!(A) s1 = new A(111);
		shared_ptr!(A) s2 = s1;
//		assert(_refCount == 3, to!string(_refCount));
		
		assert(s1.usage == 2);
		assert(s2.usage == 2);
		//assert(s2.isCopy());
		assert(s1 == s2);
		
		s1 = shared_ptr!(A)(new A(222));
//		assert(_refCount == 3, to!string(_refCount));
		
		//debug writeln("\t\t", s1.usage, "::", s2.usage);
		
		assert(s1.isValid());
		assert(s2.isValid());
		assert(s1.usage == 1, to!string(s1.usage));
		assert(s2.usage == 1, to!string(s2.usage));
		//assert(s2.isCopy());
		assert(s1 != s2);
		
		void testDeleter(A* ptr) {
			
		}
		
		void test2(shared_ptr!(A) rhs, int id) {
			//assert(rhs.isCopy);
			assert(rhs.id == id);
			assert(rhs.isValid());
			assert(rhs.usage == 2);
		}
		
		shared_ptr!(A) s3 = new A(23);
//		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 23);
		assert(s3.usage == 1);
		
		test2(s3, 23);
//		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 23);
		assert(s3.usage == 1);
		
		s3 = shared_ptr!(A)(new A(42));
//		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 42);
		assert(s3.usage == 1);
	}
	
//	assert(_refCount == 0);
}