# Independent framebuffer mathematical-art acceptance

This verifier is owned by `ai-ci`, not by the
[`rough.framebuffer`](https://github.com/isomorphisms/rough.framebuffer)
candidate's test suite. Its source is `framebuffer/verify_surfaces.c` and its
exact-input hosted runner is `.github/workflows/framebuffer-math-art.yml`.

## Claim and evidence classes

For the pinned source revision, independently compile and execute the native
surface producer and the actual candidate framebuffer renderer. Verify:

- strict P/T operation grammar, finite triangle coordinates, depth range and
  nonconstant depth; the expected triangle count for the pinned torus mesh;
- an analytic torus projection witness from the mathematical parameterization,
  independent of the producer's sampling and projection functions;
- periodic color continuity across both torus seams;
- independently sampled near-plane clipping and nonempty Enneper geometry;
- a native depth-buffer oracle that rejects occlusion reversal, winding reversal,
  and transparent occlusion;
- byte-for-byte equality between the actual PPM screenshots and a separate
  renderer invocation fed the source operation stream;
- nonblank RGB output and a minimum number of changed visible pixels between
  the two rotation angles.

The hosted runner builds six **deliberately incorrect** variants or artifact
configurations and verifies that each fails at the intended assertion:
nonperiodic palette, flipped projection x, inverted depth comparison,
unchanged-angle operation stream, missing near-plane clipping evidence, and a
forged screenshot from the wrong angle.

The source SHA in the workflow is deliberately immutable. Updating the
producer requires explicitly updating the pin and rerunning the entire
acceptance/mutation set; a green result for an ancestor must never be used
as acceptance of a newer framebuffer head.

## Limits

This is an independent **verification implementation and execution path**,
not an independent human author. Cross-model correlated reasoning mistakes
remain possible. A CPU host/PPM outcome does not imply a GPU/Android/PowerVR,
APKs, gestures or physical device outcome. It also does not fulfill Flexible
Pipes' registered dispatch or merge-authorization requirements.

Tracked by [ai-ci #246](https://github.com/isomorphisms/ai-ci/issues/246)
and [Flexible Pipes #70](https://github.com/isomorphisms/flexible-pipes/issues/70).

## Current owned compiler and source integration

The October 21 correction uses current ICK/Ike-integrated framebuffer
source and no longer compiles *any* consumer/verifier C with stock host
`cc`. The workflow constructs the exact source-built ICK frontend from
its pinned reference and uses `framebuffer/build-ick.sh` for all normal
and mutated source C. A system driver links checked ICK-produced objects
only (an explicitly declared stage-zero exception); compiler/source
identity and ELF machine are checked. The independent six-mutant semantic
oracle is unchanged.

A hosted run on this refreshed draft remains necessary; a prior green
result at the old framebuffer head is not current-head acceptance.

## Consolidated rendering-stack qualification

`verify_stack.c` extends this existing C-ABI verifier family. It does not use
the producer's tests or expected arrays. `qualify-stack.grease` materializes
each immutable candidate from Git and compiles both implementation and oracle
with the authenticated owned ICK frontend. Pinned Ike runs the Grease recipe
in `framebuffer/Ikefile`; the existing independent receipt checker validates
its actual target, recipe, identity and result.

The host witnesses cover front-hemisphere drag direction, pointer ownership,
cancellation, bounded zoom, shape changes, direct versus serialized pixels,
rational RGBA interpolation, four-sample color/depth resolution, actual oblique
3×3/5×5 diagnostic pixels, analytic normal orientation, projective material
interpolation and per-fragment lighting. The mask slice checks all 64 bit
positions and their four Boolean input states, 4,096 varied clipped/padded
plane combinations, unchanged sources/padding, extreme integer origins,
alias rejection, overflow and transactional failures. Expected mask words are
assembled from independent per-bit truth decisions.

All candidate/oracle C is instrumented with AddressSanitizer and
UndefinedBehaviorSanitizer. Fourteen changed-source executables must compile,
run and fail at named semantic witnesses: wrong drag, single-sample resolve,
empty quadratic panel, constant normal, and each wrong mask operation.
A compilation failure is not a successful mutant rejection. Leak detection
alone is disabled for the inherited instrumented Grease runtime's restricted
host environment; address and undefined-behavior instrumentation remain active.

The exact per-PR revisions live in the checked Grease recipe. The workflow
retains observed source/material digests, logs and the Ike receipt. This
qualifies host library/source behavior; NDK compilation, APK identity and
physical A1/C67 lifecycle, image quality and performance remain separate.
