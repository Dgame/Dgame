module Dgame.Internal.Error;

@nogc
void assert_fmt(Args...)(bool cond, string msg, auto ref Args args) {
    import core.stdc.stdio : sprintf;

    char[256] buf = void;

    sprintf(buf.ptr, msg.ptr, args);
    assert(cond, buf);
}