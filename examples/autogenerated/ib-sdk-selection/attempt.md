# Observe a real SDK selection transition before exact source copying

API 34 selection failures at stage 4 occur when the observer requires
ACTION_SET_SELECTION to return true. Android 14's maintained TextView
implementation returns false if the requested range already equals its
current selection. This is a documented source-level precondition issue
for repeated full-source copies; the original failed captures did not
record their prior SDK range, so their exact cause is not retroactively
declared proven.

Primary platform source:
https://github.com/aosp-mirror/platform_frameworks_base/blob/android-14.0.0_r1/core/java/android/widget/TextView.java#L14276

The observer now establishes a collapsed [0,0] selection through the real
SDK action, waits for the UI queue, refreshes its actual AccessibilityNode,
and requires the independently observed empty range. It then requires
the original full-range ACTION_SET_SELECTION to return true, refreshes
again and verifies exactly [0, UTF16 display length] before invoking COPY.
The stale clipboard sentinel, owned source-selection label, exact source
text and compiled source-copy mutation requirements are unchanged.
This strengthens the observed postcondition rather than accepting false
as a successful selection action or fabricating a clipboard.

Only the existing SDK/ART observation adapter changes. No IB reader,
decoder, DEX, native view, text coordinates, source or identity gate changes.
This boundary-specific observer is Smali like the retained acceptance
suite; no candidate Smali or alternative reader implementation is added.
Fresh API 29/API 34 results are NOT_RUN at authoring.

The source-qualified native diagnostic b75157e6 now reproduces actual
Google StackOverflowError on both APIs through the genuine ChordReader
button/caller and ICU/Arena path. The independent controlled consumer maps
its repeated checked helper to Prelude.Types.traverse and source-octet
validation. Search diagnostic output now also maps the actually observed
native Activity method names through its retained compiler plan. No
Google results or clicked-result success is inferred from handoff PASS.

Observer e4aee598 API 29 passes the expanded transport, actual legacy
decode/copy/reflow and offline/reboot continuation, then loses the emulator
connection before the final source snapshot (adb error: closed, emulator
TCP port absent). That job is FAIL; independent source capture is NOT_RUN.
API 34 fails a source-selection action during the expanded refusal profile.
No earlier or later passing checkpoint is transferred to those failed jobs.
The first 231/84007 byte scaled consumer still fails on both APIs with the
old backend. Its reusable compiler repair remains independently qualified
before being pinned into IB. Physical TAB_P10 remains BLOCKED / NOT_RUN.
