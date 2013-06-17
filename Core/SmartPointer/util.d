module Dgame.Core.SmartPointer.util;

private import core.memory : GC;

void Delete(T)(ref T var) {
	static if ((is(T == struct) || is(T == class)) && is(typeof(var.__dtor)))
		var.__dtor();
	
	static if (is(T : U[], U))
		GC.free(var.ptr);
	else {
		static if (is(T : U*, U))
			GC.free(var);
		else
			GC.free(&var);
	}
	
	var = null;
}