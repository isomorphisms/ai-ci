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

## One fixture source, two boundary mocks

`mocks/cases.jsonl` is the single fixture source for both mock surfaces:

- `mock_chat_cli.py` implements the provider-neutral stdin/stdout/stderr/exit-status boundary used by the evaluator;
- `mock_openai_responses.py` exposes the same fixtures through a local OpenAI Responses-shaped HTTP endpoint for testing an API client or parser.

Those are different boundaries, not competing providers. There is deliberately no additional CLI/provider fake with a second fixture table.

The process boundary is documented in `CLI.md`. A nonzero exit means no answer exists and must not be classified. The HTTP mock preserves the same rule by returning an error instead of manufacturing an answer.

## Literal A/B runner

`run_cli_ab.py` invokes any client once for the literal question and once for the same question with only `https://github.com/bl4ckb4ll/blackball` prepended. Across repeated trials it alternates order and preserves the exact prompt, stdout, stderr, exit status, timestamps, and whether an answer exists.

The initial positive BME fixture checks the intended decision behavior: surface the high-debt employment risk before merely matching interests to a major, ask for program-specific bachelor’s outcomes, compare alternative engineering routes, and require evidence for implied as well as explicit institutional career claims without inventing accusations.
