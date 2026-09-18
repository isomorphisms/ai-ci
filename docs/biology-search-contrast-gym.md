# Biology search contrast gym

This note defines a standing evaluation/inspection suite for search and branching work across compiler backends.

## Standing trigger

Whenever a change materially touches any of these areas, run at least the small biology contrast suite before drawing conclusions:

- fixed-string or motif search;
- many-way branching or computed/table dispatch;
- DFA/trie/Aho-Corasick style state machines;
- bit-parallel Shift-Or/Shift-And style search;
- branch elimination, branch fusion, branch-table selection, or target-specific branch instructions;
- SIMD/vectorized candidate scans;
- packed DNA representations;
- direct backend lowering intended to beat or replace a conventional high-level-language/compiler path.

This applies across ARM/Thumb, x86-64, AArch64, RISC-V, FPGA experiments, and later backends. A backend experiment should not live only on an artificial `grep` string when the same idea can be exercised on the shared FASTA/FASTQ/SAM/VCF/BED/GFF corpus.

The current computer-science anchors are:

- `isomorphisms/computer-science#23` — many-way branching;
- `isomorphisms/computer-science#24` — bit-parallel fixed-string search;
- `isomorphisms/computer-science#26` — genomics as a first-class search benchmark.

The corpus is being collected under `isomorphisms/bioawk`, branch `sample-data`, in `sample data/`.

## Prefer upstream runs before inventing our own

When an upstream project ships a runnable test/example for its own fixtures, run that exact upstream entry point first and preserve its output. Do not rewrite an upstream baseline merely to make it look like our implementation.

Biopython explicitly documents its own regression runner. The canonical first Biopython run for the FASTA/FASTQ fixtures is:

```text
cd Tests
python run_tests.py --offline test_SeqIO test_SeqIO_QualityIO
```

That uses Biopython's own tests and its own fixture directories. Its `Scripts/Performance/` directory currently contains BioSQL performance scripts rather than a motif-search benchmark, so do not mislabel those as the search baseline. For motif/search comparisons, use Biopython's own parsing/tests as the upstream parser correctness witness, then run a separately declared search workload against the same input bytes.

Use the same rule for HTSlib, bedtools, Biostrings, SeqKit, and other sources: if there is an upstream test or benchmark that directly exercises the fixture and operation we care about, preserve that run as a baseline rather than replacing it with a home-grown imitation.

## Contrast ladder

Each useful case should be able to grow through several levels. Do not require every level for every tiny change, but keep the levels separate so later work can compare like with like.

### 1. Semantic/output contrast

Run the same declared operation on the same bytes and compare exact results first.

Good seed operations include:

- exact motif positions/counts;
- GC/base counts;
- reverse complement;
- quality-threshold scans;
- simple BED/GFF/VCF field or interval filtering;
- many-pattern matching once the single-pattern oracle is solid.

The oracle should be exact output, not timing.

### 2. High-level-language contrast

For the same operation and corpus, keep competent implementations in several ecosystems when they exist, for example:

- bioawk/awk;
- Biopython/Python;
- Biostrings/R;
- ordinary C;
- later Rust/Go or another useful strong baseline;
- Idriç source expressing the same semantics.

The purpose is not a generic language shootout. It is to see how the same search/branching semantics survive different language/runtime/compiler routes.

### 3. Compiler/binary contrast

For compiled paths, record:

- source revision;
- compiler and exact version;
- optimization flags;
- target triple/ABI;
- linked/runtime dependencies;
- executable or object hash;
- text/code size.

Keep whole-program effects separate from the search kernel. Startup, parsing, allocation, compression, and runtime dispatch can otherwise hide what happened to the branch/search code.

### 4. Disassembly contrast

Disassemble comparable binaries/objects and retain the disassembly as an artifact. Compare the actual generated control flow, not just source syntax.

Look for concrete differences such as:

- linear compare/branch chains;
- jump tables or indirect branches;
- Thumb `TBB`/`TBH` or analogous target mechanisms;
- packed shift/AND/OR state updates;
- branchless masks/selects;
- vector compares and candidate masks;
- repeated loads or avoidable bounds/runtime checks;
- call boundaries that prevent an optimization from being visible;
- code-size changes.

Use the target's ordinary disassembler and record its version. When two toolchains use different assembly syntax, normalize only for presentation; preserve the raw disassembly too.

### 5. Micro-level runtime contrast

On hardware where the binary can actually run, collect narrowly relevant counters when available:

- cycles/instructions;
- branches and branch misses;
- bytes/bases processed;
- instructions per byte/base;
- cache/memory traffic when it matters;
- setup/preprocessing cost;
- code size.

Do not report native performance for a target that was only cross-compiled. Cross-compiled targets can still participate in correctness, code-generation, and disassembly contrasts.

### 6. Backend contrast

For Idriç/direct-backend work, run the same semantic case through each backend that claims the relevant operation. The point is to compare lowering decisions rather than merely prove that every backend can emit an executable.

A useful row eventually looks like:

```text
case × corpus × source language × compiler/backend × target × optimization × model/run
```

with correctness and evidence bound to that exact row.

## Contrast-suite record

Every recorded run should identify at least:

- case name and semantic operation;
- corpus file(s) and hashes;
- expected oracle/result;
- implementation/source-language identity;
- source revision;
- compiler/backend version and flags;
- target/ABI;
- worker/model/configuration that produced the change or run, when AI-authored work is being evaluated;
- binary/object hash when applicable;
- raw disassembly artifact when applicable;
- timing/counter scope when applicable;
- pass/fail/uncertain correctness verdict;
- links to retained stdout/stderr and relevant artifacts.

This follows the `ai-ci` evaluation rule that results are bound to the exact source revision, evaluator revision, model/configuration, fixture hashes, and environment. The biology suite adds compiler/code-generation evidence to that general contract.

## Comparison rules

- Correctness comes before performance.
- Compare the same semantics and same input bytes.
- Include competent baselines; do not compare an unusual backend only against deliberately weak code.
- Keep parser/decompression time separate from search-kernel time when making kernel claims.
- Preserve both high-level source and generated machine code.
- Do not infer a branch optimization from source syntax; inspect the generated code.
- Do not infer a speedup from prettier disassembly; measure it on runnable hardware.
- Preserve failures and surprising compiler output as new contrast cases.

The goal is a growing gym of reproducible cases, models, compiler paths, backends, disassemblies, and runs. A new branching/search trick should be able to enter that gym and be contrasted against existing rows without redesigning the benchmark each time.
