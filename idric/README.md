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
