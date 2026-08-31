# Blackball response-comparison mocks

This directory supplies deterministic fixtures for the Blackball before/after evaluation pipeline.

The mocks are not claims about real model behavior. They let the client, storage, parser, and comparison layers run before spending API calls or relying on stochastic model output.

## Verdicts

The authoritative labels are in `verdicts.tsv`.

Five labels compare two completed answers:

- `improved`
- `no_appreciable_difference`
- `mixed`
- `worse`
- `unsupported_pessimism`

Two labels are non-comparative terminal states:

- `failure` — a required stage did not complete;
- `unknown` — outputs exist but cannot be classified reliably.

`failure` and `unknown` must never be collapsed. A network or parser failure says nothing about whether Blackball improved the answer.

`unsupported_pessimism` is intentionally distinct from `worse`: it catches the specific false-positive failure where adding Blackball makes a model gloomier or more suspicious without earning that shift through evidence, argument, or logic.

## Initial synthetic cases

`mocks/cases.jsonl` contains seven fixed cases named after the development shorthand:

- `positive` -> `improved`
- `negative` -> `no_appreciable_difference`
- `mixed` -> `mixed`
- `terrible` -> `worse`
- `conspiratorial` -> `unsupported_pessimism`
- `failure` -> `failure`
- `unknown` -> `unknown`

The positive fixture specifically checks the intended college behavior: catch the high-debt BME employment trap before merely matching interests to a major, distinguish occupational marketing from program-specific bachelor’s outcomes, compare alternative engineering routes, and require institutions to substantiate implied as well as explicit career claims.

## Local OpenAI-shaped mock endpoint

Run:

```text
python3 mock_openai_responses.py --port 8787
```

Then POST an OpenAI Responses-style request to `/v1/responses` whose `input` is:

```text
aici-blackball-mock positive baseline
```

The final word can be `baseline`, `blackball`, or `judge`. For example, `positive judge` returns a response whose output text is a JSON object containing the expected classification.

The `failure blackball` request deliberately returns HTTP 503.

This endpoint is a transport/parser fixture only. It does not pretend to reproduce OpenAI model behavior.
