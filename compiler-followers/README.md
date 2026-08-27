# Compiler follower sweep

This directory records how compiler targets should follow `isomorphisms/idric-arm-thumb` without turning every architecture into a parallel human-guided project.

The reviewed upstream commit is in `arm-thumb.checkpoint`. `policy.tsv` records the current per-target mutatis-mutandis rule. The scheduled/manual workflow compares the selected ARM/Thumb ref with that checkpoint and writes the unreviewed commit delta plus the policy table into the GitHub Actions job summary.

The workflow is intentionally read-only. It does not modify follower repositories and it does not advance the checkpoint. A later follower-maintenance pass may use the packet to make reviewable target-specific changes and then explicitly update the checkpoint after the sweep has been reviewed.

## Policy interpretation

Two kinds of closeness are kept separate:

- **ISA closeness** measures how directly CPU lowering ideas can carry over.
- **device closeness** measures whether the whole machine/workload resembles the phone target, including heterogeneous CPU/GPU decisions.

The current modes are:

- `authority` — ARM/Thumb itself;
- `close-arm` — adapt proven work closely to another Arm/Thumb profile;
- `observe-close` — close enough to learn from, but deliberately not an active implementation priority;
- `boring-native` — preserve semantics/tests and emit straightforward target-native code, discarding Thumb-specific micro-optimization by default;
- `careful-heterogeneous` — preserve and re-evaluate higher-level CPU/GPU/precision/buffer decisions as well as CPU semantics;
- `semantic-virtual` — follow semantic capability and test progression on a virtual ISA whose execution model differs materially;
- `iron-out` — broad big-machine propagation with deliberately simple wide native realizations;
- `selective` — update when cheap, useful, or interesting rather than on every ARM change;
- `observation-only` — record applicability/deltas without ordinary implementation work;
- `separate-track` — related target whose propagation rules need a different discussion.

## WebAssembly

Wasm is deliberately a follower even though it does not resemble a physical ARM CPU. WebAssembly is a typed stack-machine virtual ISA with structured control flow and linear memory. It can therefore follow ARM/Thumb in source semantics, compiler features, exact oracles, numeric intent, address calculations, memory widths, and staged capability growth, while ignoring ARM register allocation, flags, calling convention, and instruction tricks.

The goal is not `STRH` translated mechanically into a Wasm spelling. The goal is that a proven typed 16-bit store with a particular byte-address rule acquires the corresponding Wasm linear-memory semantics.

## Shader track

The CPU follower policy is not the shader policy.

Shader compiler work lives in `isomorphisms/idris-shader-backend`. The concrete tracked branches are PowerVR/phone, Switch/Maxwell, and `target/webgpu-wgsl`. The WGSL ownership question is now settled: `idris-shader-backend:target/webgpu-wgsl` is canonical for WGSL compiler work, while `idric-embedded:webgpu` is host/runtime only.

The shader-specific propagation rules live in #21 and must distinguish shared mathematical/typed-IR semantics from shader-language lowering, precision, resource/address-space rules, execution/cooperation semantics, hardware/compiler tuning, and host/runtime boundaries. `webgpu` therefore remains `separate-track` in the CPU table and points at the canonical shader branch rather than receiving invented CPU-derived rules.

## Advancing the checkpoint

Advance `arm-thumb.checkpoint` only after a follower sweep has considered the accumulated ARM/Thumb delta. A target may legitimately record `not applicable`, remain implementation-behind, or be observation-only. None of those conditions should block ARM/Thumb development.
