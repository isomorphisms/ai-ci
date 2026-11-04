# Native Material presentation integration

Campaign: SUN-M3-NATIVE-WORKBENCH-COMPLETE-01. Overall status: PARTIAL.
This ledger separates implementation, build, ART execution and physical use.
No merge or production release is authorized or performed by this campaign.

## Ownership and exact sources

| Workstream | Default source inspected | Chosen integration source | Decision and evidence | Status |
| --- | --- | --- | --- | --- |
| FastChat | `442e8135c018ee003021f1c3f681686c80be9fd0` | `bdae9a45abca9d7a75aaeb2e6b93e971a06f3760` | REPAIR existing native controller/store/transport and framework surface; add bounded preceding-turn projection, Activity-owned accessible content and secure settings. Keep existing `HistoryTurn`, request/attempt identities and response arena. | PARTIAL |
| IB | `0f3d8dcdc20239987ce30da3d27788a90d2c090a` | `a30381aee243d56d83da19befe64e2f84ebccfc9`, stacked on reader `9f468f9b6dfba8f3895f4ab5cd7a316dc08c562e` | REUSE checked reader and its source owner; REPAIR styling to preserve qualified reflow labels; ADAPT existing BrowserHistory occurrences through revision-checked selection. | PARTIAL |
| Shared Android primitives | `6ab4818219efa7ea5eda137ca6b76976eb2a4d42` | `1f9c30aeb7cc719075ed470b6135c4cc8ce194ca` | REUSE small `native/presentation/material.h` and checked `Action.dex`; application semantics stay in consumers. Base is checked-export-aliases `153e7fc8053ba4072954a5e77d4efa3609d829e4`. | PARTIAL |
| Idriç | master `0fb1192cd30ec4747cbc727f26ddbfad515d1363` | Existing consumer pins: IB `740bbf2b1d9e811fd00c719c3473eede17ceea3b`; FastChat `ff4d852862a3942592f8ade9afde8d409d9803be` | REUSE existing typed semantic interfaces. No speculative compiler change or new universal serialization. Current master is inventory, not a silently substituted consumer pin. | PARTIAL |
| ChatGPTExporter | `1285e1e89537e92d6df7317b882e192fc942dc6c` | `6c84de4b8c4fe298c2bb61386b7158833249aca4` | REUSE verified read-only native C1 adapter and cached selected-parent path; retain browser/offline V2 verifier separately. | PARTIAL |
| ai-ci | `a66e3a9bb1070a338f8c4a67f9b4b4ac39dfb5ec` | FastChat qualification `a4037d59ed203ff8b36db20416f094d3d0e9308d`; IB requalification implementation `ba24eb20ababbcf6933973ef67d248f1f0f51e59`; consumer host oracle `0293230005b70bde26108e8ae5803512b52072cd`, UI/settings oracle `80d1fcd43305df0537e05c69c2bb5a90657185dd`; original IB reader observer `39ba6eb1218c7883fa1f1c98b07bf0dceabbf6d5` and presentation observer `b30c3896c76ffe2c391647da65465c655539997b` | ADAPT independent actual-producer observers, source/order/revision mutants and actual signed UI-defect controls. New observer code never changes the tested product APK. Consumer pins remain immutable. | PARTIAL |
| Cat Food | `eafd7fa9e61138a664b205bf8ba82ec6837bbbb9` | TAB_P10 discovery `0e73eada1193b9b7de55defacfdf425b35101de7` | REUSE target discovery. Historical C67 ARM64/API34 profile is distinct from a fresh device observation. No authenticated current device channel or local adb is available. | BLOCKED |
| Android precedents/reference | main `34b2391a97867ab25ea885cedc7ac2e04b591609` | Material API reference `689bda5bf777a39d35e5aa14bbbb921d8af555b1` | REUSE reference only: 43 signature files at AndroidX `cdeafe5b4e450d61cdb623d58c148efbb0d508cf`. Inspection complete; no Compose product dependency. | NOT_RUN (new consumer integration) |
| climenu, canonical owner `dilapidated-shed/climenu` | `b39dbb2bd44d0f87d3321f01c995edb80358b21b` | unchanged | DEFER Android adoption: current implementation is a pure Idriç command-description to HTML projection; executable/stdin bridge is still unqualified. Preserve command semantics; no chat replacement. | NOT_RUN (Android integration) |
| az, canonical owner `Ashtray-Archer/az` | `249c02b5669c1f6c9682fa5848b1b946e147a7ce` | unchanged | DEFER importing its Java/javac/d8 Android frontend into the no-Java product lane. Its Termux command/TSV contract remains owned by az. A shared native frontend must preserve that contract and canonical signer. | NOT_RUN (native migration) |

Both repository transfers were resolved from live repository metadata rather
than creating replacements under the former `isomorphisms` owner.

## Reconciled predecessors and dependency direction

| Existing work | Exact inspected head | Decision |
| --- | --- | --- |
| [isomorphisms/fastchat PR #7, “Add Compose Material 3 disk-first comparison baseline”](https://github.com/isomorphisms/fastchat/pull/7) | `c5fc80ea3350186b4af4960de1fb236acdc6b854` | DEFER comparison execution; preserve the independent Compose reference. Reject Compose/Kotlin/Gradle as a production dependency. Its managed journal/projection costs differ; no matched performance ranking is valid. |
| [isomorphisms/fastchat PR #17, “Native FastChat: composer, provider setup, durable drafts and paired APKs”](https://github.com/isomorphisms/fastchat/pull/17) | `7a4b57acf4df8809f6884a6adcaedc4fad03c141` | REUSE as the exact native application base; do not replay earlier screenshot/candidate revisions over its durable draft/provider work. |
| [isomorphisms/ib PR #167, “Integrate and qualify the checked native IB reader; retain tablet and Google blockers”](https://github.com/isomorphisms/ib/pull/167) | `9f468f9b6dfba8f3895f4ab5cd7a316dc08c562e` | REUSE integrated reader, checked reflow, original bytes, history, source arena and ICU path. Native history is a projection, not a substitute browser store. |
| [isomorphisms/ib PR #134, “Move Long View lifecycle dispatch into Idriç and exercise its direct-DEX path”](https://github.com/isomorphisms/ib/pull/134) | `41d4cae9c15e42d3b0b4ed4ed957ba86a7ac396a` | ADAPT only after the durable native task host is connected. Diagnostic lifecycle execution is not recoverable live-page acceptance. |
| [dilapidated-shed/ChatGPTExporter PR #16, “Integrate native Android capture and independently verifiable offline imports”](https://github.com/dilapidated-shed/ChatGPTExporter/pull/16) | `d19dba2bd0a10fc8b59a94931caf26cc128b9335` | REUSE native C1 capture/archive validation for the bounded read-only adapter; preserve the distinct browser/offline V2 validator. |

The dependency direction is applications → generic android-NDK presentation
primitives, and ai-ci → exact application source/artifacts. android-NDK never
depends on FastChat, IB or archive semantics. The generic module owns role
colors, sizes, shapes, text/control styling and checked framework callbacks.
FastChat owns conversation/controller/transport/storage; IB owns source visits,
reader navigation and task decisions; Exporter owns archive verification.
There is no shared database, new serialization envelope or forced process split.

Focused handoff branches remain unmerged:

- [isomorphisms/fastchat PR #22, “Present durable turns with native Material message and paging controls”](https://github.com/isomorphisms/fastchat/pull/22), `work/m3-native-presentation`, based on `sun/fc-ui-01` at `7a4b57acf4df8809f6884a6adcaedc4fad03c141`.
- [isomorphisms/ib PR #169, “Present retained source history through native Material controls beside the reader”](https://github.com/isomorphisms/ib/pull/169), `work/m3-native-workbench`, based on `work/tabp10-reader-complete` at `9f468f9b6dfba8f3895f4ab5cd7a316dc08c562e`.
- [isomorphisms/android-NDK PR #42, “Share native Material role controls and a typed framework View callback”](https://github.com/isomorphisms/android-NDK/pull/42), `work/m3-native-controls`, based on checked-export-aliases `153e7fc8053ba4072954a5e77d4efa3609d829e4`.
- [isomorphisms/ai-ci PR #336, “Add independent native presentation and archive acceptance”](https://github.com/isomorphisms/ai-ci/pull/336), `acceptance/m3-native-workbench`, based on `acceptance/ib-chordreader-handoff` at `76375652724a6921f8374738cea9360366526242`.
- [dilapidated-shed/ChatGPTExporter PR #17, “Expose verified native archive messages through a bounded read-only presentation adapter”](https://github.com/dilapidated-shed/ChatGPTExporter/pull/17), `work/native-readonly-presentation`, based on `sun/chatgpt-export-complete-01` at `d19dba2bd0a10fc8b59a94931caf26cc128b9335`.
- [isomorphisms/ib PR #135, “Project source-linked retained items and prepare Pensieve actions”](https://github.com/isomorphisms/ib/pull/135), source `39cc7257f9434f24f1aba390d40bd16c05b1f212`, remains the S08 Home projection.
- [isomorphisms/ib PR #134, “Move Long View lifecycle dispatch into Idriç and exercise its direct-DEX path”](https://github.com/isomorphisms/ib/pull/134), source `41d4cae9c15e42d3b0b4ed4ed957ba86a7ac396a`, remains the lifecycle diagnostic.
- [isomorphisms/catfood PR #156, “Discover TAB_P10 hardware and storage without assuming phone state”](https://github.com/isomorphisms/catfood/pull/156), source `0e73eada1193b9b7de55defacfdf425b35101de7`, remains the tablet discovery workstream.

## Implemented continuation

FastChat's native timeline now presents at most three preceding real durable
turns and the focused full-response page. Earlier prompts are selectable;
assistant previews retain exact UTF-8 prefixes and an explicit full-turn action.
The existing Older/Newer/Latest and response paging controls remain real
framework Buttons. Nine context Views are allocated once and reused.

Historical journal scans run in a pthread worker against an immutable published
prefix copied from the existing controller. The worker uses existing positional
reads, borrows descriptors until joined shutdown, and has no Android, transport,
credential or append authority. Superseded reads cannot publish. Focus changes
retire their old Button identities before another projection arrives. Idle
ticks reuse the visible response bytes; streaming beyond a full unchanged page
preserves the response View, layout and selection.

The independent worker observer creates five actual committed turns. It checks
ordered request/attempt identities, combining marks, RTL, supplementary scalars,
a UTF-8 sequence crossing the 1024-byte preview bound, older/empty/invalid focus,
broken-source refusal and retired/superseded publication. Actual producer
mutations reverse the source order and bypass the revision guard; each must
exit 1 with its intended diagnostic. A compiler failure or crash cannot pass.

The installed observer additionally submits a second real durable turn,
inspects the preceding user/assistant projections, selects the actual prior
request through its Button and returns to Latest. Existing paging, cancellation,
multiline Unicode and exact clipboard checks remain required.

Independent API34 failure-time hierarchy capture proved an additional native
window defect: the old application-panel controls were absent from the active
Activity accessibility root, despite continuing generation. REPLACE that
attachment mechanism with the Activity's `android.R.id.content` container.
The Canvas comparison keeps its existing lane. Provider settings use the same
content ownership, with `FLAG_SECURE` applied to the actual Activity window
before attachment. It remains secure until that Activity is destroyed, including
after Back, to avoid exposing stale credential surfaces. Settings inspection
never saves configuration or submits a provider request.

Shared contract coverage is bounded: `Action.dex` supplies the checked
`View.OnClickListener` callback, IB's Idriç adapter supplies exact history
revision/occurrence selection, FastChat retains its existing turn/attempt/event
and composer contracts, and Exporter supplies verified read-only message/part
access. A universal ordered-content/action/attachment interface has not been
completed. The theme supports light/dark and API31 system color lookup; complete
contrast, font scaling and accessibility qualification remain open.

IB's continuation preserves the established visible reflow selector contract
while applying shared role colors, shapes and hit regions. The independent
reader observer is unchanged. This repairs the observed regression
`expected=REFLOW: GREEDY observed=Reflow: Greedy`; it does not waive any reader
or viewport assertion.

## Pensieve, Longview and archive boundaries

Pensieve is IB-owned. The current S08 reducer/decision owner is
`IB.HumanDecisions`; the unmerged `IB.PensieveHome` projection is at
`39cc7257f9434f24f1aba390d40bd16c05b1f212`. It retains source/revision/activity
identity and prepares commands without asserting successful persistence.
It is not a separate repository. The current Android reader history is not
that reducer or a completed task/request/evidence workbench. There is no
qualified bridge from that S08 projection/executor to this APK's retained
source arena; no replacement decision store has been invented.

Longview's semantic owner is `IB.LongViewTask`. The checked direct-DEX lifecycle
diagnostic at `41d4cae9c15e42d3b0b4ed4ed957ba86a7ac396a` is separately qualified;
it is not a full native durable-task host in this reader APK. Historical
origin-only recovery is explicitly diagnosed at
`adce7e8f0c7c3e5a18621c6c918f94a2dc5c5d08`. Durable source reopening never
establishes restored cookies, forms, heap or live authenticated page state.

The exporter adapter verifies the existing native C1 disk archive before
exposing any content. It preserves all branch messages, exact roles, ordered
parts, unsupported raw spans, assets and source/inventory digests. Its selected
path derives from actual parent links, not mapping iteration order. It has no
provider send operation. The native C1 and browser/offline V2 envelopes remain
distinct supported interfaces. No user archive was supplied; retained test
archives are synthetic. A cross-app Android archive handoff/viewer is still
unimplemented, and the existing Android shell's success does not qualify one.

## Qualification and independent refusals

Source review, host execution, packaging, ART and physical observations remain
separate. API35 is NOT_RUN; the maintained product matrix uses APIs29/34.

| Source-bound check | Receipt | Result and limit |
| --- | --- | --- |
| FastChat `bdae9a45abca9d7a75aaeb2e6b93e971a06f3760`, producer | [41754800398](https://github.com/isomorphisms/fastchat/actions/runs/41754800398) | PASS reproducible ARM32/ARM64/x86_64 APKs, signing and API29/34 actual controls/paging/Stop/multiline Unicode/exact copy/two durable turns/prior-turn selection/secure settings. IME and physical use NOT_RUN. |
| Same FastChat source, actual ICK core/worker | [41754800418](https://github.com/isomorphisms/fastchat/actions/runs/41754800418) | PASS store/retry/replay, independent pthread worker and real reversed-order/stale-publication mutations. |
| Same FastChat source, typed semantics and HTTP2 | [Idriç41754800578](https://github.com/isomorphisms/fastchat/actions/runs/41754800578), [HTTP241754800596](https://github.com/isomorphisms/fastchat/actions/runs/41754800596) | PASS; HTTP2 uses credential-free qualification, not a claim of a live paid provider conversation. |
| ai-ci `a4037d59ed203ff8b36db20416f094d3d0e9308d`, independently downloaded exact signed FastChat | [41756196770](https://github.com/isomorphisms/ai-ci/actions/runs/41756196770) | PASS all five jobs: API29/34 current APK, independently compiled worker/mutations, actual signed old Activity-ownership producer refusal, actual signed missing-secure-window producer refusal. |
| IB `a30381aee243d56d83da19befe64e2f84ebccfc9`, source/build | [41748455979](https://github.com/isomorphisms/ib/actions/runs/41748455979) | PASS checked DEX emission/independent decoding, three ABI compilation, stable signing and byte-identical APK reconstruction. Overall runtime jobs FAIL; see the narrower results below. |
| Same IB source, original API29 ART | [artifact13287828092](https://github.com/isomorphisms/ib/actions/runs/41748455979/artifacts/13287828092) | Source/reflow/anchors/large-source/parcelable/installed reader/navigation/fragment/Activity ownership coordinators PASS. Presentation mutation lacks its diagnostic; root-transition snapshot FAIL; following History UI BLOCKED by offline emulator. |
| Same IB source, original API34 ART | [artifact13288642249](https://github.com/isomorphisms/ib/actions/runs/41748455979/artifacts/13288642249) | Actual History/Reader View/text/selection/scroll preservation and retained-source selection PASS. Presentation mutation diagnostic FAIL; entire job is not PASS. |
| ai-ci `ba24eb20ababbcf6933973ef67d248f1f0f51e59`, unchanged IB APK requalification | [41756980836](https://github.com/isomorphisms/ai-ci/actions/runs/41756980836) | PENDING at this checkpoint. Downloads original source-bound archive; rebuilds only external probe; preserves producer APK/DEX identities. |
| Exporter `6c84de4b8c4fe298c2bb61386b7158833249aca4` | [41703456445](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41703456445) | PASS independent read-only archive/selected path/roles and actual compiled role/reversed-path/version mutants. Actual disk fixtures are synthetic; no user archive or native viewer is qualified. |
| Same Exporter source, Android shell | [41703456385](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41703456385) | PASS capture-shell boundary; not archive-viewer acceptance. |
| android-NDK `1f9c30aeb7cc719075ed470b6135c4cc8ce194ca` | [41690275331](https://github.com/isomorphisms/android-NDK/actions/runs/41690275331) | PASS canonical checked DEX/JNI; consumer ART evidence remains separate. |

The first worker test launcher failed because renaming the verified Grease
implementation binary broke its applet dispatch. The corrected invocation uses
the same verified implementation path; source scripts remain Grease. A later
oracle incorrectly assumed attempts restarted at1 for each request. Actual
conversation-wide identity disproved that assumption in run41750520306. The
corrected independent fixture includes explicit retry and requires attempts3/4/5
for requests2/3/4. Producer semantics were preserved.

IB's negative ART workbench control raised an uncaught AssertionError that
`app_process` exposed only as `Killed`. This did not satisfy its required
diagnostic and was never called a passing refusal. The independent probe now
prints the exact semantic refusal and deliberately exits42; both the source
revision and callback controls require status42 and their intended diagnostic.
A crash or loader failure cannot pass. The original good/mutant producer DEX
remains unchanged. The API29 root-transition repair admits only the observed
status1 `adb: unable to connect for root: closed`, then still requires connection
within30 seconds and verified root UID before reading source bytes. Other errors
fail. This is emulator observer plumbing, not device root authorization.

Independent FastChat evidence was downloaded and ZIP-hashed again:

| Actual artifact | SHA-256 of retained ZIP | Outcome |
| --- | --- | --- |
| [Current API29,13287868838](https://github.com/isomorphisms/ai-ci/actions/runs/41756196770/artifacts/13287868838) | `f025a832a153d9deea1ffdfe0580be8f79885139dbf05a16d88ce0ece5d80b6d` | PASS |
| [Current API34,13287833390](https://github.com/isomorphisms/ai-ci/actions/runs/41756196770/artifacts/13287833390) | `4a6ea5d87ee85efd8a83206b098781f979d30b6090a0c6f1aa4357092046a05d` | PASS |
| [Old content-owner control,13288442786](https://github.com/isomorphisms/ai-ci/actions/runs/41756196770/artifacts/13288442786) | `009648dd6b9d3a94f73410dfc030061428f6ba79dc2f606b5d6340451a96326f` | Actual signed `0c5288a207595a0d6924875731091092595fa711` rejected for Activity hierarchy ownership |
| [Old settings control,13287673435](https://github.com/isomorphisms/ai-ci/actions/runs/41756196770/artifacts/13287673435) | `2b7e714a5e54a6bf8eac28b741d370fb119bb71d9a784b9e21027a23c85ab1bd` | Actual signed `aaabc570c4416fd3e39fc72154ba176fe750853f` rejected for unprotected settings window |
| [Independent worker,13288911762](https://github.com/isomorphisms/ai-ci/actions/runs/41756196770/artifacts/13288911762) | `959f8d8b5d38c6a8a1821d1403a47eb95d8129c3f7e2e8f8e7bf960589407d4a` | PASS actual source and intended mutation refusals |

The original IB API29 diagnostics ZIP is
`9e2d0144bacd1f3a54d51f6f916406803fe9a1750a460960135e96fa78e0f331`;
API34 is `bd9a19fd687f6b0915a9800a500da1e693a1d62c34abfd44ff6cc8af69f964db`.
Expected failing producer controls inside those jobs are distinct from a failed
required coordinator. `required.tsv` records each actual coordinator exit.

## Signed Android candidates

| Candidate | Exact source | Package / ABI / bytes | APK SHA-256 |
| --- | --- | --- | --- |
| [FastChat C67 artifact13288111471](https://github.com/isomorphisms/fastchat/actions/runs/41754800398/artifacts/13288111471) | `bdae9a45abca9d7a75aaeb2e6b93e971a06f3760` | `org.isomorphisms.fastchat.diskstreaming.arena`, version7 / `0.7-native-material-candidate`, min26/target34; ARM64; 2,319,187 bytes | `df713beb48277b54ffc6e1c20eef6da6b502f0deeaeb9122af435df9a9815bfa` |
| [IB reader/history artifact13286138443](https://github.com/isomorphisms/ib/actions/runs/41748455979/artifacts/13286138443) | `a30381aee243d56d83da19befe64e2f84ebccfc9` | `org.isomorphisms.ib.prepaint`, version3 / `0.3.0`; universal ARM32/ARM64/x86_64; 10,372,647 bytes | `1dec51d8711f17e941aa5ccf0cf0adb05819b68e7fcec78ae120c346bddd94b0` |

FastChat uses established public development certificate SHA-256
`aa9151e3922fa4795987c3655bc7aa4712620f1d94c24a2075acd7b29d8ac86e`;
IB uses established test certificate
`de9b1d47c5a65e6d46a204b79dd9ee566b9d3c9832ba81ebc4213d3392e92ff9`.
These are signed development candidates, not store/production releases.
Source jobs verify manifests, signatures and reproducibility. Independent ART
jobs inspect the actual installed APK identity and signer separately.

| Other build artifact | ZIP SHA-256 |
| --- | --- |
| FastChat C67 ZIP13288111471 | `d2f35e157ed78281f25351e817ac228152564b8b3c27f0f9c79b6f3380ef47c5` |
| [FastChat A1 ARM32,13287911447](https://github.com/isomorphisms/fastchat/actions/runs/41754800398/artifacts/13287911447) | `60702f538a8f085850bbeafe52b9001ffb7487a04100a29f548aca07a18b0607` |
| [FastChat x86_64,13288600748](https://github.com/isomorphisms/fastchat/actions/runs/41754800398/artifacts/13288600748) | `6d6e1add5115c067211e390d96a3f0e611d6b361b0c50b73f22e4a522c7190f9` |
| IB signed candidate ZIP13286138443 | `672a4ec631621232a5998b5a43d8039399c8877b652d917ab281c497ff8b7f53` |

Downloaded FastChat receipt/schema/material/APK/DEX checks passed the maintained
strict v3 verifier. `readelf` on the actual extracted C67 library confirms
ELF64/AArch64 with only libandroid, liblog, libc, libm and libdl dependencies.
The exact source is embedded in that library. The checked572-byte callback DEX
SHA-256 is `24e37795b5c8001a280b9f5f46c64ed510660358fb42f2a7109b52e2a5c067ad`.
Local receipt/ELF inspection is not a second cryptographic signature check or
a physical install.

Installation handoff: discover each device afresh; verify ABI, installed package,
version/signer and free space before using the matching prebuilt APK. C67 uses
the ARM64 FastChat candidate, A1 uses the separate ARM32 candidate when available.
The IB APK is universal, but its tablet acceptance still requires fresh tablet
facts. Use replacement installation and preserve existing data. If Android
refuses signer/version compatibility, stop and report the mismatch; do not
uninstall or clear storage. No compiler/build bundle belongs on either device.

## Performance evidence

These are single-run x86_64 emulator observations of FastChat
`bdae9a45abca9d7a75aaeb2e6b93e971a06f3760`, observer
`80d1fcd43305df0537e05c69c2bb5a90657185dd`. They include instrumentation
overhead. Actual measurement receipts:
[API29 artifact13288151032](https://github.com/isomorphisms/fastchat/actions/runs/41754800398/artifacts/13288151032),
ZIP `1c97bc7a2313807159e6c4729217fcab910012c7c28c8cfb9977429b95ccd119`;
[API34 artifact13288301418](https://github.com/isomorphisms/fastchat/actions/runs/41754800398/artifacts/13288301418),
ZIP `aba96e33c4d8c1a10ffc431948074c140a0f844b971d1ead473483b08541c374`.
Both ZIPs were downloaded and hashed again.

| Metric | API29 | API34 | Scope |
| --- | --- | --- | --- |
| Cold Activity launch TotalTime | 188ms | 971ms | Android `am start -W`; not time to physical input |
| Observer launch to discoverable composer | 123ms | 311ms | Instrumented launch, not cold/warm matched samples |
| Peak process RSS, VmHWM | 173720kB | 126888kB | Runtime/mappings/observer included |
| Process RSS at observation | 138212kB | 124468kB | Instrumented process |
| Android PSS at observation | 31969KiB | 17750KiB | Different metric from RSS |
| Cumulative process CPU | 251ms | 150ms | Not a percentage, streaming cost or thermal measurement |
| Second am start | Existing Activity, WaitTime1ms | Existing Activity, WaitTime2ms | Not a warm startup sample; TotalTime0 is not zero launch cost |

Post-instrumentation `dumpsys meminfo` says “No process found”; this is unavailable
data, not zero memory. No matched native/Compose/Canvas hardware experiment ran.
UI-thread stalls, incremental rendering cost, interaction latency distributions,
physical startup/RSS/CPU/thermal and warm startup are NOT_RUN. Do not attribute
differences across emulator runs to the renderer repair. The Compose reference
APK size1,042,096 bytes at its different semantic/storage source is historical
build evidence only; it cannot establish a relative efficiency claim.

## Release blockers and per-workstream handoff

The PR links above give each implementation branch and exact base. None was
merged, closed, retargeted over an unresolved base, or promoted as a release.
Current implementation heads are in the source ledger. Consumer pins differ
intentionally from later independent observer commits.

| Workstream | Integration status | Remaining dependency / next concrete action |
| --- | --- | --- |
| FastChat | PARTIAL | Qualified native durable conversation exists. Complete Markdown/links, Share, attachments, search/wide layouts and remaining controller/store/transport I/O off the UI ALooper; qualify physical issue21. |
| IB reader | PARTIAL | Preserve passing reader/source/selection gates. Finish unchanged-artifact requalification with exact diagnostic probes; separately diagnose inherited live progressive-prepaint failure. |
| IB workbench | PARTIAL | Qualified API34 retained-source history exists. Integrate actual task/request/evidence/action state through existing IB owners; history visits alone are not the requested workbench. |
| Pensieve, IB-owned | BLOCKED | Existing S08 Home projection/executor has no qualified bridge into the native retained-source arena. Connect source/revision/decision identity and actual persistence outcomes; do not invent another decision store. |
| Longview, IB-owned | PARTIAL | Lifecycle diagnostic exists. Connect durable native task host and restored inputs before claiming recoverable integrated sessions; live cookies/forms/heap are separate. |
| ChatGPTExporter | PARTIAL | Verified C1 read-only adapter exists with independent mutations. Android archive handoff/viewer remains unimplemented. No actual user export was found in the available title search; supplied test archives are synthetic. Sending must stay unavailable in imported views. |
| android-NDK | PARTIAL | Shared controls/callback are consumed by two apps. Resolve checked-export-aliases base topology, then finish role/component accessibility/theme/font-scale qualification. |
| Idriç | PARTIAL | Existing consumer pins execute; no new language/backend change proposed. Any required extension needs a reduced real failing consumer before implementation. |
| ai-ci | PARTIAL | FastChat independent qualification complete for implemented scope; IB requalification active. Add remaining IME/recreation/theme/long-thread/stall assertions with meaningful negative controls. |
| Cat Food / physical targets | BLOCKED | No current authenticated device channel. Discover C67 and TAB_P10 independently, inspect installed identity/capacity, then replacement-install exact signed candidates and exercise human input. |
| utilities Android precedents / API reference | NOT_RUN for new integration | Reference inspection is complete; no product changes or matched physical comparator run. Preserve pinned AndroidX reference. |
| climenu | NOT_RUN for Android | Qualify current command/stdin bridge before mapping its Idriç command descriptions to native controls. Canonical owner is dilapidated-shed. |
| az | NOT_RUN for native migration | Existing first-party Java Android frontend cannot enter this product lane. Preserve canonical command/TSV/permissions/signer while implementing a checked native frontend. Canonical owner is Ashtray-Archer. |

The inherited live arXiv progressive-prepaint assertion fails in IB
[browser-foundation41748456059](https://github.com/isomorphisms/ib/actions/runs/41748456059).
Preceding actual HTML/image acquisition for four papers passed. Its silent
assertion remains unresolved; this is not evidence of network unavailability
and was not waived. Full semantic UI requirements also remain incomplete:
virtualized history, Markdown blocks/links, attachment actions, search, tablet
layout, live IME/focus/back/recreation and font/contrast/accessibility coverage.
A bounded historical worker does not establish a fully nonblocking frontend.

## Physical acceptance

| Required physical exercise | MIRO C67 Android14 | SVITOO TAB_P10 | MIRO A1, functioning device conditional |
| --- | --- | --- | --- |
| Fresh identity/ABI, installed signer/version, capacity | BLOCKED | BLOCKED | NOT_RUN |
| Replacement install and launch | BLOCKED | BLOCKED | NOT_RUN |
| Long real thread, human paging/scrolling | BLOCKED | BLOCKED | NOT_RUN |
| Multiline entry, actual IME/focus and Copy | BLOCKED | BLOCKED | NOT_RUN |
| App switching, rotation/recreation and retained reopen | BLOCKED | BLOCKED | NOT_RUN |
| IB reader separately | BLOCKED | BLOCKED | NOT_RUN |
| IB workbench separately, then actual source navigation | BLOCKED | BLOCKED | NOT_RUN |

Historical C67 ARM64/API34 facts are not fresh physical discovery. TAB_P10 facts
must come from that tablet. A1 acceptance cannot come from C67, ARM32 compilation
or an emulator. No physical PASS, production release or full campaign completion
is claimed. The deliverables are independently usable integration branches,
signed candidates and the source-bound qualification receipts listed here.

