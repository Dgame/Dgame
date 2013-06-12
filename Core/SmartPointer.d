module Dgame.Core.SmartPointer;

private {
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
	if (is(T == struct) || is (T == class))
{
	return shared_ptr!T(ptr);
}

struct shared_ptr(T, alias _deleter = GC.free)
	if (is(T == struct) || is (T == class))
{
private:
	T* _ptr;
	RefCounter* _inuse;
	
	void _destruct() {
		if (this._ptr) {
			static if (is(typeof(this.ptr.__dtor)))
				this._ptr.__dtor();
			
			_deleter(this._ptr);
		}
	}
	
public:
	/*
	 @disable
	 this();
	 */
	@disable
	this(typeof(null));
	
	this(T* ptr) {
		this._ptr = ptr;
		this._inuse = new RefCounter(1);
	}
	
	this(this) {
		this._inuse.inc();
		//writefln("Counter: %d", this._inuse.counter);
	}
	
	@disable
	void opAssign(ref shared_ptr!T);
	
	void opAssign(shared_ptr!T rhs) {
		this.release();
		
		memcpy(&this, &rhs, shared_ptr!T.sizeof);
		
		this._inuse.inc();
	}
	
	~this() {
		if (this._inuse && this._inuse.dec() <= 0)
			this.release();
	}
	
	@property
	bool valid() const pure nothrow {
		return this._ptr !is null;
	}
	
	@property
	int refcount() const pure nothrow {
		return this._inuse.counter;
	}
	
	void release() {
		this._destruct();
		
		GC.free(this._inuse);
		
		this._ptr = null;
		this._inuse = null;
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
}