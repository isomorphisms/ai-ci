# Independent Holomorphic phase/log acceptance

## Purpose and types

This checker consumes mathematical case inputs and numerical observations from
the implementation under test. It never imports the application's evaluator.
It preserves the retained deterministic divisor examples and extends them with
multiplicity, removable points, logarithmic scale, and live z/3 normalization.

The mathematical input is a world point, five binary64 complex coefficients,
multisets of zero/pole world positions, time, and a camera. A camera selects
presentation only. Exact positional equality permits signed integer orders to
cancel before any logarithm, division, or argument is evaluated. The output is
circular phase, unreduced logarithmic modulus, signed singularity order, and
the reduced zero/pole multiplicities. Ordinary finite outputs require finite
phase and log modulus. Genuine singularities are classified separately.

`signed_order_at : Integer → Integer → List LatticeFactor → Integer` is the
smallest exact-cancellation slice attempted in Idriç. Its lattice coordinates
represent exact dyadic fixture locations after choosing a common scale.
The intended full reference additionally requires binary64 complex powers,
`hypot`, `atan2`, `log`, accurate summation, file IO, and process exit status.
The verifier is an IO action over ordinary TSV; the reference evaluator is pure.

## Idriç attempt and explicit fallback

`HolomorphicAcceptance.idric` uses the repository's existing documented Idriç
syntax. The current Ubuntu x86_64 container has no `idric`, `idris2`, or qualified
Idriç executable in the verified workspace, /opt, or /tmp. The actual invocation
`/usr/bin/env idric --check HolomorphicAcceptance.idric` fails because that
program is absent. The Idriç source has therefore NOT_RUN compiler acceptance.
No stock Idris, generated C, or RefC compiler substitutes for it.

The requested independent executable checker still matters. The fallback is
checked Ithon, not ordinary Python source: `HolomorphicAcceptance.pi` executes
only through the verified Ithon frontend. Its inherited binary64 math runtime
is explicit. This fallback is checker qualification, not producer, compiler,
GPU, emulator, APK, or physical-device acceptance.

The first missing capability is availability of the qualified Idriç compiler
bundle on this build host. The next acceptance is compiling and running this
exact cancellation slice with that bundle, followed by binary64-reference
facilities. The Ithon implementation can then be replaced without changing the
external TSV contract.

## Executed checker qualification

The checked Ithon frontend at revision
`d6e83969f82512e920fb17b44326cb54f31d015c` executed the complete self-test.
Analytic anchors, 31 binary64 reference observations, ten runnable faulty
evaluators, five provenance counterexamples, missing-readback rejection, and
the 34-row GPU-log parser's explicitly synthetic good/bad fixtures passed.
The frontend rejected list/generator comprehensions, tuple loop destructuring,
augmented assignment, implicit external-call types, and truth-valued conditional
expressions over lists during the first attempt. The final source uses typed
intermediate values and structural loops; it never bypasses the frontend.

The large-q/small-divisor case retains a known precision boundary: a binary32
raw phase/log channel can erase a small divisor increment when added to large
q. The checker does not hide that loss by accepting only period-reduced Wegert
colours or increasing the host tolerance. Actual generated-shader readbacks,
binary32 accuracy qualification, ICK host sampling, emulator execution and all
physical-device acceptance remain NOT_RUN.

The initial actual GPU classifier failed closed with
`GPU-NUMERICAL-POLICY-MISSING`. That implementation was deliberately incomplete.
The follow-up predeclared `gpu-policy.tsv` and its primary-source rationale
before observing any Holomorphic GPU output. Actual `gpu-audit` now jointly
requires circular phase, raw nonperiodic log modulus, exact structural semantics
and actual RGBA8 output from the same selected program. The binary64 2×10⁻¹²
budget remains host-only. The independent palette passed all six retained
shared-Wegert fixtures at their existing 2×10⁻⁵ budget.

The extended policy self-test executes three passing controls (unchanged,
phase plus 2π, and one RGB8 level) and nine targeted failures: phase outside the
predeclared budget, reversed phase, raw log shifted by a colour period, raw log
outside the source envelope, two RGB8 levels, missing produced marker, missing
colour output, changed uploaded multiplicity and a wrong singular endpoint.
Every observation in these tests is explicitly a synthetic checker fixture.
No GPU execution or physical acceptance follows from those passes.
