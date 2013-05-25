module Dgame.Core.Finalizer;

debug import std.stdio;

private {
	import Dgame.Graphics.Font;
	import Dgame.Graphics.Texture;
	import Dgame.Audio.Sound;
}

void terminate() {
	debug writeln("Terminate");
	
	_finalizeFont();
	_finalizeSound();
	_finalizeTexture();
	
	debug writeln(" >> Terminated");
}