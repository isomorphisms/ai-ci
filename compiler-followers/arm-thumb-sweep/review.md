# ARM/Thumb main snapshot review — 2026-09-06

Scope: the entire Git range from reviewed checkpoint `5f132d2f68cdd5ee7ddd98788af882598ad4c2f8` through selected `main` at `3791b38eba892d2f98548b0cc843e97fe0796940`. The checkpoint is unchanged. This is source inspection recorded for normal PR review, not a claim of human approval or target execution.

## Each changed commit

1. [`0950ebaef7b10baf391eb1a7de5227b9632ea4d1`](https://github.com/isomorphisms/idric-arm-thumb/commit/0950ebaef7b10baf391eb1a7de5227b9632ea4d1): adds `.github/workflows/biology-contrast.yml` (36 lines). It looks for an executable `.aici/biology-candidate`, passes that path when present, otherwise runs the shared corpus/oracle gate without a backend candidate. It checks out the biology corpus and calls the shared AICI biology action. No instruction selector, ABI or checked-IR contract changes.
2. [`711a42ab6f8c2a96fabd5a313fecef924ae3e589`](https://github.com/isomorphisms/idric-arm-thumb/commit/711a42ab6f8c2a96fabd5a313fecef924ae3e589): changes only the corpus and action references from branch names to exact revisions. This records what that historical commit did; it is not a policy to pin a stale compiler or to reuse those revisions for a new acceptance claim.
3. [`3791b38eba892d2f98548b0cc843e97fe0796940`](https://github.com/isomorphisms/idric-arm-thumb/commit/3791b38eba892d2f98548b0cc843e97fe0796940): merges the preceding gate work. Its changed-file diff adds the same pinned 36-line workflow to main; no additional CPU implementation or ABI changes appear. The merge commit receives its own 24 classifications rather than silently disappearing from coverage.

All three commits are dimension **2**, reusable test/oracle/verification infrastructure. None changes target-independent semantics (dimension 1), Thumb/ARMv7 lowering (3), phone/runtime integration (4), or a measured target-specific opportunity (5).

## Matrix and boundaries

`classifications.tsv` contains 3 commits × 24 policy targets = **72 explicit outcomes**: 3 `already-covered`, 42 `not-applicable`, and 27 `defer-measurement`.

The source ARM row says `already-covered` only because the source workflow contains the inspected wiring. A corpus-only success is not a direct-backend execution receipt. No target runs were collected in this review.

For CPU/virtual followers, the shared fixture contract is plausible but target execution and activation are not established here. Deferrals preserve the specific ISA, ABI, runtime and observation-only boundaries. Catalog, atlas, platform and shader rows say why host CI wiring does not change their owned facts or grant codegen responsibilities. Unresolved names remain blockers, not permission to implement a guessed target.

The full policy is bound by SHA-256 without changing its rows or inferring new maturity from existing branches. In particular A64 codegen versus catalog, Switch platform versus A64/Maxwell, Apple ABI/profile versus codegen, RV64 hosted versus RV32, M-profile versus phone Thumb, and CPU versus WGSL remain distinct.

This receipt says nothing about unmerged ARM/Thumb branches, current-Idric DEX/ART acceptance, function calls, follower implementations or emission allow-lists. It does not establish `emitted` or `tested` support. Issue #20's current branching/conditionals milestone remains in force. There is no RefC/C fallback.

If the selected upstream branch moves beyond this snapshot, CI must reject this receipt as stale for that new range rather than treating this review as continuing approval.
