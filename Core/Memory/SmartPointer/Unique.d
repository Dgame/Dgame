module Dgame.Core.Memory.SmartPointer.Unique;

unique_ptr!T make_unique(T)(T* ptr)
	if (is(T == struct)) 
{
	return unique_ptr!T(ptr);
}

void dummyDeleter(void* ptr) pure nothrow {
	
}

struct unique_ptr(T, alias _deleter = dummyDeleter)
	if (is(T == struct))
{
private:
	T* _ptr;
	
public:
	@disable
	this(typeof(null));
	
	this(T* ptr) {
		this._ptr = ptr;
	}
	
	@disable
	this(this);
	
	@disable
	void opAssign(ref unique_ptr!T);
	
	void opAssign(unique_ptr!T rhs) {
		if (this.valid)
			assert(0, "unique_pointer cannot be reassigned");
		
		this._ptr = rhs._ptr;
		
		if (!is(typeof(this) == typeof(rhs)))
			rhs._ptr = null; /// to avoid destruction of ptr
	}
	
	~this() {
		this.release();
	}
	
	void reset(T* ptr, bool release = true) {
		if (release)
			this.release();
		
		this._ptr = ptr;
	}
	
	void release() {
		if (this._ptr) {
			_deleter(this._ptr);
			
			this._ptr = null;
		}
	}
	
	@property
	bool valid() const pure nothrow {
		return this._ptr !is null;
	}
	
	void swap(ref unique_ptr!T rhs) pure nothrow {
		T* ptr = this._ptr;
		
		this._ptr = rhs.ptr;
		rhs._ptr = ptr;
	}
	
	typeof(this) move() {
		scope(exit) this._ptr = null;
		
		return typeof(this)(this._ptr);
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
	
	void test(unique_ptr!A rhs) {
		assert(rhs.valid);
		assert(rhs.id == 42);
	}
	
	unique_ptr!A as = make_unique(new A(42));
	
	assert(as.valid);
	assert(as.id == 42);
	
	typeof(as) as2 = as.move();
	
	assert(!as.valid);
	assert(as2.valid);
	assert(as2.id == 42);
	
	test(as2.move());
	
	assert(!as2.valid);
}