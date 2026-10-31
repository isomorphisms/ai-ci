# Independent checked-reader ART expectations

These observers call IB's actual compiled source exports. They do not generate
the candidate DEX, parse HTML for the candidate, or simulate a Binder/ICU
transaction. `fixture.html` is deliberately synthetic source; its observation
fields identify the same exact bytes. No network authenticity is claimed.

The source projection observer checks Unicode titles, semantic content order,
relative-link resolution, exact Prepaint wire and source-code-point ranges.
The selected paragraph separates the two declared reflow algorithms at width
10 code points: greedy chooses `[0,11), [11,15)`, while squared-raggedness
chooses `[0,8), [8,15)`. These are a named host metric, not physical pixels.

The same observer must reject a compiled candidate that ignores the algorithm
selector and another that bypasses the maintained admission gate. Explicit
negative inputs cover unequal digests/counts, unsupported charset, failed HTTP
status, incomplete acquisition and invalid UTF-8 observations. Successful
fixture execution does not qualify Android UI, durable storage, actual network
acquisition, Binder/Shizuku, SEARCH dispatch or physical TAB_P10.

The separate title and Intent observers originate in merged android-NDK's
managed-export qualification at 6ab4818219efa7ea5eda137ca6b76976eb2a4d42.
Their move here preserves their role as independent observers; no application
implementation is copied.

The numeric observer has separately fixed expectations for dynamic checked
Text-to-Integer casts: signed decimal and arbitrary precision, finite decimal
truncation, exact ratios, malformed text returning zero, and signed/unsigned
byte wrapping. The `1e100` expectation retains the exact binary floating value
used by the pinned frontend, so converting a rounded printable Double to an
integer fails. Complex, precision-suffix and nonfinite forms are explicitly
outside the repaired DEX slice and must raise its declared refusal. A compiled
source mutant returning zero must fail this observer. The Chez reference in
the backend attempt is separate host evidence; only ART qualifies these DEX
calls.

The replay workflow names one retained candidate checkpoint, IB
`513d72cb43d3097a61f6fcb821b6e4215def960f`. It verifies the official artifact
digest, compares the carried source with that exact committed source, checks
every candidate DEX digest and rejects a changed-archive control before ART.
It does not claim to compile or qualify a later IB head. The earlier 9b97c4a2
checkpoint passed title/search but its numeric process exited 137 (`Killed`).
The later retained logcat proves ART `VerifyError` at an erased numeric helper
result, followed by Android's SIGKILL handler. Backend 0f9b6e1 repairs that
checked boundary; the new checkpoint passes both API 29/API 34 at the producer
run. Independent replay still binds its own observer and declared target API.

`NativeReferenceFieldsObserver.smali` is a separate reflection oracle for the
native Binder wire prerequisite. It checks public/private instance references,
per-instance Binder identity, null initialization and separate static storage.
`observe-native-fields.grease` must reject a valid compiled field-kind mutant
with the exact ownership assertion and status 73; a verifier crash cannot count
as that rejection. Neither this class-shape test nor its host decoder proves
Shizuku authorization or an actual transaction.
