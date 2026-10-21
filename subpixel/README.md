# Independent Subpixel numerical and owned-toolchain acceptance

AICI tests the **actual** 3×3/5×5 C implementation in `isomorphisms/rough.framebuffer` against its own rational-integer midpoint oracle. The producer's numerical test arrays and product build scripts are **not** used.

Current immutable acceptance target: `f33a476c69da313745b58c10cf8057765f9cbec9` from
[isomorphisms/rough.framebuffer PR #20, “Round Subpixel translucent composition in byte units”](https://github.com/isomorphisms/rough.framebuffer/pull/20).
It includes the quadratic/cubic library and repaired build policy. The source
checkout must match that exact revision. Updating the target requires a new
review/run, not silently following a branch.

## Independent geometry oracle

`verify.c` enumerates **every 8×8 midpoint** from a rational analytic parabola and cubic curve, including fractional translated origins, comparing exact counts in all 3×3 and 5×5 cells and each public single-pixel query. Curvature coefficients, nonlinear reparameterization (including reversal), negative curvature/cubic contributions, flat split segments, duplicate OR-mask occupancy, singular/nonfinite input and transactional errors are tested.

Two mutant builds change **real implementation source** while leaving the independent oracle untouched. One negates 3×3 quadratic graph evaluation; the second reverses the 5×5 cubic term. Each mutant is compiled by the same ICK, linked with the same real unmodified other source, and **must** exit nonzero with its specific numerical-oracle rejection. Compilation failures do not count as mutant rejection.

## Build and receipt integrity

The [source-built ICK](https://github.com/dilapidated-shed/ick) compiler is pinned to `c61e448251744a2f40ad743ebef1a027bdcd2f9d`; its retained GCC reference submodule is pinned to `6294f1d9e7536e5ffcde09d1528c918d63abfef5`. Only its authenticated staged x86_64 compiler and `cc1` compile **both producer curve sources, AICI's independent oracle, AICI's receipt checker, and both mutants**.

The acceptance orchestrator is [Ike](https://github.com/dilapidated-shed/ike) at `a92fe68bf8aad8dfcfe9f7a7abd84e07290f7fe0`, built by ICK. AICI uses its own literal `subpixel/Ikefile` to run the oracle and demands `ike-build-v1` with exact target, source digest, rule, recipe, runner, status and no trailing bytes. The receipt checker is **also compiled by ICK**. Two mutated receipts (wrong target and false final result) must be rejected, not passed along by simply testing for the word `PASS`.

The ICK stage-zero build still explicitly uses GNU Make and host GCC/G++ to construct the GCC-derived compiler. The final system link driver consumes **only ICK-produced object files**, supplying CRT/libc/libm. These are not consumer source compilation alternatives or claims of self-hosted ICK. The CI workflow does not run any producer-owned Makefile, native test program or consumer CC fallback.

## Acceptance boundary

This independent mathematical check is narrower than full ai-ci product promotion. It does **not** verify complete live Flexible Pipes dispatch/delivery, Android A1/C67 ABI/runtime, actual framebuffer consumer integration or triangle-edge antialiasing. The producer branch is still draft and must not be merged solely on the strength of this acceptance candidate. Host green is not a physical C67 observation.

Tracker: [ai-ci #253](https://github.com/isomorphisms/ai-ci/issues/253); related FP #75, #77, #78 and #79.

## Global coverage and framebuffer integration

The current target includes the reusable occupancy plane and actual framebuffer
composition from the native preview branch. The independent verifier derives
union masks from rational horizontal bands and checks padding and failure
atomicity. It derives straight-alpha source-over results with integer rational
arithmetic for every coverage count 0..64, rather than copying producer tests.
Two additional real compiled mutants overwrite union masks or stamp partial
coverage opaquely; both must fail the unchanged oracle. This adds bounded host
framebuffer integration evidence, not streaming-kernel or Android acceptance.

## Whole paths and glyphs

`path_verify.c` independently checks finite-line masks using long-double squared
distances and cross products, varied oblique lines, reflection/rotation/shear,
nonuniform scale, endpoint caps, clipping, split joins and degree elevation. It
checks OR union, padded rows, malformed inputs, exact work-budget boundaries,
immediate/mid-work/final cancellation and unchanged destination/report on failure.
A direct Bernstein curve oracle bounds uncertainty between dense parameter
samples; it does not call producer jet, distance or reference helpers. The
baseline run executes 408 assertions. Four actual source mutants alter both
producer/reference half-width, overwrite rather than OR, transpose an affine
coefficient, or ignore cancellation. All must compile and fail the same oracle.

`font_verify.c` reads O/C/S/8 source master controls, then derives its own dense
long-double Bernstein polyline tubes. It never calls the didactic font sampler
or producer reference helper. Seventy-six cases cover scales 1/2/4, phases ±1/8,
forced and automatic strategies, padding and known 40×56 counters. A declared
1/64-pixel boundary strip is excluded from binary classification; definite
samples must agree. False C closure and merged 8 counters are deliberately
rendered and must fail both geometry and independent empty-component counts.
These negative input shapes complement the compiled implementation mutants.

The former active typo is removed from include paths, symbols, diagnostics,
directories and workflow names. Historical branch names and remote receipt
identities are not rewritten. Native baseline behavior stays with the producer;
independent acceptance does not assert that its per-segment alpha semantics
equal per-shape mask union.

Both source-built and exact artifact installations of the same c61e448 ICK
revision can run this verifier. The artifact route independently authenticates
the archive, driver and frontend hashes rather than trusting producer scripts.
Ike's literal POSIX recipe is the existing compatibility boundary. Device,
registered FP dispatch and final integration remain separate acceptance levels.

## Conway's real curved consumer

`conway_verify.c` accepts the exact versioned geometry seam emitted by Conway
42c99ed0d289162b6fd62d864fbf58fc042e24d8. It independently recognizes all
81 tile translations × 8 square orientations, two source motif shapes per
isometry, without implementing a competing orbit engine. At 128×128 it
compares the actual native API's individual bits with long-double distances
to the original two finite lines, circular quarter arc and separate circle.
The declared 1/32-pixel boundary strip includes the bridge's 0.01-pixel circular
approximation. Excluded samples are counted; they are not declared exact.
Forced quadratic, cubic and automatic calls must converge and preserve padded
rows. Existing independent path tests retain broader transform/work/cancel
acceptance; a sampled comparison is not a certified continuous-area theorem.

The reflected translucent probe has independently specified line coordinates,
repeated segments within one shape and ordered #RGBA colors. Every sample mask
is derived analytically, then integer-rational source-over predicts actual
native CLI bytes. This exposed an existing half-byte rounding defect: source
alpha 64, occupancy 33/64, opacity 1/2 over transparent output produced alpha
16 rather than 17. The expanded rational oracle rejects that old implementation
and checks 65,520 combinations of source/destination alpha, opacity, colors and
all 0..64 occupancies against the repair. Expectations were not relaxed.

`conway-accept.grease`, called by ICK-built Ike's `conway` target, compiles the
real library, consumer CLI and independent C checker through the authenticated
ICK. Seven changed real sources must execute and fail the unchanged checker:
screen y reflection, missing line seam, reversed serialization order, ignored
source alpha, double alpha resolution, blank output and shifted clipping.
The full positive run rasterizes the wallpaper; targeted negative runs use
the same binary's probe-only scope after checking the entire geometry inventory.
This avoids pretending seven repetitions are independent full-scene tests.
The exact second target/recipe is bound into an Ike receipt; wrong-target and
final-result receipts remain rejected. Optional expected fields do not
change the original `accept` receipt check's fixed defaults.

The retained Idriç attempt records the observed package's missing explicit
Float64 type. The ICK-compiled C-ABI oracle is a declared fallback, not Idriç
success. Conway host acceptance does not establish device behavior, protected
production admission or model dispatch.

## Read the actual font preview bytes

The `font-preview` Ike target executes `font-preview-accept.grease`. It compiles
the real immutable producer preview and this same independent font oracle with
ICK, then reads every completed output: 32 P6 panels, 640 metric records and
105,344 masks. It decodes 6,742,016 fine-grid pixels into the actual masks and
checks printed counts, enlarged/native resolved pixels, totals, fractional
cells and FNV identities exactly. Four literal bitmap controls supply exact
rectangle membership independently of the producer's bitmap accessor.

The continuous comparison reuses the independent Bernstein bounds at scales
1/1.5/2/4, all four emitted origins and both polarities. Its predeclared
1/64-pixel boundary strip is reported separately: the positive inventory has
5,015,040 definite samples and 41,472 excluded samples. These exclusions do
not apply to the exact image/mask/count round trip. Legacy stroke pixels have
no mask evidence and are not claimed accepted by this gate.

Thirteen genuine compiled source defects must execute and fail for their intended
diagnostic with unchanged oracle expectations. Ten change the preview:
bitmap row reversal, lost S control, corner sampling phase, missing microcell
edges, transposed bits, bitmap substitution, binary stamping, invented counts,
transposed fine-grid image and hardcoded strategy. Three change the actual path
library: additive union, ignored work cap and packed destination stride. The latter use the unchanged
408-assertion API oracle, because a single preview call into an empty plane
cannot distinguish first-call addition from OR. Every scope has an unchanged
positive twin. Nine additional corrupt file inventories must reject: missing
or additional rows, short/long P6 bytes, wrong totals/hash, wrong native or
enlarged grayscale and a nonbinary sample pixel. These directly attack the
metadata and resolved-image checks as well as parsing.

Targeted preview source mutations use a declared one-panel matrix, not a claim
of thirteen full-matrix repetitions. The original forced-binary fixture refused
in the producer's own fractional-cell guard and was not counted as a kill;
its corrected deliberately broken source also removes that guard so the
independent oracle observes the emitted bad bits. See
`font-preview-contract.md` for the fixed requirements and preserved failure.
The workflow verifies the third exact Ike target/recipe and rejects a forged
target. Registered FP and physical evidence remain separately bound.
