# PR #45 archive: Wegert Edric-to-GLSL host diagnostics

This directory preserves the useful implementation and context from ai-ci PR #45,
“Add staged Wegert Edric-to-GLSL host diagnostics”, after that draft became stale.

Historical source:
- ai-ci PR #45: https://github.com/isomorphisms/ai-ci/pull/45
- Wegert PR #29: https://github.com/isomorphismes/wegert/pull/29
- Wegert: https://github.com/isomorphismes/wegert
- Idriç / Edric source: https://github.com/isomorphisms/Idric
- GLSL shader backend: https://github.com/isomorphisms/idris-shader-backend
- Float16 shader-policy issue: https://github.com/isomorphisms/idris-shader-backend/issues/19
- PowerVR receipt issue: https://github.com/isomorphisms/idris-shader-backend/issues/28

## What this code was for

The old experiment split the hosted Wegert compiler path into explicit stages
instead of reporting one vague build result:

1. host setup;
2. handwritten Wegert GLSL baseline;
3. ordinary x86_64 C fallback;
4. Edric bootstrap;
5. Edric compiler API installation;
6. idris-shader-backend build against that Edric;
7. real 64-zero/64-pole Wegert source compiled as ordinary .idr;
8. validation/link of that generated GLSL;
9. the same family compiled through an actual .idric entry;
10. validation/link of the .idric-generated GLSL.

The important dependency rule was that a failed prerequisite makes dependent later
stages SKIP rather than manufacturing a cascade of independent FAIL results.
Independent earlier evidence remains usable.

The experiment also kept these boundaries separate:

- ordinary .idr control versus actual .idric source;
- compiler/API hookup versus shader source/signature precision policy;
- hosted GLSL validation versus Android/GPU/device execution;
- ICK's AArch64 CPU-side complex path versus the hosted Edric-to-GLSL path.

One observed state reached the shader source/signature boundary after the compiler
and backend hookup had already passed: Float16 source met inherited Double-oriented
shader API assumptions. The historical diagnostic name was
SOURCE_FLOAT_PROFILE_BLOCKS_SHADER_API.

## Why this is archived instead of merged

PR #45 was built on an old ai-ci architecture and fell hundreds of commits behind
main. Current ai-ci has the generic compatibility-receipt machinery under compat/
and src/aici_compat.c. That system now owns exact immutable tuples, evidence
witnesses, diagnostic codes, and compatibility verification.

These files are reference material, not active policy. Future Wegert integration
should express the useful stage/failure semantics using the current generic
compatibility machinery rather than reviving this Python verifier or replaying the
old branch.

## Contents

- original-readme.md: contemporaneous explanation from PR #45.
- check_wegert_host_receipt.py: old staged receipt verifier.
- wegert-edric-glsles-host-v1.tsv: ordered stage vocabulary.
- wegert-edric-glsles-classifications-v1.tsv: failure classifications and ownership boundaries.
- wegert-edric-glsles-observations-v1.tsv: historical observation with exact revisions.
- tests/: passing, prerequisite-failure, and invalid-dependent-stage fixtures.

Nothing here is evidence that current Wegert, current Idriç, or current
idris-shader-backend passes the old tuple. It records what the experiment meant
and preserves code that may help define the replacement receipt.
