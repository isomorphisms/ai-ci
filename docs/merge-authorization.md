# Merge authorization evidence

A green workflow is not merge authorization by itself. GitHub can attach a
successful check to a PR head while `actions/checkout` actually tested
`refs/pull/<number>/merge`. A push and a pull-request run can also publish the
same job name on the same commit. Old PR metadata can retain a base SHA after
the named base branch has moved.

`merge/verify.sh` is the deterministic authorization verifier. It consumes plain
TSV snapshots so collection can be GitHub-hosted, local, or performed by an
agent without changing the proof rules. `merge/pr-verdict.sh SNAPSHOT_DIRECTORY`
is the ordinary entry point over the ten named snapshot files. It prints a
normalized exact-head check table before the verdict. Missing
information is represented explicitly and fails closed.

## Collection rule

Collect immediately before merge. Resolve the named base ref again from the
repository; do not treat the PR object's stored `base.sha` as the live base.
Record the current PR head separately from any GitHub synthetic merge SHA.
Recompute the merge-base and meaningful diff against the intended current
base. Re-resolve stack parents and cross-repository dependencies. Historical
runs and receipts remain provenance but do not authorize a new head.

The snapshot has ten verifier inputs. `merge/collect-verdict.sh` produces all ten
from stable repository policy plus live GitHub and Git facts, then calls the
same verifier used for retained snapshots. It also retains the prospective
patch, changed-path inventory, and active ruleset contexts as collection
evidence. Collection obtains facts; `merge/verify.sh` applies policy.

### Merge state

`aici-merge-state-v4` records repository, PR number and title, exact PR head,
event SHA and whether it is the head or a synthetic merge, live base ref and
SHA, the PR-reported base SHA for provenance, merge-base, scope base, and stack
parent identity. It also binds the prospective first-parent patch, sorted
changed-path inventory, current intent record, file count, additions, and
deletions. The patch, path inventory, and intent record are hashed separately so
a narrow-looking title or stale conversation summary cannot silently authorize
a different diff or requirement. A current-scope digest binds the intent and
changed paths; live draft and mergeability state are explicit. It also records whether the work is an
`execution` or `advisory` job and its explicit
`PENDING|BLOCKED|FAILED|COMPLETE` state.

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
Base-dependent checks record the base SHA they tested and go stale when the live
base moves. Base-independent checks must declare that fact explicitly.
Skipped, cancelled, missing, in-progress, stale-head, wrong-event, wrong
checkout, and trigger-gap rows do not pass. All observed rows for the head
should be included so push/pull-request or cross-workflow job-name collisions
are visible instead of being hidden by a single green status name.

`merge/check-table.sh STATE CHECKS` renders every row as exactly one of
`PASS`, `FAIL`, `CANCELLED`, `SKIPPED`, `ABSENT`, `STALE`, or
`UNKNOWN`. These states are not collapsed before authorization.

### Dependencies

`exact` means the declared reference itself is a full revision and must equal
the resolved and expected revision. `moving-resolved` is for deliberate active
integration against a branch such as current Idriç: the branch may move, but
the run must retain the exact SHA it resolved. A durable exact-artifact gate
must not silently replace an exact dependency with a moving branch.

### Receipts and evidence boundaries

Receipts distinguish `PASS`, `FAIL`, and `NOT_VERIFIED`. A PASS is bound to the PR
head, source SHA, build SHA, artifact SHA-256 when applicable, platform, ABI,
and orthogonal evidence dimensions:

- execution: `none`, `compile`, `host`, `qemu-user`, `full-system`,
  `android-emulator`, or `physical`;
- hardware: `none`, `mock`, `virtual`, or `physical`;
- network: `none`, `loopback`, `fake-tls`, or `external-tls`;
- artifact mode: `none`, `exact-prebuilt`, or `rebuilt`.
- evidence class: `host`, `github-runner`, `qemu-user`, `qemu-system`,
  `android-emulator`, `physical-phone`, or `physical-tablet`;
- provenance: `none`, `handwritten-oracle`, `compiler-generated`,
  `packaged-only`, or `installed-artifact`;
- execution result: `none`, `compiled`, `packaged`, `installed`,
  `launched`, or `semantic-pass`.

Requirements are matched exactly on every dimension they specify. There is no
implicit promotion from emulator to physical, mock to hardware, compile to
execution, handwritten oracle to compiler generation, packaged artifact to
semantic execution, loopback to external TLS, or rebuilt to exact-prebuilt.
Physical phone and tablet remain distinct targets.

`NOT_VERIFIED` means the claim lacks the required observation. It is not a
product failure and cannot satisfy authorization. Infrastructure and collection
errors remain separate check/blocker states rather than being rewritten as
`FAIL`.

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

### Merge authority

`aici-merge-approval-v3` is an immutable, exact-state authority receipt bound to
the repository, PR number and title, exact head, live base, prospective patch,
changed paths, and an intent-record digest. `authorization_text_sha256` identifies
the human text or surrounding task context that established merge authority; it
does not have to identify the latest utterance.

The decision must be `MERGE`. Accepted authorization kinds are
`explicit-merge`, `conditional-clean`, `github-approval`, and `task-context`.
The receipt also records `authority_actor_kind`, `authority_source_kind`,
`authority_source_id`, and `authority_source_role`. The verifier requires a
human actor and enforces compatible provenance: an explicit merge comes from a
human merge-instruction message; conditional-clean comes from a human conditional
merge task/message; task-context comes from a human merge-authorizing task; and a
GitHub approval comes from a GitHub review. An acknowledgement or implementation
instruction is a valid thing for a collector to observe, but it is not a valid
authority source and cannot be rescued by labeling it `explicit-merge`.

The source is a `cockswain-merge-authority-v1` classification receipt. It names
an opaque private-context reference, digests the recovered context and
authority-establishing text, pins the Cockswain revision and classification
contract, and binds the authorized repository, PR, title, intent, and changed
path scope. Private conversation text is not copied into the public snapshot.
Missing context remains `UNKNOWN`. A changed intent/path scope, revocation, or
unresolved objection prevents the collector from issuing `MERGE`.

`task-context` means an earlier human task already authorized merge as a possible
completion once its stated conditions are satisfied. Later continuation such as
“okay,” “go,” or “so...” may therefore precede the merge without becoming a new
authorization event. Those acknowledgements do not create authority on their
own: a task that authorized only implementation, inspection, discussion, or
opening a pull request does not become merge authority merely because the human
later says “okay.”

The receipt is exact-state bound. A head, base, title, prospective patch,
changed-path, or intent-record change invalidates that receipt and requires a
fresh one. That does not automatically revoke the underlying contextual task
authority. If the refreshed state remains within the same authorized task scope,
the collector may issue a new exact-state receipt from the same authority
context. A material scope or intent change, explicit objection or revocation, or
uncertainty about whether the original task covered merging must not be
auto-refreshed.

Open objections must be recorded and block authorization rather than being
collapsed into a generic clean verdict. The verifier does not infer arbitrary
conversational semantics. The collector must preserve the identity, actor kind,
source kind, and role of the human authority source. The verifier then checks
that those provenance fields are compatible with the claimed authorization
kind. This makes the ordinary accidental failure mode -- hashing an
acknowledgement such as "okay" and labeling it `explicit-merge` -- fail closed.
The Cockswain classifier remains the semantic boundary for recovering the
correct source record. The ai-ci collector validates its provenance and scope
binding but does not reinterpret private conversation. Cryptographic
authentication of private chat history is outside this TSV verifier.

The approval file does not replace the other nine inputs. Human authority cannot
make failed or unknown evidence pass, and mechanically clean evidence cannot
manufacture human permission.

## Live collection policy

The policy directory is file-based and stable across PRs. It contains:

- `settings.tsv`: repository, job kind/state, intent file, and stack parent;
- `checks.tsv`: workflow/job/event mappings, universal versus conditional
  applicability, base dependence, trigger coverage, and the exact-checkout
  witness step;
- `dependencies.tsv`: declared dependency refs and expected revisions;
- `receipts.tsv`, `consumer.tsv`, `blockers.tsv`, and `completion.tsv`: durable
  repository evidence in the verifier schemas;
- `scope.tsv`: exact-file or prefix provenance rules plus optional anchors and
  equivalence records;
- `schedules.tsv`: scheduled claims resolved against the live default branch and
  scheduled runs;
- `authority.tsv`: Cockswain's contextual-authority classification receipt.

Universal checks must also occur in an active ruleset for the live base.
Conditional semantic checks stay out of the universal ruleset when their
workflow is legitimately ineligible for unrelated paths; the collector makes
them required only when repository policy says they apply. A checkout witness
counts only when the workflow uses the explicit PR head and the named witness
step succeeded in the observed job.

### Explicit blockers

`blockers.tsv` records each durable blocker as `OPEN`, `RESOLVED`, or
`WITHDRAWN`, with its evidence reference. Any `OPEN` row blocks
authorization even when GitHub reports the PR mergeable.

### Scheduled-workflow reality

`schedules.tsv` distinguishes `planned`, `configured`, and `operating`
claims. A configured or operating schedule must exist on the default branch and
contain a schedule trigger. Operating surveillance must have an observed run.
When a scheduled workflow is required for the verdict, its last observed run
must be `PASS`; `FAIL`, `CANCELLED`, `SKIPPED`, `ABSENT`, `STALE`,
`UNKNOWN`, and `NEVER_RUN` do not pass.

### Completion

`completion.tsv` records required steps by phase and gives each one exactly one
state: `PENDING`, `BLOCKED`, `FAILED`, or `COMPLETE`. All required rows
must be complete. An execution job must contain a required implementation step;
a plan or audit alone cannot produce a successful execution-job verdict.

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
