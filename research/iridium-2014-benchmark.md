# Iridium 2014 benchmark

## Upstream and credit

This benchmark is built around [Brian McKenna's (`@puffnfresh`) Iridium](https://github.com/puffnfresh/iridium), pinned at commit `2dc438475962b62f6ca8d00f0dff3add87418dec`.

Iridium is MIT licensed, copyright 2014 Brian McKenna. The historical benchmark imports the upstream code. The Idriç comparison is a semantic port of the exercised display-free kernel and carries the upstream MIT license in [`benchmarks/iridium-2014/IRIDIUM-LICENSE.txt`](../benchmarks/iridium-2014/IRIDIUM-LICENSE.txt); it does not claim authorship of Iridium.

A large thank-you to Brian. His 2014 Strange Loop presentation, **Idris: Practical Dependent Types with Practical Examples**, was memorable and inspiring, and the Iridium demonstration in particular remained a concrete example of practical dependent typing for more than a decade. The surviving presentation source is [`puffnfresh/stl-idris`](https://github.com/puffnfresh/stl-idris); its Iridium slide calls the project an abstracted window manager made from roughly 60% Idris and 40% Objective-C. The presentation repository is linked rather than copied because no root license was found there.

## What ai-ci checks

[`benchmarks/iridium-2014/IridiumBench.idr`](../benchmarks/iridium-2014/IridiumBench.idr) is a deterministic, display-free fixture around the original Iridium `StackSet` and layout code. It repeatedly performs focus/swap operations, also evaluates a column layout, and emits a small deterministic result. This gives us an executable semantic kernel that can survive changes of operating system and backend.

The versioned oracle is [`expected-output.txt`](../benchmarks/iridium-2014/expected-output.txt):

```text
40
17280
```

The first value is the focused window after 200,000 `focusDown`/`swapDown` steps from the fixed 64-window state. The second is the exact checksum of the eight rectangles produced by `columnLayout` for the fixed 1920×1080 sample stack. CI compares the executable output to this oracle before retaining timing evidence; running twice is retained as an additional determinism check, not as the correctness oracle.

[`.github/workflows/iridium-2014-benchmark.yml`](../.github/workflows/iridium-2014-benchmark.yml) currently:

1. checks out Iridium at the exact pinned commit;
2. reconstructs the legacy Hackage `00-index` at the 2014-10-16 cutoff, including the historical top-level `preferred-versions` file;
3. reconstructs Idris 0.9.14.3 under GHC 7.8.4 in a digest-pinned container and keys the compiler cache by the actual reconstructed package-index hash;
4. records compiler, C compiler/linker, host/container, Hackage-index, source-commit, and GHC package-database evidence;
5. compiles and runs the display-free Iridium kernel as Linux ELF inside that pinned container;
6. checks output against the versioned oracle and then requires a second run to be byte-identical;
7. records compile time and a three-process whole-program timing sample;
8. resolves `ldd` dependencies, hashes their files, and totals their file bytes inside the same pinned container that runs the benchmark, while runner-side tooling is limited to byte-level ELF inspection (`file`, byte size, `size`, `nm`, SHA-256, full `readelf` reports, and a separately derived stripped copy);
9. asks the same old Idris compiler to lower the full original `src/Quartz.idr` program to generated C with `-S`;
10. transfers that generated C to an Intel macOS runner, rebuilds the matching Idris C runtime and Iridium Objective-C/C boundary, and attempts to link the complete historical program as Mach-O;
11. always uploads a macOS reconstruction-status artifact, including object/link logs when modern macOS compatibility prevents a complete reconstruction;
12. if the Mach-O link succeeds, records `file`, byte size, `size`, SHA-256, `otool` headers/load commands/dylibs, and `nm` without launching a window manager on the CI host.

`Quartz.idr` contains `%link C "src/quartz.o"` and `%link C "src/ir.o"`. The original package build created those objects before compiling Quartz. Linux cannot build the Cocoa object, so the Linux `-S` step creates valid throwaway ELF objects solely to satisfy those historical link-path declarations during C generation. They are never linked into the reconstructed Mach-O; the macOS job rebuilds the real upstream C/Objective-C objects.

The full historical program is macOS/Cocoa. Therefore `readelf` is not meaningful for its final Mach-O executable. `readelf` belongs to the Linux/Android/ARM ELF members of the benchmark family; `otool` belongs to the macOS artifact.

## Fair comparison boundary

This branch establishes historical evidence plus a backend-neutral current-Idriç fixture. It does **not** claim that old Idris is faster/slower or larger/smaller than current Idriç.

Every Idriç row must preserve these conditions:

- run the same semantic fixture and check the same two semantic results; if a backend cannot express the fixture yet, record it as unsupported rather than substituting an easier program;
- keep the 64-window initial state, 200,000 focus/swap steps, and eight-rectangle layout calculation the same;
- do not make text formatting, `show`, or `putStrLn` overhead masquerade as kernel performance: the historical executable's output bytes remain its correctness oracle, but future common-kernel timing must put equivalent result-observation boundaries around both implementations;
- record exact source/compiler/backend revisions and full compile/run commands;
- distinguish host architecture and native hardware from QEMU/emulation; x86-64 CI timing is not evidence of ARM-phone speed;
- compare like optimization policies and report them explicitly rather than quietly giving one compiler a more aggressive build;
- compare unstripped with unstripped and stripped with equivalently stripped; do not compare an old symbol-rich executable with a new stripped deployment image;
- keep executable bytes separate from external runtime/library bytes and list the dependency surface for dynamically linked builds;
- use the same integer/float semantics for this value range rather than changing representation to make one backend easier;
- treat `run-time-3x.txt` as an end-to-end whole-process sample including startup. Before publishing a cross-backend speed ratio, add an equivalent protocol that separates cold startup from repeated in-process work for every backend being compared.

Keep two size/performance questions separate. A **common-kernel comparison** asks how the same StackSet/layout work performs behind equivalent input/result boundaries. A **deployment-footprint comparison** asks what each backend's naturally deployable artifact plus external runtime surface costs. Both are useful; combining them into one number would give either the old runtime-heavy build or the new runtime-free build an artificial advantage depending on what was silently included.

The startup distinction matters for the same reason: the historical ELF currently runs as a normal Linux process while a future Thumb artifact may be freestanding or launched through a different host boundary. Timing one process model against another and calling the ratio "compiler speed" would be artificial.

When the GPU backend is usable, do not call the whole window manager a GPU benchmark. Stack/event/focus control is primarily scalar host work. Only add a GPU result for a separately identified operation whose semantics are genuinely data-parallel, and include transfer, launch/bind, synchronization, and readback in end-to-end timings.

## Current Idriç fixture and archived RefC observation

[`benchmarks/iridium-2014/IdricBench.idric`](../benchmarks/iridium-2014/IdricBench.idric) is the backend-neutral current-Idriç semantic fixture. It deliberately retains the exercised Iridium `Store`/`Lens` update path, `Stack`/`StackSet` representation, dependent-length `Vect` integration, cyclic `single columnLayout`, 64-window insertion, 200,000 `swapDown . focusDown` steps, and the eight-rectangle 1920×1080 layout calculation. A direct backend row is accepted only if it produces the same byte-for-byte `40\n17280\n` oracle twice in succession.

Before the RefC freeze, PR #19 successfully ran this fixture through pinned Idriç commit `081b9cde0591154839fb5d80d76e5570e0436300` and RefC on Ubuntu 24.04 x86-64. The compact, durable provenance and measurements are retained in [`historical-refc-observation.md`](../benchmarks/iridium-2014/historical-refc-observation.md).

That run is a closed historical observation, not an active comparison row. In accordance with the cross-repository [RefC freeze](https://github.com/isomorphisms/ai-ci/issues/24), this branch contains no RefC workflow or build script, nothing depends on RefC, and no future acceptance criterion may require it. New rows must connect the same fixture and oracle to direct backends.

The archived observation kept these items explicitly unsupported, unresolved, or outside the claim rather than changing the benchmark:

- **Common-kernel speed ratio:** unsupported until the historical and Idriç executables both have a symmetric repeated in-process harness with equivalent input/result-observation boundaries. The three-process timing file is evidence only.
- **Optimization-policy equivalence:** unresolved because the historical Idris 0.9.14.3 generated-C/link policy was not normalized against the archived RefC policy. No speed ratio is reported.
- **Direct reuse of the 2014 Idris modules:** unsupported across the Idris 1 to current Idriç/Idris 2 source boundary. The comparison therefore ports the exercised display-free kernel semantically instead of deleting constructs that are difficult for the current compiler.
- **Cocoa/Effects/event loop:** outside this display-free kernel and not ported into the archived observation. This does not stand in for the separate full historical Quartz/Cocoa reconstruction.
- **Native ARM/phone performance:** not represented by this archived x86-64 observation. Any phone result must be recorded separately on real hardware.

Iridium's historical `Float` spelling and current Idriç's `Double` spelling do not by themselves imply different arithmetic width: Idris 1 later renamed that primitive. The fixture also uses integer-valued layout constants and sums exactly representable in binary floating point. The archived record preserves this naming boundary rather than claiming a representation change that the benchmark does not establish.

Deployment footprint remains separate from timing. The archived record distinguishes compiler-produced and stripped executable bytes from the resolved external runtime/library files and their byte total.

## Evidence record

For each successful run retain the produced artifacts rather than copying one headline number into prose. The artifact bundle is intended to remain the inspectable source of truth for compiler version, exact bytes, dynamic dependencies, ELF/Mach-O structure, output digest, and timing samples.

The Linux bundle records both the compiler-produced ELF and a derived stripped copy. Dynamic library resolution is performed inside the digest-pinned historical container, which is also where the benchmark actually executes; `runtime-library-files.txt` records each resolved file's byte count, SHA-256, and path. Those shared-library bytes are a dependency-surface measurement, not bytes silently charged to the executable itself. Runner-side `readelf` and `nm` inspect the immutable ELF bytes but do not define its runtime dependency set.

The archived RefC observation uses the same separation: executable bytes and a derived stripped copy are one set of measurements, while resolved dynamic-library files are recorded and totaled separately. Its startup-inclusive timing sample is retained only as whole-process evidence and does not define an active backend lane.

The macOS bundle is deliberately a **reconstruction evidence** artifact even when the final Mach-O cannot be linked on the current runner. A green portable-ELF job must not be mistaken for proof that the 2014 Cocoa application has been fully reconstructed; inspect `reconstruction-status.txt` for that claim.
