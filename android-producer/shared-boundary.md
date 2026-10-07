# Shared producer boundary — CF-A2-S4 candidate

Owners remain ai-ci [#207](https://github.com/isomorphisms/ai-ci/issues/207),
[#208](https://github.com/isomorphisms/ai-ci/issues/208), and Cat Food
[#109](https://github.com/isomorphisms/catfood/issues/109). This continuation
does not activate a producer, publication service, migration, or device claim.
The FP3 qualification records retain their original scope and failures.

## Three evidence classes

`AUTHENTICATED_FIXTURE` verifies actual APK bytes against independently signed
test records. Test artifacts are genuinely compiled/linked with NDK r27c,
stripped, packaged with the pinned canonical NativeActivity packager, aligned,
and signed with the existing public persistent test identity. Semantic trace
fixtures are explicitly handmade when tracing is unavailable. They do not
establish independently observed execution, isolation or deployment.

`HOST_OBSERVATION` runs the same finite graph through bounded process capture
and external exec tracing. The positive and undeclared ZIP-packager cases are
real executions on hosts with working ptrace. This class does not establish
confinement or protected issuer/store deployment. Neither class emits public
producer approval. `tests/qualify.ysh` fails overall qualification with exit 3
when mandatory execution is blocked, preserving the artifact suite results.

`ISOLATED` is the only class the public consumer admits. It requires all
independent deployment qualifications, the fixed release anchor, the signed
current-state object outside the release, protected issuer keys and artifact
storage, qualified runtime closure, and real namespace isolation. Missing
authority is `DEPLOYMENT_BLOCKED`; no candidate/fixture can promote itself.

## Exact current authority

Public check, preflight and supervisor accept no release, key or policy override.
The existing action uses the fixed `/opt/aici/android-producer/current` entrypoint.
The independently installed `/opt/aici/keys/android-producer-release.pem` verifies
both the release and `/opt/aici/android-producer/authority/current.tsv`.
Current state binds ACTIVE, generation, release SHA-256 and publication scope.
It is outside the candidate release; old authenticated releases cannot select
their own rollback floor. The deployment authority must maintain this protected
state monotonically and handle revocation. No installer/activation is supplied.

A release binds the manifest, actual source checkout, recipe/material identities,
Cat Food/resolver/plan, target obligations, native payload identities, finite
stage graph, package/version/signer/update lane, and publication scope. Manifest
omission, changed material, missing mandatory role, signed but stale decisions,
and caller-selected roots refuse before approval output. File/argv identities
are checked before executing a worker; only release-owned commands are eligible.

`files.sha256` is a strict relative-path checksum inventory. Source, policy,
packager scripts, runtime verifiers, public keys and stage arguments are required
members. Tool aliases may resolve symlinks, but actual target bytes are pinned.
An independently qualified deployment must make the entire closure immutable;
the finite fixture tool set does not claim to qualify its complete loader/runtime
closure. The host C kernels retain separate NDK compile/link records and the exact
evaluated ICK revision/capability gap.

Deployed admission also checks the independently qualified `host-files.tsv`
closure against actual host loader/libc/utility bytes. Material-domain directory
roots must be real directories inside the release mount; fixture symlink roots
do not qualify an isolated deployment. Qualification of this full closure remains
unavailable on this host.

## Cat Food binding coordination

`aici-catfood-producer-binding-v1` is a **candidate owner projection**, not a claim
that S2's canonical plan schema has been finalized. The exact opaque `plan.tsv`
bytes are hashed and the projection is authenticated by the release. Projection
semantics still require an independently qualified adapter against the actual
S2 resolver/plan schema. `plan_binding_qualification=COORDINATION_PENDING` blocks
public use. Do not feed a caller-authored projection into deployed admission.

The projection carries source repository ID/full commit, dependency material and
recipe digests, Cat Food commit/resolver digest, plan/obligation/payload digests,
artifact group, package/version/signing lane/certificate, update mode and
publication scope. Run/attempt IDs remain outside the pure plan digest.

`obligations.tsv` has exactly these columns:

| Column | Meaning |
| --- | --- |
| target | Canonical target selected by Cat Food |
| artifact_group | Complete artifact-input group |
| abi | Required loaded ABI for this registered native route |
| required | Required obligation, never a caller's optional target list |
| state | QUALIFIED for a complete admitted operation |
| reason | Pinned derivation/evidence scope |

Unknown, excluded, blocked, or another artifact group's cells cannot be dropped
or relabeled PASS. This candidate adapter handles one no-DEX NativeActivity APK
with one native payload, using `payloads.tsv` (`abi`, `library`, `sha256`). It
accepts the canonical inspector's ARMv7, ARM64 and x86 ABI vocabulary without
assuming phone=ARM32 or tablet=ARM64. Separate-ABI companion groups, multi-library,
multi-ABI, direct-DEX and alternate SDK-floor routes require their own qualified
owner adapters/aggregation. They currently refuse as unqualified shapes, rather
than silently reducing an A1+C67 request to one APK. Full plan-wide artifact
aggregation is a remaining S2/S4 integration obligation; this slice is not that
acceptance claim. The pinned packager's API21/API34 limits remain explicit.

## Finite execution graph

`stages.tsv` columns: `id`, `kind`, `depends_on`, `executable`,
`executable_sha256`, `argv`, `argv_sha256`, `output`. It is bounded to 256 nodes,
topologically ordered, duplicate-free, with unique outputs, existing predecessor
dependencies, and all mandatory compile/link/strip/package/inspect/build-toolchain/
signing kinds. The registered single-payload route has one of each kind except
that compilation can have multiple units. Arguments are one literal argument per
line. Only `@RELEASE@` and `@WORK@` are substituted; no shell eval is involved.

Successful execs must belong to `exec-allowlist.tsv` (observed namespace path,
host material path, actual executable SHA-256). A finite allowlist is necessary
but insufficient: the adapter independently requires actual Clang, LLD, strip,
canonical packager/inspector, build-toolchain kernel and signing kernel execution
in their corresponding stages. Naming a YSH wrapper "signing" cannot satisfy it.
Unknown, ambiguous, truncated, failed or undeclared execution refuses. The
observer remains outside worker mounts. Time/output capture uses the existing
native bounded-process helper; workers cannot see private issuer keys, evidence
or sealed output. Namespace teardown precedes output sealing. Interrupted/partial
worker files are never approved; further isolation/lifecycle tests remain needed
on a host that actually supports that boundary.

The mandatory signed witness binds release, source, plan, target obligations,
payload/graph, exact APK bytes, per-stage executable/argv/start/exit/output/trace.
Actual evidence bytes are retained and hashed, and traces are reclassified by the
consumer. Package stage output must equal the APK and stripped output must equal
the extracted native payload. Independent kernel and canonical final APK
inspection run again before any approval line.

## Identity lanes

`new-install` requires independent stable-lane admission and the registered
package/version/certificate. It requires no prior installed Crystal key or old
accepted C67 APK. The valid fixture uses Pauli, proving this separation.

`replacement` additionally requires independently approved prior identity and its
exact authenticated prior decision, same package/certificate, and nondecreasing
versionCode. This establishes artifact/update-identity continuity only. Install,
launch, replacement installation, visual and physical results remain NOT_RUN.
Crystal's unresolved original certificate is preserved separately in
`incidents/crystal-original-signer.tsv`; no signer migration is authorized.

## Runnable qualification

The build host supplies the exact NDK r27c compiler/linker, SDK35/API34 materials,
JRE, Grease pin, android-NDK packager commit
`996671d7b73b7151c3212409025c72b97284b35a`, clean inspection-policy commit
`9fca932be8da84b806727ffc75845df39fa85233`, and existing public test keystore.
Required environment names are explicit in `tests/run.ysh`. No phone/tablet build
or implicit SDK/compiler installation occurs. Set AICI_SOURCE_PIN to the full
commit under test, build the host kernels using `build-host-verifiers.ysh`, then
invoke `tests/qualify.ysh` through the verified Grease runtime with a fresh output
directory. `tests/run-candidate.ysh` is the runner-owned provisioning interface;
the workflow deliberately blocks if independently provisioned materials or
deployment are unavailable. Workflow eligibility is unfiltered.

`tests/authority.ysh` preserves the old event-aware controls (branch-name refusal,
exact unmerged PR head, exact main push, fixed known merged SHA) using the frozen
**admission prefix only**. That historical foreign Bash fixture always refuses;
it has no compiler/artifact checks or unsigned v1 approval path. Its workflow is
named policy-reference admission. Passing it proves none of the new artifact,
execution or deployment claims.

Mutation results require a real accepted counterpart first and a targeted
corruption refused by the candidate but accepted by the disabled guard. Parser,
material, SDK, runtime or isolation failures are invalid kills. Early zero return
is detected through absent approval schema. Execution-observer mutation remains
BLOCKED if ptrace is unavailable. Private fixture issuer and deliberately wrong
APK-signer keys are deleted at harness exit and never retained in evidence.
