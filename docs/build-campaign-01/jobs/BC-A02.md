# BC-A02 — Execute independent oracles and qualify the acceptance machinery

1. **Identity:** STAR, Ultra; owner isomorphisms/ai-ci; parent [STAR BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [issue 171](https://github.com/isomorphisms/ai-ci/issues/171). Emit bounded SUN implementation assignments.

2. **Outcome:** Required acceptance must execute independently specified expectations against the named implementation, kill representative incorrect variants, and retain disagreement. Green manifest validation must never certify oracle soundness.

3. **Intent:** Issue 171's September 28 audit separates observation, evidence validity, diagnosis and disposition; its M01–M26 corpus distinguishes designed cases from executed regressions. [Issue 183](https://github.com/isomorphisms/ai-ci/issues/183) requires human-confirmed flaws to seed broader investigation. Hash equality binds bytes, not correctness.

4. **Evidence:** AICI main is [3d174000649f9f828c29e6be981cfd0e60646014](https://github.com/isomorphisms/ai-ci/tree/3d174000649f9f828c29e6be981cfd0e60646014). Read AGENTS.md and its required documents, docs/evaluation-protocol.md, evals/README.md, evals/cases.tsv and contracts/evaluation-case-v0.contract.tsv. The semantic runner remains future work in main. Existing independent host evidence is preserved in [isomorphisms/ai-ci PR #247, “SUN T1: independently reject Holomorphic polynomial mutants with AICI reference”](https://github.com/isomorphisms/ai-ci/pull/247), head 53b705630d1816f2f43659d0a9cd4241bc734734.

5. **Reuse:** Continue that branch's tests/semantic-oracles/holomorphic-t1/, validators/verify_semantic_mutants.sh and incident ledger. It records good=1, killed=5, survived=0 and eleven rejected receipt mutations against Holomorphic 7041b262c553e295b9769ebb84b7cb626e2ce50e. Requalify these results; do not regenerate the completed initial oracle.

6. **Scope:** AICI owns reusable meta-acceptance. Consumer repositories retain mathematical/application semantics. BC-A05 owns fleet propagation; BC-A04 owns failure-stage reporting. No new general test framework or application redesign.

7. **Readiness:** READY_TO_INVESTIGATE. Refresh both exact heads and retained execution artifacts. Protect the independent expectations from candidate modification; consumer migration waits for an agreed acceptance interface.

8. **Work:** Emit four SUNs: execute the remaining useful language-neutral meta-corpus; enforce oracle/material/selected-case provenance; integrate disagreement and invalid-evidence handling with existing receipts; adopt the gate in one actual consumer through FP. Separate deterministic checks from grounded semantic judgment and identify the smallest necessary protected corpus.

9. **Acceptance:** Require good and independently broken implementations, omitted/empty/never-run cases, copied passing logs, wrong executable, circular oracle and order-permutation controls. Benign renaming and case ordering preserve judgments. Exact recorded replay is repeatable; fresh inference is separately measured. A receipt-valid but semantically wrong result must fail.

10. **Limits:** Existing Holomorphic evidence proves bounded host CPU semantics, not CPU sampling-policy intent, generated GPU shader behavior, physical A1 acceptance, arbitrary generator quality or mandatory deployed FP routing.

11. **Continuation:** Deliver decision/evidence, complete SUN texts, dependency order, precise next actions and canonical issue updates. Return contradictory independent outputs for STAR adjudication without automatically privileging implementation or test.

12. **Authority:** Research and durable handoffs only here; no merge, closure, release, deployment activation or dispatch.

END OF BC-A02
