# BC-CF08-S03 — Select support binaries by Android runtime compatibility and preserve probe failures

1. **Identity and execution.** SUN, Ultra; owner isomorphisms/catfood; parent BC-CF08 and [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [Cat Food #130](https://github.com/isomorphisms/catfood/issues/130).

2. **Outcome.** Normal C67 provisioning obtains a declared Android-compatible jq/support-runtime lane and reaches Android package delivery without selecting a generic Linux binary merely because its architecture matches. A failing executable cannot be called current because its output contains the expected version.

3. **Recovered intent.** #130's physical report distinguishes failed full provisioner, working Termux jq and successful direct Android installer. The allowed repair is an independently verified Android asset or an explicit allowed Termux support-package lane; no silent fallback after a failed pinned asset and no local compiler bootstrap.

4. **Current evidence.** At main `8ba159f8322cd436aa8e6400b0eded2d74c14011`, `install-binaries.sh` maps Linux/aarch64 to `linux-aarch64` without Android/libc discrimination. `runtime-binaries.tsv` pins generic jq/Miller assets. Its current-reuse probe discards exit status before matching version output. `android/record-c67-runtime.sh` hardcodes the same jq lane/digest/receipt. `tests/runtime-binaries.sh` uses shell fake programs and an explicit Linux platform override, so it cannot prove Android compatibility.

5. **Reuse instructions.** Repair those maintained entrypoints, existing support-runtime manifest/receipts and focused tests. Keep main's positive device/model classifier and CF-A2-S3's retained re-observation/byte checks. CF03/CF06 reuse this job rather than issuing another jq repair. Preserve the old failed asset identity and C67 report.

6. **Scope and ownership.** Own support-command acquisition and real probe semantics for the existing declared lanes. CF04/S2 owns general package graph/approved runtime obligations; S3 owns sealed installation authorization; CF05 owns whole first-command acceptance. Do not redesign all runtime delivery, replace Grease, or expand possible architectures into maintained targets.

7. **Prerequisites.** Source implementation is ready. Determine the exact approved acquisition lane from current Cat Food/target records; Android runtime package access and verified tools must be observed before effects. Positive Android acceptance requires exact package version/origin/digest/loader/runtime closure and actual C67 execution. Unavailable device access blocks only physical validation. Reject stale source, manifest, selected executable or installed receipt.

8. **Work.** Classify OS/runtime/ABI from positive target observations and validate any explicit override against them. Select the approved compatible lane before acquisition. Bind exact acquired and executed bytes, runtime provenance and semantic result; preserve command presence separately from valid acquisition. Require successful probe exit and independently expected output. Reconcile the C67 recorder to consume selected eligible material instead of demanding generic Linux jq. Preserve owned/unowned command collision behavior and stage ordering; retain failed attempts without substitution.

9. **Acceptance.** Through actual `install-binaries.sh`/provisioner/recorder entrypoints, accept declared supported Android and Linux cases, then reject generic glibc-on-Android, wrong ABI/loader, altered bytes, lying version output with nonzero exit, invalid override and missing acquisition. Use actual eligible jq semantic output, not only a version string; fixtures model selection and refuse mislabeled scope. Harmless path spacing or compatible declared shared bytes pass. Repeat, cache corruption and interruption preserve correct material and last valid state. On available C67, rerun the full provisioner and record its separate stage results; direct installer success alone does not complete this acceptance.

10. **Evidence limits.** Host selection fixtures are not Android ELF execution. C67 physical jq acceptance cannot certify A1/TAB_P10, Grease eligibility or every package. #131's non-C++ boundary remains in force for the rest of provisioning.

11. **Completion and continuation.** Deliver source/tests and exact lane/probe receipts on #130, with CF03/CF06/CF05 cross-links. Report first missing artifact/host fact, not an invented global failure. Return to STAR only if no existing approved acquisition model can represent the required support command.

12. **Authority.** Implement and verify using disposable source/host work. No merge, closure, production installation, removal, publication, activation, device compiler, schedule or dispatch.

END OF BC-CF08-S03

