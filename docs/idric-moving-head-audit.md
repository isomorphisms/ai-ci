# Idriç current-head dependency audit

Current dependency selection and historical evidence are different records.
Active lanes select declared branches and resolve them to exact SHAs for each
run. Historical receipts keep the exact SHAs that supported earlier claims, but
those SHAs do not become current checkout selectors.

## Active selection

The machine-readable source is `idric/current-heads-v1.tsv`. Each row names a
lane, repository, requested branch, role, and the repository that owns the
stronger compatibility receipt. `idric/resolve-current-heads.sh` proves that the
branch exists and records the SHA selected for that run.

Resolution proves only what source was selected. Compatibility still requires
the executable lane owned by the named receipt owner.

The DEX lane selects `isomorphisms/Idric@Idriç` together with
`isomorphisms/idric-arm-thumb@dex/sibling-backend-boundary`. This deliberately
follows the reconstructed DEX sibling boundary rather than the old ARM/Thumb
implementation ancestry. A resolved DEX ref is not a DEX execution or
physical-phone receipt.

## Historical and fixed evidence

Exact revisions remain exact when they are evidence for an earlier passing or
failing tuple, a reproduction fixture, or an independent toolchain pin. Those
uses are immutable by design. They are not evidence that the same revision is
the dependency active work should select today.

The August fleet/backend survey formerly carried by the base branch mixed a
useful historical snapshot with present-tense drift policy. That survey remains
recoverable in Git history, but it is intentionally absent from the active tree.
The scheduled check now resolves only the explicitly declared current branches.

This keeps two claims separate:

1. **Selection:** which moving branch current work should follow, and which SHA
   that branch resolved to for this run.
2. **Acceptance:** whether the exact selected compiler/backend/consumer tuple
   actually built and executed through the required lane and target.

A successful selection receipt must never be promoted to acceptance evidence.
