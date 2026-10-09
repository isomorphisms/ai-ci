# Test whether GPT-OSS understands the user's repository commands

AICI owns the checked-Ithon matrix builder, independent grader and inference adapters. Flexible Pipes owns the actual transfer-command cases, initial prompts, Grease orchestration and existing `models/catalog.toml`. Model weights remain outside Git. The models already present there are GPT-OSS-120B, Pythia-12B-deduped and Pythia-6.9B-deduped; this interface references them instead of forking their catalog.

## Commands

Invoke these `.pi` files through the checked Ithon entrypoint, never ordinary Python:

- `evaluate.pi prepare SUITE CATALOG MODEL OUTPUT`: exclusive private run directory, immutable prompt matrix and model-profile snapshot.
- `infer-http.pi run OUTPUT`: actual GPT-OSS chat requests, or Pythia completion requests, to an explicitly configured inference server.
- `infer-pythia.pi run OUTPUT`: actual local Pythia through Transformers/PyTorch, with resolved checkpoint identity and optional activation capture.
- `evaluate.pi grade OUTPUT live`: strict independent comparison of every field and every trial.
- `evaluate.pi exercise OUTPUT good|constant|stale|false-live|missing`: deliberately synthetic grader controls, always labeled HARNESS_ONLY. This is not a model backend.

The real HTTP adapter requires `MODEL_EVAL_BASE_URL` ending at the API base, usually `/v1`; `MODEL_EVAL_SERVED_MODEL` explicitly maps the catalog model to a server name when needed. `MODEL_EVAL_API_KEY` is an optional dedicated inference credential. No GitHub token is used. No redirect is followed, and no model-produced command is executed. The endpoint must implement the model's actual prompt format: GPT-OSS Harmony for chat, plain explicitly serialized completion for Pythia. A reported model name is not cryptographic attestation of remote weights; the receipt says `UNVERIFIED_REMOTE_WEIGHTS`.

Local Pythia uses an explicit absolute `MODEL_EVAL_MODEL_CACHE` and `MODEL_EVAL_ALLOW_DOWNLOAD=1`. The device is explicitly `cpu` or `cuda`. Exact model/tokenizer revisions, dependency versions, prompt text, token IDs, per-token log probabilities and timing are retained. `PYTHIA_CAPTURE_PREFILL=1` saves each layer's activation vector at the last input position, not an unbounded full tensor trace. Two Pythia sizes are model variants; HTTP and local Transformers are two execution adapters, not a claim of two independently validated mathematical implementations.

## What was wrong with the earlier transfer plan

The earlier Kitchen/Flexible Pipes fixture suite skipped the original language problem entirely. It called the transfer script with already-correct arguments, so it could not detect a model choosing a fork, losing a destination correction, inventing missing context, or executing a script-only request. Passing those fixtures also did not qualify the actual Grease runtime: the fixture's fake `grease` invoked `sh`.

Source inspection identifies additional unresolved operational risks: source name and ID are fetched in separate reads; destination errors are swallowed instead of classified; `GH_HOST` is not explicitly fixed for every API call; existence checks precede nonexclusive artifact writes; and `KITCHEN_ROOT` is accepted without an immutable source/runtime admission gate. The generated program can be deterministic while the response containing a temporary pathname is not byte-identical across runs. These are review findings, not claims that this model evaluation repairs every transfer-script defect.

## Evidence and interpretation

Keep HARNESS_ONLY, model behavior, Kitchen/Grease execution, and live transfer separate. This experiment never transfers a repository. Correct routing does not establish correct execution. Missing endpoints produce BLOCKED/NOT_RUN, not guessed model answers. Required cases require all declared trials, not merely a favorable mean. Invalid JSON, duplicate fields, extra fields, wrong names/runtime, false completion, missing outputs and stale request bindings must fail.

The prepared worker payload excludes expected answers, case IDs, split labels and grading categories. Public evaluation examples remain public regressions, not a secret holdout. Freeze prompts and oracles before inference and preserve failures. Hostile worker output is treated only as data. The filesystem and trusted evaluator remain an explicit trust boundary; self-authored receipts are not proof against an attacker able to rewrite the entire run directory.

Pythia comparisons may reveal changes caused by checkpoint, scale, prompt position or instruction wording. They do not directly explain GPT-OSS's internal mechanisms. Activation capture is instrumentation for later controlled intervention; no causal interpretability result is claimed here.

## Actual runtime boundary

The hosted test pins Ithon `d6e83969f82512e920fb17b44326cb54f31d015c`. Its foreign host-Python substrate is an Ithon implementation detail. The first actual frontend test rejected tuple assignment in the grader at `bd87ef13511d5928e52d3ada674908133045ad96`; the next version uses supported simple-name bindings and mapping updates instead of bypassing the checker. The failed hosted run is `37924412266`.
