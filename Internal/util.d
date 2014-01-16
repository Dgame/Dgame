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
module Dgame.Internal.util;

private {
	import std.math : fabs;
	import std.traits : isNumeric;
}

struct CircularBuffer(T, const size_t Limit = 16) {
	private T[Limit] _store = void;
	private uint _length;
	
	T* get() pure nothrow {
		T* ptr = &this._store[this._length];
		this._length = (this._length + 1) % Limit;
		
		//writeln("CB length = ", this._length);
		
		return ptr;
	}
}