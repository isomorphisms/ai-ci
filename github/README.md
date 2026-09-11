# GitHub runner policy

This verifier owns the repository-source part of the Debian GitHub Actions rule.
It scans every `.yml` and `.yaml` file directly under `.github/workflows`.

For ordinary Linux jobs, `runs-on` must name exactly the three labels
`self-hosted`, `linux`, and `debian`. Label order and block-vs-inline YAML do not
matter. Dynamic `runs-on` expressions are rejected because they make the accepted
operating system depend on data outside the checked job text.

Concrete GitHub-hosted runners beginning with `ubuntu-`, `windows-`, or `macos-`
are accepted only when the exact workflow path, job name, and runner string appear
in an exception TSV with a nonempty reason. Unused exceptions fail, so an old
exception cannot silently survive after the job changes.

For a public repository whose workflow listens to `pull_request`, each self-hosted
Debian job must use this job-level guard exactly:

```yaml
if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository
```

That makes a fork PR skip the job before GitHub assigns it to the self-hosted
runner. Step-level checks do not count.

## Exception format

```text
workflow<TAB>job<TAB>runs_on<TAB>reason
.github/workflows/example.yml<TAB>historical-macos<TAB>macos-15-intel<TAB>native Mach-O reconstruction
```

Exceptions are only for concrete GitHub-hosted runners. A Linux job cannot use an
exception to substitute Ubuntu, a container, or a differently labelled
self-hosted machine for the Debian follower.

## What this does not prove

A checked-in `runs-on: [self-hosted, linux, debian]` line does **not** prove that a
runner is registered, online, Debian, x86-64, correctly provisioned, or that a
workflow ran successfully. Those are runtime evidence.

Keep that evidence in the leader/follower system described in
`docs/followers.md`. A Debian follower may be marked accepted only by a matching
receipt bound to the exact source commit and acceptance kind, with the real OS,
commands, result, and external workflow/run evidence when available. Until the
Hetzner service is actually registered and exercised, its state remains pending
or blocked; this policy verifier never manufactures that acceptance.

## Mobile-led CI changes

Consumer repositories decide which paths change CI requirements. Their follower
reconciliation should treat changes to workflow files, runner setup, toolchain or
package prerequisites, and other declared CI inputs as affecting the Debian
follower. A phone/tablet-led change is complete only when the Debian follower has
either a matching accepted receipt or a durable unresolved follower job. The
shared follower verifier enforces the receipt/job distinction; consumer target
metadata supplies the path-to-follower mapping.
