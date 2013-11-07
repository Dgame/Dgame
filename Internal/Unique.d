/*
*******************************************************************************************
* Dgame (a D game framework) - Copyright (c) Randy Schütt
* 
* This software is provided 'as-is', without any express or implied warranty.
* In no event will the authors be held liable for any damages arising from
* the use of this software.
* 
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 
* 1. The origin of this software must not be misrepresented; you must not claim
*    that you wrote the original software. If you use this software in a product,
*    an acknowledgment in the product documentation would be appreciated but is
*    not required.
* 
* 2. Altered source versions must be plainly marked as such, and must not be
*    misrepresented as being the original software.
* 
* 3. This notice may not be removed or altered from any source distribution.
*******************************************************************************************
*/
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