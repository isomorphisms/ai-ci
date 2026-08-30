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
  -> one_step_at_a_time
  -> backend_plan
  -> target_code
  -> package
  -> run
  -> measure
```

`one_step_at_a_time` is the plain-English name for the checked compiler handoff
where nested computation is straightened into small explicit steps and later
steps can refer to intermediate results. Compiler literature often calls one
version of this A-normal form (ANF), but AICI does not require readers or
backends to use that historical name, and different compilers may expose a
different checked intermediate form.

A temporary result in this form is not automatically a memory store. It may
later become a register value, an immediate, a folded instruction, a reused
register, a spill only when necessary, or nothing at all after optimization.
AICI therefore must not infer emitted memory traffic from the number of
one-step temporary names.

Likewise, a real source/IR **put or store** operation is a different concept
from merely naming a temporary result. Projects that use the heavy black left
arrow for `place ⬅ value` should reserve that spelling for an operation whose
semantics actually change a place; a one-step temporary name should not imply a
store that may never exist in target code.

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
| `one_step_at_a_time` | source/type checking | Potentially every backend, because this is the shared handoff from the language. |
| `backend_plan` | one-step form or another explicit compiler seam | Mainly backend structure and which operations every target must implement. |
| `target_code` | backend plan | Instruction selection, register use, branches, SIMD, and target-specific optimizations. |
| `package` | target code | ABI, entry point, linker/object format, relocations, sections, imports, and startup responsibilities. |
| runtime surface | package/run route | Whether libc, CRT, VM, JS engine, driver, OS syscalls, or another runtime is part of the deployed system. |
| `measure` | passing run/oracle | Results become comparable only when workload, observation boundary, target class, and timing method are symmetric. |

Directly writing an ELF file, for example, removes the assembler and linker
from that route, but makes the backend responsible for ELF layout and process
entry. Avoiding libc shrinks the external runtime surface, but makes the backend
responsible for the relevant system-call ABI. Those are design choices to
record, not universal requirements for every compiler target.

A second design question is **when** to break work down one step at a time.
Doing so is not inherently slow, but flattening stronger structure too early can
throw away information that would have helped optimization. Polynomial form,
finite dispatch, scans, loops, vectors, matrix operations, complex arithmetic,
and other strong semantic operations may deserve to remain recognizable until
the compiler has used the information they carry.

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
