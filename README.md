# ai-ci

Shared executable acceptance contracts for AI-authored work across the `isomorphisms` projects.

The rule is narrow: **green means every required claim was verified for the exact commit and, when relevant, the exact final artifact bytes.** Everything else is `FAIL` or `NOT VERIFIED`.

## Why this exists

A green build job can coexist with a broken final product. The build may have been skipped, run on an old commit, tested a different APK than the released one, compiled generated C without executing the claimed source language, or checked file syntax without checking the mathematics visible in a video.

`ai-ci` separates three outcomes:

- `PASS`: the required check ran for the expected commit and its evidence is current.
- `FAIL`: the check ran for that commit and observed a violated invariant.
- `NOT VERIFIED`: the check was absent, skipped, blocked, cancelled, stale, ambiguous, malformed, or detached from the artifact now being shipped.

Only an aggregate `PASS` exits successfully.

## Current checkpoint

The first enforced contract is the fail-closed evidence gate. It already rejects:

- absent, skipped, blocked, and cancelled checks;
- reports from a different commit;
- duplicate or malformed reports;
- artifacts changed after their test;
- artifacts outside the checked repository through traversal or symlinks;
- a successful command that did not produce its promised artifact.

The Android install, fresh-host, Grease/Idriç execution, media-source, attribution, and semantic-scene checks are recorded in [`failures/escaped-defects.json`](failures/escaped-defects.json). They are not represented as finished merely because this gate exists.

## Contract

A project owns `.ai-ci/contract.json`:

```json
{
  "schema_version": 1,
  "required_checks": [
    {
      "name": "final-artifact",
      "artifact_required": true,
      "description": "The exact final artifact passed its acceptance test."
    },
    {
      "name": "clean-machine-smoke",
      "artifact_required": false,
      "description": "The documented command ran on a clean supported machine."
    }
  ]
}
```

An empty contract is invalid. A required check with no report becomes `NOT VERIFIED`.

## Record evidence by running the check

`run` executes an argv directly—there is no implicit shell—and records what actually happened:

```sh
node bin/ai-ci.mjs run \
  --check final-artifact \
  --commit 0123456789abcdef0123456789abcdef01234567 \
  --environment ubuntu-24.04 \
  --artifact dist/app-release.apk \
  --output .ai-ci/evidence/final-artifact.json \
  -- ./bin/test-final-artifact dist/app-release.apk
```

The report contains the exact argv, environment description, commit, status, and SHA-256 of the artifact after the command exits successfully.

## Aggregate the gate

```sh
node bin/ai-ci.mjs gate \
  --contract .ai-ci/contract.json \
  --evidence-dir .ai-ci/evidence \
  --commit 0123456789abcdef0123456789abcdef01234567 \
  --root . \
  --output .ai-ci/report.json
```

Exit codes are `0` for `PASS`, `1` for `FAIL`, and `2` for `NOT VERIFIED` or invalid gate input.

The repository also exposes a dependency-free JavaScript GitHub Action. Pin it to a release tag or full commit rather than copying the checker into every project:

```yaml
- name: Acceptance gate
  uses: isomorphisms/ai-ci@v1
  with:
    contract: .ai-ci/contract.json
    evidence_dir: .ai-ci/evidence
    expected_commit: ${{ github.event.pull_request.head.sha || github.sha }}
    root: .
    output: .ai-ci/report.json
```

The action writes the three-state table to the job summary. GitHub has only successful and unsuccessful job conclusions, so both `FAIL` and `NOT VERIFIED` make the job unsuccessful; the summary preserves which one occurred.

## Same tested bytes, same released bytes

After downloading the uploaded or released artifact, compare it to the tested file:

```sh
node bin/ai-ci.mjs same-bytes \
  --left dist/tested.apk \
  --right downloaded/released.apk
```

Matching filenames do not count. The command compares SHA-256 digests of the bytes.

## Add an escaped defect

Each escaped defect must leave four things behind:

`failure → missing invariant → regression fixture → shared or project-local check`

The regression must include a deliberately broken fixture that the check rejects. Do not weaken a contract to make CI green. Correct the product, correct the test, or leave the claim `NOT VERIFIED`.
