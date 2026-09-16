# GitHub runner policy

This verifier owns the repository-source part of the maintained GitHub Actions
runner policy. It scans every `.yml` and `.yaml` file directly under
`.github/workflows`.

For maintained Linux jobs, GitHub-hosted Ubuntu is the runner boundary.
Concrete `ubuntu-*` labels, including `ubuntu-latest` and pinned labels such as
`ubuntu-24.04`, are accepted directly. They do not need a runner exception.
Self-hosted Linux runners are not part of this policy, including the superseded
`[self-hosted, linux, debian]` path.

Dynamic `runs-on` expressions are rejected because the accepted runner cannot be
determined from the checked job text. Concrete GitHub-hosted Windows and macOS
runners are accepted only when the exact workflow path, job name, and runner
string appear in an exception TSV with a nonempty reason. Unused exceptions fail,
so an old exception cannot silently survive after the job changes. Ubuntu entries
are not valid exceptions because Ubuntu is already the maintained Linux case.

## Exception format

```text
workflow<TAB>job<TAB>runs_on<TAB>reason
.github/workflows/example.yml<TAB>historical-macos<TAB>macos-15-intel<TAB>native Mach-O reconstruction
```

Exceptions are for concrete non-Ubuntu GitHub-hosted runners. They are not a way
to hide dynamic runner selection or self-hosted Linux execution.

## What this does not prove

A checked-in `runs-on` line proves source configuration only. It does not prove a
runner was available, provisioned as expected, or that the workflow executed.
GitHub-hosted Ubuntu execution is established by the workflow run itself.

Do not create a generic Debian follower or Debian host-acceptance boundary merely
because a repository has GitHub Actions. Historical Debian receipts may remain as
historical evidence, and a deliberately separate portability experiment may name
another userspace, but neither changes the maintained GitHub host boundary from
Ubuntu. Keep actual target/device evidence in the leader/follower system described
in `docs/followers.md`, bound to the exact source revision and acceptance kind.
