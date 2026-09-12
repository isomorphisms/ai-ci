# Semantic evaluation cases

`cases.tsv` is the initial incident-derived corpus. Its columns
match `contracts/evaluation-case-v0.contract.tsv`:

- `case_id`: stable identifier;
- `failure_class`: narrow behavior being tested;
- `objective`: the success property;
- `input_or_fixture`: prompt, packet, trace, or fixture supplied to the run;
- `expected_outcome`: expected label or observable result;
- `oracle`: reference, predicate, probe, or rubric;
- `grader_type`: deterministic, executable, human, model, or a declared
  combination;
- `required_evidence`: evidence the verdict must cite;
- `variant_family`: paired or metamorphic cases that must agree;
- `data_source`: incident, production, synthetic, or expert origin;
- `split`: development, public regression, or protected holdout;
- `minimum_trials`: independent runs required;
- `blocking`: whether failure or uncertainty blocks the change.

The manifest is deliberately provider-neutral. A future runner may translate
it to a hosted evaluation service, but the repository remains the authoritative
source of objectives, cases, evidence requirements, and thresholds.

## Blackball response comparison

`blackball/` contains a paired context-effect evaluation for answers produced
with and without Blackball material. Its command boundary is provider-neutral,
and its deterministic mocks are plumbing fixtures rather than claims about live
model behavior.

The evaluation has one canonical verdict vocabulary while retaining substantive
effect, evidential support, operational run state, and epistemic uncertainty as
separate information. In particular, failure and unknown are not coerced to a
negative result, and unsupported pessimism is not counted as improvement merely
because the response moves in an expected skeptical direction.
