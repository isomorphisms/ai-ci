# Idris compiler-backend observations

This directory contains small deterministic probes for comparing the active
Idris-family compiler backends. The probes are observations, not release gates.

The current matrix watches:

- `isomorphisms/idric-arm-thumb` on `idric-ir-first-slice`, because the active
  backend implementation is still on PR #1 rather than `main`;
- `isomorphisms/idris-arm-backend` on `main`;
- `isomorphisms/idris-shader-backend` on `main`.

Each row in `probes.tsv` asks the same kind of discrete question of each
backend: is a particular arithmetic operation, control-flow form, memory form,
typed vector form, or target-verification check represented in the checked-in
implementation?

`probe.py` reads exact UTF-8 source files and exact literal needles and emits a
stable TSV. It performs no language-model inference and no fuzzy matching.

## Non-gating contract

A supported feature produces `present=1`; an absent feature produces
`present=0`. Both are successful observations. If a probed file is moved or
removed, the row becomes `readable=0,present=0`; that is also data rather than a
claim that the backend is broken.

The observer fails only when its own matrix or checkout mapping is malformed.
Its unit tests verify present, absent, missing-file, sorting, and duplicate-row
behavior.

This is intentionally weaker than compiling or executing the backend. A source
surface can advertise an operation and still be wrong. Conversely a refactor
can move an operation and make a literal probe disappear without removing the
capability. Those events are exactly why the raw observation is kept separate
from later interpretation.

The next stronger layer should compile the same tiny semantic fixtures through
every backend for which that operation makes sense, and eventually compare
numeric behavior on actual target implementations.
