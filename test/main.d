import std.stdio;

import Dgame.Window.Window;
import Dgame.Window.Event;

import Dgame.Graphic.Color;
import Dgame.Graphic.Surface;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Sprite;
import Dgame.Graphic.Spritesheet;
import Dgame.Graphic.Shape;
import Dgame.Graphic.Text;

import Dgame.Math.Vector2;
import Dgame.Math.Vertex;
import Dgame.Math.Matrix4;
import Dgame.Math.Rect;

import Dgame.Audio.Sound;

import Dgame.System.Keyboard;
import Dgame.System.Font;
import Dgame.System.StopWatch;

pragma(msg, Color4b.sizeof);
pragma(msg, Color4f.sizeof);
pragma(msg, Matrix4.sizeof);
pragma(msg, Window.sizeof);
pragma(msg, Surface.sizeof);
pragma(msg, Texture.sizeof);
pragma(msg, Vector2i.sizeof);
pragma(msg, Vector2f.sizeof);
pragma(msg, Vertex.sizeof);

void main() {
    Window wnd = Window(480, 640, "Dgame App - Test");

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

    Surface xs = Surface(xpixels.ptr, 16, 16);
    xs.saveToFile("samples/images/XS.png");

    wnd.setIcon(xs);

    Surface wiki_srfc = Surface("samples/images/wiki.png");
    wiki_srfc.saveToFile("samples/images/wiki_copy.png");

    Texture wiki_tex = Texture(wiki_srfc);
    writeln(wiki_tex.width, ':', wiki_tex.height, ':', wiki_tex.depth, ':', wiki_tex.getFormat());

    Sprite wiki = new Sprite(wiki_tex);
    wiki.setPosition(300, 300);

    Shape qs = new Shape(
        Geometry.Quad,
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
    circle.useAntiAlias = true;

    Shape many = new Shape(Geometry.Quad,
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
        Geometry.Quad,
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
    texQuad.setRotation(25);

    Shape tri = new Shape(
        Geometry.TriangleStrip,
        [
            Vertex(Vector2f(100, 100), Vector2f.init, Color4b.Red),
            Vertex(Vector2f(300, 100), Vector2f.init, Color4b.Green),
            Vertex(Vector2f(  0, 300), Vector2f.init, Color4b.Blue),
        ]
    );

    Font fnt = Font("samples/font/arial.ttf", 22);
    Text curFps = new Text(fnt);
    curFps.setPosition(200, 10);

    StopWatch sw;

    Sound explosion_sound = Sound("samples/audio/expl.wav");
    //explosion_sound.setVolume(75);

    Surface explo_srfc = Surface("samples/images/explosion.png");
    Texture explosion_tex = Texture(explo_srfc);
    Spritesheet explosion = new Spritesheet(explosion_tex, Rect(0, 0, 256, 256));
    explosion.setPosition(100, 100);

    Event event;

    //ushort fps = 0;

    import derelict.opengl3.gl;
    import derelict.sdl2.sdl;

    bool loop = true;
    while (loop) {
        //if (sw.getElapsedTime().msecs >= 1000) {
        //    printf("FPS: %d\n", fps);
        //    curFps.format("Current FPS: %d.", fps);

        //    fps = 0;
        //    sw.reset();
        //} else
        //    fps++;

        curFps.format("Current FPS: %d.", sw.getCurrentFPS());

        while (wnd.poll(&event)) {
            if (event.type == Event.Type.Quit) {
                loop = false;
            } else if (event.type == Event.Type.KeyDown) {
                if (event.keyboard.key == Keyboard.Code.Esc)
                    wnd.push(Event.Type.Quit);
                else if (event.keyboard.key == Keyboard.Code.Printscreen)
                    wnd.capture().saveToFile("samples/images/capture.png");
                else if (event.keyboard.key == Keyboard.Code.Space) {
                    explosion_sound.play();
                    explosion.slideTextureRect();
                }
            }
        }

        wnd.clear();
/+
        glBegin(GL_TRIANGLE_STRIP);
            glVertex3f(10, 100, 0);
            glVertex3f(10, 10, 0);
            glVertex3f(100, 100, 0);
            glVertex3f(100, 10, 0);
        glEnd();

        glBegin(GL_TRIANGLES);
            glColor3f(1, 0, 0);
            glVertex3f(100, 100, 0);
            glColor3f(0, 1, 0);
            glVertex3f(300, 100, 0);
            glColor3f(0, 0, 1);
            glVertex3f(0, 300, 0);
        glEnd();
+/
        wnd.draw(wiki);

        wnd.draw(qs);
        wnd.draw(circle);
        wnd.draw(many);
        wnd.draw(texQuad);
        wnd.draw(tri);

        wnd.draw(explosion);

        wnd.draw(curFps);

        wnd.display();
    }
}