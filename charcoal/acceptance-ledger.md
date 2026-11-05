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

## Current shared-widget adoption

Shared owner [android-NDK #43](https://github.com/isomorphisms/android-NDK/pull/43)
is `e8b67dfc67776c2b8da919785d15f38d68c91db0`. Compared with the preceding
shared source3e682fb1, only seven XML lines change: default TextViews and dialogs
use the explicit stateful F4/disabled85 foreground. Actual API34 framework
observation at [fixture #44](https://github.com/isomorphisms/android-NDK/pull/44)
passes and rejects a missing-theme candidate. All five current fixture workflows
pass. Color roles and application mathematics are unchanged.

The following application heads now adopt that correction. **A prior accepted
APK does not qualify a newer source head.** The five current priority APKs now pass the sampled lifecycle on both APIs
and both system modes; full state coverage and remaining applications are
being reconciled below. The TSV always records current
source identities; historical proofs are identified separately.

| Project / implementation PR | Exact current source | Current acceptance | Build / acceptance runs |
|---|---|---|---|
| [FastChat #23](https://github.com/isomorphisms/fastchat/pull/23) | `215ef98c09e667cdb4335d19a7041a49c7d6e5e1` | PASS CURRENT FIVE APP LIFECYCLE AND VIDEO NEGATIVE; PASS CURRENT PRODUCER SUITES | [41990448769](https://github.com/isomorphisms/fastchat/actions/runs/41990448769), [41990448464](https://github.com/isomorphisms/fastchat/actions/runs/41990448464), [41990448869](https://github.com/isomorphisms/fastchat/actions/runs/41990448869), [41990448481](https://github.com/isomorphisms/fastchat/actions/runs/41990448481) |
| [IB #170](https://github.com/isomorphisms/ib/pull/170) | `336c17c5bc3975f7e113c4ffec4de69687ebd2aa` | PASS CURRENT FIVE APP LIFECYCLE AND VIDEO NEGATIVE; PASS NATIVE API29 API34 BROWSER FOUNDATION FAIL | [41990454619](https://github.com/isomorphisms/ib/actions/runs/41990454619), [41990454629](https://github.com/isomorphisms/ib/actions/runs/41990454629), [41990454666](https://github.com/isomorphisms/ib/actions/runs/41990454666) |
| [ChatGPTExporter #18](https://github.com/dilapidated-shed/ChatGPTExporter/pull/18) | `e682e0c865ba87d4793e3a4e62ebf6864db2b188` | PASS CURRENT FIVE APP LIFECYCLE AND VIDEO NEGATIVE; PASS CURRENT PRODUCER SUITES | [41990459633](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41990459633), [41990459664](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41990459664), [41990459996](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41990459996), [41990459787](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41990459787) |
| [Chord Changes #10](https://github.com/dilapidated-shed/tablature/pull/10) | `bd7d6be5b09b77f371bd97302002ddc8966d543c` | PASS CURRENT FIVE APP LIFECYCLE AND VIDEO NEGATIVE; PASS CURRENT PRODUCER SUITES | [41990465047](https://github.com/dilapidated-shed/tablature/actions/runs/41990465047) |
| [Pasteboard #91](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/91) | `df2df8f18840c98a175b958f07749bb423e80ff0` | PASS CURRENT FIVE APP LIFECYCLE AND VIDEO NEGATIVE; PASS CURRENT PRODUCER SUITES | [41990472327](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990472327), [41990472269](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990472269), [41990472262](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990472262), [41990472333](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990472333), [41990472251](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990472251), [41990472306](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990472306) |
| [Sensor instruments #92](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/92) | `4c7fcfcdd22468e8abaa368eb863c012784909df` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990334727](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990334727), [41990334761](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990334761), [41990334852](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990334852), [41990334839](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990334839) |
| [ambient-light #2](https://github.com/isomorphisms/ambient-light/pull/2) | `2c93d0deeaacde5e1b43297648fc26afcd9935dd` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990477641](https://github.com/isomorphisms/ambient-light/actions/runs/41990477641) |
| [Android-proximity-sensor #4](https://github.com/isomorphisms/Android-proximity-sensor/pull/4) | `26cf4cc9d13818658d91d09b909d7cf92f5ccb86` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990482008](https://github.com/isomorphisms/Android-proximity-sensor/actions/runs/41990482008) |
| [wegert #76](https://github.com/isomorphismes/wegert/pull/76) | `e2fdb7939352bd0ccc9e8a49b54657bee562f5a5` | PASS API34 API35 EXECUTION API29 BOTH MODE PENDING; PASS NATIVE DEX ICK FDROID RECIPE FAIL | [41990641613](https://github.com/isomorphismes/wegert/actions/runs/41990641613), [41990641677](https://github.com/isomorphismes/wegert/actions/runs/41990641677), [41990641633](https://github.com/isomorphismes/wegert/actions/runs/41990641633), [41990641679](https://github.com/isomorphismes/wegert/actions/runs/41990641679), [41990641573](https://github.com/isomorphismes/wegert/actions/runs/41990641573), [41990641638](https://github.com/isomorphismes/wegert/actions/runs/41990641638) |
| [billiard #21](https://github.com/isomorphismes/billiard/pull/21) | `327150bdd3f48e4b78d9d29ebc8c6ac6ec6f25bd` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990486719](https://github.com/isomorphismes/billiard/actions/runs/41990486719), [41990486799](https://github.com/isomorphismes/billiard/actions/runs/41990486799), [41990487024](https://github.com/isomorphismes/billiard/actions/runs/41990487024) |
| [holomorphic #67](https://github.com/isomorphismes/holomorphic/pull/67) | `83acc7a7d5e73f2efdb79425e35c6f54f67a91f2` | CURRENT API29 API34 REPLAY PENDING; PASS STRICT GPU API34 AUXILIARY FIRST FRAME OBSERVER FAIL | [41990492896](https://github.com/isomorphismes/holomorphic/actions/runs/41990492896), [41990493281](https://github.com/isomorphismes/holomorphic/actions/runs/41990493281), [41990493268](https://github.com/isomorphismes/holomorphic/actions/runs/41990493268), [41990493311](https://github.com/isomorphismes/holomorphic/actions/runs/41990493311), [41990493341](https://github.com/isomorphismes/holomorphic/actions/runs/41990493341), [41990493402](https://github.com/isomorphismes/holomorphic/actions/runs/41990493402) |
| [pauli #30](https://github.com/isomorphismes/pauli/pull/30) | `83470a9991263f5a2b4fc5a6ff4ef3216c877f8e` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990500303](https://github.com/isomorphismes/pauli/actions/runs/41990500303), [41990500243](https://github.com/isomorphismes/pauli/actions/runs/41990500243), [41990500319](https://github.com/isomorphismes/pauli/actions/runs/41990500319), [41990500288](https://github.com/isomorphismes/pauli/actions/runs/41990500288), [41990500373](https://github.com/isomorphismes/pauli/actions/runs/41990500373) |
| [mathieu #4](https://github.com/isomorphismes/mathieu/pull/4) | `41da46d2ab718e7c780c7fc1afdc187f7781af64` | PASS CURRENT HOST AND API29 API34 CONTROLS; PASS CURRENT PRODUCER SUITES | [41990504391](https://github.com/isomorphismes/mathieu/actions/runs/41990504391) |
| [mostow #9](https://github.com/isomorphismes/mostow/pull/9) | `4a0fb0fb32bde11b1552b32eb2b1e49db7e7aceb` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990509715](https://github.com/isomorphismes/mostow/actions/runs/41990509715), [41990509695](https://github.com/isomorphismes/mostow/actions/runs/41990509695) |
| [seifert #10](https://github.com/isomorphismes/seifert/pull/10) | `f522c7232952ae881d0cf91ab6e975434866bbca` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990515554](https://github.com/isomorphismes/seifert/actions/runs/41990515554), [41990515526](https://github.com/isomorphismes/seifert/actions/runs/41990515526), [41990515436](https://github.com/isomorphismes/seifert/actions/runs/41990515436) |
| [spinor #10](https://github.com/isomorphismes/spinor/pull/10) | `d9ecb67c139e56510b9f5654cd8866f1e6d53ca0` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990518397](https://github.com/isomorphismes/spinor/actions/runs/41990518397), [41990518481](https://github.com/isomorphismes/spinor/actions/runs/41990518481), [41990518471](https://github.com/isomorphismes/spinor/actions/runs/41990518471), [41990518722](https://github.com/isomorphismes/spinor/actions/runs/41990518722) |
| [Fourier-sound #35](https://github.com/isomorphismes/Fourier-sound/pull/35) | `d126017664ca8b2cfe31e10e2903d1b3fe24e212` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990523256](https://github.com/isomorphismes/Fourier-sound/actions/runs/41990523256), [41990523195](https://github.com/isomorphismes/Fourier-sound/actions/runs/41990523195), [41990523176](https://github.com/isomorphismes/Fourier-sound/actions/runs/41990523176), [41990523298](https://github.com/isomorphismes/Fourier-sound/actions/runs/41990523298), [41990523164](https://github.com/isomorphismes/Fourier-sound/actions/runs/41990523164), [41990523152](https://github.com/isomorphismes/Fourier-sound/actions/runs/41990523152) |
| [Conway #12](https://github.com/isomorphismes/Conway/pull/12) | `2121ab622fe5637cced421a1fcef453a1a0d1c44` | API29 API34 INDEPENDENT VISUAL PENDING; PASS CURRENT PRODUCER SUITES | [41990530880](https://github.com/isomorphismes/Conway/actions/runs/41990530880), [41990530795](https://github.com/isomorphismes/Conway/actions/runs/41990530795), [41990530738](https://github.com/isomorphismes/Conway/actions/runs/41990530738) |
| [algebraic-variety-explorer-mobile #34](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/pull/34) | `ecb721f62237ef7f2b97060e0bfd6b050a62c859` | PASS API35 NATIVE PARITY BOTH MODE PALETTE PENDING; PASS NATIVE AND CI FDROID RECIPE FAIL | [41990537536](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/actions/runs/41990537536), [41990537425](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/actions/runs/41990537425), [41990537451](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/actions/runs/41990537451), [41990537527](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/actions/runs/41990537527) |

## Current priority replay and delivery

Observer `fb0d0602f5550a0f30f77ef94e343bcebfe7f822` passes both VM jobs in
[41996501618](https://github.com/isomorphisms/ai-ci/actions/runs/41996501618).
It binds all five current sources above, immutable producer artifacts and
downloaded APK SHA256 values. The unchanged observer captures 100 settled PNG
stages and20 actual videos, checks both system night modes, replacement,
cold start, rotation policy, Home/resume and force-stop reopen, and rejects the
encoded single-white-frame control. Evidence:
[API29](https://github.com/isomorphisms/ai-ci/actions/runs/41996501618/artifacts/13401086000),
[API34](https://github.com/isomorphisms/ai-ci/actions/runs/41996501618/artifacts/13400677386).

| Current candidate | Signed ARM64-containing artifact |
|---|---|
| fastchat | [Producer41990448769, artifact13397841839](https://github.com/isomorphisms/fastchat/actions/runs/41990448769/artifacts/13397841839) |
| ib | [Producer41990454666, artifact13400366625](https://github.com/isomorphisms/ib/actions/runs/41990454666/artifacts/13400366625) |
| ChatGPTExporter | [Producer41990459787, artifact13398432041](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41990459787/artifacts/13398432041) |
| tablature | [Producer41990465047, artifact13398119356](https://github.com/dilapidated-shed/tablature/actions/runs/41990465047/artifacts/13398119356) |
| Pasteboard | [Producer41990472251, artifact13398546503](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41990472251/artifacts/13398546503) |

These are review/test candidates. Partial dialogs, IME behavior, every document
state and physical C67 acceptance are outside the sampled lifecycle claim.

## Additional utility and Android frontends

| Project | Current source | PR | Validation / limitation |
|---|---|---|---|
| isomorphismes/sprott | `cafbfe7ddbd741ff86efa8955a75dc2471e04b44` | [#4](https://github.com/isomorphismes/sprott/pull/4) | PASS PRIOR HOST ARMV7 CURRENT QUALIFIED PRODUCER PENDING; API29 API34 NOT RUN |
| isomorphismes/mock-theta | `df571df0e191f038223b04a5058f026482346d73` | [#4](https://github.com/isomorphismes/mock-theta/pull/4) | PASS HOST TYPES AND ARMV7 APK; API29 API34 NOT RUN |
| isomorphismes/p-adic | `3893329bc604eda45ebee1fecb616c3ab9d7dc00` | [#2](https://github.com/isomorphismes/p-adic/pull/2) | PASS CURRENT SIGNED ARMV7 AND SHARED COPY; API29 API34 BROWSER NOT RUN |
| Ashtray-Archer/az | `9a26f501d95a672bf39e58954560200daf256073` | [#30](https://github.com/Ashtray-Archer/az/pull/30) | PASS HOST AND UNSIGNED ANDROID BUILD; API29 API34 NOT RUN |
| Ashtray-Archer/zoneedit | `dad535acd65381f2f95c3b4a01df65b4ccbca3f0` | [#3](https://github.com/Ashtray-Archer/zoneedit/pull/3) | PASS SHARED COPY CURRENT NATIVE BUILD PENDING; CURRENT API34 RUNTIME PENDING |
| Ashtray-Archer/porthole | `7b108e1cbdf2082c135b3c9aaee08d07b45bbe07` | [#1](https://github.com/Ashtray-Archer/porthole/pull/1) | PASS KTLINT COMPILE FAIL DETEKT LITERAL AND SHARED NEWAPI; API29 API34 NOT RUN |
| Ashtray-Archer/WifiScanner | `1ad0a8fbcb6847b98e46c9699dcd8a4626e7c93f` | [#1](https://github.com/Ashtray-Archer/WifiScanner/pull/1) | PASS SHARED COPY CURRENT BUILD LINT PENDING; API29 API34 NOT RUN |
| Unicode Picker / Compact IME / Clipboard smoke | `44221b2c3fd00778b39dbbab13d1b4b997607e7b` | [#93](https://github.com/Ashtray-Archer/utilities-android-phone-user/pull/93) | All current producer suites PASS, including actual API29 native picker, real IME typing and clipboard receipt. Both-mode/API34 palette lifecycle remains pending. |

Porthole's actual Android lint reports four NewApi errors in the shared E8
base resource: newer navigation-icon and force-dark attributes need proper
version-qualified definitions for the retained older API floor. This is an
outstanding shared-contract repair, with lint retained. Its new Compose
sources compile and ktlint passes; Detekt additionally requires named resources
for four literal colors in the added styling expressions. The existing
API29/API34 appearance passes remain tied to their exact accepted APKs.

## Other implemented applications

| Project | Source / PR | Dark default | Visual test | Regression tests | Artifact |
|---|---|---|---|---|---|
| coefficient-root-dance | [#8](https://github.com/isomorphismes/coefficient-root-dance/pull/8), `f9314060db59b7d6641f3033a78053cf02fb5ff3` | IMPLEMENTED SIGNING CONTINUITY BLOCKED | NATIVE EMULATOR EXECUTED BOTH MODE PALETTE PENDING | PASS NATIVE ANDROID AND FDROID | - |
| L | [#5](https://github.com/isomorphismes/L/pull/5), `295683b5b600699c0ac8132f20c29a1f0ac750fd` | IMPLEMENTED NATIVE BROWSER SIGNING BLOCKED | PRIOR APK EMULATOR PASS CURRENT BUILD PENDING | PENDING IDRIC MAKE LAYOUT REPAIR | - |
| hopf_fibration | [#6](https://github.com/isomorphismes/hopf_fibration/pull/6), `4ffe8bc03417b79c4a919d0ca1bb23c94487b999` | IMPLEMENTED SIGNING CONTINUITY BLOCKED | BOTH MODE PALETTE LIFECYCLE PENDING | PASS ANDROID NATIVE PROTOTYPE | - |
| ortho | [#5](https://github.com/isomorphismes/ortho/pull/5), `403cabed581849e612790f0ce0166f8098665b6f` | IMPLEMENTED SIGNING CONTINUITY BLOCKED | BOTH MODE PALETTE LIFECYCLE PENDING | PASS ANDROID NATIVE PROTOTYPE | - |
| theta | [#4](https://github.com/isomorphismes/theta/pull/4), `cb0d21adb6883b02b3cab586486c210d40e29604` | IMPLEMENTED SHARED E8 SIGNING BLOCKED | SIX RENDERER ANDROID PALETTE PENDING | PASS RENDERER BAKEOFF AND SHARED COPIES | - |
| young-tableaux | [#23](https://github.com/isomorphismes/young-tableaux/pull/23), `0f200b000bc4de41e0469d1fe65c7dbbad3db5d8` | IMPLEMENTED RUNTIME ADMISSION BLOCKED | OBSERVABLE JDT PASS ANDROID NOT RUN | PASS INDEPENDENT MATH EXPIRED TYPED COMPILER AND ADMISSION BLOCKED | - |
| mock-theta | [#4](https://github.com/isomorphismes/mock-theta/pull/4), `df571df0e191f038223b04a5058f026482346d73` | IMPLEMENTED SHARED E8 ARMV7 ONLY | API29 API34 NOT RUN | PASS SHARED AND TYPES NATIVE BUILD PENDING | - |
| sprott | [#4](https://github.com/isomorphismes/sprott/pull/4), `23c9a678c58fd1192e52c1e3d50996ed4ef66500` | IMPLEMENTED SHARED E8 SIGNING BLOCKED | API29 API34 NOT RUN | PASS LOCAL COPY PARSE CURRENT NATIVE CI PENDING | - |
| p-adic | [#2](https://github.com/isomorphismes/p-adic/pull/2), `3893329bc604eda45ebee1fecb616c3ab9d7dc00` | IMPLEMENTED SHARED E8 ARMV7 ONLY | API29 API34 BROWSER NOT RUN | PASS LOCAL COPY PARSE CURRENT ANDROID CI PENDING | - |
| indras-pearls | [#16](https://github.com/isomorphismes/indras-pearls/pull/16), `cffa79aa7e142cd6f2296078515e3b6296840a03` | IMPLEMENTED SHARED E8 SCIENTIFIC RASTER PRESERVED | API29 API34 NOT RUN | PASS LOCAL COPY CURRENT HOST NATIVE CI PENDING | - |

Dirichlet [#27](https://github.com/isomorphismes/dirichlet/pull/27) remains at
`17546b28412a32300e34d623acd9d29cd3203a66`: computed browser palette, white-root
negative and four WebGL portraits pass
[41969073935](https://github.com/isomorphismes/dirichlet/actions/runs/41969073935).
The independent JavaScript checks pass; the inherited host C oracle also fails
on the unchanged base. Its mathematical threshold was not weakened.

iCurses uses terminal default foreground/background, including its iLua demo.
The retained product patch is `dac8aa64292a54248b1c6804b9e9e60e5d296ce0`;
publication into the product repository remains blocked by repository ref
errors. [Independent #339](https://github.com/isomorphisms/ai-ci/pull/339)
executes the actual patch: host C/iLua, actual Android34 terminal and the
[ARM64 checkpoint](https://github.com/isomorphisms/ai-ci/actions/runs/41961330436/artifacts/13386685529)
pass. API29 and formal shared-runtime admission remain outstanding. No terminal
palette is overwritten.

## Qualified preceding sources

These proofs apply to the exact older source and bytes shown here, before the
default-widget correction was propagated. They remain useful regression
evidence, not green results for the current heads.

| Project | Exact preceding source | Visual evidence | Candidate / retained evidence |
|---|---|---|---|
| Accelerometer | `7dfacda62e5b1a7b8c28925bff437602dab7e14a` | PASS API29 API34 LAUNCH ROOT INK | [Artifact](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695167/artifacts/13383110866) |
| dilapidated-shed/ChatGPTExporter | `51bace2e9b026f0f5219d49fdf5ccaac89cb2321` | PASS API29 API34 BOTH MODES LIFECYCLE VIDEO GUARD | [Artifact](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41947436588/artifacts/13380610037) |
| dilapidated-shed/tablature | `7255ad083a1c183c42f9766ca3548c256e090daa` | PASS API29 API34 BOTH MODES LIFECYCLE VIDEO GUARD | [Artifact](https://github.com/dilapidated-shed/tablature/actions/runs/41950607269/artifacts/13382136270) |
| Gyroscope | `7dfacda62e5b1a7b8c28925bff437602dab7e14a` | PASS API29 API34 LAUNCH ROOT INK | [Artifact](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695226/artifacts/13382842737) |
| isomorphismes/algebraic-variety-explorer-mobile | `669a94fd8e89ff467e371f5b21cf14327e4ee408` | API35 EXECUTED PALETTE SAMPLES PENDING | [Artifact](https://github.com/isomorphismes/algebraic-variety-explorer-mobile/actions/runs/41970098694/artifacts/13391340281) |
| isomorphismes/billiard | `baac0eb107dcaabec48f993789abb9e12e1056f0` | PASS HOST ROUGH PIXELS ANDROID PENDING | [Artifact](https://github.com/isomorphismes/billiard/actions/runs/41958097962/artifacts/13385701997) |
| isomorphismes/Conway | `8835d5400451c12f394a9e1b2d9a67d72f419bf8` | API34 PAN REPLACEMENT BOTH MODE SAMPLES PENDING | [Artifact](https://github.com/isomorphismes/Conway/actions/runs/41976915076/artifacts/13392563447) |
| isomorphismes/Fourier-sound | `d16beea60d7b3ece9853a8705edd641bbc7ec1b0` | ANDROID BOTH MODE PENDING | [Artifact](https://github.com/isomorphismes/Fourier-sound/actions/runs/41970938009/artifacts/13391745072) |
| isomorphismes/holomorphic | `463584e2e8dd6de9114701f49ca9d78baf8710a4` | PRECEDING 5025B41 PASS API29 API34 BOTH MODES | [Artifact](https://github.com/isomorphismes/holomorphic/actions/runs/41967292308/artifacts/13389803940) |
| isomorphismes/mathieu | `dc2171acebe20035f102db3a0b2b522d4fdd0a3b` | PASS HOST API29 API34 ACTUAL CONTROLS | [Artifact](https://github.com/isomorphismes/mathieu/actions/runs/41969966507/artifacts/13389514461) |
| isomorphismes/mostow | `de1bd5f51cb22179ac0c9876227b347b1c8e0650` | PASS REAL HOST GLES ANDROID PENDING | [Artifact](https://github.com/isomorphismes/mostow/actions/runs/41970908432/artifacts/13390457737) |
| isomorphismes/pauli | `18a7e62ce30252a3fbe0f2746b3ca00cb561a796` | API34 FRAME INSPECTED CHROME PAGES PENDING | [Artifact](https://github.com/isomorphismes/pauli/actions/runs/41960123808/artifacts/13387950058) |
| isomorphismes/seifert | `3352f024a709201594d16e1dbbe2ffcf3fe3099c` | PASS REAL HOST GLES ANDROID PENDING | [Artifact](https://github.com/isomorphismes/seifert/actions/runs/41970435239/artifacts/13389803751) |
| isomorphismes/spinor | `3b8a8f130f59c4b2e3c658769e7cd7766b074a64` | ANDROID UI PENDING SCIENTIFIC COLORS PRESERVED | [Artifact](https://github.com/isomorphismes/spinor/actions/runs/41968051439/artifacts/13390355625) |
| isomorphismes/wegert | `62bd3fcb0ba9f0ff935efe57dd6292203afa066d` | CHROME NIGHT API29 PENDING | [Artifact](https://github.com/isomorphismes/wegert/actions/runs/41950617535/artifacts/13381460123) |
| isomorphisms/ambient-light | `590e194d8781b06b3d75a9a3cdcfec012ad646ea` | PASS API29 API34 LAUNCH ROOT INK | [Artifact](https://github.com/isomorphisms/ambient-light/actions/runs/41951906524/artifacts/13382326987) |
| isomorphisms/Android-proximity-sensor | `1721c30c6c0ce82d2fa37a42344c0447a11a85dd` | PASS API29 API34 LAUNCH ROOT INK | [Artifact](https://github.com/isomorphisms/Android-proximity-sensor/actions/runs/41959502810/artifacts/13384706447) |
| isomorphisms/fastchat | `8fda332e45dc96c16b4aae9955f180d475800b9c` | PASS API29 API34 BOTH MODES LIFECYCLE VIDEO GUARD | [Artifact](https://github.com/isomorphisms/fastchat/actions/runs/41947171842/artifacts/13379696620) |
| isomorphisms/ib | `f2b16841e4be8d51a4b4a88cc4264fc6681bce13` | PASS API29 API34 BOTH MODES LIFECYCLE VIDEO GUARD | [Artifact](https://github.com/isomorphisms/ib/actions/runs/41947425729/artifacts/13380884545) |
| Magnetometer | `7dfacda62e5b1a7b8c28925bff437602dab7e14a` | PASS API29 API34 LAUNCH ROOT INK | [Artifact](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695226/artifacts/13383131848) |
| Pasteboard | `29d6a7a1dbad2dea7d577a710869757d8f8b9752` | PASS API29 API34 BOTH MODES LIFECYCLE VIDEO GUARD | [Artifact](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41978032646/artifacts/13393570513) |
| Spirit Level | `7dfacda62e5b1a7b8c28925bff437602dab7e14a` | PASS API29 API34 LAUNCH ROOT INK | [Artifact](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41951695175/artifacts/13384010251) |

The priority lifecycle observer `90e216fecfe9e958d0fc55c807cb778e81e75ff8`
passes [41980041161](https://github.com/isomorphisms/ai-ci/actions/runs/41980041161):
five exact priority APKs on API29 and API34, both system night modes,
replacement installation, cold start, rotation policy, Home/resume and
force-stop reopening. It retains 100 settled PNG stages and 20 actual videos:
[API29](https://github.com/isomorphisms/ai-ci/actions/runs/41980041161/artifacts/13393263783),
[API34](https://github.com/isomorphisms/ai-ci/actions/runs/41980041161/artifacts/13394050679).
Every decoded video frame passes the broad-white-canvas predicate; an encoded
single-white-frame negative fails. Small icons, partial dialogs, documents and
scientific fields are outside that whole-canvas claim. Exporter uses its
READ_SAVED native empty/error entry, and Pasteboard's portrait lock is preserved.

## Pasteboard lifecycle and reboot repair

The actual API29 Surface resume crash was repaired in product source29d6a7a:
retain one Java Surface per native-window lifetime, release it on window loss
and destruction, and clear lockCanvas exceptions even after a null return.
The exact repaired candidate passes the priority lifecycle replay on both APIs.

Its full regression workflow later exposed a reboot-observer race: an old
boot-complete property could be read before a new kernel had booted.
[Observer #345](https://github.com/isomorphisms/ai-ci/pull/345),
`3c17121c5622af712dbb32e53c4cdb9b76b64232`, requires a different valid boot UUID,
boot_complete1, bounded ADB operations and an emulator identity. Positive and
stale/incomplete/malformed controls pass on actual API29/34/35 in
[41984253543](https://github.com/isomorphisms/ai-ci/actions/runs/41984253543).
No app reinstall or history reset is used to hide the post-reboot failure.

Product source `eaa8393578ac978dfc45e24a37407f840577f37a` adopts that separate
observer while retaining its compiler pin. **All build, migration and retained
history workflow jobs pass on API29, API34 and API35** in
[41984355192](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41984355192):
[API29](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41984355192/artifacts/13396266194),
[API34](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41984355192/artifacts/13395214849),
[API35](https://github.com/Ashtray-Archer/utilities-android-phone-user/actions/runs/41984355192/artifacts/13395544591).
The newer E8 theme source df2df8f1 passes the complete producer41990472251
and the current priority replay41996501618 on both APIs and both system modes.

## Holomorphic strict and visual acceptance

Preceding product source `463584e2e8dd6de9114701f49ca9d78baf8710a4`
passes [41977273427](https://github.com/isomorphismes/holomorphic/actions/runs/41977273427):
actual generated-fragment provenance, three ICK compilers, signed APK, and
API34 GPU execution with all34 mathematical observations, all34 same-program
RGBA8 observations and separate large-q evidence. The raw large-q range remains
RANGE_REJECTED_UNQUALIFIED. Its [signed APK](https://github.com/isomorphismes/holomorphic/actions/runs/41977273427/artifacts/13394618740)
has SHA256 `9818cfe24da9038a3aab961a31c8af23b0954d7077752f8aa1be04a1e9f2f308`.

The independent visual observer `ad111f3dde1e4336d8cbc724a9190fcf493a7cb2`
passes the same exact APK on both APIs and both system modes in
[41985101859](https://github.com/isomorphisms/ai-ci/actions/runs/41985101859):
[API29](https://github.com/isomorphisms/ai-ci/actions/runs/41985101859/artifacts/13396085819),
[API34](https://github.com/isomorphisms/ai-ci/actions/runs/41985101859/artifacts/13394734850).
Selected/inactive controls, light marks, actual process and shader provenance
are observed; per-role white mutants fail. The scientific field is preserved.

Current product83acc7a7 also promotes independent owner
`336214f6ac0e9f4acfb332fa8d60130ca8f5b885`
([#344](https://github.com/isomorphisms/ai-ci/pull/344)).
Only exact GPU_TIMER and GPU_QUERY_WINDOW metadata are classified separately.
Missing measurements and unknown observations still fail. Dedicated
[41983868021](https://github.com/isomorphisms/ai-ci/actions/runs/41983868021)
and replay of the retained complete product log pass. The current E8 product83acc7a7 passes strict producer41990493268, including
actual API34 GPU acceptance. Its APK is artifact13400870523, SHA256
`caa072a271b096bf340ca9dacd34e133020cf02ae316592b2c15f2c1fca8b976`.
The independent visual observer now binds those exact bytes at
`f14ad339b7ea55de8c87a2f7088875223699c726`; its fresh run is pending.
A separate older native-explorer smoke lane captures logs before its first-frame
marker and remains failed; a bounded presented-frame observer repair is pending.

## Remaining acceptance and delivery boundaries

All physical MIRO C67, Android14 ARM64 checks are **NOT_RUN**. Current emulator
evidence never substitutes for physical performance, GPU, IME or cross-build
upgrade acceptance. Some partial-dialog, loading/error/offline and retained
selection/scroll-state cases still lack palette-specific observation.

SURFER, Hopf, Ortho, L, Coefficient Root Dance and Theta do not have preserved
signing keys available to this job. Their runner-local debug fixtures are not
approved C67 upgrades. Sprott's expected-signer inputs are likewise unavailable.
Mock Theta and Witt currently have maintained ARMv7-only builders; no ARM64
artifact is inferred from them. Young Tableaux's explicit C++-free permitted
Grease admission gate remains closed. Its typed JDT test additionally references
expired Cat Food compiler artifact11684276190/run38090627721; the independent
mathematical audit and observable JDT check pass, but that does not qualify
the blocked typed test or APK. F-Droid buildserver container retrieval is a
separate known blocker for Wegert and SURFER.

Wardriving and Cat Food are CLI programs in the inspected sources; graphical
test interfaces belong to the application/example owners. Further terminal
palette and UI-bearing branch classification remains open. The hardware
Programmer's Keyboard source is not the software Unicode picker/IME: those
utility screens now have their own implementation in PR93 and actual API29
functional passes, with remaining palette/state coverage recorded separately.

The default-tree UI-marker census is not exhausted by the implemented list.
Further source/branch review, supported UI integration and unavailable-tree
follow-up remain open in [project-status.tsv](project-status.tsv).
Headless libraries are not cosmetically changed. External authentication,
websites, user documents, photographs and mathematical color mappings are not
inverted. The previous checkpoint and its detailed historical receipts remain
in [source00c21cad](https://github.com/isomorphisms/ai-ci/blob/00c21cadca31b0d18412b7d7866bc0cd432ffb16/charcoal/acceptance-ledger.md).
