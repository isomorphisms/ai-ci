# BC-K05 — Preserve the real failing stage through wrappers and pipelines

1. **Identity/execution:** STAR, Ultra; owner `isomorphisms/kitchen`; parent [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [Kitchen #10](https://github.com/isomorphisms/kitchen/issues/10); reporting counterpart [#9](https://github.com/isomorphisms/kitchen/issues/9).

2. **Outcome:** Required setup, subprocess, pipeline and postcondition failures remain visible through the maintained human command and consumer receipt. A surviving parent session or successful cleanup cannot become operation PASS.

3. **Recovered intent:** #10 records the repaired historical Grease wrapper that returned success before required tests ran. September symbol-check evidence also records false rejection when an early successful reader caused producer broken pipe. Correct propagation must distinguish these mechanisms.

4. **Current evidence:** Inspected [main df14daf8cc612283ea210f206f0097a31db122a0](https://github.com/isomorphisms/kitchen/tree/df14daf8cc612283ea210f206f0097a31db122a0): `bad-script-examples/{false-green-wrapper,grep-q-pipefail-broken-pipe,missing-input-counted-as-pass}/`, `tasks/source-handoff/1.sh`, `tests/source-handoff.sh`, and `.github/workflows/ib-handoff.yml`. Source handoff already requires zero status plus exact marker, prefixes untrusted output, and rejects success text from a nonzero child. Its outer conditional intentionally survives failure.

5. **Reuse:** Retained `repair/android-diagnostic-task@dd7b40f2d4ddc47c33d019f4a4caa68b059bdeaf` already tests partial nonzero output, timeouts and owner-validation failures. Main transfer candidate `tasks/github-repository-transfer/6.ysh` separates API status from response-body capture after actual Grease failures. Requalify these implemented cases; do not announce historical bugs as newly unresolved.

6. **Scope/ownership:** Kitchen owns wrapper and served-command semantics; ai-ci owns independent result validity; Grease owns shell implementation; FP owns worker/registered execution. BC-K04 owns state preservation. No replacement process framework. Carry Idriç-first, Grease-first and checked-Ithon conventions into SUN jobs; preserve numbered attempts.

7. **Prerequisites/readiness:** READY_STAR and source/corpus work. Refresh actual task interfaces and expected-stage lists. Runtime execution must respect [Cat Food #131](https://github.com/isomorphisms/catfood/issues/131): existing C++-Grease workflow artifacts are historical evidence, not an eligible new managed installation.

8. **Work:** Emit four SUN jobs: enforce required-stage execution and source identity in maintained wrapper receipts; repair uncovered subprocess/pipeline propagation using the selected interpreter's actual semantics; preserve timeout/interruption/partial-output classification through Kitchen adapters; integrate result consumption in existing handoff tests and CI so parent survival cannot hide failure. Reuse existing bounded helper and owner protocol.

9. **Acceptance:** Complete real fixture execution passes. Setup failure before any task, missing task record, stale prior PASS, failing producer with successful tail/tee, forged success text and interrupted child fail for their intended reasons. Benign empty optional output and successful early-reader semantics remain supported where the contract permits them. Independently observe attempted stages, exits and postconditions; prove every selected control executed.

10. **Evidence limits:** Host wrappers do not prove physical execution, application behavior or active FP deployment. Equal report bytes do not establish equal underlying effects.

11. **Completion/continuation:** Save the failure-semantics decision, complete SUN jobs, case coverage, dependency order and exact next commands. Escalate interpreter contradictions to the owning project; keep unrelated implementation slices runnable.

**12. Authority:** Investigate, perform bounded disposable qualification needed to settle this domain, and create SUN issue/file records and reviewable draft PRs. SUN jobs must implement and verify their assigned scope. No merge, closure, release, managed-system installation, deployment activation, recurring schedule or actual Work dispatch is inferred.

END OF BC-K05
