# Independent Holomorphic numerical checker

Execute `HolomorphicAcceptance.pi` with the checked Ithon frontend, never an
ordinary Python interpreter. `attempt.md` retains the first Idriç slice and
the missing compiler boundary. No consumer compiler is silently substituted.

Commands (arguments are ordinary files/directories):

- `selftest OUTDIR` checks analytic anchors, 31 reference observations, ten
  actually evaluated mathematical mutants, five provenance failures, and
  missing numerical output. It emits `cases.tsv`, `reference.tsv`, and
  `mutations.tsv`, plus small provenance fixture files. Its final PASS explicitly
  scopes itself to checker fixtures, with producer/GPU/emulator/physical NOT_RUN.
- `corpus OUTDIR` emits the same nonempty mathematical case/reference TSV files.
- `compare CASES.tsv READBACK.tsv` independently checks actual observations.
  Missing, duplicate, unexpected, nonfinite, or malformed required observations
  fail. Phase compares modulo 2π; logarithmic modulus is **not** reduced modulo
  the Wegert colour period. Host tolerance remains 2×10⁻¹² absolute in each
  channel. It is not silently widened for a binary32 GPU.
- `provenance EXPECTED_FRAGMENT SUBMITTED_FRAGMENT RUNTIME_LOG` compares actual
  selected source bytes to the build's expected generated source and checks
  runtime hash, length, selection, no fallback, and driver source readback.
  The caller owns trust in the expected fragment and capture of the actual
  submission; copying a sidecar into either argument is not runtime evidence.
- `gpu-structure RUNTIME_LOG` requires all 34 outputs from the selected-program
  probe's ten cases. It independently reconstructs their original coordinates,
  coefficients, exact cancelled divisor, remote positions and camera/time
  twins; checks the actual uploaded factor inventory and exact singularity order;
  and reports raw phase/log errors without classifying them. Missing output, false output-ready labels,
  missing numerical markers, graphics errors and changed corpus inputs fail.
  Self-tests use explicitly synthetic binary64 logs and never count as GPU
  execution. No binary32 tolerance has been inferred from successful fixtures.
- `gpu-audit RUNTIME_LOG` additionally enforces the predeclared
  [bounded GPU policy](gpu-policy.tsv) and its
  [source/precision rationale](gpu-policy-rationale.md): circular phase error
  ≤10⁻⁴ radians, unreduced log error ≤min(10⁻⁴, source roundoff envelope),
  regular RGBA8 error ≤one level per channel, exact singular endpoints and alpha.
  It requires all 34 same-program RGBA8 rows, their produced markers and no
  graphics errors. Seams are classified with the same budgets. These are
  application quality requirements fixed before viewing GPU output; Khronos
  does not guarantee this atan accuracy. They must not be relaxed after failure.
  Bounded shader acceptance still needs separate provenance and target-identity
  receipts; a synthetic fixture never proves GPU or physical execution.
- `palette-check CORE.glsl FIXTURES.json` verifies the independent binary64
  palette against the six retained shared-Wegert fixtures, unchanged 2×10⁻⁵
  agreement and canonical source digest.
- `large-q-audit RUNTIME_LOG` enforces the separately predeclared
  [large-q diagnostic policy](large-q-policy.tsv) and
  [range/delta rationale](large-q-policy-rationale.md). It requires the exact
  baseline/pair inputs, actual raw mode one, actual pre-Wegert mode three and
  actual RGBA8 mode two from the same selected program. The raw baseline must
  produce marker one; the finite, executed pair must produce marker zero and
  demonstrate an erased increment. The pair remains `RANGE_REJECTED_UNQUALIFIED`.
  Both precolour samples must produce marker one, meet the existing absolute
  budget and preserve the independently signed divisor increments within
  2×10⁻⁶. Colour keeps the one-level channel budget. Missing rows, clear-buffer
  sentinels, always-zero/forced-one markers, wrong signs and lost increments
  fail. The original 31 host cases, 34 GPU samples and policy stay unchanged.

The case header is `case_id world_x world_y time pan_x pan_y zoom coefficients
zeros poles remote_count`, separated by tabs. Coordinate lists use `x,y;x,y`;
`-` denotes an empty list. Exactly five coefficients are required. Coefficients
and divisor positions are rounded to the actual binary32 upload representation
before independent binary64 arithmetic; the host sample world point remains
binary64. Remote positions use the fixed world scale of two and time, never the
camera. The reference sums complex polynomial powers independently of the
producer's Horner form, with the live normalization fixed at z/3.

Readback columns are `case_id phase log_modulus singularity_order
reduced_zero_count reduced_pole_count`, separated by tabs. Counts preserve
total multiplicity, not just distinct locations. Exact cancellation happens
before distance or phase evaluation. A genuine zero/pole uses signed integer
order and may use finite placeholder channels; a removable point has order zero
and must produce the ordinary finite field value. The reference itself records
signed infinite log modulus at genuine singularities.

The retained deterministic-divisor oracle lives in Holomorphic at immutable
commit `66d4b6a7a51382349cbe1e8c520b69617154434b` in the producer checkout;
its one/24 exact/displaced vectors are retained here as reference cases.
Holomorphic's earlier polynomial semantic witness tests the CPU evaluator for
supplied u; it does not settle the worker's independent z/6 sampling policy.

No host checker fixture or C sampler establishes that a generated shader was
compiled, loaded, executed, read back, packaged, or run on any physical GPU.
