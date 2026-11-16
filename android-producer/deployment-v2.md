# Android producer v2 deployment boundary

## CF-A2-S4 continuation

The historical FP3 description below retains its original scope/failures. The
current application-neutral finite-graph candidate and stronger current-state,
plan/material/payload/execution bindings are documented in
[shared-boundary.md](shared-boundary.md). Crystal's signer incident remains
separate. S4 does not activate deployment or claim isolated execution on a host
that denies bubblewrap/ptrace; full multi-group S2 integration is still pending.

The v1 merged action is insufficient producer authority. Its ancestry test,
caller policy ref, optional prior sidecar, and generic `cc` build are superseded.
`check.ysh` does not certify them or fall back to v1. It consumes an independently
authenticated producer decision and its mandatory process witness, then runs
the existing build-toolchain and signing kernels plus canonical APK inspection.

The active release lives at `/opt/aici/android-producer/current`; the independently
installed release trust anchor lives at `/opt/aici/keys/android-producer-release.pem`.
Neither location nor expected identity is a request parameter. An immutable,
protected independently qualified deployment is required. A signed
`release.tsv` binds `generation`, `policy_commit`, `entrypoint_sha256`, and
`files_sha256`, `supervisor_sha256`, source/target/scope, independent stable-lane
authorization and `execution_qualification=QUALIFIED`. The qualification value
may be activated only after independent supervisor qualification; fixture tests
or worker declarations cannot authorize it. The verified file manifest includes the policy, packager, source
snapshot, required stages, keys, tools, verifier binaries, and runtime closure.
The deployment must advance generation monotonically and retain earlier run
decisions. Merely reaching `main` never activates a historical policy.

`required-stages.tsv` is a trusted inventory of stage name and executable digest.
The independent witness service must observe actual compile, link, stripping,
canonical packaging, artifact inspection, build-toolchain and signer checks;
it signs source/artifact/target/scope and each process's start, exit, executable
and output identities. A worker never holds the witness or decision private key.
An accepted decision includes all those identities and the witness digest.
Missing witness, forged sidecar, skipped process, changed executable, no-op
substitution or stale artifact fails. Printed PASS text is not consumed.

The NDK host verifier builder explicitly compiles and links the existing C
kernels with pinned r27c tools for `x86_64-linux-gnu`. It records the native
Linux glibc closure and executes the existing good/bad kernel and signer cases.
This is a candidate host qualification; it does not claim NDK Android execution
or authorize a generic compiler bootstrap. ICK's complete host libc qualification
is absent here; the exact evaluated revision and gap are recorded.

**Not deployed:** no independently approved release anchor, process-witness
issuer, decision-signing service, protected artifact store or active promotion
was materialized in FP3. Qualification fixtures must keep their private keys
outside application writes and label results as fixture inspection. They cannot
authorize user delivery. A signed witness format alone is not execution proof.

`supervise.ysh` now authors the fixed Crystal route: read-only source/material
mounts, private worker scratch, external exec tracing, sealed native outputs,
canonical packaging, independent checks and signed witness/decision output.
It refuses missing isolation. Syntax and its undeployed public denial were
checked; the isolated positive/hostile process suite could not run on this host.
Trace classification, process termination/rerun, complete runtime closure,
protected storage and issuer deployment therefore remain **unqualified**.
`tests/run.ysh` tests fixture authentication/semantic rejection on real APKs.
It does not qualify the supervisor or prove an actual Gradle execution was caught.
Public consumers and the supervisor require independent qualification activation.

Producer validation excludes installation, launch, replacement, visual and
physical claims. Update identity needs an authenticated prior accepted decision
and actual replacement-install evidence; it remains NOT_RUN here. Original
Crystal key recovery remains UNKNOWN; a registered test signer does not migrate
the original differently signed installs.

Owners: [AICI #207](https://github.com/isomorphisms/ai-ci/issues/207),
[Android-NDK #14](https://github.com/isomorphisms/android-NDK/issues/14),
[Cat Food #109](https://github.com/isomorphisms/catfood/issues/109),
[Crystal #8](https://github.com/functorial-games/crystal/issues/8), and
[Flexible Pipes #28](https://github.com/isomorphisms/flexible-pipes/issues/28).
