# Owned C source check

This Icky C program keeps physical bytes, logical lines and assignment tokens
as separate types and transformations:

`read_source → physical_source_requires_review → splice_logical_lines →
scan_assignments → inspect_source`.

`inventory` reports ordinary assignment tokens, owned arrow tokens,
preprocessor assignment tokens and compound assignments. `check` rejects
ordinary `=` assignments, including macro definitions. Both modes preserve
comparisons, pointer/member syntax, literals, comments and compound operators.
Backslash-LF/CRLF splices are removed before lexical classification, while
diagnostics retain the original physical line. Embedded NULs, recognized
trigraphs anywhere in phase-1 input, and unterminated literals/comments require
review and return status 2. A style violation returns 1.

Call the check only for explicitly owned ICK source. Plain cross-compiler
headers, upstream sources and deliberate compiler/test inputs must have
separate, source-bound roles; do not relabel them to obtain a green result.
Generators and active PR branches remain part of the account inventory.
A generated C file must be changed through its generator.

The checker is lexical. It does not prove compositionality, numerical
equivalence, a correct role declaration, compiler ownership, or fleet
completion. Those require source review and execution receipts. It never
rewrites files. In particular, changes to a stringified macro's spelling need
explicit semantic review.

The Makefile requires ICK to compile the checker. Its good/known-bad fixtures
prove distinctions between assignments, comparisons, compound operators,
quoted/comment bytes, preprocessing, spliced tokens, and unsupported lexical
input. The native producer under `ick-host/` proves literal `←`, `×` and `÷`
before exporting the compiler; it declares its host runtime dependency.

The public account census is in `account-sweep-2026-10-08.tsv`. It is a
discovery checkpoint, not a style certificate. The full private/public blob
inventory is retained separately.
