# Independent geometry follow-up acceptance

These are three deliberately different contracts. They import no candidate
implementation. The existing H3 ray checker remains on its own accepted branch;
this directory does not copy or supersede that check.

## Executable commands

All first-party executable source here is Ithon (`.pi`) and must enter through
the pinned Ithon frontend, currently d6e83969f82512e920fb17b44326cb54f31d015c.
Set `ITHON_CHECK_RECEIPT` to retain checked-source and lowered-source digests.
The inherited Python interpreter/library inside Ithon and the foreign SnapPy
module are explicit runtime boundaries, not first-party `.py` programs.

Each `accept.pi --self-test` checks its positive fixture and bounded independent
mathematics. Actual candidate acceptance uses these arguments:

| Checker | Arguments after accept.pi |
| --- | --- |
| m004-atlas | CANDIDATE.tsv PRESERVED.tri SNAPpy.tsv WRONG_PERMUTATION_BINARY FROZEN_TANGENT_BINARY |
| flower-stitch | ARTIFACT_DIRECTORY increasing-or-control TEST_STITCH_BINARY |
| m004-view | VIEW.tsv |

Flower artifacts are `increasing-1.tsv`, `increasing-1.txt`, `increasing-1.svg`
and corresponding scale 2 files; control uses the `control` prefix.
The Kitchen wrapper controls run `common/kitchen_controls.pi GREASE RECIPE
ITHON CHECKER` with observed absolute paths. They execute a real passing
self-test, reject four relative/missing paths, and propagate a failing checker.
These are execution-routing controls, not mathematical or promotion acceptance.

## m004 atlas

The candidate must supply all 512 scalar observations. The checker independently
solves four basis-image equations for each face transition, rather than using
the candidate's reflection/permutation construction. Three ideal face vertices
map to their ordered partners and the oriented normal maps to the negative
normal in the destination cell. It reconstructs two degree-six edge classes,
one ideal cusp, and its link counts V=4, E=12, F=8. Eight Lorentz and paired-inverse
checks run in the independent self-test.

Each reported crossing is compared with the first positive plane event. The
four-event sample is developed back to a single analytic geodesic, retaining
the full parallel camera frame. A separate local-chart calculation continues
to length 12 without the poorly conditioned huge global coordinates. Observed
travelled distance includes the initial offset 2 and never resets at a crossing.
Five targeted semantic mutations and two malformed streams must be rejected;
both separately compiled candidate mutants must actually exit 1, not crash.

The same execution imports **SnapPy 3.3.2**, loads the preserved triangulation,
compares it to census `m004`, checks actual gluing data, regular ideal shapes,
one cusp and volume 2.029883212819307, and saves its equations/cusp observations.
Use binary wheels only for this foreign dependency and retain acquisition
digests. This is established mathematical-software execution, not a Sage
interval proof or independently deployed acceptance service.

Primary sources: the pinned [SnapPy triangulation fixture](https://github.com/3-manifolds/SnapPy/blob/c3da53c2b3105489b4d71531c4f781c92b237753/src/snappy/tests/files/example_m004.tri)
and [SnapPy Manifold reference](https://snappy.computop.org/manifold.html).
The numerical tolerance is 2e-8 times (1 + magnitude of expected value).

## Crochet material

The checker reconstructs the 8,12,18,27 counted rounds from the rule “one child
per parent, and one additional child in each odd zero-based parent in later
rounds.” It checks 65 actual single crochets, 19 inserted children, every stable
identity, parent/child ordinal, cyclic adjacency, seam and noncounting chain.
The no-increase control has four rounds of eight, 32 counted stitches and no
insertions. These are finite joined-round annular constructions.

Printed per-parent instructions are parsed independently back into the material
ledger. Missing work, changed parent, counted lifting chain and wrong seam are
rejected. Two drawing scales must preserve the ledger/instructions byte for
byte and the SVG's exact material/foundation/incidence/seam identifiers. A
duplicated diagram identity fails. Ten real mutated native ledgers must exit 1;
nine independent in-memory ledger mutations exercise the checker's own refusal.
The SVG test checks semantic labels and density invariance, not optical image
quality or full geometric placement of every line.

This contract establishes discrete construction/instruction agreement only.
It does not measure yarn, crochet gauge, stretching, Gaussian curvature,
mechanical realization, handmade completion, mobile execution or GPU behavior.

## First view sample

The exact axial sample enters the adjacent tetrahedron and hits a sphere of
radius log(2)/8 around that cell's center. The center-to-center distance is
log(2), so the hit is at 7 log(2)/8. The independent checker verifies that
distance, one crossing, object identity and aligned headlight cosine; four
scalar counterexamples fail. It is not a broad raster/image oracle.

## Evidence state

Initial local checks used the pinned Ithon frontend: atlas mathematical
self-test, crochet ledger self-test and axial-view self-test passed. Candidate
native programs, foreign SnapPy, Kitchen/Grease controls and complete hosted
pipelines require their exact-head run receipts. A self-test does not promote
those pending stages. No merge, release, device or handmade claim follows.
