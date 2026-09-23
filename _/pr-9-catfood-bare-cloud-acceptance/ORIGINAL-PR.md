# Original pull request

- Repository: `isomorphisms/ai-ci`
- Pull request: #9 — Exercise Cat Food from a bare cloud container
- Opened: 2026-08-26
- Historical base recorded by GitHub: `main` at `f1933fb01482289ec8b3e55c59ae6d30e1340be1`
- Exact archived head: `438f08555a215c29479d81048cd8e31d930c674a`
- Historical size: 17 changed files, +433 / -0
- State immediately before archival: open, non-draft, mergeable

## Original contract

- start with a digest-pinned official Ubuntu 24.04 container
- make the first container command Cat Food's first README command (`apt-get update`)
- execute the complete documented fresh-Ubuntu block through `./catfood`
- require Cat Food-built artifacts for Grease, Idriç, Ithon, Fieldmouse, IR, ICU, and IB
- run ai-ci-owned sample programs and compare complete stdout byte-for-byte
- exercise ICU against a deterministic loopback C server rather than the public network
- declare a daily schedule as well as change-triggered runs; while the workflow remained only on the unmerged PR branch, GitHub did not execute that cron

The artifact checks occurred before fixtures so the acceptance test could not create a missing ICU or IB itself and then incorrectly credit Cat Food.

## Local verification recorded by the PR

- POSIX shell syntax checked
- workflow YAML parsed
- ICU server compiled under strict C17 warnings-as-errors
- loopback HTTP fixture returned the exact expected body

The cloud job was intended to be the authoritative end-to-end evidence because it alone began with the pinned bare container and performed the complete documented Cat Food provision.

## Discussion

No top-level comments or inline review threads were present when this archive was made.
