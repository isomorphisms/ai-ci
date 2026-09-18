# Merge authorization evidence

A green workflow is not merge authorization by itself. GitHub can attach a
successful check to a PR head while `actions/checkout` actually tested
`refs/pull/<number>/merge`. A push and a pull-request run can also publish the
same job name on the same commit. Old PR metadata can retain a base SHA after
the named base branch has moved.

`merge/verify.sh` is the deterministic authorization verifier. It consumes plain
TSV snapshots so collection can be GitHub-hosted, local, or performed by an
agent without changing the proof rules. Missing information is represented
explicitly and fails closed.

## Collection rule

Collect immediately before merge. Resolve the named base ref again from the
repository; do not treat the PR object's stored `base.sha` as the live base.
Record the current PR head separately from any GitHub synthetic merge SHA.
Recompute the merge-base and meaningful diff against the intended current
base. Re-resolve stack parents and cross-repository dependencies. Historical
runs and receipts remain provenance but do not authorize a new head.

The snapshot has six inputs.

### Merge state

`aici-merge-state-v1` records repository, PR number and title, exact PR head,
event SHA and whether it is the head or a synthetic merge, live base ref and
SHA, the PR-reported base SHA for provenance, merge-base, scope base, and stack
parent identity.

Authorization requires the merge-base to equal the intended current scope
base. An open parent blocks a child. A moved parent invalidates the child. A
landed parent requires retargeting/reconciliation before the child can be
authorized.

### Checks

Each check row records workflow path, job name, event, run id, whether it is
required, whether it claims head or synthetic-merge evidence, status,
conclusion, GitHub-reported head SHA, actual checkout SHA, and trigger
coverage.

A required check must be completed successfully for the exact current head.
Skipped, cancelled, missing, in-progress, stale-head, wrong-event, wrong
checkout, and trigger-gap rows do not pass. All observed rows for the head
should be included so push/pull-request or cross-workflow job-name collisions
are visible instead of being hidden by a single green status name.

### Dependencies

`exact` means the declared reference itself is a full revision and must equal
the resolved and expected revision. `moving-resolved` is for deliberate active
integration against a branch such as current Idriç: the branch may move, but
the run must retain the exact SHA it resolved. A durable exact-artifact gate
must not silently replace an exact dependency with a moving branch.

### Receipts and evidence boundaries

Receipts distinguish `PASS`, `FAIL`, and `UNKNOWN`. A PASS is bound to the PR
head, source SHA, artifact SHA-256 when applicable, platform, ABI, and four
orthogonal evidence dimensions:

- execution: `none`, `compile`, `host`, `qemu-user`, `full-system`,
  `android-emulator`, or `physical`;
- hardware: `none`, `mock`, `virtual`, or `physical`;
- network: `none`, `loopback`, `fake-tls`, or `external-tls`;
- artifact mode: `none`, `exact-prebuilt`, or `rebuilt`.

Requirements are matched exactly on every dimension they specify. There is no
implicit promotion from emulator to physical, mock to hardware, compile to
execution, loopback to external TLS, or rebuilt to exact-prebuilt.

### Scope

Scope rows classify changed commits/files as `intended`, `inherited`, or
`unexplained`. Authorization rejects inherited and unexplained scope rather
than using a crude file-count threshold. Optional `anchor` rows let a
repository prove that stack/ancestry surgery did not preserve ancestry while
losing the intended implementation. Optional `equivalent` rows let a
repository reject a newly introduced backend/path when a repository-local
comparison has established it duplicates an already-landed implementation.

### Exact-artifact consumers

For a receipt requiring `exact-prebuilt`, the consumer trace must verify and
execute that exact checksum and source revision. Any rebuild or substitution
attempt fails even if the replacement later executes successfully. Rebuilding
is separate evidence, not a fallback for an exact-artifact runtime gate.

## Ordinary ordering

1. resolve stack/dependency topology;
2. resolve the live base and recompute intended scope;
3. run cheap source-layout/interface/trigger checks;
4. build once and bind source/dependency/artifact identities;
5. run the evidence class actually required;
6. merge a clean parent first;
7. retarget/reconcile children, invalidate old receipts, and rerun affected
   exact-head checks;
8. authorize the next merge only from the refreshed snapshot.

The verifier intentionally does not infer product intent. Repository-local
scope anchors, equivalence checks, or interface contracts supply facts that are
semantic to that repository; ai-ci then enforces their provenance and result.
