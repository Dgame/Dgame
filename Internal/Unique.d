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

private import std.exception : enforce;

struct unique_ptr(T)
	if (!is(T : U*, U) && !is(T == class) && !is(T : U[], U))
{
	static struct Unique {
		T* ptr;
		void function(T*) deleter;
	}
	
	Unique* _unique;
	
	@disable
	this(typeof(null));
	
	@disable
	this(this);
	
	this(T* ptr, void function(T*) deleter = null) {
		this(ptr, deleter);
	}
	
	this(ref T* ptr, void function(T*) deleter = null) {
		this._unique = new Unique(ptr, deleter);
		ptr = null;
	}
	
	~this() {
		this.release();
	}
	
	void opAssign(typeof(this) un) {
		this.release();
		
		this._unique = un._unique;
		un._unique = null;
	}
	
	void release() {
		if (this.isValid()) {
			if (this._unique.deleter !is null)
				this._unique.deleter(this._unique.ptr);
			
			delete this._unique;
			this._unique = null;
		}
	}
	
	bool isValid() const pure nothrow {
		return this._unique !is null;
	}
	
	@property
	inout(T*) ptr() inout pure nothrow {
		return this.isValid() ? this._unique.ptr : null;
	}
	
	alias ptr this;
	
	typeof(this) move() {
		enforce(this.isValid());
		
		scope(exit) {
			delete this._unique;
			this._unique = null;
		}
		
		return typeof(this)(this._unique.ptr, this._unique.deleter);
	}
} unittest {
	struct A {
		int id;
	}
	
	unique_ptr!A test(unique_ptr!A rhs) {
		assert(rhs.isValid());
		assert(rhs.id == 42);
		
		return rhs.move();
	}
	
	unique_ptr!A as = new A(42);
	
	assert(as.isValid());
	assert(as.id == 42);
	
	typeof(as) as2 = as.move();
	
	assert(!as.isValid());
	assert(as2.isValid());
	assert(as2.id == 42);
	
	as = test(as2.move());
	
	assert(!as2.isValid());
	assert(as.isValid());
	assert(as.id == 42);
}

unique_ptr!T make_unique(T)(T* ptr, void function(T*) df) {
	return unique_ptr!T(ptr, df);
}
