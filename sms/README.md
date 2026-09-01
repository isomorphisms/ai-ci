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

Run it with three working trees and an already-built Idriç compiler:

```text
sh sms/run-cross-repository.sh ../Idric-Net ../grease ../Idric/build/exec/idris2
```

The CI workflow checks out moving branches. Their resolved commits remain in
the ordinary Actions log, but the acceptance contract does not pin the two
projects together. It also runs every six hours, so a new commit in either
project is picked up and fails visibly when the executable boundary drifts.
