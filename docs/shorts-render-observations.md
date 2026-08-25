# YouTube Shorts render failures: gateable observations

This note records an artifact-level review of the `isomorphisms/yt-shorts`
branches available on 2026-08-25. The purpose is not to score the videos. It is
to separate failures with stable executable oracles from judgments that would
become noisy generic gates.

## Findings

### Green repository checks are not video acceptance

The first `ai-ci` consumer branch (`aici-first-yt-consumer`, head
`3acb9de`) checks workflow integrity, project-language declarations, narrative
file synchronization, provenance fields, and evaluation-case schema. Those are
useful repository contracts, but none opens or decodes a video. A green result
there cannot establish that an MP4 exists, finishes decoding, has the promised
shape or duration, contains the intended audio policy, or reaches a stable
display state.

This is directly gateable. `aici-video` now tests the encoded artifact for
decode, dimensions, duration, frame rate, audio, encoding, and declared pixel
change/hold behavior.

### Requirement drift is observable at the artifact boundary

The Teleman/Wegert branch (`teleman-wegert-k-loop`, head `12c207c`) describes a
7-second clip in its README. Its renderer declares a 6-second hold plus an
8-second zoom, for a 14-second total, while the animation period for `k` is 7
seconds. The finished square artifact is therefore 14 seconds and shows two
trips of `k`, not the documented single 7-second trip. Existing green workflow
checks do not detect that mismatch.

Exact duration, dimensions, frame rate, and audio policy are low-noise gates
when the project declares them once in a reviewed contract. “One trip” is also
testable, but only with an episode-specific state oracle; a generic pixel-change
test cannot count mathematical winding correctly.

### Timeline probes work when tied to named visual witnesses

The Pearcey branch (`pearcey-wegert-t-build`, head `c1c1066`) contains the
strongest existing artifact validator. It checks both committed video sizes,
duration and frame rate; confirms that the field and cutoff indicator change
during the build; confirms that they stop changing during the hold; compares
the displayed field with a source render at the same time; and checks that a
label precedes its curve overlay. Those checks correspond to real prior bugs,
including a review copy whose 15-fps clock advanced against 30-fps source
frames.

The reusable part is not “motion is good.” It is the narrower contract that a
specified region must differ between two declared build times or remain within
a compression-tolerant bound between two declared hold times. That is the
reason `video_frame_mae` requires times, rectangle, minimum, and maximum rather
than applying a universal motion threshold.

### A precise oracle can still prove the wrong mathematical claim

The Pearcey validator compares its incremental float32 field at cutoff `T=3`
with a high-resolution quadrature of the same finite-cutoff integral. This is a
good discretization check. It does not test whether the finite-cutoff display is
an accurate approximation of the infinite Pearcey integral shown in the
definition.

At `x=y=0`, the infinite target has the closed form

`P(0,0) = (1/2) Gamma(1/4) exp(i pi/8)`.

The `[-3,3]` cutoff differs from that target by approximately `0.01852`, or
`1.02%` in relative magnitude, even though the validator reports roughly
`1e-4` agreement with its finite-cutoff reference. That does not by itself make
the animation visually wrong. It proves that test names and thresholds must
state which quantity they certify: numerical discretization at fixed cutoff,
truncation error to the mathematical limit, or merely a visual build metaphor.

This is not a safe generic video gate. It belongs in the episode's mathematical
oracle, with analytically known points or an independently justified error
bound.

### A good old render does not validate rewritten production source

The Byrne III.31 branch (`sources/oliver-byrne`, head `b9cafbd`) explicitly says
that the successful visual test predates its Ithon/Grease source-language
cleanup and does not validate the current entry point. That is the correct
diagnosis: inspecting the old video can prove the visual idea, while compiling
or linting the new source can prove some source properties, but neither proves
that the current source reproduces the accepted artifact.

The missing gate is source-to-artifact freshness: execute the declared render
entry point, then bind the resulting artifact to the source revision and
toolchain. That remains on the deterministic roadmap rather than being faked by
timestamps or the presence of an MP4.

### The best storyboard shape is one event with explicit witnesses

The theta/Mellin branch (`theta-mellin-short`, head `191dd99`) is a useful model
for future episode contracts: a fixed reference curve, a moving transformed
copy, explicit width and area witnesses, an exact `n=3` freeze, then one
algebraic generalization. The README deliberately excludes adjacent lecture
topics. This makes acceptance questions concrete: did the reference stay
fixed, did the copy compress, did the width and area comparisons reach `1/9`,
and did the freeze precede the substitution?

Those are potentially excellent episode-specific tests. They should use known
render state, inspectable geometry, or tightly scoped image regions. The
current generic suite only supplies the decoded-frame primitive; it does not
claim to infer those semantics from arbitrary pixels.

## Enforcement boundary

| Claim | Generic required gate now? | Reason |
| --- | --- | --- |
| Final file decodes completely | Yes | Directly observed by FFmpeg. |
| Shape, duration, FPS, audio, codec, pixel format | Yes, when explicitly declared | Stable metadata with exact or bounded expectations. |
| Named region changes or holds between named times | Yes, when explicitly declared | Direct decoded-pixel evidence with contract-owned thresholds. |
| Current source produced the accepted artifact | Not yet | Needs render execution plus source/toolchain binding. |
| Text is legible and inside safe areas | Not generically | OCR and saliency heuristics are noisy; prefer supplied geometry or masks. |
| The right mathematical object changed | Episode-specific | Pixel motion alone cannot identify semantic state. |
| The explanation is insightful or well paced | No | Requires grounded human or semantic review, not a deterministic pretense. |

The operating rule is: promote an observation to a required test only when its
pass condition is inspectable, its threshold is owned by the consumer, and a
targeted bad artifact demonstrates the exact diagnostic. Everything else stays
visible as a review requirement until it has a better oracle.
