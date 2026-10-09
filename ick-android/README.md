# Pinned ICK compiler for Android C

This action builds the C-only ICK compiler at
`fbe86e23d55cfec2000c08e61deea2a407fd7175`, using its immutable GCC reference
`6294f1d9e7536e5ffcde09d1528c918d63abfef5`. Host GCC/G++ bootstrap ICK.
Maintained consumer C is compiled by the resulting ICK compiler. The action
supports `armeabi-v7a`, `arm64-v8a`, and `x86_64`; call it once per ABI.

Inputs are `abi` and `ndk`, the absolute path to the consumer's installed NDK.
Outputs are `compiler`, `target_flags`, `header_target`, `gnu_target`, and
`header_overlay`, and `builtin_include`. The compiler is the raw GNU-target ICK driver; it is also
usable with an explicitly declared GNU/Linux header, runtime and linker
profile. Android headers are selected by the consumer's source-stage flags.
The application retains its NDK revision and minimum API decision. Qualification
uses API 26 and also requires strict API-26 declarations to fail from API 25.
If the existing application defines `_FORTIFY_SOURCE`, also supply that level
through the `fortify-source` action input (`FORTIFY_SOURCE` for Make). It is
applied to the real Bionic-header qualification and must pass before the action
exports a compiler. The default leaves the macro undefined, and the receipt
records the tested setting.

For `_FORTIFY_SOURCE=2`, API 26 or later, the action selects the bounded
[Bionic Fortify adapter](fortify/README.md). Add `-I<header_overlay>` before
the NDK include directories. The adapter keeps the original public Bionic
headers and checked runtime ABI, supplies eleven GCC-compatible fortified
functions, and rejects the other thirty-seven fortified public functions. It keeps
the original macro value and object-size checks. Unsupported APIs, functions
or Fortify levels fail; the producer does not undefine hardening or erase
Clang attributes to make a consumer pass. With no requested Fortify setting,
`header_overlay` is empty and the original NDK headers are used directly.

| Android ABI | ICK GNU target | NDK header directory | Baseline flags |
| --- | --- | --- | --- |
| armeabi-v7a | arm-linux-gnueabi | arm-linux-androideabi | `-marm -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp` |
| arm64-v8a | aarch64-linux-gnu | aarch64-linux-android | `-ffixed-x18` |
| x86_64 | x86_64-linux-gnu | x86_64-linux-android | `-march=x86-64-v2 -mno-avx -mno-movbe` |

The compiler does not supply an Android runtime or sysroot. Consumer build
rules compile each owned C translation unit to assembly with ICK, assemble
that file with the NDK, then link the resulting objects with the NDK. Ordinary
NDK platform source such as `android_native_app_glue.c` stays in its declared
NDK stage. Do not pass owned glyph-bearing C to the NDK compiler or silently
restore ordinary source spellings when ICK fails.

For the ICK source stage, combine `target_flags` with the application's flags
and include paths, `-S`, and these explicit platform arguments:

* `--sysroot=<ndk>/toolchains/llvm/prebuilt/linux-x86_64/sysroot`
* `-nostdinc -isystem <builtin_include>`
* `-isystem <sysroot>/usr/include`
* `-isystem <sysroot>/usr/include/<header_target>`
* `-D__ANDROID__ -D__ANDROID_API__=<application minimum API>`
* `-D__ANDROID_MIN_SDK_VERSION__=<same application minimum API>`
* `-DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD`

The ICK resource headers must precede the NDK directories. In particular,
GCC's `stdatomic.h` supplies this compiler's atomic builtins; selecting Bionic's
Clang-only atomic implementation is a producer error. `-nostdinc` also prevents
implicit host-header discovery. CMake resolves this directory from the exact
driver and checks its `stdatomic.h` and `stddef.h` before compiling.
Both API macros must match: r29's Bionic availability guards use
`__ANDROID_MIN_SDK_VERSION__`, and leaving it undefined hides required API
declarations despite a correct `__ANDROID_API__` value. The qualifier checks
that API26 declarations are exposed and keeps both API25 negative controls.

Keep normal optimization, warnings, PIC, stack protection and API requirements
from the consumer's existing build. NDK assembly consumes the emitted `.s`
file with the matching target driver and flags. NDK linking consumes objects;
it does not recompile the owned C source. For dynamic Android executables,
compile C with `-fPIC` and retain `-pie` at link time. GNU `-fPIE` can emit
COPY relocations for external data such as `stderr`; Android's linker rejects
those relocations before `main`. Inspect final executables with NDK
`llvm-readelf -r` and reject every `R_*_COPY` relocation.
For debug-enabled source, use `-gdwarf-4 -gno-variable-location-views` while
retaining the original `-g`. This selects a debug encoding accepted by the
NDK assembler; the qualifier exercises it on all three ABIs.

## CMake consumers

`OwnedC.cmake` exposes `ick_android_objects(output NAME name SOURCES ...
INCLUDES ... OPTIONS ... DEFINITIONS ... STANDARD 17)`. Configure the normal
Android NDK CMake toolchain and supply `ICK_COMPILER`, `ICK_TARGET_FLAGS`, and
`ICK_HEADER_TARGET` from the action. `ICK_COMPILER_OPTIONS` supports an explicit
compiler search prefix for local qualification. It checks the selected ABI,
GNU compiler target, NDK sysroot and numeric API floor before generating rules.
Pass the optional `ICK_HEADER_OVERLAY` output when Fortify 2 was selected.
An installed stage can be loaded through
`ick_android_stage(ROOT "/absolute/stage" FORTIFY_SOURCE 2)`; omit the final
argument only if the consumer does not request this Fortify profile.

Add the returned external objects to the existing library, and keep upstream
NDK glue in its ordinary source list. Pass the original target's owned-source
options and definitions to this call. The helper retains directory, source,
global CMake and build-type flags, including Fortify, and generates ordinary
header dependencies. It uses DWARF 4 and disables GNU variable-location view
directives because the NDK assembler does not accept the default encoding;
normal debug information remains. Clang's `-fno-limit-debug-info` is mapped
to GNU's `-fno-eliminate-unused-debug-types`, preserving complete type data.
Unsupported compiler flags or hardened headers fail the source stage.

The underlying `Makefile` also runs outside GitHub Actions: `all` uses `ABI`,
`ICK_SOURCE`, `ICK_BUILD`, and `ICK_STAGE`; `qualify` additionally uses `NDK`
and the consumer's optional `FORTIFY_SOURCE`. The source checkout must include
the exact GCC submodule. Bootstrap packages are the C/C++ build tools, flex,
bison, texinfo, GMP/MPFR/MPC development libraries, and GNU binutils for the
selected target. The consumer still uses ICK and NDK for its declared stages.
The `archive-stage` and `restore-stage` targets take `ABI`, `ICK_STAGE` and
`ICK_ARCHIVE` for workflow artifact transfer. Restore checks the executable
and exact target; callers still run qualification for their NDK profile.

## Qualification

The action requalifies cache hits. Its Makefile compiles the shared native
`assignment-arrow.c` fixture at O0 and O2, including literal ←, × and ÷, and
produces Android executables with the NDK. It also compiles ICK's pinned
nullability, availability and real Bionic-header fixtures, links the header
fixture as an Android shared library, and checks every output's ELF target and absence of COPY relocations.
The Android glyph fixture reads all three standard-stream pointers. An x86_64
negative control uses the former `-fPIE` source flags and must actually produce
`R_X86_64_COPY`, proving that the inspected boundary catches this failure.
Strict API-26 availability must be rejected at API 25 at the intended
diagnostic. Compiler, NDK and artifact hashes are retained in
`<stage>/qualification/`, alongside an explicit `android_execution NOT_RUN`.
The native `ick-host` producer separately executes the semantic fixture and its
deliberately wrong division control, including a `sizeof` quotient macro and
a separate intended rejection of `#if` division.
All ABIs also compile and statically link an atomic-int/atomic-flag fixture at
O0/O2 through the exact compiler resource headers. The x86_64 Bionic executables
run on Linux and check initialization, lock freedom, ordered load/store,
read-modify-write, compare/exchange and flags. This is a scalar atomic profile,
not acceptance of arbitrary sizes, out-of-line libatomic, or concurrent app behavior.

The exact compiler revision includes the extraction-only lowering repair in
[ICK PR #85](https://github.com/dilapidated-shed/ick/pull/85). All ABIs compile,
assemble, and statically link its independent Cartesian-component regression
at O0/O1/O2/O3/Os. The x86_64 Bionic executables run directly on Linux; the
other two qualification receipts explicitly record execution as not run.
The fixture checks member, index, argument, inline, and direct-language paths
while retaining physical polar bytes. Consumers still test their actual
renderer and foreign boundaries. The earlier dated qualification TSV records
the historical c61 builds; the [extraction repair receipt](../ick-host/qualification/complex-extraction-2026-10-09.tsv)
distinguishes the new local x86 frontend check from fresh hosted cross builds.
The shared source-boundary workflow retains each successful compiler stage
alongside its source, NDK, ELF, and runtime qualification evidence.

When Fortify 2 is selected, every ABI also compiles and statically links the
actual Bionic overflow fixture at O1, O2, O3 and Os. On an x86_64 Linux runner,
the x86_64 Bionic executables run directly: each requires twenty-two child
overflows to terminate with SIGABRT, including pointer argument side effects.
A deliberately unfortified read control must fail with exit 55. Every ABI
also requires all thirty-seven unsupported fortified functions and the API-25
profile to fail at their intended diagnostics. These runtime results use
actual Bionic on a Linux host; they do not imply Android device acceptance.

Android execution, app
behavior, packaging and physical-device acceptance remain consumer checks.
The glyph contract remains C-only, after preprocessing: binary ÷ aliases `/`;
`÷=` and preprocessor arithmetic are outside that contract. C++ and Objective-C
are separate language surfaces. Keep `_Complex` representations inside their
qualified ICK boundary; this action does not establish cross-compiler complex
ABI compatibility or a replacement ICK runtime.

The cache key binds the source, host architecture, ABI and build recipe version.
Increment its recipe version if compiler configuration changes. It contains
only the installed compiler; every invocation recompiles and inspects the
qualification products with the supplied NDK.
