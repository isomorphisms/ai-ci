# Agent instructions

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