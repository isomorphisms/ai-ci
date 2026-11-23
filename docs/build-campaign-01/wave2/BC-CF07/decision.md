# BC-CF07 decision — 2026-10-14

Keep the existing CF-A2-S4 under AICI/BC-A03 as the sole independent authority implementation. This domain emits only Cat Food's uncovered APK coverage and final admitted-export integration; it does not create four replacement authority jobs.

## Findings

Current Cat Food main `8ba159f8322cd436aa8e6400b0eded2d74c14011` lacks first-class APK admission. The retained branch `aici-android-producer-receipt@e2d65a5d76ff81bcc65f5cabf8ed2ad0e3a57482` has the useful consumer and copy/revalidate/seal implementation. [isomorphisms/catfood PR #112, “Consume exact AICI Android producer receipts”](https://github.com/isomorphisms/catfood/pull/112) is closed with stale metadata but explicitly records the live branch.

Its coverage checker requires exactly the three blocked Crystal A1/ARMv7 applications; `check-producer.ysh` refuses every other target. It delegates metadata/ELF, signer, authority and witness verification to fixed independent AICI paths and compares APK hashes before/after. `deliver-apk.ysh` validates, copies APK plus signed decision/witness, validates the copies, publishes without clobbering a destination and checks final hash. Positive authenticated delivery and publication-race qualification are explicitly blocked/not-run in `android/qualification/fp3.tsv`.

AICI's retained `android-producer-composite-gate@5c80279dfcee565f4e999d2b1f97feb966b8efd3` explicitly names CF-A2-S4. Its source-qualified `6a90fbb9…` record has 32 passing fixture cases, 2 blocked execution cases and 11 killed mutations, not deployed authority. Candidate projection `aici-catfood-producer-binding-v1` remains COORDINATION_PENDING; only ISOLATED public evidence can authorize. S4 continues that coupled implementation/qualification in BC-A03.

## Disposition

| Behavior | Disposition |
| --- | --- |
| New independent policy/issuer/verifier | Reuse CF-A2-S4; no duplicate job here |
| S3 installed bytes/firmware/local authorization | Reuse CF-A2-S3 under CF01 |
| Producer denominator, target/group coverage | BC-CF07-S01 |
| Exact copied-byte export, current policy, update consumer | BC-CF07-S02 |
| Finished label/component/icon/localization extraction | BC-P04-S02, consuming BC-P04-S01's approved plan extension |
| Existing ABI/native/DEX/route checks | Consume S4/P01 qualified contracts, no duplicated parser |
| Registered producer/supervision | FP03, consumed output |
| Actual replacement installation | Separate exact-instance acceptance, conditional on authority and access |

[Cat Food #109's corrected audit](https://github.com/isomorphisms/catfood/issues/109#issuecomment-6007307849) remains authoritative: Crystal bypassed absent APK coverage/direct handoff; it was not accepted by a preexisting APK verifier. A shaped receipt or candidate-chosen registry does not close that gap.

## Update authority and execution limits

New-install and replacement are distinct. Preserve persistent certificate/package, nondecreasing versionCode and independently approved prior identity for replacement. The original Crystal certificate's private-key recoverability remains UNKNOWN. Do not impose that incident on unrelated approved new-install applications or use a package rename/uninstall to claim continuity.

Current deployed authority was not observed; the correct claim is unavailable qualification, not proof no deployment exists anywhere. Runtime/source eligibility also remains conditional under #131. The exact historical C++ Grease digest used by S3/S4 cannot be freshly installed on managed systems merely because an artifact locator was renewed.

## Edit order

S4 releases checker/decision/current-authority interface and CF02 releases plan/group schema → CF07-S01 coverage projection → CF07-S02 final copy/export/update binding. Source and denied-path work can begin now. Positive integration waits on the exact qualified material, not whole-job status. Serialize `android/check-producer.ysh`, `deliver-apk.ysh`, `apks.tsv` and shared receipt consumers with S3 and S4 owner changes; do not change P04 extraction independently.

## Output

Two complete SUN bodies plus external reuse of CF-A2-S4. No actual builds, tests, export publication, update/install, key migration or remote mutation in this STAR.

