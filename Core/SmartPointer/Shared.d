module Dgame.Core.SmartPointer.Shared;

private {
	debug import std.stdio;
	
	import Dgame.Core.SmartPointer.util;
}

private struct RefCounter {
public:
	int counter;
	
	this(int startval) {
		this.counter = startval;
	}
	
	int inc() pure nothrow {
		return ++this.counter;
	}
	
	int dec() pure nothrow {
		return --this.counter;
	}
}

shared_ptr!T make_shared(T)(T* ptr)
	if (is(T == struct))
{
	return shared_ptr!T(ptr);
}

private static int shared_counter = 0;

struct shared_ptr(T, alias _deleter = deallocate)
	if (is(T == struct))
{
private:
	T* _ptr;
	RefCounter* _inuse;
	
	bool _isCopy;
	
	void _destruct() {
		if (this._ptr) {
			_deleter(this._ptr);
			debug writeln("delete SM with: ", __traits(identifier, _deleter));
		}
	}
	
public:
	@disable
	this(typeof(null));
	
	@disable
	this(ref shared_ptr!T);
	
	this(T* ptr) {
		this._ptr = ptr;
		this._inuse = new RefCounter(1);
		
		this._isCopy = false;
		
		shared_counter++;
	}
	
	this(shared_ptr!T rhs) {
		this._ptr = rhs._ptr;
		this._inuse = rhs._inuse;
		this._inuse.inc();
	}
	
	this(this) {
		this._inuse.inc();
		this._isCopy = true;
		
		shared_counter++;
	}
	
	@disable
	void opAssign(ref shared_ptr!T);
	
	void opAssign(shared_ptr!T rhs) {
		if (this._inuse && this._inuse.dec() <= 0)
			this.release();
		
		this._isCopy = rhs._isCopy;
		
		this._ptr = rhs._ptr;
		this._inuse = rhs._inuse;
		this._inuse.inc();
	}
	
	~this() {
		shared_counter--;
		
		debug writeln("DTor smart_ptr: ",
		              shared_counter, " => ",
		              this._inuse ? this._inuse.counter : -1,
		              " :: ", __traits(identifier, _deleter), " :: ",
		              __traits(identifier, T), " :: ",
		              this._ptr, " :: ", this._isCopy);
		
		if (this._inuse && this._inuse.dec() <= 0)
			this.release();
	}
	
	void release() {
		this._destruct();
		
		deallocate(this._inuse);
	}
	
	@property
	bool valid() const pure nothrow {
		return this._ptr !is null;
	}
	
	@property
	bool isCopy() const pure nothrow {
		return this._isCopy;
	}
	
	@property
	int refcount() const pure nothrow {
		return this._inuse ? this._inuse.counter : 0;
	}
	
	void swap(ref shared_ptr!T rhs) pure nothrow {
		T* ptr = this._ptr;
		
		this._ptr = rhs.ptr;
		rhs._ptr = ptr;
	}
	
	void reset(T* ptr) {
		this._destruct();
		
		this._ptr = ptr;
	}
	
	@property
	inout(T*) ptr() inout pure nothrow {
		return this._ptr;
	}
	
	alias ptr this;
	
	bool opEquals(ref const shared_ptr!T rhs) const pure nothrow {
		return this._ptr == rhs._ptr;
	}
	
} unittest {
	struct A {
	public:
		int id;
	}
	
	void test(shared_ptr!A rhs) {
		assert(rhs.isCopy);
		assert(rhs.id == 42);
		assert(rhs.valid);
		assert(rhs.refcount == 2);
	}
	
	shared_ptr!A as = make_shared(new A(42));
	
	assert(as.id == 42);
	assert(as.refcount == 1);
	assert(as.valid);
	assert(!as.isCopy);
	
	test(as);
	
	assert(as.id == 42);
	assert(as.refcount == 1);
	assert(as.valid);
	assert(!as.isCopy);
	
	shared_ptr!A s1 = make_shared(new A(111));
	shared_ptr!A s2 = s1;
	
	assert(s1.refcount == 2);
	assert(s2.refcount == 2);
	assert(s2.isCopy());
	assert(s1 == s2);
	
	s1 = make_shared(new A(222));
	
	assert(s2.isValid());
	assert(s1.refcount == 1);
	assert(s2.refcount == 1);
	assert(s2.isCopy());
	assert(s1 != s2);
}

