# Agent instructions

## Cross-repository anti-patterns

These rules apply in addition to stricter repository-specific rules below.

- Claim only the boundary actually exercised. Source presence, fixtures, generation, compilation, packaging, installation, launch, smoke checks, semantic execution, backend execution, and physical-device execution are different evidence levels. If a stronger boundary was not exercised, report it as unverified.
- The named mechanism is part of acceptance. Do not substitute a fallback, oracle, mock, alternate backend, alternate executable, lookalike renderer, or conventional nearby toolchain and keep the original label.
- Do not weaken acceptance to obtain green. Repair the implementation. Change the contract only when the requirement itself is shown to be wrong or obsolete, and keep that semantic decision explicit. Targeted negative tests must fail for the intended reason when the distinction matters.
- Keep semantics independent of convenient representations. Mathematical, domain, and language objects are not defined by tuples, matrices, compiler nodes, ABI records, transport bytes, storage shapes, or UI payloads unless the semantics explicitly say so.
- Current explicit human corrections and current architecture outrank stale source, generated code, upstream conventions, older branches, bootstrap precedent, and familiar practice. Do not restore a rejected abstraction under its old name or a near-synonym.
- Acceptance belongs to an exact head and its material pins. An ancestor's, sibling branch's, or previous pin's green result is historical evidence only.
- Mocks, fixtures, harnesses, and today's platform adapter must cross replaceable interfaces; they do not get to define the permanent architecture merely because they are currently convenient.
- Preserve the repository's chosen implementation path and layout before introducing familiar infrastructure. Where `_` is an established machinery boundary, keep build/package/generated/test/compiler material there and preserve canonical source and intended soft links.

## Green must preserve the promised property

Do not make a failing contract green by deleting a known-bad case, broadening acceptance, adding `continue-on-error` behavior, replacing semantic assertions with file/smoke checks, or changing the contract to match the broken implementation.

A contract may change only when the promised property itself is shown to be wrong or obsolete. Keep that semantic decision explicit and independent of the implementation failure.

Every new required assertion needs a targeted known-bad fixture that fails for the intended reason. A generic nonzero exit or unrelated crash is not sufficient when the contract distinguishes failure classes.

## Test the implementation under test

An oracle, fixture generator, mock backend, fallback, alternate renderer, or same-plan reimplementation may provide comparison data, but it is not acceptance of the named implementation.

Receipts must identify the exact executable/artifact and exact source revision that performed the work. When a contract requires `fallback=none`, do not hide a fallback behind wrapper code or relabel its output as native evidence.

## Exact-head evidence only

A green workflow for an ancestor, sibling branch, previous pin, or different artifact is historical evidence. Do not report it as acceptance of the current head.

Tie receipts to the commit being evaluated and to material compiler/backend/tool pins. If the head changes, rerun the evidence that depends on it.

## Preserve stage and provenance boundaries

Do not let a later-stage success erase an earlier-stage failure. Keep acquisition, decoding, recovery, compilation, packaging, execution, publication, and other contract stages distinct when the consumer's claim depends on those distinctions.

A successful build is not a successful install; install is not launch; launch is not semantic behavior; local packaging is not store publication. Report only the strongest boundary actually demonstrated.