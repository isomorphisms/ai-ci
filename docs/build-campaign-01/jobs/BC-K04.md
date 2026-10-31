# BC-K04 — Preserve resources, partial state and the human session

1. **Identity/execution:** STAR, Ultra; owner `isomorphisms/kitchen`; parent [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [Kitchen #11](https://github.com/isomorphisms/kitchen/issues/11); related [#2](https://github.com/isomorphisms/kitchen/issues/2) and [#24](https://github.com/isomorphisms/kitchen/issues/24).

2. **Outcome:** Maintained handoffs preserve the human's shell, files, checkout and recoverable operation state through resource exhaustion, malformed input, interruption and retry. Refusal names the failed boundary without a destructive “repair.”

3. **Recovered intent:** September mailbox near-miss evidence requires explicit copy/move effects and disposable recovery tests; no mail loss was established. October source-handoff requirements prohibit checkout resets and parent-shell termination. Transfer history requires identity-bound reruns rather than blindly repeating accepted requests.

4. **Current evidence:** [main df14daf8cc612283ea210f206f0097a31db122a0](https://github.com/isomorphisms/kitchen/tree/df14daf8cc612283ea210f206f0097a31db122a0) has `tasks/source-handoff/1.sh`, `tests/source-handoff.sh`, `tasks/ib-durable-store/requirements.md` and exact-head `.github/workflows/ib-handoff.yml`. Tests cover spaces, quotes, stale/partial checkouts, dirty files and errexit-parent survival. That is specific coverage, not a complete storage/exhaustion matrix.

5. **Reuse:** [retained transfer source 933ec7974b7b06050fa107a6733a3d1698cabb87](https://github.com/isomorphisms/kitchen/tree/933ec7974b7b06050fa107a6733a3d1698cabb87) records the mode-0777 counterexample and ownership/0700 repair in `evidence/fp-control-02/private-state-repair/`. Preserve it. [#11's existing update](https://github.com/isomorphisms/kitchen/issues/11#issuecomment-6016697793) reports mbox fsync/interruption qualification; do not duplicate its transaction engine.

6. **Scope/ownership:** Kitchen owns preparation, temporary-state lifecycle and session protection. Cat Food supplies storage/runtime facts; mbox and other producers own data durability. BC-K02 consumes these controls; BC-K05 owns truthful failure propagation. Carry Idriç-first, Grease-first and checked-Ithon conventions into SUN jobs; preserve numbered attempts.

7. **Prerequisites/readiness:** READY for source audit and disposable host work. Re-read task contracts and owner recovery semantics. Runtime-dependent execution requires an eligible implementation under [Cat Food #131](https://github.com/isomorphisms/catfood/issues/131). Actual target free-space/mount facts remain target-specific.

8. **Work:** Emit four SUN jobs: close observed scratch/extraction/output resource gaps in maintained handoffs; reconcile secure partial-state handling across retained and current transfer paths; strengthen interruption/retry/session preservation with owner-defined recovery; wire representative source-test and transfer consumers into existing CI. Assign overlapping generator edits once and provide BC-K02 the settled interface.

9. **Acceptance:** Successful runs and safe retries preserve unrelated files, HEAD, cwd and parent options. Inject unavailable scratch, short writes, exhausted capacity, malformed arguments, symlink/shared state and interruption; reject before prohibited effects and retain recoverable state. Accept benign spaces, quotes, sufficient constrained capacity and valid cached completion. Compare before/after state independently; do not infer crash safety or exactly-once behavior from exit status.

10. **Evidence limits:** Disposable filesystem results do not prove SDF locking, Android mount behavior, physical storage or live mailbox acceptance. Historical repairs remain scoped to their exact bytes.

11. **Completion/continuation:** Record case-to-owner coverage, fully written SUN jobs, dependencies, verified commands and exact next actions. Escalate incompatible recovery semantics to STAR; preserve unrelated runnable work.

**12. Authority:** Investigate, perform bounded disposable qualification needed to settle this domain, and create SUN issue/file records and reviewable draft PRs. SUN jobs must implement and verify their assigned scope. No merge, closure, release, managed-system installation, deployment activation, recurring schedule or actual Work dispatch is inferred.

END OF BC-K04
