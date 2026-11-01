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

The independent Idriç program compiles and executes under the pinned current
frontend. Its CRC standard value, valid record and targeted checksum/UTF-8/
framing/duplicate controls pass. The first source attempt exposed ambiguous
chained record updates and repeated nested pattern names; explicit expected
entry constructors and distinct subterm names resolve those diagnostics without
another language or backend. The generated ART caller independently assembles
and decodes; execution remains pending. The copy fixture compiles with ICK and
links against NDK 27.2.12479018. Grease parse/expression checks pass after replacing
an invalid `@split(...)` spelling with documented `@[split(...)]` list splicing.

The next stage adds explicit own-copy/intervening-capture expectations,
twenty numbered overflow fixtures, real SDK readback after visible input,
smali-only caller-identity controls and independently compiled permission/UID
mutants. Lifecycle procedures cover observer crash, real manager revocation,
framework expiration and reboot. These definitions have not yet passed Android
execution. The private controlled capability is never printed or archived;
neither identity control inserts clipboard history. General test-data and
snapshot work remains checked Idriç, and procedures remain Grease.

API 29/34 execution of the previous observer reached case 21 and failed. Actual
fixture bytes showed that System.File's text write stopped at embedded NUL.
Fixture writes now use Data.Buffer and explicit UTF-8; independent fixture reads
also preserve NUL while history-record validation continues to refuse it. The
new binary roundtrip control passes locally, including a zero byte at offset 6
in nul.txt and in the framed ART request. No consumer assertion changed. Spatial
UI, real legacy-APK upgrade and corrupt migration procedures are now defined;
their Android execution is still pending.

Consumer 96b7af1d1b76fc660e91a3a91366ee0906d3b071, run 41331507210,
fails actual fixture installation on API 29/34 with
INSTALL_FAILED_INVALID_APK / Failed to extract native libraries, res=-2.
Inspection shows the fixture requested extractNativeLibs=false while the
canonical packager emitted a compressed .so. The fixture now explicitly selects
normal native extraction, matching its actual packaging. Installation must be
rerun; a packaging receipt alone is not installed acceptance. The exposed
provider mutant also removes its reinforcing native manifest-permission check
and is genuinely recompiled, so the independent caller isolates Android's
permission enforcement rather than failing startup for a different reason.
