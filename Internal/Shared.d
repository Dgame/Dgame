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

debug {
	static int _refCount;
	static int _sharedCount;
	
	static ~this() {
		writefln(" > Remaining shared_ptr's: %d / %d", _refCount, _sharedCount);
	}
}

struct shared_ptr(T)
	if (!is(T : U*, U) && !is(T == class) && !is(T : U[], U))
{
	static struct Shared {
		T* ptr;
		int usage;
		void function(T*) deleter;
	}
	
	Shared* _share;
	
	this(T* ptr, void function(T*) deleter = null) {
		debug {
			_sharedCount++;
			writefln(" > Create the %d shared_ptr.", _sharedCount);
		}
		
		debug writefln("\tShared CTor for type %s (ptr = %X)",
		               __traits(identifier, T), ptr);
		
		this._share = new Shared(ptr, 0, deleter);
		
		this.addRef();
	}
	
	this(this) {
		debug writefln("\tShared Postblit for type %s (ptr = %X) with usage = %d",
		               __traits(identifier, T), this.ptr, this.usage);
		
		this.addRef();
	}
	
	void opAssign(shared_ptr!T sptr) {
		this.releaseRef();
		
		this._share = sptr._share;
		sptr.addRef();
	}
	
	void opAssign(T* ptr) {
		this.releaseRef();
		
		this._share = new Shared(ptr);
		
		this.addRef();
	}
	
	~this() {
		debug writefln("\tShared DTor for type %s (ptr = %X) with usage = %d",
		               __traits(identifier, T), this.ptr, this.usage);
		
		this.releaseRef();
	}
	
	bool isValid() const pure nothrow {
		return this._share !is null;
	}
	
	int usage() const pure nothrow {
		return this.isValid() ? this._share.usage : -1;
	}
	
	void addRef() {
		if (!this.isValid())
			return;
		
		this._share.usage++;
		debug _refCount++;
	}
	
	void releaseRef() {
		if (!this.isValid())
			return;
		
		this._share.usage--;
		debug _refCount--;
		
		if (this._share.usage <= 0)
			this.release();
	}
	
	void dissolve() {
		while (this.isValid() && this.usage > 0) {
			this.releaseRef();
		}
	}
	
	void release() {
		if (this.isValid()) {
			if (this._share.deleter !is null) {
				debug writefln("\tShared: Destroy type %s (ptr = %X)",
				               __traits(identifier, T), this.ptr);
				this._share.deleter(this._share.ptr);
				
				this._share.ptr = null;
				
				delete this._share;
			}
		}
	}
	
	@property
	inout(T*) ptr() inout pure nothrow {
		return this.isValid() ? this._share.ptr : null;
	}
	
	alias ptr this;
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
		assert(_refCount == 1, to!string(_refCount));
		
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
		assert(_refCount == 3, to!string(_refCount));
		
		assert(s1.usage == 2);
		assert(s2.usage == 2);
		//assert(s2.isCopy());
		assert(s1 == s2);
		
		s1 = new A(222);
		assert(_refCount == 3, to!string(_refCount));
		
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
		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 23);
		assert(s3.usage == 1);
		
		test2(s3, 23);
		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 23);
		assert(s3.usage == 1);
		
		s3 = new A(42);
		assert(_refCount == 4, to!string(_refCount));
		
		assert(s3.isValid());
		assert(s3.id == 42);
		assert(s3.usage == 1);
	}
	
	assert(_refCount == 0);
}