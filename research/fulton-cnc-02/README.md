# Independent pole-continuation acceptance

This independent Macaulay2 oracle checks the bounded `Rz(C)Rx(A)` AC-head
continuation diagnostic from `singularity-free-Gcode`.  It independently
constructs the unit-circle and meridian ideals, then checks the producer's
captured output for the declared cases and input-boundary diagnostics.

It accepts only the idealized tip-plus-direction model.  It does not accept
full SO(3), an AC table, measured machine geometry, collision, toolpath timing,
compliance, a dwell, emitted G-code, or a physical machine motion.

Run it after capturing the producer runs into a directory containing
`positive.stdout.txt`, `invalid-zero.stderr.txt`, and
`invalid-full-frame.stderr.txt`, and the observed `producer-exits.tsv`:

```text
M2 --script research/fulton-cnc-02/accept.m2 EVIDENCE_DIRECTORY
```

`cases.tsv` declares the positive fixture and nine targeted false records.
The whole-fiber record changes a two-point path limit into a one-dimensional
fiber; the status record lies about Y/X; the other two suppress the required
input rejections.  The expected first diagnostics are recorded rather than
treated as passing behavior.

The merge follow-up fixes a concrete cross-record flaw: a missing field could
previously borrow the next case's value. Each record is now bounded by its next
case marker; duplicate identities and duplicate fields are rejected. Every
meridian equation, determinant, intersection basis, dimension/degree/reduction
and status is checked, including irrational real settings. The original pole
equations and process exits are checked separately from success labels.

The former six-case receipt remains historical evidence. The maintained
seven-case fixture includes `(1,1)` and its negative rescaling, whose limiting
settings are real but irrational over QQ. The source SHA-256 of the unchanged
producer program is
`9411693f6872489de16855f16964b7cc7e63de473cbba92086857601d00c0ba5`.
Fresh Flexible Pipes execution uses the real Grease stage and captures the
three observed process exits before running this oracle. Regression fixture
exits are deliberately constructed test data; fresh captured exits are required
for a new implementation acceptance.

They are only regression inputs. A later candidate needs fresh captured output,
input and source hashes, and a run receipt; replayed fixture bytes do not accept
changed producer source.
