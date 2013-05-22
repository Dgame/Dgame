module Dgame.Core.Finalizer;

debug import std.stdio;

private {
	import Dgame.Graphics.Font;
}

void terminate() {
	debug writeln("Terminate");
	_finalizeFont();
	debug writeln(" >> Terminated");
}