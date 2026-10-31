# BC-P04 — Require the finished APK to preserve approved application presentation

**1. Identity:** STAR, Ultra; owner `isomorphisms/ai-ci`; parent [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [ai-ci issue225](https://github.com/isomorphisms/ai-ci/issues/225).

**2. Outcome:** An APK is rejected before promotion when its actual launcher, label, component, icon or declared localization differs from the approved source-bound application plan.

**3. Intent:** Issue225 records the physical C67 report that “zero & infinity” became “Wegert” while native code remained unchanged. Application identity is a maintained requirement; an intentional rebrand needs explicit approved plan evidence. No fixture may derive its expectation from the candidate being judged.

**4. Evidence:** ai-ci main `3d174000649f9f828c29e6be981cfd0e60646014` already includes merged release safeguards from [PR241](https://github.com/isomorphisms/ai-ci/pull/241) and [PR242](https://github.com/isomorphisms/ai-ci/pull/242). android-NDK main `11edd1e0d9748d7c618413ec9f5afad52049046a` contains `apk/build-nativeactivity-apk.sh`: resources and optional expected application/activity label checks exist. [PR18, “SUN 1: preserve APK resources and launcher identity in direct NativeActivity packaging”](https://github.com/isomorphisms/android-NDK/pull/18) is closed; its implementation is now present.

**5. Reuse:** Preserve finished-APK extraction, wrong-label controls and publish-after-verification. Continue [ai-ci PR230](https://github.com/isomorphisms/ai-ci/pull/230), the Cat Food companion chain and Wegert producer adoption. Optional packager input is defense in depth; it does not replace mandatory independent policy.

**6. Ownership:** Applications own identity/resources; Cat Food owns target/profile plans; android-NDK packages; ai-ci enforces expected versus observed identity; FP composes. BC-A03 owns generic approved policy, BC-CF07 signer/install admission, BC-FP03 producer routing. No new canonical application registry in ai-ci.

**7. Prerequisites:** READY to investigate. SUN execution needs a refreshed approved application plan, actual APK, admissible packager/extractor tools, BC-P01/P02 provenance and BC-CF02 companion obligations. A missing localization or icon decision is explicit unresolved material, never guessed from the output.

**8. Work:** Emit four SUNs: source-plan presentation contract; independent final-package extraction; mandatory admission and bypass rejection; real Wegert/Pauli consumer integration with retained companion work. Serialize changes overlapping PR230. Retain direct-DEX and NativeActivity distinctions.

**9. Acceptance:** Approved fixture passes. Reject changed display/launcher labels, wrong component/icon, omitted required localization, candidate-derived expected fields, stale plan and missing required assertion. Accept inherited application label and declared harmless resource ordering. Bind extraction bytes and artifact digest to exact source/profile/policy/attempt; a failed or interrupted publication cannot overwrite a previously verified artifact.

**10. Limits:** Host extraction does not prove on-device display, launch, replacement installation or visual correctness. Preserve the reported C67 observation separately from exact retained-byte evidence.

**11. Completion:** Return decision, complete SUN jobs, dependency order and next actions; update issue225 with what existing safeguards satisfy and what remains. Contradictory source-approved presentation returns to the application owner.

**12. Authority:** Investigation, bounded qualification and assignment records. No rebranding, signer changes, merge, release, installation or activation inferred.

END OF BC-P04
