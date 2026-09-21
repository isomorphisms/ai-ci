# ai-ci

`ai-ci` is a shared contract test suite for AI-authored project work.

Its rule is stricter than ordinary green CI:

> A check must demonstrate the promised result, and it must prove that it
> rejects a deliberately broken example of the same result.

The `sms/` receipt applies that rule across the moving Idric-Net and Grease SMS
branches. It compiles the real `Network.SMS` parser, drives the filesystem
service through that executable, and proves four hostile service mutations are
rejected. See [`sms/README.md`](sms/README.md).

The initial kernel is a small native C verifier. It has no package-manager
bootstrap and does not treat file existence alone as acceptance. A consumer pins
this repository by full commit SHA, supplies a tab-separated contract, and
runs the verifier against the finished repository or artifact tree.

## What the deterministic kernel checks

- narrative synchronization: canonical script text, voiceover input text, and
  caption text remain byte-identical;
- asset provenance manifest schema and nonempty required attribution fields;
- workflow integrity: rejection of `continue-on-error`, shell `||`, and
  `set +e`; full-SHA action pins; explicit PR-head checkout for primary source
  when exact-head evidence is required; and event-scoped coverage of critical paths;
- language boundaries, including detecting shell files mislabeled as Grease.
- evaluation-case manifests with explicit objectives, oracles, evidence,
  provenance, variants, holdout splits, trial counts, and blocking status.
- runtime evidence scoped to the exact process, job, service, or actor under
  test, with positive effects and fatal markers judged in that same scope.

Every required assertion has a good contract fixture and a targeted known-bad
fixture in `tests/cases.tsv`. The self-test audits that coverage mechanically;
adding an assertion without a unique diagnostic and matching bad fixture makes
CI fail.

## Pull-request merge verdicts

The `merge/` contract produces a fail-closed verdict from ten plain TSV files:
exact PR/topology state, checks, dependencies, evidence receipts, scope,
exact-artifact consumption, merge authority, blockers, scheduled-workflow
reality, and job completion. The authority receipt is bound to the repository,
PR number/title, exact head and base, prospective patch, changed paths, intent
record, and the human text or task context that established authority. The
receipt separately records the human actor, authority-source kind, stable source
identifier, and source role, so an acknowledgement cannot be relabeled as an
explicit merge instruction merely by changing `authorization_kind`. An
ambiguous acknowledgement may continue a task that already authorizes merging;
it cannot create merge authority when the surrounding task did not provide it.
Unresolved objections still fail closed.

The verdict prints exact-head checks as
`PASS|FAIL|CANCELLED|SKIPPED|ABSENT|STALE|UNKNOWN`. Receipts bind source and
build commits, artifact hashes, target/evidence class, provenance, and execution
result, so QEMU cannot satisfy a physical-phone requirement, a handwritten
oracle cannot satisfy compiler generation, and packaging cannot satisfy
execution. Receipt claims themselves use `PASS|FAIL|NOT_VERIFIED`; absence of
evidence is not a product failure.

Run `merge/pr-verdict.sh SNAPSHOT_DIRECTORY`; see
[`docs/merge-authorization.md`](docs/merge-authorization.md) for the schemas and
collection rules.

`merge/collect-verdict.sh OWNER/REPOSITORY PR POLICY_DIRECTORY OUTPUT_DIRECTORY`
is the repository-owned live path. It resolves the PR head, live base, merge
tree, prospective first-parent patch, changed paths, active ruleset contexts,
Actions runs/jobs, checkout witnesses, dependencies, scheduled runs, and
contextual-authority provenance before invoking the same deterministic
verifier. Repository policy supplies semantic scope, evidence requirements,
durable blockers, completion state, and Cockswain's authority receipt; the
collector does not infer them from GitHub or conversation text.

For the ordinary operational question before final authorization, run
`merge/state.sh SNAPSHOT_DIRECTORY`. Its six-file observation contract emits
either one `READY` row or a small table of typed blockers with concrete objects
and next actions. It preserves `NOT_VERIFIED`, classifies conflicts separately
from CI, distinguishes target-branch/upstream/transient failures, and keeps
informational followers from becoming merge gates. See
[`merge/state/README.md`](merge/state/README.md).

`merge/collect-github.sh` builds that smaller operational snapshot with four
bounded API reads.
`merge/collect-set.sh` evaluates a TSV population in one command and shares
live-base/baseline responses across PRs in the same sweep.

## Workflow trigger integrity

A semantic check is only protective when changes to the implementation it
asserts can actually trigger the workflow. The shared
`workflow-integrity-v0` contract already provides event-scoped
`yaml_paths` checking: consumers keep a repository-specific list of critical
paths and the contract rejects omitted, negative, commented, or misplaced path
entries. `yaml_primary_checkout_ref` also rejects the default synthetic
pull-request merge checkout when the contract requires the primary repository to
use the explicit PR-head expression. If the material dependency set is broad or difficult to maintain,
prefer an unfiltered `pull_request`/push trigger over a narrow filter that can
leave production changes untested.

The reusable parsing and diagnostics belong here in `ai-ci`; consumer
repositories should keep only their own critical-path lists, fixtures, expected
results, and workflow wiring.

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

## F-Droid release acceptance

The optional `fdroid/` action verifies commit-bound receipts from the actual
F-Droid release path. It pins source, fdroiddata, fdroidserver, and the
buildserver image; requires the current metadata, scanner, build, policy, APK,
and install witnesses; opens the finished APKs to check their ZIP and native ABI
contents; and compares two clean F-Droid rebuilds byte-for-byte. Upstream-signed
contracts additionally require F-Droid's signature-copy reproducibility result
and the expected signing key.

Candidate, submitted, and published profiles remain separate so a successful
local build, an open fdroiddata merge request, or a successful status query
cannot be mislabeled as store acceptance. See [`fdroid/README.md`](fdroid/README.md)
for the receipt schema, ABI-split rules, current official-check mapping, and the
manual-review boundary.

## Hostile-web ingestion acceptance

The optional `ingestion/` action owns a ten-case hostile-input corpus and a
machine-readable seven-stage receipt. It keeps input acquisition, network,
decompression, decoding, HTML recovery, document construction, and downstream
extraction separate; rejects a later success after the first real failure; and
requires `SKIP` to say why the stage did not run.

An implementation-under-test receipt must name its executable and exact source
revision, state `fallback=none`, and include an `execve` trace. The verifier
rejects traces that invoke the side-by-side curl/libxml2 oracle. See
[`ingestion/README.md`](ingestion/README.md) for the schema and current
`document_log_subset_v0` boundary.

## Idriç bounded orthogonal-core acceptance

The optional [`idric-orthogonal/`](idric-orthogonal/) gate pins one exact Idriç
revision and reruns the compiler-owned unified higher-mathematics receipt plus
its independent exact R128 oracle.  Its machine-readable output is explicitly
`BOUNDED_GREEN`: backend handoff, target execution, certified sphere action,
arbitrary transforms, and numerical algorithm choice do not silently inherit
`PASS` from the closed R128 sample.

## Merge authorization

The optional `merge/` action is the fail-closed authorization layer for routine
PR merges. It consumes snapshots of the live base/stack graph, observed checks,
dependency revisions, receipts, scope provenance, and exact-artifact consumer
trace. It rejects stale or synthetic-head evidence, skipped or missing checks,
check-name collisions, moving refs used as exact dependencies, evidence-class
promotion, inherited scope, and rebuild fallback. See
[`docs/merge-authorization.md`](docs/merge-authorization.md).

## Run locally

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici src/aici.c
/tmp/aici self-test tests/cases.tsv
/tmp/aici suite tests/good-suite.tsv .

cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-video src/aici_video.c -lm
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-video-fixtures video/tests/make_video_fixtures.c
/tmp/aici-video-fixtures /tmp/aici-video-test-data
/tmp/aici-video self-test video/tests/cases.tsv /tmp/aici-video-test-data

cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-fdroid src/aici_fdroid.c
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-fdroid-fixtures fdroid/tests/make_receipt_fixtures.c
/tmp/aici-fdroid-fixtures fdroid/contracts/native-upstream-v1.example.tsv /tmp/aici-fdroid-test-data
/tmp/aici-fdroid self-test /tmp/aici-fdroid-test-data/cases.tsv
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

For an F-Droid release receipt:

```yaml
- uses: isomorphisms/ai-ci/fdroid@0123456789abcdef0123456789abcdef01234567
  with:
    contract: ci/fdroid-release.contract.tsv
    receipt: out/fdroid/receipt.tsv
    root: out/fdroid
```

The runner must provide `sha256sum`, `unzip`, and a C17 compiler. The action
verifies evidence and finished APK bytes; the receipt-producing job must run the
pinned F-Droid tools, reject mutable build inputs, inspect Fastlane's
code-quality report, and preserve the independent logs. Its trusted caller must
also anchor the contract's source revision to the release ref or CI event.

## Limits

The deterministic checks cannot decide whether an explanation is
mathematically insightful or whether an obscure remembered source is the
intended one. The video probe cannot infer whether a changed region changed for
the right semantic reason, and the Grease contract proves declared invocation
rather than a working Grease runtime. The roadmap adds source packets,
artifact freshness, executable renderer probes, and grounded semantic review
without allowing those softer checks to override a deterministic failure.
The F-Droid verifier cannot infer copyright ownership, license compatibility,
privacy behavior, anti-features, or game functionality. It requires explicit,
source-bound witnesses for those reviews and never lets them override a failed
deterministic check; F-Droid maintainers retain the final inclusion decision.

## Trust boundary

Contracts and suites are executable policy, not a sandbox. Keep required policy
in a trusted, reviewed location. Do not run PR-controlled contracts in a
`pull_request_target` or other secret-bearing job. Path checks reject literal
`..` segments and matching final-component symlinks, but do not claim complete
filesystem confinement through a symlinked root.

The v0 Action requires a POSIX runner with a C17 `cc`; CI currently exercises
Ubuntu 24.04. Native Windows runners are not yet supported.

See `docs/evaluation-protocol.md` for the normative evaluation method,
`research/llm-failure-modes.md` for the empirical basis,
`research/repository-context-methodology.md` for the boundary among retrieval,
in-context learning, training, and constrained decision state, and
`docs/failure-ledger.md` for the reconstructed incident classes. The next
contracts are in `docs/roadmap.md`.
