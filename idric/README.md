# Current Idriç dependency heads

This directory declares moving branch selectors for active Idriç ecosystem
lanes. It does not treat an old passing SHA as the present dependency merely
because that SHA remains useful evidence.

`current-heads-v1.tsv` names the branch each active lane selects now.
`resolve-current-heads.sh` resolves those branch names to exact SHAs for the
current run and records the result. Ref resolution is selection evidence only;
it is not a compatibility, build, backend-execution, or device-execution pass.
The repository named in `receipt_owner` owns that stronger evidence.

Exact revisions in historical receipts, old PRs, reproductions, or independent
toolchain pins remain exact for the claim they originally supported. They must
not silently become checkout selectors for current work.

The DEX lane intentionally selects
`isomorphisms/idric-arm-thumb@dex/sibling-backend-boundary`. That is the current
DEX sibling-backend boundary, not the old ARM/Thumb implementation lane. The
manifest chooses what current DEX work should test; it does not claim that DEX
backend execution or physical-phone acceptance has already occurred.

The superseded August fleet/backend survey remains in Git history. It is not
part of the active tree and no scheduled job compares that frozen survey with
current repository heads.

## Source migration inventory

`source-inventory-v1.tsv` is the canonical list of Idriç source files that must
be considered when the language surface or semantics changes.
`source-index.md` is the same inventory in human-readable form with direct
GitHub links.

Entries marked `follow` are migration/revalidation obligations. Entries marked
`review-only` are historical specimens that must be inspected but should not
be mechanically rewritten.

`source-owners-v1.tsv` defines the GitHub owner namespaces included in
mechanical discovery. `discover-source-files.sh` enumerates every non-empty
repository in those namespaces, walks each current default-branch tree, and
emits every `*.idric` path. It fails closed if a recursive tree is truncated.

`check-source-inventory.sh` compares that discovered repository/ref/path set
with the canonical inventory. A new source file, a deleted or moved source file,
or a default-branch/ref change makes the check fail until the inventory is
deliberately reconciled. Its positive and adversarial cases are exercised by
`tests/source-inventory-check.sh`.

The `Idriç source inventory` workflow runs this check for relevant ai-ci
changes and once per day. Cross-repository changes therefore cannot silently
leave the canonical list stale indefinitely.

The source inventory is intentionally distinct from `current-heads-v1.tsv`:
dependency-head selection and source migration are different questions.
