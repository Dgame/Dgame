module Dgame.Core.Memory.SmartPointer.Shared;

private {
	debug import std.stdio;
	import core.stdc.stdlib : malloc, free;
	import std.conv : emplace;
}

void dummy_deleter(void*) { }

private mixin template Make(T) {
	static T* make(Args...)(Args args) {
		T* mem = cast(T*) .malloc(T.sizeof);
		
		return .emplace(mem, args);
	}
	
	static void free(ref T* ptr) {
		.destroy(*ptr); /// for DTor call
		.free(ptr);
		
		ptr = null;
	}
}

private struct Counter {
public:
	int count = 1;
	
	int inc() pure nothrow {
		return ++this.count;
	}
	
	int dec() pure nothrow {
		return --this.count;
	}
	
	mixin Make!(typeof(this));
} unittest {
	writeln("unittest for Counter");
	
	Counter* c1;
	assert(c1 is null);
	{
		scope(exit) Counter.free(c1);
		
		c1 = Counter.make();
		
		assert(c1 !is null);
		assert(c1.count == 1);
		c1.inc();
		assert(c1.count == 2);
		c1.dec();
		assert(c1.count == 1);
	}
	assert(c1 is null);
}

private struct Payload(T) {
public:
	T* ptr;
	Counter* counter;
	
	this(T* ptr) in {
		assert(ptr !is null);
	} body {
		this.ptr = ptr;
		this.counter = Counter.make();
	}
	
	~this() {
		debug writeln("Delete Payload and Counter");
		
		Counter.free(this.counter);
	}
	
	mixin Make!(typeof(this));
} unittest {
	writeln("unittest for Payload");
	
	int i = 42;
	
	Payload!(int)* p1;
	assert(p1 is null);
	{
		scope(exit) Payload!(int).free(p1);
		
		p1 = Payload!(int).make(&i);
		
		assert(p1 !is null);
		assert(p1.ptr !is null);
		assert(*p1.ptr == i);
	}
	assert(p1 is null);
}

struct shared_ptr(T, alias _deleter = dummy_deleter)
	if (!is(T == class) && !is(T : U*, U))
{
private:
	Payload!(T)* _payload;
	
	static int _id;
	
	void _destruct() {
		_deleter(this._payload.ptr);
		
		this._payload.ptr = null;
		typeof(this._payload).free(this._payload);
	}
	
public:
	@disable
	this(typeof(null));
	
	this(T* ptr) {
		this._payload = Payload!T.make(ptr);
		
		_id++;
	}
	
	this(this) {
		if (this._payload !is null)
			this._payload.counter.inc();
		
		_id++;
	}
	
	void opAssign(ref shared_ptr!T sptr) in {
		assert(sptr.isValid());
	} body {
		if (!this.isValid())
			_id++;
		
		this.release();
		
		this._payload = sptr._payload;
		this._payload.counter.inc();
	}
	
	void opAssign(shared_ptr!T sptr) {
		this.opAssign(sptr);
	}
	
	~this() {
		this.release();
		
		_id--;
	}
	
	void release() {
		if (!this.isValid()) {
			debug writeln("Delete invalid shared_ptr :: ",
			              __traits(identifier, _deleter),
			              " :: ", _id,
			              " :: ", this._payload ? this._payload.ptr : null);
			
			return;
		}
		
		if (!this._payload.counter.dec()) {
			debug writeln("Destruct with ",
			              __traits(identifier, _deleter),
			              " :: ", _id,
			              " :: ", this._payload ? this._payload.ptr : null);
			
			this._destruct();
		} else {
			debug writeln("One out with ",
			              __traits(identifier, _deleter),
			              " :: ", _id,
			              " :: ", this._payload ? this._payload.ptr : null);
		}
	}
	
	void reset(T* ptr) in {
		assert(ptr !is null);
	} body {
		this.release();
		
		this._payload = Payload!T.make(ptr);
	}
	
	@property
	inout(T*) ptr() inout pure nothrow {
		if (this._payload !is null)
			return this._payload.ptr;
		
		return null;
	}
	
	alias ptr this;
	
	@property
	int usage() const pure nothrow {
		return this._payload !is null ? this._payload.counter.count : -1;
	}
	
	bool isValid() const pure nothrow {
		return this._payload !is null ? this._payload.ptr !is null : false;
	}
	
	static int ID() {
		return _id;
	}
}

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
	
	shared_ptr!A as = new A(42);
	
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
	
	assert(s1.usage == 2);
	assert(s2.usage == 2);
	//assert(s2.isCopy());
	assert(s1 == s2);
	
	s1.reset(new A(222));
	
	debug writeln("\t\t", s1.usage, "::", s2.usage);
	
	assert(s1.isValid());
	assert(s2.isValid());
	assert(s1.usage == 1, to!string(s1.usage));
	assert(s2.usage == 1, to!string(s2.usage));
	//assert(s2.isCopy());
	assert(s1 != s2);
	
	void testDeleter(A* ptr) {
		
	}
	
	void test2(shared_ptr!(A, testDeleter) rhs, int id) {
		//assert(rhs.isCopy);
		assert(rhs.id == id);
		assert(rhs.isValid());
		assert(rhs.usage == 2);
	}
	
	shared_ptr!(A, testDeleter) s3 = new A(23);
	
	assert(s3.isValid());
	assert(s3.id == 23);
	assert(s3.usage == 1);
	
	test2(s3, 23);
	
	assert(s3.isValid());
	assert(s3.id == 23);
	assert(s3.usage == 1);
	
	s3.reset(new A(42));
	
	assert(s3.isValid());
	assert(s3.id == 42);
	assert(s3.usage == 1);
}