# GitHub runner policy

This verifier owns the repository-source part of the maintained GitHub Actions
runner policy. It scans every `.yml` and `.yaml` file directly under
`.github/workflows`.

For ordinary maintained Linux jobs, GitHub-hosted Ubuntu is the normal runner.
Concrete `ubuntu-*` labels, including `ubuntu-latest` and pinned labels such as
`ubuntu-24.04`, are accepted directly. They do not need a runner exception and a
public `pull_request` job on GitHub-hosted Ubuntu does not need the same-repository
fork guard that existed for public self-hosted runners.

A workload that genuinely requires self-hosted Debian may still use exactly the
three labels `self-hosted`, `linux`, and `debian`. Label order and block-vs-inline
YAML do not matter. Because that job actually uses a self-hosted runner, a public
repository workflow that listens to `pull_request` must guard that job at job
scope with:

```yaml
if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository
```

That is a targeted self-hosted safety rule, not a requirement to make Debian or
self-hosting the ordinary Linux path.

Dynamic `runs-on` expressions are rejected because the accepted runner cannot be
determined from the checked job text. Concrete GitHub-hosted Windows and macOS
runners are accepted only when the exact workflow path, job name, and runner
string appear in an exception TSV with a nonempty reason. Unused exceptions fail,
so an old exception cannot silently survive after the job changes. Ubuntu entries
are not valid exceptions because Ubuntu is already the ordinary maintained Linux
case.

## Exception format

```text
workflow<TAB>job<TAB>runs_on<TAB>reason
.github/workflows/example.yml<TAB>historical-macos<TAB>macos-15-intel<TAB>native Mach-O reconstruction
```

Exceptions are for concrete non-Ubuntu GitHub-hosted runners. They are not a way
to hide dynamic runner selection or an arbitrary self-hosted label set.

## What this does not prove

A checked-in `runs-on` line proves source configuration only. It does not prove a
runner was available, provisioned as expected, or that the workflow executed.
GitHub-hosted Ubuntu execution is established by the workflow run itself.
Self-hosted Debian additionally needs real runner/runtime evidence when a project
claims that boundary.

Do not create a generic Debian follower merely because a repository has GitHub
Actions. A Debian follower belongs only to a consumer or workload that actually
requires Debian. Keep such evidence in the leader/follower system described in
`docs/followers.md`, bound to the exact source revision and acceptance kind.
