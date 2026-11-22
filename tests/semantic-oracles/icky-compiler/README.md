# Independent host check for the ICKY compiler lane

The oracle specifies return values, the order of externally observable
stores, and an ordinary cross-object call with 64-bit arguments and return
values. Neither the compiler's AST nor its receipt supplies these expectations.
Written `010` must produce eight. Written `10` must produce ten. The third
store uses an argument above the 32-bit range. The same executable oracle runs
against candidate objects produced at `-O0` and `-O2`.

The check is for the explicit `__builtin_icky(...)` lane in [Flexible Pipes
#71](https://github.com/isomorphisms/flexible-pipes/issues/71). It uses native
Linux x86-64 ELF objects. A success-only parser, a shape-correct response with
the wrong numeral, a changed source frame, a neighboring arrow, an unsupported
expression, a stale line map, and a truncated ELF object are required to fail.

## Hosted inputs

Run the `check` target in this directory's Makefile. Supply these Make
parameters as absolute paths with no spaces.

| Parameter | Required input |
| --- | --- |
| `BUILD` | A fresh output directory with an existing parent |
| `ICK` | The native driver staged from the exact K2 candidate source |
| `ICK_PARSER_PACKAGE` | The verified and extracted native ICKY parser, loader, application, and runtime closure |
| `ICK_MUTANT_FRONTEND` | The `cc1` built from the same exact candidate with `ignored-assignment.patch` applied |

Use the owner workflow's K1-preserving compiler bootstrap for both frontends.
Apply the patch with zero fuzz and strip one path component. Its `gcc/c` path
starts at the root of the materialized, disposable mutant source. Build the
mutant in a separate workspace. The acceptance Makefile uses `-B` to select
its `cc1` for one object and checks the actual selected path in the external
execution trace. Preserve the unmodified driver, frontend, and parser package.

The mutant invokes the maintained parser, validates its response, and writes
the same kind of compiler receipt. It discards the checked plan during code
generation and emits the final CPP noun, omitting all parser-directed stores.
It must link and execute, preserve the expected arithmetic and call behavior,
and trigger the oracle's exact assignment-effect failure.

## Evidence

The output directory retains the source and expectation snapshots, Linux
process-execution traces, compiler parser receipts, object files, ELF
inspection, executables, diagnostic logs and exact stdout. Preserve
`materials.sha256` and `result.tsv` with those bytes. For a second replay,
choose a new build directory. The check stages fresh source snapshots and
compares them against the pinned verifier checkout after execution.

The hosted caller must independently attest the exact AICI verifier and ICK
checkout revisions, the mutant source and build, and acceptance and digest
of the complete parser package. The Make target records observed material
hashes and the native host verdict. Registered producer admission and the
four Android ABI results remain pending separate qualification.
