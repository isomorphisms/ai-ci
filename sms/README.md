# Executable SMS cross-repository receipt

This check compiles the current Idric-Net `Network.SMS` command-line parser and
passes that executable to the current Grease filesystem service. It does not
substitute a shell parser, contact a provider, use a real telephone number, or
invoke a model.

The normal probe emits one tab-separated `PASS` or `FAIL` line per observable
claim. The self-test then places four deliberately broken service wrappers in
the same path and requires the probe to reject missing authorization, early
delivery, delivery after cancellation, and collapsed same-time events at their
specific checks.

Run it with the three dependency working trees; the runner builds the declared
Idriç checkout itself:

```text
bash sms/run-cross-repository.sh ../Idric-Net ../grease ../Idric
```

The CI workflow checks out moving branches. `sms/build/current-head-receipt.tsv`
records every requested ref, resolved SHA, clean/dirty state, stage result, and
first failure. A failed prerequisite leaves later stages as `SKIP`; it is never
relabeled as an independent downstream failure. The workflow runs every six
hours, so a new commit in any component is picked up and fails visibly when the
executable boundary drifts.
