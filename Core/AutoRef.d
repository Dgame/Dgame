module Dgame.Core.AutoRef;

import std.conv : to;
import std.traits;

template isConstFunction(alias func) {
	enum isConstFunction = isSomeFunction!func && !isMutable!(typeof(func));
}

template deduceConstType(alias func) {
	static if (isConstFunction!func) {
		static if (is(typeof(fun) == immutable))
			enum deduceConstType = "immutable";
		else
			enum deduceConstType = "const";
	} else
		enum deduceConstType = "";
}

template autoRef(alias func) {
	private string gen() {
		enum Ret  = ReturnType!func.stringof;
		enum Attr = functionAttributes!func;

		alias Args = ParameterTypeTuple!func;
		alias Pstc = ParameterStorageClassTuple!func;
		alias DefVals = ParameterDefaultValueTuple!func;

		enum names = [ParameterIdentifierTuple!func];
		enum fname = __traits(identifier, func);

		const bool isStatic = __traits(isStaticFunction, func);
		const bool isFinal  = __traits(isFinalFunction, func);

		string str;

		if (Attr & FunctionAttribute.property)
			str ~= "@property\n";
		if (Attr & FunctionAttribute.ref_)
			str ~= "ref ";

		if (isStatic)
			str ~= "static ";
		if (isFinal)
			str ~= "final ";

		str ~= Ret ~ " " ~ fname ~ "(";

		foreach(i, Type; Args) {
			if (Pstc[i] == ParameterStorageClass.scope_)
				str ~= "scope ";
			if (Pstc[i] == ParameterStorageClass.out_)
				str ~= "out ";
			if (Pstc[i] == ParameterStorageClass.lazy_)
				str ~= "lazy ";
			/*if (Pstc[i] == ParameterStorageClass.ref_)
				str ~= "ref ";*/

			str ~= Args[i].stringof ~ " ";
			str ~= names[i];

			static if (!is(DefVals[i] == void)) {
				static if (is(typeof(DefVals[i]) == enum))
					str ~= " = " ~ Args[i].stringof ~ '.' ~ to!string(DefVals[i]);
				else
					str ~= " = " ~ to!string(DefVals[i]);
			}

			if ((i + 1) != Args.length)
				str ~= ", ";
		}

		str ~= ")";
		str ~= deduceConstType!func;

		if (Attr & FunctionAttribute.pure_)
			str ~= " pure";
		if (Attr & FunctionAttribute.nothrow_)
			str ~= " nothrow";
		if (Attr & FunctionAttribute.trusted)
			str ~= " @trusted";
		if (Attr & FunctionAttribute.safe)
			str ~= " @safe";

		str ~= " {\n\treturn " ~ fname ~ "(";

		static if (Args.length) {
			str ~= names[0];
			foreach(i, Type; Args[1 .. $]) {
				str ~= ", " ~ names[i + 1];
			}
		}

		str ~= ");\n}\n\n";

		return str;
	}

	enum autoRef = gen();
} unittest {
	struct A {
	public:
		ubyte id;
	}

	class B {
	public:
		ubyte test1(ref const A a) const {
			return a.id;
		}

		mixin(autoRef!test1);
	}

	B b = new B();
	assert(42 == b.test1(A(42)));
}