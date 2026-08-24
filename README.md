# ai-ci

`ai-ci` is a shared contract test suite for AI-authored project work.

Its rule is stricter than ordinary green CI:

> A check must demonstrate the promised result, and it must prove that it
> rejects a deliberately broken example of the same result.

The initial kernel is a small native C verifier. It has no package-manager
bootstrap and does not treat file existence alone as acceptance. A consumer pins
this repository by full commit SHA, supplies a tab-separated contract, and
runs the verifier against the finished repository or artifact tree.

## What v0 checks

- narrative synchronization: canonical script text, voiceover input text, and
  caption text remain byte-identical;
- asset provenance manifest schema and nonempty required attribution fields;
- workflow integrity: rejection of `continue-on-error`, shell `||`, and
  `set +e`; full-SHA action pins; and event-scoped coverage of critical paths;
- language boundaries, including detecting shell files mislabeled as Grease.

Every required assertion has a good contract fixture and a targeted known-bad
fixture in `tests/cases.tsv`. The self-test audits that coverage mechanically;
adding an assertion without a unique diagnostic and matching bad fixture makes
CI fail.

## Run locally

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici src/aici.c
/tmp/aici self-test tests/cases.tsv
/tmp/aici suite tests/good-suite.tsv .
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

## Limits

The v0 checks are deterministic. They cannot decide whether an explanation is
mathematically insightful or whether an obscure remembered source is the
intended one, and the Grease contract proves declared invocation rather than a
working Grease runtime. The roadmap adds source packets, artifact probes, and
grounded semantic review without allowing those softer checks to override a
deterministic failure.

## Trust boundary

Contracts and suites are executable policy, not a sandbox. Keep required policy
in a trusted, reviewed location. Do not run PR-controlled contracts in a
`pull_request_target` or other secret-bearing job. Path checks reject literal
`..` segments and matching final-component symlinks, but do not claim complete
filesystem confinement through a symlinked root.

The v0 Action requires a POSIX runner with a C17 `cc`; CI currently exercises
Ubuntu 24.04. Native Windows runners are not yet supported.

See `research/llm-failure-modes.md` for the empirical basis and
`docs/failure-ledger.md` for the reconstructed incident classes. The next
contracts are in `docs/roadmap.md`.
