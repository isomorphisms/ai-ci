# Host-context execution work

The root AICI AGENTS.md still applies.

Use `execute.sh` or `./host-context/execute` for mediated local execution.
Never turn the legacy trace auditor's success into permission to execute.
The executor is stage-zero POSIX shell so it does not need Grease, gh, a
compiler, or an installation recipe to get started. Its actual external probe
dependencies are explicit and checked. Do not label it Grease source.

Keep expected constraints separate from measured facts. Receipts are outputs
only. Preserve exact argv, child status, and failed or interrupted outcomes.
Tests must inspect actual child side effects and output, not only self-written
trace rows. A passing `command -v` or exit status is not application acceptance.

Do not call this a sandbox or a verified transfer/installer. Keep issue #179
open for remaining trust boundaries and consumer adoption. Do not publish
production receipts automatically: arguments can contain private data.
