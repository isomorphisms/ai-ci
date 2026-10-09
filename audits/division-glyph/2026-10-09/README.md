# Account-wide division migration: source closure and execution evidence

The owned division migration is published for the reconciled account scope.
The current public branch table records 61 migration, design-source, or
toolchain publications across 40 repositories. Every classified maintained
default or active-PR source has a disposition. Hosted checks, complete runtime
closure, signed packaging, physical-device acceptance, and default-branch
merges retain their separate requirements.

Read the current status tables for publication and acceptance. The original
census files preserve what was observed before migration, including their old
`REVIEW_PENDING` labels; those historical labels are not the final source
assessment. Each table identifies its observation scope or exact source head.
Later CI results must be checked against the current PR head.

## Account scope and immutable observations

The authenticated census contains 384 distinct repositories: 6 archived,
19 API-confirmed empty, and 359 nonempty default trees. All nonempty trees
were completely traversed. Large recursive responses were completed with
622 exact child-tree reads, leaving no failed or truncated default-tree
response. The initial trees contain 680,010 tracked blobs.

| Source category | Default-tree paths |
| --- | ---: |
| C and C headers | 187,084 |
| C++ and C++ headers | 17,648 |
| Lua | 417 |
| `.idric` | 236 |
| `.idr` compatibility | 3,827 |
| D | 42,128 |

The initial collection also traversed 71 open PR heads. A later frozen
94-head observation was classified in full, including unchanged inherited
branches. The account listing at 06:37–06:40 UTC on 2026-10-09 queried all
384 repositories and found 95 open PRs. Subsequent publications brought the
known set to 100, all re-read with complete source trees. These observations
are successive exact-head collections rather than one atomic GitHub snapshot.

All 359 default heads remained unchanged across the reconfirmations. An old
PR base SHA is not evidence that its repository default advanced: FastChat's
`ff84af404be34c4a8369de549bf8b32429445c19` default was already present in the
original census. Distinct active variants were migrated on their own branches;
publishing a separate migration PR does not cover an unchanged active variant.
Twenty-one repositories with submodules retain their recorded submodule
identities as separate source and producer boundaries.

The public records contain 374 repository identities, 350 nonempty defaults,
92 frozen PR roles, and 98 current PR rows. Aggregate account counts include
the authenticated nonpublic scope; its identities and source paths are
excluded from this directory.

### Which records answer which question

| Record | Purpose |
| --- | --- |
| [refresh-coverage-public.tsv](refresh-coverage-public.tsv) | Collection times, complete-tree counts, later publications, and explicit refresh limits |
| [default-heads-reconfirmed-public.tsv](default-heads-reconfirmed-public.tsv) | Reconfirmed public default commits |
| [open-pr-source-roles-observed-public.tsv](open-pr-source-roles-observed-public.tsv) | Immutable roles for the 92 public heads in the frozen 94-head observation |
| [active-source-producer-status-public.tsv](active-source-producer-status-public.tsv) | Current observed head, title, source/producer scope, and acceptance boundary for all 98 public active PRs |
| [historical-pending-default-dispositions-public.tsv](historical-pending-default-dispositions-public.tsv) | Explicit current disposition and evidence link for each of the 39 historical public `REVIEW_PENDING` defaults |
| [nonmath-source-ownership-public.tsv](nonmath-source-ownership-public.tsv) | Earlier shell/runtime/compiler and copied-source ownership decisions retained as public evidence |
| [default-role-reconciliation-public.tsv](default-role-reconciliation-public.tsv) | Final dispositions of the late default-branch review gaps |
| [fork-source-closure.tsv](fork-source-closure.tsv) | 1,493 exact blob comparisons and reviewed source roles for IR and jsonlite |
| [sent-reference-blobs-public.tsv](sent-reference-blobs-public.tsv) | Exact upstream identity of all seven sent C/header files and both producer files |
| [compiled-include-roles-public.tsv](compiled-include-roles-public.tsv) | 22 compiled include/definition instances, including the five migrated Young Tableaux test quotients |
| [source-template-roles-public.tsv](source-template-roles-public.tsv) | Four observed C configuration-template instances and their upstream role |
| [language-consumer-publications-public.tsv](language-consumer-publications-public.tsv) | Nineteen language/backend/Android branches with exact source heads and scoped CI observations |
| [native-publications.tsv](native-publications.tsv) | Eight native consumer publications, exact Git trees, and executed evidence |

`repositories-public.tsv`, `default-source-trees-public.tsv`,
`open-prs-observed-public.tsv`, and the original C/Lua/Idriç classification
files remain the historical collection records.

## Source interpretation and closure

The migration covers maintained owned C, Lua, and `.idric` arithmetic, plus
owned generators and the producers that actually compile their output.
Source roles distinguish executable ownership, syntax/compiler controls,
upstream imports, frozen numerical references, design sketches, and
incomplete copied coursework. C++, D, and `.idr` compatibility source retain
their recorded language boundaries.

The initial focused C review read and Git-identity-verified 190 distinct
C/header blobs across 229 instances in 28 profiles. That focused sample was
followed by the complete owned/default and active-variant reconciliation; it
is not presented as coverage of the whole account's 187,084 C/header paths.
The final pass also followed `.inc`, `.def`, source templates, generated C,
symlinks, and copied owned arena code consumed by another repository.

The scanner is the actual Idriç program
[AuditC.idric](../../../examples/autogenerated/division-glyph-migration/AuditC.idric).
It handles C line splicing before token recognition while retaining physical
source locations; binary division, compound assignment, preprocessor tokens,
strings/comments, malformed quoted regions, and trigraphs have separate
results. Lua long-bracket strings/comments and floor division, and Idriç
nested comments, primed identifiers, multiline strings, and inequality have
their own lexical rules. Interpolation is flagged for manual review.
Unsupported extensions, missing arguments, and unreadable files fail.

The scanner's compiled self-tests pass. It reproduces the original 190-blob
C findings exactly. Unsupported include-file suffixes were inspected through
byte-identical, explicitly temporary C audit copies; source files were not
renamed. The temporary Python scanner and tests were removed after their
controls were ported to Idriç, retaining the existing four-file Python
allowlist and checking it before imported compiler source is materialized.

The original Idriç review read all 292 distinct blobs across 701 default/PR
path instances, with no fetch failures; 699 instances are public. All were
also checked for interpolation openers, with none present. Later new and
changed active files were reviewed separately. Arithmetic embedded in C
generator strings was migrated at the generator and downstream C producer.
Coxeter's custom operator and expression are recorded as design source.

### Fork and reference decisions

IR's complete current tree was compared with its exact upstream R base
`3da432e44c5ab99eef6da071183fa0ff315381f1`, accounting for the move under
`code/`. Of 709 C/header/include/grammar paths there, 702 are byte-identical
and seven contain reviewed parser or string changes. All 30 arithmetic
scanner findings in those seven files match the upstream path, source-line
contents, column, and token-kind multiset exactly. The owned changes add
Unicode/parser spellings and adjust `fn` strings; they add no C arithmetic.
The entire 749-path CXXR source subset remains in subtree
`b12c08f052d89467122a0deee381f13609ea4e40`, identical to its declared import.

The jsonlite default `a95c2e5399ab71596be50bf0b1766dc1ae703d5d` is an
ancestor of canonical `jeroen/jsonlite` with the same exact merge base. All
35 current C/header paths are that upstream snapshot. Comparing against the
GitHub fork-network parent had produced a misleading earlier delta count.
Sent's seven C/header files and both producer files likewise match the
declared suckless snapshot exactly. Bioawk's owned motif extension and ICU's
owned transport files contain no arithmetic division; ICU's 1,017 relocated
curl-reference C/header blobs remain byte-identical and excluded from its
declared build.

Actual remaining owned defaults were changed: seven RHS array-size
quotients, fourteen SURFER ray-tracer quotients, eight Jacobian-diagnostic
quotients, three quotients in the unfinished Coursera sketch, and one in
Knot Complement's design comparison. Their role records retain the existing
unfinished/frontend limitations. Frozen ordinary-C comparison programs and
their independent outputs remain unchanged.

## Qualified compiler and runtime boundaries

| Compiler | Exact source used | Published support |
| --- | --- | --- |
| ICK C | `c61e448251744a2f40ad743ebef1a027bdcd2f9d` | Merged [dilapidated-shed/ick #84 — Recognize ÷ division in Icky C](https://github.com/dilapidated-shed/ick/pull/84) |
| Icky Lua | `87306483cec50f8c750a22dda1d0742246fad756` | Merged [isomorphisms/lua #1 — Add symbolic assignment, comparison, and function glyphs](https://github.com/isomorphisms/lua/pull/1) |
| Idriç | `94dfd99bd3e376507fedc8611053b7173b2519f0` | Merged [isomorphisms/Idric #131 — Idriç: admit × and ÷ mathematical operators in .idric](https://github.com/isomorphisms/Idric/pull/131) |

The rebuilt native ICK frontend has SHA-256
`a181082f120a906c86ebd8c7a2378bcc83d9694a8c533438536768f180ad1b17`.
The native runtime is the declared GCC 13 startup/libgcc and glibc/libm
substrate. Static executable qualification also includes the actual
`crtbeginT.o` and unwind runtime. Bootstrap compilation and the compiler
that parses owned consumer C are recorded separately.

The rebuilt Idriç payload has SHA-256
`4864ed84e76332e6bc295d158524fa113e8b6e078aa6b9f586bdd9e7e06210ab`.
It compiles and executes the scanner and migrated benchmark; benchmark
stdout remains exactly `40` followed by `17280`. The compiler and language
backend records state their actual supported API/bootstrap boundary.
The shader backend's full local suite uses its supported official Idris2
v0.8.0 bootstrap and matching API. It does not use current Idriç as an API
substitute; its official compiler/API hosted build has passed separately.

[isomorphisms/ai-ci #231 — Guard owned C and qualify pinned ICK native and Android producers](https://github.com/isomorphisms/ai-ci/pull/231)
qualifies native and all three Android compiler stages. Android keeps the
actual NDK headers, API-floor macros, ABI options, warnings, optimization,
debug settings, stack protection, and existing Fortify level. Owned C goes
through ICK to assembly; the NDK retains assembly, platform glue, and linkage.
The ARM A32/Thumb, floating-point, and AArch64 x18 choices follow each
consumer's original producer rather than one substituted fleet profile.

The bounded GNU-inline Fortify adapter calls the actual Bionic checking
entrypoints. Its qualifier checks 22 ordinary and side-effect overflow cases
at O1, O2, O3, and Os, rejects 37 unsupported call families, exercises API-floor
and bypass controls, and compiles/links atomics. Valid and failing fortified
calls execute against actual x86-64 static Bionic. Consumer builds and
application runtime gates remain additional evidence.

Real x86-64 Android emulator execution exposed a separate loader problem:
GCC PIE source generation emitted a COPY relocation for `stderr`. The
affected executable producers now generate PIC and still link PIE. Shared
qualification references `stdin`, `stdout`, and `stderr`, rejects COPY
relocations in actual ELF output, and retains an old-PIE negative that emits
the rejected relocation. The native-boundary producer additionally rejects
text relocations before packaging. Both original Android page-size emulator
gates remain required.

## Executed consumer evidence

The current branch table records every separate maintained variant, including
all six FastChat branches, all three Seifert and Wegert variants, both Young
Tableaux and keyboard variants, all three Android-NDK branches, both Reddit
backend branches, and the eight ai-ci branches. Normal active-branch base
integrations retain their feature work and existing draft status.

| Consumer group | Executed evidence retained |
| --- | --- |
| Native models | Sprott's 73,728 reference steps and trajectory checks; Le Petit Prince's 65,536 turn/walk pairs; all 16,777,216 compact direction codes with sampled/extreme inputs; C examples' fixed output; Ike's canonical suite and 26 parser executions |
| Fourier | All 13 native programs; all five Android libraries across three ABIs; both specialized ARM voice routes; Cortex-A7/A15 numerical execution; all seven checks green at the recorded current head |
| Indra's Pearls | 431 math/core/trace assertions; complete three-ABI libraries and the specialized ARM application/API21 probe; original raster and trace-control emulator gates retained |
| Mostow | Original host suite; eight-stage fixture regeneration and two actual GLES framebuffers byte-identical to the originals; both real r29/API21 libraries; both signed APKs and the actual Flexible Pipes producer gate under the merged signer policy |
| Young Tableaux | 107 migrated quotients including the five directly included test expressions; 9,938 native checks, 106,628 consolidation checks, 171,228 independent audit cases, eight mutants, and renderer/visual controls; actual Android libraries |
| Idriç and generators | Theta's generated browser output and Pauli's full image byte-identical; Field Mouse runtime, negative, differential, CLI, and install checks; Seifert semantic groups and host geometry; Hopf actual generation and downstream C compilation |
| Shader and native media | Full shader semantic/mock/negative suite, actual Mesa shader/framebuffer execution, and Android runner link; Spinor frame/trajectory parity and the complete 240-frame movie on its recorded earlier source-equivalent head |
| LÖVE game | Two divisions compiled through the glyph-capable LuaJIT lexer; bytecode equality; FR1/FR2 compatibility controls; execution against the actual checked-in Android runtime archives and stock LÖVE 11.5 draw path; debug/release APK CI |
| RP2040 keyboard | Actual bare-metal ICK bootstrap, installed compiler, and all eight UF2 outputs on the qualified migration branch; active variant integration preserves its engineering records |
| FastChat and quiz session | Actual owned-C host/Android stages; original exact old Icky Lua compiler, linked-runtime checks, and stock-runtime counterfactual retained independently; three-ABI platform stages for the quiz application |
| Smaller native defaults | RHS expected bytes unchanged; SURFER original optimized and sanitizer checks; complete 14×26 Jacobian report byte-identical with its exact numeric-header input |

The LÖVE result uses its actual application runtimes. A standalone run with
another Lua executable would not establish that boundary. Similarly, the
quiz-session and FastChat consumers retain the exact older Icky Lua gate
separately from the current owned-C compiler. A missing qualified session or
runtime receipt remains a real packaging boundary.
At Toki Pona head `bbb708b90effca5c296f5fa93bdba797bb1be566`, all three
platform producer jobs and the original exact session-host gate pass. Both
actual APK and AAB jobs then fail the unchanged closure check:
`Missing qualified ICK session object closure for arm64-v8a: quiz_session.o`.
The missing qualified object and receipt are not replaced by a platform-C
compile result, and emulator acceptance remains unestablished.

### The audit and compiler repositories are also consumers

The ai-ci consumer migration includes 36 divisions in twelve verifier/fixture
files and three in the native-boundary probe, plus the Idriç benchmark
quotient. The migration is integrated into all eight relevant active branches.
The shared compiler branch also migrates its C assignment guard's two
array-size quotients; its original exact-inventory and negative tests pass.
Deliberate compiler compatibility divisions and assignment-scanner fixtures
remain explicit controls.

The twelve verifier programs compile with actual ICK. Executed evidence
covers 14 compatibility cases, 12 Soil cases, six build-preflight cases,
canonical Ike receipt/follower tests, nine real-video cases, all 45 F-Droid
receipt cases and producer tests, and ingestion corpus/receipt comparison.
Hosted HTTP/provider and platform execution remain part of their workflows.

The native-boundary suite retains exact NDK r27d/API24, both offset variants,
strict C17 warnings, RELRO/NOW, ELF alignment/dependency checks, and both
4 KiB and 16 KiB emulator page-size lanes. Its 34 host cases, 34 targeted
semantic rejections, and four damaged-bundle controls remain intact.
Actual Android execution is checked independently of host execution and
the shared API26 compiler qualifier.

## Reading the remaining acceptance boundaries

Every current source row has a final ownership/migration role. Successful
local compilation, a source-equivalent predecessor run, and a green
current-head hosted run are different observations and are labeled separately.
Queued/running workflows remain pending; an `action_required` workflow
requires GitHub approval. The current Reddit bibliography branch retains
that external approval condition after its bot-only bibliography update.

Knot Complement's design still contains pre-existing unsupported operators,
and the Coursera sorting sketch remains incomplete. They have source
migration evidence and their original comparison boundaries, without a
new claim that the unfinished implementation runs. SURFER's hosted leak
check retains its original setting despite the local environment's
LeakSanitizer inspection restriction. Existing quiz runtime closure, package
identity, signer, emulator, release, and physical-device gates are preserved.

Binary `÷` keeps the original operand types, precedence, and integer/floating
division behavior. Compound C updates were expanded only after reviewing
their simple, side-effect-free lvalues. Lua `//`, Idriç `/=` inequality,
paths/URLs, and unchanged upstream/reference source retain their original
meaning. Source publication does not grant a new device acceptance receipt
or authorize merging a consumer PR or issuing a release.
