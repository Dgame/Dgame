module Dgame.Core.Memory.SmartPointer.Shared;

private {
	debug import std.stdio;
	/*
	 import std.conv : emplace;
	 
	 import core.stdc.stdlib : malloc, free;
	 */
}

shared_ptr!T make_shared(T)(T* ptr)
	if (is(T == struct))
{
	return shared_ptr!T(ptr);
}

private static int shared_counter = 0;

void dummyDeleter(void* ptr) pure nothrow {
	
}

private struct SharedData(T) {
public:
	T* _ptr;
	int _usage;
	
	int inc() pure nothrow {
		return ++this._usage;
	}
	
	int dec() pure nothrow {
		return --this._usage;
	}
}

struct shared_ptr(T, alias _deleter = dummyDeleter)
	if (is(T == struct))
{
private:
	SharedData!(T)* _shared;
	bool _isCopy;
	
	void _destruct() {
		if (this._shared && this._shared._ptr) {
			debug writeln("delete SM (", this._shared._ptr, ") with: ",
			              __traits(identifier, _deleter));
			
			_deleter(this._shared._ptr);
			this._shared._ptr = null;
			
			debug writeln("Destructed");
		}
	}
	
public:
	@disable
	this(typeof(null));
	
	@disable
	this(ref shared_ptr!T);
	
	this(T* ptr) {
		this._shared = new SharedData!T(ptr, 1);
		
		shared_counter++;
	}
	
	this(this) {
		this._shared.inc();
		this._isCopy = true;
		
		shared_counter++;
	}
	
	@disable
	void opAssign(ref shared_ptr!T);
	
	void opAssign(shared_ptr!T rhs) {
		if (this._shared && this._shared.dec() <= 0)
			this.release();
		
		this._shared = rhs._shared;
		
		if (!is(typeof(this) == typeof(rhs)))
			rhs._shared = null; /// to avoid destruction of ptr
		else
			this._shared.inc();
	}
	
	~this() {
		debug writeln("DTor smart_ptr: ",
		              shared_counter, " => ",
		              (this._shared ? this._shared._usage : -1),
		              " :: ", __traits(identifier, _deleter), " :: ",
		              __traits(identifier, T), " :: ",
		              (this._shared ? this._shared._ptr : null), " :: ", this._isCopy);
		
		shared_counter--;
		
		if (this._shared && this._shared.dec() <= 0)
			this.release();
	}
	
	void release() {
		this._destruct();
		
		if (this._shared) {
			.destroy(*this._shared);
			//			.free(this._shared);
		}
	}
	
	@property
	bool valid() const pure nothrow {
		return this._shared !is null && this._shared._ptr !is null;
	}
	
	@property
	bool isCopy() const pure nothrow {
		return this._isCopy;
	}
	
	@property
	int refcount() const pure nothrow {
		return this._shared ? this._shared._usage : 0;
	}
	
	void swap(ref shared_ptr!T rhs) pure nothrow {
		T* ptr = this._shared._ptr;
		
		this._shared._ptr = rhs._shared._ptr;
		rhs._shared._ptr = ptr;
	}
	
	void reset(T* ptr, bool destruct = true) {
		if (this._shared) {
			if (destruct)
				this._destruct();
			
			this._shared._ptr = ptr;
		} else if (ptr !is null) {
			this._shared = new SharedData!T(ptr, 1);
			//			this._shared = make_SharedData!T(ptr, 1);
		}
	}
	
	@property
	inout(T*) ptr() inout pure nothrow {
		return this._shared ? this._shared._ptr : null;
	}
	
	alias ptr this;
	
	bool opEquals(ref const shared_ptr!T rhs) const pure nothrow {
		if (!this._shared || !rhs._shared)
			return false;
		
		return this._shared._ptr == rhs._shared._ptr;
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
	
	assert(s2.valid);
	assert(s1.refcount == 1);
	assert(s2.refcount == 1);
	assert(s2.isCopy());
	assert(s1 != s2);
	
	void testDeleter(A* ptr) { }
	
	void test2(shared_ptr!(A, testDeleter) rhs, int id) {
		assert(rhs.isCopy);
		assert(rhs.id == id);
		assert(rhs.valid);
		assert(rhs.refcount == 2);
	}
	
	shared_ptr!(A, testDeleter) s3 = make_shared(new A(23));
	
	assert(s3.valid);
	assert(s3.id == 23);
	assert(s3.refcount == 1);
	
	test2(s3, 23);
	
	assert(s3.valid);
	assert(s3.id == 23);
	assert(s3.refcount == 1);
	
	s3 = make_shared(new A(42));
	
	assert(s3.valid);
	assert(s3.id == 42);
	assert(s3.refcount == 1);
}

