# BC-CF03-S05 — Materialize the existing checked Ithon and Internet Archive runtime closure without ambient fallback

**1. Identity and execution:** SUN, Ultra; producer owners `dilapidated-shed/ithon` and `dilapidated-shed/internetarchive`; parent BC-CF03 and [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [Cat Food #33](https://github.com/isomorphisms/catfood/issues/33). This continues existing checked execution and client packaging, not a language rewrite.

**2. Outcome:** Make the Ithon interpreter/checker and existing `ia-ithon` client materializable as exact runtime packages, with explicit target qualification and complete source/module/native-library closure. No phone source/compiler build or silent ambient Python route.

**3. Recovered intent:** Preserve original Ithon .pi semantics and Internet Archive application ownership. The whole inventory requires both rows to remain visible. Optional Ithon/Archive absence cannot become a universal bootstrap stop or permission to install the old Python client.

**4. Current evidence:** Ithon main is 396d8b7af1417a0a61245db940fdb22ef9fbac51; Archive master is 0ea2e7243bcbf78cf2002ebbaea4a735731784ba. [dilapidated-shed/internetarchive PR #1, “Rewrite Internet Archive tools in Ithon”](https://github.com/dilapidated-shed/internetarchive/pull/1) merged, retained f9e86e74d7a56bbbfcae7c505514117f056129c3. Its launcher delegates to `${ITHON:-ithon}` and checked `ithon/ia.pi`.

**5. Reuse instructions:** Reuse [dilapidated-shed/ithon PR #5, “Run checked Ithon on Manimi’s host Python”](https://github.com/dilapidated-shed/ithon/pull/5) and [dilapidated-shed/ithon PR #10, “Make checked consumer receipts executable”](https://github.com/dilapidated-shed/ithon/pull/10). Existing native and explicitly selected checked host-runtime paths are different qualified modes; preserve their checker, loader and receipts. Do not convert the old client tree into the selected runtime.

**6. Scope and ownership:** Ithon owns interpreter/frontend/loader qualification; Archive owns client modules/fixtures; Cat Food consumes. Implement packaging around existing `ithon`, `ithon_host.py`, `Lib/ithon_run.py`, Android producer and Archive launcher. New first-party helper logic follows checked Ithon/Idriç and Grease requirements.

**7. Prerequisites:** The inherited Android producer lists only aarch64-linux-android and x86_64-linux-android; ARMv7 is not qualified. Begin closure and supported-target packaging now; record ARM32’s exact missing target/compiler/runtime boundary, without speculative port. Qualified compiler stages and no-C++ material eligibility remain mandatory.

**8. Work:** Bind one explicit native or owner-qualified host-runtime mode per package. Eliminate ambient fallback from the delivered wrapper while preserving the upstream development launcher. Include checker/import modules, matched standard-library and extension closure, TLS/CA resources actually used, application files, hashes and provenance. Adapt the inherited package path without shipping its Java/Gradle testbed as production. Prepare a Cat Food descriptor and independent clean-prefix consumption.

**9. Acceptance:** Run real arrow/membership-typed .pi code and nested checked imports, then Archive’s maintained offline URL/client fixtures through the installed command outside source/build trees. Reject ill-typed .pi, tampered checker/lowered source, absent extension/stdlib/CA, wrong ABI, unexpected host interpreter and failed check with stale receipt. Benign relocation and repeated installation preserve semantics; a changed source or runtime invalidates evidence.

**10. Evidence limits:** Current release collection is 0/0 for Ithon. No Android bytes were built or executed in this STAR. Prior Manimi host receipts prove their bounded host route only. Archive credentials, uploads, mutations and broad 2018 parity are outside this packaging slice.

**11. Completion and continuation:** Deliver working package preparation/installation integration, complete declared closure and executed positive/bad/benign controls on available qualified targets. Return exact unsupported ARM32 or build stage with minimal reproducer; keep other target lanes moving. Reuse existing producer issues when discovered.

**12. Authority:** Use isolated reviewable branches and bounded offline fixtures; do not publish, activate or access accounts here. No permission to bypass existing source-language, independent acceptance or physical-device gates is inferred.

END OF BC-CF03-S05

