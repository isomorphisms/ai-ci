# ai-ci

`ai-ci` is a shared contract test suite for AI-authored project work.

Its rule is stricter than ordinary green CI:

> A check must demonstrate the promised result, and it must prove that it
> rejects a deliberately broken example of the same result.

The initial kernel is a small native C verifier. It has no package-manager
bootstrap and does not treat file existence alone as acceptance. A consumer pins
this repository by full commit SHA, supplies a tab-separated contract, and
runs the verifier against the finished repository or artifact tree.

## What the deterministic kernel checks

- narrative synchronization: canonical script text, voiceover input text, and
  caption text remain byte-identical;
- asset provenance manifest schema and nonempty required attribution fields;
- workflow integrity: rejection of `continue-on-error`, shell `||`, and
  `set +e`; full-SHA action pins; and event-scoped coverage of critical paths;
- language boundaries, including detecting shell files mislabeled as Grease.
- evaluation-case manifests with explicit objectives, oracles, evidence,
  provenance, variants, holdout splits, trial counts, and blocking status.

Every required assertion has a good contract fixture and a targeted known-bad
fixture in `tests/cases.tsv`. The self-test audits that coverage mechanically;
adding an assertion without a unique diagnostic and matching bad fixture makes
CI fail.

## Finished-video acceptance

The optional `video/` action tests the encoded artifact, not a renderer's source
or a metadata sidecar. It uses FFmpeg to prove that the whole file decodes and
FFprobe to check declared dimensions, duration, frame rate, audio policy, codec,
and pixel format. A contract can also compare two decoded frames inside an
explicit rectangle using mean absolute RGB error. That supports narrow claims
such as “this plot changes during the build” and “this region holds at the end”
without making either behavior a universal style rule.

Its self-test generates real MP4 files at runtime. There is one targeted bad
video for every diagnostic, and CI requires each bad video to fail first at the
intended assertion. See [`video/README.md`](video/README.md) for the contract
format and [`docs/shorts-render-observations.md`](docs/shorts-render-observations.md)
for the incident analysis that determined this boundary.

## Run locally

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici src/aici.c
/tmp/aici self-test tests/cases.tsv
/tmp/aici suite tests/good-suite.tsv .

cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-video src/aici_video.c -lm
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-video-fixtures video/tests/make_video_fixtures.c
/tmp/aici-video-fixtures /tmp/aici-video-test-data
/tmp/aici-video self-test video/tests/cases.tsv /tmp/aici-video-test-data
```

Those are direct compiler and verifier invocations, not a Bash- or
Python-authored command layer.

## Use from another repository

After checking out the consumer repository, use the action at a full commit
SHA:

```yaml
- uses: isomorphisms/ai-ci@0123456789abcdef0123456789abcdef01234567
  with:
    suite: config/ai-ci.suite.tsv
    root: .
```

Do not copy the placeholder SHA. Pin the exact reviewed commit.

For a finished video:

```yaml
- uses: isomorphisms/ai-ci/video@0123456789abcdef0123456789abcdef01234567
  with:
    contract: ci/short.contract.tsv
    root: media
```

The runner must provide `ffmpeg`, `ffprobe`, and a C17 compiler. The example
contract is intentionally fixture-sized; consumers should copy its operations
and set project-specific dimensions, timing, audio, and frame regions.

## Limits

The deterministic checks cannot decide whether an explanation is
mathematically insightful or whether an obscure remembered source is the
intended one. The video probe cannot infer whether a changed region changed for
the right semantic reason, and the Grease contract proves declared invocation
rather than a working Grease runtime. The roadmap adds source packets,
artifact freshness, executable renderer probes, and grounded semantic review
without allowing those softer checks to override a deterministic failure.

## Trust boundary

Contracts and suites are executable policy, not a sandbox. Keep required policy
in a trusted, reviewed location. Do not run PR-controlled contracts in a
`pull_request_target` or other secret-bearing job. Path checks reject literal
`..` segments and matching final-component symlinks, but do not claim complete
filesystem confinement through a symlinked root.

The v0 Action requires a POSIX runner with a C17 `cc`; CI currently exercises
Ubuntu 24.04. Native Windows runners are not yet supported.

See `docs/evaluation-protocol.md` for the normative evaluation method,
`research/llm-failure-modes.md` for the empirical basis, and
`docs/failure-ledger.md` for the reconstructed incident classes. The next
contracts are in `docs/roadmap.md`.
