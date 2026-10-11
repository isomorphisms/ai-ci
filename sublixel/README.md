# Independent Sublixel numerical and owned-toolchain acceptance

AICI tests the **actual** 3×3/5×5 C implementation in `isomorphisms/rough.framebuffer` against its own rational-integer midpoint oracle. The producer's numerical test arrays and product build scripts are **not** used.

Current immutable acceptance target: rough.framebuffer policy-stack `49592bf113d6d6294fbce1224b83501896594a5d` ([PR #10](https://github.com/isomorphisms/rough.framebuffer/pull/10)), which includes 3×3 PR #6 and 5×5 PR #8. The source checkout must match that exact revision. Updating the target requires a new review/run, not silently following a branch.

## Independent geometry oracle

`verify.c` enumerates **every 8×8 midpoint** from a rational analytic parabola and cubic curve, including fractional translated origins, comparing exact counts in all 3×3 and 5×5 cells and each public single-pixel query. Curvature coefficients, nonlinear reparameterization (including reversal), negative curvature/cubic contributions, flat split segments, duplicate OR-mask occupancy, singular/nonfinite input and transactional errors are tested.

Two mutant builds change **real implementation source** while leaving the independent oracle untouched. One negates 3×3 quadratic graph evaluation; the second reverses the 5×5 cubic term. Each mutant is compiled by the same ICK, linked with the same real unmodified other source, and **must** exit nonzero with its specific numerical-oracle rejection. Compilation failures do not count as mutant rejection.

## Build and receipt integrity

The [source-built ICK](https://github.com/dilapidated-shed/ick) compiler is pinned to `c61e448251744a2f40ad743ebef1a027bdcd2f9d`; its retained GCC reference submodule is pinned to `6294f1d9e7536e5ffcde09d1528c918d63abfef5`. Only its authenticated staged x86_64 compiler and `cc1` compile **both producer curve sources, AICI's independent oracle, AICI's receipt checker, and both mutants**.

The acceptance orchestrator is [Ike](https://github.com/dilapidated-shed/ike) at `a92fe68bf8aad8dfcfe9f7a7abd84e07290f7fe0`, built by ICK. AICI uses its own literal `sublixel/Ikefile` to run the oracle and demands `ike-build-v1` with exact target, source digest, rule, recipe, runner, status and no trailing bytes. The receipt checker is **also compiled by ICK**. Two mutated receipts (wrong target and false final result) must be rejected, not passed along by simply testing for the word `PASS`.

The ICK stage-zero build still explicitly uses GNU Make and host GCC/G++ to construct the GCC-derived compiler. The final system link driver consumes **only ICK-produced object files**, supplying CRT/libc/libm. These are not consumer source compilation alternatives or claims of self-hosted ICK. The CI workflow does not run any producer-owned Makefile, native test program or consumer CC fallback.

## Acceptance boundary

This independent mathematical check is narrower than full ai-ci product promotion. It does **not** verify complete live Flexible Pipes dispatch/delivery, Android A1/C67 ABI/runtime, actual framebuffer consumer integration or triangle-edge antialiasing. The producer branch is still draft and must not be merged solely on the strength of this acceptance candidate. Host green is not a physical C67 observation.

Tracker: [ai-ci #253](https://github.com/isomorphisms/ai-ci/issues/253); related FP #75, #77, #78 and #79.
