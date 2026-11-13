# CF-A2-S4 qualification continuation

Status: **DEPLOYMENT_BLOCKED**. Promotion remains disabled. Full shared Android
producer acceptance is not established.

The source under this run is `6a90fbb9fac8984fe853924d6f5e7298f2458574`, tree
`6bdc59cf699c379d5cd2e520eb904a6304d131b9`. These records are a later
evidence-only addition. The source implementation was run before these records
were added; no exact-head execution claim is made for the evidence commit.

This resumes isomorphisms/ai-ci PR #211, “Bind Android producer execution and
diagnostic claims to verified identities”
(https://github.com/isomorphisms/ai-ci/pull/211), retained original head
`e4723d886658edffd65ffa3d35dc3a2cf83f15ce`, with audited main
`8bf8be153f792c4def251287ed85543d1fe24f07` integrated. The retained branch
was advanced without force. The PR remains closed/draft/unmerged because its
independent authority blockers remain unresolved.

## Evidence scopes

| Claim | Observed result |
| --- | --- |
| Signing C kernel | 6 cases, 0 failures |
| Shared C kernel | 69 cases, 0 failures |
| build-toolchain-v0 | 7 good/bad cases included in the kernel suite; all pass |
| Legacy policy-reference admission, main push | 3 controls pass at audited main |
| Legacy policy-reference admission, exact unmerged retained branch source | 3 controls pass at the source pin above |
| Producer artifact/decision fixtures | 32 PASS, 2 BLOCKED in 34-case inventory |
| Checker disabling mutations | 11 KILLED, each with the real accepted counterpart (early return is killed by missing approval output) |
| Real NDK-then-undeclared-packager execution | BLOCKED: ptrace denied; runnable case retained |
| Execution observer disabling mutation | BLOCKED: ptrace denied; no mutation kill claimed |
| Isolated supervisor execution | BLOCKED: namespace probe unavailable |
| Public check / supervisor | Refuse absent independently deployed authority; no approval stdout |
| Producer aggregate qualifier | Exit 3, DEPLOYMENT_BLOCKED |
| Install, launch, replacement installation, visual, physical | NOT_RUN |

The historical authority controls protect **policy-reference admission only**.
They do not protect artifact, signing, version, packager execution, or deployment
claims. Their separate scope and historical FP3 failure records are preserved.

The accepted Pauli APK is genuinely NDK compiled/linked, stripped, packaged,
aligned and signed with the existing public persistent test certificate. Its
`AUTHENTICATED_FIXTURE` witness uses explicitly handmade semantic exec traces
because ptrace is denied. Authentication of fixture records is not independent
execution observation. The decision and witness TSVs here are text specimens,
not a portable signed release or deployed approval.

New-install and authenticated replacement-identity counterparts both pass.
They report `PRODUCER_EXECUTION NOT_VERIFIED` and `PROMOTION DISABLED`.
Replacement installation is not tested. The unrelated Pauli new-install
counterpart requires no Crystal original signer; Crystal's unresolved incident
remains separately recorded.

Additional public probes in `public-root-probes.tsv` bind the caller release,
decision-key, witness-key and trust-root selectors to exact denial results.
Check and supervisor reach their specific override guards. Preflight refuses
the missing deployment prerequisite first, so its override guards are not
qualified by those probes.

The live GitHub snapshot lists ten successful unrelated push workflows at this
source. No Android qualification workflow ran for this closed PR's branch push;
those workflows select pull_request or main push events. These unrelated greens
are not Android qualification or deployed-authority evidence.

Every negative decision case checks its exact refusal and empty approval stdout.
The suite includes genuine sibling version, wrong-package and wrong-certificate
APKs, changed APK bytes, all seven missing stages, field/witness corruption,
altered verifier, stale release and caller-selected release root.

## Exact material/source pins

| Material | Pin |
| --- | --- |
| ai-ci implementation | 6a90fbb9fac8984fe853924d6f5e7298f2458574 |
| Fixture source | ebbfd7370378ff5ea3369cbe7ae6f05f5fe3b947 |
| Cat Food observed checkout (not S2-final schema) | 609a9628d5a52860f956bf62e0914a0cd03292ae |
| android-NDK canonical packager | 996671d7b73b7151c3212409025c72b97284b35a |
| Clean packager inspection policy | 9fca932be8da84b806727ffc75845df39fa85233 |
| NDK | r27c, 27.2.12479018 |
| SDK | build-tools 35.0.0, Android 34 r3 |
| Evaluated ICK | 79eccb8ff232e05bdbb9e345fc224f251636b43f |
| Grease parent gitlink observed | 5651cf97a1b5042f24f14112a7ade9a1518eb0bc |
| Persistent public signer source repository | Fourier-sound 89dcfb840cec1a66ee04c7f7404954cbd6c09839 |

Actual compiler/linker, host verifier, SDK, Java, Grease, libc and fixture output
SHA-256 pins are in the adjoining material records. These pin bytes that were
used; they do not qualify full runtime provenance or an immutable isolation
closure. Grease source-build provenance remains NOT_VERIFIED. Host verifier
compile and link use NDK r27c, with the exact ICK capability gap retained in
`host-verifiers.tsv`.

The APK is package `org.isomorphisms.pauli`, versionCode 6, armeabi-v7a,
library `libfixture.so`, test certificate
`de9b1d47c5a65e6d46a204b79dd9ee566b9d3c9832ba81ebc4213d3392e92ff9`.

## Runnable qualification and remaining prerequisites

Run the actual Grease interpreter with `build-host-verifiers.ysh FRESH_HOST_DIR`,
then signing/kernel self-tests and
`tests/qualify.ysh FRESH_QUALIFICATION_DIR`. All paths are resolved from the
scripts. Supply the recorded NDK, SDK, Java, packager, approved-policy, persistent
PUBLIC test signer and verifier materials using the environment names recorded
in `invocation.tsv`. `tests/run-candidate.ysh` is the separately provisioned
runner interface; it deliberately cannot bootstrap/activate independent
authority from candidate source.

Fixture authority and intentionally wrong APK signing keys are disposable and
excluded from this evidence package. Successful harness cleanup was checked
before receipts. This workspace restores removed files between tool sessions;
their remaining scratch file contents were separately zeroed and rechecked.

Required before deployed promotion:
- S1 invariant ledger and S2 canonical resolver/plan binding coordination; the
  candidate owner projection is COORDINATION_PENDING, not a finalized S2 schema.
- Qualified adapters and plan-wide aggregation for multiple artifact groups,
  companion ABIs, multi-library/multi-ABI, direct DEX and alternate SDK-floor
  shapes. The current registered adapter admits one no-DEX NativeActivity APK
  with one native payload and refuses unqualified shapes.
- A host that permits independent exec observation and namespace isolation,
  followed by the positive, undeclared-packager and execution-mutant suites.
- Independently signed release and protected monotonic current-state authority,
  qualified stable lane/publication authorization, issuer/store isolation,
  complete immutable host/runtime/material closure and lifecycle qualification.

The fixed independent release boundary remains intact. There is no unsigned v1
self-assertion path. No merge, release, service activation, signer migration,
device compilation or physical acceptance occurred. Owners remain ai-ci #207,
#208 and Cat Food #109.
