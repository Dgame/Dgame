module Dgame.Core.Memory.SmartPointer.util;

private {
	debug import std.stdio;
	import std.traits : isAssignable, isStaticArray;
	import core.memory : GC;
}

/**
 * Deallocate GC memory
 * Works like delete
 */
@trusted
void deallocate(T)(ref T var)
	if (isAssignable!(T, typeof(null)) && !isStaticArray!T)	
{
	const bool isPtr = is(T : U*, U);
	
	static if (isPtr && is(U == struct) && is(typeof(var.__dtor)))
		.destroy(*var);
	else static if (is(T == class))
		.destroy(var);
	
	static if (is(T : U[], U)) {
		static if (is(U == struct)) {
			foreach (ref U item; var) {
				.destroy(item);
			}
		}
		
		GC.free(var.ptr);
	} else {
		static if (isPtr)
			GC.free(var);
		else
			GC.free(&var);
	}
	
	var = null;
} unittest {
	struct A {
	public:
		int id;
		
		this(int i) {
			this.id = i;
			debug writeln("A::CTor ", this.id);
		}
		
		~this() {
			debug writeln("A::DTor ", this.id);
		}
	}
	
	class B {
	public:
		int id;
		
		this(int i) {
			this.id = i;
			debug writeln("B::CTor ", this.id);
		}
		
		~this() {
			debug writeln("B::DTor ", this.id);
		}
	}
	
	A* a = new A(42);
	assert(a.id == 42);
	deallocate(a);
	assert(a is null);
	
	int[] arr1 = new int[8];
	int* arr1Ptr = arr1.ptr;
	
	assert(arr1.length == 8);
	deallocate(arr1);
	assert(arr1 is null);
	assert(arr1.length == 0);
	assert(arr1Ptr != arr1.ptr);
	
	B b = new B(1337);
	assert(b !is null);
	assert(b.id == 1337);
	deallocate(b);
	assert(b is null);
	
	A[] arr = [A(142), A(123)];
	assert(arr.length == 2);
	assert(arr[0].id == 142);
	assert(arr[1].id == 123);
	//	writeln("....");
	deallocate(arr);
	assert(arr.length == 0);
	//	writeln("----");
}