# Fresh-chat command boundary

Every evaluation sample receives the literal UTF-8 prompt on stdin. A successful chat command writes only UTF-8 answer text to stdout and exits 0. Diagnostics go to stderr. A nonzero exit means that no answer exists and must not be classified.

Each invocation starts fresh: it receives no conversation identifier, previous response identifier, memory, or prior turn. Provider-specific implementation remains replaceable.

The surrounding raw receipt records executable revision, provider/model, sampling and retrieval configuration, Blackball ref, timestamps, stdout, stderr, and exit status. It must not infer retrieval from the presence of a URL.

## Paired protocol

Ask the same literal question under two conditions: the question alone, and only `https://github.com/bl4ckb4ll/blackball` prepended to that exact question. Repeat trials, alternate order where possible, preserve failures, and retain raw outputs before classification. A frozen-context experiment is a distinct intervention and must keep a distinct condition name.

## Fixture and result boundary

`mocks/cases.jsonl` contains synthetic baseline/conditioned answers and expected verdicts. Fixture identifiers do not become a second result vocabulary. `verdicts.tsv` owns classification; substantive effect, evidence status, and run status remain separate dimensions.

## Implementation status

This directory defines the contract and fixture oracle. It does not provide a qualified client or runnable A/B evaluator. The older Python/YSH implementations were removed during reconciliation with current shared language policy. Real-provider execution needs a separately qualified adapter at this same boundary and a real endpoint receipt; synthetic fixtures cannot supply that evidence.

## Unqualified Grease adapter

`openai_chat_cli.grease` and `live_chat_smoke.grease` remain an unqualified
real-provider adapter. Invoke them through `grease` bound to the current
`dilapidated-shed/grease` source gitlink; an arbitrary `osh`, Bash, or
different Oils revision is not a Grease execution receipt.

The original selected default model remains `gpt-5.6-sol`; `OPENAI_MODEL`
may select an explicitly authorized alternative. Model/account availability
has not been verified. The client sends `store:false`, no conversation or
previous-response identifier, and the current Responses `web_search` tool
when retrieval is enabled. Tool availability does not prove retrieval occurred.
See the [official web-search request contract](https://developers.openai.com/api/docs/guides/tools-web-search).

The smoke compares the actual stdout file with the one byte `4`, so trailing
newlines or extra text cannot become a false PASS through command substitution.
Transport, incomplete responses and empty answer text fail.

The remaining acceptance dependency is a receipt executing these exact scripts
on the verified current Grease implementation, followed by a real Responses
endpoint run using an environment-provided authorized key and selected model.
The present workspace has no `grease` executable. No key availability check or
secret read was performed, and no synthetic response can satisfy this live gate.
Keep the PR open until that receipt exists.
