module Dgame.Core.Memory.SmartPointer.Unique;

void dummyDeleter(void* ptr) pure nothrow {
	
}

struct unique_ptr(T, alias _deleter = dummyDeleter)
	if (!is(T == class) && !is(T : U*, U))
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
	
	~this() {
		this.release();
	}
	
	void reset(T* ptr) in {
		assert(ptr !is null);
	} body {
		this.release();
		
		this._ptr = ptr;
	}
	
	void release() {
		if (this._ptr !is null) {
			_deleter(this._ptr);
			
			this._ptr = null;
		}
	}
	
	bool isValid() const pure nothrow {
		return this._ptr !is null;
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
		assert(rhs.isValid());
		assert(rhs.id == 42);
	}
	
	unique_ptr!A as = new A(42);
	
	assert(as.isValid());
	assert(as.id == 42);
	
	typeof(as) as2 = as.move();
	
	assert(!as.isValid());
	assert(as2.isValid());
	assert(as2.id == 42);
	
	test(as2.move());
	
	assert(!as2.isValid());
}