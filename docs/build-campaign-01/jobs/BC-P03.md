# BC-P03 — Qualify repeated builds and cache reuse against independent clean outputs

**1. Identity:** STAR, Ultra; owner `isomorphisms/android-NDK`; parent [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [android-NDK issue14](https://github.com/isomorphisms/android-NDK/issues/14).

**2. Outcome:** The maintained producer's promised reproducible outputs match independent clean builds; incremental and cached results match the same contract after every material change.

**3. Intent:** The coordinator requires two independent workspaces, environmental probes and separate unsigned, packaged and signed boundaries. [ai-ci issue225](https://github.com/isomorphisms/ai-ci/issues/225) records Wegert producing equal APKs with the wrong inherited NDK: equality alone does not establish correct inputs.

**4. Evidence:** android-NDK main `11edd1e0d9748d7c618413ec9f5afad52049046a` contains `apk/build-nativeactivity-apk.sh`. Live [PR17, “Make NativeActivity packaging reproducible with a source epoch”](https://github.com/isomorphisms/android-NDK/pull/17), branch `max/reproducible-nativeactivity-candidate`, is `12b509b6244848d1b90276344eb9ab52bf3fea81`. Its source normalizes times/modes, sorts assets, removes ZIP metadata and uses API24+ v2 signing. These changes are candidate work, not absent implementation.

**5. Reuse:** Preserve PR17's FastChat reproducer, old-packager mutant, ZIP-extra-field mutant and current resource/publication safeguards. Its reported exact-head packaging/audio checks do not establish all downstream cache behavior. Refresh FastChat and Wegert consumer pins before extending coverage.

**6. Ownership:** android-NDK owns reusable packaging; producer repositories own compilation/cache recipes; ai-ci owns independent comparison; FP supplies immutable requests. BC-P01 owns executable identity, BC-P04 presentation, BC-FP02 replay. Avoid another build/cache service.

**7. Prerequisites:** READY for investigation. Execution needs BC-P02 closure, approved signer/test lane and currently admissible host tools. The [Cat Food131 correction](https://github.com/isomorphisms/catfood/issues/131) blocks prohibited managed-system tools; historical Grease PASS cannot release that prerequisite.

**8. Work:** Emit four SUNs: reconcile the existing epoch candidate; independently repeat complete consumer compilation and packaging; audit actual incremental/cache keys and implement missing invalidations; integrate real consumer receipts through FP. Inventory existing caches first—do not invent one. Keep targets' output contracts separate.

**9. Acceptance:** Build twice without sharing or copying outputs. Vary workspace path, timezone, input modes/order and declared environment. Compare clean, incremental and cache-hit results; mutate source, dependency, recipe, profile, compiler and policy individually. Reject a planted stale hit, copied-first-output comparison and undeclared toolchain. Accept irrelevant attempt-ID/time variation outside stable material. Preserve unexplained differences as failures without narrowing the boundary afterward.

**10. Limits:** Packaging-byte equality is distinct from compiler reproducibility, update continuity and physical acceptance. Signing modes and API floors must remain explicit; no cross-architecture identical-byte requirement.

**11. Completion:** Return decision, complete SUN jobs, material-key inventory, dependency order and exact next actions. Update issue14/PR17 with retained evidence. Reopen judgment only if an independently established output contract conflicts with required signing or consumer behavior.

**12. Authority:** Investigation, focused qualification and job records only; no merge, release, key creation, signer substitution or deployment activation.

END OF BC-P03
