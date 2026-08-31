# Fresh-chat command boundary

The Blackball evaluator does not depend on the API client's internal implementation or command name.

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

## Live ICU command

The first real implementation is being built in `dilapidated-shed/icu#12` as:

```text
icu openai
```

It implements this boundary directly: complete prompt on stdin, answer text only on stdout, diagnostics on stderr, and nonzero exit when no answer exists. The OpenAI-specific layer is Idriç and uses ICU's own existing HTTP/TLS transport rather than curl, an OpenAI SDK, or another HTTP client.

The A/B runner can therefore substitute it without an adapter:

```text
OPENAI_API_KEY=... \
OPENAI_MODEL=gpt-5.6-sol \
python3 evals/blackball/run_cli_ab.py \
  --client /path/to/icu \
  --client-arg openai \
  --question 'question to test'
```

Each A/B sample is a new ICU process and each `icu openai` invocation creates one fresh Responses API request. No conversation or prior-response identifier crosses the boundary. The ICU request sets `store=false` and supplies no tools.

The exact ICU revision, model, Responses endpoint/configuration, and Blackball revision still belong in the AICI run receipt. A green deterministic ICU mock-endpoint test establishes transport/parser/command behavior; it is not evidence about real model behavior.

## Mock command

`mock_chat_cli.py` implements the same boundary directly from the synthetic cases.

Example:

```text
AICI_BLACKBALL_MOCK_ID=positive \
AICI_BLACKBALL_MOCK_PHASE=baseline \
python3 evals/blackball/mock_chat_cli.py < prompt.txt
```

Mock-only environment variables are deliberately out-of-band. The real API command does not implement them and does not mimic the mock's internal implementation.

The three mock phases are:

- `baseline` — return the fixed unconditioned answer;
- `blackball` — return the fixed Blackball-conditioned answer, or a synthetic process failure;
- `judge` — return the fixed JSON comparison judgment.

The evaluator-facing command boundary itself remains only stdin/stdout/stderr/exit status.

## Replacement rule

The evaluator depends on this process contract, not ICU specifically. ICU is the first live implementation because it dogfoods the project's own network path. A different provider or implementation may replace it later without rewriting the A/B logic if it preserves the same boundary and records its exact identity in the run receipt.
