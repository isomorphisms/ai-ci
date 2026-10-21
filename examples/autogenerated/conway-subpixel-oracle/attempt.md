# Program attempt: Conway Subpixel oracle

Status: PARTIAL; Idriç precision slice rejected by the observed package

## Purpose and intended behavior

Independently qualify the actual Conway *442 geometry seam and its native
sample masks. Keep the existing group engine authoritative. The checker must
recognize the 648 distinct square isometries, two motif shapes per isometry,
and compare native occupancy with independently derived line/circular tubes.
A separate reflected translucent probe distinguishes ordered paint from
set-valued geometry and tests repeated segments within a single shape.

## Type-system sketch

Values: finite screen coordinates, affine isometries, finite line segments,
circular arcs, stroke radii, individual midpoint samples, per-shape occupancy
sets, paint order and explicit numerical uncertainty.

Central pure operations: distance_to_segment : ScreenPoint → Segment → Distance;
distance_to_arc : ScreenPoint → CircularArc → Distance;
sample_membership : ScreenPoint → Stroke → Inside | Outside | Boundary;
classify_square_isometry : AffineTransform → Either Error SquareIsometry.
An occupancy mask denotes a set of 64 samples; union must be idempotent.
Decoded geometry and raw C ABI buffers have separate roles.

Actions: read the versioned Conway seam, call the actual native path API,
compare definite individual bits, retain excluded-boundary counts and emit a
failing exit on any wrong definite sample or missing/duplicated geometry.
Bounds and source identities must be checked before native invocation.

Required invariants: all 81 tile translations × 8 orientations appear exactly
once, source motif endpoint/circle geometry survives the seam, clipping and
padding are preserved, each shape resolves alpha once, and no geometry helper
from the producer computes the independent expected answer.

## Runtime and backend boundary

The first Idriç slice requests an explicit Float64 screen-distance calculation,
without silently accepting the default Float16 or narrowing to Float32. The
full checker also requires a verified direct binding to caller-owned C path
records and mask buffers. Existing C oracles use long double independently of
the producer's binary64 arithmetic. The installed Idriç package is the observed
94dfd99bd3e376507fedc8611053b7173b2519f0 host package; host checking alone would
not establish a direct native API binding.

## Idriç attempt

Source: ConwayDistance.idric. From its explicit source directory, invoked the
observed package's `bin/idric --check ConwayDistance.idric`. Exit 1: "Undefined
name Float64" at the ScreenCoordinate definition; the dependent Num error is
secondary. An initial absolute-path invocation of conway-distance.idric also
exposed a module/file-name mismatch, corrected before the precision check.
No RefC or generated-C route was used. This is a result for the recorded
94dfd99 package, not a claim about every current compiler/backend.

## Fallback and language work

The requested explicit precision primitive is unavailable in this package.
Retain the failed Idriç source and implement the native acceptance slice as
`subpixel/conway_verify.c` within the established ICK-compiled C-ABI oracle
boundary. It uses long double for its independent distances. Removing that boundary
requires explicit high-precision numeric support and a qualified native C ABI
binding for these records; a passing distance program alone is insufficient.
The smallest first language acceptance is this same source checking with a
preserved explicit Float64 width, followed by a native distance calculation
whose generated target and returned values are inspected. The C implementation
is separately verified; its result is not Idriç success.

The first C positive run correctly rejected the old producer's translucent
pixels. One initial oracle mistake was corrected first: CSS alpha nibble 8
expands to 136/255, not 128/255. After that correction the unchanged expectation
still found pixel (17,10) blue 230 versus rational 231 in all three strategies.
The expanded rational oracle reduced the producer defect to alpha 64 × 33/64
occupancy × 1/2 opacity: exact alpha 16.5 was rounded to 16. The repaired source
passes all 65,520 rational cases. The full repaired Conway run passes 22,748
checks and 5,979,792 definite sample comparisons, with 243,696 boundary samples
excluded. It used the recorded authenticated ICK artifact and ICK-built Ike.
Source-mutant and receipt acceptance is recorded separately after execution.
