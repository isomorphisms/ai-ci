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
