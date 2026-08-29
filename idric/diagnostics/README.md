# Idric integration diagnostics

This directory names diagnostic boundaries that are more useful than a single consumer build verdict.

## Wegert hosted Edric -> GLSL probe

Wegert PR `isomorphismes/wegert#29` is the first concrete consumer experiment for the previously open Wegert/Idric integration gap. It is deliberately **hosted x86_64 only**. It does not build Android, does not cross-compile for the phone, and does not claim GPU execution.

The stage registry is `wegert-edric-glsles-host-v1.tsv`; the failure vocabulary is `wegert-edric-glsles-classifications-v1.tsv`.

The intended chain is:

```text
existing Wegert GLSL baseline
        |
hosted x86_64 Wegert C fallback
        |
Edric bootstrap
        |
Edric compiler API install
        |
GLSL backend built with Edric
        |
64-zero/64-pole Wegert .idric compile
        |
generated GLSL validation + vertex link
```

A failed stage does not erase evidence from independent earlier stages. Dependent later stages should be marked `SKIP`, not incorrectly reported as separate failures. The producer should always retain one log per stage and the exact Wegert, Idric, and shader-backend revisions.

### Precision diagnosis

The shader backend currently has a distinction that must remain visible in diagnostics:

- emitted GLSL can be `highp` or `mediump` on the Mali-oriented branch;
- the source shader API still uses inherited `Double` spelling for scalar values;
- the no-wide-float Idric source profile may therefore reject a `.idric` shader before backend lowering even though the target GLSL arithmetic would have been `float`.

That state is `SOURCE_FLOAT_PROFILE_BLOCKS_SHADER_API`. Do not collapse it into `GLSLES_BACKEND_BUILD`: the compiler API/code-generator hookup may already be working.

### ICK is orthogonal

ICK is not a member of this hosted compatibility tuple. Wegert's ICK object is an isolated AArch64 CPU-side complex-math path. Hosted x86_64 Wegert uses its ordinary Cartesian C fallback instead. An ICK failure must not be allowed to turn an Edric-to-GLSL observation red, and a passing ICK object says nothing about the shader compiler path.

### Acceptance boundary

The hosted probe is diagnostic and non-fatal while the stack is moving. A future hard acceptance gate can require all stages to pass for one exact tuple. Even then, `HOST_EDRIC_GLSL_PATH_PASS` means only that source -> compiler -> GLSL validation succeeded; actual GPU execution requires a separate target receipt.
