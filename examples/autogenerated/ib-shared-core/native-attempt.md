# Independent IB Linux native oracle

## Type sketch before implementation

Import the actual IB.Linux.Platform boundary and the independent shared-core
oracle. Compare native results with explicit goldens: ABI 1, pointer width 64,
empty UTF-8 length 0, ASCII length 3, 東京 length 6, 🙂 length 4, and
A東京🙂éB length 15. Refuse an embedded NUL at the Idriç/C boundary.

Emit each case as name=True/False and exit unsuccessfully on the first false.
A compiled byte-count mutation must produce native-empty-bytes=False and a
nonzero process status. A missing shared library must also fail execution.
The same clean executable must pass after restoring the clean library.

This tests a real generated Chez program plus ICK-built C FFI on Linux x86-64.
It does not establish a GUI, network, persistence or Android execution claim.

## Result

PASS for generated Linux/Chez execution and ICK C FFI: all 46 cases, native
byte-count mutation rejection, missing-library rejection, clean restoration
and relocation into a Unicode/apostrophe directory. Exact FP receipts retain
the source, compiler/runtime and executable identities and original failures.

The real compiler misquotes Unicode build paths and returns zero after Error:;
the recipe caught its missing executable and now declares/refuses that input
restriction. See https://github.com/isomorphisms/Idric/issues/138. Identical
generated Scheme/library/launcher bytes yielded different compiled .so hashes
in two fresh output builds; byte reproducibility remains unresolved. Android,
GUI, network and durable disk recovery remain unaccepted.
