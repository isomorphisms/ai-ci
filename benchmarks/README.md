# Compiler ladder and standard workloads

This directory separates two things that are often both called a benchmark:

1. **capability checks** — how far a compiler can carry the same small program;
2. **measurement workloads** — once the program is correct, what code size,
   dependency surface, compile time, and runtime it produces.

A compiler should not get one blended score. A result records which rung it
reached, what target it used, and the evidence for that claim.

## Plain-language compilation ladder

Use these names in AICI reports:

```text
source
  -> named_steps
  -> backend_plan
  -> target_code
  -> package
  -> run
  -> measure
```

`named_steps` is the local plain-English name for an ANF-like checked
intermediate form. The idea is simple: nested computations are broken into
small explicit steps and intermediate results are named. A backend can then
consume those steps without having to understand the whole source language.
The technical form may differ by compiler, so AICI records the actual technical
name separately rather than pretending every compiler literally uses ANF.

`backend_plan` is a small target-facing plan such as `WriteByte` and `Exit`.
It says what the backend intends to do without yet committing to x86, Thumb,
RISC-V, Wasm, or another encoding.

`target_code` is the actual target instruction or target-language stream.
`package` is the executable/container form around it: ELF, Wasm module, shader
source/module, DEX/APK payload, and so on. `run` proves the target actually
accepted and executed it. `measure` comes last because timing or size numbers
are not meaningful if the semantic oracle has not passed first.

## Dependencies and consequences

| Choice | Depends on | What changes when this choice changes |
| --- | --- | --- |
| `named_steps` | source/type checking | Potentially every backend, because this is the shared handoff from the language. |
| `backend_plan` | named steps or another explicit compiler seam | Mainly backend structure and which operations every target must implement. |
| `target_code` | backend plan | Instruction selection, register use, branches, SIMD, and target-specific optimizations. |
| `package` | target code | ABI, entry point, linker/object format, relocations, sections, imports, and startup responsibilities. |
| runtime surface | package/run route | Whether libc, CRT, VM, JS engine, driver, OS syscalls, or another runtime is part of the deployed system. |
| `measure` | passing run/oracle | Results become comparable only when workload, observation boundary, target class, and timing method are symmetric. |

Directly writing an ELF file, for example, removes the assembler and linker
from that route, but makes the backend responsible for ELF layout and process
entry. Avoiding libc shrinks the external runtime surface, but makes the backend
responsible for the relevant system-call ABI. Those are design choices to
record, not universal requirements for every compiler target.

## Standard workloads

`print-x-v1` is the smallest end-to-end compiler ladder. It is intentionally
not a speed benchmark. It asks whether one frozen source program can move
through the compiler and become an observable target program with exact output
and exit status.

`iridium-2014-v1` is the first larger workload. It exercises real data
structures and repeated updates. Timing comparisons remain disabled until both
sides use an equivalent repeated in-process harness; whole-process timings may
still be retained as observations without publishing a speed ratio.

See:

- `stages-v1.tsv` for the shared vocabulary and dependencies;
- `checks-v1.tsv` for the standard checks;
- `workloads-v1.tsv` for frozen workload definitions;
- `results-v1.tsv` for evidence-backed observations.

## Result rules

Every result is revision-specific. `pass`, `fail`, `not_verified`, and
`not_applicable` are distinct. Missing compiler seams, real-device execution,
or symmetric timing must stay `not_verified`; a different route cannot fill in
the missing evidence.

Target-specific properties are not forced into a fake universal score. For
example, a direct Linux backend can legitimately report “no assembler, linker,
CRT, or libc,” while a Wasm or shader route naturally records a host/runtime or
driver surface instead. AICI compares the declared surface rather than calling
one architecture correct and the other wrong.
