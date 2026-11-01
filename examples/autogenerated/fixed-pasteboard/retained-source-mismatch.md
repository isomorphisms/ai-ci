# Retained stage revision mismatch

The Fixed Pasteboard integration initially treated the utilities workflow's
retained compiler stage as source-identical to the current ICK pin. That was
wrong. ai-ci action `4ea071a96239f3a29ca6d98454feb59947d87cfe` builds ICK
`c61e448251744a2f40ad743ebef1a027bdcd2f9d`; the current ai-ci producer expects
`fbe86e23d55cfec2000c08e61deea2a407fd7175`. The frontend version string and
target triple do not distinguish that semantic change.

Utilities run `41323674382`, exact source
`bf7afcc4f7f31e7cde89ec960836929a69e7e174`, re-executed the complete current
qualification against the old retained binary. ARM compile/link passed, while
x86_64 actual complex extraction failed at O0: the old binary returned physical
radius/angle for extraction-only functions, while the assertion correctly
required Cartesian components. The gate remained failed; it was not weakened or
relabeled as an application failure. No completed candidate came from that run.

The consumer now selects newly produced exact-source stages from ai-ci run
`41322683283`, source `edb615dcca30863b19a61318f6d365c25cc2ebdf`, whose three
ABI qualification jobs pass. Every restore also checks the stage's declared
source receipt against the producer's requested revision before use. Current
qualification still executes after restore. This receipt check prevents the
observed accidental substitution; it is not a cryptographic proof against a
maliciously forged producer receipt.

The host frontend cache is also invalidated: its earlier key named the newer
ICK pin while its action selected the older one. Current builds use the newer
pinned host producer and a new key. Keep historical old-stage successes scoped
to that old compiler. Do not promote them as current producer evidence.
