# Fresh-chat command boundary

The Blackball evaluator does not depend on the eventual API client's internal implementation or command name.

Its minimal process contract is:

```text
UTF-8 prompt on stdin
        |
        v
   chat command
        |
        +--> UTF-8 answer text on stdout, exit 0
        |
        `--> diagnostic on stderr, nonzero exit: no answer exists
```

The evaluator must not classify stderr text or a nonzero process as an LLM answer.

No conversation identifier, prior response identifier, memory state, or previous turn is passed through this boundary. A real implementation can therefore issue a fresh request for every invocation.

Metadata needed for reproducibility belongs in the surrounding run receipt rather than mixed into answer stdout. That includes the executable revision, model name, provider, sampling settings, tool/retrieval configuration, Blackball ref, timestamp, and exit status.

## Live smoke test

`live_chat_smoke.grease` is the minimal real-client smoke test for this boundary. It sends one fresh prompt asking for the exact answer `4`, requires exit status 0, and requires stdout to contain exactly `4` apart from trailing newlines removed by command substitution.

Run it with the Grease-enabled OSH interpreter and the client command to test:

```text
osh evals/blackball/live_chat_smoke.grease ./openai_chat_cli
```

Additional client arguments may follow the client executable. On success the test prints:

```text
PASS live_chat_smoke
```

There is no fallback to a mock. A missing client, transport/API failure, or wrong answer is a failure. This smoke test establishes only that a real client can complete one fresh generation and honor the stdin/stdout/exit-status boundary; it does not establish Blackball retrieval quality or an A/B model effect.

## Mock command

`mock_chat_cli.py` implements this boundary directly from the synthetic cases.

Example:

```text
AICI_BLACKBALL_MOCK_ID=positive \
AICI_BLACKBALL_MOCK_PHASE=baseline \
python3 evals/blackball/mock_chat_cli.py < prompt.txt
```

Mock-only environment variables are deliberately out-of-band. The eventual real API command does not need them and does not need to mimic the mock's implementation.

The three mock phases are:

- `baseline` — return the fixed unconditioned answer;
- `blackball` — return the fixed Blackball-conditioned answer, or a synthetic process failure;
- `judge` — return the fixed JSON comparison judgment.

A successful mock judgment uses `classification` for the canonical verdict from `verdicts.tsv` and separately reports `substantive_effect`, `evidence_status`, and `run_status`. The fixture ID is not a result kind.

The evaluator-facing command boundary itself remains only stdin/stdout/stderr/exit status.

## Replacement rule

When the real ICU/API client lands, the suite should substitute that executable at the command boundary rather than rewrite the evaluation logic. If its native user interface is richer, a tiny adapter may normalize it to this boundary; the evidence receipt should identify that adapter explicitly.
