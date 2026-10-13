# BC-K04 source coverage

Inspection date: 2026-10-13. Reachable scope is the Kitchen resource/session domain, not a complete account backlog inventory. Direct repository reads are authoritative source observations; issue descriptions are attributed reports.

## Immutable source sets

| Repository/ref | Read sources | Purpose |
|---|---|---|
| [ai-ci campaign c28ae588ec9699a374ecd59c5392691623b78a51](https://github.com/isomorphisms/ai-ci/tree/c28ae588ec9699a374ecd59c5392691623b78a51/docs/build-campaign-01) | `REQUEST.md`, `jobs/BC-K04.md`, `jobs/BC-K02.md`, `jobs/BC-K05.md` | Required 12 fields, implementation scope, division of ownership, runtime correction, retained work. |
| [ai-ci main 3d174000649f9f828c29e6be981cfd0e60646014](https://github.com/isomorphisms/ai-ci/tree/3d174000649f9f828c29e6be981cfd0e60646014) | `AGENTS.md`, `README.md`, `docs/failure-ledger.md`, `research/llm-failure-modes.md` | Current shared requirements: exact evidence, independent controls, host context, required execution, no language substitution. Main resolved during inspection; no code changed. |
| [Kitchen main df14daf8cc612283ea210f206f0097a31db122a0](https://github.com/isomorphisms/kitchen/tree/df14daf8cc612283ea210f206f0097a31db122a0) | `AGENTS.md`, `README.md`, `user/{filesystem,shell-style}.md`, `shells/grease-ysh.md`, `systems/README.md`, `preflight/terminal.md` | Local mandatory flow, preserve numbered attempts, target facts, exact program, correct session. |
| Same Kitchen main | `tasks/source-handoff/{1.sh,requirements.md,README.md}`, `tests/source-handoff.sh`, `tasks/ib-durable-store/{2.sh,requirements.md,README.md}` | Actual manifest/extraction/session mechanisms, source boundary, known repairs, IB integration contract. |
| Same Kitchen main | `tasks/github-repository-transfer/{README.md,HOW-TO-MOVE-A-GITHUB-REPOSITORY-TO-ANOTHER-ORGANIZATION.md,6.ysh,render-standalone-github-repository-organization-transfer.ysh}`, `tests/github-repository-transfer-grease.sh` | Actual current generator/candidate and test coverage; older README's POSIX instruction is superseded by AGENTS and canonical procedure. |
| Same Kitchen main | `.github/workflows/{ib-handoff,github-repository-transfer}.yml`, `tasks/sdf-spec-list-refile/README.md` | Existing CI coverage; disallowed current C++ runtime selection; existing SDF gate ownership. |
| [Kitchen retained 933ec7974b7b06050fa107a6733a3d1698cabb87](https://github.com/isomorphisms/kitchen/tree/933ec7974b7b06050fa107a6733a3d1698cabb87) | `tasks/github-repository-transfer/{README.md,generate-transfer-github-repository-script.sh,10.grease,10.NOTES.md,compact-handoff-requirements.md}`, `tests/qualify-transfer-artifact.pi`, `evidence/fp-control-02/private-state-repair/README.md` | 0700 repair, deterministic generation, independent API events, pending-state retention, source audit of unsafe-path coverage and direct final writes. |
| [Kitchen retained 4208115cfa2204adc8c883cb19c32d838aca4008](https://github.com/isomorphisms/kitchen/tree/4208115cfa2204adc8c883cb19c32d838aca4008) | `tasks/sdf-spec-list-refile/{README.md,requirements.md,gate.py}`; recursive tree | Owner recovery and exact wrapper/argument/corpus binding. Other named wrapper/test paths discovered via tree and gate, not independently executed. |

Main and retained recursive trees were collected. Kitchen branches collection returned 29 entries in one 100-entry page; `fp2/qualified-transfer-generator` still resolves to the retained SHA. This is branch coverage, not issue coverage.

## Issue and discussion coverage

| Record | Full bodies / comments observed | Disposition |
|---|---|---|
| [Kitchen #11](https://github.com/isomorphisms/kitchen/issues/11) | Body; 2/2 comments, latest 2026-10-12 16:45:34 UTC | Canonical K04. Original near miss and owner recovery report retained. |
| [Kitchen #2](https://github.com/isomorphisms/kitchen/issues/2) | Body; 0 comments | Paths require observed host state; no generic layout repair. |
| [Kitchen #24](https://github.com/isomorphisms/kitchen/issues/24) | Body; 2/2 comments, latest 2026-10-06 02:50:26 UTC | Historical missing-checkout/testing flaws; later current source supersedes historical CI-absence claim. |
| [Cat Food #131](https://github.com/isomorphisms/catfood/issues/131) | Body including October 10 no-C++ correction; 1/1 comments | Runtime eligibility remains a concrete conditional execution gate. The body correction outranks the earlier implementation comment. |
| [isomorphisms/kitchen PR #31, “Bind SDF filing handoffs to exact tested bytes and intent”](https://github.com/isomorphisms/kitchen/pull/31) | PR body/current metadata; head 4208115cfa2204adc8c883cb19c32d838aca4008, closed | Retained source was inspected; no live/SDF qualification inferred. |
| [isomorphisms/mbox PR #1, “Rigorously test disposable mailbox filing, fidelity and recovery”](https://github.com/isomorphisms/mbox/pull/1) | PR body/current metadata; head 4d4245ea625a8b15afba218d57a8e61376d07451, closed | Reported disposable recovery evidence only; no new mbox execution. |

Directly reviewed issue bodies: 4. Issue comments collected: 5/5 according to returned totals, each list fits one page. PR metadata/bodies: 2. No issue or PR writes, live transfers, merges or installations occurred. No claim of a full PR discussion/review audit.

## Recovered requirements and evidence classes

| Requirement | Source/date | Type | Later correction/current disposition |
|---|---|---|---|
| Copy/move/source roles and disposable recovery must be explicit | Kitchen #11, September 29 incident recorded in body | Historical repository report | No proven data-loss claim; mbox owns transaction engine. |
| Correct paths, preserve valid files and supported symlinks | Kitchen #2, September 29–30 | Historical repository report | Symlink acceptance is task-specific; private transfer-state symlinks are separately disallowed. |
| Preserve checkout and parent session | Main source requirements and tests, October source handoff | Source contract plus executed baseline | 27 current source cases passed; resource controls remain missing/unexecuted. |
| Private state means owner plus 0700, not mkdir alone | Retained repair README, October 8-era branch | Historical executed-evidence report and current source | Preserve bad mode-0777 fixture and positive twin; broaden only uncovered nested/file-kind/resource boundaries. |
| Exact generated bytes, every attempted POST, pending retry bound to identity | Kitchen #24 comments and retained generator/tests | Source plus historical reports | K04 preserves resource state; K02 owns complete identity/interface reconciliation. |
| Native runtime is not synonymous with C++ | Cat Food #131 October 10 human correction in issue | Explicit correction reported in owner record | C++ artifact remains in current workflow but cannot release new runtime qualification. |
| Parent survival cannot mean operation success | Source README, compact requirements, BC-K05 | Source contract | K04 preserves session; K05 owns truthful stage result interface. |

## Executed evidence and unexecuted controls

Authoritative baseline: disposable Linux 6.18.44 x86_64; exact source/test Git blobs `578e9d0fc7cfde015c9e66027e54cc014a3aa558` and `472b3b25e685fc3deb4a9ba45ec64804416c134f`. Existing `tests/source-handoff.sh` returned exit 0 and “source handoff regression cases: 27 passed.” The suite covers its own synthetic Git/source fixtures; it is not IB implementation acceptance.

New capacity, short-write, nested-state and reached-interruption cases: NOT_RUN. Grease transfer acceptance: NOT_RUN, eligible runtime unresolved. No managed runtime installation attempted. Personal Context was queried and returned unavailable; recovered issue reports are not represented as original chat transcripts.

## Case ownership and handoff inventory

| Required case family | Implementation owner | Independent observers / controls |
|---|---|---|
| Scratch, manifest, extraction, output capacity | S01 | Required file-list oracle; reached fault; no accepted incomplete emission; sufficient-capacity twin; checkout/state snapshots. |
| Shared/symlink/nested state, partial cache, output collision | S02 | File kinds/UID/modes/bytes; acquisition/API counts; private valid/cache twin; preserve unrelated files. |
| Interruption and retry/session state | S03 | Reached transition record, independent POST count, owner recovery inventory, parent options/cwd/variables; valid retry twins. |
| Exact artifact and consumer/workflow bypass | S04 | Generated-byte hashes, exact-head run, executed case inventory, stale/bypass mutant, positive actual consumer. |
| Complete transfer parameters/identity/client adoption | BC-K02 retained STAR | Consumes K04 resource contract; not duplicated here. |
| Required-stage and timeout/result classification | BC-K05 retained STAR | Consumes K04 interruption witnesses; not duplicated here. |
| Mailbox fsync/journal/source replacement | mbox existing owner | Existing transaction corpus; no new engine in Kitchen. |

END OF BC-K04 SOURCE COVERAGE
