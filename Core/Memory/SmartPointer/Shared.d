module Dgame.Core.Memory.SmartPointer.Shared;

private debug import std.stdio : writeln, writefln;

private static int _refCount = 0;

debug static ~this() {
	writefln("%d shared_ref's remain.", _refCount);
}

private struct Ref(T) {
private:
	void function(T*) _deleter;

	void _destruct() {
		debug writefln("Destruct %s with %s (ptr = %X)",
				 __traits(identifier, T), typeof(&this._deleter).stringof, this._ptr);

		if (this._ptr !is null) {
			_deleter(this._ptr);
			this._ptr = null;

			_refCount--;
		}
	}

	int _usage;
	T* _ptr;

public:
	@disable
	this();

	@disable
	this(this);

	@disable
	this(typeof(null));

	@disable
	void opAssign(Ref!(T)*);

	this(T* ptr, void function(T*) _deleter) {
		this._ptr = ptr;
		this._deleter = _deleter;

		_refCount++;
	}

	void addRef() {
		this._usage++;
	}

	void releaseRef() {
		debug writefln("Release %s with %s (%d usage :: ptr = %X)",
				 __traits(identifier, T), typeof(&this._deleter).stringof, this._usage, this._ptr);

		this._usage--;

		if (this._usage <= 0)
			this._destruct();
	}

	@property
	int usage() const pure nothrow {
		return this._usage;
	}
}

shared_ref!T make_shared(T)(T* ptr, void function(T*) _deleter) {
	auto _ref = new Ref!T(ptr, _deleter);
	_ref.addRef();

	return shared_ref!T(_ref);
}

struct shared_ref(T) {
private:
	Ref!(T)* _ref;

	this(Ref!(T)* _ref) {
		this._ref = _ref;
	}

public:
	this(this) {
		if (this._ref !is null)
			this._ref.addRef();
	}

	~this() {
		if (this._ref !is null)
			this._ref.releaseRef();
	}

	void collect() {
		if (this._ref !is null) {
			while (this._ref.usage > 0) {
				this._ref.releaseRef();
			}
		}
	}

	@property
	inout(T*) ptr() inout pure nothrow {
		if (this._ref!is null)
			return this._ref._ptr;

		return null;
	}

	alias ptr this;

	@property
	int usage() const pure nothrow {
		return this._ref !is null ? this._ref.usage : -1;
	}

	bool isValid() const pure nothrow {
		return this._ref !is null ? this._ref._ptr !is null : false;
	}
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

	assert(s1.usage == 2);
	assert(s2.usage == 2);
	//assert(s2.isCopy());
	assert(s1 == s2);

	s1 = make_shared(new A(222), (A* aptr) => dummy_deleter(aptr));

	debug writeln("\t\t", s1.usage, "::", s2.usage);

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

	assert(s3.isValid());
	assert(s3.id == 23);
	assert(s3.usage == 1);

	test2(s3, 23);

	assert(s3.isValid());
	assert(s3.id == 23);
	assert(s3.usage == 1);

	s3 = make_shared(new A(42), (A* aptr) => dummy_deleter(aptr));

	assert(s3.isValid());
	assert(s3.id == 42);
	assert(s3.usage == 1);
}