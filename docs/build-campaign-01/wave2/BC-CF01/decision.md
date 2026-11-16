# BC-CF01 decision — 2026-10-14

Keep the settled profile/instance architecture and existing CF-A2-S3 identity. Emit two complete continuations, not four artificial replacements. The important correction is that the baseline describes old-main defects that the retained S3 source already repairs.

## Evidence and disposition

| Boundary | Current disposition | Owner / next work |
| --- | --- | --- |
| Positive A1/C67/TAB_P10 classification | Implemented on current main; new observed-property adapter candidate retained | Reuse `android/target.sh` and [isomorphisms/catfood PR #136, “FC-M4: classify captured Android identity without planning overrides”](https://github.com/isomorphisms/catfood/pull/136), `d48e4bd406d6cb5d6cd2fa3f3ea1f78b80277815` |
| Changed firmware / empty fingerprint | Old-main false positives; repaired on retained S3, not a new source defect | CF-A2-S3 reconciliation/requalification |
| Installed-byte reconstruction, v3 receipts, scope, locks | Already implemented by S3 | Preserve seals; do not move their implementation to a duplicate CF04 job |
| Approved package/profile obligations and graph | Existing S2 continuation | CF-A2-S2 under BC-CF04, released schema/material prerequisite |
| General profile lookup and mandatory consumer usage | Still incomplete; A1-only staged reader | BC-CF01-S01 |
| Independent APK/current authority | S4, separate AICI owner | Reuse CF-A2-S4 from BC-A03; no duplicate issuer |
| Physical behavior | NOT_RUN here; historical reports remain scoped | Exact device/firmware/artifact acceptance when authorized and available |

Current Cat Food main is `8ba159f8322cd436aa8e6400b0eded2d74c14011`. Retained `aici-android-producer-receipt@e2d65a5d76ff81bcc65f5cabf8ed2ad0e3a57482` is 24 commits ahead and 8 behind main. Full [isomorphisms/catfood PR #112, “Consume exact AICI Android producer receipts”](https://github.com/isomorphisms/catfood/pull/112) and retained `android/qualification/cf-a2-s3.md` establish that its repaired firmware/fingerprint behavior, whole-tree reconstruction and twelve host suites must be preserved. Closed metadata head `fffa3c9…` is not the live retained source.

The staged `android/profile.pi` at `a1d36ee45b66a1af86d7594cc18df889610d5c81` still restricts model to A1. It expects inventory key `build_fingerprint` while `device-state.sh` emits `fingerprint`; require-current only checks inventory binding. This source mismatch and absence of a common current reader justify the distinct profile/consumer job. The classifier candidate alone does not resolve it.

## Source roles and corrections

- #110 is the durable incident record; its terminal report is user-provided observation, not fresh execution here.
- S1's comment reports historical executed corruptions on old main. Its unpublished `e7111dc954b34fb9d3919f6cbd62812e01b4be22` is unavailable.
- S3 qualification is an existing implementation/evidence record. No new test run was performed in this investigation.
- #118 is a settled architectural decision and implementation handoff, not evidence that all consumers exist.
- #131's later user correction forbids the exact C++ Grease runtime used by historical S3 evidence. Historical results remain results; that artifact is not a current eligible managed-system prerequisite.
- Personal Context returned unavailable. Updated S3 prose is a traceable continuation, not falsely quoted recovered original text.

## Edit order and release boundaries

First reconcile S3's current-main divergence, preserving installed authorization and main's classifier/planner. In parallel S2 releases approved obligation/material semantics and BC-CF01-S01 prepares profile reader changes. Freeze their shared field/schema boundary before integrating profile/plan digests into S3. Kitchen CF-A2-S5 owns the capture consumer and FP03 the registered diagnostic caller; they consume the released profile schema rather than wait for whole jobs. BC-CF02-S01 then binds the canonical resolver inputs; S3 requalifies affected seals after that exact artifact exists.

Source reconciliation and profile implementation are ready. Eligible runtime is the first execution blocker; unavailable physical access blocks only physical receipts. A new independent issuer is neither required for ordinary read-only profile lookup nor authorized here.

## Output

Two complete bodies: CF-A2-S3 (existing identity continued) and BC-CF01-S01 (distinct uncovered profile-consumer work). No remote mutation, product implementation, device action or deployment occurred.

