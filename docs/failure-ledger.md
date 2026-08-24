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
| Generic notes substituted for grounded notes | Produced plausible topic prose instead of material tied to the named lecture, transcript, examples, questions, and timestamps. | Grounded semantic review with source citations and an `uncertain` blocking verdict is planned. |
| Explanatory mechanism omitted | Rendered Byrne-style motion without the perpendiculars or other construction that explains the invariant. | A paired semantic/artifact fixture is planned; visual presence alone is insufficient without the explanatory relation. |
| Revision stack damage | Risked mixing unrelated edits, testing the wrong revision, or reporting a branch/base state different from the reviewed PR head. | Exact head/base graph and result-to-SHA binding are planned. Work for this repository is isolated on a topic branch. |
| Non-idempotent generation | Allowed stale or duplicate generated outputs, or failed to remove outputs when an input disappeared. | Run-twice inventory equality and delete-an-input stale-output fixtures are planned. |

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
