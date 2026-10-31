# BC-K04 decision — resources, partial state and the human session

STAR/Ultra source decision, 2026-10-13. Owner: `isomorphisms/kitchen`. Parent: [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239). Canonical: [Kitchen #11](https://github.com/isomorphisms/kitchen/issues/11); related [#2](https://github.com/isomorphisms/kitchen/issues/2) and [#24](https://github.com/isomorphisms/kitchen/issues/24).

Authoritative assignment: [BC-K04](https://github.com/isomorphisms/ai-ci/blob/c28ae588ec9699a374ecd59c5392691623b78a51/docs/build-campaign-01/jobs/BC-K04.md) and [REQUEST.md](https://github.com/isomorphisms/ai-ci/blob/c28ae588ec9699a374ecd59c5392691623b78a51/docs/build-campaign-01/REQUEST.md). This continuation executes the domain investigation and authors implementation jobs. It does not implement the SUN work or mutate remote repositories.

## Decision and evidence

Keep Kitchen's existing preparation and owner-adapter architecture. Preserve the source-test POSIX exception, dirty-checkout and parent-errexit repairs, transfer pending-intent mechanism, and existing-state 0700 refusal. Add missing resource and transition controls to the maintained paths; do not create a durability engine, test framework, target registry or replacement transfer runner.

Live source refresh found Kitchen main unchanged at [df14daf8cc612283ea210f206f0097a31db122a0](https://github.com/isomorphisms/kitchen/tree/df14daf8cc612283ea210f206f0097a31db122a0). The retained `fp2/qualified-transfer-generator` branch is still [933ec7974b7b06050fa107a6733a3d1698cabb87](https://github.com/isomorphisms/kitchen/tree/933ec7974b7b06050fa107a6733a3d1698cabb87). These are distinct implementations, not interchangeable qualification evidence.

| Source observation | Already preserved | Remaining boundary and disposition |
|---|---|---|
| `tasks/source-handoff/1.sh`, `tests/source-handoff.sh` | Clean Git environment; exact committed-file selection; protected checkout; conditional child invocation; marker plus exit; untrusted output prefixing | Manifest awk write is unchecked; no complete resource-exhaustion/short-write corpus. S01 owns complete preparation, extraction/capture/emission resource failures and required-file coverage. An unchecked write is source evidence, not a claimed reproduced false PASS. |
| Current transfer renderer and `6.ysh` | Real bounded candidate read/header check; separate API body/status; numeric ID postcondition; already-transferred no-POST path | Renderer streams directly to stdout and temporary probes lack a qualified interruption lifecycle. S02 owns resource handling. Identity, personal-owner and complete presentation reconciliation remain K02. |
| Retained generator, `10.grease`, compact requirements | Private-state repair, existing output refusal, durable pre-POST intent, accepted-unverified no-resend, visibility check | Generation writes directly to final output names. Top state directory is checked, but nested transfer-state, ledger, cached-file and path-component behavior need explicit ownership/file-kind/resource qualification. S02 supplies that bounded contract without independently deciding K02's final four/six-input interface. |
| Retained `tests/qualify-transfer-artifact.pi` | Eighteen API scenarios; seven acquisition/state negatives; exact artifact reruns; independent API observations | Reached interruption points and recoverable-state disposition through resource failures remain unqualified. S03 owns adapter lifecycle, not producer durability. |
| Current two handoff workflows | Exact-head checkouts and unfiltered triggers exist; transfer CI now exists | Transfer workflow selects a forbidden C++ runtime. S04 consumes eligible owner material and wires real consumers; it does not install a replacement. |
| SDF filing retained gate | Exact wrapper/executor/corpus/argument binding, explicit disposable mutations, live-mutation block | Preserve mbox's engine; owner recovery contract constrains cleanup. No new mbox transaction implementation or SDF qualification belongs here. |

The unchanged main source suite was materialized into a disposable Linux x86_64 workspace. Git blob identities matched remote tree objects: engine `578e9d0fc7cfde015c9e66027e54cc014a3aa558`; test `472b3b25e685fc3deb4a9ba45ec64804416c134f`. Running `sh /workspace/scratch/7d963a3a41c1/k04-audit/tests/source-handoff.sh` returned exit 0 and **27/27 PASS**. This proves that baseline suite on those bytes only. No new resource controls, transfer runtime cases or SUN implementation ran. An initial materialization had an extra newline; it was corrected and both blob identities verified before the authoritative rerun. That preliminary run is not exact-source evidence.

## Corrections and ownership

- [Kitchen #11](https://github.com/isomorphisms/kitchen/issues/11) records mutation-capable advice before adequate verification, not established mail loss. Its [October 6 update](https://github.com/isomorphisms/kitchen/issues/11#issuecomment-6016697793) reports mbox fsync/interruption tests; this is retained reported evidence, not execution in this audit.
- [Kitchen #2](https://github.com/isomorphisms/kitchen/issues/2) forbids invented conventional paths and silent file repair. Correct symlinks remain valid where the task permits them; unsafe symlinked **private state** is a distinct refusal condition.
- [Kitchen #24's first update](https://github.com/isomorphisms/kitchen/issues/24#issuecomment-6007769263) requires deterministic generation and observation of every POST. Its [second update](https://github.com/isomorphisms/kitchen/issues/24#issuecomment-6008329518) is historical runtime blockage, not the last word on production requirements.
- [Cat Food #131](https://github.com/isomorphisms/catfood/issues/131)'s October 10 human correction takes priority: no introduced C++ executable/runtime/toolchain, no Python-2 installation to satisfy a launcher, and no stock YSH or shell substitute relabeled as Grease. Source readiness does not imply an eligible runtime exists.
- [BC-K02](https://github.com/isomorphisms/ai-ci/blob/c28ae588ec9699a374ecd59c5392691623b78a51/docs/build-campaign-01/jobs/BC-K02.md) owns exact final parameter-bound transfer, acquisition/identity semantics and client adoption. [BC-K05](https://github.com/isomorphisms/ai-ci/blob/c28ae588ec9699a374ecd59c5392691623b78a51/docs/build-campaign-01/jobs/BC-K05.md) owns truthful required-stage/status/timeout propagation. K04 settles resource state first; these domains consume exact successor contracts and do not independently edit overlapping generators.
- New helper decisions remain Idriç-first; authored shell is Grease-first except the existing reviewed source-test adapter; Python-family first-party source requires checked Ithon. Existing legacy Python remains debt.

## Required state contract

Preparation must either verify every required byte and produce a complete accepted artifact, or refuse. Partial stdout may physically escape on a short write, so acceptance must reject incomplete units; do not promise transactional stdout. Staged output must not overwrite unrelated existing files. Resource preflight is target-scoped and cannot guarantee later capacity: actual write/extraction/capture results need tests.

Private recovery state must retain executing-user ownership and 0700 semantics. A failed attempt cannot silently chmod, clean or replace foreign state. Cleanup removes invocation-owned scratch only; pending intent and producer-required recovery evidence survive. A retry reconciles the original repository identity and retained visibility before effects, and cannot blindly resend an accepted-unverified operation.

Before/after observers must capture checkout HEAD/index, tracked and untracked bytes, unrelated sentinels, path kinds, ownership/modes, recovery files and parent cwd/options/variables. Independent API observation records every attempted method/endpoint/owner/count. A successful parent wrapper is not transfer PASS.

## Allocation, order and release

| Job | Readiness | Release / exact next action |
|---|---|---|
| BC-K04-S01 | READY_HOST_IMPLEMENTATION | Refresh main/AGENTS and local work; implement the next bounded source-test candidate; run the existing source and IB host suites with resource controls. |
| BC-K04-S02 | SOURCE_IMPLEMENTATION_READY; RUNTIME_CONDITIONAL | Continue retained resource repair and current renderer lifecycle in isolation; eligible runtime execution requires exact Cat Food #131 acceptance material. |
| BC-K04-S03 | CONDITIONAL | Require exact S01/S02 successors and settled resource interfaces; transfer execution also needs eligible runtime material. |
| BC-K04-S04 | CONDITIONAL | Require exact S01–S03 results for complete acceptance. Begin independent source-test consumer wiring after S01; transfer runtime/consumer lanes remain explicitly blocked until their prerequisites exist. |

S01 and S02 are independently implementable source work. S03 serializes lifecycle edits after them. S04 alone owns workflow edits. K02 consumes the resulting transfer resource contract; K05 consumes interruption/status witnesses. Material changes to source, contract, runtime, policy, recipe, generated bytes or parameters invalidate affected acceptance.

Four SUN/Ultra jobs are fully authored, 442–465 whitespace-counted words each, with all twelve required fields and END markers. Files and manifest are ready for the coordinator to publish. Authored: 4. Filed: 0. Dispatched: 0. SUN implementations: 0. New adverse-control executions: 0. Existing exact-source baseline cases executed: 27.

## Evidence limits and outstanding boundary

Personal Context returned unavailable, so this decision relies on repository source and explicitly attributed issue reports; it claims neither original-chat recovery nor exhaustive history. Grease, Idriç/edric and Ithon commands were not found on this disposable host's PATH. That observation neither establishes global absence nor authorizes substitution. Physical devices, SDF locks/storage, live mailbox data, live transfer and active FP deployment remain outside this audit. Runtime-ineligible dependent execution remains BLOCKED, not PASS.

END OF BC-K04 DECISION
