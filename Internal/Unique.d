module Dgame.Internal.Unique;

void dummy_deleter(void* ptr) pure nothrow {
	
}

struct unique_ptr(T, alias _deleter = dummy_deleter)
	if (!is(T == class) && !is(T : U*, U))
{
private:
	T* _ptr;
	
public:
	@disable
	this(typeof(null));
	
	@disable
	this(this);
	
	@disable
	void opAssign(T*);
	
	this(T* ptr) {
		this._ptr = ptr;
	}
	
	~this() {
		this.release();
	}
	
	void release() {
		if (this.isValid()) {
			static if (is(T == struct) && is(typeof(T)))
				destroy!T(*this._ptr);
			
			_deleter(this._ptr);
		}
	}
	
	void reset(T* ptr) in {
		assert(ptr !is null);
	} body {
		this.release();
		
		this._ptr = ptr;
	}
	
	bool isValid() const pure nothrow {
		return this._ptr !is null;
	}
	
	@property
	inout(T*) ptr() inout {
		return this._ptr;
	}
	
	alias ptr this;
	
	typeof(this) move() {
		scope(exit) this._ptr = null;
		
		return typeof(this)(this._ptr);
	}
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