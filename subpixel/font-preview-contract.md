# Independent emitted font preview acceptance

The producer is immutable rough.framebuffer f33a476c69da313745b58c10cf8057765f9cbec9.
Acceptance must read actual completed native preview output, not regenerate a
lookalike or accept a producer hash as the expected answer.

The full positive must contain 32 P6 panels, 640 ordered metric rows and
105,344 ordered mask rows. Read every emitted sample pixel back into its
64-bit mask using bit 8*sy+sx; match the serialized mask and printed popcount
exactly. Derive enlarged and native grayscale pixels, totals, fractional-cell
counts and FNV identity from those same decoded bits. Reject malformed,
missing, duplicated, out-of-order or trailing records and P6 bytes.

Bitmap answers come from four independent literal seven-row controls. Compute
each transformed rectangle decision at the exact binary-rational midpoint,
including scale 1.5, phases ±1/8, zero and clipped −2.5, both polarities.
Continuous answers use the existing independent long-double Bernstein chord
bounds, extended to those same scales/origins. Declare the existing 1/64-pixel
boundary exclusion before running; count definite and excluded samples
separately. Exact image/mask/count equalities have no tolerance. Unit zero-origin
continuous masks must retain O/8 counters and C/S openings. Every continuous
case must contain fractional cells. Legacy stroke panels explicitly have no
mask evidence; their image semantics are outside this acceptance.

Known-bad controls must change genuine producer source, compile with the same
qualified ICK and execute successfully. Keep oracle source/expectations fixed.
Use a separately declared one-panel matrix (1×, −1/8, black on white) for
targeted negatives; execute an unchanged-source positive twin at that exact
scope first. A compile failure, producer refusal, missing inventory, or broad
nonzero exit does not count as a semantic kill. Require the intended diagnostic.

Required changed sources: reversed bitmap rows; lost S control; corner phase;
missing last microcell row/column; transposed bits; bitmap substituted for
continuous masks; forced binary coverage; invented printed counts; transposed
fine-grid image only; hardcoded strategy; arithmetic addition replacing mask
union; ignored work cap. Preserve source, successful execution and rejection logs for each.
Also reject missing/trailing TSV/P6 data through explicit file corruptions.

Build both checker and real preview through ICK, invoke the gate through the
source-built Ike `font-preview` target and verify its exact target/recipe receipt.
Retain all identities and honest host/device/model-dispatch boundaries.

## Preserved first attempt

The full positive passed 32 panels, 512 mask cases, 105,344 cells and 6,742,016
decoded bits. Its continuous comparison matched 5,015,040 definite samples and
excluded 41,472 boundary samples. The first six source controls rejected.
The global forced-binary source then exited 1 in the producer's own
fractional-cell guard, before independent acceptance. That is a refused producer,
not a semantic oracle kill. The corrected fixture changes that guard too, only
in this deliberately broken source, allowing its binary masks to be emitted.
Oracle/expectations remain unchanged. The first Grease syntax check also
rejected a double-quoted backslash-n; actual multiline strings replace it.
