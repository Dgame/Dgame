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

debug import std.stdio : writefln;
private import Dgame.Internal.Allocator : type_calloc, type_free, construct;

struct shared_ptr(T) {
	struct Shared {
		T* ptr;
		int count;
		void function(T*) t_del;
		void function(void*) any_del;
	}
	
	private Shared* _shared;
	
	this(T* ptr) {
		this._shared = construct!Shared(ptr, 1);
	}
	
	this(T* ptr, void function(T*) t_del) {
		this._shared = construct!Shared(ptr, 1, t_del);
	}
	
	this(T* ptr, void function(void*) any_del) {
		this._shared = construct!Shared(ptr, 1, null, any_del);
	}
	
	this(this) {
		if (this._shared !is null)
			this._shared.count++;
	}
	
	~this() {
		debug writefln("DTor shared_ptr!%s: usage = %d", __traits(identifier, T), this.usage());

		if (this._shared !is null) {
			this._shared.count--;
			if (this._shared.count <= 0) {
				this.release();
			}
		}
	}

	bool isValid() const pure nothrow {
		return this._shared !is null;
	}

	void release() {
		if (this._shared.t_del !is null)
			this._shared.t_del(this._shared.ptr);
		else if (this._shared.any_del !is null)
			this._shared.any_del(this._shared.ptr);

		type_free(this._shared);
		this._shared = null;
	}
	
	void dissolve() {
		if (this._shared is null)
			return;
		
		while (this._shared.count > 1) {
			this._shared.count--;
		}
	}
	
	@property
	inout(T*) ptr() inout pure nothrow {
		if (this._shared !is null)
			return this._shared.ptr;
		
		return null;
	}
	
	alias ptr this;
	
	int usage() const pure nothrow {
		if (this._shared !is null)
			return this._shared.count;
		
		return -1;
	}
}

shared_ptr!T make_shared(T)(T* ptr, void function(T*) deleter) {
	return shared_ptr!T(ptr, deleter);
}

unittest {
	import std.conv : to;
	
	struct A {
		int id;
	}
	
	{
		void test(shared_ptr!A rhs) {
			//assert(rhs.isCopy);
			assert(rhs.id == 42);
			assert(rhs.isValid());
			assert(rhs.usage == 2);
		}
		
		shared_ptr!A as = new A(42);
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
		
		shared_ptr!A s1 = new A(111);
		shared_ptr!A s2 = s1;
//		assert(_refCount == 3, to!string(_refCount));
		
		assert(s1.usage == 2);
		assert(s2.usage == 2);
		//assert(s2.isCopy());
		assert(s1 == s2);
		
		s1 = shared_ptr!A(new A(222));
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
		
		void test2(shared_ptr!A rhs, int id) {
			//assert(rhs.isCopy);
			assert(rhs.id == id);
			assert(rhs.isValid());
			assert(rhs.usage == 2);
		}
		
		shared_ptr!A s3 = new A(23);
//		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 23);
		assert(s3.usage == 1);
		
		test2(s3, 23);
//		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 23);
		assert(s3.usage == 1);
		
		s3 = shared_ptr!A(new A(42));
//		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 42);
		assert(s3.usage == 1);
	}
	
//	assert(_refCount == 0);
}