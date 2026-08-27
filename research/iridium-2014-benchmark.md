# Iridium 2014 benchmark

## Upstream and credit

This benchmark is built around [Brian McKenna's (`@puffnfresh`) Iridium](https://github.com/puffnfresh/iridium), pinned at commit `2dc438475962b62f6ca8d00f0dff3add87418dec`.

Iridium is MIT licensed, copyright 2014 Brian McKenna. The benchmark imports the upstream code; it does not copy it into ai-ci or claim authorship of it.

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
3. reconstructs Idris 0.9.14.3 under GHC 7.8.4 in a digest-pinned container and caches that toolchain under a cache key tied to the package universe;
4. records compiler, host/container, Hackage-index, source-commit, and GHC package-database evidence;
5. compiles and runs the display-free Iridium kernel as Linux ELF;
6. checks output against the versioned oracle and then requires a second run to be byte-identical;
7. records compile time and a three-process whole-program timing sample;
8. records `file`, byte size, `size`, `ldd`, `nm`, SHA-256, full `readelf` reports, an equivalently stripped copy, and resolved shared-library file sizes;
9. asks the same old Idris compiler to lower the full original `src/Quartz.idr` program to generated C with `-S`;
10. transfers that generated C to an Intel macOS runner, rebuilds the matching Idris C runtime and Iridium Objective-C/C boundary, and attempts to link the complete historical program as Mach-O;
11. always uploads a macOS reconstruction-status artifact, including object/link logs when modern macOS compatibility prevents a complete reconstruction;
12. if the Mach-O link succeeds, records `file`, byte size, `size`, SHA-256, `otool` headers/load commands/dylibs, and `nm` without launching a window manager on the CI host.

`Quartz.idr` contains `%link C "src/quartz.o"` and `%link C "src/ir.o"`. The original package build created those objects before compiling Quartz. Linux cannot build the Cocoa object, so the Linux `-S` step creates valid throwaway ELF objects solely to satisfy those historical link-path declarations during C generation. They are never linked into the reconstructed Mach-O; the macOS job rebuilds the real upstream C/Objective-C objects.

The full historical program is macOS/Cocoa. Therefore `readelf` is not meaningful for its final Mach-O executable. `readelf` belongs to the Linux/Android/ARM ELF members of the benchmark family; `otool` belongs to the macOS artifact.

## Fair comparison boundary

This branch establishes historical evidence. It does **not** yet claim that old Idris is faster/slower or larger/smaller than current Idriç.

When an Idriç backend reaches this source surface, the cross-backend row must preserve these conditions:

- run the same semantic fixture and the same versioned output oracle; if a backend cannot express the fixture yet, record it as unsupported rather than substituting an easier program;
- keep the 64-window initial state, 200,000 focus/swap steps, and eight-rectangle layout calculation the same;
- record exact source/compiler/backend revisions and full compile/run commands;
- distinguish host architecture and native hardware from QEMU/emulation; x86-64 CI timing is not evidence of ARM-phone speed;
- compare like optimization policies and report them explicitly rather than quietly giving one compiler a more aggressive build;
- compare unstripped with unstripped and stripped with equivalently stripped; do not compare an old symbol-rich executable with a new stripped deployment image;
- keep executable bytes separate from external runtime/library bytes and list the dependency surface for dynamically linked builds;
- use the same integer/float semantics for this value range rather than changing representation to make one backend easier;
- treat the current `run-time-3x.txt` as an end-to-end whole-process sample including startup. Before publishing a cross-backend speed ratio, add an equivalent protocol that separates cold startup from repeated in-process work for every backend being compared.

That last point matters because the historical ELF currently runs as a normal Linux process while a future Thumb artifact may be freestanding or launched through a different host boundary. Timing one process model against another and calling the ratio "compiler speed" would be artificial.

When the GPU backend is usable, do not call the whole window manager a GPU benchmark. Stack/event/focus control is primarily scalar host work. Only add a GPU result for a separately identified operation whose semantics are genuinely data-parallel, and include transfer, launch/bind, synchronization, and readback in end-to-end timings.

## Evidence record

For each successful run retain the produced artifacts rather than copying one headline number into prose. The artifact bundle is intended to remain the inspectable source of truth for compiler version, exact bytes, dynamic dependencies, ELF/Mach-O structure, output digest, and timing samples.

The Linux bundle records both the compiler-produced ELF and a derived stripped copy. It also records the installed files resolved by `ldd`; those shared-library bytes are a dependency-surface measurement, not bytes silently charged to the executable itself.

The macOS bundle is deliberately a **reconstruction evidence** artifact even when the final Mach-O cannot be linked on the current runner. A green portable-ELF job must not be mistaken for proof that the 2014 Cocoa application has been fully reconstructed; inspect `reconstruction-status.txt` for that claim.
