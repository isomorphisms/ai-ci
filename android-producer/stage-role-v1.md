# Approved stage-role witness interface

`stage-roles.tsv` is the immutable boundary between approved compiler policy
and observed producer execution. A03 owns its issuer and contents; the producer
candidate cannot derive authority from its own graph, executable names,
`--version` output, or declarations.

The tab-separated columns are:

| column | meaning |
| --- | --- |
| `stage` | exact `stages.tsv` stage identifier |
| `role` | approved role within that stage, such as `driver`, `frontend`, `linker`, `stripper`, `package`, `inspect`, `build-toolchain`, or `signing` |
| `required` | literal `required`; absent roles cannot be waived by the candidate |
| `executable` | release-relative executable whose successful `execve` must be observed |
| `executable_sha256` | exact executable bytes |
| `arguments` | release-relative file containing required literal argument tokens, one per line |
| `arguments_sha256` | exact argument-requirement bytes |
| `support` | release-relative SHA-256 manifest for declared sysroot, builtin-header, recipe, policy, or other role support bytes |
| `support_sha256` | exact support-manifest bytes |

The object has a detached signature verified by `role-authority.pem`. Both the
role object and issuer digest are bound into the release, witness, and decision.
The protected deployment anchor selects that issuer; callers cannot supply a
key or role file.

Every graph stage needs an approved `driver` matching its exact executable.
Compilation additionally needs `frontend`; link needs `linker`; strip needs
`stripper`; the remaining stage kinds need a same-named semantic role. More
roles may be required without changing the observer. This permits an ICK driver
and owned cc1, an explicitly split ICK-source/NDK-assembly/link route, or a
qualified relocated executable. It does not treat identical version text,
basename, symlink, or inherited SDK/NDK path as identity.

The independent trace consumer checks successful declared executions, exact
paths, required arguments, support bytes, child failures, trace completeness,
stage output digests, and the final APK bytes. A changed source, executable,
support manifest, role policy, graph, output, or authenticated trace invalidates
the decision. Stub traces exercise parsing only. `HOST_OBSERVATION` remains
non-authorizing, and only an independently provisioned `ISOLATED` deployment
may emit producer approval.

Current qualification remains conditional on the exact provisioned Grease
runtime/material record, A03 role issuer, P02 material closure, and disposable
isolation. Their absence is `DEPLOYMENT_BLOCKED`, not a fixture pass.
