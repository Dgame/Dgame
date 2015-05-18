module Dgame.Internal.m3;

package(Dgame):

@nogc
T make(T : U[], U)(size_t len) nothrow {
    import core.stdc.stdlib : malloc;
    
    static assert(!is(U : V[], V), "Only basic types are allowed");

    void* p = malloc(len * T.sizeof);
    return p ? (cast(U*) p)[0 .. len] : null;
}

@nogc
T remake(T : U[], U)(ref T arr, size_t len) nothrow {
    import core.stdc.stdlib : realloc;
    
    static assert(!is(U : V[], V), "Only basic types are allowed");

    immutable size_t new_len = len + arr.length;

    void* p = realloc(arr.ptr, new_len * T.sizeof);
    return p ? (cast(U*) p)[0 .. new_len] : null;
}

@nogc
void unmake(T : U[], U)(ref T arr) nothrow {
    import core.stdc.stdlib : free;
    
    static assert(!is(U : V[], V), "Only basic types are allowed");

    free(arr.ptr);
}