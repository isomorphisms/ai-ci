# Merge-state dogfood

`2026-09-20.tsv` is the retained observation from the open-PR integration
sweep. Each row binds a real repository, PR, and exact head observed through the
GitHub API. `blocker_set` is the small set the merge-state contract must expose;
it is not a claim that the PR should be merged.

The `before_*` columns count the minimum distinct discovery interactions used
to reconstruct the old answer: PR topology, head workflows, failed jobs/logs,
base comparison, evidence receipts, and cross-repository follower/dependency
state. The `after_*` columns count the new operational interface. Four API reads
is the uncached per-PR ceiling; `collect-set.sh` shares identical base reads.
The optimization target is agent attention: one command and no conversational
inference, even when the bounded API work is similar.

`physical-present-reusable` means a physical receipt exists for an exact
artifact and a declared rule may reuse that bounded claim. It does not promote
the receipt to a different artifact, device class, or current-head claim.

