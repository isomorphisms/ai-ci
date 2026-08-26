# Idris compiler-backend observations

This directory contains small deterministic probes for comparing the active
Idris-family compiler backends. The probes are observations, not release gates.

The current matrix watches:

- `isomorphisms/idric-arm-thumb` on `idric-ir-first-slice`, because the active
  backend implementation is still on PR #1 rather than `main`;
- `isomorphisms/idris-arm-backend` on `main`;
- `isomorphisms/idris-shader-backend` on `soap-f16-mode`, the stacked PR #11
  branch with executable whole-shader F16/F32 selection;
- `isomorphisms/algebraic-variety-explorer-mobile` on
  `dogfood/idris-shader-f16`, as an independent downstream consumer of that
  shader mode.

Each row in `probes.tsv` asks the same kind of discrete question of each
backend: is a particular arithmetic operation, control-flow form, memory form,
typed vector form, or target-verification check represented in the checked-in
implementation?

`fp16_probes.tsv` separates several precision milestones that must not be
collapsed into one claim. It now observes the selectable whole-shader compiler
mode and its checked-IR/GLSL regression test while continuing to report the
still-open mixed-width IR, explicit conversion, source-level F16, and real
PowerVR framebuffer milestones independently.

`fp16_consumers.tsv` observes the Algebraic Variety Explorer dogfood gate. That
consumer pins an exact shader-backend revision and compiles the bounded Surfer
root-search path as both F16 and F32, validates the generated GLSL, and rejects
F64. Those rows prove that the downstream test surface exists; the consumer's
own CI run is the stronger compile evidence.

`probe.py` reads exact UTF-8 source files and exact literal needles and emits a
stable TSV. It performs no language-model inference and no fuzzy matching.

## Non-gating contract

A supported feature produces `present=1`; an absent feature produces
`present=0`. Both are successful observations. If a probed file is moved or
removed, the row becomes `readable=0,present=0`; that is also data rather than a
claim that the backend is broken.

The observer fails only when its own matrix or checkout mapping is malformed,
or when an explicitly promoted FP16 baseline fact regresses. Its unit tests
verify present, absent, missing-file, sorting, and duplicate-row behavior.

Source probes remain weaker than compiling or executing the backend. A source
surface can advertise an operation and still be wrong, while a refactor can
move an operation and make a literal probe disappear without removing the
capability. The Algebraic Variety Explorer lane is useful because it adds a
separate downstream compiler check, but it still does not establish exact
binary16 arithmetic on generic GLES or real PowerVR framebuffer behavior.

The stronger numerical layer remains target execution: compare known F16/F32
cases, including cancellation and binary16 boundary behavior, against a CPU
reference and the actual device framebuffer.
