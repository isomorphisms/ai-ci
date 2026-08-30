# Hostile web corpus v1

This directory is the canonical byte-level fixture source for the first
cross-repository ingestion receipt. `REVISION` names the semantic corpus
revision; consumers additionally record the exact `ai-ci` commit SHA.

The corpus is intentionally small but not friendly. It distinguishes a
successful empty response from failed retrieval, includes a redirect, a
declared-length truncation, invalid UTF-8, an unknown charset, truncated gzip,
a non-2xx response, a TLS handshake failure, and malformed HTML that still has
useful document structure.

The `.hex` files are canonical byte sequences. The fixture server decodes them
before transmission. This keeps invalid UTF-8 and truncated compressed bytes
reviewable in Git while preserving their exact wire form.

The document fixtures establish only the named `document_log_subset_v0`
semantics: document order, tag/text events, title text, and source fixture
identity. They do not establish a browser DOM or complete WHATWG recovery.

Every receipt has seven stages in this order:

1. `input_acquisition`
2. `network`
3. `decompression`
4. `decoding`
5. `html_recovery`
6. `document_construction`
7. `downstream_extraction`

`SKIP` means the stage did not run. `not_applicable` skips do not block a later
stage; `not_implemented` and `blocked_by_*` skips do. A failure must be followed
only by `blocked_by_<first failure>` skips.
