# I-MATH-01 — execution checkpoint, 8 October 2026

Work item: [isomorphisms/ai-ci #232 — STAR I-MATH-01: prepare all isomorphismes math repos, sources, Idriç kernels and builds](https://github.com/isomorphisms/ai-ci/issues/232).
The user explicitly requested execution here. This is a dated evidence
snapshot, not a second live PR queue. Refresh mutable GitHub state before use.

## Complete scope and preparation result

All **49** repositories returned by the final live `isomorphismes` inventory are
accounted for: **18 READY**, **15 BLOCKED**, **16 NO_ACTION_WITH_REASON**.
The initial response contained 43; the closing refresh returned six additional
identities. [scope-refresh.md](scope-refresh.md) records their actual existing
history and dispositions; they are not assumed to have been newly created.
READY means a bounded next mathematical or qualification task is ready; it does
not mean every application is buildable, installed, or accepted.

- [inventory.tsv](inventory.tsv): default branch/SHA, Idriç and literature
  locations, open PR identities, test-path counts, build-contract presence,
  latest observed workflow and per-repository disposition.
- [dispositions.tsv](dispositions.tsv): recovered intent, mathematical boundary,
  implementation status and cheapest next action for every repository.
- [branches.tsv](branches.tsv): all **412** observed branch heads.
- [closed-pulls.tsv](closed-pulls.tsv): all **272** observed closed PRs, preserving
  merged versus closed-unmerged status and dependent bases.
- [open-items.tsv](open-items.tsv): current issue/PR titles and source links.
- [recent-workflows.tsv](recent-workflows.tsv): **138** runs, at most the five
  most recent per repository. This is explicitly not an exhaustive Actions log.
- [sources.md](sources.md): source rights, acquired literature, and concrete
  theorem/definition-to-fixture mappings.
- [next-jobs.md](next-jobs.md): five bounded Sun investigations, each responsible
  for an exact Earth/Moon handoff after resolving its named uncertainty.

Initial observation window: 8 October 2026, approximately 16:00–16:45 UTC;
closing scope refresh and six-repository inspection: approximately 17:05–17:08 UTC. Repository
and branch collections fit in one 100-item page per requested scope; no
recursive tree was truncated. The face and voice repositories are empty,
not fetch failures masquerading as empty implementations. Default-source
columns are qualified explicitly: absence there does not imply absence on
the 412 historical/working branches. The two executed leaves are updated
below; other snapshot heads remain the initial reconnaissance heads.

## Executed Seifert work

The README conflict in the existing ribbon parent was repaired, preserving
both the corrected L-layout description and the already merged bibliography.
The published parent `aabe1917ba1bf624ddc102444a71909b5c15aa78` has the exact
reviewed tree `65a78f4c8b4f42730290b5d4d10fdfcaf24f77c5`. GitHub subsequently
reported that parent mergeable/clean. No renderer, geometry, or interaction
redesign was introduced.

The source-style child follows that parent at application-source checkpoint
`68b41ba7b4624610813429102ebb8f404426b075`; its reviewed tree is
`03a46af9401f4b3b58459ab1cc922b2caaad576e`. Local geometry and gesture tests
pass with an explicitly selected ICK scalar compiler. Its adapter suite and
343-state comparison with immutable v0.2 geometry pass. The existing NDK
syntax-normalization boundary is retained and identified as such.

Both versionCode 2, DEX-free, NativeActivity APKs were built and signed through
the canonical NDK packager. Real Flexible Pipes preflights fail closed because
the merged policy does not register the Seifert test package. The minimal
dependency is [isomorphisms/ai-ci #236 — Register Seifert's stable public test Android signer](https://github.com/isomorphisms/ai-ci/pull/236).
Candidate-registry positive and negative checks pass; this does not substitute
for the merged-policy gate. The final candidates and raw failed gate receipts
belong to the existing source-style PR.

The Idriç child was repaired and checked with current compiler source
`ff4d852862a3942592f8ade9afde8d409d9803be`. Seventeen executed host check
groups cover signed unwrapped turns, exact conditional genus/linking arithmetic,
missing geometric prerequisites, nonfinite values and overflow. The inherited
binary64 prototype is named explicitly, no longer shadowing `Number`. This
does not qualify Float16/Float32 target lowering or integrate an Android HUD.

Existing review surfaces:

- [isomorphismes/seifert #1 — Three orthant blocks, attached L-shaped ribbons and broader sticky touch](https://github.com/isomorphismes/seifert/pull/1)
- [isomorphismes/seifert #2 — Source-style pass: compositional ICKY C and explicit compiler boundary](https://github.com/isomorphismes/seifert/pull/2)
- [isomorphismes/seifert #5 — Define Idriç arithmetic-topology readouts and fail-closed invariants](https://github.com/isomorphismes/seifert/pull/5)

## Executed Mostow work

[isomorphismes/mostow #1 — Living hyperbolic sheet with bounded motion and paired Android builds](https://github.com/isomorphismes/mostow/pull/1)
retains the implementation and the exact APKs built from application source
`12aa1481bad53334e1506435f8bf8c71060960c4`.

PASS in this execution: strict host mathematics through the declared ICK
compiler; deterministic fixture regeneration with unchanged bytes; mode-box
corners; 1,000 emitted-float poses; invalid input and stretched-mutant rejection;
unit-normal checks; analytic all-time local metric bounds; and the actual shared
GLES renderer in Mesa llvmpipe. The all-time singular-value interval is
approximately `[0.95905332138, 1.04170826899]`, inside `[1/1.10, 1.10]`.

Both retained APKs now pass the **actual** canonical Flexible Pipes producer
against merged ai-ci policy `01608a2493fa409463f70e8fbfd8a123ef59ee85`.
The previous missing signer registration is no longer the blocker. Each
producer receipt binds package, version, signer, ABI and APK digest. The
fixture, shaders, geometry and visible choices were preserved. Test runners
now require an explicit host compiler instead of silently invoking `cc`.

## Toolchain and acceptance boundaries

| Owner/input | Observed identity or boundary |
| --- | --- |
| Cat Food | `609a9628d5a52860f956bf62e0914a0cd03292ae`; MIRO_A1/armeabi-v7a primary; MIRO_C67/arm64-v8a paired |
| Flexible Pipes | `9775aa324f523cbc6c758e89461915484a5a0fc7`; existing `android-apk-preflight` pipeline actually executed |
| ai-ci producer | merged `01608a2493fa409463f70e8fbfd8a123ef59ee85` |
| Canonical android-NDK packager | merged `7c61ee43e75f7c2dab9288edb0e10055898b36e6` |
| Seifert Android compilation | NDK 27.2.12479018, API 21; first-party warnings are errors |
| Retained Mostow compilation | historical NDK 29.0.14206865, API 21; no unnecessary rebuild asserted |
| Android verification tools | build-tools 35.0.0, archive verified against official repository metadata |
| ICK scalar host compiler | driver SHA-256 `acde6cf158c527a415105cd692796c3c998a636f6887ab0d30262773e3611e91`; cc1 `4fbf0c20391dc3e46d0840df795ebbc7e9b878d54858f6e0006f143501feb08c` |
| Explicit host runtime | libatomic archive `ea5855f573bce90a1dad67d29929dd165e547f2300fc2b2e661851c913cdaed3`; no clean-source rebuild or complex-runtime claim |
| Grease execution | existing runtime digest `7e31cd05b7a9d8fb2a4a9e003a7f3fcb0159138506d17f0fb28da8cbe22aa85c`; ASan leak detection disabled for traced host, no leak PASS |
| Idriç | clean source at `ff4d852862a3942592f8ade9afde8d409d9803be`; built C/Chez support and current compiler; host checks only |

The ordinary Idriç bootstrap first failed because inherited support targets
attempted RefC/GMP. No GMP or RefC fallback was installed. Existing C/Chez
support and compiler/library targets supplied a working current compiler.
This build-system defect remains distinct from the now-passing Seifert modules.

Physical installation, replacement update, launch, lifecycle, sustained timing,
touch and actual phone GPU acceptance are **NOT_RUN** for both applications.
No phone was used for compilation. No PR was merged and no release was made.
Old green workflows are reported as observed history, not as proof of ICK,
direct Idriç lowering, producer acceptance or current physical behavior.

Remaining CI work: Seifert's inherited workflows use generic host `cc`, mutable
action tags and do not execute the new readout runner; Mostow has no required
workflow. The explicit local receipts are the evidence for this pass. A later
CI change must provision the named compiler/Grease runtime, pin exact heads,
and cover every material source path without promoting an unavailable tool to
PASS. These PRs are not described as ready for automatic merge.

## Final publication verification

Published application qualification trees were fetched and compared with the
reviewed local trees: Mostow `5c5d9b612e909efebbd735ad66eddfbbdbd64244`,
Seifert source-style/evidence `420630cbcbf26925f1c73c2f936b2cc56a039195`, and
Seifert Idriç `fd718e5de9b3a579338098c387ecaccc9fc16f19`; every comparison
was identical. The ribbon parent has three passing hosted checks; the final
source-style head has all three passing; the Idriç head has the inherited
geometry check passing. These hosted results retain the compiler/coverage
limits above. Mostow has no hosted checks.

The unmerged Seifert signer-registration head
`20f9d3f4a4ee13dc552135c35f459059d40680fe` has 31 passing checks. It remains a
candidate policy, so Seifert's merged-policy producer disposition is still
BLOCKED. The original 43-repository ledger head
`558a7a670d5e80b8032816b90ffed1b9544f70ae` has 30 passing checks; later scope
updates must be checked at their own heads.
