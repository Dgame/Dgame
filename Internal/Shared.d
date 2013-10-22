module Dgame.Internal.Shared;

private {
	debug import std.stdio;
	import core.stdc.stdlib : malloc, free;
}

debug {
	static int _refCount;
	static int _sharedCount;

	static ~this() {
		writefln(" > Remaining shared_ref's: %d / %d", _refCount, _sharedCount);
	}
}

struct shared_ref(T) if (!is(T == class)) {
private:
	static struct Owner {
		static struct Ref {
			T* ptr;
			int count;

			void function(T*) destructFunc;
		}

		Ref* _ref;

		this(T* ptr, void function(T*) destructFunc) {
			debug {
				_sharedCount++;
				writefln(" > Create the %d shared_ref.", _sharedCount);
			}

			this._ref = cast(Ref*) malloc(Ref.sizeof);
			this._ref.ptr = ptr;
			this._ref.count = 0;
			this._ref.destructFunc = destructFunc;

			this.addRef();
		}

		bool isValid() const pure nothrow {
			return this._ref !is null;
		}

		void addRef() pure nothrow in {
			assert(this.isValid());
		} body {
			this._ref.count++;
			debug _refCount++;
		}

		void releaseRef() in {
			assert(this.isValid());
		} body {
			this._ref.count--;
			debug _refCount--;

			if (this._ref.count <= 0)
				this._destruct();
		}

		void _destruct() in {
			assert(this.isValid());
		} body {
			debug writefln("\tDestroy shared_ref with type = %s and func = %s (ptr = %X)",
						   __traits(identifier, T), typeof(&this._ref.destructFunc).stringof, this._ref.ptr);
			this._ref.destructFunc(this._ref.ptr);

			free(this._ref);
			this._ref = null;
		}
	}

	Owner _ownership;

public:
	this(T* ptr, void function(T*) df) {
		debug writefln("\tShared CTor for type %s with func = %s (ptr = %X)",
					   __traits(identifier, T), typeof(&df).stringof, ptr);

		this._ownership = Owner(ptr, df);
	}

	this(this) {
		debug writefln("\tShared Postblit for type %s (ptr = %X) with usage = %d",
					   __traits(identifier, T), this.ptr, this.usage);

		if (this._ownership.isValid())
			this._ownership.addRef();
	}

	~this() {
		debug writefln("\tShared DTor for type %s (ptr = %X) with usage = %d",
					   __traits(identifier, T), this.ptr, this.usage);

		if (this._ownership.isValid())
			this._ownership.releaseRef();
	}

	@disable
		void opAssign(T* ptr);

	void dissolve() {
		while (this._ownership.isValid() && this._ownership._ref.count > 0) {
			this._ownership.releaseRef();
		}
	}

	bool isValid() const pure nothrow {
		return this._ownership.isValid() && this.usage > 0;
	}

	@property
	int usage() const pure nothrow {
		if (this._ownership.isValid())
			return this._ownership._ref.count;

		return -1;
	}

	@property
	inout(T*) ptr() inout {
		return this._ownership.isValid() ? this._ownership._ref.ptr : null;
	}

	alias ptr this;
}

shared_ref!T make_shared(T)(T* ptr, void function(T*) df) {
	return shared_ref!T(ptr, df);
}

void dummy_deleter(void*) { }

unittest {
	import std.conv : to;

	struct A {
	public:
		int id;
	}

	void test(shared_ref!A rhs) {
		//assert(rhs.isCopy);
		assert(rhs.id == 42);
		assert(rhs.isValid());
		assert(rhs.usage == 2);
	}

	shared_ref!A as = make_shared(new A(42), (A* aptr) => dummy_deleter(aptr));
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

	shared_ref!A s1 = make_shared(new A(111), (A* aptr) => dummy_deleter(aptr));
	shared_ref!A s2 = s1;
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

	void test2(shared_ref!A rhs, int id) {
		//assert(rhs.isCopy);
		assert(rhs.id == id);
		assert(rhs.isValid());
		assert(rhs.usage == 2);
	}

	shared_ref!A s3 = make_shared(new A(23), (A* aptr) => dummy_deleter(aptr));
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
