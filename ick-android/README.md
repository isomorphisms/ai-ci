# Pinned ICK compiler for Android C

This action builds the C-only ICK compiler at
`c61e448251744a2f40ad743ebef1a027bdcd2f9d`, using its immutable GCC reference
`6294f1d9e7536e5ffcde09d1528c918d63abfef5`. Host GCC/G++ bootstrap ICK.
Maintained consumer C is compiled by the resulting ICK compiler. The action
supports `armeabi-v7a`, `arm64-v8a`, and `x86_64`; call it once per ABI.

Inputs are `abi` and `ndk`, the absolute path to the consumer's installed NDK.
Outputs are `compiler`, `target_flags`, `header_target`, and `gnu_target`.
The application retains its NDK revision and minimum API decision. Qualification
uses API 26 and also requires strict API-26 declarations to fail from API 25.
If the existing application defines `_FORTIFY_SOURCE`, also supply that level
through the `fortify-source` action input (`FORTIFY_SOURCE` for Make). It is
applied to the real Bionic-header qualification and must pass before the action
exports a compiler. The default leaves the macro undefined, and the receipt
records the tested setting.

**Current fortified-header blocker:** with this exact ICK pin and NDK r27c,
`_FORTIFY_SOURCE=2` fails on Bionic's Clang `overloadable`, `pass_object_size`
and diagnostic constructs. The unfortified-header pass does not resolve that
consumer requirement. Keep existing hardening flags and the failed gate;
do not undefine Fortify or erase header annotations to make a consumer pass.

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
* `-isystem <sysroot>/usr/include`
* `-isystem <sysroot>/usr/include/<header_target>`
* `-D__ANDROID__ -D__ANDROID_API__=<application minimum API>`
* `-DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD`

Keep normal optimization, warnings, PIC, stack protection and API requirements
from the consumer's existing build. NDK assembly consumes the emitted `.s`
file with the matching target driver and flags. NDK linking consumes objects;
it does not recompile the owned C source.

## CMake consumers

`OwnedC.cmake` exposes `ick_android_objects(output NAME name SOURCES ...
INCLUDES ... OPTIONS ... DEFINITIONS ... STANDARD 17)`. Configure the normal
Android NDK CMake toolchain and supply `ICK_COMPILER`, `ICK_TARGET_FLAGS`, and
`ICK_HEADER_TARGET` from the action. `ICK_COMPILER_OPTIONS` supports an explicit
compiler search prefix for local qualification. It checks the selected ABI,
GNU compiler target, NDK sysroot and numeric API floor before generating rules.

Add the returned external objects to the existing library, and keep upstream
NDK glue in its ordinary source list. Pass the original target's owned-source
options and definitions to this call. The helper retains directory, source,
global CMake and build-type flags, including Fortify, and generates ordinary
header dependencies. It disables GNU variable-location view directives because
the NDK assembler does not accept them; normal DWARF/debug information remains.
Unsupported compiler flags or hardened headers fail the source stage.

The underlying `Makefile` also runs outside GitHub Actions: `all` uses `ABI`,
`ICK_SOURCE`, `ICK_BUILD`, and `ICK_STAGE`; `qualify` additionally uses `NDK`
and the consumer's optional `FORTIFY_SOURCE`. The source checkout must include
the exact GCC submodule. Bootstrap packages are the C/C++ build tools, flex,
bison, texinfo, GMP/MPFR/MPC development libraries, and GNU binutils for the
selected target. The consumer still uses ICK and NDK for its declared stages.

## Qualification

The action requalifies cache hits. Its Makefile compiles the shared native
`assignment-arrow.c` fixture at O0 and O2, including literal ←, × and ÷, and
produces Android executables with the NDK. It also compiles ICK's pinned
nullability, availability and real Bionic-header fixtures, links the header
fixture as an Android shared library, and checks every output's ELF target.
Strict API-26 availability must be rejected at API 25 at the intended
diagnostic. Compiler, NDK and artifact hashes are retained in
`<stage>/qualification/`, alongside an explicit `android_execution NOT_RUN`.
The native `ick-host` producer separately executes the semantic fixture and its
deliberately wrong division control.

These are source, object and link qualifications. Android execution, app
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
