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
