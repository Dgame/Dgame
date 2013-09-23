module build;

import std.stdio;
import std.path : dirName, buildNormalizedPath, absolutePath;
import std.process : system, ErrnoException;
import std.file : mkdir, exists, read, dirEntries, SpanMode;
import std.array : endsWith;
import std.string : format, toUpper, chop;
import std.exception : enforce;

version(DigitalMars) {
	enum {
		DMD = true,
		GDC = false,
		LDC = false
	}
} else version(GNU) {
	enum {
		DMD = false,
		GDC = true,
		LDC = false
	}
} else version(LDC) {
	enum {
		DMD = false,
		GDC = false,
		LDC = true
	}
}

version(Windows) {
	enum {
		Windows = true,
		Posix = false
	}
} else version(Posix) {
	enum {
		Windows = false,
		Posix = true
	}
} else
    static assert(false, "Unknown operating system.");

enum {
	Project = "Dgame",
	LibDir  = "lib",
	srcDgame = "../"
}

// Compiler configuration
version(DigitalMars) {
	pragma(msg, "Using the Digital Mars DMD compiler.");

	enum CompilerOptions = "-lib -O -release -inline -wi";

	string buildCompileString(string files, string libName) {
		return format("dmd %s -of%s/%s %s -I%s", CompilerOptions, outdir, libName, files, derelictImportDir);
	}
} else version(GNU) {
	pragma(msg, "Using the GNU GDC compiler.");
	
	enum CompilerOptions = "-c -s -O3 -Wall";

	string buildCompileString(string files, string libName) {
		return format("gdc %s -o %s/%s %s -I%s", CompilerOptions, outdir, libName, files, derelictImportDir);
	}
} else version(LDC) {
	pragma(msg, "Using the LDC compiler.");

	enum CompilerOptions = "-lib -O -release -enable-inlining -w -wi";

	string buildCompileString(string files, string libName) {
		return format("ldc2 %s -of%s/%s %s -I%s", CompilerOptions, outdir, libName, files, derelictImportDir);
	}
} else
	static assert(false, "Unknown compiler.");

static if (Windows && DMD) {
	enum {
		Prefix = "",
		Extension = ".lib"
	}
} else static if (Posix || GDC || LDC) {
	enum {
		Prefix = "lib",
		Extension = ".a"
	}
} else
	static assert(false, "Unknown operating system and compiler.");

struct Package {
	const string name;
	string path;
}

final abstract class Pack {
public:
	static const Core	= Package("Core",	srcDgame ~ "Core/");
	static const Audio	= Package("Audio",	srcDgame ~ "Audio/");
	static const Graphics = Package("Graphics", srcDgame ~ "Graphics/");
	static const Math 	= Package("Math",	srcDgame ~ "Math/");
	static const System = Package("System",	srcDgame ~ "System/");
	static const Window = Package("Window", srcDgame ~ "Window/");
}

// Map package names to source paths.
Package[string] pathMap;

string buildPath;
string derelictImportDir;

debug {
	string outdir = LibDir ~ "/Debug";
} else {
	string outdir = LibDir ~ "/Release";
}

static this() {
	if (!LibDir.exists())
		mkdir(LibDir);
		
	if (!outdir.exists())
		mkdir(outdir);
		
	// Initializes the source path map.
	pathMap = [
		Pack.Core.name.toUpper() : Pack.Core,
		Pack.Audio.name.toUpper() : Pack.Audio,
		Pack.Graphics.name.toUpper() : Pack.Graphics,
		Pack.Math.name.toUpper() : Pack.Math,
		Pack.System.name.toUpper() : Pack.System,
		Pack.Window.name.toUpper() : Pack.Window,
	];
}

enum DerelictDirname = "\\derelict";

void main(string[] args) {
	// Determine the path to this executable so that imports and source files can be found
	// no matter what the working directory.
	buildPath = args[0].dirName();

	string derelictPath = args[0].absolutePath().dirName() ~ "\\..\\.." ~ DerelictDirname;
	derelictPath = derelictPath.buildNormalizedPath();

	writeln("Assume '", derelictPath, "' as derelict path.");
	writeln("Verify...\n");

	/*if (.exists(derelictPath))
		derelictImportDir = derelictPath;
	else */{
		writeln("Assume, that the derelict path is in 'external.txt'.");
		writeln("Verify...\n");

		if (.exists(buildPath ~ "/external.txt"))
			derelictImportDir = cast(string) .read(buildPath ~ "/external.txt");

		if (derelictImportDir.length == 0 || !.exists(derelictImportDir)) {
			do {
				writeln("Derelict import path not found.");
				writeln("You can enter the full path in 'external.txt'.");
				writeln("But for now, please enter the full path here or press q for quit:");

				derelictImportDir = readln().chop();

				if (derelictImportDir[0] == 'q')
					return;

				if (.exists(derelictImportDir)) {
					if (derelictImportDir.endsWith(DerelictDirname))
						break;

					derelictImportDir ~= DerelictDirname;
					if (.exists(derelictImportDir))
						break;
				}
			} while (true);
		}
	}

	if (derelictImportDir.endsWith(DerelictDirname))
		derelictImportDir = derelictImportDir.dirName();

	if (buildPath != "./") {
		outdir = buildNormalizedPath(buildPath, outdir);

		// fix up the package paths
		foreach (ref Package pack; pathMap) {
			pack.path = buildNormalizedPath(buildPath, pack.path);
		}
	}

	if (args.length == 1)
		buildAll();
	else
		buildSome(args[1 .. $]);
}

// Build all of the Derelict libraries.
void buildAll() {
	writeln("Building all packages.");
	try {
		foreach (ref Package pack; pathMap) {
			buildPackage(pack);
		}

		writeln("\nAll builds complete\n");
	}
	// Eat any ErrnoException. The compiler will print the right thing on a failed build, no need
	// to clutter the output with exception info.
	catch (ErrnoException e) {
		writeln("\nBuild Failed!\n");
	}
}

// Build only the packages specified on the command line.
void buildSome(string[] args) {
	try {
		// If any of the args matches a key in the pathMap, build
		// that package.
		foreach (s; args) {
			auto key = s.toUpper();

			Package* p = key in pathMap;
			if (!p)
				writefln("Unknown package '%s'", s);
			else
				buildPackage(*p);
		}

		writeln("\nSelected builds complete\n");
	} catch (ErrnoException e) {
		writeln("\nBuild Failed!\n");
	}
}

void buildPackage(ref const Package pack) {
	writeln();
	writefln("Building %s/%s", Project, pack.name);
	writeln();

	// Build up a string of all .d files in the package directory.
	string joined;
	foreach (string s; dirEntries(pack.path, SpanMode.breadth)) {
		if (s.endsWith(".d")) {
			writeln(s);
			joined ~= " " ~ s;
		}
	}

	writeln();

	string libName = format("%s%s%s%s", Prefix, Project, pack.name, Extension);
	string arg = buildCompileString(joined, libName);
	writeln(arg);

	(system(arg) == 0).enforce(new ErrnoException("Build failure"));

	writeln("Build succeeded.");
}
