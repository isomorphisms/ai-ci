# BC-FP02 — Deterministic plans, recorded replay, and attempt recovery

**Identity:** STAR, Ultra; owner `isomorphisms/flexible-pipes`; parent [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [issue 1](https://github.com/isomorphisms/flexible-pipes/issues/1), coordinated with [14](https://github.com/isomorphisms/flexible-pipes/issues/14), [18](https://github.com/isomorphisms/flexible-pipes/issues/18), and [19](https://github.com/isomorphisms/flexible-pipes/issues/19).

**Outcome:** Equal material inputs yield the same stable plan; replay consumes exact accepted model bytes without inference; interrupted or overlapping attempts preserve truthful results and bounded effects.

**Recovered intent:** [Pipeline contract](https://github.com/isomorphisms/flexible-pipes/blob/def2a66fe61a2b23440f98031f1defa738a0d1ee/docs/pipeline-contract.md) distinguishes deterministic programs, fresh model inference, and recorded replay. Fixed seeds do not prove fresh-output identity. Preserve ragged payloads and legitimate exploration; orchestration metadata cannot silently change semantics.

**Current evidence:** October 12 main `def2a66fe61a2b23440f98031f1defa738a0d1ee`, repository ID `1405888814`, still accepts only `kind=command` in `scripts/run-pipeline`. Retained [isomorphisms/flexible-pipes PR #31, “Implement registered Kitchen script execution and preserve FP2 qualification attempts”](https://github.com/isomorphisms/flexible-pipes/pull/31), live `implement/fp2-runtime-qualification@442a33bfd36a23df3d757d17a31b8084cab21a38`, contains atomic journals, per-attempt worker identities, watchdog recovery, and `validate_cached_result`.

**Reuse:** Continue `scripts/registered-execution.pi`, `registered-worker.pi`, `registered-watchdog.pi`, and `tests/registered-execution/qualify-cache.pi`. Current source already compares cached request ID, digest, operation, inputs, and release identity: do not resurrect the repaired cached-identity finding from older notes.

**Ownership/scope:** This is the single campaign owner for plan/replay/attempt lifecycle. BC-FP01 owns admission and callers; adapters consume this lifecycle. No second scheduler, retry framework, model catalogue, or application oracle.

**Prerequisites/readiness:** READY for investigation and independent fixtures. Refresh source and runtime qualification; admission integration depends on BC-FP01. Actual model execution requires an explicitly selected capable worker and resource permission. Grease-dependent managed execution remains conditional on [FP73](https://github.com/isomorphisms/flexible-pipes/issues/73)'s qualified C++-free runtime; preserve checked Ithon and Idriç-first helper constraints.

**Work:** Produce four SUN boundaries: canonical material plan versus attempt metadata; bounded model-worker capture plus exact recorded replay; interruption/concurrency recovery and immutable failed history; cache/publication revalidation against current authority. Set retry effects for each maintained operation and investigate lost external responses before allowing repeats.

**Acceptance:** Positive: independently repeated plans and replayed downstream outputs match, with zero model calls during replay. Bad controls: mutated recorded bytes, undeclared clock/environment input, stale completion, changed dependency/policy, revoked qualification, worker overlap, and interruption before publication. Benign controls: different attempt IDs/timestamps preserve stable plan bytes; explicit fresh inference remains separately valid. Verify actual final state, not merely equal receipts.

**Evidence limits:** Historical replay is not current admission; deterministic output is not exactly-once effects or reproducible compilation. Retain unavailable worker, skipped, interrupted, and failed states.

**Completion:** Emit decision/evidence, complete SUN jobs, exact prerequisite/rejection checks, dependency order and next actions; update existing records. A conflict with an owner's promised retry semantics returns that specific question.

**Authority:** Investigate, perform bounded qualification needed to settle this domain, and create SUN issue/file records. Do not execute the emitted SUN implementation campaign here. No merge, closure, release, activation, recurring schedule, or actual Work dispatch is inferred.

END OF BC-FP02
