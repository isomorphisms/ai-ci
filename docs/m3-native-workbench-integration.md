# Native Material presentation integration

Campaign: SUN-M3-NATIVE-WORKBENCH-COMPLETE-01. Overall status: PARTIAL.
This ledger separates implementation, build, ART execution and physical use.
No merge or production release is authorized or performed by this campaign.
Shared native controls function in FastChat, IB's reader/history panes and
the exporter's C1 archive view. Full task/evidence history, Pensieve/Longview
native execution bridges, the remaining rich-content controls and physical
acceptance remain unfinished.

## Ownership and exact sources

| Workstream | Default source inspected | Chosen integration source | Decision and evidence | Status |
| --- | --- | --- | --- | --- |
| FastChat | `442e8135c018ee003021f1c3f681686c80be9fd0` | `759605c434fc94b6ea3ce604710f8340a36918a8` | REPAIR existing native controller/store/transport and framework surface; add bounded preceding-turn projection, Activity-owned accessible content and secure settings. Keep existing `HistoryTurn`, request/attempt identities and response arena. | PARTIAL |
| IB | `0f3d8dcdc20239987ce30da3d27788a90d2c090a` | `994dbe273d5d198525a34e55feb9fd007827e4a4`, stacked on reader `9f468f9b6dfba8f3895f4ab5cd7a316dc08c562e` | REUSE checked reader and its source owner; REPAIR styling to preserve qualified reflow labels; ADAPT existing BrowserHistory occurrences through revision-checked selection. | PARTIAL |
| Shared Android primitives | `6ab4818219efa7ea5eda137ca6b76976eb2a4d42` | `b2ee19121aa3fa1112cd8338b7b6a7baca237b5f` | REUSE small `native/presentation/material.h` and checked `Action.dex`; application semantics stay in consumers. Base is checked-export-aliases `153e7fc8053ba4072954a5e77d4efa3609d829e4`. | PARTIAL |
| Idriç | master `0fb1192cd30ec4747cbc727f26ddbfad515d1363` | Existing consumer pins: IB `740bbf2b1d9e811fd00c719c3473eede17ceea3b`; FastChat/Exporter `ff4d852862a3942592f8ade9afde8d409d9803be` | REUSE existing typed semantic interfaces. No speculative compiler change or new universal serialization. Current master is inventory, not a silently substituted consumer pin. | PARTIAL |
| ChatGPTExporter | `1285e1e89537e92d6df7317b882e192fc942dc6c` | `41132f68f2b74cb4f2a4f5c7fdbba8a2c96543d2` | ADAPT verified C1 snapshots to shared native controls, read-only entry and bounded worker-owned Unicode pages; REUSE archive verification/storage and retain browser/offline V2 verifier separately. Actual native source/runtime qualification is scoped below. | PARTIAL |
| ai-ci | `a66e3a9bb1070a338f8c4a67f9b4b4ac39dfb5ec` | Archive input qualification `fc5e5fca71b9d8d5831619b7a9a0130e449a93a6`; qualified archive/reader observer `6cfacc591b5e6b187547b4409e976772f319c28b`; IB signed-input pin `4c6da077072308fa2a649e40bc84129e78429e8d`; qualified IB producer/compositor observer `d059e45b56de1f9b17e71852c886111940701f27`. Earlier exact-source receipts remain scoped below. | ADAPT independent actual-producer observers, source/order/revision mutants and actual signed UI-defect/artifact controls. New observer code never changes the tested product APK. Consumer pins remain immutable. | PARTIAL |
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

| Responsibility and source entry point | Authoritative interface / boundary |
| --- | --- |
| FastChat: [conversation contract](https://github.com/isomorphisms/fastchat/blob/759605c434fc94b6ea3ce604710f8340a36918a8/src/conversation.h), [actual store/controller](https://github.com/isomorphisms/fastchat/blob/759605c434fc94b6ea3ce604710f8340a36918a8/src/conversation.c), [transport boundary](https://github.com/isomorphisms/fastchat/blob/759605c434fc94b6ea3ce604710f8340a36918a8/src/transport_boundary.h) | `Conversation`, `HistoryTurn`, request/attempt/event admission, committed response extents and journal replay stay in the existing application owner. Transport/provider configuration remains separate from the renderer. |
| Same FastChat source: [native controller](https://github.com/isomorphisms/fastchat/blob/759605c434fc94b6ea3ce604710f8340a36918a8/android/native_activity.c), [framework panel](https://github.com/isomorphisms/fastchat/blob/759605c434fc94b6ea3ce604710f8340a36918a8/android/material_panel.inc), [historical worker](https://github.com/isomorphisms/fastchat/blob/759605c434fc94b6ea3ce604710f8340a36918a8/android/timeline_projection.h), [provider editor](https://github.com/isomorphisms/fastchat/blob/759605c434fc94b6ea3ce604710f8340a36918a8/android/provider_setup.inc) | Native controller dispatch, composer/draft lifecycle, reusable framework controls, bounded immutable historical projection and Activity-owned credential editor. The worker has no append/transport authority. |
| IB: [navigation](https://github.com/isomorphisms/ib/blob/994dbe273d5d198525a34e55feb9fd007827e4a4/src/IB/Reader/Navigation.idric), [selection](https://github.com/isomorphisms/ib/blob/994dbe273d5d198525a34e55feb9fd007827e4a4/src/IB/Reader/Selection.idric), [document](https://github.com/isomorphisms/ib/blob/994dbe273d5d198525a34e55feb9fd007827e4a4/src/IB/Reader/Document.idric), [history projection](https://github.com/isomorphisms/ib/blob/994dbe273d5d198525a34e55feb9fd007827e4a4/src/IB/Reader/Workbench.idric) | BrowserHistory occurrence order/cursor and exact source/revision/selection semantics; revision-checked projected source selection. Source arena/receipt validation remains upstream of display. |
| Same IB source: [checked Activity/controller](https://github.com/isomorphisms/ib/blob/994dbe273d5d198525a34e55feb9fd007827e4a4/examples/autogenerated/native-reader/NativeReader.idric), [native pane adapter](https://github.com/isomorphisms/ib/blob/994dbe273d5d198525a34e55feb9fd007827e4a4/native/android/ib_reader_workbench.c) | Existing checked Activity/controller and NativeTextView stay authoritative; JNI styles controls and switches pane visibility, without rebuilding the reader or creating a store. |
| android-NDK: [shared controls](https://github.com/isomorphisms/android-NDK/blob/b2ee19121aa3fa1112cd8338b7b6a7baca237b5f/native/presentation/material.h), [checked callback](https://github.com/isomorphisms/android-NDK/blob/b2ee19121aa3fa1112cd8338b7b6a7baca237b5f/examples/autogenerated/presentation-callback/PresentationCallback.idric) | Theme tokens, framework View primitives, real control IDs/hit regions and checked native `onClick(View)` declaration; no application model. |
| Exporter: [read-only contract](https://github.com/dilapidated-shed/ChatGPTExporter/blob/41132f68f2b74cb4f2a4f5c7fdbba8a2c96543d2/native/cgw_presentation.h), [verified implementation](https://github.com/dilapidated-shed/ChatGPTExporter/blob/41132f68f2b74cb4f2a4f5c7fdbba8a2c96543d2/native/cgw_presentation.c) | Worker-only verified native C1 archive access; selected parent path, exact roles/parts, assets, unsupported source spans and archive provenance. No provider-send interface. |

Focused handoff branches remain unmerged:

- [isomorphisms/fastchat PR #22, “Present durable turns with native Material message and paging controls”](https://github.com/isomorphisms/fastchat/pull/22), `work/m3-native-presentation`, based on `sun/fc-ui-01` at `7a4b57acf4df8809f6884a6adcaedc4fad03c141`.
- [isomorphisms/ib PR #169, “Present retained source history through native Material controls beside the reader”](https://github.com/isomorphisms/ib/pull/169), `work/m3-native-workbench`, based on `work/tabp10-reader-complete` at `9f468f9b6dfba8f3895f4ab5cd7a316dc08c562e`.
- [isomorphisms/android-NDK PR #42, “Share native Material role controls and a typed framework View callback”](https://github.com/isomorphisms/android-NDK/pull/42), `work/m3-native-controls`, based on checked-export-aliases `153e7fc8053ba4072954a5e77d4efa3609d829e4`.
- [isomorphisms/ai-ci PR #336, “Add independent native presentation and archive acceptance”](https://github.com/isomorphisms/ai-ci/pull/336), `acceptance/m3-native-workbench`, based on `acceptance/ib-chordreader-handoff` at `76375652724a6921f8374738cea9360366526242`.
- [dilapidated-shed/ChatGPTExporter PR #17, “Read verified C1 archives through bounded native Material controls”](https://github.com/dilapidated-shed/ChatGPTExporter/pull/17), `work/native-readonly-presentation`, based on `sun/chatgpt-export-complete-01` at `d19dba2bd0a10fc8b59a94931caf26cc128b9335`.
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
archives are synthetic. The new native reader uses the same shared Material
controls, an app-owned checked `onClick(View)` declaration, and existing private
workspace selection. Its explicit READ_SAVED entry constructs neither bridge
nor WebView. A capture-menu reader temporarily retains the existing capture
root and returns to it on Close; it refuses entry during an archive operation.

Archive verification, JSON/role/part decoding and Android ICU grapheme paging
run on one detached worker. UI publication contains at most2048 UTF16 units,
reuses Views and rejects stale request revisions. One outstanding verification
across Activity destruction prevents accumulating snapshots during repeated
recreation; the unavailable state is visible and recoverable with Back/reopen.
No UI-thread verification join is introduced. Page and part navigation retains
the selected-parent path; canonical all-branch inventory is separately labelled.
Unknown provider roles come from verified original metadata. Unknown/asset
blocks display their actual raw metadata, without inventing asset acquisition.
TextView selection/copy remains native. Reopen restores archive data, not a
prior viewport or a live page.

This source uses ICK for the new JNI renderer and C1 projection, followed by
NDK assembly/link. Legacy capture/WebView platform C keeps its explicit NDK
qualification gap. The standalone signed x86 production-code test package uses
the existing fixture namespace/signature/UID and actual captured synthetic
archive, without its synthetic transport. That namespace is distinct from the
deliverable ARM64 app. Independent ai-ci6cfacc59/fc5e5fca observes actual text, roles,
branch callback, framework copy, compositor, offline reopening and unchanged
archive bytes, then corrupts an actual normalized file and requires refusal.
At source41132f68 the producer additionally passes byte-identical signed ARM64
reproduction and actual API34 viewing with the qualified6cf observer. The
independent29/34 observations of unchanged final411 bytes are scoped below.

Exporter reuses the existing source-bound ICK cross compiler stages from IB
producer `82cc8716b3feb05a05e5aa7fa0bac7b4db40f8c6`, ICK source
`fbe86e23d55cfec2000c08e61deea2a407fd7175`. ARM64 compiler artifact12240678290
ZIP SHA-256 is `16525b18ca3cb38848be6f6ea35527eee218e52a0934a4719c7fda6a3332edd7`;
x86_64 artifact12240692135 is
`9fdd4788b872f355545ad177a825fd9aa99f04bddc07d1615efeb9348652f3ac`.
The final producer requalifies these actual target compilers against NDK29
before compiling new owned UI/C1 source: glyph/Bionic, API25 rejection,
atomics, complex values and branch protection. Target-prefixed GCC paths remain
honest. This does not relabel an older qualification or compile the new owned
renderer with NDK Clang. Source-stage and qualification receipts are retained
in the producer artifact. Existing legacy capture platform-C compilation remains
the explicit exception awaiting separate migration.


## Visible-surface regression and actual input qualification

The first Activity-content repair passed accessibility actions against an
**invisible view tree**. Old signed FastChat
`bdae9a45abca9d7a75aaeb2e6b93e971a06f3760` has black API29 and API34 startup
screenshots. Real API29 key dispatch timed out in run41762938888 while
InputDispatcher reported no focused input window. Its earlier semantic checks
do not qualify a functioning visible app. That APK is superseded.

Android10 platform [NativeActivity.java](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-10.0.0_r47/core/java/android/app/NativeActivity.java)
claims Surface and InputQueue before native startup.
[Window.java](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-10.0.0_r47/core/java/android/view/Window.java)
and [PhoneWindow.java](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-10.0.0_r47/core/java/com/android/internal/policy/PhoneWindow.java)
define their release. Shared `m3_framework_window` clears both callbacks before
Decor attachment and refuses late/failed handoff. FastChat759605c4 calls it.
Native lifecycle/controller remains; Canvas comparison stays separate. IB's
ordinary checked Activity has no NativeActivity claims and retains the
compatible shared predecessor1f9c30aeb7cc719075ed470b6135c4cc8ce194ca.

Independent FrameProbe now samples actual compositor pixels at actual Send and
Setup Button bounds. Each must match its real semantic fill within two RGB
levels, and fills must differ. A populated layout/accessibility tree cannot
pass. The old signed bdae APK must reach the exact compositor refusal, not a
crash, timeout or missing sampling control.

The separate IME observer uses an empty isolated durable store. It requires an
actual system keyboard window, resized content, focus and composer bounds,
injects real ASCII/Enter events after Unicode/combining/RTL text, checks exact
multiline text, dismisses the keyboard with Back and verifies the journal stays
empty. An actual ADJUST_NOTHING mutation must fail precise geometry admission.
This does not prove language-specific composition or physical typing.

IB6f's actual retained-document screenshots separately exposed old XML
backgroundTint values surviving the native shared background. Shared dark text
then appeared on legacy dark buttons, while the new untinted History Button
was correct. IBa6ef removes those conflicting XML tint attributes. Independent
ReaderFrameProbe compares live Sources/History compositor pixels to their actual
shared neutral fills and saves that live frame before instrumentation ends.
The actual inflated-control tint mutation must reach the exact compositor
refusal. Earlier6f source/reader semantic passes do not establish correct colors.
The D059 observer additionally proves dark pixels reached the live compositor
before asserting refusal. The earlier9efa tint negative returned ordinary PASS
and failed the gate; setter completion was insufficient activation evidence.
The stronger observer passed both APIs on a6ef before producer994 pinned it.
In [run41769213879](https://github.com/isomorphisms/ai-ci/actions/runs/41769213879),
API29 job126374870133 executed the old signed6f artifact through its reader,
acquisition, offline and provenance checks, then failed precisely
`FAIL IB semantic surfaces differ from actual compositor`. This is a reproduced
bad-producer failure, not a passing full workflow.
API34 job126374870421 in that same repeat stopped earlier at the declared
emulator reboot-transport deadline; it did not reach the new compositor check
and cannot count as a theme refusal or passing qualification.

The da920 repeat of FastChat had two corrupt emulator SDK archive failures
before boot. Its API34 IME case separately failed final Back geometry after
typing; it is not an infrastructure failure. That probe sampled once after500ms.
Source4c41 retains all state requirements, observes asynchronous restoration
with a bounded40*50ms deadline, fails immediately if Activity finishes and logs
actual baseline/current height, keyboard top and finishing state on refusal.
This deadline is not an interaction-latency benchmark.

## Source-bound qualification

API29/34 runtime below means x86_64 emulator ART. ARM64 ART and physical
acceptance remain separate. API35/36 runtime is NOT_RUN, including where IB's
manifest targets36.

| Source-bound check | Receipt | Outcome and limit |
| --- | --- | --- |
| FastChat759605c4 reproducible producer | [41766075259](https://github.com/isomorphisms/fastchat/actions/runs/41766075259) | PASS signed ARM32/ARM64/x86 APK reproduction and API29/34 semantic controls, paging, Stop, exact clipboard, durable turns/history and secure settings. Compositor/IME are separately required below. |
| Same FastChat core/worker and HTTP2 | [41766075298](https://github.com/isomorphisms/fastchat/actions/runs/41766075298), [41766075366](https://github.com/isomorphisms/fastchat/actions/runs/41766075366) | PASS store/replay/retry/worker/mutations and credential-free transport qualification; not a paid-provider request. |
| Same FastChat typed semantics | [41766075166](https://github.com/isomorphisms/fastchat/actions/runs/41766075166) | PASS existing Idriç conversation semantics. |
| Independent ai-ci8528c49e FastChat | [41767027593](https://github.com/isomorphisms/ai-ci/actions/runs/41767027593) | PASS all ten jobs: actual conversation controls on API29/34, visible compositor surfaces and real IME/key/Back on both APIs, targeted signed ownership/settings/black-surface producers, actual broken resize integration, independent worker/mutations and ARM64 signature/ABI/source/tamper inspection. |
| Follow-up ai-ci4c41cf77 FastChat, same759 APK | [41769213192](https://github.com/isomorphisms/ai-ci/actions/runs/41769213192) | PASS all ten jobs after the bounded asynchronous Back observation. API29/34 compositor, actual IME input and unchanged final restoration/journal requirements pass. Same exact signed source/ABI/settings/ownership/frame/resize/worker controls remain required. |
| IB tint repair a6efebaf producer | [41768558936](https://github.com/isomorphisms/ib/actions/runs/41768558936) | Source/three-ABI reproducibility PASS. Both Android jobs FAIL the old negative observer after actual good-color/history assertions; a tint setter return did not prove that the mutation had reached the compositor. Not a whole-run PASS. |
| Independent ai-ci9efa0c9b, unchanged signed IB a6efebaf | [41773741372](https://github.com/isomorphisms/ai-ci/actions/runs/41773741372) | API34 actual source/history/compositor positive PASS; required tint negative returned ordinary PASS and therefore the job FAILS. No passing negative inferred. |
| Independent ai-ciD059, same a6efebaf bytes | [41775440050](https://github.com/isomorphisms/ai-ci/actions/runs/41775440050) | API29/34 PASS after requiring actual dark-pixel mutation activation before the unchanged precise refusal assertion. Ordered durable history remains unchanged. This observer was qualified before IB consumed its pin. |
| IB994dbe27 final producer | [41776460289](https://github.com/isomorphisms/ib/actions/runs/41776460289) | PASS source/checked DEX/three-ABI signed byte reproduction and both API29/34 real reader/acquisition/source-history/UI/compositor/tint-negative gates with the qualified D059 pin. |
| Independent ai-ci4c6da077, unchanged final IB994dbe27 APK | [41781023723](https://github.com/isomorphisms/ai-ci/actions/runs/41781023723) | API34 PASS all required source/callback/capability/provenance/acquisition/offline/History/Reader/compositor gates and activated actual tint refusal. API29 FAIL before emulator boot (TCP5554 refused/boot deadline); no app execution result. |
| Follow-up ai-ci70d9d1ec, unchanged final IB994dbe27 APK | [41782774097](https://github.com/isomorphisms/ai-ci/actions/runs/41782774097) | API29 PASS. Original API34 stopped before boot; one rerun passed native capability/acquisition/reflow/copy/offline gates, then failed the120s emulator-reboot transport deadline before History UI. Not a passing whole matrix, and not a new application refusal. |
| Independent ai-ci6cfacc59, unchanged final IB994dbe27 APK | [41790878088](https://github.com/isomorphisms/ai-ci/actions/runs/41790878088) | API29 and34 PASS all required source/callback/capability/provenance/acquisition/offline/History/Reader/compositor gates and the activated actual dark-tint refusal. |
| Follow-up ai-ci4c6da077 FastChat, unchanged759 APK | [41781023332](https://github.com/isomorphisms/ai-ci/actions/runs/41781023332) | PASS all ten jobs, including real compositor/IME/key/Back API29/34, signed bad producers, broken resize, worker and ARM64 inspection. |
| Independent ai-ci6cfacc59 FastChat, unchanged759 APK | [41790877894](https://github.com/isomorphisms/ai-ci/actions/runs/41790877894) | PASS all ten required jobs; no new FastChat product build or source relabelling. |
| IB6f88d23d producer | [41760151727](https://github.com/isomorphisms/ib/actions/runs/41760151727) | PASS checked DEX/independent decode, 3ABI compilation, byte-identical signing and both API29/34 reader, acquisition, provenance, lifecycle, navigation and History/Reader gates. |
| Independent ai-ci8528c49e unchanged IB APK | [41767028106](https://github.com/isomorphisms/ai-ci/actions/runs/41767028106) | API29 and API34 PASS: exact-source typed revision/callback mutations, actual installed acquisition/capability controls, provenance refusal, offline history and History/Reader View/selection/scroll/source identity. Independent external probe rebuilt; no product APK recompiled or modified. |
| android-NDK b2ee1912 | [41764933438](https://github.com/isomorphisms/android-NDK/actions/runs/41764933438) | PASS canonical checked DEX/JNI, independent decode, framework/ICU ART and mutations. New handoff's actual screen/input evidence belongs to FastChat. |
| Exporter6c84de4b | [41703456445](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41703456445) | PASS independent real C1 read-only adapter and compiled role, selected-parent-path and component-version mutants. Actual disk archives are synthetic; no Android archive viewer qualified. |
| Same Exporter capture shell | [41703456385](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41703456385) | PASS capture boundary only. |
| First actual Exporter native viewer4aec7193 | [41787433847](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41787433847) | PASS checked app callbacks, ICK projection/UI source and NDK link, signed ARM64 byte reproduction, actual API34 production-code read-only view/role/branch/copy/compositor/offline reopen/no archive writes/corrupt-source refusal. Distinct synthetic fixture namespace; not user-data or ARM64 runtime acceptance. |
| Exporter b2ef2af6 stronger producer | [41788146871](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41788146871) | Source/reproduction and valid native views PASS. Deliberate signed bad producer crashed from an unrelayed UI-thread assertion; required precise rejection was absent, so the runtime job FAILS. No generic crash accepted as a negative pass. |
| Independent ai-ci6cfacc59, unchanged b2ef2af6 APKs | [41790878034](https://github.com/isomorphisms/ai-ci/actions/runs/41790878034) | Both API29/34 PASS independently reconstructed actual C1 archive, SDK/source/ABI inspection, actual archive digests/roles/branch/framework copy/compositor/reopen, unchanged archive bytes, exact signed control-guard mutant rejection and corrupt-source refusal. Product APKs not recompiled. |
| Final Exporter41132f68 producer | [41791869583](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41791869583) | PASS all three jobs: current checked DEX, ICK new UI/C1 source with fresh NDK29 qualification, both native ABI payloads, byte-reproduced established ARM64 signature, actual API34 production UI and both meaningful refusals. Uses already qualified6cf observer and8dp control gaps. Legacy platform-C qualification gap remains declared. |
| Independent final Exporter41132f68, ai-ci fc5e5fca | [41792856962](https://github.com/isomorphisms/ai-ci/actions/runs/41792856962) | Both API29/34 PASS on unchanged final production bytes: independently reconstructed captured C1 disk data, exact source/SDK/signer/ABI, native roles/branch/copy/compositor/offline reopen, no archive writes, precise signed control-guard mutation rejection and actual corrupt-source refusal. Actual user archive and physical NOT_RUN. |
| Final fc5e5fca FastChat repeat, unchanged759 APK | [41792856875](https://github.com/isomorphisms/ai-ci/actions/runs/41792856875) | All ten jobs PASS, including actual signed candidate, API29/34 native/IME, source-order/revision, ownership/secure-window/compositor/keyboard and artifact negatives. |
| Final fc5e5fca IB repeat, unchanged994 APK | [41792856831](https://github.com/isomorphisms/ai-ci/actions/runs/41792856831) | API29 PASS. API34 capability/acquisition/reflow/copy/offline gates PASS, then emulator failed to return within the120s reboot-transport bound before History UI. Whole API34 job FAIL; not a new application assertion refusal and not a whole-matrix pass. Preceding6cf unchanged-source both-API PASS remains separately recorded. No retry of this run. |
| Historical IBa303 independent | [41758756603](https://github.com/isomorphisms/ai-ci/actions/runs/41758756603) | API29/34 PASS unchanged signed bytes, semantic/callback/capability mutants, acquisition, offline history and reader/history preservation. Not promoted to new6f source. |

Critical controls compile actual worker mutations reversing turn order and
bypassing stale publication; typed IB mutations bypass revision admission and
change onClick(View) to onClick(Int32). Installed IB capability mutants bypass
UID/death/flags/stale authorization. Archive mutants corrupt roles/path/version.
Each requires the intended diagnostic; compile failures or crashes cannot pass.

Actual signed FastChat producers test Activity ownership0c5288a2,
secure settingsaaabc570 and compositor failurebdae9a45. Host artifact controls
reject wrong source, wrong ABI and changed signed bytes using actual SDK
verification. Loader failure in IME source68ec was not counted as a passing
negative. Corrected709e run41762938888 passed API34 IME and the resize mutation,
but API29 key dispatch timed out and exposed the black-screen flaw; that whole
run is not PASS.

Exact old signed producers retained solely as rejection controls:

| Boundary | Actual rejected source | Producer run / x86 artifact |
| --- | --- | --- |
| Activity content ownership | `0c5288a207595a0d6924875731091092595fa711` | 41751490657 /13286571421 |
| Secure settings window | `aaabc570c4416fd3e39fc72154ba176fe750853f` | 41753731428 /13286189228 |
| Visible framework compositor | `bdae9a45abca9d7a75aaeb2e6b93e971a06f3760` | 41754800398 /13288600748 |
| IB XML tint integration | `6f88d23d337c17e076ded68a308542f0955b921e` | 41760151727 /13290449853 full archive; independently rejected by API29 in41769213879 |

The resize and tint controls also mutate actual live Window/View state in the
observer. They do not replace the application with a mock or count generic
crashes as refusals.

The archive UI has a separately compiled, signed production-code mutant with
one actual View-object identity admission guard deleted. A same-ID foreign
View must leave the current control enabled; the mutant admits it and disables
that control synchronously, reaching the precise rejection. Its source patch,
native binary, APK and hashes are retained. The repaired observer relays the
original UI-thread Throwable to its result handler; Android14's
[Instrumentation.SyncRunnable](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-14.0.0_r1/core/java/android/app/Instrumentation.java)
does not catch Runnable exceptions. That preserves the assertion and prevents
an uncaught process death from substituting for a semantic refusal.

Earlier IB emulator capacity/adbd failures were repaired in the harness:
verified selected bytes are retained, the exact verified archive digest is
rechecked before pruning guarded job-owned paths, and4GiB free space is required.
Only the exact observed root-transition status1 diagnostic permits bounded
reconnect plus verified root UID. The independent Smali probe prints its
semantic refusal and exits42; source/callback controls require both, rather
than accepting an uncaught AssertionError exposed only as “Killed”.

## Signed Android artifacts and installation

| Candidate | Exact source | Package / ABI / size | APK SHA-256 |
| --- | --- | --- | --- |
| [FastChat13293216565](https://github.com/isomorphisms/fastchat/actions/runs/41766075259/artifacts/13293216565) | `759605c434fc94b6ea3ce604710f8340a36918a8` | org.isomorphisms.fastchat.diskstreaming.arena; version7/0.7-native-material-candidate; min26/target34; ARM64; 2,319,187 bytes | `e7f1d847cfea4c1dccee164c643ded8c3b57f5b82d62aa6112188e0c9f435936` |
| [IB13297599590](https://github.com/isomorphisms/ib/actions/runs/41776460289/artifacts/13297599590) | `994dbe273d5d198525a34e55feb9fd007827e4a4` | org.isomorphisms.ib.prepaint; version3/0.3.0; min29/target36; universal ARM32/ARM64/x86_64; 10,372,647 bytes | `50a38c613a89c3e1ea3dbfd954ba5917c5e18ef44f27f297eae61ffcd76a4b47` |
| [Exporter13304221264](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41791869583/artifacts/13304221264) | `41132f68f2b74cb4f2a4f5c7fdbba8a2c96543d2` | org.isomorphisms.chatgptexporter; version5/0.4-native-reader-candidate; min26/target34; ARM64; 94,924 bytes | `1d402d9d908b4d25662fb9bfba3b4509997d7d38c7caf5f174619939c54ac98f` |

Established public development/test certificate SHA-256:
FastChat `aa9151e3922fa4795987c3655bc7aa4712620f1d94c24a2075acd7b29d8ac86e`;
IB and Exporter `de9b1d47c5a65e6d46a204b79dd9ee566b9d3c9832ba81ebc4213d3392e92ff9`.
These are development candidates, not production/store releases.
Checked572-byte Action.dex remains
`24e37795b5c8001a280b9f5f46c64ed510660358fb42f2a7109b52e2a5c067ad`.

Downloaded ZIP digests match GitHub artifact digests and actual extracted APKs:
FastChat ARM64 `bc9b2fada46c5b29f198d8fc3033abcb3a6e1882db5054a6d0cb818394dfcbc9`;
IB candidate `343e2666266a19a115c8b7772a0707d20ac270e0c0e2b26cc24fb83bb1378879`.
IB full source archive13299215602 (verified by source-bound input guards):
`973328d29c109d7efa898a04b97e05fb9ca77c88b48bf943773855a4a25cbde8`.
FastChat x86 artifact13292987492:
`c60253da29ccc4341d9b007533f41567da56c70e752350b7f821f6935b6caefc`;
ARM32 artifact13292274462:
`762f1bbd8216353beebc9c7365d8fdd141894c833c9299d74da862edf1837e05`.
Exporter final ZIP13304221264:
`24d3d5b13862d280c65c60f90cedafc99d4d7252406d396a7def1dea820a8b2c`.
Its signed ARM64 repeat hashes are both the1d402d9d digest above; unsigned
repeats are both `e6afe08adac6062e3b50127b24e5a2c3029e77f858e968b09cd5cd2627a9f15b`.
Production-code x86 test APK is
`ecb949038f4d4ffd5b9692b0e791d16b095d821b808f93cc7c8ad93690ab3d1e`;
its namespace is `org.isomorphisms.chatgptexporter.e1fixture`, version1.
It contains the actual production transport/renderer, while its existing test
namespace permits keeping the actual captured synthetic archive and UID.
This namespace and x86 execution are not ARM64 device acceptance.
Independent SDK signature/manifest/source/ELF checks are a distinct acceptance
job, not merely trust in producer receipts.

The following independent receipts were downloaded, ZIP hashes matched and
their exact result/signature diagnostics inspected:

| Artifact in independent FastChat run41767027593 | ZIP SHA-256 | Observed result |
| --- | --- | --- |
| API29 IME13293282610 | `4edac2d191aa000a7ed6d32988dd96bfb0e916f3348476497ada905b5a048680` | compositor, actual keyboard/input/Back and empty journal PASS |
| API34 IME13293490684 | `3d4cdcfbd09c3325bf915f89580657fd17431fa412d340629ebc970978ffe3d7` | same actual positive assertions PASS |
| Follow-up4c41 API29 IME13294282013, run41769213192 | `9ce8d7ef9dbe26a23f114b5d20bc0a3d99690e4225320a3b37ba5a5db34aa937` | compositor, actual input and bounded asynchronous Back restoration PASS |
| Follow-up4c41 API34 IME13294780026, same run | `880df71e1ab1e23d3ba51756f7a35847b3eeb397d848d753ad8486e4c71f15e6` | same required state assertions PASS; not an interaction-latency benchmark |
| Old signed black-surface13293306895 | `77a4441907331a72a6bc91a3e27dee4de473e440dc3d76feb0ebd42ea2075c6b` | exact compositor assertion REJECTED |
| Broken resize13292803391 | `da18ebc891a18a31d10ca9f1d13dd42298e393629a34c597a085eddddd1efdf6` | exact keyboard geometry assertion REJECTED |
| Actual C67 signed delivery13293097758 | `eae996cce8e6e2507d44bc48788d8b73374a6e75b9489b7b201ed495728766eb` | SDK verifies one v2 signer, declared ARM64/SDK/manifest, checked DEX, ELF64/AArch64 and source; wrong source/ABI and tampered signed bytes REJECTED. ARM64 ART and physical remain NOT_RUN. |
| IB API29 artifact13293073980, run41767028106 | `10bbe8faea56d124977e56a4deb147350b2b4c0d902a95e345d37f31f8c9ee01` | Actual6f source, typed/callback/capability/provenance controls and History/Reader source/generation/order preservation PASS. SDK verifies one v3 signer matching the established IB certificate. |
| IB API34 artifact13293416150, same run | `60b8e09ada3787d47268b7194da83115862d4d414a8e621f77c3da2aca6b4f0e` | Same required unchanged-product gates PASS; actual retained source and generation1 read back. End-of-instrumentation screenshot shows launcher, so it is not an IB visual reference. |
| IB a6ef API29 artifact13296564170, run41775440050 | `e700c8e9e9354571341ba72e77c6c220cd126f88f3080df003b251af64754841` | Positive reader/history/compositor and activated actual dark-tint refusal PASS. Durable source/generation/order preserved. |
| IB a6ef API34 artifact13297361319, same run | `622ff70c29db7df9d9b78b1f5e34a7828d0831386872cce1acac46a76bf11f68` | Same positive and actual activated negative PASS; both good and deliberately dark compositor frames inspected. |
| Final IB994dbe27 API34 artifact13298814595, run41781023723 | `f2466b0afb0f352d3093e6d638bd5e61fcc820b8e922af92f1576a3f532cd9ff` | Unchanged installed APK, actual retained source/history, one established v3 signer, live good-color frame and precisely refused activated dark mutation inspected. |
| Final IB994 API29 artifact13303557447, run41790878088 | `f5e3f45a39cce2a022b8be61f92a224b509a3db3b5f5505b91151a8fd3a18258` | Full independent actual-source/callback/capability/acquisition/offline/History/Reader PASS; preserved durable generation1, source and history; precisely rejected activated dark-tint mutation. |
| Final IB994 API34 artifact13303333511, same run | `34fa564d2d90aec3d7ad8ffc004bfcab04095527e2ae8bdde91ff54a6e564b5d` | Same required gates PASS. Actual live good reader frame inspected; Forward wraps on320dp, so compact/font-scale qualification remains incomplete. |
| Final Exporter411 API29 artifact13303992886, run41792856962 | `5afc721874a2d4a95b8506e9f8949256573478e7c79c92d45f4cc67dbe411cc6` | Actual reconstructed archive expected=verified1, full-account-complete=false. Source/roles/native view/reopen/copy/no writes PASS. Actual signed guard mutant returns CODE0 with exact same-ID assertion; corrupt normalized source returns CODE-1 with explicit refusal. |
| Final Exporter411 API34 artifact13304262751, same run | `b50021365342c2f9c2e3a80a8fee06bddb2c778d1e110f7ab492856b07cc14d4` | Same required assertions and precise refusals inspected. Actual production-code frame viewed; eight real controls and readable source/role/body. Synthetic captured C1 data; actual user archive NOT_RUN. |

Installation handoff: discover each device, ABI, installed package, signer,
version and free space afresh. C67 uses ARM64 FastChat; A1 uses its separate
ARM32 APK only if functioning and compatible. Universal IB still requires min29
and fresh tablet facts. Replacement-install while preserving data. On signer
or version mismatch stop; do not uninstall or clear storage. No build tools or
compiler bundles belong on the devices.

On a matching device, open the downloaded APK from Downloads, select the Android
package installer's Update action and then Open. Installation has not been
performed by this campaign. If Android refuses the existing signer/version,
record that result and keep the current app/data intact.
IB's network acquisition also requires its existing authorized Shizuku/ICU
worker route. Installing this APK does not provision that authority. Offline
reopening requires actual retained source data; the empty/capability states
are distinct from a functioning acquisition route.

## Performance and physical acceptance

Single-run FastChat759605c4 observations, x86_64 emulators, include the runtime
and observer. Cold screenshots were inspected and show actual framework UI on
both APIs. These are not matched physical-device or renderer comparisons.

| Metric | API29 | API34 | Limit |
| --- | --- | --- | --- |
| Cold Activity launch TotalTime | 920ms | 2329ms | am start -W; not first composited frame latency |
| Instrumented launch to discoverable composer | 930ms | 2159ms | Includes instrumentation, not a warm/cold matched sample |
| Peak process RSS, VmHWM | 184284kB | 123532kB | Process/runtime/observer included |
| Observed process RSS | 145908kB | 123532kB | Not a bounded-memory long-thread proof |
| Observed Android PSS | 34360KiB | 30067KiB | Distinct from RSS |
| Cumulative process CPU | 1578ms | 1299ms | Not incremental cost, percent CPU or thermal behavior |
| Second am start | Existing Activity; WaitTime4ms | Existing Activity; WaitTime8ms | Not a warm launch; TotalTime0 is not zero launch cost |

Receipts: [API29 artifact13293156945](https://github.com/isomorphisms/fastchat/actions/runs/41766075259/artifacts/13293156945),
downloaded ZIP SHA-256 `ba89cb7df91e652ff392cb1bfb7208524f35554b83e819c48357a4a894aabbe4`;
[API34 artifact13292439133](https://github.com/isomorphisms/fastchat/actions/runs/41766075259/artifacts/13292439133),
ZIP `a4658d2c30e05c13c8a58b2beb4bdf1ef421bf289d8d15528df1cf8e1692a406`.
Post-instrumentation meminfo says no process found; that means unavailable,
not zero memory. Differences between these emulator runs do not establish
renderer efficiency or causation.

No matched native/Compose/framebuffer semantic-fixture/hardware experiment ran.
IB and Exporter startup, RSS and interaction-latency measurements remain NOT_RUN.
Compose's historical1,042,096-byte APK used different managed storage and cannot
establish efficiency. Warm startup, UI-thread stall distribution, incremental
layout cost, long-conversation peak memory and physical CPU/thermal comparison
are NOT_RUN. Earlier bdae launch/accessibility/RSS timings measured a black
compositor frame; they are not usable-render startup or product comparison.

| Required physical exercise | MIRO C67 Android14 | SVITOO TAB_P10 | MIRO A1, functioning conditional |
| --- | --- | --- | --- |
| Fresh identity/ABI, installed signer/version, capacity | BLOCKED | BLOCKED | NOT_RUN |
| Replacement install and launch | BLOCKED | BLOCKED | NOT_RUN |
| Long thread, scrolling/pagination, touch feedback | BLOCKED | BLOCKED | NOT_RUN |
| Multiline human entry and exact message copy | BLOCKED | BLOCKED | NOT_RUN |
| App switching and rotation/recreation | BLOCKED | BLOCKED | NOT_RUN |
| Offline retained-content reopen | BLOCKED | BLOCKED | NOT_RUN |
| IB reader separately | BLOCKED | BLOCKED | NOT_RUN |
| IB history/workbench separately and reader transition | BLOCKED | BLOCKED | NOT_RUN |

No authenticated live device channel exists. Emulator observations do not
qualify C67, TAB_P10 or A1. The physical pagination report remains open:
[isomorphisms/fastchat issue #21](https://github.com/isomorphisms/fastchat/issues/21).
The branch's black-surface regression does not establish the cause of the
original physical v6 Canvas “Unresponsive” report.

## Release status and next concrete actions

The focused PR links above give each exact base/branch. All five implementation
PRs remain drafts; no merge, close, retarget over an unresolved base or release
was performed. Source heads are in the ownership ledger. A later documentation
head must not be confused with tested acceptance sources6cfacc591b5e6b187547b4409e976772f319c28b
and fc5e5fca71b9d8d5831619b7a9a0130e449a93a6. The latter passes archive29/34
and all ten FastChat jobs; its IB29 passes while IB34 stops at emulator reboot.
The preceding6cf IB matrix passes both APIs. Documentation publication does not
relabel pending automatic reruns as passing.

| Workstream | Integration | Remaining dependency / next action |
| --- | --- | --- |
| FastChat | PARTIAL | Visible/IME emulator qualification passes; physical issue21 remains. Add Markdown/links/Share/attachments/search/wide layout; move remaining controller/store/transport I/O off UI ALooper. |
| IB reader | PARTIAL | Preserve passing API29/34 source/reader gates; diagnose inherited live scientific-media assertion separately. |
| IB workbench | PARTIAL | Retained-source History/Reader works; connect actual task/request/evidence/action state through IB's existing owners. Visits are not task history. Move synchronous history reads/projection and the bounded128-control rebuild behind asynchronous ownership and measure incremental cost before claiming a fully nonblocking workbench. |
| IB browser frontend | NOT_RUN | Preserve existing browser frontend and source authorities; integrate shared presentation through its actual task/controller interface and qualify it separately. No browser frontend changes were made by this campaign. |
| Pensieve, IB-owned | NOT_RUN (native integration) | Connect existing S08 producer/executor and actual persistence outcomes to native source arena while preserving identity and authority. This missing implementation is unfinished work, not an external blocker. |
| Longview, IB-owned | PARTIAL | Connect durable native task host and restored inputs. Distinguish durable reopen from live page cookies/forms/heap recovery. |
| ChatGPTExporter | PARTIAL | Native C1 Android viewer, offline entry and producer plus independent29/34 gates pass. Complete generalized V2/SAF archive handoff, actual user-export acceptance, rich content, long Unicode UI stress, theme/font/a11y/tablet/performance qualification. Existing256-byte workspace initialization still performs legacy UI-thread storage access; page worker still decodes full parts. Preserve read-only authority. |
| android-NDK | PARTIAL | Shared controls are consumed by three apps; resolve checked-export-aliases base dependency and finish theme/font-scale/state/accessibility qualification. |
| Idriç | PARTIAL | Existing consumer pins execute; any language/backend extension requires a reduced real failing consumer. |
| ai-ci | PARTIAL | Retain exact-source producer negatives and current receipts; add remaining recreation/touch/font/contrast/long-thread/performance assertions. |
| Cat Food / physical targets | BLOCKED | Establish live authenticated device channel; discover C67/TAB independently, inspect installed identity/capacity, then install exact candidates and exercise human input. |
| Android precedents/reference | NOT_RUN for new consumer | Reference inspection complete; preserve pinned43-signature AndroidX reference, no matched physical comparison yet. |
| climenu | NOT_RUN for Android | Qualify command/stdin bridge before mapping existing Idriç descriptions to native controls. |
| az | NOT_RUN for native migration | Implement checked native frontend preserving command/TSV/permission/signer authority; Java frontend cannot enter this lane. |

IB [browser-foundation41760151831](https://github.com/isomorphisms/ib/actions/runs/41760151831)
still fails inherited arXiv progressive-prepaint while core passes. Four actual
HTML/image harvests preceded the failure; this is not network-unavailability
evidence and was not waived. It is separate from passing reader/history gates.
Virtualized long history, full semantic controls, media/Markdown/links,
attachments, search, tablet layout and complete accessibility remain unfinished.
A bounded history worker does not prove a fully nonblocking frontend.

Cat Food's inspected `eafd7fa9e61138a664b205bf8ba82ec6837bbbb9`
`android/delivery.tsv` explicitly leaves IB as `gap:android-package-missing`;
the inspected package registry has no entries for these new APK candidates.
Its documented runtime archive/file/direct-DEX delivery is not evidence of a
qualified APK-install path for these applications. Do not invent a Cat Food
install command or register a fake pending package. GitHub Actions artifacts
are the source-bound distribution handoff; native Android Update is a manual
handoff until the existing Cat Food owner wires and qualifies APK delivery.
The campaign's full completion criteria are not met; these PRs are not
merge-ready for that claim.
