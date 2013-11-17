module Dgame.Internal.Log;

private {
	import std.file : append;
	import std.string : format;

	import Dgame.Window.MessageBox;
}

struct Log {
	static string LogFile;

	template error(size_t line = __LINE__, string filename = __FILE__, Args...) {
		static void error(string msg, Args args) {
			static immutable string Err = "Error";

			static if (args.length != 0)
				msg = .format(msg, args);

			if (LogFile.length != 0)
				.append(LogFile, format("%s: %s @ %s ; %d.", Err, msg, filename, line));

			MessageBox(MessageBox.Error, Err, msg).show();
			throw new Exception(msg, filename, line);
		}
	}

	static void info(Args...)(string msg, Args args) {
		import std.stdio : writeln, writefln;

		version(none) {
			if (LogFile.length != 0) {
				static if (args.length != 0)
					.append(LogFile, .format(msg, args));
				else
					.append(LogFile, msg);
			}
		}

		static if (args.length != 0)
			writefln(msg, args);
		else
			writeln(msg);
	}
}