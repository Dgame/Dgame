module Dgame.Core.Memory.Finalizer;

private {
	debug import std.stdio;
	
	import Dgame.Graphics.Font;
	import Dgame.Graphics.Texture;
}

void terminate() {
	debug writeln("Terminate");
	
	_finalizeFont();
	_finalizeTexture();
	
	debug writeln(" >> Terminated");
}