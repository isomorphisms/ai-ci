# Independent acceptance for SUN LERAY-EXACT-01

This C11 verifier independently recomputes the reduced periodic Beltrami
calculation in `walnut-burgundy/leray-overlooking-the-seine`. It consumes captured
producer TSV. It does not include, compile into itself, call, or copy the
producer's finite-difference/time-stepping implementation. Its references come
from the closed forms derived below, evaluated with `long double`, `log1pl`,
and `expm1l`.

The result concerns one exact-flow family. It cannot accept a general
three-dimensional Navier–Stokes solver, arbitrary data, nonlinear transport,
pressure recovery, or a physical fluid experiment. Source review, compilation,
producer execution, independent output acceptance, and CI receipts remain
distinct evidence stages. Committing this source alone proves none of the
execution stages.

## Continuous calculation

The horizontal velocity `(sin z, cos z, 0)` has unit length at every height.
It changes only with height, while every particle stays at its initial height.
Consequently transport contributes zero, divergence is zero, curl equals the
velocity, and the Laplacian equals its negative. A constant pressure suffices.

For nonnegative viscosity ν, the amplitude at time t is `exp(−νt)`. The velocity
is `exp(−νt)(sin z, cos z, 0)`. With the spatial average normalized to one,
energy is `exp(−2νt)/2` and helicity is `exp(−2νt)`. Thus energy and helicity
are constant at ν = 0 and decay at rate 2ν when ν > 0.

A particle starting at `(x₀,y₀,z₀)` moves horizontally by
`integrated_amplitude(t)(sin z₀, cos z₀, 0)`, where
`integrated_amplitude(t) = (1 − exp(−νt))/ν`. Its continuous extension at ν = 0
is t. Displacements are measured on the unwrapped periodic trajectory; reducing
positions modulo 2π would change the requested diagnostic.

## Discrete calculation

For an N-point periodic height grid, spacing h = 2π/N, the centered three-point
Laplacian sends the sampled field to `−λₕ` times itself, with
`λₕ = 4sin²(h/2)/h²`. The centered curl sends it to `cₕ` times itself, with
`cₕ = sin(h)/h`. These eigenvalues follow by adding or subtracting the shifted
sine/cosine values. The sampled vector still has unit length.

The semidiscrete exact amplitude is `exp(−νλₕt)`. After m forward Euler steps
of size Δt = t/m, the numerical amplitude is
`A = (1 − νλₕΔt)ᵐ`. The verifier evaluates its logarithm with `log1pl`, rather
than repeating the producer's stencil updates. Numerical energy is A²/2 and
numerical helicity is cₕA². Their semidiscrete references are
`exp(−2νλₕt)/2` and `cₕexp(−2νλₕt)`.

The trapezoidal sum of the numerical velocity amplitudes has the closed form
`S = (1 − A)(1 − νλₕΔt/2)/(νλₕ)`. At ν = 0 its continuous extension is t.
The verifier uses `expm1l` to retain precision in `1 − A`. It does not numerically
integrate its own particles.

All RMS norms mean `sqrt(mean(horizontal_x² + horizontal_y² + vertical²))`.
The velocity error is `|A − exp(−νt)|/exp(−νt)`; the temporal error is
`|A − exp(−νλₕt)|/exp(−νλₕt)`. The initial Laplace and curl RMS errors are
`|λₕ − 1|` and `|cₕ − 1|`. Particle error is the absolute RMS
`|S − integrated_amplitude(t)|`, while displacement is S. Divergence is zero
for this ansatz, including the stored zero vertical velocity.

The expansions `λₕ = 1 − h²/12 + O(h⁴)` and
`cₕ = 1 − h²/6 + O(h⁴)` give second-order spatial convergence. At fixed grid,
`log A = −νλₕt − (νλₕ)²tΔt/2 + O(Δt²)` gives first-order temporal convergence
against the semidiscrete reference. Comparing only against the continuous
solution would mix those two errors and could hide temporal refinement.

## Captured-output contract

The exact header and row matrix live in `accept.c`. Each row has 18 tab-separated
fields; the file must end in LF. The expected 16 rows are:

| case | N | m | ν | t |
| --- | --- | --- | --- | --- |
| spatial | 16, 32, 64, 128 | 1 | 0 | 0 |
| temporal | 64 | 64, 128, 256, 512 | 0.2 | 1 |
| combined | 16, 32, 64, 128 | 4N² | 0.2 | 1 |
| inviscid | 64 | 512 | 0 | 1 |
| decay | 64 | 512 | 0.2 | 0.5, 1, 2 |

The verifier rejects missing, duplicate, unexpected, reordered, or extra rows;
wrong grids/step counts/parameters; missing or extra columns; embedded NUL or
CR; decimal overflow; nonfinite numbers; hex numbers; negative diagnostics,
including negative zero; whitespace and trailing junk. It recomputes every
numeric diagnostic and every printed continuous/semidiscrete reference.

Success requires consecutive spatial error ratios between 3.8 and 4.1,
temporal error ratios between 1.98 and 2.02, and combined velocity error ratios
between 3.8 and 4.1. It then checks all values against the independent formulas.
The diagnostic tolerance is `5×10⁻¹¹ + 2×10⁻⁸|reference|`, allowing double-array
stencil rounding and up to 65,536 Euler steps while remaining much smaller than
the observed refinement errors. ν = 0 is exact; the ν = 0.2 field permits an
absolute 2×10⁻¹⁷ decimal-printing difference. Times are binary-exact values and
must match exactly. These tolerances do not accept an arbitrary approximate
solution or demonstrate another grid/time range.

## Execution and adversarial controls

Build `accept.c` as C11 through the pinned qualified ICK toolchain, with strict
warnings, `-lm`, and the native scalar runtime flags exported by `ick-host`.
No generic host compiler is an acceptance fallback. The consumer workflow must
record exact producer, ai-ci, and ICK commits, build flags, source/artifact hashes,
runtime output hashes, process exits, and host facts. C11 qualification and
repeatability must run on the actual compiled producer and oracle; this parser
does not infer them from a TSV file or a source declaration.

The compiled verifier has two invocations:

```text
leray-exact-verify OUTPUT.tsv
leray-exact-verify --self-test OUTPUT.tsv
```

The second invocation first accepts the complete fresh producer capture. It
then mutates those captured bytes 41 ways and requires rejection at each named
diagnostic. Every numeric output column has a targeted mutation. The controls
explicitly corrupt continuous energy/helicity and semidiscrete energy/helicity
references, disrupt each refinement family, remove/duplicate/add rows, damage
the header and column structure, and insert hostile numeric/text forms. A
passing fixture is the actual captured producer output, not a fixture emitted
by the oracle under test. The mutation checks prove rejection behavior; they
cannot prove the provenance or honesty of their original input capture.

Invalid viscosity, unstable timesteps, and invalid grids must also be exercised
by launching the producer's input path and observing its nonzero exits and
specific diagnostics. Replacing an expected TSV parameter is a separate parser
control and cannot substitute for those producer executions. Independent MOON
recomputation and the later AI-CI receipt must bind the same fresh captured bytes
and exact source revisions. Missing execution, a skipped job, or a compiler
blocker remains NOT_RUN/BLOCKED; it does not inherit PASS from this source.
