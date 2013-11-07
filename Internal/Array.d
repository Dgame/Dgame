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
module Dgame.Internal.Array;

private import core.stdc.stdlib : malloc, realloc, free;

struct array(T) {
private:
	void _init(size_t cap = 4) {
		cap = cap < 4 ? 4 : cap;

		this.ptr = cast(T*) .malloc(cap * T.sizeof);
		this.capacity = cap;
	}

public:
	T* ptr;
	size_t length;
	size_t capacity;

	~this() {
		static if (is(T == struct) || is(T == class)) {
			foreach (ref T item; this.ptr[0 .. this.length]) {
				.destroy!T(item);
			}
		}

		.free(this.ptr);
		this.ptr = null;
	}

	size_t reserve(size_t size) {
		size = size < 1 ? 1 : size;

		if (this.ptr !is null) {
			this.capacity += size;
			this.ptr = cast(T*) .realloc(this.ptr, this.capacity * T.sizeof);
		} else
			this._init(size);

		return this.capacity;
	}

	void append(T item) {
		this.append(item);
	}

	void append(ref T item) {
		if (this.length == this.capacity)
			this.reserve(this.capacity);

		this.ptr[this.length++] = item;
	}

	void opOpAssign(string op : "~")(T item) {
		this.append(item);
	}

	void opOpAssign(string op : "~")(ref T item) {
		this.append(item);
	}

	void append(T[] items) {
		if (this.length == this.capacity)
			this.reserve(items.length);

		foreach (ref T item; items) {
			this.append(item);
		}
	}

	inout(T[]) opSlice() inout pure nothrow {
		return this.ptr[0 .. this.length];
	}

	void opSliceAssign(T item) {
		for (size_t i = 0; i < this.length; ++i) {
			this.ptr[i] = item;
		}
	}

	// TODO: opSliceAssign(T item, size_t i1, size_t i2) ?

	void opSliceAssign(T[] items) {
		const size_t len = this.length > items.length ? items.length : this.length;
		for (size_t i = 0; i < len; ++i) {
			this.ptr[i] = items[i];
		}
	}

	void opSliceOpAssign(string op)(T item) {
		for (size_t i = 0; i < this.length; ++i) {
			mixin("this.ptr[i] " ~ op ~ "= item;");
		}
	}

	alias ptr this;
}