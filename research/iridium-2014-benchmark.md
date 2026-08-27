# Iridium 2014 benchmark

## Upstream and credit

This benchmark is built around [Brian McKenna's (`@puffnfresh`) Iridium](https://github.com/puffnfresh/iridium), pinned at commit `2dc438475962b62f6ca8d00f0dff3add87418dec`.

Iridium is MIT licensed, copyright 2014 Brian McKenna. The benchmark imports the upstream code; it does not copy it into ai-ci or claim authorship of it.

A large thank-you to Brian. His 2014 Strange Loop presentation, **Idris: Practical Dependent Types with Practical Examples**, was memorable and inspiring, and the Iridium demonstration in particular remained a concrete example of practical dependent typing for more than a decade. The surviving presentation source is [`puffnfresh/stl-idris`](https://github.com/puffnfresh/stl-idris); its Iridium slide calls the project an abstracted window manager made from roughly 60% Idris and 40% Objective-C. The presentation repository is linked rather than copied because no root license was found there.

## What ai-ci checks

[`benchmarks/iridium-2014/IridiumBench.idr`](../benchmarks/iridium-2014/IridiumBench.idr) is a deterministic, display-free fixture around the original Iridium `StackSet` and layout code. It repeatedly performs focus/swap operations, also evaluates a column layout, and emits a small deterministic result. This gives us an executable semantic kernel that can survive changes of operating system and backend.

[`.github/workflows/iridium-2014-benchmark.yml`](../.github/workflows/iridium-2014-benchmark.yml) currently:

1. checks out Iridium at the exact pinned commit;
2. reconstructs a historical Idris 0.9.14.3 C-backend toolchain under GHC 7.8.4;
3. compiles and runs the display-free Iridium kernel as Linux ELF;
4. runs the fixture twice before timing and requires byte-identical output;
5. records compile time and a three-run timing sample;
6. records `file`, byte size, `size`, `ldd`, `nm`, SHA-256, and full `readelf` header/section/program-header/dynamic/symbol/relocation reports;
7. asks the same old Idris compiler to lower the full original `src/Quartz.idr` program to generated C with `-S`;
8. transfers that generated C to an Intel macOS runner, rebuilds the matching Idris C runtime and Iridium Objective-C/C boundary, and attempts to link the complete historical program as Mach-O;
9. if that Mach-O link succeeds, records `file`, byte size, `size`, SHA-256, `otool` headers/load commands/dylibs, and `nm` without launching a window manager on the CI host.

The full historical program is macOS/Cocoa. Therefore `readelf` is not meaningful for its final Mach-O executable. `readelf` belongs to the Linux/Android/ARM ELF members of the benchmark family; `otool` belongs to the macOS artifact.

## Future backend comparison

When the Idriç Thumb backend reaches this source surface, compile the same deterministic kernel rather than inventing a different microbenchmark. Record both executable bytes and external runtime/library dependencies. The interesting comparison is not only `text` size; a small dynamically linked executable and a freestanding native image make different deployment assumptions.

When the GPU backend is usable, do not call the whole window manager a GPU benchmark. Stack/event/focus control is primarily scalar host work. Only add a GPU result for a separately identified operation whose semantics are genuinely data-parallel, and include transfer, launch/bind, synchronization, and readback in end-to-end timings.

Emulation is acceptable for architecture-correctness and binary inspection. It is not evidence that one backend is faster on the physical Android phone. Native-phone timings should remain a separate row when they become available.

## Evidence record

For each successful run retain the produced artifacts rather than copying one headline number into prose. The artifact bundle is intended to remain the inspectable source of truth for compiler version, exact bytes, dynamic dependencies, ELF/Mach-O structure, output digest, and timing samples.
