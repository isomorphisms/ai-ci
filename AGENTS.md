# Agent instructions

Read [`README.md`](README.md), [`docs/failure-ledger.md`](docs/failure-ledger.md),
and [`research/llm-failure-modes.md`](research/llm-failure-modes.md). This file is
the canonical shared guardrail for recurrent agent failures. Repository-local
`AGENTS.md` files may add stricter rules; do not copy this whole section into
every repository.

## Recurrent agent anti-patterns

- **Do not claim stronger evidence than was produced.** Source presence,
  generation, compilation, packaging, installation, launch, semantic execution,
  backend execution, physical-device execution, and publication are different
  evidence levels. Claim only the strongest level actually demonstrated.

- **Do not substitute the requested mechanism.** An oracle, mock, fallback,
  handwritten equivalent, alternate backend, alternate executable, lookalike
  renderer, or convenient reimplementation does not count as acceptance of the
  named implementation.

- **Do not weaken acceptance to obtain green.** Repair the implementation.
  Change a test or contract only when the intended requirement itself is
  independently shown to be wrong or obsolete.

- **Do not reuse stale acceptance.** A successful run from an ancestor, sibling
  branch, previous dependency pin, different artifact, or old PR head is
  historical evidence only. Bind acceptance to the exact revision and material
  pins under review.

- **Do not invent missing continuity.** If an earlier decision, branch state,
  artifact, or conversation fact cannot actually be recovered, report it as
  missing or uncertain rather than reconstructing a plausible history.

- **Do not restore rejected abstractions from stale precedent.** Explicit current
  human corrections and current architecture outrank inherited code, generated
  files, old branches, bootstrap history, upstream conventions, and familiar
  terminology. Do not reintroduce a rejected ontology under a synonym.

- **Do not let representation define semantics.** Matrices, tuples, compiler
  nodes, ABI records, transport bytes, storage formats, and UI payloads are
  representations unless the semantics explicitly make them part of the object.

- **Do not replace deliberate repository design with conventional practice merely
  because it is familiar.** Before introducing a framework, build system,
  runtime, language, directory structure, or abstraction, inspect the
  repository's established implementation path and current architecture.

- **Do not design from fixtures.** Mocks, sample data, test harnesses, temporary
  platform adapters, and today's first executable path must remain replaceable.
  They do not define the permanent interface.

- **Before adding a parallel design, inspect the surrounding current work.**
  Check the current branch, architecture documents, established interfaces,
  terminology, and nearby active changes before inventing another model for the
  same concept.

- **Preserve meaningful stage boundaries.** A later-stage success does not erase
  an earlier-stage failure. Build is not install; install is not launch; launch
  is not semantic behavior; local packaging is not publication.

- **Keep repository-specific conventions local.** Do not turn a convention such
  as `_` build layout, a particular backend hierarchy, or temporary subsystem
  leadership into a universal rule unless it is actually shared across
  repositories.

## ai-ci-specific enforcement

- Every new required assertion needs a passing fixture and a targeted known-bad
  fixture that fails for the intended diagnostic when failure classes matter.
- Scope runtime evidence to the exact process, service, job, or actor under test.
  Unrelated platform noise is not a target failure, and target failure must not
  be hidden by unrelated success.
- When a contract requires `fallback=none`, prove the implementation under test
  performed the work; a wrapper may not hide or relabel a fallback.
- Keep receipts explicit about executable/artifact identity, exact source
  revision, and the stage each result proves.

## Leader/follower enforcement

- Before finishing work led from a phone, tablet, or other architecture-specific
  environment, inspect the consumer repository's follower policy and target
  metadata. Run followers available in the current environment and leave
  durable jobs for the rest.
- Every follower job must name the exact source commit or artifact it follows.
  Do not leave follower obligations only in chat, agent context, or CI logs.
- Close or mark a follower accepted only when its required acceptance kind has a
  matching receipt. Build, runtime, artifact validation, and physical-device
  execution are not interchangeable.
- `unsupported`, inaccessible, and `not run` are never synonyms for green.
  Conditional `n/a` needs a reason.
- If newer work supersedes an unfinished follower, record the supersession
  explicitly. Do not erase the original dependency merely because the branch
  moved forward.
- See [`docs/followers.md`](docs/followers.md) and use `src/aici_followers.c` to
  verify, list pending followers, and render the exact-trigger matrix.

## GitHub runner enforcement

- Maintained Linux GitHub Actions jobs use exactly `[self-hosted, linux, debian]`.
  Do not introduce `ubuntu-*`, `windows-*`, `macos-*`, dynamic `runs-on`, or a
  different self-hosted label set except through a concrete reviewed exception
  accepted by `src/aici_github.c`.
- A public repository workflow that listens to `pull_request` must guard every
  self-hosted Debian job at job scope so fork PRs skip before runner assignment.
  Step-level guards do not satisfy this requirement.
- Checked-in runner labels are configuration, not runtime evidence. Do not call a
  Debian follower registered, online, provisioned, or accepted without the real
  runner/service and an exact-head execution receipt.
- When phone/tablet work changes workflows, runner setup, packages, toolchains,
  or other CI requirements, update the consumer's Debian follower work as part
  of the same change. A pending or blocked follower job is valid durable state;
  invented acceptance is not.
- See [`github/README.md`](github/README.md) and use the `github/` action to scan
  repository workflow policy.
