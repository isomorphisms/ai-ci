# Independent regression transitions

The checked Ithon verifier compares a fixed, consumer-owned case matrix with
two actual Vitest JSON reports. Each selected case must fail as an assertion
in the baseline and pass in the candidate. Both reports must contain complete,
consistent assertion counts, no pending/skipped assertions, and no loader error.
A summary PASS, test count, absent case, duplicate selected case, changed scope,
or failed candidate assertion cannot satisfy the gate.

Inputs are `MATRIX.tsv BASELINE.json CANDIDATE.json SCOPE DECISION.txt`. The matrix
header is `case_id`, `scope`, `full_name`; `all` selects all rows. Report files are
bounded to 8 MiB. The output records all input digests and the exact selected
case IDs. JSON is only the existing external runner's result format.

Run through the pinned Ithon frontend. This is report comparison, not proof of
report origin or trusted deployment. FP must execute the pinned tests, capture
the reports outside candidate write scope, and bind source/corpus/tool identities.
An undeployed FP service cannot acquire production authority from this result.

`tests/qualify.pi` exercises a positive pair plus absent, duplicated, failed,
skipped, loader-error, count-only, inconsistent-count, wrong-baseline and invalid
matrix controls. It verifies the intended rejection diagnostic in each case.
