# Native scroll settlement and first-touch acceptance

Purpose: qualify the maintained reader after a verified missed-link defect. The candidate keeps checked Idriç navigation, ICU acquisition and Arena semantics; only the JNI adapter's public SDK scroll cancellation changes. This independent SDK oracle is test code, not a candidate Java/Kotlin/DEX reader implementation.

## Original failure and Android mechanism

IB d02fe516's single zero-distance smoothScrollTo call repaired retained fragment positioning but could leave a fresh OverScroller active. Frozen independent observer42 full29 archive13104564402 (139042233 bytes, SHA25694858a124f4f08ad4dea106e98eeb37430e512e4bd6c0ad262c952a5c7de831a) retained Reader One while expecting “Second retained fixture acquired through ICU.” after one actual Next gesture. Corrected read-only inspector98c832a/run41360971208 prints those final predicate values. The earlier inference that this was merely a cached readiness value was wrong; refreshing an accessibility node did not repair the missed navigation.

Primary Android source for both qualified APIs shows smoothScrollBy starts a timed scroller after its idle gap even for zero distance, while the rapid subsequent call aborts it. ACTION_DOWN interception considers that scroller active. The adapter now performs both public SDK calls in the same pre-draw animation clock and preserves its measured position and checked source-derived collapsed selection.

* [API29 ScrollView](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-10.0.0_r1/core/java/android/widget/ScrollView.java)
* [API29 OverScroller](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-10.0.0_r1/core/java/android/widget/OverScroller.java)
* [API34 ScrollView](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-14.0.0_r1/core/java/android/widget/ScrollView.java)
* [API34 OverScroller](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-14.0.0_r1/core/java/android/widget/OverScroller.java)

## Independent observation and negative control

EarlyLinkTouchProbe observes public SDK views, a changed native text object during a real user-visible reflow, its pre-draw animation timestamp, and an actual hardware frame commit. Its passive OnTouchListener always returns false and records real child DOWN/UP counts/timestamps; it never scrolls, selects, focuses or follows a link. The instrumentation pauses before reflow to exercise the idle branch, then sends exactly one existing touchscreen DOWN/UP gesture at Next. It accepts only a frame-commit delay at most100ms and actual child-UP/input-completion interval below200ms, shorter than the qualified250ms SDK animation. A late/unobserved frame or gesture fails a separate timing precondition; it cannot become a designated mutation rejection.

The single-scroll compiled APK keeps the same checked DEX, cursor settlement, source projection, identities, payload, package/version and certificate; only the second native cancellation call is removed. It must fail the exact child-touch-delivery assertion within that measured window. The original must receive exactly one DOWN and UP and actually fetch Reader Two through ICU. An independent committed-range read then compares original bytes with the controlled fixture. No repeat touch, longer pre-touch wait after reflow, direct navigation substitute, hidden API, fake network or hosted-as-physical claim.

The existing zero-point and stale-cursor/animation controls remain required. Full/isolated fragment receipts now include first-touch delivery, compiled single-scroll rejection and independent acquired-source proof. There are ten frozen APK inputs: one original and nine native controls. All producer hashes are checked before Android.

Type/ownership sketch: FrameObservation carries SDK pre-draw and frame-commit clocks; TouchObservation carries passive child events and their actual clock; AdmittedDocument remains the checked reader's own ICU/Arena result verified from committed bytes. Volatile fields plus CountDownLatch publish callback observations without borrowing candidate navigation logic. Observation callbacks never grant admission or override SDK event results.

Physical SVITOO TAB_P10 and ARM execution remain BLOCKED/NOT_RUN without fresh access and device facts. Both current older-source decoder/lifecycle/link lanes pass and Google caller/query/original-byte handoff passes; public Google results still fail JavaScript-only continuation content. Those older observations do not qualify a changed APK. The new source must earn host/required ART and independently frozen replays before candidate publication.

## Current source binding

Source 0d2da9cb8fbb5b63790eb19d4490b8477bbe6801, producer41362975147, archive13107505276 is1019769202 bytes,SHA2566a2ec5422dddf60c10aa4a4db36bd5435b4b37ccaf582c4ce70dca56697a72ae. Source-to-DEX and signed packaging pass; required ART workers and independent runtime replays still need results. Producer observer is5de6e5f786b99aa074027941d19bc0e7705e37ce. All ten APK hashes and source/compiler/frontend/payload identities must match before Android.

The independent early-link controller also captures the complete pre-positive source snapshot. The positive must add exactly two response receipts (URL entry and followed link); Reader Two's response identity must be absent from the earlier snapshot, and its committed original range must match the fixture. Reopening a previously retained source cannot satisfy this new-acquisition claim.
