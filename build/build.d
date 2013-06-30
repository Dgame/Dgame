import std.path : dirName;
import std.stdio : writefln, writeln;
import std.process : shell, ErrnoException;
import std.file : read, exists, mkdir, dirEntries, SpanMode;
import std.array : endsWith;
import std.string : format, toUpper, capitalize;

enum {
	MajorVersion = "1",
	MinorVersion = "0",
	BumpVersion  = "0",
	FullVersion  = MajorVersion ~ "." ~ MinorVersion ~ "." ~ BumpVersion
}

version(Windows) {
    enum prefix = "";
	
    version(Shared) {
		enum extension = ".dll";
	} else  {
		enum extension = ".lib";
	}
} else version(Posix) {
    enum prefix = "lib";
	
    version(Shared) {
		enum extension = ".so";
	} else {
		enum extension = ".a";
	}
} else {
    static assert(false, "Unknown operating system.");
}

string derelictImportDir;

// Compiler configuration
version(DigitalMars) {
	version(Shared) {
		static assert(false, "Shared library support is not yet available with DMD.");
	}
	
	pragma(msg, "Using the Digital Mars DMD compiler.");
	
	// -property 
	debug {
		enum compilerOptions = "-lib -O -debug -g -wi";
	} else {
		enum compilerOptions = "-lib -O -release -inline -noboundscheck -wi";
	}

	string buildCompileString(string files, string libName) {
		return format("dmd %s -of%s%s %s %s", compilerOptions, outdir, libName, files, derelictImportDir);
	}
} else version(GNU) {
    pragma(msg, "Using the GNU GDC compiler.");
	
    version(Shared) {
		enum compilerOptions = "-s -O3 -Wall -shared";
    } else {
		enum compilerOptions = "-s -O3 -Wall";
	}
	
    string buildCompileString(string files, string libName) {
		version(Shared) {
			return format("gdc %s -Xlinker -soname=%s.%s -o %s%s.%s %s %s", 
				compilerOptions, libName,MajorVersion, outdir, libName, FullVersion, files, derelictImportDir);
		} else {
			return format("gdc %s -o %s%s %s %s", compilerOptions, outdir, libName, files, derelictImportDir);
		}
    }
} else version(LDC) {
    pragma(msg, "Using the LDC compiler.");
	
    version(Shared) {
		enum compilerOptions = "-shared -O -release -enable-inlining -property -wi";
	} else {
		enum compilerOptions = "-lib -O -release -enable-inlining -property -wi";
	}
	
    string buildCompileString(string files, string libName) {
        version(Shared) {
            return format("ldc2 %s -soname=%s.%s -of%s%s.%s %s %s",
            	compilerOptions, libName, MajorVersion, outdir, libName, FullVersion, files, derelictImportDir);
		} else {
            return format("ldc2 %s -of%s%s %s %s", compilerOptions, outdir, libName, files, derelictImportDir);
		}
    }
} else {
    static assert(false, "Unknown compiler.");
}

// Package names
enum packMain = "Dgame";
enum packExt  = "../";
enum packGraphics = "Graphics";
enum packSystem = "System";
enum packWindow = "Window";
enum packMath   = "Math";
enum packAudio  = "Audio";
enum packCore   = "Core";
// enum packAudioCore = packAudio ~ packCore;

// Source paths
enum srcGraphics = packExt ~ '/' ~ packGraphics;
enum srcSystem = packExt ~ '/' ~ packSystem;
enum srcWindow = packExt ~ '/' ~ packWindow;
enum srcMath   = packExt ~ '/' ~ packMath;
enum srcAudio  = packExt ~ '/' ~ packAudio;
enum srcCore   = packExt ~ '/' ~ packCore;
// enum srcAudioCore = packExt ~ '/' ~ packAudio ~ '/' ~ packCore;

enum Debug = "/Debug/";
enum Release = "/Release/";

// Map package names to source paths.
string[string] pathMap;
string buildPath;
string outdir = "lib/";

static this() {
    // Initializes the source path map.
    pathMap = [
        packGraphics : srcGraphics,
        packSystem : srcSystem,
        packWindow : srcWindow,
        packMath   : srcMath,
        packAudio  : srcAudio,
        packCore   : srcCore,
        // packAudioCore : srcAudioCore
    ];
}

void main(string[] args) {
    // Determine the path to this executable so that imports and source files can be found
    // no matter what the working directory.
    buildPath = args[0].dirName() ~ "/";
	
	if (!outdir.exists())
		mkdir(outdir);

	derelictImportDir = "-I" ~ cast(string) read("build.txt");
	
	debug
		outdir ~= Debug;
	else
		outdir ~= Release;
	
	if (!outdir.exists())
		mkdir(outdir);

    if (buildPath != "./") {
		outdir = buildPath ~ outdir;

		// fix up the package paths
		auto keys = pathMap.keys;
		foreach(i, s; pathMap.values) {
			pathMap[keys[i]] = buildPath ~ s;
		}
    }

	buildAll();
}

// Build all of the Dgame libraries.
void buildAll() {
	debug
		writeln("Building Dgame in debug mode");
	else
		writeln("Building Dgame in release mode");
	
	string libNames = " ";
    try {
		foreach(key; pathMap.keys) {
			libNames ~= buildPackage(key);
			libNames ~= " ";
		}
    }
    // Eat any ErrnoException. The compiler will print the right thing on a failed build, no need
    // to clutter the output with exception info.
    catch (ErrnoException e) { }
}

string buildPackage(string packageName) {
    writefln("Building %s", packageName);
    writeln();

    // Build up a string of all .d files in the directory that maps to packageName.
    string joined;
	
    auto p = pathMap[packageName];
    foreach(string s; dirEntries(pathMap[packageName], SpanMode.breadth)) {
		if (s.endsWith(".d")) {
			writeln(s);
			joined ~= " " ~ s;
		}
    }

    string libName = format("%s%s%s%s", prefix, "Dgame", packageName, extension);
    string arg = buildCompileString(joined, libName);
	
    string s = shell(arg);
    writeln(s);
    writeln("Build succeeded.");
	
	return libName;
}