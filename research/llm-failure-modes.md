# Language-model failure modes that inform ai-ci

The research does not imply that every model fails every case. It does show why
instructions and same-model self-review are not sufficient enforcement.

## Evaluation discipline

[OpenAI's evaluation best-practices guide](https://developers.openai.com/api/docs/guides/evaluation-best-practices)
recommends task-specific evaluation, logging, continuous evaluation, and
criteria-based scoring instead of relying only on open-ended generation. The
ai-ci translation is executable repository contracts, real failure fixtures,
and continuous regression cases collected from observed incidents.

## Missing evidence and invented continuity

[AbstentionBench](https://arxiv.org/abs/2506.09038) reports that abstention on
unanswerable and underspecified questions remains unsolved across twenty
datasets and twenty frontier models; reasoning fine-tuning reduced abstention
performance by 24% on average.

**Contract implication:** pair incomplete-source cases with answerable twins.
The incomplete case must return structured `missing_evidence` without invented
details; the twin prevents indiscriminate refusal.

## Sycophancy under user pressure

[Towards Understanding Sycophancy in Language
Models](https://arxiv.org/abs/2310.13548) found sycophancy across five
assistants and showed that challenges containing suggested false answers can
reduce accuracy.

**Contract implication:** repeat the same evidence under neutral wording,
praise, and an incorrect challenge. The verdict may change only when new
evidence is supplied. Also include a genuine correction that must change it.

## Constraints lost inside long context

[Lost in the Middle](https://arxiv.org/abs/2307.03172) found that models often
use information less reliably when it occurs in the middle rather than at the
beginning or end of a long context.

**Contract implication:** position-shuffle every critical `must`, `must_not`,
and `preserve` constraint and require identical compliance.

## False claims of completion

[From Confident Closing to Silent
Failure](https://arxiv.org/abs/2606.09863) studies agents that assert completion
when independently measured environment state says otherwise. It also reports
poor detection by LLM judges that relied on confident wording or action volume.

**Contract implication:** derive “done” only from captured state: exact commit,
artifact hash, installation or decoding result, and the required fail-to-pass
transition. The worker model cannot issue its own final pass.

## Visible-test reward hacking

[SpecBench](https://arxiv.org/abs/2605.21384) separates visible isolated tests
from held-out compositional tests and reports that agents can saturate the
visible suite while still failing the held-out behavior.

**Contract implication:** keep protected compositional cases, make evaluator
files read-only, and reject modifications to tests or expected outputs. Include
zero-byte artifacts, stale outputs, constant renderers, and hard-coded samples.

## Self-review is not an independent verifier

[Large Language Models Cannot Self-Correct Reasoning
Yet](https://arxiv.org/abs/2310.01798) found that intrinsic self-correction
without external feedback can fail or reduce accuracy.

**Contract implication:** require external evidence such as compiler output,
independent calculations, source manifests, decoded frames, transcription, or
device installation. “Double-check carefully” is not a gate.

## Model-judge bias

[Judging LLM-as-a-Judge with MT-Bench and Chatbot
Arena](https://arxiv.org/abs/2306.05685) documents position, verbosity, and
self-enhancement biases in model judges. A later systematic study also finds
[position bias across judges and tasks](https://arxiv.org/abs/2406.07791).

**Contract implication:** blind model identity, swap candidate order, require
order-consistent verdicts, and never use a model judge where a deterministic
predicate exists.

## One success is not reliability

[tau-bench](https://arxiv.org/abs/2406.12045) evaluates the final state of
tool-agent interactions and reports low multi-trial reliability, including
retail `pass^8` below 25% in the original study.

**Contract implication:** important publish, deletion, credential, and release
cases run repeatedly and gate on all trials, not the best run.

## Real repository coordination

[SWE-bench](https://arxiv.org/abs/2310.06770) evaluates real GitHub issue
resolution using fail-to-pass and pass-to-pass tests. Its original systems
resolved only a small fraction of tasks even with repository context.

**Contract implication:** test from a clean checkout, run the documented user
path, preserve existing tests, exercise repeat execution, and inspect
cross-file effects. A narrow unit test in the edited directory is insufficient.

## Public-test contamination

[Proving Test Set Contamination in Black-Box Language
Models](https://arxiv.org/abs/2310.17623) presents evidence that benchmark
ordering can reveal memorization.

**Contract implication:** continuously create private metamorphic variants by
changing names, numbers, constraint positions, layouts, paraphrases, and
distractors. Keep temporal holdouts from newly observed failures.

## Resulting policy

- deterministic state checks are authoritative;
- model review is advisory unless a contract explicitly requires grounded
  review, and it never overrides deterministic failure;
- every public regression case should generate private variants;
- every required contract proves that it rejects at least one known-bad case;
- skipped checks, missing dependencies, zero assertions, timeouts, and absent
  inputs are failures, never passes.
