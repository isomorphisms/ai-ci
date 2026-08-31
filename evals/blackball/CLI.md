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

## Mock command

`mock_chat_cli.py` implements this boundary directly from the synthetic cases.

Example:

```text
AICI_BLACKBALL_MOCK_ID=positive \
AICI_BLACKBALL_MOCK_PHASE=baseline \
python3 evals/blackball/mock_chat_cli.py < prompt.txt
```

Mock-only environment variables are deliberately out-of-band. A real API command does not need them and does not need to mimic the mock's implementation.

The three mock phases are:

- `baseline` — return the fixed unconditioned answer;
- `blackball` — return the fixed Blackball-conditioned answer, or a synthetic process failure;
- `judge` — return the fixed JSON comparison judgment.

A successful mock judgment uses `classification` for the canonical verdict from `verdicts.tsv` and separately reports `substantive_effect`, `evidence_status`, and `run_status`. The fixture ID is not a result kind.

The evaluator-facing command boundary itself remains only stdin/stdout/stderr/exit status.

## First real-provider adapter

`openai_responses_cli.py MODEL` is the smallest live OpenAI Responses API adapter for this boundary. It uses only the Python standard library, reads `OPENAI_API_KEY` from the environment, sends one fresh `POST /v1/responses` request with `store: false`, and writes only completed assistant text to stdout.

HTTP errors, transport failures, incomplete responses, malformed JSON, and completed responses with no output text all produce a diagnostic on stderr and a nonzero exit. They therefore remain operational failures rather than becoming answer text.

For the single genuine smoke prompt, run the Grease/YSH script with `OPENAI_API_KEY` already exported:

```text
ysh evals/blackball/live_openai_smoke.ysh
```

It sends `Reply with exactly: live provider reached` to `gpt-5.6-luna`. A successful run prints the provider's answer on stdout. The script is intentionally only a smoke probe; the paired evaluator still owns baseline/Blackball receipts and verdict handling.

To substitute the real adapter into the paired runner, use the same command boundary:

```text
python3 evals/blackball/run_cli_ab.py --client python3 --client-arg evals/blackball/openai_responses_cli.py --client-arg gpt-5.6-luna --question 'YOUR QUESTION'
```

`run_cli_ab.py` records the client and its model argument in `run.json`, along with the exact prompts, stdout, stderr, timestamps, exit status, and whether an answer exists for each trial.

`AICI_OPENAI_BASE_URL` exists only so acceptance tests can point this same adapter at the repository's local Responses-shaped HTTP mock. Normal live use leaves it unset and therefore uses `https://api.openai.com/v1`.

## Replacement rule

A different real provider should substitute its own tiny adapter at this process boundary rather than rewrite the evaluation logic. If its native user interface is richer, normalize it to stdin/stdout/stderr/exit status; keep provider-specific metadata in the surrounding evidence receipt rather than answer stdout.
