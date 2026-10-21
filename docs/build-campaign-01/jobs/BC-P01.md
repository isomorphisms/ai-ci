# BC-P01 — Bind compiler qualification to the executable that actually produced the output

**1. Identity:** STAR, Ultra; owner `isomorphisms/ai-ci`; parent [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [ai-ci issue 175](https://github.com/isomorphisms/ai-ci/issues/175).

**2. Outcome:** An admitted build proves which qualified compiler, frontend, assembler and linker performed each stage. A manifest or successful wrapper cannot certify a substituted producer.

**3. Recovered intent:** Issue175 requires actual ICK/NDK evidence. [Flexible Pipes issue71](https://github.com/isomorphisms/flexible-pipes/issues/71) additionally preserves ICKY ownership and distinguishes configure detection, Flex bootstrap and compiler parsing. [Cat Food issue131](https://github.com/isomorphisms/catfood/issues/131) supersedes installation of C++ implementations on managed systems. Do not infer a bootstrap exemption. Apply [ai-ci253](https://github.com/isomorphisms/ai-ci/issues/253)'s stricter owned-toolchain consumer lane only at its recorded scope; its explicit stage-zero/link exceptions do not override managed-host restrictions.

**4. Current evidence:** ai-ci main `3d174000649f9f828c29e6be981cfd0e60646014` has `contracts/build-toolchain-v0.contract.tsv` and `android-producer/check.sh`. ICK main `c61e448251744a2f40ad743ebef1a027bdcd2f9d` has `qualification/android-boundary/compile-application.grease`: it checks driver version/target/digest, but these declarations do not independently witness executed cc1. Its A32 application lane differs from the Thumb NEON foundation lane.

**5. Reuse:** Preserve [ICK PR89, “K1: isolate GCC gengtype Flex and verify C-only Bison independence”](https://github.com/dilapidated-shed/ick/pull/89), existing SUN K1, [ICK issue37](https://github.com/dilapidated-shed/ick/issues/37) and [issue63](https://github.com/dilapidated-shed/ick/issues/63). Requalify live heads and retained traces; do not restore COBOL or substitute the limited ICKY grammar for C.

**6. Ownership:** ai-ci specifies independent witnesses; ICK/ICKY own compiler/parser capability; android-NDK owns its tool procedures; FP owns admission. No competing compiler runner or application redesign.

**7. Prerequisites:** READY for investigation. Before executable qualification, resolve admitted host/runtime closure with BC-P02 and BC-CF03, and current policy with BC-A03. Reject changed tool/source hashes, expired artifacts and inherited NDK paths; unavailable admissible tools remain BLOCKED.

**8. Work:** Emit four SUN boundaries: observed process/frontend identity; exact ICK capability and bootstrap classification; compiler-backed ICKY integration continuing K1; real consumer adoption through BC-FP03. Separate cross-target compiler, host-runtime and Android-link qualification. Preserve specific unsupported capabilities rather than silently falling back.

**9. Acceptance:** Execute an approved producer and independently inspect its outputs. Reject same-version stock GCC, swapped cc1, inherited wrong NDK, fabricated witness, unused parser and failed-child success. Accept approved relocation and explicitly distinct compile/link executables. Bind workflow attempt, source, policy, target and output bytes. A repeated wrong-tool build is still wrong.

**10. Limits:** Existing hosted or emulated results do not prove physical acceptance, deployment or C++-free closure. Record bootstrap and managed-system scope independently.

**11. Completion:** Return source-bound decision, complete SUN jobs, dependencies and next executable actions; update issue175/K1 without duplicate assignments. Reopen judgment only for a concrete conflict between approved tool authority and required capability.

**12. Authority:** Investigation, bounded qualification and assignment records are authorized. No merge, closure, release, installation or deployment activation is inferred.

END OF BC-P01
