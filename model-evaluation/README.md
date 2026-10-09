# Test whether GPT-OSS understands the user's repository commands

AICI owns the checked-Ithon matrix builder, independent grader and inference adapters. Flexible Pipes owns the actual transfer-command cases, initial prompts, Grease orchestration and existing `models/catalog.toml`. Model weights remain outside Git. The models already present there are GPT-OSS-120B, Pythia-12B-deduped and Pythia-6.9B-deduped; this interface references them instead of forking their catalog.

## Commands

Invoke these `.pi` files through the checked Ithon entrypoint, never ordinary Python:

- `evaluate.pi prepare SUITE CATALOG MODEL OUTPUT [CONDITION]`: exclusive private run directory, immutable prompt matrix and model-profile snapshot. An optional exact existing condition produces one shard while retaining the complete parent suite and its digest. The default still prepares the full matrix.
- `infer-http.pi run OUTPUT`: actual GPT-OSS chat requests, or Pythia completion requests, to an explicitly configured inference server.
- `infer-pythia.pi run OUTPUT`: actual local Pythia through Transformers/PyTorch, with resolved checkpoint identity and optional activation capture.
- `evaluate.pi grade OUTPUT live`: strict independent comparison of every field and every trial.
- `evaluate.pi exercise OUTPUT good|constant|stale|false-live|missing`: deliberately synthetic grader controls, always labeled HARNESS_ONLY. This is not a model backend.

The real HTTP adapter requires `MODEL_EVAL_BASE_URL` ending at the API base, usually `/v1`; `MODEL_EVAL_SERVED_MODEL` explicitly maps the catalog model to a server name when needed. `MODEL_EVAL_API_KEY` is an optional dedicated inference credential. No GitHub token is used. No redirect is followed, and no model-produced command is executed. The endpoint must implement the model's actual prompt format: GPT-OSS Harmony for chat, plain explicitly serialized completion for Pythia. A reported model name is not cryptographic attestation of remote weights; the receipt says `UNVERIFIED_REMOTE_WEIGHTS`.

The owned Linux Ollama route has a 55-minute work deadline from entry, including runtime readiness and the model pull. HTTP, metadata, and pull timeouts use the remaining budget; a process alarm also interrupts a blocked operation at the absolute deadline. The adapter stops admitting requests, preserves captured raw output, and records attempted requests, completed HTTP responses, completed normalized final responses, and the stopping phase/reason. An earlier operation timeout remains distinct from exhausting the complete run budget. JSON receipts are published atomically without replacing an existing receipt, so an alarm during writing cannot leave a truncated final receipt mistaken for complete evidence. Owned-process teardown has a separate bounded 30-second terminate/kill allowance so the alarm cannot interrupt cleanup. If only the final model-pin check times out after all HTTP replies completed, the complete HTTP receipt remains unchanged and the local-execution marker is `INCOMPLETE`. No partial owned run earns a live pass. The generic externally configured HTTP entrypoint retains its existing 300-second per-call timeout and has no new whole-run deadline. Synthetic clock/client controls exercise expiry before a request, after one completed response, during a response, and after complete HTTP inference; these are harness tests with zero network/model calls.

Local Pythia uses an explicit absolute `MODEL_EVAL_MODEL_CACHE` and `MODEL_EVAL_ALLOW_DOWNLOAD=1`. The device is explicitly `cpu` or `cuda`. Exact model/tokenizer revisions, dependency versions, prompt text, token IDs, per-token log probabilities and timing are retained. `PYTHIA_CAPTURE_PREFILL=1` saves each layer's activation vector at the last input position, not an unbounded full tensor trace. Two Pythia sizes are model variants; HTTP and local Transformers are two execution adapters, not a claim of two independently validated mathematical implementations.

## What was wrong with the earlier transfer plan

The earlier Kitchen/Flexible Pipes fixture suite skipped the original language problem entirely. It called the transfer script with already-correct arguments, so it could not detect a model choosing a fork, losing a destination correction, inventing missing context, or executing a script-only request. Passing those fixtures also did not qualify the actual Grease runtime: the fixture's fake `grease` invoked `sh`.

Source inspection identifies additional unresolved operational risks: source name and ID are fetched in separate reads; destination errors are swallowed instead of classified; `GH_HOST` is not explicitly fixed for every API call; existence checks precede nonexclusive artifact writes; and `KITCHEN_ROOT` is accepted without an immutable source/runtime admission gate. The generated program can be deterministic while the response containing a temporary pathname is not byte-identical across runs. These are review findings, not claims that this model evaluation repairs every transfer-script defect.

## Evidence and interpretation

Keep HARNESS_ONLY, model behavior, Kitchen/Grease execution, and live transfer separate. This experiment never transfers a repository. Correct routing does not establish correct execution. Missing endpoints produce BLOCKED/NOT_RUN, not guessed model answers. Required cases require all declared trials, not merely a favorable mean. Invalid JSON, duplicate fields, extra fields, wrong names/runtime, false completion, missing outputs and stale request bindings must fail.

The prepared worker payload excludes expected answers, case IDs, split labels and grading categories. Public evaluation examples remain public regressions, not a secret holdout. Freeze prompts and oracles before inference and preserve failures. Hostile worker output is treated only as data. The filesystem and trusted evaluator remain an explicit trust boundary; self-authored receipts are not proof against an attacker able to rewrite the entire run directory.

### Live-response provenance

The first grader trusted a response's `evidence=live` and `status=EXECUTED` fields after checking the request ID and hash. Its `false-live` control sent a live label to the **fixture** grader, so it only proved label-mismatch rejection. It did not prove that the live grader rejected a relabeled synthetic answer. That defect is retained as an executable regression: all correct synthetic answers relabeled live, with no raw inference evidence, must receive zero live passes.

New manifests bind the complete model-profile snapshot as well as the frozen suite and requests. Live HTTP grading requires matching run/request/model identities, a completed inference record covering every declared request, the captured raw request reconstructed independently from the frozen payload, and both raw request and response digests. The grader independently decodes the raw response, checks the served model and normal completion, rejects tool calls, and compares its final text and usage metadata to the normalized response record. A rewritten answer or prompt therefore cannot pass merely by retaining the old completion label or recomputing one digest. Optional reasoning effort comes from the frozen model profile.

For a profile that pins an Ollama digest, grading additionally requires matching before/after runtime and model observations plus `local-execution.json`, bound to the request/model hashes and the owned server process. That marker is written only after the final runtime/model check succeeds. Completed HTTP replies therefore cannot receive a live pass if the owned process or final pin check failed afterward. A reported local model digest remains separate from attested Hugging Face weight equivalence.

The self-test includes two complete synthetic transport records and seventeen targeted provenance mutants, all explicitly harness-only. These checks establish internal evidence consistency under a trusted collector; they do not attest remote model weights or prove that an attacker controlling the entire output directory made a real network call. HTTP weight identity remains `UNVERIFIED_REMOTE_WEIGHTS`. Historical manifests and the current local Transformers/Pythia adapter lack this complete provenance contract and cannot obtain a new live pass without a separately qualified receipt upgrade. Do not edit old evidence into the new format.

For condition sharding, each manifest and summary records `parent_suite_sha256`, the full `parent_count`, and `condition_selection`. The retained `suite.parent.json` is the frozen complete suite. Each shard must contain every case and seed for its selected condition; the three 72-request shards together cover the original 216-request matrix. A single shard's success proves only its 72 trials. The self-test verifies that splitting and recombining conditions preserves every original request exactly once and rejects unknown condition names before creating output.

Pythia comparisons may reveal changes caused by checkpoint, scale, prompt position or instruction wording. They do not directly explain GPT-OSS's internal mechanisms. Activation capture is instrumentation for later controlled intervention; no causal interpretability result is claimed here.

## Actual runtime boundary

The hosted test pins Ithon `d6e83969f82512e920fb17b44326cb54f31d015c`. Its foreign host-Python substrate is an Ithon implementation detail. The first actual frontend test rejected tuple assignment in the grader at `bd87ef13511d5928e52d3ada674908133045ad96`; the next version uses supported simple-name bindings and mapping updates instead of bypassing the checker. The failed hosted run is `37924412266`.
