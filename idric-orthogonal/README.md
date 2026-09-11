# Idriç bounded orthogonal-core acceptance

This gate records the strongest claim supported by the merged Idriç compiler:
**bounded green**, not a general high-dimensional rotation facility.

The pinned source of truth is `isomorphisms/Idric` revision
`47557b43053c829d4f8aa1581007002b57f9c59f`.  AICI does not copy its transform
implementation or maintain another mathematics library.  `run.sh` refuses a
different or dirty checkout, runs Idriç's own `edric009` compiler/executable
receipt, runs Idriç's independent exact R128 oracle, and only then writes the
machine-readable receipt checked in as `expected-receipt-v1.tsv`.

## Classification

| Facility | Classification | Exact boundary |
| --- | --- | --- |
| Four named finite spaces and rank-indexed identity | Settled and executable | `PlaneName`, `ImagePlaneName`, `RealThreeName`, and `Real128Name`; this is not an open universe of user-defined spaces. |
| Exact vector/covector samples | Settled and executable | Distinct datatypes over exact `Integer` coordinates; the public `Unsafe...` representation boundary can deliberately erase roles. |
| Euclidean operations | Settled and executable | One standard-coordinate structure per represented named space; lowering, raising, dot, squared norm, symbolic norm, and distance require that structure. |
| Closed O/SO syntax and exact evaluator | Settled and executable | Identity, first-axis reflection, first-plane quarter-turn, integral unit-quaternion rotation in R3, and composition. Orientation is structural metadata on reviewed constructors, not a derived determinant result. |
| Exact R128 fixture | Settled and independently checked | Nonzero coordinates 1, 2, 3, and 128; reflection/quarter-turn images, norm and dot preservation, H squared, G fourth power, determinant signs, and distant-coordinate preservation. |
| Unit-sphere samples | Implemented but incomplete | `UnitSpherePoint` carries a squared-norm equality. There is no checked orthogonal action returning another certified point. |
| Reusable transform preservation law | Not implemented | No theorem covers every constructor and composition in the closed transform language. |
| Arbitrary transforms | Not implemented | No arbitrary-angle rotation, general Householder family, user matrix, certified matrix, x-to-e1 synthesis, or generic alignment algorithm. |
| Scalar/metric generality | Explicitly provisional | The executable carrier is the exact integer-coordinate fragment and only the standard-coordinate metric is representable. |
| Numerical algorithm selection | Human/design choice remains | Givens versus Householder versus another factorization is downstream numerical policy, not settled by this receipt. |

The missing sphere action is not repaired here.  The present transform type
does not carry a reusable metric-preservation equality.  Adding one requires a
deliberate theorem representation, especially for the public integral
unit-quaternion constructor; wrapping the transformed coordinates and asserting
membership would be unsound.

## Receipt stages

The receipt keeps semantic presence, compiler checking, negative checking,
exact execution, the independent oracle, backend handoff, and target execution
separate.  `PASS`, `FAIL`, `SKIP`, and `NOT_VERIFIED` are the only stage status
vocabulary.  A missing backend or target layer is `NOT_VERIFIED`, never `PASS`.

The genuine 2D Givens probe tracked by `ai-ci#29` and
`idris-shader-backend#30/#31` is deliberately outside this contract.  It tests
a numerical backend primitive and does not establish R128 synthesis, the sphere
model, or a preferred high-dimensional algorithm.  At the pinned audit date,
that probe is on an open shader-backend branch; its hosted receipt is Mesa
software execution, while real PowerVR hardware execution remains unrecorded.

Run from this repository with a clean checkout of the pinned Idriç revision:

```sh
sh idric-orthogonal/run.sh /path/to/Idric \
  47557b43053c829d4f8aa1581007002b57f9c59f \
  /tmp/idric-orthogonal-receipt.tsv
diff -u idric-orthogonal/expected-receipt-v1.tsv \
  /tmp/idric-orthogonal-receipt.tsv
```

The optional fourth argument names another clean Idriç checkout at the same
revision with an already-built compiler.  It exists for local audit work only;
hosted acceptance bootstraps the pinned checkout itself.

