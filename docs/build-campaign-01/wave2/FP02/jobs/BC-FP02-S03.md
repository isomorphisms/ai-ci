# BC-FP02-S03 — Preserve attempt history and revalidate recovery before renewed effects

**1. Identity and execution:** SUN / Ultra; owner `isomorphisms/flexible-pipes`; parent BC-FP02 and [campaign239](https://github.com/isomorphisms/ai-ci/issues/239); canonical [FP14](https://github.com/isomorphisms/flexible-pipes/issues/14), dependency [FP15](https://github.com/isomorphisms/flexible-pipes/issues/15).

**2. Outcome:** Interrupted, repeated and overlapping registered attempts retain their actual first failure and effect history. Recovery verifies current state/material before reusing acceptance or repeating an external operation.

**3. Recovered intent:** Lost responses require independent postcondition inspection; local journals do not imply exactly-once effects. Historical replay can remain valid while current admission is revoked. Preserve parent sessions and unrelated user files.

**4. Current evidence:** Live `implement/fp2-runtime-qualification@442a33bfd36a23df3d757d17a31b8084cab21a38` already implements atomic records, request locks, unique worker UIDs, watchdogs and `validate_cached_result`. It rejects stale release, request/control/evidence/authority/checks/artifacts. [isomorphisms/flexible-pipes PR #128, “Register exporter acceptance”](https://github.com/isomorphisms/flexible-pipes/pull/128) at `a5ca40e20656066cee856e060baff5f352713909` preserves and extends those paths. Main `b7f944b1391a8a2ea96ee07f6b9c0431311842b0` adds durable transfer POST protection through owner procedures.

**5. Reuse:** Continue `registered-execution.pi`, `registered-worker.pi`, `registered-watchdog.pi`, `qualify-cache.pi`, the actual transfer procedure and main handoff recovery. Do not reassign the already-fixed cached-request mismatch or FP127 stale delivery PASS.

**6. Scope and ownership:** FP owns attempt/replay/publication sequencing; Kitchen owns transfer retry semantics, CF owns installation generations, P03 owns producer incremental cache correctness, ai-ci A03/A04 owns authority/verdict. Consume those artifact interfaces rather than duplicating their algorithms.

**7. Prerequisites:** Refresh exact reconciled S01/BC-FP01-S01 interfaces and owner effect contracts. Require qualified runtime/worker isolation for execution. Consume A03 current-authority decisions and P03 cache material/verdict for producer reuse; do not wait for every owner job's overall completion. Read current shared/local instructions: Idriç-first helpers, Grease orchestration, checked Ithon, scoped Ike and exact ICK/NDK stages; no new Python/Bash debt or runtime substitution.

**8. Work:** Integrate owner retry classifications with existing journal transitions. Revalidate accepted objects immediately before publication/effect, preserve failed prior attempts, and independently verify ambiguous remote postconditions. Reject late worker results for superseded attempts; expose interrupted, stale, not-run and blocked states through A04. Exercise existing Kitchen and exporter operations plus a disposable publisher fixture through actual controller paths.

**9. Acceptance:** Interrupt before/after child completion, sealing, remote response and final publication; retry from fresh sessions. Reject stale completion, overlapping worker writes, copied producer output, changed policy/tool/source, revoked authority and deleted/corrupt accepted artifact. Observe external effect counts independently, including lost-response then already-completed no-op. Benign identical retrieval/replay and harmless relocated paths remain valid. Verify actual final files/effects and prior failures, not matching receipt text alone.

**10. Evidence limits:** Deterministic receipts do not prove exactly-once effects; synthetic remote fixtures do not prove live account behavior. Preserve source, runtime, external mutation, publication and device evidence separately.

**11. Completion and continuation:** Release exact lifecycle/checker interface, executed interruption matrix and owner-consumer receipts. Reconcile FP14/15 and original failure records. If an operation's retry promise conflicts with observed behavior, isolate that operation and return its exact owner question.

**12. Authority:** Implement and test disposable effects; prepare reviewable branch/draft changes. No live mutation, deployment activation, merge, closure, release, installation or dispatch.

END OF BC-FP02-S03
