# Holomorphic explorer evidence boundary

This note gives future CI work a shared vocabulary for the whole-plane explorer without copying its mathematical derivation or making a benchmark fixture the source of truth.

The canonical application contract is [`isomorphismes/analytic-continuation/docs/holomorphic-mathematical-contract.md`](https://github.com/isomorphismes/analytic-continuation/blob/main/docs/holomorphic-mathematical-contract.md). General complex/projective numerical semantics and their cross-backend corpus belong to the Idriç complex-arithmetic work. An ai-ci profile may consume those sources by immutable revision; it must not redefine them.

## Evidence layers

| Layer | What it can establish | What it cannot establish |
| --- | --- | --- |
| Mathematical proof/reference | The declared function space is admissible; `exp(q)` is entire and nonzero for entire `q`; the normalized Riesz representer has the claimed minimum norm | That code implements the formulas or that motion looks good |
| Host numerical oracle | Descriptor evaluation, prescribed local data, `q`, `Re(q)`, `Im(q)`, `R exp(q)`, and named identities at exact cases/tolerances | A theorem merely because a finite sample passed; backend or device execution |
| Backend agreement | A named backend matches the versioned host/numerical corpus under declared precision and exceptional-value policy | Shader compilation/loading/execution, untested inputs, or visual quality |
| GPU numeric/image oracle | Generated shader bytes were compiled, linked, loaded, executed, and read back; numeric channels or pixels match a named oracle/tolerance | Holomorphy inferred from RGB, `dFdx`/`dFdy`, or screenshots alone |
| Target-device receipt | The exact artifact executed the tested path on named real hardware/driver and produced bound logs/readback/screenshots | General device coverage or mathematical correctness beyond the linked evidence |
| Visual acceptance | The user accepted scale, density, amplitude, phase/sign, timing, overlap, cadence, and the observed motion | A universal mathematical optimum or a backend semantic change |

A later layer supplements earlier evidence; it does not replace it. In particular, a green device run cannot repair a wrong function-space definition, and a proof cannot show that a shader binary was loaded.

## Capability vocabulary

These names are suitable as corpus metadata, profile requirements, or receipt fields once an executable profile is justified:

- `complex-arithmetic-semantics` — the versioned Idriç complex/projective corpus and exceptional-value policy are identified;
- `entire-perturbation-reference` — a host oracle evaluates the admitted whole-plane descriptor family independently of Android/GPU code;
- `divisor-preservation` — evidence binds the tested `R exp(q)` decomposition to explicit zeros/poles and a nonvanishing entire factor;
- `reproducing-representer-reference` — value/derivative normalization, gauge, norm convention, and minimum-norm identity are named and checked at the appropriate proof/reference layer;
- `shader-follower-parity` — an already-approved descriptor is evaluated and `Re(q)` is handed to log modulus while `Im(q)` is handed to phase before canonical Wegert coloring;
- `target-hardware-receipt` — generated/compiled/linked/loaded/executed/readback evidence is bound to the artifact, source revision, device, OS, GPU, driver, and test case.

Each capability needs its own source revision and evidence pointers. Do not collapse them into a single `holomorphic=true` flag.

## Required negative boundaries

An eventual verifier should reject claims based only on:

- RGB difference or a screen-space derivative as certification of holomorphy;
- the historical disc-Bergman descriptor relabeled as an entire whole-plane descriptor;
- a hard-coded finite coefficient count presented as the definition of entire freedom;
- source generation without shader compilation and link evidence;
- shader compilation without load, execution, and readback evidence;
- emulator success relabeled as target-phone acceptance;
- visual approval relabeled as a minimum-norm theorem, or the theorem relabeled as aesthetic approval.

The present note is acceptance vocabulary, not an implemented ai-ci profile. When stable descriptor fixtures exist, implementation should add good and targeted known-bad cases under the ordinary ai-ci diagnostic-coverage rules rather than weakening those rules for this application.
