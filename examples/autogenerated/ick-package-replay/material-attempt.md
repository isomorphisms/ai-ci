# Independent acquired-package material admission

## Purpose and type sketch

Admit the actual extracted package before compiler execution. Archive acquisition
and the candidate's `material.tsv` do not establish the current extracted bytes.
The caller supplies an independently approved complete material-record digest
and required path/digest/mode rows outside the package. The observer has no
acquisition, extraction, write, repair or compiler-execution operation.

Values are a package root, an expected complete manifest SHA-256, a required
material file and observed regular-file material. Each material row describes a
relative canonical pathname, SHA-256 and full permission mode. Directories are
containers; links and special nodes are outside this profile.

Central actions:

- `inspect_material : Text → IO Text` enumerates node types before content reads,
  then observes every regular file digest and mode in canonical pathname order.
- `admit_material : Text → Text → Text → IO ()` checks the trusted complete
  inventory digest, compares independently reconstructed rows with the candidate
  record, and requires every externally supplied required row.

Failure exits preserve a specific `MATERIAL-*` diagnostic. The observer uses
the existing `SourceProcess` escaped argv interface, absolute GNU host utilities,
and the maintained Idriç Chez backend. No generated C, RefC, Python, or alternate
verifier is an implementation fallback.

Invariants: package material is unchanged; candidate metadata cannot define its
own approval; all node kinds are checked before hashing any file; canonical
pathnames exclude delimiters, traversal, duplicate components and leading
options while retaining literal `+`.

## Verification

PASS: 16 independently constructed cases executed through the actual compiled
Idriç Chez observer. They cover valid relocated material with spaces and an
apostrophe, literal plus names, changed executable bytes with rehashed candidate
metadata, missing dependency with correspondingly relaxed candidate metadata,
false mode, extra file, forged/reordered record, false/duplicate/malformed
required rows, symlink, FIFO, newline/tab pathnames and wrong approved inventory.
Every call is bounded by five seconds and fingerprints file bytes, modes, node
kinds and symlink targets before/after. All fingerprints were unchanged. FIFO
refusal returned the intended node-kind diagnostic with status 1, not timeout.
The fixture corpus imports process observation only, not the admission observer
or acquisition implementation. `outcomes.tsv` is written outside candidate
package trees only after every case actually passed.

The actual 870-file delivered compiler package independently passed against
approved material digest
`62661fb117fc5b36dd2ffc280f44e9eae3d1b6c88863de6aac547b6fd9b34459`.
This proves current complete material identity and required payload membership;
it does not establish semantic compiler execution, which remains a separate
replay stage.

Compiler: Idriç `2bce7677f513d711875e978bd6f5ad28b9e54d58`, maintained
Chez host backend. Compile existing `SourceProcess.idric` with its source
directory and `--check` into the same explicit build directory, then add that
directory's `ttc` to `IDRIS2_PATH` alongside the pinned prelude/base TTC paths.
Compile each new module with `--source-dir` for this example and `-o` for the
actual executable. The initial guessed `-i` option failed; the compiler's real
`--help` documents `IDRIS2_PATH`, not that option. An attempted source-directory
import without a compiled TTC also failed and misleadingly returned exit 0;
acceptance therefore requires actual executable files and the executed cases.

## Language work

The first NUL-delimited enumeration attempt failed: the inherited subprocess
Text capture returned only the first NUL-separated portion, making the ordinary
control's inventory empty. The failure is retained as a bounded text-capture
observation, not a compiler-wide causal diagnosis. The working observer first
asks `find` to reject any basename outside the restricted ASCII profile, which
includes all newline/tab/control delimiters, then uses newline framing. This
does not substitute languages or broaden accepted pathnames. All node kinds
are checked before any byte read; absolute host utility paths run with a cleared
environment and fixed C locale.

The next language/library capability suggested by this attempt is an explicitly
byte-preserving subprocess result. Its acceptance should return embedded NUL
bytes unchanged before callers use NUL-framed filesystem observations. That
facility is not required or falsely claimed by this profile's implemented
pathname-validation path.
