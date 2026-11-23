# Android Grease worker qualification

The current Grease source gitlink owns language semantics. This observer executes
the separately built x86_64 Android engine in its inherited YSH mode on actual
API 29/34 emulators. It compares literal metacharacter-containing URI bytes and
an opaque NUL/non-UTF-8 payload, rejects a changed interpreted program's output,
and requires a declared invalid-scheme refusal with no stdout prefix.

The source mutant is an interpreted Grease program, not a compiled C++ runtime
mutant. No shell command is built from the URI; it is pushed as a data file.
Native ELF/build provenance, host generation, target execution, actual Shizuku,
ICU acquisition and physical-device acceptance remain distinct boundaries.
