# Agent instructions

Read [`README.md`](README.md), [`docs/failure-ledger.md`](docs/failure-ledger.md),
and [`research/llm-failure-modes.md`](research/llm-failure-modes.md). This file is
the canonical shared guardrail for recurrent agent failures. Repository-local
`AGENTS.md` files may add stricter rules; do not copy this whole section into
every repository.

## Cross-repository anti-patterns

- Before designing or editing, inspect the current branch, current architecture,
  established interfaces, and nearby current work. Explicit later human
  corrections and current architecture outrank stale source, generated code,
  old branches, upstream convention, and familiar practice.
- Do not invent continuity. If an earlier decision, artifact, branch state, or
  conversation fact cannot be recovered from available evidence, report it as
  missing or uncertain rather than synthesizing a plausible history.
- Claim only the boundary actually exercised. Source presence, generation,
  compilation, packaging, installation, launch, semantic execution, backend
  execution, physical-device execution, and publication are distinct evidence
  levels. Report stronger boundaries as unverified until they are exercised.
- The named mechanism is part of acceptance. An oracle, mock, fallback,
  alternate backend, alternate executable, lookalike renderer, or convenient
  reimplementation may provide comparison data, but it cannot pass the named
  implementation.
- Bind acceptance to the exact head and material pins that produced the result.
  Green results from an ancestor, sibling branch, old artifact, mutable
  dependency, or previous compiler/backend pin are historical evidence only.
- Do not weaken the promised property to obtain green. Do not delete or dilute
  refusal cases, broaden malformed-input acceptance, replace semantic checks
  with file/smoke checks, hide failures, or change expected output merely to
  match a broken implementation. Change a contract only for an independent,
  explicit semantic decision.
- Preserve stage boundaries. A later success does not erase an earlier failure;
  build is not install, install is not launch, launch is not semantic behavior,
  and local packaging is not publication.
- Keep semantic objects independent of convenient representations. Tuples,
  matrices, compiler nodes, ABI records, transport bytes, storage shapes, and UI
  payloads are representations unless the semantics explicitly make them part
  of the object.
- Do not restore a rejected ontology under its old name or a near-synonym merely
  because stale code or conventional terminology still contains it.
- Do not introduce a familiar language, framework, build system, runtime, or
  abstraction solely because it is conventional. Preserve the repository's
  established implementation path unless the task explicitly changes it.
- Mocks, fixtures, harnesses, and platform adapters must cross replaceable
  interfaces. Do not let today's fixture or easiest platform layer define the
  permanent architecture.

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
