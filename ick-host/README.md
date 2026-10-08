# Native ICK producer

This action builds ICK `c5d28dde9cc333a562b907785d0370b725146cdf`
over GCC `6294f1d9e7536e5ffcde09d1528c918d63abfef5` and executes
literal `←` initialization and assignment before exporting the compiler.
Consumers compile and link their C tests with that compiler. A stock compiler
is used only to bootstrap ICK; it is never an acceptance substitute.

The composite action uses GitHub's required shell interface to invoke fixed
build tools. The build is a Makefile, not a maintained shell program.
The source revision and GCC dependency are checked before materialization.

The native scalar profile links against the Ubuntu 24.04 glibc and prebuilt
GCC 13 startup/runtime objects. Their package versions and hashes are recorded
in the stage directory. No host C frontend compiles consumer code. The ICK
frontend and driver perform consumer compilation and linkage.

Consumers pass the exported `link_flags`: `-fno-link-libatomic`. Automatic
libatomic linkage and building the complete ICK native runtime are outside
this profile. The latter currently asserts in binary128 complex component
lowering while compiling `__multc3`/`__divtc3`. Neither complex cross-compiler
ABI compatibility nor atomics needing out-of-line helpers inherit acceptance
from this producer. A consumer must qualify those capabilities separately.

The output establishes a native C producer and assignment syntax. It does
not establish an Android sysroot, an Android ABI, a physical-device result,
or a semantic style review. Cross compilers remain consumer-owned.
