# BC-CF07 source coverage

Collected 2026-10-14. This is source/discussion investigation and complete job authoring, not newly executed product acceptance. Current Cat Food main was refreshed twice and remained `8ba159f8322cd436aa8e6400b0eded2d74c14011`.

Shared baseline read: REQUEST.md, AGENTS.md, shared-aici-AGENTS.md, the four assigned STAR packets, wave1/jobs.tsv and wave1's 26 preexisting SUN identities. Standing working-contract, intent-lock and split-work-jobs were applied; explicit STAR/SUN Ultra overrides allocation defaults. Cat Food current AGENTS/README were read, plus ai-ci README, failure ledger and research guardrails at `949a60dad5e014cafce2c49619df9bbdbcfaafc0`.

## Reachable refresh denominator

Cat Food all-state REST issue collection: pages 100 + 37 + 0 = 137 distinct numbered records, classified as 33 issues and 104 PRs. Branch collection: 100 + 12 + 0 = 112 current refs. This refresh screens current work and does not claim deep review of all 104 PRs/112 branches. Main, retained producer, staged profile and SDF trees were fetched recursively with `truncated=false`. Source inventories are not an atomic snapshot.

Complete issue-comment tools advertise all-page retrieval; counts below match each fetched issue's declared comment count. They do not expose per-page sizes, so no invented page count is reported. PR issue-discussion counts are distinguished from inline reviews; review-thread pagination, current checks/rulesets and merge eligibility were not audited because no integration/merge authorization is requested.

Personal Context returned “unavailable for this conversation.” Existing CF-A2 source/evidence and issue records were recovered, but unpublished S1 commit `e7111dc954b34fb9d3919f6cbd62812e01b4be22` and original complete CF-A2 prose were not. Continuations preserve existing IDs and disclose reconstruction from durable records. No private transcript is published.


## Complete discussions

| Source | Body | Comments read / declared |
| --- | --- | ---: |
| [Cat Food #109](https://github.com/isomorphisms/catfood/issues/109) | Complete | 7/7 |
| [Cat Food #118](https://github.com/isomorphisms/catfood/issues/118) | Complete | 3/3 |
| [ai-ci #207](https://github.com/isomorphisms/ai-ci/issues/207) | Complete including corrected causal audit | 5/5 |
| [Cat Food #131](https://github.com/isomorphisms/catfood/issues/131) | Complete later human correction | 1/1 |

## Exact implementation inspected

- Retained Cat Food `aici-android-producer-receipt@e2d65a5d76ff81bcc65f5cabf8ed2ad0e3a57482`: complete `android/apks.tsv`, `check-apk-coverage.ysh`, `check-producer.ysh`, `deliver-apk.ysh`, `content.sh`, `android/qualification/fp3.tsv`, `cf-a2-s3.md` and source/evidence README.
- [isomorphisms/catfood PR #112, “Consume exact AICI Android producer receipts”](https://github.com/isomorphisms/catfood/pull/112): full current body, 0/0 comments; live retained branch refreshed independently, not inferred from frozen metadata.
- [isomorphisms/ai-ci PR #211, “Bind Android producer execution and diagnostic claims to verified identities”](https://github.com/isomorphisms/ai-ci/pull/211): metadata refreshed, 0 issue/0 review comments. Live `android-producer-composite-gate@5c80279dfcee565f4e999d2b1f97feb966b8efd3` inspected independently; its `README.md`, `shared-boundary.md`, `qualification/s4/README.md` are complete source records. Original tested source `6a90fbb9fac8984fe853924d6f5e7298f2458574` is distinguished from evidence commit.
- [isomorphisms/ai-ci PR #230, “SUN 1: independently verify Cat Food companion plans and signed APK bytes”](https://github.com/isomorphisms/ai-ci/pull/230), `0699756155d614bb75caeb679d97e40934b7dced`: complete `android-companion/verify.sh` read; source parsing/ancestry checks are not deployed authenticated authority.

## Exact dedupe

CF-A2-S4 appears explicitly in retained AICI source; it is continued by BC-A03, not replaced here. CF-A2-S3 remains current-instance/material authorization. CF07's two bodies own producer/plan coverage and exact-byte final export/update consumption. P04 owns finished presentation extraction and mandatory gate. All depend on released interface/material artifacts rather than whole-job completion.

## Evidence limitations

No actual APK download/inspection/build, policy deployment, issuer-key access, isolated supervised execution, export race execution, replacement installation or physical run happened here. Historical S4 32 PASS/2 BLOCKED and S3 denial results retain their recorded scope. Installed authority was not observed. Complete PR review/thread and current-check audits were out of scope; no merge-readiness claim.

