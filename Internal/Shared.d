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

private {
	debug import std.stdio;
	import core.stdc.stdlib : malloc, free;
}

debug {
	static int _refCount;
	static int _sharedCount;

	static ~this() {
		writefln(" > Remaining shared_ptr's: %d / %d", _refCount, _sharedCount);
	}
}

struct shared_ptr(T) {
	struct Ref {
		T* ptr;
		int usage;

		void function(T*) clean_up;

		void addRef()/* pure nothrow */{
			this.usage++;
			debug _refCount++;
		}

		void releaseRef()/* pure nothrow */{
			this.usage--;
			debug _refCount--;
		}

		void destruct() {
			this.clean_up(this.ptr);
		}
	}

	Ref* _ref;

	this(T* ptr, void function(T*) clean_up) {
		debug writefln("\tShared CTor for type %s with func = %s (ptr = %X)",
						   __traits(identifier, T), typeof(&clean_up).stringof, ptr);

		this._ref = cast(Ref*) .malloc(Ref.sizeof);

		this._ref.ptr = ptr;
		this._ref.usage = 0;
		this._ref.clean_up = clean_up;

		debug {
			_sharedCount++;
			writefln(" > Create the %d shared_ptr.", _sharedCount);
		}

		this._ref.addRef();
	}

	this(T* ptr) {
		this(ptr, null);
	}

	this(this) {
		debug writefln("\tShared Postblit for type %s (ptr = %X) with usage = %d",
						   __traits(identifier, T), this.ptr, this.usage);

		if (this.isValid())
			this._ref.addRef();
	}

	~this() {
		debug writefln("\tShared DTor for type %s (ptr = %X) with usage = %d",
						   __traits(identifier, T), this.ptr, this.usage);

		if (this.isValid()) {
			this._ref.releaseRef();

			if (this._ref.usage <= 0)
				this.release();
		}
	}

	void release() {
		if (this.isValid() && this._ref.clean_up !is null) {
			debug writefln(" > Destroy shared_ptr with type = %s and func = %s (ptr = %X)",
							   __traits(identifier, T), typeof(&this._ref.clean_up).stringof, this._ref.ptr);

			this._ref.destruct();

			.free(this._ref);
			this._ref = null;
		}
	}

	void dissolve()/* pure nothrow */{
		while (this.isValid() && this._ref.usage > 0) {
			this._ref.releaseRef();
		}
	}

	bool isValid() const pure nothrow {
		return this._ref !is null;
	}

	@property
		int usage() const pure nothrow {
			if (this.isValid())
				return this._ref.usage;

			return -1;
		}

	@property
		inout(T*) ptr() inout pure nothrow {
			return this.isValid() ? this._ref.ptr : null;
		}

	alias ptr this;
}

shared_ptr!T make_shared(T)(T* ptr, void function(T*) df) {
	return shared_ptr!T(ptr, df);
}

void dummy_deleter(void*) { }

unittest {
	import std.conv : to;

	struct A {
	public:
		int id;
	}

	void test(shared_ptr!A rhs) {
		//assert(rhs.isCopy);
		assert(rhs.id == 42);
		assert(rhs.isValid());
		assert(rhs.usage == 2);
	}

	shared_ptr!A as = make_shared(new A(42), (A* aptr) => dummy_deleter(aptr));
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

	shared_ptr!A s1 = make_shared(new A(111), (A* aptr) => dummy_deleter(aptr));
	shared_ptr!A s2 = s1;
	assert(_refCount == 3, to!string(_refCount));

	assert(s1.usage == 2);
	assert(s2.usage == 2);
	//assert(s2.isCopy());
	assert(s1 == s2);

	s1 = make_shared(new A(222), (A* aptr) => dummy_deleter(aptr));
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

	shared_ptr!A s3 = make_shared(new A(23), (A* aptr) => dummy_deleter(aptr));
	assert(_refCount == 4, to!string(_refCount));

	assert(s3.isValid());
	assert(s3.id == 23);
	assert(s3.usage == 1);

	test2(s3, 23);
	assert(_refCount == 4, to!string(_refCount));

	assert(s3.isValid());
	assert(s3.id == 23);
	assert(s3.usage == 1);

	s3 = make_shared(new A(42), (A* aptr) => dummy_deleter(aptr));
	assert(_refCount == 4, to!string(_refCount));

	assert(s3.isValid());
	assert(s3.id == 42);
	assert(s3.usage == 1);
}
