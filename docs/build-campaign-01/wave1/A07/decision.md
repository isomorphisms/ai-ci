# BC-A07 decision — committed execution coverage

Investigated 2026-10-13. Four SUN/Ultra implementation jobs are authored; this domain agent performed no SUN implementation, remote write, dispatch, merge, closure or release. The continuing user task authorizes filing issues and durable campaign documentation. Read-only remote access is this agent's coordination boundary; the parent coordinator publishes these exact packets.

## Decision

Use one ai-ci-owned supported workflow parser behind the existing core predicates and merge checker. Preserve the stronger checkout scoping already merged. Treat lexical restrictions, source eligibility, observed checkout/tree integrity, and executed failure propagation as different assertions. Unsupported YAML or shell semantics must return an explicit non-passing result; they cannot disappear into an empty successful scan.

Do not construct another general YAML policy engine, scheduler, source registry, or arbitrary-shell proof system. Parser semantics are owned by S01; S02 consumes that representation and clarifies lexical/run-evidence claims. S03 implements reusable before/after tracked-source enforcement, preserving existing consumer checks. S04 implements trigger/delegation adoption and comparison-base repair through the same parser.

## Source findings and preserved work

- ai-ci `main` remains `3d174000649f9f828c29e6be981cfd0e60646014`. `merge/check-workflow-head.sh` marks any matching expression inside an active checkout block as exact; comments and incorrectly scoped text are not excluded. `src/aici.c` instead restricts checkout fields to `with:`. This is a verified source divergence, not a newly executed reproduction.
- The core `yaml_run_lacks` uses `yaml_value(content, "run")`, then substring matching. Quoted keys escape that recognition; harmless quoted operator bytes still match. `primary_checkouts_use_ref` overwrites repeated `ref` values and lacks whole-document duplicate/disabled-step validation.
- `yaml_paths` presently compares literal list strings inside canonical `on: EVENT: paths:` structure. It does not demonstrate actual GitHub event execution, a complete dependency inventory, delegated calls, or unfiltered-trigger eligibility. In fact, its final `valid && included` rejects an unfiltered event even though README recommends unfiltered workflows when closure is broad.
- [isomorphisms/ai-ci PR #130, “Reject synthetic PR checkout in workflow integrity”](https://github.com/isomorphisms/ai-ci/pull/130) and [isomorphisms/ai-ci PR #138, “Harden workflow integrity YAML scoping”](https://github.com/isomorphisms/ai-ci/pull/138) are merged. Their retained branches still resolve to their recorded heads `e8c92a7806fd23a3bcdc7a1259f169afa990eeca` and `1202819451af8eec828a50fd9251dd6a71b3ac02`. Preserve those fixes; neither is an advanced unmerged parser replacement.
- Idriç's API identity is `isomorphisms/Idric`, default `Idriç`, head `2734ac5a86610eddfab73b1644d72b4ac85a65ee`; older repository docs name the redirecting `dilapidated-shed/Idric`. All five inspected CI workflows declare exact-head checkout. [isomorphisms/Idric PR #106, “Run Idriç merge checks on exact PR heads”](https://github.com/isomorphisms/Idric/pull/106) is merged and removed `HEAD^1`. Issue 103's original four-checkout defect is repaired.
- The pinned style action `d76e865c3742c51308ddf211ee6f5b724f4104de` chooses the PR base SHA correctly in the ordinary case. It silently replaces an absent/unavailable base with `HEAD^`, so a multi-commit PR can still lose earlier changes. Preserve correct normal behavior and repair that fallback; do not claim the consumer still explicitly requests `HEAD^1`.
- Idriç's `ci-edric-types.yml` filters four path groups but invokes `_/edric all`, whose scope includes nine focused cases and an emitter script, plus compiler/bootstrap inputs outside those groups. Its dedicated type workflow therefore has incomplete eligibility. The unfiltered main build also runs those smoke cases; this is not evidence that all compiler CI is bypassed.
- `xbrl_acceptance.py` already checks tracked cleanliness, exact expected head, and receipt identity in preparation, build stamping, pre-execution and post-execution. Preserve it. ai-ci's merge workflow checks `HEAD` once, while its core action has no general before/after source guard. Snapshot guards do not prove that a program never temporarily rewrote and restored a file.

## Dependency order and boundaries

| Job | Readiness | Boundary |
| --- | --- | --- |
| BC-A07-S01 | SOURCE_READY; execution conditional | Shared parser and compatibility adapters; owns `src/aici.c` parser edits. Qualified P01/P02 tool material must be resolved before compilation. |
| BC-A07-S02 | CONDITIONAL on S01 exact verified result | Lexical diagnostics and actual status-evidence integration; serialize core/contract edits. |
| BC-A07-S03 | SOURCE_READY; execution conditional | Shared tracked-source guard and real workflow integration; preserve XBRL receipt semantics. Qualified runtime material must be resolved before new-helper acceptance. |
| BC-A07-S04 | CONDITIONAL on S01 and S02 exact verified results | Trigger/delegate coverage and Idriç style-range wiring; serialize Idriç edits with S03. |

BC-A04 owns process-result semantics; BC-A06 owns material dependency transition obligations; BC-A02 owns independent oracle semantics; BC-P01 owns compiler qualification; BC-P02 owns executable material closure; BC-T01 owns Ike adoption. A07 consumes their results where needed without defining competing contracts. S03's `.github/workflows/self-test.yml` integration follows T01-S04; the reusable guard can be implemented independently. No qualified compiler/runtime artifact was acquired in this STAR: exact P01/P02 revision, acquisition location and artifact digest are required release evidence, not invented prerequisites. Unavailable qualified tools block execution of that boundary, not writing or reviewable integration work.

## Evidence limit and next actions

This STAR collected live repository source and issue/PR metadata, not current workflow execution or physical evidence. No test result is asserted. S01 and S03 have independent source implementation available after refreshing current source; final execution remains conditional on qualified owner prerequisites. Preserve all FAIL/NOT_RUN/UNKNOWN states. The parent coordinator files updates under existing issues 168, 2 and Idric 103; this agent has not posted them. No exhaustive account-wide CI census or new direct personal-conversation retrieval is claimed.

END OF BC-A07 DECISION
