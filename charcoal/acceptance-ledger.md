# Universal charcoal UI acceptance

Request: `SUN-UNIVERSAL-DARK-CHARCOAL-UI-COMPLETE-01`.

This job is **incomplete**. A source edit, signed package, functional test,
visual sample and physical-device check are separate evidence. `PENDING` means
the condition has not passed, rather than an inferred success. No branch has
been merged, release published, or installed application replaced.

The repository census contains 452 accessible user-owned repositories across
14 accounts: 442 public repositories in [repository-inventory.tsv](repository-inventory.tsv)
and 10 private repositories whose names are not published here. Enumeration is
complete for those accounts; interface discovery and supported-build
classification are not. An UNINSPECTED row is outstanding work, not an exclusion.

| Project | Dark default | Visual test | Regression tests | Artifact |
|---|---|---|---|---|
| FastChat | PASS, sampled launch/root/controls/bars in both system modes on API29 and API34 | PASS, API29/API34 compositor and screenshot; rotation/transition coverage pending | PASS, both APIs: paging, Stop, Unicode, exact copying, history and provider settings | [Signed C67 ARM64 APK ZIP](https://github.com/isomorphisms/fastchat/actions/runs/41947171842/artifacts/13379696620) |
| IB native reader/workbench | PENDING execution | PENDING | Current producer rerunning | PENDING |
| ChatGPTExporter native reader | PASS, API34 sampled root/controls/bars in both system modes | PASS, API34 compositor and screenshot; independent API29/34 replay prepared | PASS, signed/reproducible build, API34 archive/capture/refusal checks and browser checks | [Signed ARM64 candidate and evidence](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588/artifacts/13380610037) |
| Chord Changes | Charcoal reader and fingering frames observed | Coarse reader frame PASS, functional run incomplete | Storage upgrade, parser and semitone tests passed; later fresh accessibility root failed | [Signed candidates and failure evidence](https://github.com/dilapidated-shed/tablature/actions/runs/41946000057/artifacts/13379281466) |
| Pasteboard | API34 sampled canvas/window PASS | API34 three-board screenshot PASS, 97 percent dark pixels; both system modes pending | Signed ABI packages and regression variants PASS; real migration PASS on API29/34/35; workflow suite results below | [Signed candidate APK ZIP](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41946125428/artifacts/13378759643) |
| Wegert / zero & infinity | PENDING visual qualification | PENDING, scientific image colors excluded | Reproducible direct APK build and stable signing PASS; F-Droid container unavailable | [Device candidate APK ZIP](https://github.com/isomorphismes/wegert/actions/runs/41946005535/artifacts/13377813818) |
| iCurses and iLua demo | PENDING | PENDING | Local changes; branch publication blocked | Unpublished Git commit below |
| Shared android-NDK presentation | Adopted by app branches | Qualified through FastChat API29/API34 | Native/XML palette mutation, frame rejection and integer contrast PASS locally and hosted | Consumed in signed FastChat packages |
| Other utility applications | PENDING implementation | PENDING | Existing tests do not qualify new palette | PENDING |
| Wardriving | Terminal inheritance; no graphical app in inspected source | Not applicable to current CLI | No theme changes required for terminal inheritance | No APK exists at inspected source |
| Cat Food | Terminal inheritance; no graphical source found in inspected main | GUI testing interfaces belong to app/example repositories | Existing receipts do not qualify the new app builds | Delivery registration pending qualification |
| Grease | Terminal policy audit pending | No forced terminal palette | No cosmetic changes made | Not applicable |
| Ambient Light / related shared sensor instruments | Existing NativeActivity implementation discovered on active font branch | PENDING | Integration pending in shared instrument owner | PENDING |
| Holomorphic, Conway, Pauli | Additional indexed Android manifests discovered | PENDING | Source and active-branch inspection pending | PENDING |
| Remaining repository census | UNINSPECTED | PENDING | PENDING | PENDING |

## Exact implementation sources

| Repository / PR | Source commit | Build / acceptance |
|---|---|---|
| [android-NDK #43 — Default native presentation and launch windows to charcoal](https://github.com/isomorphisms/android-NDK/pull/43) | `3e682fb1175beef5625dbd2418730220e49fc9bd` | Actual shared resources and C controls compiled and packaged by FastChat |
| [FastChat #23 — Make FastChat launch, conversation and provider settings charcoal](https://github.com/isomorphisms/fastchat/pull/23) | Current `8fda332e45dc96c16b4aae9955f180d475800b9c`; independently qualified preceding APK source `1a810df430b41ea52a372e7bba1c01dc1df81512` | [Current producer 41947171842](https://github.com/isomorphisms/fastchat/actions/runs/41947171842): all signed builds and API29/API34 PASS. First API34 guest ran out of memory before app launch; exact retry passed. [Independent 41945734444](https://github.com/isomorphisms/ai-ci/actions/runs/41945734444): API29 and API34 PASS on unchanged preceding APK bytes. New source differs only in the observer pin |
| [IB #170 — Keep the native reader and retained history charcoal in every system mode](https://github.com/isomorphisms/ib/pull/170) | `f2b16841e4be8d51a4b4a88cc4264fc6681bce13` | [Producer 41947425729](https://github.com/isomorphisms/ib/actions/runs/41947425729), pending. Browser foundation 41947425696 failed; preceding head failed its live arXiv prepaint step, separate from Android theming |
| [ChatGPTExporter #18 — Default native archive reader and capture shell chrome to charcoal](https://github.com/dilapidated-shed/ChatGPTExporter/pull/18) | `51bace2e9b026f0f5219d49fdf5ccaac89cb2321` | [Producer 41947436588](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588) PASS, including API34 in both modes and offline reopening/copy/source/refusal checks. Browser E2E, check and native presentation workflows PASS. Independent API29/API34 same-byte replay prepared |
| [Tablature #10 — Make Chord Changes launch, controls and fingering canvas charcoal](https://github.com/dilapidated-shed/tablature/pull/10) | `797c5bf4983e51a1bb0d75c689a5a92def5c1c02` | [Current producer 41948393539](https://github.com/dilapidated-shed/tablature/actions/runs/41948393539) pending. Previous `c96111fe` [producer 41946000057](https://github.com/dilapidated-shed/tablature/actions/runs/41946000057) failed a later fresh accessibility dump after storage upgrades and semitone checks passed. Current source additionally assigns primary text explicitly |
| [Utilities #91 — Use shared charcoal canvas and launch theme for Fixed Pasteboard](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/91) | `e3b018bfa12cd1d33cfd8ee4934ef3ce688c2a66` | [Producer 41946125428](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41946125428): signed builds and API29/34/35 migrations PASS; workflow suites API34/35 PASS and API29 final status pending. [API34 visual/functional evidence](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41946125428/artifacts/13379208914) |
| [Wegert #76 — Use charcoal application chrome while preserving phase portrait colors](https://github.com/isomorphismes/wegert/pull/76) | `23beee5efd901999c7218b1201df24feeebf8538` | [Native build 41946005576](https://github.com/isomorphismes/wegert/actions/runs/41946005576), pending; [F-Droid 41946005535](https://github.com/isomorphismes/wegert/actions/runs/41946005535) failed |
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
