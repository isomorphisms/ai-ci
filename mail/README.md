# Mail translation acceptance

> No implementation is the oracle. The independently established behavior,
> source provenance, protocol rules, and acceptance corpus are the oracle.

AICI pushes bad translations back before they enter the SDF → SSH/issh → mbox →
RFC message/MIME → migration state → Gmail pipeline. This branch implements test
infrastructure, synthetic data, comparison rules, and adversarial model adapters.
It implements none of the mail stack.

**Current verdict: INCOMPLETE / SOURCE_BLOCKED.** The original libssh2 source is
pinned and intact. The intended original mbox/message parser and Gmail importer
were not found. Neither malformed-input recovery nor an SDF mbox convention can
be selected honestly yet. Every `UNRESOLVED` case remains a gate blocker, even
when its bytes survive. No translation or physical SDF/Gmail pass is claimed.

## Read in this order

- [PROVENANCE.md](PROVENANCE.md): exact source trees and what the audit establishes.
- [INVARIANTS.md](INVARIANTS.md): reasons, evidence, concrete fixtures, failure classes.
- [adapters/CONTRACT.md](adapters/CONTRACT.md): language-neutral invocation and files.
- [COVERAGE.tsv](COVERAGE.tsv): enforced, conditional, and pending boundaries.
- [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md): decisions that must precede release acceptance.
- [QUALITY_REVIEW.md](QUALITY_REVIEW.md): attacks on this suite and remaining holes.

## Executable infrastructure

`make_corpus.c` constructs literal examples and independently supplied answers.
It never invokes a mail parser. Committed binary inputs, decoded payload files,
source hashes, expected facts, and construction spans live in `corpus/`.
`.gitattributes` protects these byte-exact files from newline conversion.

`accept.c` drives every language through the same explicit chunk frames, compares
actual output files, enforces deadlines, records executable/input digests, and
produces a differential table. Semantic records never substitute for raw bytes.
Its exhaustive mode tests every two-chunk cut for inputs below 4096 bytes, plus
whole input, one-byte reads, small and prime lengths, and a specified PRNG.

`accept challenge ABSOLUTE_GENERATOR ABSOLUTE_ADAPTER NEW_OUTPUT` creates a
fresh, valid RFC 5322 folded-header holdout after the candidate artifact has
been identified. It records the random seed, generator and adapter hashes, then
runs every partition. An optional `SEED COUNT` makes a failing holdout exactly
reproducible. Release/candidate CI should use the no-seed form and keep the
generated corpus and expected files controller-owned. The fixed-seed self-test
proves that a deliberately public-case-only adapter is rejected; it does not
claim a security boundary against a malicious same-account process.

`replay_mutant.c` is **only a test of the harness**. Its good mode copies expected
semantic observations, while preserving input via the actual stream protocol.
Its bad modes damage bytes, source positions, output payloads, or observations.
Passing replay is not mail parsing, SSH, migration, or original-program evidence.

The host build requires a C17 compiler and OpenSSL libcrypto development files.
The test infrastructure's use of libcrypto for SHA-256 does not select a crypto
backend for issh. `Makefile` provides `all`, `corpus-check`, and `test`. Build from
the checkout using `make -C /absolute/ai-ci/mail test BUILD=/absolute/new-output`.
This is a direct make invocation, not a shell application. Use a fresh build
directory for each run because child output files intentionally reject reuse.

The generator optionally accepts a 32-bit seed and at most 1024 extra grammar
cases. `--generated-only OUTPUT SEED COUNT` produces a compact valid RFC
holdout without public or unresolved cases. The runner accepts
`run CORPUS ABSOLUTE_ADAPTER NEW_OUTPUT [exhaustive]`,
`challenge ABSOLUTE_GENERATOR ABSOLUTE_ADAPTER NEW_OUTPUT [SEED COUNT]`,
`self-test CORPUS ABSOLUTE_GENERATOR REPLAY_ADAPTER NEW_OUTPUT`, and
`differential CORPUS REGISTRY NEW_OUTPUT`. Exit 0 means all selected assertions
passed; 1 means a mismatch; **2 means unresolved or unavailable evidence**.
Timeout exits 124 and must never be converted to PASS. Full release acceptance
also requires the source, live SSH, persistence, large-parser, and physical gates
in COVERAGE.tsv; the compact runner alone cannot grant release acceptance.

Use `large/stream.c` for generated large inputs and measured address-space limits.
Its byte-stream probe tests the measurement gate, not a parser. Current receipts
explicitly separate those claims.

## Independence and changes

No D, Idriç, Agda, or other translated API defines these expectations. A source
map was consulted only for retained/deleted-file evidence. No translation output
was collected for expected answers. The original C program will be another
candidate once an adapter exists. A disagreement triggers investigation against
source and specification, never voting. Classify a resolution as implementation
bug, test bug, deliberate discard, underspecification, retained original behavior,
or original bug requiring human decision; preserve the reproducer and rationale.

The older [AICI issue 52](https://github.com/isomorphisms/ai-ci/issues/52) addresses
a read-only paragraph viewer and proposes a materializing reference. This job
has a broader migration boundary and explicitly forbids a reference
implementation from defining truth. It does not silently change that viewer's
product contract or claim its obligations have been completed.
