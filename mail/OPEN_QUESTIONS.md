# Open questions and release blockers

1. **Q1 / SOURCE_BLOCKED: intended original mbox parser.** The verified ICU
   branch contains a design note, not the original. Needed: repository, exact
   copied/upstream commit, complete implementation/tests, local diff and explicit
   discard decisions. Only then select separator grammar, escape depth,
   Content-Length, CRLF/LF, empty-mailbox and final-message behavior. Earlier
   references to “NetBSD mbox” do not settle these choices.
2. **Q2 / SOURCE_BLOCKED: original RFC/MIME parser.** It may be separate from
   the framer. Needed: exact source and retained charset/encoded-word/recovery
   behavior. Strict specification cases have answers; malformed-case recovery
   must not be guessed. RFC6532 and RFC2231 may be unsupported retained features,
   not translation regressions, until provenance decides.
3. **Q3 / SOURCE_BLOCKED: original Gmail importer.** The gmail-cli branch is a
   surface sketch. Needed: original importer if copied, exact import method,
   request options, raw-byte transformation policy, durable state and explicit
   dedup/reconciliation decisions. Do not replace it with a new library.
4. **Q4 / NOT_RUN: real adapters.** All language entries currently lack an
   executable. Build identity, whole-hog source coverage, fallback prohibition,
   backend and platform evidence must accompany actual adapters. Replay success
   proves only the harness can compare observations.
5. **Q5 / PENDING: live local SSH controller.** Contract, payload fixture and
   model cases exist. Server provisioning, independent trace capture, fault
   injection, and candidate integration are not implemented. A key-trust receipt
   alone cannot prove key checking happened.
6. **Q6 / PENDING: actual migration persistence adapter and fake service.**
   Model cases cannot expose all write-order bugs. Need external kill barriers,
   independent remote acceptance log, actual filesystem recovery, torn-record
   generator for the selected format and duplicate inspection after restart.
7. **Q7 / CONDITIONAL: source snapshot consistency.** Mail delivery/compaction
   can alter a live spool. Need a coherent snapshot/locking strategy selected by
   the migration owner. Same path and size alone are insufficient identity.
   Test same-size replacement, append during read, truncation, and resume against
   another snapshot without modifying the public raw corpus.
8. **Q8 / PENDING: bounded parser work and descendants.** Large hashing probes
   validate generator, counts, hashes and resource rejection. They do not prove
   incremental mbox/MIME parsing, early output, bounded scratch use or child
   process accounting. Require actual parser runs once adapters exist.
9. **Q9 / NOT_RUN: physical SDF→Gmail.** The procedure is separate and not
   committed. No connection, private source selection, import, or real restart
   occurred in this job.
10. **Q10 / DECISION_REQUIRED: original/spec conflict.** Preserve separate
    compatibility and protocol findings. A human decides whether a known original
    bug remains compatibility behavior or requires intentional correction.

These are gates, not excuses to promote a partial result. The executable corpus
can already reject many plausible errors, but the requested end-to-end suite
is unfinished until these material gaps are closed. No source or behavior was
invented to replace the missing programs.
