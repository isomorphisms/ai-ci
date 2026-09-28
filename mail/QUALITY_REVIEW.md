# Attack on the suite

| Attack/question | Current answer | Remaining risk |
| --- | --- | --- |
| Could semantic success conceal raw corruption? | archive.bin is compared independently; newline/unfold/decode mutations fail | Candidate must feed its actual archival path |
| Could 32-bit offsets pass? | A run crosses 2³² with a source receipt; a real >4 GiB byte stream is also consumed | Per-message spans require Q1; a large parser adapter is absent |
| Could arbitrary chunking reveal assumptions? | One-byte, prime, deterministic random and every two-chunk cut run | All possible multi-cut partitions are exponential; bounded random coverage is not a proof |
| Could a crash duplicate mail without a test failing? | Unsafe retry and false certainty model observations are rejected | Yes, a real implementation could lie in its receipt or reorder filesystem operations; Q6 remains a release blocker |
| Could skipped host verification pass? | A claimed accepted mismatch fails the model checker | Yes, a lying adapter can manufacture a rejection; live server auth/exec witnesses are required by Q5 |
| Do expected answers come from a translation? | No. Literals, protocol rules and user-established safety requirements construct them | Generator/expected-data review is still needed; self-review is not independent human review |
| Are mbox semantics guessed? | No. Construction spans and unresolved expectations remain separate | A complete retained-parser acceptance claim is blocked |
| Can missing implementations appear green? | Registry dashes yield NOT_RUN and exit 2 | The full release gate is a conjunction of COVERAGE states, not just the compact runner |
| Could a bad decoder satisfy the raw checks? | Decoded leaf files have independent expected bytes and structure | Unlisted charset/error recovery behavior remains unresolved |
| Could the original's bug become the oracle? | Compatibility/spec conflict gets its own discrepancy class | Human decision required before changing obligations |
| Is a hash receipt proof of parsing? | No; the large probe is labeled byte-stream evidence only | Actual incremental parser and descendants are Q8 |
| Are fixtures redundant? | Plain/base64/wrapped/QP share one payload intentionally to compare distinct equalities | Do not add further same-path fixtures without a new failure hypothesis |
| Is string/integer behavior language-specific? | Binary files, hex values, decimal positions and a fixed PRNG avoid host strings/numeric serialization | Adapters need checked integer conversion and byte-based slicing |
| Can fixtures or output be stale? | Deterministic regeneration and byte diff; fresh run directories; executable/input hashes | Build provenance must bind source to the actual binary |

## Additional realistic failures to carry forward

Source replacement at the same path/size; offset rebasing after spool compaction;
half a multibyte character replaced with U+FFFD; truncation at embedded NUL;
Content-Length trusted across a conflicting separator; signed 32-bit overflow;
base64url confused with base64; MIME boundary case-folding; counting multipart
container CRLF as attachment bytes; dropping repeated Received/X headers;
attachment filename path traversal; importing before host verification; stderr
deadlock while only stdout is drained; ignoring a late nonzero remote exit;
using the SFTP EOF rule for libssh2 channel zero-byte returns; treating a canceled
request as not submitted; dedup by Gmail thread ID; acknowledging local append
before fsync; accepting a valid checksum on a record from the wrong source
snapshot; reordering intent after submission; retrying 429/5xx without accounting
for outcome uncertainty; receipt success based on unrelated subprocess output.

Current executable mutations cover a subset, explicitly listed in the receipt.
`every-From`, source-snapshot, filename traversal, true crash-order and real host-
verification mutations are **not killed yet**. The suite therefore remains
unfinished for end-to-end acceptance. It must not be weakened or relabeled to
hide these gaps.

## What the mutation proof actually establishes

Byte-mutating adapters execute altered stream behavior. Semantic/state mutants
alter fixture-replayed observations; their rejection proves the comparator checks
those fields, not that any native implementation reached those states. The large
buffering mutant actually allocates with total input and is stopped by the
resource cap. Keeping those evidence kinds separate is essential.
