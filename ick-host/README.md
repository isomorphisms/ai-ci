# Native ICK producer

This action builds ICK `c61e448251744a2f40ad743ebef1a027bdcd2f9d`
over GCC `6294f1d9e7536e5ffcde09d1528c918d63abfef5` and executes
literal `←`, `×` and `÷` before exporting the compiler. The pinned source
contains [dilapidated-shed/ick PR #84, “Recognize ÷ division in Icky C”](https://github.com/dilapidated-shed/ick/pull/84).
Consumers compile and link their C tests with that compiler. A stock compiler
is used only to bootstrap ICK; it is never an acceptance substitute.

The qualifier executes at `-O0` and `-O2`. It checks integer truncation,
floating division from volatile inputs, precedence and left associativity,
single macro-operand evaluation, pointers, retained ASCII slash, literal bytes
and macro stringification. A separately compiled control replaces the quotient
macro with multiplication and must exit exactly 2. A compiler that merely
accepts the glyph cannot pass with the wrong arithmetic result.
An ordinary `sizeof(array) ÷ sizeof(array[0])` macro is exercised separately
from the intentionally unsupported `#if 8 ÷ 2` preprocessor expression.

[The dated native receipt](qualification/2026-10-09.tsv) records the exact
compiler and fixture identities used for local execution. Each consumer still
runs the action and its own tests on its current pinned source.

This is binary C division after preprocessing. C++/Objective-C, preprocessor
`#if` arithmetic, and a `÷=` compound token are outside this source contract.
Existing `/=` and foreign/compatibility source retain their ordinary spelling.

The composite action uses GitHub's required shell interface to invoke fixed
build tools. The build is a Makefile, not a maintained shell program.
The source revision and GCC dependency are checked before materialization.

The native scalar profile links against the Ubuntu 24.04 glibc and prebuilt
GCC 13 startup/runtime objects. Their package versions and hashes are recorded
in the stage directory. No host C frontend compiles consumer code. The ICK
frontend and driver perform consumer compilation and linkage.
The installed-stage cache is bound to the exact source, host platform,
runtime package versions and hashes of every declared startup/runtime file.
The semantic qualifier and negative controls execute on every cache restore.
The declared startup set includes `crtbeginT.o` for static consumers. A static
stdio round-trip containing literal division executes on every restore and
must have no ELF interpreter. Static consumers append the separately exported
`static_runtime_flags` after their objects: the glibc/GCC unwind link group
`-Wl,--start-group -lc -lgcc_eh -Wl,--end-group`. This retains actual static
glibc dependencies rather than suppressing unwind references.
The same declared host dependency includes AddressSanitizer and UndefinedBehaviorSanitizer
runtime objects for consumers that require those checks. Instrumentation is
produced by ICK; each consumer must still execute its sanitizer suite.

Consumers pass the exported `link_flags`: `-fno-link-libatomic`. Automatic
libatomic linkage and building the complete ICK native runtime are outside
this profile. The latter currently asserts in binary128 complex component
lowering while compiling `__multc3`/`__divtc3`. Neither complex cross-compiler
ABI compatibility nor atomics needing out-of-line helpers inherit acceptance
from this producer. A consumer must qualify those capabilities separately.

The output establishes a native C producer and the qualified glyph syntax. It does
not establish an Android sysroot, an Android ABI, a physical-device result,
or a semantic style review. Cross compilers remain consumer-owned.
