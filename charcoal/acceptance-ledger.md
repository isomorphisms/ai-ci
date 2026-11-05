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
| FastChat | PASS, sampled own surfaces/bars on both APIs and system modes | PASS API29/API34 rotation, resume, reopen; all retained startup-video frames pass broad-white guard locally | PASS paging, Stop, Unicode, copying, history, settings | [Signed C67 ARM64](https://github.com/isomorphisms/fastchat/actions/runs/41947171842/artifacts/13379696620) |
| IB native reader/workbench | PASS, sampled native reader/history/root/bars in both modes | PASS current-source API29/API34 lifecycle; broad-white video guard PASS locally | PASS native/ART suites; separate browser-foundation live arXiv prepaint remains red | [Signed C67 candidate](https://github.com/isomorphisms/ib/actions/runs/41947425729/artifacts/13380884545) |
| ChatGPTExporter native reader | PASS owned native reader; external ChatGPT is preserved | PASS API29/API34 lifecycle via READ_SAVED; broad-white video guard PASS locally | PASS archive/capture/copy/offline/refusals and browser checks | [Signed ARM64 and evidence](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588/artifacts/13380610037) |
| Chord Changes | PASS reader/controls/fingering on both APIs/modes | PASS five scenes; API34 lifecycle/video guard; API29 lifecycle follow-up running | PASS API29/API34 music/storage/interaction | [Signed candidates](https://github.com/dilapidated-shed/tablature/actions/runs/41950607269/artifacts/13382136270) |
| Pasteboard | Charcoal samples PASS; current lifecycle repair requalifying | Previous API34 lifecycle PASS; real previous API29 Home/resume crash; repaired both-API replay running | Current build and all three migration suites PASS; workflow API35 FAIL at control launch, investigation pending | [Current signed repair candidate](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41978032646/artifacts/13393570513) |
| Wegert / zero & infinity | IMPLEMENTED; API34/35 emulator execution PASS | Full independent chrome/night-mode/API29 samples pending; scientific colors preserved | PASS native, direct DEX/JNI and ICK boundaries; reproducible signed build PASS; F-Droid buildserver container unavailable | [Device candidate APK ZIP](https://github.com/isomorphismes/wegert/actions/runs/41950617535/artifacts/13381460123) |
| iCurses and iLua demo | Terminal defaults inherited; exact RGB belongs to terminal configuration | PASS real terminal execution on host/API34; API29 NOT_RUN | PASS C/iLua host and API34; product branch publication and formal shared admission remain BLOCKED | [ARM64 runtime checkpoint](https://github.com/isomorphisms/ai-ci/actions/runs/41961330436/artifacts/13386685529) |
| Shared android-NDK presentation | Adopted by applications; newer default TextView correction qualified | Real API34 framework color observation and missing-theme rejection PASS | All five current DEX/JNI/native/WebView/framework suites PASS | Consumed by applications; no standalone upgrade APK |
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
| Holomorphic | Shared launch and shader controls implemented | Preceding source5025b41 passes actual control pixels on API29/API34 in both modes | Current463584e strict capture requalification running; previous log incomplete and rejected | [Preceding signed APK/evidence](https://github.com/isomorphismes/holomorphic/actions/runs/41967292308/artifacts/13389803940) |
| Pauli | IMPLEMENTED shared launch theme and local explanation-page stylesheet | Actual API34 orbital frame inspected; independent chrome/page samples pending | PASS all five mathematical, ABI, Android and signed-package producers | [Signed C67 ARM64 candidate](https://github.com/isomorphismes/pauli/actions/runs/41960123808/artifacts/13387950058) |
| Mathieu | PASS actual charcoal canvas/control roles | PASS host renderer and API29/API34 both-mode interaction; API34 PNG inspected | PASS exact math/session, all three ABI builds and signed packages | [Signed C67 candidate](https://github.com/isomorphismes/mathieu/actions/runs/41969966507/artifacts/13389514461) |
| Mostow | Implemented shared default; optional paper artwork retained | PASS actual host GLES roles; inspected quotient PNG; Android pending | PASS math/GLES, ICK links, paired signed producer and real FP preflight | [Signed C67/ARM32 pair](https://github.com/isomorphismes/mostow/actions/runs/41970908432/artifacts/13390457737) |
| Seifert | Implemented shared scene/readout/launch roles | PASS real host GLES background/readout assertions; Android pending | PASS math/GLES and all three signed ABI packages | [Signed C67 candidate](https://github.com/isomorphismes/seifert/actions/runs/41970435239/artifacts/13389803751) |
| Spinor | Implemented shared neutral void/launch windows | Scientific geometry/colors preserved; Android UI samples pending | PASS host semantics, native ABI links, movie and signed three-ABI packages | [Signed C67 candidate](https://github.com/isomorphismes/spinor/actions/runs/41968051439/artifacts/13390355625) |
| Current DEX constructor/source-observer fixtures | Explicit shared theme and default widget correction | PASS actual API34 default F4 TextView; missing declared theme is rejected | PASS constructor/text/selection/reflow mutants, recovery and all five workflows | Test fixtures; no C67 upgrade package |
| Programmer's Keyboard | No application GUI in inspected main | Paper keypad/fabrication previews intentionally retain their export colors | Hardware/firmware and document-export project; no cosmetic changes made | Not applicable |
| Conway | Shared launch resources implemented; shader preserved | PASS existing API34 pan/replacement execution; both-mode API29/chrome samples pending | PASS ICK compilers, signed debug and unsigned F-Droid release build | [Signed three-ABI C67-compatible APK](https://github.com/isomorphismes/Conway/actions/runs/41976915076/artifacts/13392563447) |
| Fourier Voice and audio diagnostics | Implemented shared windows; microphone/speaker blank canvases explicitly cleared | Android both-mode visual/lifecycle checks pending; audio/scientific pixels preserved | PASS all six current workflows, including three-ABI signed packages and numeric/host/GPU references | [Signed ARM64 application set](https://github.com/isomorphismes/Fourier-sound/actions/runs/41970938009/artifacts/13391745072) |
| SURFER | Implemented shared windows and charcoal native editor/keypad/reference chrome | PASS existing API35 preset/parity execution; independent API29/API34 pending | PASS host CI and all native ICK packages; F-Droid fixed container unavailable; signer continuity BLOCKED | [Test fixture only](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/actions/runs/41970098694/artifacts/13391340281) |
| Dirichlet | Implemented browser controls/readouts; scientific field unchanged | PASS actual browser computed palette, white mutation and four WebGL portraits | PASS 17 JS tests/243 numeric comparisons; inherited C character assertion FAIL on unchanged base too | [Browser evidence](https://github.com/isomorphismes/dirichlet/actions/runs/41969073935/artifacts/13388712573) |
| Coefficient Root Dance | Implemented charcoal planes/controls and fixed launch theme | Shared owner copies PASS; actual Android acceptance running | Existing renderer/math/gesture suites retained; signing continuity BLOCKED | Pending; future debug outputs are fixtures |
| Hopf | Implemented shared neutral canvas and launch theme | Actual Android UI checks pending | Existing generated-math/gesture suites retained; signing continuity BLOCKED | Pending; future debug outputs are fixtures |
| Ortho | Implemented shared neutral canvas and launch theme | Shared owner copies PASS; actual Android UI checks pending | Generated geometry/touch unchanged; signing continuity BLOCKED | Pending; future debug outputs are fixtures |
| L | Implemented native navigation and browser charcoal; scientific fields preserved | Shared owner copies PASS; actual browser/Android visual checks pending | Existing mathematical seam retained; signing continuity BLOCKED | Pending; future debug outputs are fixtures |
| Remaining repository census | UNINSPECTED | PENDING | PENDING | PENDING |

## Exact implementation sources

| Repository / PR | Source commit | Build / acceptance |
|---|---|---|
| [android-NDK #43 — "Default native presentation and launch windows to charcoal"](https://github.com/isomorphisms/android-NDK/pull/43) | Current `e8b67dfc67776c2b8da919785d15f38d68c91db0`; established app pins `3e682fb1175beef5625dbd2418730220e49fc9bd` | New default widget correction qualified by fixture6243cab and all five workflows; older explicit-view app candidates remain separately bound |
| [FastChat #23 — Make FastChat launch, conversation and provider settings charcoal](https://github.com/isomorphisms/fastchat/pull/23) | Current `8fda332e45dc96c16b4aae9955f180d475800b9c`; independently qualified preceding APK source `1a810df430b41ea52a372e7bba1c01dc1df81512` | [Current producer 41947171842](https://github.com/isomorphisms/fastchat/actions/runs/41947171842): all signed builds and API29/API34 PASS. First API34 guest ran out of memory before app launch; exact retry passed. [Independent 41945734444](https://github.com/isomorphisms/ai-ci/actions/runs/41945734444): API29 and API34 PASS on unchanged preceding APK bytes. New source differs only in the observer pin |
| [IB #170 — Keep the native reader and retained history charcoal in every system mode](https://github.com/isomorphisms/ib/pull/170) | `f2b16841e4be8d51a4b4a88cc4264fc6681bce13` | [Producer 41947425729](https://github.com/isomorphisms/ib/actions/runs/41947425729) PASS: signed build and API29/API34 actual ART suites. Browser foundation 41947425696 remains red at the separate live arXiv prepaint step |
| [ChatGPTExporter #18 — Default native archive reader and capture shell chrome to charcoal](https://github.com/dilapidated-shed/ChatGPTExporter/pull/18) | `51bace2e9b026f0f5219d49fdf5ccaac89cb2321` | [Producer 41947436588](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588) PASS. [Independent 41950267065](https://github.com/isomorphisms/ai-ci/actions/runs/41950267065) PASS on API29/API34 with exact signed bytes and both system modes. Browser E2E, host check and native presentation PASS |
| [Tablature #10 — Make Chord Changes launch, controls and fingering canvas charcoal](https://github.com/dilapidated-shed/tablature/pull/10) | `7255ad083a1c183c42f9766ca3548c256e090daa` | [Producer 41950607269](https://github.com/dilapidated-shed/tablature/actions/runs/41950607269) PASS on API29/API34, including reader/fingering screenshot guards. [Independent launch 41956413784](https://github.com/isomorphisms/ai-ci/actions/runs/41956413784) PASS both system modes on both APIs. The original case-sensitive setlist test is retained and passes with authored button case preserved |
| [Utilities #91 — "Use shared charcoal canvas and launch theme for Fixed Pasteboard"](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/91) | Current `29d6a7a1dbad2dea7d577a710869757d8f8b9752`; previous `e3b018bfa12cd1d33cfd8ee4934ef3ce688c2a66` | Current producer41978032646 builds/signs all ABIs and passes API29/34/35 migration. Workflow API35 fails later control launch. Previous41946125428 passed its existing suites but lifecycle41976766131 proves an API29 Home/resume crash. Current repair caches/releases the Canvas producer; exact-byte lifecycle follow-up41980041161 running |
| [Wegert #76 — Use charcoal application chrome while preserving phase portrait colors](https://github.com/isomorphismes/wegert/pull/76) | `62bd3fcb0ba9f0ff935efe57dd6292203afa066d` | [Native/API34/35 41950617392](https://github.com/isomorphismes/wegert/actions/runs/41950617392), direct DEX/JNI41950617528 and ICK41950617449 PASS. [F-Droid 41950617535](https://github.com/isomorphismes/wegert/actions/runs/41950617535) direct reproducible/signing job PASS; buildserver container lookup fails |
| [Utilities #92 — Use the shared charcoal palette in native sensor instruments](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/92) | `7dfacda62e5b1a7b8c28925bff437602dab7e14a` | Accelerometer41951695167, Spirit Level41951695175 and Gyroscope/Magnetometer41951695226 all PASS; separate from Pasteboard branch. [Independent appearance41957592533](https://github.com/isomorphisms/ai-ci/actions/runs/41957592533) PASS all ten app/API cases, both system modes |
| [Ambient Light #2 — Default Ambient Light's native instrument and launch window to charcoal](https://github.com/isomorphisms/ambient-light/pull/2) | `590e194d8781b06b3d75a9a3cdcfec012ad646ea` | [Producer41951906524](https://github.com/isomorphisms/ambient-light/actions/runs/41951906524) PASS source-built ABI packages, API35 same-candidate replacement and actual posted frame. [Independent appearance41957592533](https://github.com/isomorphisms/ai-ci/actions/runs/41957592533) PASS both system modes on API29/API34 |
| [Proximity #4 — Use fixed charcoal launch and native sensor presentation](https://github.com/isomorphisms/Android-proximity-sensor/pull/4) | `1721c30c6c0ce82d2fa37a42344c0447a11a85dd` | [Producer41959502810](https://github.com/isomorphisms/Android-proximity-sensor/actions/runs/41959502810) PASS model, qualified ABI builds and signed APK/AAB. Initial7287f source had an incorrect relative include depth; preserved failed run41957239974 |
| [Billiard #21 — Default native Billiard chrome and framebuffer to shared charcoal](https://github.com/isomorphismes/billiard/pull/21) | `baac0eb107dcaabec48f993789abb9e12e1056f0` | ICK native41958098108, actual Rough pixels/host mathematics41958098011 and signed APK41958097962 all PASS. Android execution pending |
| [Holomorphic #67 — "Use charcoal launch resources and checked shader control surfaces"](https://github.com/isomorphismes/holomorphic/pull/67) | Current `463584e2e8dd6de9114701f49ca9d78baf8710a4`; visually sampled product `5025b41cea08b2f173eb54b9344819be7c82fc55` | Previous41967292308 signs all three ABIs but strict math fails: timer metadata crashed old checker and retained observations are incomplete. Scientific appearance41976395534 PASS both APIs/modes on exact5025b41 APK. Current41977273427 streams actual logs before launch and uses strict timer-aware owner; numeric acceptance remains pending. No PR release publication |
| [Pauli #30 — Use charcoal launch windows and explanation pages](https://github.com/isomorphismes/pauli/pull/30) | `18a7e62ce30252a3fbe0f2746b3ca00cb561a796` | Android41960123808, phone41960123840, hydrogen41960123820, Idriç41960123846 and shell41960123866 all PASS. Actual API34 frame artifact13386654737 inspected; ARM64 APK artifact13387950058 verified against signer receipt |
| [Mathieu #4 — "Default Mathieu to shared charcoal while preserving exact choreography"](https://github.com/isomorphismes/mathieu/pull/4) | `dc2171acebe20035f102db3a0b2b522d4fdd0a3b` | All41969966507 jobs PASS: exact mathematics/session, actual host pixels, three ABI compilers/signing and API29/API34 both-mode UI. Visual artifacts13390686883/API29 and13391035324/API34; actual API34 scene inspected. Permanent signer f997a30170a967e073ab47e1212a71b3967ffe2e1e88d78d659c77bf085cb3fe retained |
| [Mostow #9 — "Use shared charcoal launch windows and native Mostow controls"](https://github.com/isomorphismes/mostow/pull/9) | `de1bd5f51cb22179ac0c9876227b347b1c8e0650` | Shared41970908437 and all math/GLES/ICK/signed-pair jobs41970908432 PASS. Host PNG artifact13389924380 inspected; paired artifact13390457737 includes real FP preflight and stable de9b signer. Android execution pending |
| [Seifert #10 — "Use shared charcoal launch, scene and readout surfaces in Seifert"](https://github.com/isomorphismes/seifert/pull/10) | `3352f024a709201594d16e1dbbe2ffcf3fe3099c` | Shared41970435238, actual host math/GLES41970435361 and all three signed ABI packages41970435239 PASS. Android execution pending; previous crop-coordinate observer failure is retained in source documentation |
| [Spinor #10 — "Use shared charcoal launch windows and native Spinor background"](https://github.com/isomorphismes/spinor/pull/10) | `3b8a8f130f59c4b2e3c658769e7cd7766b074a64` | Shared41968051523, native41968051467, signed three-ABI41968051439 and movie41968051500 all PASS. Android UI execution pending |
| [android-NDK #44 — "Make current DEX construction and source-observer fixtures charcoal"](https://github.com/isomorphisms/android-NDK/pull/44) | `6243cab2cdcfe2cde7f04ee155051bb4ff3bb263` | All five current workflows PASS: WebView41972785703, NativeActivity41972785329, audio41972785323, DEX/JNI41972785452 and framework-effects/API34 41972785503. Real default F4 text, missing-theme rejection, prior semantic mutants and recovery PASS. API29/both-mode startup/rotation remain pending |
| [Flexible Pipes #265 — Restore the exact Holomorphic Grease engine from an available archive](https://github.com/isomorphisms/flexible-pipes/pull/265) | `9531b31de8a3f5dd41f8083dd2ecdd1293e31628` | Exact engine/launcher verified; actual checked-fragment consumer41959704963 job127022888126 PASS. Later native timer error is separate |
| [ai-ci #339 — Execute retained iCurses source through its real acceptance commands](https://github.com/isomorphisms/ai-ci/pull/339) | Checkpoint `137f59c557b6db5854aac0c46129d21926118d20`; product `dac8aa64292a54248b1c6804b9e9e60e5d296ce0` | Run41961330436 PASS host C/iLua, actual API34 x86_64 terminal execution and ARM64 bundle. Product branch creation returns HTTP422; existing-ref publication returned server error and retained its old head. No product implementation PR is claimed. Formal shared executable admission remains BLOCKED |
| [ai-ci #338 — "Require fixed charcoal roots, controls and bars in native UI acceptance"](https://github.com/isomorphisms/ai-ci/pull/338) | `ebfb667b64009f0c0bdf9dcfafb7884196786ef5` | Shared41960531762, FastChat41960531676, sensor41960531734, Pasteboard/Chord41960531755 and Exporter41960531599 PASS. Historical IB41960531639 is not current-source IB acceptance |

| [Conway #12 — "Use shared charcoal launch windows for the native Conway wallpaper"](https://github.com/isomorphismes/Conway/pull/12) | `8835d5400451c12f394a9e1b2d9a67d72f419bf8` | Shared41976914920, Android41976915076 and unsigned release41976914841 PASS. API34 real pan and replacement; stable de9b signer. Old .base64 compiler failure repaired through existing qualified provider |
| [Fourier-sound #35 — "Default Fourier Voice and audio diagnostics to shared charcoal windows"](https://github.com/isomorphismes/Fourier-sound/pull/35) | `d16beea60d7b3ece9853a8705edd641bbc7ec1b0` | All six workflows PASS: native41970938009, stripped41970938088, ICK voice41970938043, numeric41970938121, GPU reference41970938428 and copies41970938149. ARM64 set includes six signed app/diagnostic APKs |
| [SURFER #34 — "Make SURFER native controls and reference application chrome charcoal"](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/pull/34) | `669a94fd8e89ff467e371f5b21cf14327e4ee408` | CI41970098560, native packages/API35 41970098694 and shared41970098642 PASS. Unsigned release job41970098630 PASS; immutable F-Droid container unavailable. Inherited ephemeral signer blocks upgrade delivery |
| [Dirichlet #27 — "Use shared charcoal roles in Dirichlet viewer controls and readouts"](https://github.com/isomorphismes/dirichlet/pull/27) | `17546b28412a32300e34d623acd9d29cd3203a66` | Browser41969073935 PASS, actual four portraits and computed-style white negative. Host C41969073887 repeats unchanged base265442 failure from39349613589; generated C41969073768 cancelled. No numerical predicate weakened |
| [coefficient-root-dance #8 — "Make coefficient and root planes, controls and launch windows charcoal"](https://github.com/isomorphismes/coefficient-root-dance/pull/8) | `a47c074ac58613d34fcc907cafa460291d16cd78` | Current exact-source build/visual checks pending; shared copy checks available from the linked PR. Preserved signing identity unavailable; debug builds remain fixtures |
| [hopf_fibration #6 — "Use shared charcoal launch windows and neutral Hopf canvas"](https://github.com/isomorphismes/hopf_fibration/pull/6) | `4ffe8bc03417b79c4a919d0ca1bb23c94487b999` | Current exact-source build/visual checks pending; shared copy checks available from the linked PR. Preserved signing identity unavailable; debug builds remain fixtures |
| [ortho #5 — "Use shared charcoal launch windows and neutral orthant canvas"](https://github.com/isomorphismes/ortho/pull/5) | `403cabed581849e612790f0ce0166f8098665b6f` | Current exact-source build/visual checks pending; shared copy checks available from the linked PR. Preserved signing identity unavailable; debug builds remain fixtures |
| [L #5 — "Make L navigation, browser controls and launch windows charcoal"](https://github.com/isomorphismes/L/pull/5) | `61a19d59381ba240236647663602213fbdabe470` | Current exact-source build/visual checks pending; shared copy checks available from the linked PR. Preserved signing identity unavailable; debug builds remain fixtures |
| [ai-ci #340 — "Prepare independent checked-shader charcoal control acceptance"](https://github.com/isomorphisms/ai-ci/pull/340) | `69ebba2e2499a391d53b75b0326df5f8b770a8ad` | Run41976395534 PASS API29/API34 both modes; exact signed source5025b41 and checked-fragment driver digest. Evidence13392246564/API29 and13392287073/API34. Actual API34 controls inspected; mathematical parity not inferred |
| [ai-ci #342 — "Share canonical charcoal copy verification across native applications"](https://github.com/isomorphisms/ai-ci/pull/342) | `876a843dd7c5c635adaba854a53fd6f2c2139210` | New shared e8b67 owner and white-root copy negative PASS41978238512. Earlier immutable consumers still bind their qualified3e682 owner/action versions |
| [ai-ci #343 — "Replay priority charcoal APKs through rotation and reopening on both APIs"](https://github.com/isomorphisms/ai-ci/pull/343) | `90e216fecfe9e958d0fc55c807cb778e81e75ff8` | Previous41976766131 PASS all five API34 cases and three API29 cases; Pasteboard API29 crash retained. Current41980041161 replays repaired signed source and all-frame broad-white guard. Current results pending |
| [ai-ci #344 — "Keep GPU timer metadata separate from mathematical observations"](https://github.com/isomorphisms/ai-ci/pull/344) | `61c8c914acb2586b72b8a948a723e7f8579baaa6` | Actual Ithon self-tests41977411156 PASS. Shader consumer pins ancestorf3caae8 with identical checker bytes. Timer rows cannot substitute for missing measurements; current retained incomplete logs remain rejected |

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
The per-app rows distinguish the lifecycle cases already executed from remaining
IME, partial-dialog, loading/error/offline, full startup and state-retention
coverage. Broad-white video guards do not prove every partial surface or dialog.
Package IDs, maintained development signers, data formats and installation
authority are preserved. The separately identified SURFER, Hopf, Ortho, L and
Coefficient Root Dance lanes lack preserved keys; their fixtures are not approved
C67 upgrades. Artifact availability does not authorize installation.

The old android-NDK direct-DEX demonstration builders still generate temporary
debug signers and omit the shared theme resources. They are not approved C67
upgrade artifacts. Their resource/builder integration remains outstanding;
this job has not silently migrated their package or signing identity.


## Recent lifecycle and compositor evidence

At sourcef1f47992, run41976766131 retains current-source FastChat, IB and Exporter
lifecycle PASS on both APIs and old Pasteboard/Chord PASS on API34. Artifacts
[API29](https://github.com/isomorphisms/ai-ci/actions/runs/41976766131/artifacts/13391369878)
and [API34](https://github.com/isomorphisms/ai-ci/actions/runs/41976766131/artifacts/13391893355)
contain actual videos, ten settled stages per passing app/API and receipts.
Exporter uses its existing READ_SAVED native empty/error entry; its external
ChatGPT default page is intentionally not restyled. Pasteboard's portrait lock
is retained. Its real API29 resume crash is a product failure, not a palette
failure; the current candidate repairs Surface lifetime rather than bypassing
resume.

Local canonical Grease decoded all16 videos from the eight passing app/API
cases, examined every frame and rejected no broad light canvas. An encoded
single-white-frame mutant is rejected. This guard is now in the current hosted
replay; small icons, launcher artwork and partial dialogs are outside that
whole-canvas predicate. The selected Chord startup contact sheet and real
Holomorphic API34 control screenshot were visually inspected. Scientific fields
are never judged by a global dark-coverage threshold.
