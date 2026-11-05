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
attempted all 442 public repositories: 120 contain UI markers, 409 full trees
were readable, and 33 require follow-up. Eleven of the latter have a readable
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
| Chord Changes | PASS, sampled reader, controls and fingering frames on API29/API34 | PASS, five producer scenes plus independent API29/API34 launch in both system modes | PASS, full API29/API34 managed/music/storage/interaction and screenshot guards | [Signed candidates and evidence](https://github.com/dilapidated-shed/tablature/actions/runs/41950607269/artifacts/13382136270) |
| Pasteboard | PASS, sampled canvas in both system modes on API29/API34 | PASS, root/card compositor samples and screenshots | PASS, all six workflow/migration suites on API29/34/35 | [Signed candidate APK ZIP](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41946125428/artifacts/13378759643) |
| Wegert / zero & infinity | IMPLEMENTED; API34/35 emulator execution PASS | Full independent chrome/night-mode/API29 samples pending; scientific colors preserved | PASS native, direct DEX/JNI and ICK boundaries; reproducible signed build PASS; F-Droid buildserver container unavailable | [Device candidate APK ZIP](https://github.com/isomorphismes/wegert/actions/runs/41950617535/artifacts/13381460123) |
| iCurses and iLua demo | Terminal defaults inherited; exact RGB belongs to terminal configuration | PASS real terminal execution on host/API34; API29 NOT_RUN | PASS C/iLua host and API34; product branch publication and formal shared admission remain BLOCKED | [ARM64 runtime checkpoint](https://github.com/isomorphisms/ai-ci/actions/runs/41961330436/artifacts/13386685529) |
| Shared android-NDK presentation | Adopted by app branches | Qualified through FastChat API29/API34 | Native/XML palette mutation, frame rejection and integer contrast PASS locally and hosted | Consumed in signed FastChat packages |
| Other utility applications | PENDING implementation | PENDING | Existing tests do not qualify new palette | PENDING |
| Wardriving | Terminal inheritance; no graphical app in inspected source | Not applicable to current CLI | No theme changes required for terminal inheritance | No APK exists at inspected source |
| Cat Food | Terminal inheritance; no graphical source found in inspected main | GUI testing interfaces belong to app/example repositories | Existing receipts do not qualify the new app builds | Delivery registration pending qualification |
| Grease | Terminal policy audit pending | No forced terminal palette | No cosmetic changes made | Not applicable |
| Accelerometer | PASS, sampled launch root and native ink in both system modes | PASS API29/API34 independent same-byte launch; state/rotation coverage pending | PASS all existing ABI/package producer checks | [Signed candidates](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695167/artifacts/13383110866) |
| Spirit Level | PASS, sampled launch root and native ink in both system modes | PASS API29/API34 independent same-byte launch; state/rotation coverage pending | PASS source-built packages, host renderer and existing API35 frame/replacement checks | [Signed candidates](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695175/artifacts/13384010251) |
| Gyroscope | PASS, sampled launch root and native ink in both system modes | PASS API29/API34 independent same-byte launch; state/rotation coverage pending | PASS existing ABI and API35 posted-frame/replacement checks | [Signed candidates](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695226/artifacts/13382842737) |
| Magnetometer | PASS, sampled launch root and native ink in both system modes | PASS API29/API34 independent same-byte launch; state/rotation coverage pending | PASS existing ABI and API35 posted-frame/replacement checks | [Signed candidates](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695226/artifacts/13383131848) |
| Ambient Light | PASS, sampled launch root and native ink in both system modes | PASS API29/API34 independent same-byte launch; state/rotation coverage pending | PASS existing source-built package/API35 frame checks | [Signed per-ABI APK ZIP](https://github.com/isomorphisms/ambient-light/actions/runs/41951906524/artifacts/13382326987) |
| Proximity | PASS sampled root and native ink in both system modes | PASS independent API29/API34 live launch | PASS host model, ABI packages and signed bundle; prior header-path failure repaired | [Signed candidates](https://github.com/isomorphisms/Android-proximity-sensor/actions/runs/41959502810/artifacts/13384706447) |
| Billiard | IMPLEMENTED native canvas/chrome and shared launch theme | PASS actual Rough host pixel checks; Android execution pending | PASS host mathematics/paper exports, ICK Android linking and signed packages | [Signed paired candidates](https://github.com/isomorphismes/billiard/actions/runs/41958097962/artifacts/13385701997) |
| Holomorphic | IMPLEMENTED shared launch theme and checked shader control roles | Scientific field unchanged; live control acceptance pending | Source-built shader generation and packages running | PENDING |
| Pauli | IMPLEMENTED shared launch theme and local explanation-page stylesheet | Actual API34 orbital frame inspected; independent chrome/page samples pending | PASS all five mathematical, ABI, Android and signed-package producers | [Signed C67 ARM64 candidate](https://github.com/isomorphismes/pauli/actions/runs/41960123808/artifacts/13387950058) |
| Mathieu | IMPLEMENTED shared charcoal canvas, controls and launch theme | Real host renderer PASS; Android pending | Host exact mathematics/session PASS; repaired compiler boundary qualifying | PENDING |
| Mostow | IMPLEMENTED shared charcoal default and controls; optional paper artwork retained | Native GLES samples pending | Shared owner copies PASS; actual math/GLES and signed producers running | PENDING |
| Seifert | IMPLEMENTED shared charcoal scene/readout/launch surfaces | Real GLES neutral-role samples pending | Shared owner copies PASS; math/GLES and signed producers running | PENDING |
| Spinor | IMPLEMENTED shared charcoal void/launch windows | Scientific cube/ribbon colors preserved; Android samples pending | Shared owner comparison and existing math/native/package producers running | PENDING |
| Current DEX constructor/source-observer fixtures | IMPLEMENTED explicit shared theme | Actual default TextView color observation added; Android pending | Grease parse and independent observer assembly PASS | Test fixtures only; no C67 upgrade package |
| Programmer's Keyboard | No application GUI in inspected main | Paper keypad/fabrication previews intentionally retain their export colors | Hardware/firmware and document-export project; no cosmetic changes made | Not applicable |
| Conway and remaining mathematical viewers | Additional indexed interfaces discovered | PENDING | Source and active-branch inspection pending | PENDING |
| Remaining repository census | UNINSPECTED | PENDING | PENDING | PENDING |

## Exact implementation sources

| Repository / PR | Source commit | Build / acceptance |
|---|---|---|
| [android-NDK #43 — Default native presentation and launch windows to charcoal](https://github.com/isomorphisms/android-NDK/pull/43) | `3e682fb1175beef5625dbd2418730220e49fc9bd` | Actual shared resources and C controls compiled and packaged by FastChat |
| [FastChat #23 — Make FastChat launch, conversation and provider settings charcoal](https://github.com/isomorphisms/fastchat/pull/23) | Current `8fda332e45dc96c16b4aae9955f180d475800b9c`; independently qualified preceding APK source `1a810df430b41ea52a372e7bba1c01dc1df81512` | [Current producer 41947171842](https://github.com/isomorphisms/fastchat/actions/runs/41947171842): all signed builds and API29/API34 PASS. First API34 guest ran out of memory before app launch; exact retry passed. [Independent 41945734444](https://github.com/isomorphisms/ai-ci/actions/runs/41945734444): API29 and API34 PASS on unchanged preceding APK bytes. New source differs only in the observer pin |
| [IB #170 — Keep the native reader and retained history charcoal in every system mode](https://github.com/isomorphisms/ib/pull/170) | `f2b16841e4be8d51a4b4a88cc4264fc6681bce13` | [Producer 41947425729](https://github.com/isomorphisms/ib/actions/runs/41947425729) PASS: signed build and API29/API34 actual ART suites. Browser foundation 41947425696 remains red at the separate live arXiv prepaint step |
| [ChatGPTExporter #18 — Default native archive reader and capture shell chrome to charcoal](https://github.com/dilapidated-shed/ChatGPTExporter/pull/18) | `51bace2e9b026f0f5219d49fdf5ccaac89cb2321` | [Producer 41947436588](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588) PASS. [Independent 41950267065](https://github.com/isomorphisms/ai-ci/actions/runs/41950267065) PASS on API29/API34 with exact signed bytes and both system modes. Browser E2E, host check and native presentation PASS |
| [Tablature #10 — Make Chord Changes launch, controls and fingering canvas charcoal](https://github.com/dilapidated-shed/tablature/pull/10) | `7255ad083a1c183c42f9766ca3548c256e090daa` | [Producer 41950607269](https://github.com/dilapidated-shed/tablature/actions/runs/41950607269) PASS on API29/API34, including reader/fingering screenshot guards. [Independent launch 41956413784](https://github.com/isomorphisms/ai-ci/actions/runs/41956413784) PASS both system modes on both APIs. The original case-sensitive setlist test is retained and passes with authored button case preserved |
| [Utilities #91 — Use shared charcoal canvas and launch theme for Fixed Pasteboard](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/91) | `e3b018bfa12cd1d33cfd8ee4934ef3ce688c2a66` | [Producer 41946125428](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41946125428) PASS all six workflow/migration suites. [Independent 41950267113](https://github.com/isomorphisms/ai-ci/actions/runs/41950267113) PASS both modes on API29/API34. [API34 sampled scene](https://github.com/isomorphisms/ai-ci/actions/runs/41950267113/artifacts/13380931795) |
| [Wegert #76 — Use charcoal application chrome while preserving phase portrait colors](https://github.com/isomorphismes/wegert/pull/76) | `62bd3fcb0ba9f0ff935efe57dd6292203afa066d` | [Native/API34/35 41950617392](https://github.com/isomorphismes/wegert/actions/runs/41950617392), direct DEX/JNI41950617528 and ICK41950617449 PASS. [F-Droid 41950617535](https://github.com/isomorphismes/wegert/actions/runs/41950617535) direct reproducible/signing job PASS; buildserver container lookup fails |
| [Utilities #92 — Use the shared charcoal palette in native sensor instruments](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/92) | `7dfacda62e5b1a7b8c28925bff437602dab7e14a` | Accelerometer41951695167, Spirit Level41951695175 and Gyroscope/Magnetometer41951695226 all PASS; separate from Pasteboard branch. [Independent appearance41957592533](https://github.com/isomorphisms/ai-ci/actions/runs/41957592533) PASS all ten app/API cases, both system modes |
| [Ambient Light #2 — Default Ambient Light's native instrument and launch window to charcoal](https://github.com/isomorphisms/ambient-light/pull/2) | `590e194d8781b06b3d75a9a3cdcfec012ad646ea` | [Producer41951906524](https://github.com/isomorphisms/ambient-light/actions/runs/41951906524) PASS source-built ABI packages, API35 same-candidate replacement and actual posted frame. [Independent appearance41957592533](https://github.com/isomorphisms/ai-ci/actions/runs/41957592533) PASS both system modes on API29/API34 |
| [Proximity #4 — Use fixed charcoal launch and native sensor presentation](https://github.com/isomorphisms/Android-proximity-sensor/pull/4) | `1721c30c6c0ce82d2fa37a42344c0447a11a85dd` | [Producer41959502810](https://github.com/isomorphisms/Android-proximity-sensor/actions/runs/41959502810) PASS model, qualified ABI builds and signed APK/AAB. Initial7287f source had an incorrect relative include depth; preserved failed run41957239974 |
| [Billiard #21 — Default native Billiard chrome and framebuffer to shared charcoal](https://github.com/isomorphismes/billiard/pull/21) | `baac0eb107dcaabec48f993789abb9e12e1056f0` | ICK native41958098108, actual Rough pixels/host mathematics41958098011 and signed APK41958097962 all PASS. Android execution pending |
| [Holomorphic #67 — Use charcoal launch resources and checked shader control surfaces](https://github.com/isomorphismes/holomorphic/pull/67) | `5025b41cea08b2f173eb54b9344819be7c82fc55` | Earlier checked-fragment math/provenance PASS; native compile exposed inherited GPU timer pointer indirection. Corrected declarations preserve timing logic. Fresh checked producer41967292308 and related native producers running. Automatic PR publication remains disabled |
| [Pauli #30 — Use charcoal launch windows and explanation pages](https://github.com/isomorphismes/pauli/pull/30) | `18a7e62ce30252a3fbe0f2746b3ca00cb561a796` | Android41960123808, phone41960123840, hydrogen41960123820, Idriç41960123846 and shell41960123866 all PASS. Actual API34 frame artifact13386654737 inspected; ARM64 APK artifact13387950058 verified against signer receipt |
| [Mathieu #4 — Default Mathieu to shared charcoal while preserving exact choreography](https://github.com/isomorphismes/mathieu/pull/4) | `5a405cfbe3af93bd766d45c84b6e7d5fb801c6e3` | Run41967298674 host mathematics/session/renderer PASS; repaired ICK assembler provider, native packages and API29/API34 execution pending. Permanent certificate f997a30170a967e073ab47e1212a71b3967ffe2e1e88d78d659c77bf085cb3fe retained |
| [Mostow #9 — Use shared charcoal launch windows and native Mostow controls](https://github.com/isomorphismes/mostow/pull/9) | `7475f488f7a9c0e0c83b102e41db09f80ac6f855` | Shared owner41968006697 PASS; real math/GLES and paired packages41968006546 running |
| [Seifert #10 — Use shared charcoal launch, scene and readout surfaces in Seifert](https://github.com/isomorphismes/seifert/pull/10) | `379195711e7bff028e3d9109c2d546f4bdc29320` | Shared owner41968030895 PASS; real math/GLES41968030865 and signed ABI packages41968030989 running |
| [Spinor #10 — Use shared charcoal launch windows and native Spinor background](https://github.com/isomorphismes/spinor/pull/10) | `3b8a8f130f59c4b2e3c658769e7cd7766b074a64` | Shared contract41968051523, native41968051467 and signed packages41968051439 pending |
| [android-NDK #44 — Make current DEX construction and source-observer fixtures charcoal](https://github.com/isomorphisms/android-NDK/pull/44) | `831e5d2ba75a74ebe5b5d4f05fb8f654a93854e0` | Canonical Grease parse and actual smali3.0.10 assembly PASS; current-source framework-effects Android execution pending |
| [Flexible Pipes #265 — Restore the exact Holomorphic Grease engine from an available archive](https://github.com/isomorphisms/flexible-pipes/pull/265) | `9531b31de8a3f5dd41f8083dd2ecdd1293e31628` | Exact engine/launcher verified; actual checked-fragment consumer41959704963 job127022888126 PASS. Later native timer error is separate |
| [ai-ci #339 — Execute retained iCurses source through its real acceptance commands](https://github.com/isomorphisms/ai-ci/pull/339) | Checkpoint `137f59c557b6db5854aac0c46129d21926118d20`; product `dac8aa64292a54248b1c6804b9e9e60e5d296ce0` | Run41961330436 PASS host C/iLua, actual API34 x86_64 terminal execution and ARM64 bundle. Product branch creation returns HTTP422; existing-ref publication returned server error and retained its old head. No product implementation PR is claimed. Formal shared executable admission remains BLOCKED |
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
The later exact-head contract41956413795 passed after retrying a socket hang-up
while acquiring the unchanged runtime archive. The new canonical `bin/grease`
entrypoint also passes local native/XML mutations, frame positive/white
rejection and exact-integer Idriç replay; the launcher SHA is
`37088097c36a2f82cf45aaea9392e4a4cf16155fecb9da87d08a9c7fb4d92e4a`.

The twelve-case independent instrument appearance run41960531734 uses exact signed
candidate bytes and captures the actual resumed Activity in both system modes.
It independently samples a charcoal root and light ink inside the application
canvas. These checks do not establish sensor accuracy or full state/rotation
coverage. Six apps, including Proximity, pass both API levels and both modes.
At ai-ci source ebfb667b64009f0c0bdf9dcfafb7884196786ef5, canonical Grease
contract41960531762, FastChat41960531676, Exporter41960531599 and
Pasteboard/Chord41960531755 also pass. Historical IB41960531639 retains its older
fixture source and does not qualify the current charcoal IB APK.

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
