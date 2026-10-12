# BC-A07 — Make workflow source checks cover the actual committed execution

1. **Identity:** STAR, Ultra; owner isomorphisms/ai-ci; parent [STAR BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [issue 168](https://github.com/isomorphisms/ai-ci/issues/168), with [issue 2](https://github.com/isomorphisms/ai-ci/issues/2) source-integrity obligations.

2. **Outcome:** Material production changes must reach required acceptance on the exact committed source. Comments, disabled steps, delegated producer omissions, synthetic checkouts and validation-time source repair cannot masquerade as executed protection.

3. **Intent:** Issue 168's September 28 parser counterexamples distinguish source policy from runtime failure propagation. Issue 2 forbids CI completing missing compiler source changes. Preserve legitimate generated-artifact comparisons and integration tests with honest scope.

4. **Evidence:** AICI [main 3d174000649f9f828c29e6be981cfd0e60646014](https://github.com/isomorphisms/ai-ci/tree/3d174000649f9f828c29e6be981cfd0e60646014) retains divergent merge/check-workflow-head.sh AWK matching and src/aici.c parsing. The former accepts matching text anywhere in an active checkout block; yaml_run_not_contains uses substring checking. contracts/workflow-integrity-v0.contract.tsv, tests/merge-workflow-head.sh and tests/fixtures/workflow-* expose current boundaries. Read AGENTS.md and required documents first.

5. **Reuse:** Reconcile existing parser work rather than replacing both with a second policy engine. [Idriç 103](https://github.com/isomorphisms/Idric/issues/103) is partly stale: at current 2734ac5a86610eddfab73b1644d72b4ac85a65ee all four named workflows now declare exact head. Preserve this repair; independently verify style comparison-base semantics and execution before retiring any obligation.

6. **Scope:** AICI owns shared supported syntax, diagnostics, source identity and trigger coverage; leaves own critical paths and actual workflow wiring. BC-A04 owns process-result semantics; #175 owns selected toolchain qualification. No arbitrary-shell-proof claim or consumer application redesign.

7. **Readiness:** READY_TO_INVESTIGATE. Refresh branches, parser fixtures, action pins, delegated actions and exact consumer source. Enumerate production, oracle, workflow and dependency inputs; unsupported syntax must remain explicit rather than pass by omission.

8. **Work:** Emit four SUNs: unify supported checkout/YAML parsing; separate lexical policy from behavioral status checks; bind before/after tracked-source integrity to reported head; audit and repair actual consumer trigger/delegated-call coverage. Requalify retained fixes before assigning further edits.

9. **Acceptance:** Reject comment-only ref, wrong checkout, quoted-key swallowed failure, duplicate keys, disabled required steps, hidden delegate and source-patching validator. Accept harmless quoted operator text without a false behavioral diagnosis and correctly committed generated outputs. A multi-commit PR must compare the full intended base. Demonstrate that material production changes trigger actual selected cases; irrelevant changes do not alter deterministic source judgments.

10. **Limits:** Source configuration proves eligibility and declared wiring, not that a workflow ran, toolchain executed, artifact worked or device passed. Preserve exact-head versus synthetic integration evidence.

11. **Continuation:** Return decision/evidence, full SUN jobs, supported-syntax boundary, consumer dispositions, dependencies, next actions and issue updates. Escalate genuinely unsupported semantics without weakening acceptance.

12. **Authority:** No merge, closure, release, deployment activation or dispatch.

END OF BC-A07
