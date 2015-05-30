import std.stdio;

import Dgame.Graphic;
import Dgame.Math;
import Dgame.Audio;
import Dgame.System;
import Dgame.Window;

debug {
    pragma(msg, Color4b.sizeof);
    pragma(msg, Color4f.sizeof);
    pragma(msg, Matrix4x4.sizeof);
    pragma(msg, Window.sizeof);
    pragma(msg, Surface.sizeof);
    pragma(msg, Texture.sizeof);
    pragma(msg, Vector2i.sizeof);
    pragma(msg, Vector2f.sizeof);
    pragma(msg, Vertex.sizeof);
    pragma(msg, GLSettings.sizeof);
}

void main() {
    Window wnd = Window(480, 640, "Dgame App - Test", Window.Style.Default, GLSettings(0, 0, 2));
    //wnd.setVerticalSync(Window.VerticalSync.Enable);
/*
    immutable int display_count = DisplayMode.getNumOfDisplays();
    writeln("Display count = ", display_count);
    writeln("All Display modes:");

    for (ubyte i = 0; i < display_count; i++) {
        writeln("Modes of Display #", i);
        foreach (ref const DisplayMode dm; DisplayMode.listModes(i)) {
            writeln("\t", dm.width, ':', dm.height, ':', dm.refreshRate);
        }
    }
*/
    immutable uint black = Color4b.Black.asHex();
    immutable uint blue = Color4b.Blue.asHex();
    uint[256] xpixels = [
        blue, black, black, black, black, black, black, black, black, black, black, black, black, black, black, blue,
        black, blue, black, black, black, black, black, black, black, black, black, black, black, black, blue, black,
        black, black, blue, black, black, black, black, black, black, black, black, black, black, blue, black, black,
        black, black, black, blue, black, black, black, black, black, black, black, black, blue, black, black, black,
        black, black, black, black, blue, black, black, black, black, black, black, blue, black, black, black, black,
        black, black, black, black, black, blue, black, black, black, black, blue, black, black, black, black, black,
        black, black, black, black, black, black, blue, black, black, blue, black, black, black, black, black, black,
        black, black, black, black, black, black, black, blue, blue, black, black, black, black, black, black, black,
        black, black, black, black, black, black, black, blue, blue, black, black, black, black, black, black, black,
        black, black, black, black, black, black, blue, black, black, blue, black, black, black, black, black, black,
        black, black, black, black, black, blue, black, black, black, black, blue, black, black, black, black, black,
        black, black, black, black, blue, black, black, black, black, black, black, blue, black, black, black, black,
        black, black, black, blue, black, black, black, black, black, black, black, black, blue, black, black, black,
        black, black, blue, black, black, black, black, black, black, black, black, black, black, blue, black, black,
        black, blue, black, black, black, black, black, black, black, black, black, black, black, black, blue, black,
        blue, black, black, black, black, black, black, black, black, black, black, black, black, black, black, blue,
    ];

    Surface xs = Surface(xpixels.ptr, 16, 16);
    xs.saveToFile("samples/images/XS.png");

    wnd.setIcon(xs);

    ushort[256] sdl_pixels = [
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
        0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff, 0x0fff
    ];

    Surface sdl_logo = Surface(sdl_pixels.ptr, 16, 16, 16, Masks(0x0f00, 0x00f0, 0x000f, 0xf000));
    sdl_logo.saveToFile("samples/images/sdl_logo.png");

    Surface blit_test = Surface(64, 64);
    blit_test.blit(xs);
    Rect dest = Rect(16, 0, 16, 16);
    blit_test.blit(sdl_logo, null, &dest);
    blit_test.saveToFile("samples/images/blit_test.png");

    string filenameWithTail = "samples/images/XS.png;trailing chars goes here";
    string cleanFilename = filenameWithTail[0 .. 21];
    writeln("Clean filename is ", cleanFilename);
    Surface xs2 = Surface(cleanFilename);
    xs2.saveToFile("samples/images/xs2.png");

    Surface wiki_srfc = Surface("samples/images/wiki.png");
    wiki_srfc.saveToFile("samples/images/wiki_copy.png");

    Texture wiki_tex = Texture(wiki_srfc);
    wiki_tex.setSmooth(true);
    writeln(wiki_tex.id, ':', wiki_tex.width, ':', wiki_tex.height, ':', wiki_tex.format);

    Joystick controller;
    // Check for joysticks
    if (Joystick.count() < 1)
        writeln("Warning: No joysticks connected!");
    else {
        controller = Joystick(0);

        writeln("Game Controller Name: ", controller.getName());
    }

    Sprite wiki = new Sprite(wiki_tex);
    wiki.setPosition(300, 300);
    
    Texture ship_tex = Texture(Surface("samples/images/starship_sprite.png"));
    Spritesheet ship = new Spritesheet(ship_tex, Rect(0, 0, 64, 64));
    ship.setPosition(200, 32);
    ship.setRotationCenter(32, 32);

    Shape qs = new Shape(
        Geometry.Quads,
        [
            Vertex( 75,  75),
            Vertex(175,  75),
            Vertex(175, 175),
            Vertex( 75, 175)
        ]
    );
    qs.fill = Shape.Fill.Line;
    qs.setColor(Color4b.Blue);
    qs.setPosition(250, 10);

    Shape circle = new Shape(25, Vector2f(180, 380));
    circle.setColor(Color4b.Green);

    Shape many = new Shape(Geometry.Quads,
        [
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
            Vertex(40, 45)
        ]
    );
    many.fill = Shape.Fill.Full;
    many.setColor(Color4b.Red);

    Shape texQuad = new Shape(
        Geometry.Quads,
        [
            Vertex(  0,  0),
            Vertex(140,  0),
            Vertex(140, 140),
            Vertex(  0, 140)
        ]
    );
    texQuad.setTexture(&wiki_tex);
    texQuad.setColor(Color4b.Green.withTransparency(125));
    texQuad.setPosition(175, 425);
    texQuad.setRotationCenter(70, 70);
    texQuad.setRotation(25);

    Shape tri = new Shape(
        Geometry.TriangleStrip,
        [
            Vertex(Vector2f(100, 100), Vector2f.init, Color4b.Red),
            Vertex(Vector2f(300, 100), Vector2f.init, Color4b.Green),
            Vertex(Vector2f(  0, 300), Vector2f.init, Color4b.Blue),
        ]
    );

    Shape s1 = new Shape(Geometry.Quads, [Vertex(0, 0), Vertex(100, 0), Vertex(100, 100), Vertex(0, 100)]);
    s1.setColor(Color4b.Green);
    //s1.setRotationCenter(50, 50);
    s1.setOrigin(50, 50);
    s1.setRotation(45);
    s1.setPosition(240, 320);

    Shape s2 = new Shape(Geometry.Quads, [Vertex(0, 0), Vertex(50, 0), Vertex(50, 50), Vertex(0, 50)]);
    s2.setColor(Color4b.Blue);
    //s2.setRotationCenter(25, 25);
    s2.setOrigin(25, 25);
    s2.setPosition(240, 320);

    Shape s3 = new Shape(10, Vector2f(0, 0));
    s3.setColor(Color4b.Red);
    s3.setRotation(90);
    s3.setPosition(240, 320);

    Font fnt = Font("samples/font/arial.ttf", 22);
    Text curFps = new Text(fnt);
    curFps.setPosition(200, 10);

    StopWatch fps_sw;
    //StopWatch sw;

    //immutable ubyte FPS = 60;
    //immutable ubyte TicksPerFrame = 1000 / FPS;

    Sound explosion_sound = Sound("samples/audio/expl.wav");
    //explosion_sound.setVolume(75);

    Surface explo_srfc = Surface("samples/images/explosion.png");
    Texture explosion_tex = Texture(explo_srfc);
    Spritesheet explosion = new Spritesheet(explosion_tex, Rect(0, 0, 256, 256));
    explosion.setPosition(100, 100);

    Texture frames_tex = Texture(Surface("samples/images/frames.png"));
    Spritesheet frames = new Spritesheet(frames_tex, Rect(0, 0, 32, 32));
    
    ubyte idx = 0;

    Event event;

    //ushort fps = 0;

    bool loop = true;
    while (loop) {
        //if (sw.getElapsedTicks() < TicksPerFrame)
        //    continue;
        //else
        //    sw.reset();

        //if (sw.getElapsedTime().msecs >= 1000) {
        //    printf("FPS: %d\n", fps);
        //    curFps.format("Current FPS: %d.", fps);

        //    fps = 0;
        //    sw.reset();
        //} else
        //    fps++;

        curFps.format("Current FPS: %d.", fps_sw.getCurrentFPS());

        while (wnd.poll(&event)) {
            if (event.type == Event.Type.Quit) {
                loop = false;
            } else if (event.type == Event.Type.KeyDown) {
                if (event.keyboard.key == Keyboard.Key.Esc)
                    wnd.push(Event.Type.Quit);
                else if (event.keyboard.key == Keyboard.Key.S)
                    wnd.capture().saveToFile("samples/images/capture.png");
                else if (event.keyboard.key == Keyboard.Key.Space) {
                    explosion_sound.play();
                    explosion.slideTextureRect();
                } else if (event.keyboard.key == Keyboard.Key.Dot) {
                    frames.selectFrame(idx);
                    writeln(idx);
                    idx++;

                    ship.rotate(20);
                } else if (event.keyboard.key == Keyboard.Key.Comma)
                    writeln("Window is on display ", wnd.getDisplayIndex());
                else if (event.keyboard.key == Keyboard.Key.F)
                    wnd.toggleFullscreen();
                else if (event.keyboard.key == Keyboard.Key.D)
                    wnd.setFullscreen(Window.Style.Desktop);
            } else if (event.type == Event.Type.JoystickAxisMotion) {
                writeln("Joystick #", event.joystick.motion.which,
                        " moved about ", event.joystick.motion.value,
                        " around axis ", event.joystick.motion.axis);
            } else if (event.type == Event.Type.JoystickHatMotion) {
                writeln("Joystick #", event.joystick.hat.which,
                        " moved about ", event.joystick.hat.value,
                        " around hat ", event.joystick.hat.hat);
            } else if (event.type == Event.Type.JoystickButtonDown) {
                writeln("Joystick #", event.joystick.button.which,
                        " pressed button ", event.joystick.button.button);
            }
        }

        wnd.clear();

        wnd.draw(ship);
        wnd.draw(wiki);

        wnd.draw(qs);
        wnd.draw(circle);
        wnd.draw(many);
        wnd.draw(texQuad);
        wnd.draw(tri);

        wnd.draw(s1);
        wnd.draw(s2);
        wnd.draw(s3);

        wnd.draw(explosion);
        wnd.draw(frames);

        wnd.draw(curFps);

        wnd.display();
    }
}
