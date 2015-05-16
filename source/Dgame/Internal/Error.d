module Dgame.Internal.Error;

package(Dgame):

@nogc
void assert_fmt(Args...)(void* ptr, string msg, auto ref Args args) nothrow {
	return assert_fmt(ptr !is null, msg, args);
}

@nogc
void assert_fmt(Args...)(bool cond, string msg, auto ref Args args) nothrow {
    import core.stdc.stdio : sprintf;

    char[256] buf = void;

    sprintf(buf.ptr, msg.ptr, args);
    assert(cond, buf);
}

@nogc
void print_fmt(Args...)(string fmt, auto ref Args args) nothrow {
    import core.stdc.stdio : printf;

    printf(fmt.ptr, args);
}