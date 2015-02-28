import std.stdio;

import Dgame.Window.Window;
import Dgame.Window.Event;
import Dgame.Graphic.Text;
import Dgame.System.Font;
import Dgame.System.StopWatch;

void main() {
	Window wnd = Window(640, 480, "Dgame Test");

	StopWatch clock;
	Font fnt = Font("samples/font/arial.ttf", 22);
	Text curFps = new Text(fnt);

	bool running = true;
	
	Event event;
	while (running) {
		wnd.clear();
		
		while (wnd.poll(&event)) {
			switch (event.type) {
				case Event.Type.Quit:
					writeln("Quit Event");
					running = false;
				break;
					
				default: break;
			}
		}
		
		curFps.format("Current FPS: %d.", clock.getCurrentFPS());
		
		wnd.draw(curFps);
		
		wnd.display();
	}
}