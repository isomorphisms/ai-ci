# Checked export alias observer qualification

The independent observer calls pure/partial exports and checks literal Unicode
results. It creates a real SDK AtomicInteger, invokes the checked IO alias with
35 and then -7, and expects values 42 and 35. A separately compiled producer
that adds 1 instead must fail the first exact-effect assertion.

The initial source at 3d53775f60ba3672d67ae903a510bfdaa0fd54dc assembled but
Android-NDK run 41273908319 failed its positive observer on both API 29 and 34:
the process exited 137 with only `Killed`, without a success or assertion marker.
That run is failed; a killed positive is never accepted as mutation rejection.
The earlier runtime/JNI/native-field/Text-order phases completed their checks.
The observer did not retain AndroidRuntime errors on the unexpected status.

Static independent decode exposes an observer register error: its failure path
replaced the AtomicInteger handle with a String, then joined the path that uses
that handle in a second typed call. A void failure helper cannot establish
nonreturning control flow for the ART verifier. A separate diagnostic register
now preserves the counter type on every edge. Unexpected status or missing
exact marker also captures AndroidRuntime errors before the emulator exits.
This diagnosis is an inference from the decoded observer until fresh execution.

No candidate DEX, public ABI, compiler semantics or expected counter result is
changed by the observer repair. New API 29/34 execution, including intended
compiled-mutant rejection, remains required before qualification.
