# BC-FP01 source coverage

Refreshed 2026-10-14 UTC. Scope is this domain's six-domain FP research, not an account census or exhaustive history recovery. Original packet baseline/jobs/BC-FP01.md, baseline/REQUEST.md, baseline/AGENTS.md, shared ai-ci instructions, baseline wave1 index/overlap and the four full shared-controller SUNs were read. Working-contract, intent-lock and split-work-jobs were applied; explicit STAR/SUN Ultra selection overrides role defaults.

## Reachable discovery denominator

- One all-state issue search returned 87 issue bodies; one all-state PR search returned 43 PR bodies, each below requested100. These are accessible search results, not atomic totals or full audits of all130 records. Full deep-read scope is22 selected issue bodies +30 comments across the six FP domains, and13 selected PR bodies/diffs plus their discussion reads. Current new work120–130 was screened before splitting.
- Branch search returned48 names then an empty terminal page (cursor NDg→null). Thirteen relevant main/retained refs were resolved with live commit reads, not closed PR metadata. Full PR discussion tools reported0 discussion records for each of the13; review-thread calls likewise returned0. The all-page comment/file tools provide complete supported aggregation but do not expose HTTP page counts. Review-thread pagination is not exposed; zero returned rows is the observable coverage.
- Filename enumeration used all-page tool for11 selected PRs; full diff/body reads covered13. The519 changed paths of the merged transfer candidate and185 of IB include many receipts; listing those paths is not a claim of reading every artifact byte.
- Source snapshots are in ../FP01/source-cache (32 fetched FP files,22 complete issue/comment documents,13 PR body/current-ref records) and FP06/source-cache for the Young Tableaux workflow. Shared current ai-ci cache is ../source-cache/ai-ci/949a60dad5e014cafce2c49619df9bbdbcfaafc0; full AGENTS/README/failure-ledger/research were read, with source history explicitly reconstructed rather than verbatim original transcripts.

## Domain issue/discussion coverage

| Issue | Full returned comments |
| --- | ---: |
| [isomorphisms/flexible-pipes#24](https://github.com/isomorphisms/flexible-pipes/issues/24) | 5 |
| [isomorphisms/flexible-pipes#26](https://github.com/isomorphisms/flexible-pipes/issues/26) | 2 |
| [isomorphisms/flexible-pipes#35](https://github.com/isomorphisms/flexible-pipes/issues/35) | 6 |
| [isomorphisms/flexible-pipes#73](https://github.com/isomorphisms/flexible-pipes/issues/73) | 1 |
| [isomorphisms/flexible-pipes#79](https://github.com/isomorphisms/flexible-pipes/issues/79) | 8 |

Domain denominator: 5 selected full issue bodies and 22 returned comments; shared issues overlap other domains and must not be summed as unique coverage.

## Retained/current candidates

| Candidate | Live branch/head | Evidence scope |
| --- | --- | --- |
| [isomorphisms/flexible-pipes PR #31, “Implement registered Kitchen script execution and preserve FP2 qualification attempts”](https://github.com/isomorphisms/flexible-pipes/pull/31) | implement/fp2-runtime-qualification @ 442a33bfd36a23df3d757d17a31b8084cab21a38 | Candidate source; not installed promotion |
| [isomorphisms/flexible-pipes PR #117, “Repair C67 transfer bootstrap and durable execution checks”](https://github.com/isomorphisms/flexible-pipes/pull/117) | repair/c67-single-transfer-generator-read-20261013 @ d3107814d495e0ae1248e3287575bab323fc8109 | Merged source; runtime claims remain scoped |
| [isomorphisms/flexible-pipes PR #128, “Register exporter acceptance”](https://github.com/isomorphisms/flexible-pipes/pull/128) | repair/exporter-registered-acceptance @ a5ca40e20656066cee856e060baff5f352713909 | Candidate source; not installed promotion |
| [isomorphisms/flexible-pipes PR #126, “FC-M1–M5: record execution envelope and qualified evidence boundaries”](https://github.com/isomorphisms/flexible-pipes/pull/126) | work/fc-m1-m5-envelope-20261014 @ 2a29e8d5d689f38575a1f1952b67d5dec4a85b6e | Candidate source; not installed promotion |
| [isomorphisms/flexible-pipes PR #129, “Admit RHS SUN jobs and route independent acceptance through Kitchen”](https://github.com/isomorphisms/flexible-pipes/pull/129) | sun/rhs-autonomous-execution @ 40ea03ce88666d98490bcc2ad4138a7e214b7f58 | Candidate source; not installed promotion |
| [isomorphisms/flexible-pipes PR #130, “Execute and retain the IB Linux first-wave qualification”](https://github.com/isomorphisms/flexible-pipes/pull/130) | work/ib-linux-first-wave @ 0a71b84eefebb14254117b04dedbd4073762dc23 | Candidate source; not installed promotion |

## Exact files and boundaries inspected

- [README.md](https://github.com/isomorphisms/flexible-pipes/blob/b7f944b1391a8a2ea96ee07f6b9c0431311842b0/README.md) at b7f944b1391a8a2ea96ee07f6b9c0431311842b0: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [.github/workflows/run-pipeline.yml](https://github.com/isomorphisms/flexible-pipes/blob/b7f944b1391a8a2ea96ee07f6b9c0431311842b0/.github/workflows/run-pipeline.yml) at b7f944b1391a8a2ea96ee07f6b9c0431311842b0: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [scripts/run-pipeline](https://github.com/isomorphisms/flexible-pipes/blob/b7f944b1391a8a2ea96ee07f6b9c0431311842b0/scripts/run-pipeline) at b7f944b1391a8a2ea96ee07f6b9c0431311842b0: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [scripts/github-transfer-stage-zero.sh](https://github.com/isomorphisms/flexible-pipes/blob/b7f944b1391a8a2ea96ee07f6b9c0431311842b0/scripts/github-transfer-stage-zero.sh) at b7f944b1391a8a2ea96ee07f6b9c0431311842b0: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [scripts/github-transfer-session.grease](https://github.com/isomorphisms/flexible-pipes/blob/b7f944b1391a8a2ea96ee07f6b9c0431311842b0/scripts/github-transfer-session.grease) at b7f944b1391a8a2ea96ee07f6b9c0431311842b0: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [tasks/catfood-fp-kitchen/SUN-FP-EXECUTION-01.txt](https://github.com/isomorphisms/flexible-pipes/blob/b7f944b1391a8a2ea96ee07f6b9c0431311842b0/tasks/catfood-fp-kitchen/SUN-FP-EXECUTION-01.txt) at b7f944b1391a8a2ea96ee07f6b9c0431311842b0: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [docs/registered-execution-v1.md](https://github.com/isomorphisms/flexible-pipes/blob/442a33bfd36a23df3d757d17a31b8084cab21a38/docs/registered-execution-v1.md) at 442a33bfd36a23df3d757d17a31b8084cab21a38: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [scripts/registered-execution.pi](https://github.com/isomorphisms/flexible-pipes/blob/442a33bfd36a23df3d757d17a31b8084cab21a38/scripts/registered-execution.pi) at 442a33bfd36a23df3d757d17a31b8084cab21a38: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [scripts/registered-execution.pi](https://github.com/isomorphisms/flexible-pipes/blob/a5ca40e20656066cee856e060baff5f352713909/scripts/registered-execution.pi) at a5ca40e20656066cee856e060baff5f352713909: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [docs/exporter-acceptance.md](https://github.com/isomorphisms/flexible-pipes/blob/a5ca40e20656066cee856e060baff5f352713909/docs/exporter-acceptance.md) at a5ca40e20656066cee856e060baff5f352713909: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [.github/workflows/exporter-acceptance-qualification.yml](https://github.com/isomorphisms/flexible-pipes/blob/a5ca40e20656066cee856e060baff5f352713909/.github/workflows/exporter-acceptance-qualification.yml) at a5ca40e20656066cee856e060baff5f352713909: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [tasks/fastchat/outcomes.tsv](https://github.com/isomorphisms/flexible-pipes/blob/2a29e8d5d689f38575a1f1952b67d5dec4a85b6e/tasks/fastchat/outcomes.tsv) at 2a29e8d5d689f38575a1f1952b67d5dec4a85b6e: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.
- [tasks/ib-desktop/README.md](https://github.com/isomorphisms/flexible-pipes/blob/0a71b84eefebb14254117b04dedbd4073762dc23/tasks/ib-desktop/README.md) at 0a71b84eefebb14254117b04dedbd4073762dc23: source inspection; large controller reads focus on admission, plan, cached-result, stage/recovery and effect boundaries.

Main live identity: repository1405888814, isomorphisms/flexible-pipes, main@b7f944b1391a8a2ea96ee07f6b9c0431311842b0. FP31 closed snapshot1fbe5d3373c983aeecbe355e23d9f12e6737b41d differs from live442a33bfd36a23df3d757d17a31b8084cab21a38; FP33 snapshotfc4443f27ae11dcae32ab62d62f510812be9a57d differs from live86c2d16f634eb73e0e338f2531827d1ea040b037. These distinctions were preserved.

## Executed evidence and limits

This STAR performed source/API reads and authored packets, not product implementation, build, model inference, deployment, transport or device tests. Remote workflow metadata is observed evidence; detailed test counts remain source/report-attributed unless independently read. For FP127, exact source workflow explicitly checks out head; returned PR runs38566286188/38566286410/38566286692 all completed success. For FP128, first observation had Kitchen38572058642 in progress; final one-time refresh reports it and exporter38572058686 completed success, with all six returned PR workflows successful. First-page workflow APIs do not expose other event runs or full account history. No synthetic checkout is relabeled as head evidence.

Readiness still separates actual qualified C++-free runtime, current accepted owner material, installed trust and physical evidence. Retained historical C++ host runs cannot release Cat Food131. Missing platform acknowledgement, host isolation or hardware blocks only its exact lane. No private history corpus or private artifact was downloaded; public source snapshots are not original conversation transcripts. No remote mutations occurred.

Concrete absent path: tasks/catfood-fp-kitchen/source-material.tsv returned404 at exact main; AGENTS.md also returned404, so shared current ai-ci and baseline campaign instructions apply. Initial guessed job filename/case and paired build path404s were corrected from the observed PR filename enumeration; no absence claim relies on those guesses.

