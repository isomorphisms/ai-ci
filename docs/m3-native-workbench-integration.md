# Native Material presentation integration

Campaign: SUN-M3-NATIVE-WORKBENCH-COMPLETE-01. Overall status: PARTIAL.
This ledger separates implementation, build, ART execution and physical use.
No merge or production release is authorized or performed by this campaign.

## Ownership and exact sources

| Workstream | Default source inspected | Chosen integration source | Decision and evidence | Status |
| --- | --- | --- | --- | --- |
| FastChat | `442e8135c018ee003021f1c3f681686c80be9fd0` | `b382c67f57ab67dd44cabc5c8e673015ddd74b06` | REPAIR existing native controller/store/transport and framework surface; add bounded preceding-turn projection. Keep existing `HistoryTurn`, request/attempt identities and response arena. | PARTIAL |
| IB | `0f3d8dcdc20239987ce30da3d27788a90d2c090a` | `a30381aee243d56d83da19befe64e2f84ebccfc9`, stacked on reader `9f468f9b6dfba8f3895f4ab5cd7a316dc08c562e` | REUSE checked reader and its source owner; REPAIR styling to preserve qualified reflow labels; ADAPT existing BrowserHistory occurrences through revision-checked selection. | PARTIAL |
| Shared Android primitives | `6ab4818219efa7ea5eda137ca6b76976eb2a4d42` | `1f9c30aeb7cc719075ed470b6135c4cc8ce194ca` | REUSE small `native/presentation/material.h` and checked `Action.dex`; application semantics stay in consumers. Base is checked-export-aliases `153e7fc8053ba4072954a5e77d4efa3609d829e4`. | PARTIAL |
| Idriç | master `0fb1192cd30ec4747cbc727f26ddbfad515d1363` | Existing consumer pins: IB `740bbf2b1d9e811fd00c719c3473eede17ceea3b`; FastChat `ff4d852862a3942592f8ade9afde8d409d9803be` | REUSE existing typed semantic interfaces. No speculative compiler change or new universal serialization. Current master is inventory, not a silently substituted consumer pin. | PARTIAL |
| ChatGPTExporter | `1285e1e89537e92d6df7317b882e192fc942dc6c` | `6c84de4b8c4fe298c2bb61386b7158833249aca4` | REUSE verified read-only native C1 adapter and cached selected-parent path; retain browser/offline V2 verifier separately. | PARTIAL |
| ai-ci | `a66e3a9bb1070a338f8c4a67f9b4b4ac39dfb5ec` | New timeline observers `21d19a83ccec345be98c074ef439bf84ee4c6c81`; existing IB reader observer `39ba6eb1218c7883fa1f1c98b07bf0dceabbf6d5`; presentation observer `b30c3896c76ffe2c391647da65465c655539997b` | ADAPT independent actual-producer observers; new order and stale-publication mutations, explicit opt-in installed timeline exercise. | PARTIAL |
| Cat Food | `eafd7fa9e61138a664b205bf8ba82ec6837bbbb9` | TAB_P10 discovery `0e73eada1193b9b7de55defacfdf425b35101de7` | REUSE target discovery. Historical C67 ARM64/API34 profile is distinct from a fresh device observation. No authenticated current device channel or local adb is available. | BLOCKED |
| Android precedents/reference | main `34b2391a97867ab25ea885cedc7ac2e04b591609` | Material API reference `689bda5bf777a39d35e5aa14bbbb921d8af555b1` | REUSE reference only: 43 signature files at AndroidX `cdeafe5b4e450d61cdb623d58c148efbb0d508cf`. Inspection complete; no Compose product dependency. | NOT_RUN (new consumer integration) |
| climenu, canonical owner `dilapidated-shed/climenu` | `b39dbb2bd44d0f87d3321f01c995edb80358b21b` | unchanged | DEFER Android adoption: current implementation is a pure Idriç command-description to HTML projection; executable/stdin bridge is still unqualified. Preserve command semantics; no chat replacement. | NOT_RUN (Android integration) |
| az, canonical owner `Ashtray-Archer/az` | `249c02b5669c1f6c9682fa5848b1b946e147a7ce` | unchanged | DEFER importing its Java/javac/d8 Android frontend into the no-Java product lane. Its Termux command/TSV contract remains owned by az. A shared native frontend must preserve that contract and canonical signer. | NOT_RUN (native migration) |

Both repository transfers were resolved from live repository metadata rather
than creating replacements under the former `isomorphisms` owner.

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

## Qualification and release gates

Current-source receipts are recorded below when terminal. Source review,
host pthread execution, packaging, ART and physical observations are separate.
API35 is NOT_RUN; this product matrix currently requires APIs29/34.

Active exact-source qualification:

- FastChat source `b382c67f57ab67dd44cabc5c8e673015ddd74b06`: [host and independent worker mutations 41750520306](https://github.com/isomorphisms/fastchat/actions/runs/41750520306), [paired ARM builds and API29/34 UI 41750520443](https://github.com/isomorphisms/fastchat/actions/runs/41750520443). PENDING at this checkpoint.
- IB source `a30381aee243d56d83da19befe64e2f84ebccfc9`: [checked source, APK and API29/34 reader/workbench 41748455979](https://github.com/isomorphisms/ib/actions/runs/41748455979). PENDING at this checkpoint. Browser-foundation progressive-prepaint failure remains separate.
- Exporter source `6c84de4b8c4fe298c2bb61386b7158833249aca4`: [independent read-only archive 41703456445](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41703456445) PASS. Actual compiled role, reversed-path and component-version mutations were rejected. [Android shell 41703456385](https://github.com/dilapidated-shed/ChatGPTExporter/actions/runs/41703456385) PASS is capture-shell evidence, not archive-viewer UI evidence.
- Shared Android source `1f9c30aeb7cc719075ed470b6135c4cc8ce194ca`: [canonical checked DEX/JNI 41690275331](https://github.com/isomorphisms/android-NDK/actions/runs/41690275331) PASS. Consumers retain their own ART gates.

The first new host gate stopped before compilation because renaming the pinned
Grease implementation binary made its applet dispatcher reject the launcher.
That is a launcher failure, not a passing/refusing timeline execution. Source
`b382c67f57ab67dd44cabc5c8e673015ddd74b06` restores the verified executable
entrypoint and reruns the same required oracle; no assertion was weakened.

| Responsibility | Next concrete handoff | Release readiness |
| --- | --- | --- |
| FastChat | Require the new independent host worker mutations and API29/34 two-turn UI exercise at the exact current head; then complete the remaining controller I/O and content presentation work. | NOT_READY |
| IB reader/workbench | Finish the current exact-source reader and separate History/Reader preservation/source-selection observers; diagnose the inherited progressive-prepaint assertion with retained output. Extend actual task/evidence state through its existing owner. | NOT_READY |
| Shared primitives | Resolve checked-export-aliases base topology before integration; keep consumer runtime and accessibility/theme qualification distinct from callback emission. | NOT_READY |
| Idriç | Keep pinned semantic compatibility tests required; introduce a language/backend change only with a reduced actual failing consumer. No new compiler capability is claimed here. | No independent language change proposed |
| Pensieve | Connect the existing S08 Home projection and executor to verified retained source references and native controls, preserving decision IDs and persistence outcome reports. | NOT_READY |
| Longview | Integrate its durable-task host and actual restored inputs with native lifecycle callbacks; qualify durable recovery separately from live page, cookie and form continuity. | NOT_READY |
| ChatGPTExporter | Establish a verified read-only Android archive handoff/viewer using its existing C1 or separately verified V2 authority; keep sending unavailable for imported views. | NOT_READY |
| ai-ci | Retain actual good/mutant executables and source-bound UI receipts; add the remaining long-input, IME, lifecycle, theme and critical UI producer mutations. | NOT_READY |
| Cat Food/device acceptance | Observe each current device independently, verify installed package/version/signer/capacity, deliver the corresponding prebuilt artifact, replacement-install and exercise actual human input. | BLOCKED by live access |
| Android references | Use the pinned APIs and existing renderer baselines only as comparisons; collect matched semantic/hardware measurements before interpreting performance differences. | Reference inspection only |
| climenu | Qualify its command input/runtime bridge before adapting its typed command descriptions to native controls. | Android NOT_RUN |
| az | Preserve its command/TSV, permissions and signer while replacing its first-party Java frontend through the checked native route. | Native migration NOT_RUN |

The inherited live arXiv progressive-prepaint test fails in IB browser-foundation
run [41748456059](https://github.com/isomorphisms/ib/actions/runs/41748456059).
The preceding actual HTML/image acquisition for four papers passed. The silent
progressive-prepaint assertion is unresolved; this is not evidence of network
unavailability and was not waived.

Remaining product work: complete task/evidence/action projection in IB; native
Pensieve/Longview and archive-viewer adapters; fully virtualized conversation
history; Markdown blocks/links; Share; attachments; search; wide layouts;
controller/store/transport I/O migration off the UI ALooper; native font-scale,
theme/contrast, real IME/focus/back and recreation qualification. A bounded
historical worker does not establish a fully nonblocking frontend.

Physical results are individually BLOCKED for MIRO C67 and SVITOO TAB_P10
without a current authenticated channel and fresh target/package observations.
MIRO A1 is NOT_RUN and conditional on a functioning device. No emulator or
ARM32 run on another phone can satisfy those targets. Do not uninstall around
signature/version conflicts; use replacement installation and preserve data.

No matched native/Compose/framebuffer hardware comparison has run. Physical
startup, input latency, stalls, RSS, streaming CPU and thermal behavior are
NOT_RUN. Emulator process/launch metrics, when retained, apply only to their
exact product/observer/device image and are not paired renderer comparisons.

Historical emulator measurements were downloaded and checked from
[API29 artifact 13284887181](https://github.com/isomorphisms/fastchat/actions/runs/41748900342/artifacts/13284887181),
ZIP SHA-256 `54fcc7980cfce32eab99a242ca5b645e5e7b2678326f22c1991d1facad007ea2`.
They bind FastChat `1b2f428c1c0b96da44304f8d2c56caf1eda286e2`, not the later
worker-header/oracle revisions. The downloaded screenshot was inspected;
this is an initial empty phone surface, not visual proof of a long thread.

| Observation, API29 x86_64 emulator | Measured value | Limit |
| --- | --- | --- |
| Cold activity launch, Android `am start -W` TotalTime | 1095 ms | Framework launch timing; not physical input latency |
| Observer launch-to-discoverable composer | 1003 ms | Includes instrumentation/observer overhead |
| Process peak resident set, `/proc/self/status` VmHWM | 180388 kB | Instrumented product process; includes mappings/runtime |
| Process resident set at observation | 142084 kB | Instrumented product process |
| Android process PSS at observation | 30365 KiB | Distinct metric from RSS |
| Cumulative process CPU at observation | 1052 ms | Not streaming CPU percentage or thermal cost |
| Second `am start -W` | Existing Activity received intent; WaitTime 2 ms | Not a measured warm startup; TotalTime 0 must not be marketed as zero launch cost |

The post-instrumentation `dumpsys meminfo` contained "No process found".
Its empty result was not treated as zero memory. Compose baseline source
`c5fc80ea3350186b4af4960de1fb236acdc6b854` has different storage/projection
costs and lacks a matched execution here. The Canvas comparator has no paired
run on this source/hardware. Neither is assigned a performance rank.
