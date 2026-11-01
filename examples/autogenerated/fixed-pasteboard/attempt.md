# Independent Fixed Pasteboard observer

The consumer is the retained utilities-android-phone-user Pasteboard, not a
replacement. This attempt uses Idriç for independent binary-record inspection,
fixture text, framed requests and explicit expected responses. It imports no
consumer model, encoder, decoder or storage implementation. Smali is an
independent ART caller, not a producer for candidate application code. A separate
NativeActivity fixture performs real Android clipboard copies when its visible
buttons receive input; it never injects history records.

The oracle must identify the exact consumer/compiler/APK/environment, reject a
compiled wrong-order source mutant, reject corrupt/checksum-invalid snapshots,
and distinguish installed clipboard behavior from host reference behavior.
Native code is restricted to the fixture's SDK effects and UI. Source is owned
by ICK; upstream NativeActivity glue, assembly and linking belong to the pinned
NDK. No Java/Kotlin source is generated or compiled.

The host binary API accepts `Int` offsets because Data.Buffer exposes that
compatibility boundary. Checked framing uses natural Unicode scalar counts;
record integrity uses explicit Bits32/Bits64. Binary headers never become text
before their length and CRC are checked. No payload enters diagnostics.

Execution is in progress. No ART, installed APK, privileged observer or physical
device success is established by source presence. Any compiler/runtime gap and
fallback must be recorded here rather than silently changing language/backend.
