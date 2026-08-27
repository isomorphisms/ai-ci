# Shader follower sweep

This track is deliberately separate from the CPU follower sweep. GPU/shader propagation cannot be modeled by copying ARM/Thumb notions such as ISA closeness, register similarity, or a single boring-native lowering rule.

The tracked compiler branches are:

- `isomorphisms/idris-shader-backend:target/powervr-ge8322-gles` — empirical phone reference;
- `isomorphisms/idris-shader-backend:target/switch-maxwell-sm53` — original Switch / Tegra X1 Maxwell follower;
- `isomorphisms/idris-shader-backend:target/webgpu-wgsl` — canonical WGSL compiler branch and language peer.

`idric-embedded/webgpu` is not a WGSL compiler authority. It remains a host/runtime/platform breadcrumb. The shader branch owns WGSL emission plus only the minimum WebGPU host boundary needed to validate, run, and prove generated shaders.

## Authority model

There is intentionally no single authority for every layer.

- **Shared mathematical/rendering semantics and typed shader-IR contracts** are the portable contract. A useful correction may be discovered on any target, but it should be expressed without vendor assumptions before becoming shared.
- **PowerVR/phone** is the primary empirical reference because it is the real inexpensive phone workload being exercised. It is where device/driver receipts, framebuffer oracles, precision experiments, and PowerVR-specific tuning are proved.
- **Switch/Tegra X1** is a hardware follower, not a textual GLSL clone. UAM/deko3d and inspectable TGSI/DKSH/Maxwell code provide an independent compiler oracle.
- **WebGPU/WGSL** is a language peer. It follows shared mathematical and IR semantics, but `target/webgpu-wgsl` is canonical for WGSL syntax, validation, address spaces, uniformity rules, resource layout, optional features, and the compiler-facing WebGPU contract. Portable fixes discovered there may flow back into the common IR.

This makes directionality depend on the kind of decision rather than on one global source branch.

## Review dimensions

Every accumulated shader change should be classified before propagation.

1. **Mathematical/rendering semantics and typed IR** — normally propagate to all three targets. This includes value-to-color semantics, bounded shader computation, representation invariants, accepted/rejected source constructs, and exact or tolerance-based oracles.
2. **Shader-language lowering** — preserve the operation and legality, not the spelling. GLSL ES choices may adapt to UAM-compatible GLSL; WGSL is rewritten under WGSL's own type, control, validation, and builtin rules.
3. **Precision/value width** — preserve F16/F32 semantic intent, then prove each lowering independently. PowerVR `mediump`, Maxwell FP16 behavior, and WGSL optional `f16` are not interchangeable promises.
4. **Resources, bindings, layouts, and address spaces** — preserve the abstract resource class and byte/layout contract where shared, then map it to GLES, deko3d/UAM, or WebGPU/WGSL rules. Do not flatten distinct memory/resource classes merely to make targets look alike.
5. **Execution, derivatives, barriers, subgroups/quads, and uniformity** — share the semantic capability only when it is actually common. Legality, lane grouping, participation, synchronization, and divergence rules remain target-specific.
6. **Hardware/compiler optimization** — local by default. PowerVR TBDR/USC expression shaping, Maxwell predicates/dual issue/native scheduling, or implementation-specific WebGPU lowering do not propagate by resemblance. A portable optimization must be re-justified as a shared transformation.
7. **Host/runtime behavior** — propagate only the compiler-visible boundary. Android GLES driver setup, Switch deko3d runtime work, and general WebGPU host/runtime work belong to their platform owners rather than being copied as shader rules.

## Target policy table

`policy.tsv` records one row per tracked target. Its columns are deliberately shader-specific:

- `role` — phone reference, hardware follower, or language peer;
- `math_ir` — relation to shared mathematical/IR decisions;
- `language` — local, adapted, or canonical language lowering;
- `precision` — measure, remeasure, or validate on the target;
- `resources` — local, adapted, or canonical resource model;
- `execution` — local, adapted, or language-semantic execution rules;
- `host_boundary` — target-local runtime or compiler-facing boundary;
- `evidence` — the strongest ordinary acceptance evidence for that target.

These columns replace CPU-style ISA/device closeness because those axes hide the distinctions that matter for shaders.

## Checkpoints

`checkpoints.tsv` records the branch snapshot from which new changes need review. The initial values are the branch heads when this policy was adopted. They are **not** a claim that the three branches were semantically identical or fully caught up with one another at that instant.

Advance a target checkpoint only after the accumulated delta for that target has been reviewed under this policy. A review may legitimately conclude:

- `apply` — the same shared decision belongs on another target;
- `adapt` — the decision belongs there but needs target-native lowering;
- `already-covered` — the target already expresses the semantic result differently;
- `not-applicable` — the change is genuinely local to its source target;
- `defer-measurement` — the semantic idea is plausible but target evidence is still missing.

Follower lag does not block phone development, and WGSL does not lose ownership of WGSL compiler work merely because the phone is the empirical reference.

## CI behavior

The scheduled/manual workflow is read-only. It:

1. validates the checked-in shader policy and checkpoints;
2. resolves the current head of each tracked target branch;
3. reports commits accumulated since that target's checkpoint;
4. prints the shader-specific policy table and review dimensions into the job summary;
5. warns when one or more tracked branches have unreviewed changes;
6. never mutates target repositories and never advances a checkpoint automatically.

The resulting packet is intended for a later human/AI sweep that classifies each change by the dimensions above and opens reviewable target-specific PRs only where warranted.
