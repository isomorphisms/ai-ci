# BC-K01 source coverage

Observed 2026-10-14. Read baseline REQUEST/AGENTS/shared-ai-ci instructions, the original K01 packet, and complete prior K04-S01–S04/T01-S03 bodies; P02/T01/A06 dependency identities were read from the prior manifest. Applied working-contract, intent-lock and split-work-jobs, with user-selected STAR/SUN Ultra.

## Reachable denominator and discussion depth

Kitchen all-state REST issue enumeration: page 1, per_page=100, 54 records; page 2 empty. Distinct totals: 21 issues, 33 pull requests. Branch enumeration: 20 + 17 + empty = 37. This is inventory coverage, not full source review of every record/branch.

Across these four Kitchen domains, full current bodies and every public issue comment were read for #1 (2/2), #5 (2/2), #9 (1/1), #10 (1/1), #14 (0/0), #15 (3/3), #24 (3/3), #26 (1/1), #30 (0/0), #37 (2/2), #43 (4/4): 11 issues, 19/19 declared comments. Each comments endpoint used per_page=100/page=1; returned cardinality matched the issue's declared count, with no hidden next page. K01's direct requirements are #1/#14/#9/#5/#26; other records informed owner deduplication.

Full bodies for Kitchen pull requests #27, #29, #31, #51, #52, #53, #54 were read. General comments: #31 1/1; others 0/0. Inline comments and review objects: seven endpoints each, all 0/0. Pull-request bodies were reconciled with actual live branches; #27/#29 metadata heads are historical. Other enumerated records were title/body inventory only, not full thread audits.

Direct sources: https://github.com/isomorphisms/kitchen/issues/1 ; https://github.com/isomorphisms/kitchen/issues/14 ; https://github.com/isomorphisms/kitchen/issues/9 ; https://github.com/isomorphisms/kitchen/issues/5 ; https://github.com/isomorphisms/kitchen/issues/26 . No original private transcript was recovered; issue summaries and comments remain attributed reports. Conversation-history denominator unknown.

## Exact source inspection

Main `5a00f0c498c93a6bcacbfc41ccbd320e5a1d2b16`: full AGENTS, `assumptions/README.md`, `preflight/terminal.md`, `systems/miro-a1-termux.md`, `tasks/source-handoff/{README.md,requirements.md,1.sh}`, `tests/source-handoff.sh`, `.github/workflows/{ib-handoff,native-transfer-handoff}.yml`, historical failure README specimens and task-tree inventory. Only repository-root AGENTS exists in the inspected main tree. The main diff from old packet ref was enumerated; source-handoff blobs remain unchanged.

Retained `repair/android-diagnostic-task@dd7b40f2d4ddc47c33d019f4a4caa68b059bdeaf`: full repaired A1 mirror, procedure wrapper/engine, qualification, prerequisites, registry and capture-v2 requirements. Retained `fp2/qualified-transfer-generator@933ec7974b7b06050fa107a6733a3d1698cabb87`: full candidate10 and compact requirements. These are source observations; their reported historical runtime results were not repeated.

New current candidates reviewed for overlap: isomorphisms/kitchen PR #53, “Qualify IB Linux source and native execution through Grease and Ike” (https://github.com/isomorphisms/kitchen/pull/53), `1a1c31236947ed3df50e94342276d1ae1280f986`, tree inventory and `tasks/ib-desktop/pipeline.grease`; isomorphisms/kitchen PR #54, “Prepare RHS hosted native acceptance commands” (https://github.com/isomorphisms/kitchen/pull/54), initially `add708cc25e11e62fd094c07863c63dd725738ba`, finally `3280a9f370d91298f959ffe0d367773ad74c799b`. Full `2.grease` was inspected; final compare adds only `detector.grease`, whose full added body was read. Positive RHS native execution remains pending in its body.

Final git remote refresh confirmed main, retained transfer/Android, FastChat and IB heads unchanged, and detected the RHS advance above. This is a sequence of observations, not an atomic multi-repository snapshot.

## Executed evidence and limits

Observed host: Ubuntu 24.04.3, Linux x86_64; sh/git/awk/sed/grep/mktemp/stat present. Exact clean main checkout ran `sh tests/source-handoff.sh`: exit 0, 27/27 named cases, including real disposable Git source materialization, repeat exact emissions, forged marker/nonzero child and parent survival. Engine Git blob `578e9d0fc7cfde015c9e66027e54cc014a3aa558`; suite blob `472b3b25e685fc3deb4a9ba45ec64804416c134f`; verified tree remained clean afterward. This is new host-source-seam evidence, not general preparation, Grease, Android, SDF or deployment acceptance.

CF107/131/123 full bodies/comments were read for cross-owner constraints (2/2,1/1,1/1). CF01 profile-source particulars were supplied by the sibling source audit and are dependency evidence, not Kitchen-run tests. No remote mutation, release, installation, device command or user credential operation occurred. New files here are complete proposed implementation jobs, not executed SUNs.
