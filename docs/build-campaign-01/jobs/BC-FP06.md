# BC-FP06 — Publish verified paired Android prereleases through the owner pipeline

**Identity:** STAR, Ultra; owner `isomorphisms/flexible-pipes`; parent [BUILD-CAMPAIGN-01](https://github.com/isomorphisms/ai-ci/issues/239); canonical [issue 45](https://github.com/isomorphisms/flexible-pipes/issues/45).

**Outcome:** A registered publisher consumes an independently accepted paired build and makes the exact approved APKs/checksums durably retrievable, while preserving authority, target, signer, and retry boundaries.

**Recovered intent:** Reuse Young Tableaux's demonstrated input/output shape. FP owns reusable publication; Cat Food owns maintained target/profile facts; applications own semantics and UI acceptance. A publication step must not rebuild, substitute, or silently accept missing companion artifacts.

**Current evidence:** FP main `def2a66fe61a2b23440f98031f1defa738a0d1ee` contains no named paired prerelease operation. The current client is `isomorphismes/young-tableaux`, stable repository ID `1405872600`, default branch `tables@a60493703dc164cfc8573f050848b77c6a00badf`; the former owner in issue45 is stale. Both [rc1](https://github.com/isomorphismes/young-tableaux/releases/tag/v0.4.0-rc1) and [rc2](https://github.com/isomorphismes/young-tableaux/releases/tag/v0.4.0-rc2) currently expose A1 ARMv7 and C67 AArch64 APK/checksum assets.

**Reuse/current gap:** Inspect the exact client [build workflow](https://github.com/isomorphismes/young-tableaux/blob/a60493703dc164cfc8573f050848b77c6a00badf/.github/workflows/build-apk.yml): paired outputs and signer checks exist, but Actions uploads retain artifacts for seven days; no reusable FP publisher is established. Its triggers still name `main`/a historical feature branch rather than default `tables`; route that coverage dependency to ai-ci. Existing release metadata demonstrates availability, not newly verified package contents or current-source acceptance.

**Scope:** Compose existing release APIs and receipt contracts; do not create a release service or move application tests into FP. BC-FP03 owns producer admission, BC-FP05 visible delivery, BC-FP02 recovery, and BC-FP01 operation authority.

**Prerequisites/readiness:** READY for investigation and synthetic publication qualification. SUN live publication is conditional on exact accepted source/build/package receipts and explicit release authorization. Refresh signer identity, companion requirements, asset availability and owner transfer by numeric ID. Current workflow's C++ Grease dependency also requires [FP73](https://github.com/isomorphisms/flexible-pipes/issues/73) reconciliation; old host PASS does not qualify new managed execution.

**Work:** Emit three SUNs: admit the complete immutable paired artifact set; implement reusable authority-separated prerelease publication and recovery; independently retrieve published assets and connect the existing Young Tableaux consumer. Specify partial-upload and lost-response behavior without assuming exactly-once effects.

**Acceptance:** Positive: the two required APKs and checksum files retrieve with exact admitted bytes from a fresh consumer. Bad: absent companion, mixed source, changed signer/ABI, wrong package/version, expired input, unauthorized publication, or changed asset during retry. Benign: declared per-ABI differences and already-identical release assets. Deterministic manifests exclude timestamps; byte-reproducible compilation requires separate independent producer builds.

**Limits:** Published, retrieved, installed, launched, and physically accepted remain separate. Existing release assets cannot satisfy a changed source or revoked policy.

**Completion:** Return decision/evidence, full SUN jobs, prerequisite order, exact next actions and updated canonical records. Conflicting release authority or signer continuity returns the precise owner question.

**Authority:** Investigate, perform bounded qualification needed to settle this domain, and create SUN issue/file records. Do not execute the emitted SUN implementation campaign here. No merge, closure, release, activation, recurring schedule, or actual Work dispatch is inferred.

END OF BC-FP06
