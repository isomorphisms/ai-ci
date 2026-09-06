# Compiler follower sweep

Draft PR #22 implements issue #20; a passing receipt is not a claim that the draft has landed or is merge-ready. ARM/Thumb remains the primary human-guided direct CPU backend proving ground. Follower lag never blocks its development.

`arm-thumb.checkpoint` is the reviewed baseline. `policy.tsv` records each target's owner, layer, stage, propagation mode, ISA closeness, device closeness, scope and rule. The workflow resolves the selected ARM/Thumb branch once, reports the entire accumulated delta, prints the full policy, and validates `arm-thumb-sweep/` against that independently resolved snapshot.

Everything in the sweep is read-only with respect to checkpoints and follower repositories. A receipt records classification, not completed follower implementation, target execution, human approval or merge readiness.

## Machine-checked full-sweep receipt

Version 2 uses `arm-thumb-sweep/meta.tsv` and `classifications.tsv`. Metadata must contain exactly seven unique fields: `receipt_version`, `upstream_repository`, `upstream_ref`, `from`, `through`, `policy_sha256`, and `coverage`. The authority is fixed to `isomorphisms/idric-arm-thumb`; metadata cannot redirect it. The policy digest covers the byte-exact table, including all ownership, maturity, ISA/ABI rules and blockers.

For **every commit in `from..through` and every policy target**, classifications contain exactly one row:

```text
commit<TAB>dimensions<TAB>target<TAB>outcome<TAB>rationale
```

Dimensions are a unique ascending list from 1 through 5 and must agree across a commit's target rows. Rationales cannot be empty or whitespace. There are no implicit outcomes: even irrelevant rows require `not-applicable`. A template outcome such as `PENDING` fails. The validator rejects missing, duplicate, excess, unknown or stale rows and reconstructs the complete Git ancestry rather than trusting a supplied commit list or first-parent log. Side-branch commits and merge commits are included. Shallow or grafted histories fail; replacement objects are disabled.

The validator takes explicit independently obtained endpoints; there is no checkpoint-to-itself default:

```sh
UPSTREAM_GIT=/path/to/full/upstream-history \
  sh compiler-followers/validate-sweep.sh \
  compiler-followers/policy.tsv compiler-followers/arm-thumb-sweep \
  "$reviewed_from" "$resolved_upstream_head" main

sh compiler-followers/tests/test-sweep-validator.sh
```

A supplied `UPSTREAM_GIT` is a trusted local history input and is never fetched into or modified. Without it the validator clones the fixed authority into a temporary directory. An empty matrix is valid only for an independently verified zero-length range; it cannot stand in for a nonempty selected upstream delta.

Successful output is TSV containing the exact endpoints, policy and classification hashes, commit/target/row counts, `checkpoint_action=read-only`, `merge_readiness=not-asserted`, and `target_execution=not-asserted`. Output appears only after all checks pass. CI records it in the job log and summary. If upstream advances, the old receipt fails the current-snapshot gate until the newly accumulated delta is classified; ARM development is not blocked.

The checked-in initial nonempty receipt covers three commits through `3791b38eba892d2f98548b0cc843e97fe0796940`, across all 24 policy rows (72 classifications). The checkpoint is deliberately unchanged. See `arm-thumb-sweep/review.md` for the inspected changes and limits; this is not a receipt for unmerged ARM/Thumb branches or for backend execution.

## Authority is layered

- `isomorphisms/Idric` owns language semantics and target-independent checked compiler/IR contracts.
- `isomorphisms/idric-arm-thumb` owns the lead direct CPU implementation, backend seams, exact fixtures, rejection boundaries and machine-code verification.
- Each follower owns its actual ISA, ABI, object format, runtime boundary and cost decisions.

An ARM instruction, flag trick, representation, ABI or phone constraint is not a universal language rule. Record a target-independent semantic/IR decision in the core/compiler journal before treating it as binding on followers. RefC/C is not a follower backend path, fallback or correctness authority; missing direct lowering stays a red gate.

The immediate milestone clarified in issue #20 is **branching/conditionals, not function calls**. Propagate accepted semantic contracts, fixtures/oracles and verification methods, not an ARM-specific control-flow recipe. Whether a follower makes a choice easier, harder, illegal or irrelevant requires target evidence.

## Independent policy axes and review dimensions

`layer` identifies codegen, virtual codegen, an architecture catalog, a platform overlay, a target profile, a shader boundary or an unresolved target. `stage` records present maturity. `mode` records propagation policy. A branch existing proves neither implementation maturity nor codegen ownership. ISA closeness is independent of whole-device/workload closeness.

Classify every changed commit (the union of its changed hunks) by:

1. target-independent language or checked-IR semantics;
2. reusable backend seam, fixture, oracle, rejection boundary or verification method;
3. Thumb/ARMv7-specific instructions, flags, ABI, object format or optimization;
4. phone/Android SDK/JNI/runtime/device/workload integration;
5. an opportunity relevant only to some targets.

For every target record one of `apply`, `adapt`, `already-covered`, `not-applicable`, or `defer-measurement`. `apply` and `adapt` describe review decisions, not completed code changes. Deferral must explain the missing measurement or blocker. A complete matrix does not prove that the reviewer classified the changes correctly: normal substantive review remains necessary.

Keep `known`, `required`, `emitted`, and `tested` distinct. Complete inventories may grow independently; emission allow-lists require exact source fixtures, object/disassembly and executable target evidence. Inventory, platform and shader rows cannot become CPU codegen merely through a sweep outcome.

## Settled ownership and target boundaries

- Generic A64 codegen: `idric-x86-aggressive-backend:a64-backend`; the policy records a designated scaffold, not implemented support. The broad A64/SVE/SME catalog belongs to `idric-big-iron:arch/aarch64-sve`, not a second selector.
- Original Switch/Tegra X1: `idric-embedded:switch` owns platform/runtime/deployment. A64 codegen and `idris-shader-backend:target/switch-maxwell-sm53` remain separate. Whole-device/workload closeness does not imply Thumb ISA closeness. Switch 2/T239/Ampere is a separate future target.
- Apple CPU ISA/ABI/SoC atlas: `idric-x86-aggressive-backend:Apple`; modern arm64 reuses A64 and Intel targets reuse x86-64. Historical targets remain historical. Apple GPU/Metal is a separate shader track.
- WGSL compiler: `idris-shader-backend:target/webgpu-wgsl`; `idric-embedded:webgpu` is host/runtime only. Shader policy #21/#23 remains separate.
- Backend-facing XED/form inventory, instruction encyclopedia and executable x86-64 work belong in `idric-x86-aggressive-backend`. `idric-big-iron:arch/x86-64` owns an independent LLVM-derived cross-vendor catalog/comparative oracle. Neither inventory implies emitted support.
- Cortex-M7/S32K3 may reuse Thumb-2 machinery only where the exact M-profile and ABI permit; automotive remains observation-first. RP2040 is Armv6-M Cortex-M0+, not the phone's Thumb-2/VFP profile, and its PIO is a separate ISA. Its policy row is an inventory, not a backend.

RISC-V follows accepted semantics using its own registers, comparisons, branches, encodings and execution environment. RV64I + LP64 + ELF64 + Linux is one provisional hosted lane, not a user-selected universal XLEN. The embedded roadmap also names RV32. Keep RV64-only `*W`, `LD`/`SD`, LP64 and ELF64 assumptions out of shared IR; require an RV32 lane before claiming a generic RISC-V backend.

Wasm is a semantic/virtual follower: preserve numerical intent, address calculations, memory effects and fixture/oracle structure through Wasm validation, typed-stack, structured-control, module and linear-memory rules, not ARM registers, flags, ABI or instruction spellings.

POWER, s390x, A64/SVE, AVR, 8051/CH55x, MSP430 and similar catalog branches do not gain permission to start codegen from this sweep. Their separate reproducible execution gates still apply. Embedded e200 VLE/SPE/ABI is not server POWER. TriCore reference work belongs to `idric-automotive-ecu:reference/tricore-tc18`; the old embedded branch is superseded.

`rp4080` remains blocked until renamed to a concrete device with its programmable ISAs separated. Unspecialized `esp` remains blocked until an exact Xtensa or RISC-V device/profile is selected.

## Checkpoint proposals remain read-only

CI passes the immutable PR base SHA (or push-before SHA) to `check-checkpoint.sh`. If the policy did not yet exist there, bootstrap uses the reviewed seed `5f132d2f68cdd5ee7ddd98788af882598ad4c2f8`, never the candidate's chosen checkpoint. An unavailable base commit or a base containing policy but missing its checkpoint fails closed.

An unchanged checkpoint allows a prospective receipt from that checkpoint through the independently resolved upstream snapshot. A proposed checkpoint change requires the entire trusted old checkpoint-to-current-main delta, and the proposal must equal that resolved `main` head. A retained transition receipt can be rechecked when it ends at the already-reviewed checkpoint and there is no new upstream delta. Non-main inspection cannot advance the main checkpoint.

Neither script writes a checkpoint, edits followers, commits, pushes, approves or merges. Even a complete machine-checked receipt only supplies evidence for a separately reviewed checkpoint proposal. Until the entire accumulated delta is classified and reviewed, do not advance it or claim merge readiness.
