# Bounded semantic-oracle meta-corpus

This is the executed BC-A02-S01 slice for issue 171 cases M01, M02, M04,
M06, M09 and M23. `aici_meta_corpus.c` first runs small good and bad
implementations and tests, writing `raw-observations.tsv`. Classification then
consumes those recorded observations and the separately authored
`expectations.tsv`; the candidate and its test do not supply their own oracle.

The executable distinguishes the candidate's semantic result, the observed test
result, their agreement, evidence validity, diagnosis and disposition. Thus a
correct reordered set remains semantically accepted while an order-sensitive
test is recorded as a test defect. A missing set element is rejected even when a
false-positive test says PASS. Candidate-produced expected output remains
`UNTRUSTED_PRODUCER`, missing/empty/never-run selection remains `INCOMPLETE`,
and contradictory independent M09 expectations remain a disagreement for STAR
judgment.

`Makefile` requires the qualified ICK compiler explicitly. It has no `cc`
fallback. The test target:

1. executes 13 scenarios and retains raw candidate/test observations;
2. classifies the same recorded observations twice and compares verdict bytes;
3. compares the verdict with independently written expected dispositions;
4. repeats observation/classification with permuted cases, oracle rows and set
   order, then compares the canonical verdict bytes; and
5. verifies one explicit disposition for every M01–M26 row.

The self-test workflow selects the repository's pinned ICK host-C producer and
uploads the raw observations plus canonical verdicts. Those host results prove
only these 13 scenarios. They do not establish corpus-wide soundness, fresh
model inference, GPU/device behavior or the deferred M03/M17/M24–M26 owner
integrations.
