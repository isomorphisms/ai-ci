# Shader codegen regression receipts

This directory records compiler-output facts that sit between source semantics and device performance.

The motivating regression is the Analytic Continuation factor fold. The typed program has room for 32 zeros and 32 poles. The old flattened shader evaluated each slot's `atan` and `log` before selecting whether the slot was active. With one zero and one pole that meant almost all expensive factor work was useless, and the compiler-generated APK took more than a second to react to touch on the physical Mali-G57 tablet.

The repaired generic and Mali backends recover real control flow around inactive factor work. Both repaired lowp and repaired highp APKs respond essentially immediately on that tablet. This makes the structural control-flow repair the important result; changing precision alone is not accepted as a structural fix.

## What the receipt tracks

`verify_receipt.py` keeps these claims distinct:

- exact producer and backend revisions;
- workload identity;
- requested GLSL precision class;
- inactive-factor code shape;
- logical factor capacity and expensive work per factor;
- how much inactive expensive work remains eager;
- static `atan`/`log`, real `if`, and ternary counts as reviewable code-shape observations;
- typed IR generation and shader generation/validation;
- driver load, GPU execution, framebuffer capture, vendor-device evidence, and interactive-response evidence as separate stages.

The Analytic Continuation workload currently accepts either `GUARDED_EXPANDED` or a future `BOUNDED_LOOP` shape. It rejects `EAGER`. That is deliberate: the current repair is good enough to run interactively, while a later compact bounded loop should be able to improve code shape without fighting a test that canonizes 64 statically expanded branches.

Precision is orthogonal to the structural gate. `lowp`, `mediump`, and `highp` are explicit emission choices. A lowp shader with eager inactive transcendental work still fails; a highp shader with the correct structure can pass the structural receipt. Application policy may prefer lowp separately.

## Evidence boundary

Compilation is not execution. Hardware stages must be reported separately and cannot be inferred from GLSL validation or program link. A physical-device performance observation that has not been imported into a repository receipt remains a documented external observation, not a fabricated CI pass.

## Run

```sh
python shader-codegen/verify_receipt.py self-test
python shader-codegen/verify_receipt.py verify shader-codegen/receipt-v1.example.tsv
```

The self-test includes deliberately bad fixtures for the old eager lowering, a fake precision-only 'fix', a guarded path that regresses to eager selects, a fake vendor-device receipt, and a `SKIP` with no reason.
