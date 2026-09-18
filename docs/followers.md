# Leader and follower acceptance

Mobile development may lead without making the other maintained environments disappear.
A follower is a target that should independently catch up to a tested source or artifact state.

## Durable records

A repository using this policy keeps one `aici-follower-job-v1` TSV record per follower and a separate `aici-follower-receipt-v1` TSV record for actual evidence. The records are deliberately plain `key<TAB>value` text.

A job records the repository, branch/PR, exact trigger commit, leading platform and architecture, leader evidence, artifact identity and SHA-256 when applicable, follower platform and architecture, required action, acceptance kind and action, state, last attempted commit, blocker, evidence, dependencies, reason, supersession, and follow policy.

A receipt records the same source and follower identity plus the exact attempted commit, OS/runtime, build and test commands, artifact identity/hash, external evidence URL when one exists, time, and result.

Version 1 uses `follow_policy=exact`. Rolling a job to a descendant is therefore an explicit new job or supersession, never a silent rewrite of history.

## Target identity is not architecture identity

A follower target is the concrete environment named by the consumer repository, not merely its CPU architecture. Two targets may both be `x86_64` and still require independent evidence because the operating system, package manager, persistence model, hardware access, or runtime boundary differs.

Examples include GitHub-hosted Ubuntu, a disposable Ubuntu container, a persistent Hetzner host, and a Void Linux development machine. A receipt from one does not satisfy another merely because all four execute x86-64 code. Likewise, AArch64 tablet evidence cannot satisfy ARMv7 phone evidence.

Consumer repositories own this target catalog because only they know which distinctions are material to their delivered system. AICI verifies exact identities and receipts; it must not collapse distinct consumer targets into a generic architecture bucket.

Do not turn every technically distinguishable architecture, page size, emulator, or hardware combination into a required follower. A required follower must correspond to a maintained deployment or compatibility target that the consumer has actually identified. A useful CI probe may cover an extra dimension without creating a deployment obligation. If a future target has a durable record before activation, use `required=conditional` and `state=n/a` with the activation condition in `reason`. Physical-device evidence is required only for an identified physical deployment target; an ABI, ISA, page-size, or emulator distinction alone does not create one.

## Acceptance kinds must describe what actually ran

`build`, `runtime`, `artifact`, `physical-device`, and `publication` are evidence classes, not labels of convenience. The acceptance action and receipt must actually perform the operation named by the class.

In particular:

- a repository contract test, target-selection test, or manifest validation is not by itself a `runtime` receipt;
- a compile is not an install or execution receipt;
- an artifact hash/metadata check is not a runtime receipt;
- emulator execution is not a physical-device receipt;
- publication is not implied by a locally produced package.

A wrapper may sequence several stages, but the receipt may claim only the stage it actually records. If a runtime follower depends on provisioning first, its acceptance action should provision the exact target state and then execute the delivered command or program. If that cannot run in the current environment, leave a durable pending or blocked job rather than substituting a cheaper contract check.

Architecture-neutral source does not require inventing architecture-specific binaries. A shell script, data file, or other portable artifact may legitimately be byte-identical across targets while its runtime dependency is architecture-specific. Delivery, installation, and target execution still receive separate target receipts.

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

Follower acceptance also has a bookkeeping boundary. When a matching receipt lands, reconcile every durable tracker that still names that exact follower as outstanding: update the follower job, cross-link the receipt, and update or close the issue, PR checklist, or status note whose blocker it resolves. These records do not update each other automatically. If the new evidence belongs to a successor trigger or different exact scope, mark the older tracker superseded rather than silently treating it as satisfied. Historical evidence stays historical, but stale `pending` or `blocked` statements must not remain authoritative after their obligation has actually been retired.

When an identified maintained follower cannot be executed from the current machine, create the job anyway. A later agent must be able to execute it cold from the repository record without recovering intent from chat or CI logs. Do not create a required blocked job merely because a hypothetical target could exist.

Receipts are evidence, not wishes. Credentials, unavailable hardware, an inaccessible cloud host, or an unsupported backend should leave a blocked or unsupported job rather than an invented pass.
