# Bounded acceptance for the Fulton–CNC research experiment

This owner-side oracle independently substitutes exact analytic elbow
coordinates, a non-meridian pole setting, and an offset double point into the
equations. It also checks the producer's actual Macaulay2 transcript fields.
It does not reuse the producer's Gröbner procedure. This is deliberately a
small exact research experiment, with Macaulay2 as the explicitly requested
algebra owner; no C build or general grading framework is introduced.

Producer mathematics: [walnut-burgundy/fulton at de7d0bf7901f8f595e3518e50a375755c5974ac6](https://github.com/walnut-burgundy/fulton/tree/de7d0bf7901f8f595e3518e50a375755c5974ac6).
`cases.tsv` lists all 17 targeted false records, one for every retained
producer-transcript diagnostic. `observed-negative-results.tsv` records
their actual first errors, not mere fixture presence. The four rows below
highlight the principal defect classes; the complete matrix is authoritative.

The FP capture mode reads the three actual earlier stage stdout files from
one run directory. Ordinary capture mode reads the same producer bytes with
the explicit fixture filenames. An unknown mode is rejected. Producer input
hashes and full argv live with the original FP run receipt.

Acceptance is limited to these equations and transcripts. It does not grade
the exposition, prove an arbitrary radical computation, authenticate a human
chat surface, inspect a real machine, or accept physical motion. Input/output
digests and producer provenance must accompany the result: replaying a saved
good transcript alone cannot accept an altered producer.

The retained negative controls modify one relevant assertion at a time:

| Control | Change | Required first diagnostic |
| --- | --- | --- |
| radicalized-arm | Replace the doubled arm length by one | FULTON-ARM-MULTIPLICITY |
| nilpotent-pole | Deny equality of original pole ideal and radical | FULTON-POLE-REDUCED |
| whole-fiber-is-limit | Report the punctured limit as a circle | FULTON-LIMIT-DIMENSION |
| local-is-global | Report zero local differential at the regular crossing | FULTON-OFFSET-LOCAL-GLOBAL |

These are deliberately false result records, not claims about faulty upstream
Macaulay2. The unchanged positive twin must pass each time. Broader private
variants and an offline continuation diagnostic belong to the bounded Earth
handoff in the Fulton research branch.
