# Merge-state observation

`merge/state.sh SNAPSHOT_DIRECTORY` answers one question:

> What concrete condition prevents this exact pull-request head from advancing?

It does not merge, waive, or infer product policy. A repository supplies its
required checks, evidence, dependencies, followers, draft rule, and authority
observation in six plain TSV files. The command emits a stable blocker table.
Zero blockers produces one `READY` row; every other result names an object and a
next mechanical action.

## Snapshot files

`pr.tsv` is `key<TAB>value` using schema `aici-pr-observation-v1`. It records the
repository, PR number/title, exact head, live and PR-reported base revisions,
draft and mergeability state, conflicting paths, overlap, reconciliation policy,
and explicit draft-promotion condition.

`checks.tsv` records required check runs. Both the observed GitHub head and the
actual checkout must equal the current PR head. A base-sensitive check also
records the live base it tested. Failed checks carry one machine-produced cause:
`pr`, `baseline`, `upstream`, `transient`, or `unknown`; unknown stays
`AMBIGUOUS` rather than becoming an invented implementation failure.

`evidence.tsv` uses `PASS`, `FAIL`, and `NOT_VERIFIED`. Every required claim
binds the head, source, artifact hash, execution environment, hardware, network,
provenance, and execution result it actually observed and separately names the
required values. A QEMU, fake-transport, package, or handwritten-oracle row
therefore cannot satisfy a physical, external-network, semantic-execution, or
compiler-generated requirement.

`dependencies.tsv` records exact dependency state. `followers.tsv` records
current and old triggers, whether a follower blocks merging, its acceptance
kind, successor, concrete object, and next action. Informational follower debt
does not block a source merge; stale unsuperseded bookkeeping does.

`authorization.tsv` is an observation of the existing exact-state authority
receipt. It never derives authority from an acknowledgement. A valid receipt on
the exact head is silent. A task-context receipt may be refreshed mechanically
only when its observer has already established that scope is unchanged.

## Stable blocker codes

The public codes are `READY`, `DRAFT`, `CONFLICT`, `CI_PENDING`, `CI_FAILED`,
`CI_STALE`, `DEPENDENCY_PENDING`, `FOLLOWER_PENDING`, `FOLLOWER_STALE`,
`EVIDENCE_MISSING`, `EVIDENCE_STALE`, `EVIDENCE_FAILED`,
`PHYSICAL_EXECUTION_REQUIRED`, `NOT_VERIFIED`,
`HUMAN_AUTHORIZATION_REQUIRED`, `AUTHORIZATION_STALE`, `UPSTREAM_FAILURE`,
`INFRASTRUCTURE_FAILURE`, and `AMBIGUOUS`.

The more detailed ten-file `merge/verify.sh` proof remains the final
authorization verifier. This observation contract is the smaller operational
surface used before that point and by Cockswain.

## Live GitHub collection

`merge/collect-github.sh OWNER/REPOSITORY PR POLICY_DIRECTORY OUTPUT_DIRECTORY`
performs four GitHub reads: PR metadata, the live base head, exact-head check
runs, and live-base check runs. It writes the six observation files and then
runs the classifier. A failed check is classified as PR-introduced only when the
same named check passes on the live base; a base failure becomes
`UPSTREAM_FAILURE`, and missing comparison evidence stays `AMBIGUOUS`.

The policy directory holds `settings.tsv`, the seven-column required-check table,
and repository-produced evidence, dependency, follower, and authorization
observations. Each check names its workflow file. Declaring a check
`binding=head` succeeds only when `merge/check-workflow-head.sh` proves that
every primary checkout in that pull-request workflow explicitly selects
`${{ github.event.pull_request.head.sha || github.sha }}`. A GitHub run label is
never treated as checkout proof; a workflow that regresses to the synthetic
merge ref produces `CI_STALE`.

For a workload sweep, `merge/collect-set.sh MANIFEST.tsv OUTPUT_DIRECTORY`
accepts `repository`, `pr`, and `policy` columns. It retains one snapshot and
result per PR while caching identical live-base and baseline-check reads across
the set. A blocked PR is a successful collection result; only collection errors
abort the sweep.
