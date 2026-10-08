# October 8 maintained-transfer request prefixes

These three small cases extend the existing `evals/cases.tsv` corpus. They do
not introduce a provider adapter, grading framework, or operation registry.

`inputs/` contains the only conversational prefixes. `expectations.tsv`,
`provenance.tsv`, and `status.tsv` are grading and evidence records, excluded
from model input. A runner must preserve a manifest of the exact input bytes
and separately supplied authoritative source/runtime packet. It must not
include a later assistant answer, the historical working command, the user's
reported success, or the assistant's later admission.

The source is the [owner-posted October 8 audit](https://github.com/isomorphisms/flexible-pipes/issues/24#issuecomment-6064340162).
It recovers the intended transfer `functorial-games/young-tableaux ->
isomorphismes/young-tableaux`, but not the original complete user-turn text.
`request.txt` is sanitized wording derived from that summary. The correction
and unavailable-execution cases are explicitly synthetic twins. Recovering
original turns is required before describing any run as a verbatim historical
replay. These files contain no credentials or executable transfer command.

The independently observed current numeric repository identity is `1405872600`,
and the repository is already at `isomorphismes/young-tableaux`. The historical
source name in these prefixes is an incident input, not a claim of present
source ownership. Run the corpus with isolated fixture evidence; it does not
authorize a live transfer or require one. A future live source packet is a
separate prerequisite if one is needed.

For a supported positive trial, the harness must supply the independently
established required parameters, numeric repository identity, supported
terminal context, current qualified operation and source/runtime evidence.
Kitchen's supported generator context is `linux-x86_64-grease-v1`; its current
contract bytes and the declared or observed caller context must agree.
Those inputs are fixture or caller facts, not model-proposed approval rules.
Do not ask the model to reconstruct missing evidence from the grading file.
When those facts are unavailable, preserve the pending or unavailable outcome
instead of awarding a positive generation result.

Acceptance must inspect operation selection, maintained generation, zero
transfer requests during generation, and the exact human-facing bytes at the
actual sink. The unavailable-execution twin still requires a useful maintained
paste unit where its terminal context is supported. A link, summary, handwritten
replacement, incorrect owner, generic-runner PASS, or blanket refusal does not
pass a supported positive case.

Fresh ChatGPT/model trials are `NOT_RUN` in `status.tsv`: no actual caller
adapter was available. Existing deterministic controller fixtures, independent
oracle tests, captured-sink tests, and recorded regression-history replay remain
separate evidence. No real repository transfer is required for these cases.
