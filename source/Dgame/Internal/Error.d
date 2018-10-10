module Dgame.Internal.Error;

private:

auto size_of(Args...)(auto ref Args args) {
    size_t size = 0;
    static foreach (a; args) {
        {
            static if (is(typeof(a) : U[], U)) {
                size += U.sizeof * a.length;
            } else {
                size += a.sizeof;
            }
        }
    }

    return size;
}

package(Dgame):

@nogc
void assert_fmt(Args...)(void* ptr, string msg, auto ref Args args) nothrow {
    return assert_fmt(ptr !is null, msg, args);
}

@nogc
void assert_fmt(Args...)(bool cond, string msg, auto ref Args args) nothrow {
    import core.stdc.stdio: sprintf;
    import Dgame.Internal.m3: make, unmake;

    auto buf = make!(char[])(msg.length + size_of(args) + 16);
    scope(exit) unmake(buf);

    sprintf(buf.ptr, msg.ptr, args);
    assert(cond, buf);
}

@nogc
void print_fmt(Args...)(string fmt, auto ref Args args) nothrow {
    import core.stdc.stdio : printf;

    printf(fmt.ptr, args);
}