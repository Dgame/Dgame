module Dgame.Core.SmartPointer;

private {
	debug import std.stdio;
	import core.memory : GC;
	import std.c.string : memcpy;
}

struct RefCounter {
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
	if (is(T == struct) || is(T == class)) 
{
	return shared_ptr!T(ptr);
}

void Finalize(T)(auto ref T value) pure nothrow {
	static if (is(T == struct) && is(typeof(value.__dtor)))
		value.__dtor();
	
	.destroy(value);
	
	static if (is(T : U*, U))
		GC.free(value);
	else
		GC.free(&value);
}

private static int shared_counter = 0;

struct shared_ptr(T, alias _deleter = Finalize)
	if (is(T == struct) || is(T == class))
{
private:
	T* _ptr;
	RefCounter* _inuse;
	
	bool _isCopy;
	
	void _destruct() {
		if (this._ptr) {
			_deleter(this._ptr);
			///writeln(__traits(identifier, _deleter));
		}
	}
	
public:
	@disable
	this(typeof(null));
	
	this(T* ptr) {
		this._ptr = ptr;
		this._inuse = new RefCounter(1);
		
		this._isCopy = false;
		
		shared_counter++;
	}
	
	this(this) {
		this._inuse.inc();
		
		this._isCopy = true;
		
		shared_counter++;
	}
	
	@disable
	void opAssign(ref shared_ptr!T);
	
	void opAssign(shared_ptr!T rhs) {
		this.release();
		
		memcpy(&this, &rhs, shared_ptr!T.sizeof);
		
		this._inuse = new RefCounter(1);
	}
	
	~this() {
		shared_counter--;
		
		debug writeln("DTor smart_ptr: ",
		              shared_counter, " => ",
		              this._inuse ? this._inuse.counter : -1,
		              " :: ", __traits(identifier, _deleter), " :: ",
		              this._ptr, " :: ", this._isCopy);
		
		if (this._inuse && this._inuse.dec() <= 0) {
			this.release();
		}
	}
	
	void release() {
		this._destruct();
		
		Finalize(this._inuse);
		
		this._ptr = null;
		this._inuse = null;
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
	
} unittest {
	struct A {
	public:
		int id;
	}
	
	void test(shared_ptr!A rhs) {
		assert(rhs.isCopy);
		assert(rhs.valid);
		assert(rhs.refcount == 2);
	}
	
	shared_ptr!A as = make_shared(new A(42));
	
	assert(as.refcount == 1);
	assert(as.valid);
	assert(!as.isCopy);
	
	test(as);
	
	assert(as.refcount == 1);
	assert(as.valid);
	assert(!as.isCopy);
}