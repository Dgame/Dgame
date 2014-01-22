/*
 *******************************************************************************************
 * Dgame (a D game framework) - Copyright (c) Randy Schütt
 * 
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not claim
 *    that you wrote the original software. If you use this software in a product,
 *    an acknowledgment in the product documentation would be appreciated but is
 *    not required.
 * 
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source distribution.
 *******************************************************************************************
 */
import std.stdio;

import Dgame.Window.all;
import Dgame.Graphics.all;
import Dgame.Audio.all;
import Dgame.System.all;

static immutable string Path = "E:\\D\\dub\\packages\\derelict-master";

pragma(lib, Path ~ "\\lib\\dmd\\DerelictSDL2.lib");
pragma(lib, Path ~ "\\lib\\dmd\\DerelictUtil.lib");
pragma(lib, Path ~ "\\lib\\dmd\\DerelictGL3.lib");
pragma(lib, Path ~ "\\lib\\dmd\\DerelictAL.lib");
pragma(lib, Path ~ "\\lib\\dmd\\DerelictOGG.lib");

import Dgame.Internal.core : getDgVersion;

pragma(msg, getDgVersion());

pragma(msg, Color.sizeof);
pragma(msg, Font.sizeof);
pragma(msg, Surface.sizeof);
pragma(msg, Vertex.sizeof);
pragma(msg, Vertex.sizeof);
pragma(msg, FloatRect.sizeof);
pragma(msg, Vector2f.sizeof);
pragma(msg, Vector3f.sizeof);

enum ushort width = 1024;
enum ushort height = 640;

void main() {
	Window wnd = new Window(VideoMode(width, height), "Dgame Demo");
	wnd.setVerticalSync(Window.Sync.Disable);
	wnd.setFpsLimit(15);
	wnd.setClearColor(Color.Green);
	
	{
		writeln("<>");
		Surface test = Surface("../../samples/img/wiki.png");
		Surface test2 = test;
		test2 = test;
		writeln("</>");
	}
	writeln("====");
	
	Sound[3] sound;
	//sound[0] = new Sound(new VorbisFile("../../samples/audio/orchestral.ogg"));
	//sound[1] = new Sound(new WaveFile("../../samples/audio/step.wav"));
	sound[0] = new Sound("../../samples/audio/orchestral.ogg");
	sound[1] = new Sound("../../samples/audio/collect.wav");
	sound[2] = new Sound("../../samples/audio/expl.wav");
	//sound[0] = Sound.loadOnce("../../samples/audio/orchestral.ogg");
	//sound[1] = Sound.loadOnce("../../samples/audio/step.wav");
	
	Color ccol = Color(0.7, 0.7, 0.7);
	writefln("Green Color: %d,%d,%d,%d",
	         Color.Green.red, Color.Green.green, Color.Green.blue, Color.Green.alpha);
	
	Shape qs = Shape.make(Shape.Type.Quad, [
		Vertex(75, 75),
		Vertex(275, 75),
		Vertex(275, 275),
		Vertex(75, 275)]);
	
	//qs.setSmooth(Shape.SmoothTarget.Line, Shape.SmoothHint.Nicest);
	qs.setColor(Color.Blue);
	//qs.setType(Shape.Type.Triangle);
	//	qs.rotate(-25);
	qs.setPosition(500, 300);
	
	Shape circle = Shape.makeCircle(25, Vector2f(225, 425));
	circle.setSmooth(Smooth.Target.Line);
	circle.setColor(Color.White);
	
	Shape many = Shape.make(Shape.Type.Quad, [
		Vertex(55, 55),
		Vertex(60, 55),
		Vertex(60, 60),
		Vertex(55, 60),
		Vertex(15, 15),
		Vertex(20, 15),
		Vertex(20, 20),
		Vertex(15, 20),
		Vertex(30, 30),
		Vertex(35, 30),
		Vertex(35, 35),
		Vertex(30, 35),
		Vertex(40, 40),
		Vertex(45, 40),
		Vertex(45, 45),
		Vertex(40, 45)]);
	many.setColor(Color.Red);
	
	Surface wiki = Surface("../../samples/img/wiki.png"); // <
	
	Color col = wiki.getColorAt(82, 33);
	writefln("color: at (%d:%d) is %d, %d, %d", 82, 33, col.red, col.green, col.blue);
	
	Surface copy = wiki.subSurface(ShortRect(0, 0, 50, 50)); // <
	copy.saveToFile("../../samples/img/wiki_sub.png");
	copy.setColorkey(Color(254, 200, 88));
	copy.setBlendMode(Surface.BlendMode.Add);
	copy.setAlphaMod(150);
	
	ShortRect dst = ShortRect(5, 5, 0, 0);
	wiki.blit(copy, null, &dst);
	wiki.saveToFile("../../samples/img/wiki_copy.png");
	
	Surface wiki2 = Surface("../../samples/img/wiki.png");
	///
	writefln("Bits: %d, Bytes: %d", wiki2.bits, wiki2.bytes);
	
	Texture tex = new Texture();
	tex.loadFromMemory(wiki2.pixels, wiki2.width, wiki2.height, wiki2.bits);
	Texture copy_tex = new Texture();
	copy_tex.loadFromMemory(copy.pixels, copy.width, copy.height, copy.bits);

	Surface copy_tex_srfc  = Surface.make(&copy_tex.getMemory()[0], copy_tex.width, copy_tex.height);
	copy_tex_srfc.saveToFile("../../samples/img/wiki_copy.png");
	
	ShortRect dst_copy = ShortRect(65, 25, copy.width, copy.height);
	
	Texture tex3 = tex.subTexture(dst_copy);
	writefln("\ttex3 -> w: %d, h: %d", tex3.width, tex3.height);
	Surface texToSrfc2 = Surface.make(tex3.getMemory().ptr, tex3.width, tex3.height, tex3.getFormat().formatToBits());
	texToSrfc2.saveToFile("../../samples/img/wiki_sub.png");
	
	tex.copy(copy_tex, &dst_copy);
//	writeln(" => ", tex);
	void[] mem = tex.getMemory();
	//writeln(" => ", mem);
	Surface texToSrfc = Surface.make(&mem[0], tex.width, tex.height, tex.getFormat().formatToBits());
	texToSrfc.saveToFile("../../samples/img/wiki_copy_tex.png");

	uint[256] xpixels = [
		255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255,
		0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0,
		0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0,
		0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0,
		0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 255, 0, 0, 255, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 255, 255, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 255, 255, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 255, 0, 0, 255, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0,
		0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0,
		0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0,
		0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0,
		255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255,
	];
	
	Surface xs = Surface.make(&xpixels[0], 16, 16);
	xs.saveToFile("XS.png");
	
	Spritesheet wiki_sprite = new Spritesheet(tex);
	wiki_sprite.setPosition(50, 100);
	wiki_sprite.setTextureRect(ShortRect(15, 15, 25, 25));
	
	uint[256] pixels = [
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0aab, 0x0789, 0x0bcc, 0x0eee, 0x09aa, 0x099a, 0x0ddd, 
		0x0fff, 0x0eee, 0x0899, 0x0fff, 0x0fff, 0x1fff, 0x0dde, 0x0dee, 
		0x0fff, 0xabbc, 0xf779, 0x8cdd, 0x3fff, 0x9bbc, 0xaaab, 0x6fff, 
		0x0fff, 0x3fff, 0xbaab, 0x0fff, 0x0fff, 0x6689, 0x6fff, 0x0dee, 
		0xe678, 0xf134, 0x8abb, 0xf235, 0xf678, 0xf013, 0xf568, 0xf001, 
		0xd889, 0x7abc, 0xf001, 0x0fff, 0x0fff, 0x0bcc, 0x9124, 0x5fff, 
		0xf124, 0xf356, 0x3eee, 0x0fff, 0x7bbc, 0xf124, 0x0789, 0x2fff, 
		0xf002, 0xd789, 0xf024, 0x0fff, 0x0fff, 0x0002, 0x0134, 0xd79a, 
		0x1fff, 0xf023, 0xf000, 0xf124, 0xc99a, 0xf024, 0x0567, 0x0fff, 
		0xf002, 0xe678, 0xf013, 0x0fff, 0x0ddd, 0x0fff, 0x0fff, 0xb689, 
		0x8abb, 0x0fff, 0x0fff, 0xf001, 0xf235, 0xf013, 0x0fff, 0xd789, 
		0xf002, 0x9899, 0xf001, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0xe789, 
		0xf023, 0xf000, 0xf001, 0xe456, 0x8bcc, 0xf013, 0xf002, 0xf012, 
		0x1767, 0x5aaa, 0xf013, 0xf001, 0xf000, 0x0fff, 0x7fff, 0xf124, 
		0x0fff, 0x089a, 0x0578, 0x0fff, 0x089a, 0x0013, 0x0245, 0x0eff, 
		0x0223, 0x0dde, 0x0135, 0x0789, 0x0ddd, 0xbbbc, 0xf346, 0x0467, 
		0x0fff, 0x4eee, 0x3ddd, 0x0edd, 0x0dee, 0x0fff, 0x0fff, 0x0dee, 
		0x0def, 0x08ab, 0x0fff, 0x7fff, 0xfabc, 0xf356, 0x0457, 0x0467, 
		0x0fff, 0x0bcd, 0x4bde, 0x9bcc, 0x8dee, 0x8eff, 0x8fff, 0x9fff, 
		0xadee, 0xeccd, 0xf689, 0xc357, 0x2356, 0x0356, 0x0467, 0x0467, 
		0x0fff, 0x0ccd, 0x0bdd, 0x0cdd, 0x0aaa, 0x2234, 0x4135, 0x4346, 
		0x5356, 0x2246, 0x0346, 0x0356, 0x0467, 0x0356, 0x0467, 0x0467, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 
		0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff];
	
	{
		Surface icon = Surface.make(pixels.ptr, 16, 16, 32);
		icon.saveToFile("icon.png");
		wnd.setIcon(icon);
	}
	
	Spritesheet sp = new Spritesheet(new Image("../../samples/Map/tileset.png"), ShortRect(119, 0, 16, 16));
	sp.setPosition(50, 200);
	
	Spritesheet sp2 = new Spritesheet(new Image("../../samples/img/tofte.png"), ShortRect(0, 0, 16, 16));
	sp2.setPosition(200, 50);
	
	Font font = Font("../../samples/font/arial.ttf", 14, Font.Mode.Blended);
	font.setHint(Font.Hint.Mono);
	Text text = new Text(font);
	text.setColor(Color.Blue);
	text.setPosition(25, 350);
	//text.setBlendMode(BlendMode.Multiply);
	//text.setBlendColor(Color.Red);
	//	text("При употреблении алкоголя всегда надо закусывать.");
	
	Color[4] colors = [Color.Red, Color.Magenta, Color.White, Color.Blue];
	ubyte cidx = 0;
	
	TiledMap tm = new TiledMap("../../samples/Map/map2.tmx");

	Blend blend = new Blend(Blend.Mode.Multiply, Color.Blue);
	
	Image trans_img = new Image("../../samples/img/wiki.png");

	Sprite trans_sprite = new Sprite(trans_img);
	trans_sprite.setBlend(blend);
	trans_sprite.setPosition(500, 400);
	
	Image img = new Image("../../samples/img/wiki.png");//, Texture.Format.RGB);
	
	Shape circle3 = Shape.makeCircle(50, Vector2f(180, 380), 30);
	circle3.bindTexture(img);
	circle3.setTextureRect(ShortRect(25, 25, 100, 100));
	circle3.move(300, -100);
	circle3.setRotation(25);

	float[12] pos = [
		170, 170, 0,
		310, 170, 0,
		310, 310, 0,
		170, 310, 0];
	
	Shape va = Shape.make(Shape.Type.Quad, pos);
	va.bindTexture(img);
	va.setColor(Color.Green.withTransparency(125));
	va.setRotation(25);
	
	Image exploImg = new Image("../../samples/img/explosion.png");
	Spritesheet explosion = new Spritesheet(exploImg, ShortRect(0, 0, 256, 256));
	explosion.setLoopCount(1);
	
	writeln("====");
	
	tm.setView(90, 90, 60, 60);
	//	tf.setRotation(45);
	//	tm.setTransform(tf);

	//wnd.clear();
	//wnd.display();
	//wnd.getClock().wait(1000);
	//
	//return;
	
	float[] mat = [
		55, 55, 0f,
		60, 55, 0f,
		60, 60, 0f,
		55, 60, 0f,
		15, 15, 0f,
		20, 15, 0f,
		20, 20, 0f,
		15, 20, 0f,
		30, 30, 0f,
		35, 30, 0f,
		35, 35, 0f,
		30, 35, 0f,
		40, 40, 0f,
		45, 40, 0f,
		45, 45, 0f,
		40, 45, 0f];
	
	Image fbo_img1 = new Image("../../samples/img/wiki.png");
	Image fbo_img2 = new Image("../../samples/img/wiki.png");
	
	Shape circle2 = Shape.makeCircle(25, Vector2f(60, 60));
	circle2.setSmooth(Smooth.Target.Line);
	circle2.setColor(Color.Red);
	circle2.fill(false);
	
	Shape va_many = Shape.make(Shape.Type.Quad, mat);
	
	FrameBufferObject fbo = new FrameBufferObject(fbo_img1);
	fbo.draw(va_many);
	fbo.setTexture(fbo_img2);
	fbo.draw(circle2);
	
	Sprite fbo_s1 = new Sprite(fbo_img1);
	fbo_s1.setPosition(500, 50);
	Sprite fbo_s2 = new Sprite(fbo_img2);
	fbo_s2.setPosition(680, 50);
	
	Clock myclock = new Clock();
	
	Event event;
	
	while (wnd.isOpen()) {
		wnd.clear();
		
		//		wnd.draw(bg);
		
		if (Keyboard.isPressed(Keyboard.Code.Left))
			writeln("Left");
		
		if (Keyboard.isPressed(Keyboard.Code.Right))
			writeln("Right");
		
		while (EventHandler.poll(&event)) {
			switch (event.type) { /* Process the appropriate event type */
				case Event.Type.KeyDown:  /* Handle a KEYDOWN event */
					writeln("Oh! Key press: ", event.keyboard.code);
					Time time = Clock.getTime();
					writefln("Game Loop runs now for %d ms - %f secs - %f min", time.msecs, time.seconds, time.minutes);

					sp.slideTextureRect();
					
					if (event.keyboard.key == Keyboard.Code.Esc) {
						EventHandler.push(Event.Type.Quit);
					} else if (event.keyboard.key == Keyboard.Code.Num1) {
						writefln("Sound #0 (type = %s) is %f seconds long.", sound[0].getType(), sound[0].getLength());
						sound[0].play();
						//writeln("set color");
						//qs.getVertexAt(0).color = Color.Red;
						//qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Num2) {
						writefln("Sound #1 (type = %s) is %f seconds long.", sound[1].getType(), sound[1].getLength());
						sound[1].play();
						//    writeln("set color");
						//    qs.getVertexAt(1).color = Color.Cyan;
						//    qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Num3) {
						writefln("Sound #2 (type = %s) is %f seconds long.", sound[2].getType(), sound[2].getLength());
						sound[2].play();
						//    writeln("set color");
						//    qs.getVertexAt(2).color = Color.Yellow;
						//    qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Num4) {
						//    writeln("set color");
						//    qs.getVertexAt(3).color = Color.Magenta;
						//    qs.update();
					} else if (event.keyboard.key == Keyboard.Code.Space) {
						//						tm.load("../level_1.tmx");
						//Keyboard.startTextInput();
					} else if (event.keyboard.key == Keyboard.Code.KP_Enter) {
						//Keyboard.stopTextInput();
					} else {
						writeln("Make screenshot");
						wnd.capture().saveToFile("screenshot.png");
					}
					
					if (event.keyboard.mod & Keyboard.Mod.Ctrl) {
						writeln("CTRL");
					}
					
					if (event.keyboard.mod & Keyboard.Mod.Shift) {
						writeln("SHIFT");
					}
					
					if (event.keyboard.mod & Keyboard.Mod.Caps) {
						writeln("CAPS");
					}
					
					if (event.keyboard.mod & Keyboard.Mod.Alt) {
						writeln("ALT");
					}
					
					if (event.keyboard.mod & Keyboard.Mod.Gui) {
						writeln("GUI");
					}
					
					if (event.keyboard.mod & Keyboard.Mod.Mode) {
						writeln("Alt Gr");
					}
					
					if (event.keyboard.mod & Keyboard.Mod.Num) {
						writeln("Num Lock");
					}
					
					writefln("Mod: %d", event.keyboard.mod);
					//qs.scale(-0.5, -0.5);
					//qs.rotate(15, 0, 0);
					//qs.move(150, -25);
					
					System.Power powI = System.getPowerInfo();
					
					writefln("Es verbleiben %d second bei %d %%. Status: %s",
					         powI.seconds, powI.percent, powI.state);
					writefln("Available RAM: %d.", System.getRAM());
					
					qs.setColor(colors[cidx++ % colors.length]);
					qs.setType(Shape.Type.LineLoop);
					
					//tm.move(5, 5);
					explosion.setLoopCount(1);
					
					if (event.keyboard.key == Keyboard.Code.Space) {
						/*img = new Image("../../samples/Map/new_tilset.png");
						 tm.exchangeTileset(img);
						 } else {*/
						tm.reload(Vector2s(1, 0), Vector2s(9, 4));
					}
					
					//tof.row = 1;
					
					if (event.keyboard.code == Keyboard.Code.F1) {
						wnd.toggleFullscreen();
						
						writeln("Is fullscreen: ", wnd.isFullscreen());
					}
					
					break;
					
				case Event.Type.MouseButtonDown:
					writefln("Mouse down at %d:%d", event.mouseButton.x, event.mouseButton.y);
					break;
					
				case Event.Type.Quit:
					wnd.close();
					break;
					
				default: break;
			}
		}
		//writefln("Current Fps: %d <=> %d", myclock.getCurrentFps(), wnd.getFpsLimit());
		
		text.format("Current Fps: %d <=> %d",
		            myclock.getCurrentFps(), wnd.getFpsLimit());
		wnd.draw(text); 
		
		wnd.draw(tm);
		
		//tf.setPosition(250, 50);
		//tf.setScale(0.5f);
		////tf.activateView(true);
		//
		wnd.draw(tm);
		//
		////tf.activateView(false);
		//tf.resetTranslation();
		//
		wnd.draw(qs);
		wnd.draw(many);
		wnd.draw(circle);
		wnd.draw(circle3);
		
		wnd.draw(wiki_sprite);
		wnd.draw(sp);
		wnd.draw(sp2);
		wnd.draw(explosion);
		
		wnd.draw(trans_sprite);
		
		wnd.draw(fbo_s1);
		wnd.draw(fbo_s2);
		
		sp2.slideTextureRect();
		//explosion.slideTextureRect();
		explosion.execute();
		
		wnd.draw(va);
		
		//tof.slide();
		//wnd.draw(tof);
		
		//qs.move(1, 1);
		wnd.display();
		
		//SDL_Delay(20);
	}
	
	writeln("\tend of main");
}