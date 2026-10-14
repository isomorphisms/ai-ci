# BC-P01 decision — actual compiler witnesses and retained ICKY continuation

Research date: 2026-10-14 UTC. Parent: https://github.com/isomorphisms/ai-ci/issues/239. Canonical: https://github.com/isomorphisms/ai-ci/issues/175. This is a STAR/Ultra decision and SUN handoff, not execution of the new SUNs.

The exact source still does not prove that an admitted build's selected compiler did the work. Current ai-ci main `949a60dad5e014cafce2c49619df9bbdbcfaafc0` has a legacy `android-producer/check.sh` that compiles its verifier with ambient `cc` and chooses the latest SDK build-tools. Its retained `android-producer-composite-gate@5c80279dfcee565f4e999d2b1f97feb966b8efd3` is substantially ahead in behavior: `execution.ysh` captures descendant exec traces outside the worker, binds outputs and refuses incomplete traces. However, its mandatory compile role is hardcoded to NDK `clang-18`; it has no admitted ICK-driver/owned-cc1 role. `HOST_OBSERVATION` expressly cannot issue acceptance. Preserve this implementation; extend the existing roles rather than create another compiler runner.

| Boundary | Disposition |
| --- | --- |
| Actual driver/cc1/assembler/link witness | New BC-P01-S01; reuse retained observer, approved authority supplied by A03. |
| Hosted compiler and runtime capability | New BC-P01-S02; continue ICK37 and existing Cat Food probe, independently distinguish owned cc1, borrowed libgcc, cross-target and managed eligibility. |
| K1 configure/Bison/Flex classification | COMPLETED narrow source/build boundary; no repeat bootstrap job. Exact final ICK `15a8c6d9bd2202516119df97a79afa8092b046f6` has completed successful C-only/AICI run38103758861 and four-ABI run38103758867. Artifact11690225333 remains unexpired until2026-10-25. This is metadata plus retained discussion, not a fresh downloaded execution. |
| ICKY source-preserving V3 and complete hosted package | Reuse BC-P02-S03, bounded repair completed at `bc2aad9006d3d44e896d2f5092a7ac82e7bf066b`, run38344914067. Do not regenerate 77 assertions or reopen the launcher-only defect; preserve the original negative archive. |
| Actual ICKY→ICK consumer | Reuse existing SUN K2, expanded into complete handoff; source-frame comparison and the compiler-owned map remain missing. |
| Independent compiler-backed ICKY acceptance | Reuse existing SUN K3, expanded into complete handoff; not parser-unit or hosted-package acceptance. |
| Generic acquisition/closure | Reuse P02-S01/S02/S04, no duplicate downloader. |
| Registered adoption | Reuse P02-S05 and FP03; these consume qualified witness artifacts, not require whole-job completion cycles. |

K2 decision: use the retained V3 complete input frame and written byte slices. The ICK consumer compares them to its own immutable input and carries raw-to-preprocessed expansion identities. Admit only explicitly mapped source forms; existing ordinary C semantics remain with ICK's current compiler. Unsupported syntax in the ICKY-selected lane must reject. The decimal-Nat AST is not C literal semantics: written `010` and `10` remain distinguishable. This neither replaces full C parsing nor replaces the surviving GCC gengtype Flex bootstrap. Renew STAR judgment only if an actual supported syntax lane cannot be connected without changing its meaning or duplicating parsing.

Order: P01-S01 independent witness artifact and P01-S02 hosted capability can develop in parallel. K2 consumes the already-qualified parser package and P01-S01 interface; K3 consumes exact K2 objects and witnessed execution. A03 owns approved roles/issuer/policy; P01 owns observed execution. A07 and T01 consume released interfaces without waiting for all parser work. Preserve P02→T01→A06→A02's existing FP order.

First execution blocker: no independently observed eligible isolated producer deployment/runtime/issuer in this research. Exact policy can allow named disposable bootstrap stages without authorizing C++ installation on Cat Food-managed systems. Cat Food131 remains binding; no stock compiler, stock parser, Python, RefC, YSH relabeling or phone compilation is a substitute. Source implementation is available; authenticated admission, managed delivery and physical evidence remain distinct conditional boundaries.
