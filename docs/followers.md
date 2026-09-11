# Leader and follower acceptance

Mobile development may lead without making the other maintained environments disappear.
A follower is a target that should independently catch up to a tested source or artifact state.

## Durable records

A repository using this policy keeps one `aici-follower-job-v1` TSV record per follower and a separate `aici-follower-receipt-v1` TSV record for actual evidence. The records are deliberately plain `key<TAB>value` text.

A job records the repository, branch/PR, exact trigger commit, leading platform and architecture, leader evidence, artifact identity and SHA-256 when applicable, follower platform and architecture, required action, acceptance kind and action, state, last attempted commit, blocker, evidence, dependencies, reason, supersession, and follow policy.

A receipt records the same source and follower identity plus the exact attempted commit, OS/runtime, build and test commands, artifact identity/hash, external evidence URL when one exists, time, and result.

Version 1 uses `follow_policy=exact`. Rolling a job to a descendant is therefore an explicit new job or supersession, never a silent rewrite of history.

## States

`accepted` means an exact passing receipt exists. `pending` and `blocked` remain unresolved. `unsupported` is also unresolved and is never green. `n/a` is permitted only for a conditional target and requires a reason. `superseded` requires the successor job to exist.

Build, runtime, artifact, physical-device, and publication acceptance are different kinds. A build receipt cannot satisfy a runtime job, and simulated Android execution cannot satisfy a physical-device job.

## Commands

Compile the verifier with the repository's ordinary strict C flags:

```sh
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
  -o /tmp/aici-followers src/aici_followers.c
```

Then inspect a repository ledger:

```sh
/tmp/aici-followers verify followers/jobs followers/receipts
/tmp/aici-followers pending followers/jobs followers/receipts
/tmp/aici-followers matrix followers/jobs followers/receipts
```

The optional final argument to `pending` or `matrix` is an exact trigger commit.

## Repository integration

The consumer repository decides which changed files affect which targets. That inference belongs close to its real target metadata rather than in a universal AICI hard-coded architecture list. A consumer's reconciliation step should fail when an affected maintained follower has neither a valid accepted receipt nor durable unresolved work.

When Linux GitHub Actions are assigned to the Debian follower, the consumer's impact mapping must treat changes to workflow files, runner setup, package prerequisites, toolchains, and other declared CI inputs as affecting that follower. A phone- or tablet-led change that alters those requirements therefore needs either an exact accepted Debian receipt or a durable pending/blocked Debian follower job. Merely changing the workflow labels does not satisfy the follower.

When a follower cannot be executed from the current machine, create the job anyway. A later agent must be able to execute it cold from the repository record without recovering intent from chat or CI logs.

Receipts are evidence, not wishes. Credentials, unavailable hardware, an inaccessible cloud host, or an unsupported backend should leave a blocked or unsupported job rather than an invented pass.
