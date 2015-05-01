module Dgame.Internal.d2c;

private:

//import Dgame.Internal.Error;
import Dgame.Internal.m3;

char[] heapBuffer;
char[256] stackBuffer = void;

@nogc
char* make_buffer(size_t len) nothrow {
    if (stackBuffer.length > len)
        return stackBuffer.ptr;

    if (heapBuffer.length > len)
        return heapBuffer.ptr;

    //print_fmt("(Re)Order heap buffer: %d\n", len + 1);
    heapBuffer = remake(heapBuffer, len + 1);

    return heapBuffer.ptr;
}

public:

@nogc
static ~this() nothrow {
    //print_fmt("Free heap buffer: %d\n", heapBuffer.length);
    unmake(heapBuffer);
}

@nogc
const(char)* toStringz(string text) nothrow {
    if (text.length == 0)
        return null;

    if (text[$ - 1] == '\0')
        return text.ptr;

    char* ptr = make_buffer(text.length);
    ptr[0 .. text.length] = text[];
    ptr[text.length] = '\0';

    return ptr;
}