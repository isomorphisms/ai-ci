# From claimed history to mediated execution

Follow-up to PR #178, "Require host-context preflight for operational commands,"
and issues #176 and #179.

The original verifier accepts a history supplied by its caller. Its checks
cannot establish that an `observed:` row came from a real measurement. Relabel
that interface as a trace-consistency auditor, not an execution gate.

The new local interface takes only an argv request and expected environment
constraints. `host-context/execute.sh` itself collects facts, checks them,
invokes the exact captured argv through the resolved program path, and records
the child result. It accepts no prior receipt or history as authorization.
Expected OS/architecture/node/uid/cwd values are constraints to compare, not
facts to re-label as observed.

This is the first executor-owned enforcement layer, implemented in stage-zero
POSIX shell to avoid assuming a compiler or Grease binary on the target. It
checks its actual helper dependencies and does not acquire them automatically.
It does not solve executable-byte identity, trusted-host attestation, arbitrary
shell semantics, nested processes, validated installers, authentication,
network endpoints, or consumer bypass. Those obligations remain open in #179.

See `host-context/README.md` for the precise supported interface, tests, privacy
handling, and evidence limits. A green legacy auditor result must never be
accepted in place of this runner's actual execution.
