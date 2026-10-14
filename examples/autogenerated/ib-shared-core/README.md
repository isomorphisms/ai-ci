# Independent IB core acceptance

SharedCoreOracle imports actual IB.LongViewTask, LongViewLifecycle and
FragmentStore. Its 38 expected outcomes are independent corpus/goldens; IB's
producer assertion list is not treated as an oracle. The actual source modules
are snapshotted by Kitchen, checked, and evaluated in distinct build directories
for clean, three production mutants and recovery.

NativeFoundationOracle adds eight golden native ABI/UTF-8 boundary cases and is
generated explicitly with maintained Idriç/Chez. The library is compiled/linked
through qualified native ICK. Compiled C mutation and missing-library refusal
exercise the same generated program before restoring the clean library.

parity.grease calls the existing src/aici_followers.c verifier. It requires
Linux runtime, MIRO A1 ARM32 physical and TAB_P10 ARM64 physical exact-trigger
records. A missing/stale/blocked record or receipt cannot pass. Test fixtures
for this gate are parser/admission tests, never physical-device acceptance.

Recipes: isomorphisms/kitchen tasks/ib-desktop/7.grease (source checking),
8.grease (native checking) and pipeline.grease (FP entrypoint). Registration
and exact source/dependency/executable receipts belong to isomorphisms/flexible-pipes.

The first accepted Linux source run is historical checker/evaluator evidence;
the current source heads require their own replay. The 46-case generated Linux
program and native failure/recovery controls also passed, with Unicode-path
relocation. Compiler Unicode build paths and byte reproducibility remain separate
upstream qualification gaps. GUI, network, ordinary disk
restoration, renderer termination and Android execution are separate lanes.
The bounded parity wrapper is not yet installed as a required default-branch
CI check. The draft IB integration cannot be accepted until its actual Android
followers catch up.
