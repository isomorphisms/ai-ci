# BC-A04 — Preserve the actual failing stage through wrappers and reports

1. **Identity:** STAR, Ultra; owner isomorphisms/ai-ci; parent [STAR BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [issue 171](https://github.com/isomorphisms/ai-ci/issues/171). This is the failure-classification mechanism, separate from BC-A02's oracle mechanism.

2. **Outcome:** Every required task retains its actual exit/result, stage, target, selected cases and retry history. A later wrapper, upload or reporting success cannot erase failure; an unrelated infrastructure failure cannot falsely condemn demonstrated product behavior.

3. **Intent:** Issue 171 and docs/failure-ledger.md preserve the historical Grease checkout-before-test failure, native-pad unrelated-process crash and publication-query false success. Observation, evidence validity, diagnosis and disposition remain separate; proposed labels are not an already implemented universal schema.

4. **Evidence:** AICI main [3d174000649f9f828c29e6be981cfd0e60646014](https://github.com/isomorphisms/ai-ci/tree/3d174000649f9f828c29e6be981cfd0e60646014), AGENTS.md, required documents and docs/evaluation-protocol.md explicitly retain these boundaries. Existing src/aici.c runtime fixtures, ingestion/ staged receipts, host-context/ and merge/state.sh supply partial mechanisms; the ledger does not claim a generic executable classifier.

5. **Reuse:** Live consumer heads remain IB 10fa7bbe93ff9ffa1ba7b9f62e0dd8f6c10a86bc, Toki ef55a23acd94cc501e7a0d5e44ab01296b881c30 and Fourier ac0e9b40a556012b42be240f1c32c88370028b4a. [IB 119](https://github.com/isomorphisms/ib/issues/119) owns exact-text.yml pipeline masking; [Toki 11](https://github.com/place-of-honor/learn-toki-pona/issues/11) owns the ineffective forbidden-content check; [Fourier 31](https://github.com/isomorphismes/Fourier-sound/issues/31) owns discarded startup self-test results. Continue their existing assignments.

6. **Scope:** AICI owns reusable verdict semantics and independent controls; FP records actual execution; consumers repair their own stages. BC-A07 handles source parsing, and BC-A05 handles generator-cause propagation.

7. **Readiness:** READY_TO_INVESTIGATE. Refresh actual source, shell defaults, callers and maintained deployment targets. Host controls can proceed without physical Android access; runtime claims require their own artifact/target receipts.

8. **Work:** Emit four SUNs: settle and implement stage-preserving normalization; retain subprocess/pipe/timeout/cancellation results in existing execution receipts; qualify consumer-specific status repairs; enforce truthful aggregate completion and retained failed retries.

9. **Acceptance:** Execute an oracle printing every expected line then exiting seven, failing compiler with plausible output, omitted test, timeout, interruption and upload-only failure. Reject each at the intended stage. Preserve unrelated-process noise and successful optional cleanup as benign controls. Replaying identical observations yields identical verdicts; later success never rewrites failed history.

10. **Limits:** Source-confirmed IB/Fourier gaps are not executed Android failures. Toki's historical isolated mutation is not a mutated full APK workflow. CPU rasterization is not GPU computation.

11. **Continuation:** Return complete SUN packets, causal evidence, dependency order, next actions and exact issue updates. Escalate only when new observations contradict the agreed stage semantics.

12. **Authority:** No implementation in this STAR; no merge, closure, release, deployment, device mutation or dispatch.

END OF BC-A04
