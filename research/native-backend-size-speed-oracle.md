# Native backend size/speed oracle

Date: 2026-08-26

## Purpose

When comparing a runtime-free backend such as the Idriç Arm Thumb path with Idris 2 RefC, AICI should not collapse "size" or "speed" into one number.

A tiny program can contain only a few useful machine instructions while depending on a much larger runtime closure. Conversely, a tiny direct-syscall program can make a pathological number of syscalls and therefore run slower than buffered libc output despite having much less language/runtime machinery.

## Seed fixture

Use a deliberately transparent output fixture:

- baseline: write one byte, `X`;
- repeated: write `X\b` 100,000 times;
- buffered equivalent: emit the same 200,000 output bytes with a bounded number of writes;
- CPU-only equivalent: same counter/branch structure with no output.

A host-side Armv7 Thumb cross-link experiment on 2026-08-26 produced:

| Fixture | code+data | minimal ELF |
| --- | ---: | ---: |
| one `X` | 17 bytes | 101 bytes |
| `X\b` × 100,000 | 30 bytes | 114 bytes |

The repeated program adds only 13 executable-file bytes because the repetition count lives in the loop, not as duplicated output data.

This is a build-size result only. The 100,000-output version deliberately performs 100,000 raw Arm/Linux `write` syscalls and has not yet been executed on the target phone.

## Required metric separation

For every backend/revision, record all of these independently:

### Artifact

- source bytes
- generated-C bytes, when applicable
- object-file bytes
- final executable bytes
- stripped executable bytes
- loadable segment bytes
- code/text bytes
- read-only data bytes
- writable data/BSS bytes

### Dependency closure

- dynamic interpreter, if any
- exact `DT_NEEDED`/shared-library list
- bytes of every required external shared object
- total unique dependency-closure bytes
- distinguish per-executable private bytes from shared/amortized system bytes
- distinguish static archive members copied into the executable from archive bytes merely present on the build machine

Do **not** report "libc size" as though a dynamically linked executable contains all of `libc.so`. Dynamic libc is an external runtime dependency and can be shared across programs. Static linking also normally pulls selected archive members rather than blindly concatenating an entire archive.

### Startup

- cold elapsed time
- warm elapsed time
- user CPU
- system CPU
- page faults when available
- maximum RSS

### Steady work

- elapsed time with stdout to `/dev/null`
- elapsed time to an actual terminal as a separate measurement
- syscall count by syscall name
- bytes written
- branch/instruction counts where practical
- allocations/frees where practical
- RefC reference-count increments/decrements where practical

Terminal output must be kept separate because PTY and rendering cost can dominate backend cost.

## RefC-specific facts to preserve

Current Idris 2 sources establish several useful boundaries:

- the official benchmark harness says it was created to provide a consistent performance metric while optimizing RefC and has been tested on Chez and RefC;
- RefC documentation calls the backend lightweight/minimal-dependency and portable, but says performance is worse than the Scheme backends;
- `support/refc/Makefile` builds the RefC runtime as `libidris2_refc.a`;
- `Compiler.RefC.CC` links generated code with `libidris2_support.a`, `-lidris2_refc`, `-lgmp`, and `-lm`, with ordinary C startup/libc behavior supplied by the selected compiler toolchain;
- Idris Prelude `putChar` maps to C `putchar`, so libc buffering can make syscall structure differ dramatically from a raw-syscall Thumb loop;
- RefC uses a tagged `Idris2_Value *` representation and reference-count machinery, but current versions include unboxing/packing optimizations. AICI must inspect the generated C/assembly before asserting that a particular loop allocates on every iteration.

Sources:

- https://github.com/idris-lang/Idris2/blob/main/benchmark/readme.md
- https://idris2.readthedocs.io/en/latest/backends/refc.html
- https://github.com/idris-lang/Idris2/blob/main/src/Compiler/RefC/CC.idr
- https://github.com/idris-lang/Idris2/blob/main/support/refc/Makefile
- https://github.com/idris-lang/Idris2/blob/main/support/refc/_datatypes.h
- https://github.com/idris-lang/Idris2/blob/main/libs/prelude/Prelude/IO.idr

## Backend comparison matrix

At minimum, run each fixture through:

1. runtime-free Arm Thumb using raw syscalls;
2. tiny C using raw syscalls;
3. C using libc I/O;
4. Idris 2 RefC;
5. Idriç Thumb at its current supported source-ABI boundary.

For RefC, add two loop representations where the source language permits it:

- a representation likely to exercise generic boxed/reference-counted values;
- a fixed-width representation selected to test current packing/unboxing optimizations.

The oracle should reject comparisons that silently change output batching, terminal destination, iteration count, numeric representation, optimization level, architecture, ABI, or static/dynamic link mode.

## Evidence shape

A useful AICI result should emit a small machine-readable record per binary, for example fields equivalent to:

```text
revision
backend
target
source_fixture
optimization
link_mode
artifact_bytes
load_bytes
text_bytes
dynamic_dependencies[]
dependency_closure_bytes
cold_elapsed_ns
warm_elapsed_ns
user_ns
system_ns
max_rss_bytes
syscalls_by_name
output_bytes
allocation_count
free_count
refcount_inc_count
refcount_dec_count
```

Unavailable counters should be explicit `unknown`, not zero.

## Interpretation rule

Never infer "backend X is faster" from the 100,000 tiny-write terminal fixture alone.

Use it to expose the cost structure. The central comparison is:

> How many bytes and how much machinery are required before the useful operation can execute, and how does that fixed floor amortize as the useful work grows?

That is the quantity relevant to composing many very small independently executable programs.