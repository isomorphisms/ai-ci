# Independent linked ARM ledger acceptance

`check-arm-ledgers.mjs` checks the two exact archived specimens selected by the
English Major Fortran inventory. It imports no producer code. It independently
reads original Git blobs, GNU readelf sections, mapping symbols, ABI flags and
attributes, ELF relocations, and the original listing columns. The candidate
must retain 3,442 instructions, 98 data rows and six suppressed ranges, with
exact bytes/assembly/order, native-record links and actual encoded widths.

The checker reads the frozen relocation inventory only as a candidate to compare
with readelf; it never trusts that inventory as the original relocation source.
Its finite source pins and ABI expectations are explicit in its own source.

Run from any directory:
`node /ABSOLUTE/ai-ci/fortran-coverage/check-arm-ledgers.mjs --repository /ABSOLUTE/English-major-C --self-test --receipt /ABSOLUTE/FRESH.tsv`.
`--directory` can select another six-file candidate set. The receipt refuses
existing output and dirty material leaf/oracle paths. It binds both exact heads,
the oracle digest, all six candidate digests and the specimen manifest.

There are 22 targeted cases: 21 deliberately corrupt candidates must be rejected
for their intended diagnostic; unavailable original Git evidence must be
explicitly reported missing. Cases cover row loss/duplication/order, altered
bytes/operands, literal or ISA misclassification, Thumb width/context, A32
predicates, swallowed suppressed ranges, missing crosswalk/range entries,
missing descriptions/relocations, ABI conflation, duplicated totals and false
semantic/library/language claims.

PASS proves structural annotation accounting only. The checker does not certify
the truth of the preliminary English explanations, full flag effects, address
semantics, memory/fault/ordering effects, floating-point behavior, callee effects,
whole-process closure or Fortran conformance. Those remain UNVERIFIED/UNKNOWN.
No original executable, QEMU or QR interpreter is invoked.
