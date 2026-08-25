# Contract roadmap

## Three enforcement layers

1. **Deterministic contracts** inspect exact files, manifests, hashes, Git
   revisions, and finished artifacts. These are authoritative.
2. **Executable acceptance probes** install, launch, decode, rerun, or otherwise
   observe the promised user path. A source file or sidecar cannot report its
   own success.
3. **Grounded semantic review** handles judgments that cannot yet be reduced to
   mechanics. Its verdict must cite source passages or artifact regions;
   `uncertain` blocks a required gate, and it cannot override a deterministic
   failure.

## Next deterministic contracts

- `revision-stack`: bind results to the exact PR head and base graph;
- `artifact-freshness`: bind artifact hashes to source and toolchain hashes;
- `idempotent-generation`: run harvest/generation twice and compare the full
  output inventory, then remove an input and prove stale output disappears;
- `policy-strength`: prevent ordinary product changes from deleting contracts,
  loosening thresholds, replacing the ai-ci pin, or removing bad fixtures.

## Artifact probes

- `video-acceptance` first slice is implemented in `video/`: decode the final
  MP4; check declared duration, dimensions, frame rate, audio, codec, pixel
  format, and explicit change/hold regions from frames rather than a sidecar;
- `video-layout`: add safe-area and required-region checks only when the
  consumer supplies inspectable geometry or masks; do not infer text boxes with
  a brittle generic OCR threshold;
- `android-install-launch`: verify alignment and signature, install the APK on
  the declared Android level, launch the expected package, and detect an early
  crash;
- `narrative-audio`: compare canonical script/captions exactly and independently
  transcribe the generated audio rather than trusting a generation receipt.

## Semantic review cases

The case schema and initial incident-derived corpus now exist in
`contracts/evaluation-case-v0.contract.tsv` and
`evals/cases.tsv`. The next implementation step is a runner that
captures traces and artifacts, applies deterministic gates first, and emits
criterion-level `pass`, `fail`, or `uncertain` verdicts bound to the exact
worker and evaluator revisions.

- generic theta notes versus notes grounded in the named lecture, transcript,
  examples, questions, and timestamps;
- Byrne motion with and without the perpendiculars that explain the invariant;
- an unavailable prior thread, paired with an answerable twin, to require
  `missing_evidence` instead of a plausible invented reconstruction;
- judge-order swaps and concise-correct versus verbose-wrong twins.

Every new contract must add a good fixture and at least one deliberately broken
fixture with the exact expected diagnostic. A contract without a demonstrated
failure mode is not eligible to become required.
