# Blackball response-comparison evaluation

This directory contains deterministic fixtures and plumbing for comparing the same question with and without Blackball context. The fixtures are synthetic; they are not evidence about live model behavior.

## One verdict vocabulary

`verdicts.tsv` is the authoritative result vocabulary:

- `improved`
- `no_appreciable_difference`
- `mixed`
- `worse`
- `unsupported_pessimism`
- `failure`
- `unknown`

`mocks/cases.jsonl` uses the development fixture IDs `positive`, `negative`, `mixed`, `terrible`, `conspiratorial`, `failure`, and `unknown`. Those names select fixtures only. They are not a second `result_kind` vocabulary.

The fixture mapping is explicit:

- `positive` -> `improved`
- `negative` -> `no_appreciable_difference`
- `mixed` -> `mixed`
- `terrible` -> `worse`
- `conspiratorial` -> `unsupported_pessimism`
- `failure` -> `failure`
- `unknown` -> `unknown`

There is therefore no separate `in_between` result. The mixed case is represented by the canonical `mixed` verdict.

## Orthogonal result dimensions

Each fixture also records three diagnostic dimensions. They supplement the verdict rather than rename it:

- `substantive_effect` — what kind of response change was observed;
- `evidence_status` — whether the claims or reasoning introduced by the Blackball-conditioned answer that matter to the classification are supported, unsupported, mixed, insufficient, or not evaluated;
- `run_status` — whether the comparison completed or failed operationally.

`evidence_status` is not evaluator confidence. In particular, a response can improve one part of the decision while adding unsupported claims elsewhere; the `mixed` fixture records that distinction rather than calling the whole result supported.

`failure` and `unknown` remain different. `failure` means a required generation, transport, retrieval, parsing, or other stage did not complete. `unknown` means completed outputs exist but do not justify a reliable classification. Neither may silently become `no_appreciable_difference`.

`unsupported_pessimism` is also distinct from ordinary `worse`: it targets the specific false positive where Blackball makes an answer gloomier or more suspicious without earning that change through evidence, argument, or logic.

## Execution boundary

The synthetic fixture source is `mocks/cases.jsonl`. It records expected distinctions; it is not a live provider, measured model result, or runnable A/B evaluator.

`CLI.md` specifies the provider-neutral fresh-chat boundary and raw receipt requirements. No Python or YSH client, mock server, or runner is bundled here. A future implementation must use the current checked Idriç/Ithon/Grease and build-toolchain policies; failed generation still means that no answer exists.
