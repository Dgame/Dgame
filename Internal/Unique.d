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

struct unique_ptr(T) {
	T* ptr;
	void function(T*) t_del;
	void function(void*) any_del;
	
	alias ptr this;
	
	@disable
	this(typeof(null));
	
	this(T* ptr) {
		this.ptr = ptr;
	}
	
	this(T* ptr, void function(T*) t_del) {
		this.ptr = ptr;
		this.t_del = t_del;
	}
	
	this(T* ptr, void function(void*) any_del) {
		this.ptr = ptr;
		this.any_del = any_del;
	}
	
	@disable
	this(this);
	
	@disable
	void opAssign(typeof(this));
	
	bool isValid() const pure nothrow {
		return this.ptr !is null;
	}
	
	~this() {
		if (this.ptr is null)
			return;
			
		if (this.t_del !is null)
			this.t_del(this.ptr);
		else if (this.any_del !is null)
			this.any_del(this.ptr);
	}
}

unique_ptr!T move(T)(ref unique_ptr!T rhs) {
	T* ptr = rhs.ptr;
	rhs.ptr = null;
	
	if (rhs.t_del !is null)
		return unique_ptr!T(ptr, rhs.t_del);
	return unique_ptr!T(ptr, rhs.any_del);
}

unittest {
	struct A {
		int id;
	}
	
	unique_ptr!A test(unique_ptr!A rhs) {
		assert(rhs.isValid());
		assert(rhs.id == 42);
		
		return move(rhs);
	}
	
	unique_ptr!A as = new A(42);
	
	assert(as.isValid());
	assert(as.id == 42);
	
	unique_ptr!A as2 = move(as);
	
	assert(!as.isValid());
	assert(as2.isValid());
	assert(as2.id == 42);
	
	unique_ptr!A as3 = test(move(as2));
	
	assert(!as2.isValid());
	assert(as3.isValid());
	assert(as3.id == 42);
}

unique_ptr!T make_unique(T)(T* ptr, void function(T*) df) {
	return unique_ptr!T(ptr, df);
}
