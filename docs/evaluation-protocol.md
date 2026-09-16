# Evaluation protocol

This is the normative protocol for evaluations of AI-authored work. It turns
the evaluation guidance summarized in `research/llm-failure-modes.md` into a
repository contract. A project may add stricter rules, but should not silently
weaken these ones.

## Unit of evaluation

The unit is not the final answer alone:

```text
task + starting revision + supplied evidence
    -> captured trace + produced artifacts + final state
    -> independent checks
    -> verdict bound to the tested revision
```

Capture enough of the run to distinguish a correct outcome from a persuasive
completion claim: the prompt, relevant instructions, starting and ending
revisions, tool and command trace, stdout/stderr, artifacts and their hashes,
and final user-visible state. Secret values must be removed without deleting
the fact that a secret-bearing action occurred.

Bind observations to the system under test. A fatal marker in a global runner,
emulator, browser, or service log does not establish that the target failed.
Capture a stable target identity before exercising it, require that identity to
remain live, and apply both positive-effect assertions and failure checks to
evidence attributed to that identity. Preserve global logs as context. Every
scoped failure check needs paired controls: an unrelated actor's identical
failure marker must not fail the target, while the target's marker must fail.

## Design each case before using it as a gate

Every case declares:

1. **Objective:** one concrete behavior or failure class.
2. **Data:** the task, source packet, fixture, and origin of the case.
3. **Oracle:** the reference answer, mechanical predicate, executable probe, or
   rubric that distinguishes pass from fail.
4. **Criterion:** a narrow pass condition written before inspecting the new
   candidate output.
5. **Trials:** how many independent runs must pass.
6. **Blocking status:** whether failure or `uncertain` blocks the change.

The case manifest is checked by
`contracts/evaluation-case-v0.contract.tsv`. The schema is only the admission
gate; it does not prove that the declared oracle is good.

### Repository-backed reasoning cases

Retrieval success and answer grounding are not evidence that a repository
improved a decision. A repository-backed case must identify the
decision-bearing record, the intermediate state it should change, and the
independent downstream oracle. It must include an ablation or replacement of
the decisive record, a paired fact change that should alter the result, and an
irrelevant-context control that should not.

Grade retrieval, interpretation, state update, and downstream outcome
separately. Only the last two can support a claim that repository detail
improved reasoning. See
`research/repository-context-methodology.md` for the mechanism and the ASE /
Blackball architecture boundary.

## Evaluate four distinct things

Do not collapse these into one impressionistic score:

- **Outcome:** Did the promised user-visible result actually work?
- **Process:** Did the agent use required sources, tools, checks, and safety
  boundaries, and avoid forbidden ones?
- **Style:** Did the result obey the requested form and project conventions?
- **Efficiency:** Did it avoid needless retries, context churn, commands, cost,
  and elapsed time?

Outcome and mandatory process gates are conjunctive: strength in one category
cannot average away failure in another. Style and efficiency may be reported
separately unless the project explicitly makes them blocking.

## Build the dataset from real work

Use a small useful seed, then grow it continuously. Include:

- ordinary cases representative of real work;
- edge cases and adversarial cases;
- negative controls that must not trigger the behavior;
- incidents observed in production or prior agent work;
- human-curated and domain-expert cases where correctness needs expertise;
- protected compositional cases that are not exposed to the worker;
- temporal holdouts added after newly observed failures.

Record each case's origin and split. Do not tune on the holdout set. A public
regression case should have private metamorphic variants that change names,
numbers, layout, wording, distractors, or constraint position without changing
the answer.

## Prefer narrow graders

Use the strongest available oracle in this order:

1. deterministic predicate;
2. executable acceptance probe against the final artifact or environment;
3. human or model rubric grounded in a supplied source packet.

Prefer classification, pairwise comparison, or scoring one explicit criterion
at a time over asking a grader whether the result is generally good. Split a
compound rubric into separately reported criteria. A semantic grader must
return `pass`, `fail`, or `uncertain`, cite the source passages or artifact
regions supporting its verdict, and explain only the failed or uncertain
criteria.

A model grader cannot:

- override a deterministic or executable failure;
- accept confidence, fluent prose, action volume, a receipt, or a sidecar as
  evidence of the promised result;
- grade its own unaided answer as the sole verifier;
- see candidate identity when it is irrelevant;
- use a rubric that has not been checked against human judgments on a sample.

For comparisons, run both candidate orders and require an order-consistent
verdict. Include concise-correct versus verbose-wrong controls. When the worker
and grader share a model family, record that fact and require external evidence
or a second independent check.

## Metamorphic families

Important semantic cases are families, not isolated prompts:

- **Missing evidence:** an unanswerable case must produce
  `missing_evidence`; an answerable twin must use the supplied evidence.
- **Pressure:** neutral wording, praise, and an incorrect challenge must not
  change an evidence-supported answer; a genuine correction must change it.
- **Constraint position:** move each `must`, `must_not`, and `preserve`
  constraint among the beginning, middle, and end of the context.
- **Visible-test gaming:** change identifiers and values, combine previously
  isolated requirements, and include zero-byte, stale-output, and constant-
  output traps.
- **Completion:** pair an unverified completion claim with a run whose exact
  artifact and final state were independently observed.
- **Judge bias:** swap order, blind identity, and exchange concise and verbose
  presentations without changing correctness.

## Reliability and continuous evaluation

Run the evaluation suite on every relevant change and bind every result to the
exact source revision, evaluator revision, model/configuration, fixture hashes,
and environment. Preserve failures as new regression cases.

One successful nondeterministic run is not reliability. High-consequence cases
such as release, publish, deletion, migration, credential use, and remote state
changes require repeated independent trials. A required case passes only when
all declared trials pass. Report per-case results and trial counts; do not hide
failures in an average.

Skipped checks, missing sources, absent dependencies, evaluator crashes,
timeouts, empty outputs, zero assertions, and malformed traces are failures.
For a required semantic gate, `uncertain` also blocks.

## Seed cases

`evals/cases.tsv` records the first incident-derived case
families: invented continuity, false completion, sycophancy, lost constraints,
generic source-free notes, omitted explanatory geometry, model-judge bias, and
single-run reliability. The rows are specifications for a runner, not claims
that a semantic runner already exists.

## Sources

This protocol adapts the evaluation workflow, dataset guidance, narrow-grader
preference, trace capture, and outcome/process/style/efficiency split from
[OpenAI's evaluation best practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices),
[agent evaluation guidance](https://developers.openai.com/api/docs/guides/agent-evals),
and [systematic Codex skill evaluation](https://developers.openai.com/blog/eval-skills).
The adversarial additions and stricter evidence hierarchy come from the
research and incidents cited in `research/llm-failure-modes.md`.
