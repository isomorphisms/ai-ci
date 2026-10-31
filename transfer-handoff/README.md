# Independent transfer handoff checks

The host executor in this fixture is **legacy C++-generated YSH reference only**,
not an accepted production Grease runtime. The expired, seven-day GitHub Actions
artifact `12192502970` is no longer acquired. The action checks out Grease at
`ba869518c7d850de6c47d8c6234654575e264e6c`, checks its `source/` gitlink
against Oils `5651cf97a1b5042f24f14112a7ade9a1518eb0bc`, independently
checks out that exact Oils commit, runs the maintained `cpp-spec` oracle,
and checksum-verifies the copied host executable. A separate provenance
receipt records the source revisions, built SHA-256 digest and reference-only
scope. This avoids an expiring artifact ID without promoting C++ or the
incomplete D implementation to production acceptance. The published ARM
packages remain checksum-verified packaging fixtures, not physical execution
or approval for installation.

`tests/transfer-handoff.grease` runs the actual native Grease interpreter and
Kitchen-generated program. GitHub responses are synthetic; mutation counts
are observed by the external fixture. It exercises the FP session twice and
requires one total POST, plus identity, upstream, login, redirect, collision,
interrupted transport, late convergence, missing-envelope and changed-byte
rejections. `tests/grease-package-payloads.grease` checks genuine published ARM
payloads and six damaged/incompatible controls without executing ARM code.

`verify.grease` checks delivered byte identity and binds it to the FP record,
then independently reads destination identity rather than trusting producer
stdout. A local envelope is an execution record, not a cryptographically
authenticated trusted-controller attestation. Missing-envelope rejection does
not establish protection against a forged envelope or privileged bypass.

The `publication` mode therefore fails closed even when a local envelope claims
PASS for admission or delivery. The FP session invokes it before any live API
effect. Its explicit `acceptance-fixture` context runs the native integration
suite but records `publication=BLOCKED` and `job_completion=NOT_ACCEPTED`.
This is a refusal boundary, not an implemented trusted transport. The public FP
transfer operation now prepares exact Kitchen bytes only, and the independent
suite compares those bytes with a direct Kitchen regeneration, verifies zero
fixture POST attempts, rejects the retired four-argument route and rejects the
historical considered/consider mismatch. The separate six-argument execute
operation retains the existing one-attempt/recovery controls.

The complete task remains unaccepted until the exact source-fetch/bootstrap
handoff, provisioning reuse/acquisition/recovery matrix, protected FP admission,
and real device/result boundaries pass. No host suite result closes issue 245
or authorizes a success claim about the physical Conan Wu transfer.
