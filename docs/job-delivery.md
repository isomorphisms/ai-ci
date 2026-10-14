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

Version 2 handoffs carry first-class binary attachments. The independent gate
requires an observed attachment event with the authoritative payload digest and
size, declared filename and MIME type, trusted surface and nonempty file ID. It
rejects link-only responses, missing files, changed bytes, renames and MIME
substitution. Flexible Pipes owns bounded direct-file and ZIP-member
materialization; ai-ci recomputes the materialized identity from the captured
source before accepting the event.

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

Trackers: [FP #39](https://github.com/isomorphisms/flexible-pipes/issues/39),
[#219](https://github.com/isomorphisms/ai-ci/issues/219),
[FP #35](https://github.com/isomorphisms/flexible-pipes/issues/35),
[FP final review #17](https://github.com/isomorphisms/flexible-pipes/issues/17).


## Independently admitted and read-back artifacts

`check_authority` compares the stage's request, corrections, model, audience,
source context and attachment against an independently supplied expected spec.
Required literal text belongs to that admission, not the generating worker.
This covers explicit constraints; it does not replace grounded semantic review
for requirements that cannot be reduced to literal checks.

`reference_attachment` independently reads the unique declared member, checks
source/payload digests and bounds, and refuses unsafe, missing, duplicate,
encrypted or corrupt members. It does not call FP's extraction function.

The existing checked CLI also accepts:
`check-job-delivery.pi actual STAGE SOURCE DELIVERED METADATA ADMISSION RESULT`.
ADMISSION contains `spec` and `required_text`; METADATA binds the message/file
identity, surface, filename and MIME to the read-back bytes. Text and binary
input files are actually opened and hashed. A caller's `trusted=true` or
`evidence_class=platform` cannot supply missing host authentication.

The output is `CONTRACT_PASS` with `platform_delivery_status=NOT_VERIFIED`.
The `fixture` and `service-readback` labels describe the comparison inputs;
they do not authenticate their acquisition or the client's rendered surface.
A producer could still fabricate local input files. The trusted platform adapter
must supply authenticated observations outside the worker boundary before any
production acceptance or dispatch is permitted. That adapter remains unavailable.

The suite retains every old case, adds independent admission/readback cases and
records nine rejection transitions where the previous contract accepted a
self-consistent wrong request/model or a correct declared attachment with wrong
read-back data. Sanitized positive specimens are retained for CLI inspection.
Actual delivery-service and physical-device qualification remain separately
required and have not been replaced by those specimens.

