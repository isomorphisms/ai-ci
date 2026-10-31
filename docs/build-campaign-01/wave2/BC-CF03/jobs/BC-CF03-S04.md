# BC-CF03-S04 — Continue IR’s exact-source Android package with explicit compiler and runtime eligibility gates

**1. Identity and execution:** SUN, Ultra; owner `isomorphisms/ir`; parent BC-CF03 and [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [Cat Food #33](https://github.com/isomorphisms/catfood/issues/33). Continue [isomorphisms/ir PR #24, “Sync IR source to R-devel r90659 (preserve Unicode semantics)”](https://github.com/isomorphisms/ir/pull/24) as the existing producer work.

**2. Outcome:** Produce an honestly qualified IR runtime package from the selected exact source and implement its existing packaging/consumer boundary. Resolve the real language/toolchain conflict before admission; do not invent a new R implementation.

**3. Recovered intent:** Whole-inventory delivery preserves IR’s Unicode semantics and private installation beside ordinary R. Runtime-only phones and [Cat Food #131](https://github.com/isomorphisms/catfood/issues/131) forbid compiler installation and C++ managed material. Optional IR incompleteness cannot stop unrelated provisioning.

**4. Current evidence:** Default `ir` is 7829f310ce505109fc4bfd0e1d151b2c92b4b29f; live #24 is 29ea780263bd5d1a32a67327b39a6c8581fd1a32. [isomorphisms/ir PR #2, “Build an isolated ARMv7 Termux package”](https://github.com/isomorphisms/ir/pull/2) landed. Existing release `ir-4.7.0-devel-armv7.1` binds older 84564b69c1bcad789f0f3be686660c226071e184; its .deb SHA-256 is 36874b459e15ae781789ab4dba8834a50a97ee48970306424a71ff3ae3049de1.

**5. Reuse instructions:** Reuse `build-armv7-termux`, `build/termux-armv7/package/build.sh`, existing Unicode/regression fixtures and build records. Preserve historical release bytes; they do not qualify newer source. The real recipe explicitly selects gcc-15, gfortran-15 and g++-15 and links eleven named runtime dependencies. Its native Android build executes freshly built R.

**6. Scope and ownership:** IR owns source/runtime semantics and package production; Cat Food owns supported consumer import, material obligations and admission. Keep `ir`/`irscript` private and ordinary `R`/`Rscript` unchanged. Do not introduce a generic apt solver or rename CXXR history into an eligible runtime.

**7. Prerequisites:** Packaging qualification can begin independently. Enumerate actual C, Fortran, C++ and inherited runtime stages against qualified ICK/NDK capabilities. Identify exact mandatory C++ source/library or unavailable Fortran stage as BLOCKED_CAPABILITY; no waiver, silent GCC fallback, translation or altered build claim.

**8. Work:** Add source-bound stage checks and complete dependency/material receipts to the existing producer. Qualify safe .deb-to-existing-Cat-Food payload preparation only from approved exact contents, without running arbitrary maintainer scripts or hiding transitive libraries. Preserve modes, paths, symlinks, resources and license records. Emit deterministic package identity and per-ABI support; do not copy ARMv7 success into ARM64.

**9. Acceptance:** Run actual IR Unicode/assignment/function/equality/tensor and relevant upstream regression behavior on the qualified built runtime. Independently reject wrong revision, undeclared C++ dependency, omitted library, wrong ABI, stale .deb, failing producer with stale output, and command collisions. Benign private-prefix relocation and repeat installation retain results and ordinary R. Retain minimal failing target reproducer when compilation is blocked.

**10. Evidence limits:** Metadata refreshed: one release/four assets, no fresh .deb download or runtime execution here. Source-sync CI success is neither compiler qualification nor exact-head runtime acceptance. Container execution remains distinct from A1 physical execution.

**11. Completion and continuation:** Deliver implementation and executable eligibility/package checks, exact remaining capability owner, complete closure and prepared consumer descriptor. Keep #24 unaccepted until its original executed semantic obligations pass; do not revive CXXR as a convenient alternative.

**12. Authority:** Work in isolation; no remote mutation, release, device install or merge is authorized by this campaign. Preserve original issue/PR scope and historical failures. Return a genuine source-language conflict for judgment while completing unaffected packaging work.

END OF BC-CF03-S04

