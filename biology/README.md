# Biology search contrast gate

This directory makes the standing biology search/branch comparison rule executable.

The gate has two jobs:

1. verify that the shared `isomorphisms/bioawk` sample corpus still contains the exact upstream bytes recorded in `sample data/SOURCES.tsv`;
2. run the same exact semantic cases against a built-in C oracle and, when supplied, a backend candidate executable.

It is intentionally small. It is not a general benchmarking framework and it does not make performance claims on targets that cannot actually run.

## Built-in operations

The first operations are enough to exercise the branch/search ideas that motivated the suite:

- `bytes-count FILE NEEDLE` — overlapping exact byte-string count over the complete file;
- `fasta-motif-count FILE MOTIF` — overlapping exact motif count over FASTA sequence bodies, with records kept separate;
- `fasta-base-histogram FILE -` — exact `A/C/G/T/N/other` counts over FASTA sequence bodies, giving a stable many-way-dispatch workload.

`cases.tsv` applies these to the shared FASTA/FASTQ/SAM/VCF/BED/GFF fixtures. More operations should be added only when they correspond to a real compiler/search question and have an exact oracle.

## Candidate protocol

A backend probe is one executable. The gate invokes it as:

```text
candidate OPERATION FILE ARGUMENT
```

It must write exactly one result line and exit zero. The result must equal the independent C oracle exactly.

Examples:

```text
candidate bytes-count sample.fastq ACGT
candidate fasta-motif-count reference.fa ACGT
candidate fasta-base-histogram reference.fa -
```

This deliberately keeps the semantic boundary above the machine realization. A backend is free to use ordinary conditional branches, a jump table, table-driven DFA transitions, Shift-Or/Shift-And state, SIMD candidate scans, branchless masks, or another correct strategy.

## Direct command-line use

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
  -o /tmp/aici-biology src/aici_biology.c

/tmp/aici-biology verify-corpus \
  '../bioawk/sample data/SOURCES.tsv' \
  '../bioawk/sample data'

/tmp/aici-biology oracle biology/cases.tsv '../bioawk/sample data'

/tmp/aici-biology compare \
  biology/cases.tsv \
  '../bioawk/sample data' \
  ./my-backend-biology-probe
```

## GitHub Actions use

Check out the backend repository normally, check out the shared corpus, then invoke this action. While the gate PR is open, use its branch; after merge, use the normal pinned `ai-ci` revision.

```yaml
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
  with:
    repository: isomorphisms/bioawk
    ref: sample-data
    path: _bioawk
- uses: isomorphisms/ai-ci/biology@biology-search-contrast-gym
  with:
    corpus_root: _bioawk/sample data
    candidate: ./build/backend-biology-probe
```

If `candidate` is omitted, the action still verifies the corpus and emits the oracle rows. This is useful before a backend can execute the semantic operation. Once a backend declares support, supply its candidate executable so a wrong lowering becomes a failing gate.

The action writes `biology-contrast-results.tsv` in the caller workspace and exposes that path as the `results` output. Callers may upload or retain it with their other compiler/disassembly evidence.

## What this gate does not do

This gate proves semantic agreement and corpus identity. It does not infer that one branch strategy is faster from the source or disassembly. Performance work still needs the evidence ladder in `docs/biology-search-contrast-gym.md`: retain object/binary identity and raw disassembly, then collect timing/counters only on hardware where the binary really runs.

Cross-repository anchors remain `computer-science#23/#24/#26`, `Idric#20/#21`, the relevant backend issue, and `bioawk#2` for the corpus.
