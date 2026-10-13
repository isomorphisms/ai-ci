# Independent pole-continuation acceptance

This independent Macaulay2 oracle checks the bounded `Rz(C)Rx(A)` AC-head
continuation diagnostic from `singularity-free-Gcode`.  It independently
constructs the unit-circle and meridian ideals, then checks the producer's
captured output for the declared cases and input-boundary diagnostics.

It accepts only the idealized tip-plus-direction model.  It does not accept
full SO(3), an AC table, measured machine geometry, collision, toolpath timing,
compliance, a dwell, emitted G-code, or a physical machine motion.

Run it after capturing one producer run into a directory containing
`positive.stdout.txt`, `invalid-zero.stderr.txt`, and
`invalid-full-frame.stderr.txt`:

```text
M2 --script research/fulton-cnc-02/accept.m2 EVIDENCE_DIRECTORY
```

`cases.tsv` declares the positive fixture and four targeted false records.
The whole-fiber record changes a two-point path limit into a one-dimensional
fiber; the status record lies about Y/X; the other two suppress the required
input rejections.  The expected first diagnostics are recorded rather than
treated as passing behavior.

The `good` fixture was captured by the checked-in Flexible Pipes pipeline
`fulton-cnc-02-earth` (pipeline SHA-256
`b707f87fede49068cf80c3d2521d697ae641e0cd2cef06614fd4b0dff512f3b0`):
the positive stdout hash is
`c450d76c47a9409986f0055ebae49387936d499f6baedebe7501ac9dabe0112a`,
the zero-meridian stderr hash is
`050b70d8d7e8f862a0c0a77b2a3e2dd2ce06741fc19ca049fadece6f7fb8296b`,
and the full-frame stderr hash is
`df3e1c2ed05695122c8d1d3fa697adc1a59948f032e7d833f5615099f23292ee`.
The final sequential receipts ran Flexible Pipes revision
`fa851ce9b107b70f9f36ad986cce614bc5dfe931` against CNC revision
`e6d52cb50a1691a917530fd264a935029c14f3a6`; the producer source SHA-256 is
`9411693f6872489de16855f16964b7cc7e63de473cbba92086857601d00c0ba5`.

They are only regression inputs. A later candidate needs fresh captured output,
input and source hashes, and a run receipt; replayed fixture bytes do not accept
changed producer source.
