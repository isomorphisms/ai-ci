# Hostile-ingestion receipts

This optional AICI action owns the canonical hostile-web corpus and validates
the shared seven-stage receipt. It does not implement the candidate path.

The first implementation under test is ICU compiled through Idriç. Its current
receipt identifies the native C/OpenSSL transport boundary explicitly. The
side-by-side oracle uses curl for retrieval, gzip for compressed bytes, iconv
for UTF-8 validation, and libxml2 for recoverable HTML. Oracle output is written
to a separate receipt and is never supplied as candidate input.

For implementation-under-test receipts, the verifier requires an `execve`
trace and rejects any candidate trace that invokes curl, libxml2's command-line
program, Python, html5lib, warcio, or another named oracle. It also rejects an
oracle identity in candidate metadata, a non-`none` fallback field, a later
success after the first failed or unimplemented boundary, and inaccurate
`first_failure` / `first_incomplete` summaries.

Consumers must pin `isomorphisms/ai-ci` by a full commit SHA and record that SHA
as `corpus_repository_revision`; `corpus_revision` comes from
`corpus-v1/REVISION`.

Example:

```yaml
- uses: isomorphisms/ai-ci/ingestion@<full commit SHA>
  with:
    receipt: out/valid_utf8.candidate.tsv
    role: implementation-under-test
    exec_trace: out/valid_utf8.execve
    oracle_receipt: out/valid_utf8.oracle.tsv
```

The current document boundary is deliberately named
`document_log_subset_v0`. It is not a claim of browser DOM compatibility.
