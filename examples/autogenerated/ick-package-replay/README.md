# Independent replay of the retained ARMv7 ICK package

BC-P02-S02 continues the existing installed-stage producer. No GCC rebuild,
producer checkout, NDK acquisition or managed-system installation occurs here.
`package_replay.pi` is checked Ithon; invoke it through the pinned Ithon
frontend, never as Python. Its current host frontend uses the declared
inherited Python substrate.

The `acquire ARCHIVE SHA256 DESTINATION` command validates the independent
tar digest and source/GCC/ABI receipt, then preflights canonical paths, node
types, duplicate entries, privileges, member counts and expanded size before
creating a fresh destination. Symlinks and special nodes are refused. A
hardlink may refer only to an earlier regular member and is materialized as
an independent regular file; its expanded size counts against the same limit.
The output uses the existing shared SHA-256/mode/path `material.tsv` format.
The destination's parent is caller-owned trusted storage; this is not a
concurrent hostile-filesystem sandbox. An I/O failure can leave an incomplete
fresh directory, never a success receipt; retry uses another fresh directory.

The `replay ROOT LEAF LEAF_SHA256 GLYPH_SOURCE OUTPUT` command runs the
delivered driver in a fresh unrelated directory with a bounded environment.
It verifies the driver target and delivered cc1 location and emits ARMv7
assembly at O0/O2 for both an unchanged real Fourier Voice leaf and the
existing ICK glyph fixture. The source pin and digest are in the workflow;
the consumer's ordinary-C leaf is preserved byte-for-byte.

The archive SHA-256 anchors provenance; a producer receipt alone does not.
Acquisition creates the material record, and cannot independently certify it.
`package-closure/verify.grease` remains the shared independent verifier. Run
it under an eligible qualified Grease runtime before accepting full closure;
its absence is explicitly NOT_RUN in this host observation. The literal `+`
pathname extension is required by the actual GCC `libgdiagnostics++.h` support
file and has its positive in the unchanged shared refusal corpus.

Synthetic acquisition controls cover relocation, the internal hardlink,
literal-plus header, altered digest, absolute/traversing/duplicate paths,
symlink and escaping/forward hardlink, privileged mode, reserved manifest,
missing frontend and wrong source. Fake fixture payloads are never executed.

The separate `ick-package-replay.yml` workflow reuses immutable artifact
11610372892 from run 37916479044. It checks its exact tar bytes and actual
consumer source before host replay. Archive expiry is an acquisition failure;
the verifier does not rebuild, repair or substitute another compiler.

Generated assembly and a declared frontend location are bounded host
observations. They do not establish mathematical equivalence, object ABI,
NDK assembly/link, authenticated process witnesses, Android execution,
reproducible builds, package publication or C++-free managed eligibility.
