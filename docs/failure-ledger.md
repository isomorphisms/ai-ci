# Failure ledger

This is a conservative reconstruction from the available conversation context
and repository reconnaissance on 2026-08-24. It is not presented as a verbatim
or exhaustive transcript. Missing history is recorded as missing rather than
filled with a plausible story.

## Reported incident classes

| Failure | What went wrong | Enforcement state |
| --- | --- | --- |
| Invented continuity | Answered as if an unavailable earlier thread or decision had been recovered. | Semantic case planned: incomplete evidence must yield `missing_evidence`; an answerable twin prevents blanket refusal. |
| Confident false completion | Reported work as done from narration or tool activity instead of independently observed state. | Revision, artifact-hash, install/launch, and decode probes are planned. A worker cannot grant its own pass. |
| Narrow green test | Tested a helper or source file while skipping the actual release, composition, install, or render path. | v0 rejects empty suites and missing assertions. End-to-end artifact probes are planned. |
| CI that does not protect its check | Added a check but omitted its files from workflow path filters, or did not invoke it from the workflow. | v0 `workflow-integrity` uses event-scoped path parsing and adversarial comment/action-input fixtures. |
| Swallowed CI failure | Used `continue-on-error`, shell `||`, or `set +e`, allowing a failing check to look green. | v0 blocks these declared forms; future policy will broaden structured workflow validation. |
| Mutable supply-chain reference | Used an action tag instead of a reviewed full commit SHA. | v0 requires 40-hex remote action refs, rejects noncanonical `uses` keys and Docker actions, and allows reviewed local actions. |
| Language/runtime masquerade | Named shell code Grease, invoked `.ysh` through Bash or `sh`, or hid Python behind a nominal Grease command layer. | v0 rejects `.py`/`.sh`, checks every `.ysh` shebang, and requires an exact YSH runner command. A real Grease runtime smoke gate remains blocked upstream. |
| Narrative drift | Script, voiceover input, and captions described different claims. | v0 requires exact canonical text equality and nonempty input. Generated-audio transcription is planned. |
| Weak asset provenance | Accepted a shaped manifest without the named attribution columns or nonempty creator/license/history fields. | v0 checks the exact seven-column header and nonempty fields. License/source verification remains future work. |
| Sidecar-as-artifact | Treated a receipt, manifest, or source declaration as proof that final media was correct. | Video decoding, frame inspection, audio, dimensions, duration, safe-area, and final-hold probes are planned. |
| Build-as-install proof | Treated a produced APK as proof that it installs, launches the intended package, and stays alive. | Android signature/alignment/install/launch/crash probes are planned. |
| Cross-process CI noise | Applied a global fatal-log pattern to every emulator process and blamed the target for an unrelated platform-service crash. | v0 scoped evidence requires an exact target identity, positive target effects, an unrelated-noise passing fixture, and a target-fatal failing fixture. |
| Generic notes substituted for grounded notes | Produced plausible topic prose instead of material tied to the named lecture, transcript, examples, questions, and timestamps. | Grounded semantic review with source citations and an `uncertain` blocking verdict is planned. |
| Explanatory mechanism omitted | Rendered Byrne-style motion without the perpendiculars or other construction that explains the invariant. | A paired semantic/artifact fixture is planned; visual presence alone is insufficient without the explanatory relation. |
| Revision stack damage | Risked mixing unrelated edits, testing the wrong revision, or reporting a branch/base state different from the reviewed PR head. | Exact head/base graph and result-to-SHA binding are planned. Work for this repository is isolated on a topic branch. |
| Non-idempotent generation | Allowed stale or duplicate generated outputs, or failed to remove outputs when an input disappeared. | Run-twice inventory equality and delete-an-input stale-output fixtures are planned. |

## Recovered dated incidents

The second Personal Context pass used broad chronological searches followed by
queries for incidents named in the first results. “Direct” below means a user
message was retrieved or remains in the available recent conversation context;
it does not mean every surrounding turn was recovered.

| Date | Evidence | Incident recovered |
| --- | --- | --- |
| 2026-08-21 | Direct user messages | `learn-toki-pona` had no releases; the supplied APK then “wouldn't install” and Android gave a generic error. Later inspection found `resources.arsc` uncompressed and not four-byte aligned because the build signed without first running `zipalign`. Package/signature checks had not proved installability. |
| 2026-08-21 | Direct user constraint | The user wanted the implementation in Ithon, not Python. This recurred repeatedly over the next three days rather than being a marginal style preference. |
| 2026-08-21 | Direct correction preserved in a screenshot | The assistant mixed up two architectures. Wegert already had a native Android EGL/OpenGL ES renderer and touch loop; analytic continuation should reuse them. A missing Ithon/Manimi bridge was not a blocker for the interactive view, while pre-rendered Manimi movies were a separate guided mode. |
| 2026-08-22 | Direct user message | The assistant proposed an arbitrary degree-seven/eight-degree-of-freedom polynomial model for `analytic-continuation`. The user rejected it because “the whole point … is to get away from polynomials”: the aim was an infinite-dimensional random analytic completion, progressively conditioned by user constraints. A finite series cutoff could be an approximation, not the model's ontology. |
| 2026-08-22 | Direct user message | “You're using bash instead of oil shell or Grease.” The user asked for the Grease source to be placed where required rather than silently substituting another shell. |
| 2026-08-22 | Direct user message | `analytic-continuation` showed a black movie instead of the expected mathematical domain coloring. A green build or release could not establish correct playback or correct rendering semantics. |
| 2026-08-23 | Direct correction sequence | Asked to recover an earlier chat, the assistant first confidently invented an F-Droid task (“fix MR !46503”), then guessed an `archive-org-reading-corpus` workflow. The target was titled “Finalize Internet Archive URL workflow” and concerned the Archive URL workflow on `ithon-rewrite`. This is the clearest recovered example of invented continuity under missing evidence. |
| 2026-08-24 | Direct user messages and external status | The user required CI to inspect actual GitLab MR acceptance/comments and actual F-Droid visibility/version. Wegert PR #20's status job was green while its own output reported fdroiddata MR !46503 open with a failed pipeline, repository/public visibility problems, and package 0.1.100 not visible. Green meant the script ran, not that publication succeeded. |
| 2026-08-24 | Direct user messages | The assistant repeatedly called Manimi “Manim”; the user corrected the project name and then corrected Python to Ithon. Elsewhere the user said to stop using Python and JavaScript, and after a Byrne render asked to verify that no Bash or Python had been introduced. The assistant later admitted `scene.py`, `render.sh`, and CI Bash violations; the nominal replacement had not yet been natively rerendered. |
| 2026-08-24 | Direct recent conversation | The first Byrne III.31 render was good enough to commit as a test, but it omitted the red dotted perpendicular construction. Without those perpendiculars, the moving right-angle invariant was not actually explained. |
| 2026-08-24 | Direct recent conversation | Pearcey corrections included a wrong minus sign, capital `T` instead of the actual changing limits, unnecessary decimal precision, starting too zoomed in, slow step sizes, stopping the cutoff at 3 without mathematical justification, ambiguous natural-caustic versus overlay presentation, and insufficient final hold. The user observed that the picture stabilized around cutoff 3–5 and wanted the pacing adjusted to that fact. |
| 2026-08-24 | Direct recent conversation | Earlier theta video notes were treated as low-quality and unsettled because they were generic rather than grounded in the actual lecture, transcript, examples, questions, and timestamps. The user selected the Mellin direction and then noted that the intended Wegert colors were missing. |
| 2026-08-24 | Direct user messages | For Byrne sources, use the CC BY-SA 4.0 diagrams as starting material with attribution, license link, modification note, and share-alike treatment; do not copy the author's HTML/CSS. For Wikipedia trigonometry assets, preserve the original creator plus meaningful later modification/uploader history rather than crediting only the latest uploader. |
| 2026-08-24 | Direct user messages | The user asked for the assistant-authored video-suggestion notes to be marked with a dunce-cap warning when they were stupid and required smart-mode reconsideration. They also explicitly warned that polished assistant-generated recap prompts must not be counted as independent user complaints. |
| 2026-08-25 | Exact workflow log and repaired run | `utilities-android-phone-user` PR #3 launched the native pad, registered insert/copy/page-change touches, and reached the expected final state, but its smoke test failed on `android.process.media` reporting a locked downloads database. The global fatal-log grep had misattributed another process's crash. Scoping evidence to the pad process made the same behavioral coverage pass; the paired regression now requires unrelated noise to pass and a target fatal to fail. |
| 2026-08-25 | Exact public fdroiddata MR head `d44a624fd` | Wegert fdroiddata MR !46503 contained structurally misindented YAML while the upstream repository's own F-Droid workflow only built Gradle's unsigned release APK. That upstream green build could not establish that `fdroid readmeta`, schema validation, `rewritemeta`, `lint`, the production-like fdroid buildserver, source/APK scanners, or the official fdroiddata pipeline accepted the submission. |

## Leads not yet corroborated by direct user messages

Earlier assistant audits named the items below, but the second context search did
not recover the underlying user turns. They remain search leads, not claims
about what the user said:

- noninteger polynomial coefficients rounded incorrectly in Wegert and
  `analytic-continuation`, reportedly blocking several PRs;
- Ithon PR #2 corrupting `∈` inside strings or compact expressions;
- Game PR #2 scaling held items incorrectly and Game PR #3 fixing a permanent
  package identity before confirmation;
- Keyboard PR #3 describing 13 Regex actions for five keys;
- `az` tests allegedly executing shipped YSH through Bash;
- IB/ibrowser green tests allegedly missing stale-file and reharvest behavior;
- concrete complaint details for Catfood, ICU, AbeBooks price tooling, PDF
  harvesting, Indra's Pearls, and Field Mouse.

These should not become regression fixtures until the original complaint,
repository evidence, or an independently reproduced failure is recovered.

## Research-predicted recurrence risks

These are not asserted as past incidents. They are regression families worth
adding because published evaluations show them repeatedly:

- sycophancy under praise or an incorrect user challenge;
- critical constraints lost when moved into the middle of long context;
- visible-test gaming and hard-coded samples;
- same-model self-review without independent evidence;
- judge position, verbosity, and self-preference bias;
- one lucky successful agent run mistaken for reliability;
- public benchmark memorization or contamination.

## Closure rule

An item is not closed by adding prose to memory. Close it only when there is an
authoritative contract or probe, a positive fixture, a deliberately broken
fixture with the exact expected diagnostic, and CI evidence bound to the
reviewed revision. If judgment remains irreducibly semantic, keep it open and
require grounded evidence plus an explicit `uncertain` outcome.
