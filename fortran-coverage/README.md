# Archived Fortran machine-evidence check

One-off independent structural acceptance for EMC-FORTRAN-COVER-01.
Run `node check.mjs --repository ABSOLUTE_LEAF_ROOT --inventory ABSOLUTE_TABLE_ROOT --self-test`.
The input snapshots are exact Git commits recorded by the leaf. This checker
does not import leaf implementation code or use its summary as an oracle.

GNU readelf independently supplies section, mapping-symbol and relocation
evidence. Original native listing columns independently supply record order,
encoding bytes, ISA/data classifications and printed relocations. Full physical
file and executable-section partitions must account for every byte or retain
an explicit missing range. Unknown semantics and library closure cannot become
complete claims. A passing structural check does not certify instruction meanings,
run the programs, close libraries, or establish ISO Fortran support.

Use --receipt ABSOLUTE_PATH to retain exact leaf/oracle Git identities, source
pins digest and generated table digest inventory. Refuse a receipt path that
already exists. Re-run after any material source change. The --self-test cases
must each fail for their named diagnostic with the original corpus as positive twin.
# Linked ARM successor

See [ARM-LEDGERS.md](ARM-LEDGERS.md) for the separate independent checker of
the two linked ARM preliminary English ledgers. Frozen inventory acceptance and
successor annotation acceptance retain separate receipts and evidence boundaries.

`check-cmov-claims.mjs` adds a separate finite primary-reference/byte/English claim
check for eight repaired x86 conditional-move occurrences. It reads the pinned
Intel CMOVcc blob, independently decodes original ELF bytes and checks 256 flag
assignments with three disclosed operand pairs (768 modeled transitions).
Eleven corruptions must fail, including predicate/source mistakes, false
completion and altered primary evidence. It does not run a specimen or certify
complete effects. The other 117 historical partial descriptions remain unverified.

## Reorganized consumer directories

All three checkers accept `--path-map _/path-map.tsv`. The map filename and both
columns are relative to `--repository`, regardless of the launch directory.
The plain TSV starts with `old_path<TAB>new_path`. Each subsequent row maps an
old logical file or directory to its current location. The longest matching
directory prefix wins; an exact file mapping overrides its parent directory.
Unmapped paths retain their original location. Prefixes match whole path
components, so `examples` does not match `examples-old`.

Include directory mappings for sets that a checker enumerates, such as
`coverage` to `_/coverage`, and exact overrides where assembly listings or
English annotations have been separated from binaries. The map changes only
current worktree reads. It does not change historical Git `commit:path`
lookups, source pins, specimen manifests, generated historical tables, or any
byte, instruction, ABI, or semantic assertion.

Empty or duplicate source paths, absolute paths, `.` or `..` components, malformed
rows, and destinations escaping through symlink ancestors are rejected. The
map itself must also be inside the repository. Receipt checks cover the map
and all mapped destinations of their existing material scopes, including
directories split across several locations. Receipts include the map's SHA-256
and the shared path resolver's SHA-256. A dirty map cannot produce an exact-head
receipt. Existing calls without `--path-map` keep the original layout.

Run the focused positive and negative path tests with
`node /ABSOLUTE/ai-ci/fortran-coverage/worktree-paths.test.mjs`.
