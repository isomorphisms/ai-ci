# H³ ray scalar and rejection oracle

Origin: https://github.com/isomorphisms/flexible-pipes/issues/131
Consumer: isomorphismes/knot-complement, refactor/c/h3_ray.c.

accept.c includes no candidate geometry source. It expects exactly 34 ordered finite fields for the log-2 example: point, unit direction, accumulated travel, intrinsic distance, three coordinate models and their tangent derivatives, transported forward vector and plane/sphere first-hit lengths. Expected values use exact fractions and an independent upper-half-space distance/unit-speed identity. Duplicate, extra, missing, reordered, malformed and nonfinite fields fail.

Five actual corrupted streams are rejected. Four child-process cases must exit with the intended assertion-failure code 1: nonfinite scalar comparison, nonfinite matrix comparison, frozen ray direction and reset accumulated travel. Missing executables and crashes do not count as valid rejection. The caller bounds total execution time.

Build through the pinned ICK host profile declared in ci/build-toolchain.tsv. Invocation takes OUTPUT.tsv, RECENTER_TEST, FROZEN_DIRECTION_TEST and RESET_TRAVEL_TEST in that order. Flexible Pipes owns the command-stage orchestration and original output bytes.

This is numerical host acceptance of the supplied ray example plus adversarial executable checks. It is not a formal proof for all H³, an m004 topology test, GPU readback, physical-phone acceptance or final promotion. The independently maintained source/checker revisions must be recorded with the candidate source and compiler digest.

