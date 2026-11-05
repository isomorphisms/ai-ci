# Universal charcoal UI acceptance

Request: `SUN-UNIVERSAL-DARK-CHARCOAL-UI-COMPLETE-01`.

This job is **incomplete**. A source edit, signed package, functional test,
visual sample and physical-device check are separate evidence. `PENDING` means
the condition has not passed, rather than an inferred success. No branch has
been merged, release published, or installed application replaced.

The repository census contains 452 accessible user-owned repositories across
14 accounts: 442 public repositories in [repository-inventory.tsv](repository-inventory.tsv)
and 10 private repositories whose names are not published here. Enumeration is
complete for those accounts. [Default-tree path discovery](public-interface-paths.tsv)
attempted all442 public repositories: 120 contain UI markers, 409 full trees
were readable, and33 require follow-up. Eleven of the latter have a readable
[root-only fallback](root-tree-followup.tsv). The private default-tree scan read
nine repositories and found no UI markers; one tree remains unavailable. These
are path markers, not proof of build support, absence of interfaces, branch
coverage or theme acceptance. Active-branch and rendering-authority review
continues. An UNINSPECTED row is outstanding work, not an exclusion.
[Per-project status](project-status.tsv) includes every default-tree UI-marker
candidate plus the implemented active-branch applications. A `tree` identity is
discovery evidence, not a source commit or accepted build.

| Project | Dark default | Visual test | Regression tests | Artifact |
|---|---|---|---|---|
| FastChat | PASS, sampled launch/root/controls/bars in both system modes on API29 and API34 | PASS, API29/API34 compositor and screenshot; rotation/transition coverage pending | PASS, both APIs: paging, Stop, Unicode, exact copying, history and provider settings | [Signed C67 ARM64 APK ZIP](https://github.com/isomorphisms/fastchat/actions/runs/41947171842/artifacts/13379696620) |
| IB native reader/workbench | PASS, sampled native reader/history/root/bars in both system modes | PASS, API29/API34 compositor and controls | PASS, signed build plus both ART suites; separate browser-foundation live arXiv prepaint remains red | [Signed C67 candidate ZIP](https://github.com/isomorphisms/ib/actions/runs/41947425729/artifacts/13380884545) |
| ChatGPTExporter native reader | PASS, native reader/root/controls/bars in both system modes | PASS, API29/API34 independent same-byte replay | PASS, build, archive/capture/copy/offline/refusal checks and browser checks | [Signed ARM64 candidate and evidence](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588/artifacts/13380610037) |
| Chord Changes | PASS, sampled reader, controls and fingering frames on API29/API34 | PASS, five producer scenes; independent both-mode launch sample pending | PASS, full API29/API34 managed/music/storage/interaction and screenshot guards | [Signed candidates and evidence](https://github.com/dilapidated-shed/tablature/actions/runs/41950607269/artifacts/13382136270) |
| Pasteboard | PASS, sampled canvas in both system modes on API29/API34 | PASS, root/card compositor samples and screenshots | PASS, all six workflow/migration suites on API29/34/35 | [Signed candidate APK ZIP](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41946125428/artifacts/13378759643) |
| Wegert / zero & infinity | IMPLEMENTED; API34/35 emulator execution PASS | Full independent chrome/night-mode/API29 samples pending; scientific colors preserved | PASS native, direct DEX/JNI and ICK boundaries; reproducible signed build PASS; F-Droid buildserver container unavailable | [Device candidate APK ZIP](https://github.com/isomorphismes/wegert/actions/runs/41950617535/artifacts/13381460123) |
| iCurses and iLua demo | PENDING | PENDING | Local changes; branch publication blocked | Unpublished Git commit below |
| Shared android-NDK presentation | Adopted by app branches | Qualified through FastChat API29/API34 | Native/XML palette mutation, frame rejection and integer contrast PASS locally and hosted | Consumed in signed FastChat packages |
| Other utility applications | PENDING implementation | PENDING | Existing tests do not qualify new palette | PENDING |
| Wardriving | Terminal inheritance; no graphical app in inspected source | Not applicable to current CLI | No theme changes required for terminal inheritance | No APK exists at inspected source |
| Cat Food | Terminal inheritance; no graphical source found in inspected main | GUI testing interfaces belong to app/example repositories | Existing receipts do not qualify the new app builds | Delivery registration pending qualification |
| Grease | Terminal policy audit pending | No forced terminal palette | No cosmetic changes made | Not applicable |
| Accelerometer / Spirit Level / Gyroscope / Magnetometer | IMPLEMENTED through shared color header and launch resources | API29/API34/night/state coverage pending | Current shared-instrument producer runs pending | PENDING |
| Ambient Light | IMPLEMENTED; signed ABI builds and API35 posted-frame/replacement checks PASS | API29/API34/night/state coverage pending | PASS existing source-built package/API35 frame checks | [Signed per-ABI APK ZIP](https://github.com/isomorphisms/ambient-light/actions/runs/41951906524/artifacts/13382326987) |
| Holomorphic, Conway, Pauli | Additional indexed Android manifests discovered | PENDING | Source and active-branch inspection pending | PENDING |
| Remaining repository census | UNINSPECTED | PENDING | PENDING | PENDING |

## Exact implementation sources

| Repository / PR | Source commit | Build / acceptance |
|---|---|---|
| [android-NDK #43 — Default native presentation and launch windows to charcoal](https://github.com/isomorphisms/android-NDK/pull/43) | `3e682fb1175beef5625dbd2418730220e49fc9bd` | Actual shared resources and C controls compiled and packaged by FastChat |
| [FastChat #23 — Make FastChat launch, conversation and provider settings charcoal](https://github.com/isomorphisms/fastchat/pull/23) | Current `8fda332e45dc96c16b4aae9955f180d475800b9c`; independently qualified preceding APK source `1a810df430b41ea52a372e7bba1c01dc1df81512` | [Current producer 41947171842](https://github.com/isomorphisms/fastchat/actions/runs/41947171842): all signed builds and API29/API34 PASS. First API34 guest ran out of memory before app launch; exact retry passed. [Independent 41945734444](https://github.com/isomorphisms/ai-ci/actions/runs/41945734444): API29 and API34 PASS on unchanged preceding APK bytes. New source differs only in the observer pin |
| [IB #170 — Keep the native reader and retained history charcoal in every system mode](https://github.com/isomorphisms/ib/pull/170) | `f2b16841e4be8d51a4b4a88cc4264fc6681bce13` | [Producer 41947425729](https://github.com/isomorphisms/ib/actions/runs/41947425729) PASS: signed build and API29/API34 actual ART suites. Browser foundation 41947425696 remains red at the separate live arXiv prepaint step |
| [ChatGPTExporter #18 — Default native archive reader and capture shell chrome to charcoal](https://github.com/dilapidated-shed/ChatGPTExporter/pull/18) | `51bace2e9b026f0f5219d49fdf5ccaac89cb2321` | [Producer 41947436588](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588) PASS. [Independent 41950267065](https://github.com/isomorphisms/ai-ci/actions/runs/41950267065) PASS on API29/API34 with exact signed bytes and both system modes. Browser E2E, host check and native presentation PASS |
| [Tablature #10 — Make Chord Changes launch, controls and fingering canvas charcoal](https://github.com/dilapidated-shed/tablature/pull/10) | `7255ad083a1c183c42f9766ca3548c256e090daa` | [Producer 41950607269](https://github.com/dilapidated-shed/tablature/actions/runs/41950607269) PASS on API29/API34, including reader/fingering screenshot guards. The original case-sensitive setlist test is retained and now passes with authored button case preserved |
| [Utilities #91 — Use shared charcoal canvas and launch theme for Fixed Pasteboard](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/91) | `e3b018bfa12cd1d33cfd8ee4934ef3ce688c2a66` | [Producer 41946125428](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41946125428) PASS all six workflow/migration suites. [Independent 41950267113](https://github.com/isomorphisms/ai-ci/actions/runs/41950267113) PASS both modes on API29/API34. [API34 sampled scene](https://github.com/isomorphisms/ai-ci/actions/runs/41950267113/artifacts/13380931795) |
| [Wegert #76 — Use charcoal application chrome while preserving phase portrait colors](https://github.com/isomorphismes/wegert/pull/76) | `62bd3fcb0ba9f0ff935efe57dd6292203afa066d` | [Native/API34/35 41950617392](https://github.com/isomorphismes/wegert/actions/runs/41950617392), direct DEX/JNI41950617528 and ICK41950617449 PASS. [F-Droid 41950617535](https://github.com/isomorphismes/wegert/actions/runs/41950617535) direct reproducible/signing job PASS; buildserver container lookup fails |
| [Utilities #92 — Use the shared charcoal palette in native sensor instruments](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/92) | `7dfacda62e5b1a7b8c28925bff437602dab7e14a` | Accelerometer41951695167, Spirit Level41951695175 and Gyroscope/Magnetometer41951695226 running; separate from Pasteboard branch |
| [Ambient Light #2 — Default Ambient Light's native instrument and launch window to charcoal](https://github.com/isomorphisms/ambient-light/pull/2) | `590e194d8781b06b3d75a9a3cdcfec012ad646ea` | [Producer41951906524](https://github.com/isomorphisms/ambient-light/actions/runs/41951906524) PASS source-built ABI packages, API35 same-candidate replacement and actual posted frame; broader visual/physical checks pending |
| iCurses — no implementation PR published | Unreferenced commit `dac8aa64292a54248b1c6804b9e9e60e5d296ce0`, parent `e2c2df710955c99cb2ba3b9b0384a2b8b489e9dd` | Creating a new branch returns HTTP422 Reference update failed. No CI execution or PR is claimed |
| [ai-ci #338 — Require fixed charcoal roots, controls and bars in native UI acceptance](https://github.com/isomorphisms/ai-ci/pull/338) | Observer `3e7a512fd68e299491bac8b40f2e199875b62008` | [API34 evidence including live screenshots](https://github.com/isomorphisms/ai-ci/actions/runs/41945734444/artifacts/13378369391) |

## Evidence boundaries and remaining work

FastChat's independent observer checks exact application root, button surfaces,
status/navigation bar colors and light icon flags with Android system night
mode enabled and disabled. Five deliberate live mutations must fail: white
status bar, white navigation bar, dark icons, white root and white control.
The screenshot is captured while the application remains visible. Functional
acceptance still exercises the real framework callbacks, paging, Stop,
multiline Unicode, exact clipboard text, prior turns and secure settings.

The coarse frame guard independently accepts a generated charcoal frame and
rejects a generated white frame. This does not prove every dialog or startup
transition. The fixed palette checker rejects separate native-header and XML
text-color mutations. These self-tests also passed locally using verified
Grease runtime SHA256 `7e31cd05b7a9d8fb2a4a9e003a7f3fcb0159138506d17f0fb28da8cbe22aa85c`.
The exact-integer Idriç contrast oracle is preserved under
`examples/autogenerated/charcoal-contrast`; local retained-compiler replay PASS
is recorded in [contrast-host-replay.txt](contrast-host-replay.txt).
The dedicated [contract run41948679548](https://github.com/isomorphisms/ai-ci/actions/runs/41948679548)
also passed with independently pinned native/XML palette and white-frame
mutations. [Hosted contract evidence](https://github.com/isomorphisms/ai-ci/actions/runs/41948679548/artifacts/13379028563).

Application-owned dashboard surfaces now use the same neutral palette.
External sign-in pages, captured documents, photographs, scientific phase
portraits and user-configured terminal colors are not inverted or recolored.
iCurses changes use terminal default foreground/background rather than
overwriting the user's terminal palette; this is not a promise of exact RGB
charcoal inside every terminal emulator.

Physical MIRO C67, Android14 ARM64 acceptance is **NOT_RUN** for every candidate.
IME keyboard behavior, startup frame sequences, rotation, dialogs, loading,
error/offline screens and reopening need per-app coverage before completion.
Package IDs, existing development signers, data formats and installation
authority are preserved. Artifact availability does not authorize installation.

The old android-NDK direct-DEX demonstration builders still generate temporary
debug signers and omit the shared theme resources. They are not approved C67
upgrade artifacts. Their resource/builder integration remains outstanding;
this job has not silently migrated their package or signing identity.
