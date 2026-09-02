# Compiler follower sweep

This directory records how CPU and virtual-ISA targets should react to reviewed work from `isomorphisms/idric-arm-thumb` without turning every architecture into a parallel human-guided project.

The reviewed upstream commit is in `arm-thumb.checkpoint`. `policy.tsv` records the target owner, layer, present maturity, propagation mode, and mutatis-mutandis rule. The scheduled/manual workflow compares the selected ARM/Thumb ref with the checkpoint and writes the unreviewed commit delta plus the policy table into the GitHub Actions job summary.

The workflow is intentionally read-only. It does not modify follower repositories and it does not advance the checkpoint.

`arm-thumb-sweep/` is the machine-checked receipt for the checkpoint. Its metadata binds the exact old checkpoint, new checkpoint, upstream repository, and byte-exact policy. For every commit in a nonempty delta, `classifications.tsv` must contain exactly one outcome for every policy target. This deliberately conservative full matrix makes “possibly affected” auditable: irrelevant rows say `not-applicable`; they cannot disappear through silence. A zero-delta receipt has only the header because there are no changed commits to classify.

`validate-sweep.sh` reconstructs the exact commit range from the upstream Git history and compares the required commit × policy-target matrix with the receipt. CI obtains the old checkpoint from the PR base (or the pre-push commit), so changing the checkpoint and pretending the sweep started at the new value is rejected. The validator clones read-only, and the workflow retains `contents: read` permission.

## Authority is layered

- `isomorphisms/Idric` owns language semantics and target-independent checked compiler/IR contracts.
- `isomorphisms/idric-arm-thumb` is the primary human-guided **CPU backend proving ground**. It establishes useful backend seams, exact fixtures, rejection boundaries, and direct-machine-code verification first.
- Each follower owns its actual ISA, ABI, object format, runtime boundary, and target-specific cost decisions.

An ARM/Thumb implementation choice does not become a universal language rule merely because it was discovered first on the phone. If a phone constraint changes target-independent semantics or IR, record that decision in the core/compiler journal before treating it as binding on followers.

RefC/C is not a follower implementation path, fallback, or correctness authority. Follower codegen work is direct and must keep unsupported lowering visible as a red gate.

## Three independent policy axes

Do not infer one axis from another.

- `layer` says what the referenced branch owns: CPU codegen, virtual codegen, an architecture catalog, a platform overlay, a target profile, a shader boundary, or an unresolved target blocker.
- `stage` says what exists now. `implementation-planned` and `inventory-only` are not claims that a backend exists.
- `mode` says how reviewed ARM/Thumb work should be considered for that row.

ISA closeness and whole-device/workload closeness remain separate. The original Switch is the important example: its Cortex-A57 CPU is AArch64 rather than Thumb, while the overall Arm CPU + integrated GPU + interactive-rendering workload is relatively close to the phone.

## Review every ARM/Thumb change before propagation

Classify each changed commit or hunk by what actually changed:

1. target-independent language or checked-IR semantics;
2. reusable backend seam, fixture, oracle, rejection boundary, or verification method;
3. Thumb/ARMv7-specific instruction selection, flags, ABI, object format, or optimization;
4. phone/Android runtime, SDK/JNI, device, renderer, or workload-specific integration;
5. a target-specific opportunity that belongs only on some follower.

Then record one outcome for each relevant target:

- `apply` — the same target-independent decision belongs there;
- `adapt` — the decision belongs there with target-native lowering;
- `already-covered` — the target already expresses the result differently;
- `not-applicable` — the change is genuinely source-target-local;
- `defer-measurement` — applicability is plausible but target evidence is missing.

Never interpret “follower” as instruction-for-instruction copying or as an instruction to port every ARM repository workload everywhere.

## Complete architecture knowledge is not codegen support

Every architecture project keeps these states distinct:

1. `known` — present in the pinned architecture catalog;
2. `required` — required by a selected concrete target/profile;
3. `emitted` — permitted in generated code;
4. `tested` — backed by generated object/disassembly and executable evidence.

Complete instruction inventories may grow independently. Executable emission surfaces grow only from exact source fixtures and target-native oracles. An inventory branch must never be treated as an implementation branch.

## Settled ownership boundaries

- Generic executable AArch64 codegen belongs on `isomorphisms/idric-x86-aggressive-backend:a64-backend`. It is currently a designated scaffold, not an implemented backend.
- `isomorphisms/idric-big-iron:arch/aarch64-sve` owns the broad A64/SVE/SME architecture catalog and research notes, not a competing instruction selector.
- `isomorphisms/idric-embedded:switch` owns original-Switch platform/runtime/deployment integration. It does not own AArch64 instruction selection or Maxwell shader compilation.
- `isomorphisms/idric-x86-aggressive-backend:Apple` is an Apple CPU ISA/ABI/SoC target atlas. Modern Apple CPU codegen reuses the generic A64 owner; Intel-Mac codegen reuses the x86-64 owner. Apple GPU/Metal work is a separate shader track.
- `isomorphisms/idris-shader-backend:target/webgpu-wgsl` is canonical for WGSL compiler work. `isomorphisms/idric-embedded:webgpu` is host/runtime only.

## RISC-V XLEN boundary

The existing `architecture-first-seed` pins one convenient hosted oracle: RV64I + LP64 + ELF64 + Linux userspace. That tuple was selected as an initial QEMU/Linux lane; it is not a declaration that the shared RISC-V backend or the user's embedded goals are intrinsically 64-bit.

The earlier embedded roadmap names RV32. Keep XLEN applicability explicit, do not leak RV64-only `*W`, `LD`/`SD`, LP64, or ELF64 assumptions into target-independent IR, and add an RV32 lane before describing the backend as generic RISC-V.

## Explicit blockers and moved branches

- `idric-embedded:rp4080` names no real Raspberry Pi MCU. Do no implementation work until it is renamed to a concrete target such as RP2350 and every programmable ISA on that device is separated.
- `idric-embedded:esp` is not one ISA. Select an exact Xtensa or RISC-V device/profile first.
- `idric-embedded:tricore-aurix` is superseded by `idric-automotive-ecu:reference/tricore-tc18`.
- `idric-big-iron:arch/x86-64` owns an independent LLVM-derived cross-vendor architecture catalog and comparative notes. Backend-facing XED/form inventory, the instruction encyclopedia, and executable codegen belong in `idric-x86-aggressive-backend`. Neither catalog implies emitted support.
- Switch 2/T239/Ampere is not covered by the original-Switch Tegra-X1/Maxwell row.

## Advancing the checkpoint

Advance `arm-thumb.checkpoint` only after one reviewed sweep has classified the entire accumulated ARM/Thumb delta and recorded an outcome for every policy row that could be affected. `not-applicable`, observation-only, inventory-only, and implementation-behind are valid outcomes; silence is not.

Until a machine-checked sweep receipt exists, an automated or low-context pass must not advance the checkpoint. Follower lag never blocks ARM/Thumb development.
