# Complex/projective implementation hierarchy

This policy is deliberately narrow.

Thumb-2 remains the human-in-the-loop leader for **general** Idriç backend development.

Complex and projective arithmetic are an explicit current exception. For this subsystem:

```text
mathematical semantics
    -> x86-64 CPU leading executable implementation and CPU oracle
    -> shared numerical/projective corpus
    -> Thumb-2, GPU/shader, application, and other followers
```

The current Thumb-2 complex/projective implementation is provisional and may later be replaced. A later Thumb rewrite is not a semantic break if it continues to satisfy the shared mathematical contract.

The x86-64 implementation may lead engineering choices for this subsystem. It may not redefine `Complex`, C^n, CP^n, floating precision, projective equality, or holomorphicity according to convenient register layouts.

## Evidence roles

Receipts use one of these roles:

- `X86_LEADER` — executable CPU reference;
- `THUMB_FOLLOWER` — provisional ARM follower;
- `SHADER_FOLLOWER` — shader/GPU follower;
- `APPLICATION_CONSUMER` — application-level consumer such as analytic-continuation.

Every receipt records a source head SHA and the exact tested checkout SHA. A pull-request merge SHA is useful evidence, but it does not replace the source-head SHA.

Every stage is one of `PASS`, `SKIP`, or `FAIL`. `SKIP` must carry a reason. A later `PASS` never erases an earlier `FAIL` in the same receipt.

## Required x86 leader evidence

An `X86_LEADER` receipt must prove all of these:

- direct backend generation/build;
- native x86-64 execution;
- numerical complex corpus;
- projective-equivalence/non-equivalence corpus;
- thin-Debian execution;
- deterministic headless mathematical render.

Those stages may not be `SKIP` in a leader receipt.

The candidate must remain a direct backend path where the backend repository requires one; C, RefC, LLVM, an external assembler, or another host compiler may not be smuggled in as the implementation.

## Thumb follower evidence

A `THUMB_FOLLOWER` receipt must explicitly say the implementation is `PROVISIONAL_DISPOSABLE` until the user replaces or promotes it.

Executable QEMU evidence may be `PASS` when actually demonstrated. QEMU is not a physical-device receipt. Unsupported shared numerical/projective/render stages may be `SKIP` with reasons.

The temporary polar representation, register assignments, helper conventions, and ABI are not architecture for the other implementations.

## Shader/GPU follower evidence

The following stages are distinct and must not be collapsed:

```text
typed IR generated
shader source generated
shader compiled/validated
program linked
shader loaded by a driver
shader executed
framebuffer captured
specific vendor/device receipt
```

Compile/link evidence may be `PASS` while all hardware stages remain `SKIP`. No receipt may infer GPU execution merely from shader compilation.

Declared precision belongs in the receipt. GLSL precision class is an emission/application choice, not the mathematical definition of the value. An application may deliberately request `lowp`, `mediump`, or `highp`; a backend must not silently substitute a different class and must not claim that changing precision repaired an unrelated structural/codegen defect.

## Application consumers

Applications may consume only the pieces they genuinely need. A finite complex-plane viewport does not have to manufacture a runtime CP^1 object merely because the shared mathematics includes CP^1.

Application-specific interaction, rendering, JNI, touchscreen state, random-walk policy, and release machinery remain application concerns unless a genuinely reusable mathematical boundary is established.

For the current whole-plane explorer the preserved mathematical model is:

```text
f(z) = R(z) exp(q(z))
```

`R` carries the explicit finite divisor and `q` is entire. Conjugation, magnitude, phase, gauge choice, and coloring are observational/non-holomorphic and may not silently enter a state advertised as a holomorphic deformation.

## Receipt verifier

`verify_receipt.py` checks the common provenance/status grammar plus role-specific minimum evidence. Its self-test contains both accepting and rejecting fixtures, including:

- leader with a skipped projective stage;
- shader receipt falsely claiming vendor execution without the preceding load/execute/capture chain;
- Thumb receipt missing the provisional/disposable marker;
- `SKIP` without a reason;
- missing source-head provenance.

The verifier is intentionally about evidence claims, not numerical correctness itself. The numerical/projective oracles remain in the implementation repositories.
