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
module Dgame.Internal.Scoped;

private {
	debug import std.stdio : writeln, writefln;
	import core.memory : GC;
}

struct scoped(A : T[], T)
	if (!is(T == class) && !is(T : U*, U))
{
	T[] arr;
	void function(ref T[]) _deleter;
	
	@disable
	this(this);
	
	this(T[] arr, void function(ref T[]) del = null) {
		this.arr = arr;
		if (del !is null)
			this._deleter = del;
		else {
			this._deleter = (ref T[] arr) {
				GC.free(arr.ptr);
				arr = null;
				GC.minimize();
			};
		}
		
		debug writefln("Allocate %d %s's (ptr = %x)", arr.length, T.stringof, arr.ptr);
	}
	
	alias arr this;
	
	~this() {
		debug writefln("Deallocate %d %s's (ptr = %x)", this.arr.length, T.stringof, this.arr.ptr);
		
		static if (is(T == struct)) {
			foreach (ref T elem; this.arr) {
				.destroy!T(elem);
			}
		}
		
		this._deleter(this.arr);
	}
}