# Reject hidden assignment handoffs

`validators/job_delivery.pi` consumes Flexible Pipes' extended stage receipt
and exact artifact. It imports that owner contract instead of duplicating a
job schema. `check-job-delivery.pi STAGE_JSON PAYLOAD RESPONSE RESULT` is its
checked-Ithon CLI. The caller must provide the pinned Flexible Pipes scripts
directory on the module search path and execute through the pinned Ithon
entrypoint. A PASS result binds stage, payload and response file SHA-256.

The validator reads actual response captures, compares the complete literal
artifact against the authoritative stage bytes, and checks sequenced delivery
and dispatch identities. It rejects hidden/internal-only jobs, GitHub-only
storage, successful dispatch without requested display, title/summary/link-only
replies, mutation/truncation, forged mode changes, dispatcher-first ordering,
duplicate dispatch and unreconciled “where’s the text?” recovery.

Deterministic rejection occurs before downstream dispatch and before final
semantic review. Explicit human dispatch-only remains supported. Summary plus
the full assignment succeeds. A recovered handoff preserves original identity
and the previous delivery failure.

The trusted controller must own observations and the original human request;
this is not a remote attestation service. Caller-authored captures cannot prove
that ChatGPT emitted a real message. Local fixtures establish the bounded
enforcement contract, not deployed platform adoption. The maintained FP runner
therefore holds a generated assignment pending a trusted delivery adapter.

This extends the exact-artifact boundary of
[#205](https://github.com/isomorphisms/ai-ci/issues/205) and
[#176](https://github.com/isomorphisms/ai-ci/issues/176). Their execution/host
checks are unchanged; seeing an assignment does not prove execution of its
commands. FP owns rendering, metadata and mechanics; this repository owns
output-satisfaction enforcement. No Kitchen, Cat Food or leaf policy copy is
needed. See [FP's contract](https://github.com/isomorphisms/flexible-pipes/blob/main/docs/job-delivery.md).

Both October 6 recurrences are retained as sanitized owner fixtures with
positive twins. `tests/job-delivery/check.pi` builds its own capture evidence
without calling the producer's `deliver()`; expected outcomes and diagnostics
are in `cases.tsv`. FP's separate suite executes effects and the real runner.

Trackers: [#219](https://github.com/isomorphisms/ai-ci/issues/219),
[FP #35](https://github.com/isomorphisms/flexible-pipes/issues/35),
[FP final review #17](https://github.com/isomorphisms/flexible-pipes/issues/17).
