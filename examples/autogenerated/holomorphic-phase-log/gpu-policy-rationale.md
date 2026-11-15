# Predeclared bounded GPU accuracy policy

This policy was written from the checked source, fixed corpus and shared
palette before opening any actual Holomorphic GPU numerical or colour
readbacks. It is an application accuracy requirement for named hardware on
that bounded corpus. It is not a claim that every conforming driver must meet
this accuracy, a universal theorem about this renderer, or a tolerance fitted
to observed failures. An implementation which misses it fails qualification;
the budget must not be increased in response.

## What the platform does and does not promise

Khronos GLSL ES 3.00 revision 6, §4.5.1, PDF pages 58–59, gives operation
accuracy for highp addition, subtraction, multiplication, division and logarithm.
It permits flushing subnormal values to zero. Trigonometric functions have no
specified precision. The corresponding current GLSL ES 3.20 §4.7.1 preserves
this distinction. Thus highp alone cannot prove an atan2 error budget. The
shader avoids atan2(0,0) and log(0) by construction; those domain preconditions
remain independently checked.

Primary sources:

- [GLSL ES 3.00, revision 6](https://registry.khronos.org/OpenGL/specs/es/3.0/GLSL_ES_Specification_3.00.pdf#page=59)
- [GLSL ES 3.20, range and precision](https://registry.khronos.org/OpenGL/specs/es/3.2/GLSL_ES_Specification_3.20.html#range-and-precision)

## Application accuracy and the existing colour budget

Keep the existing one-RGB8-level regular-point budget unchanged. Add mandatory
raw numerical comparisons: circular phase error at most 10⁻⁴ radians and raw
log-modulus error at most 10⁻⁴. The binary64 host budget remains 2×10⁻¹².
Phase uses its circular distance; log modulus is never reduced by log(10).
Consequently a whole colour-period shift in log modulus still fails.

The scale comes from the shared palette, not GPU output. Away from its band
seams, lightness lies between 66 and 73, the u′ and v′ denominators stay bounded
away from zero, and the sRGB transfer slope is at most 12.92. Bounding the
derivatives of the documented L*u*v* conversion over that box gives conservative
normalized-channel sensitivities below 17 per phase radian and 10 per unit of
log modulus. The two 10⁻⁴ budgets therefore contribute less than 0.0027 in a
channel, below 1/255 ≈ 0.003922. This motivates a field accuracy target tighter
than the established display budget. It does not turn that local derivative
bound into a global continuity claim, nor reserve the whole display budget for
field error: the actual final RGBA8 bytes must independently meet the original
one-level limit. The independent CPU palette retains its existing 2×10⁻⁵
floating-point fixture agreement.

For a checkable conservative derivative calculation, use
Y ≤ 0.452, |∂Y/∂L| ≤ 0.0153, u′ ∈ [0.1453, 0.2504],
v′ ∈ [0.4158, 0.5209], |∂L/∂phase| ≤ 1.719 and
|∂L/∂log_modulus| ≤ 1.738. Differentiating the rational XYZ expressions over
that box gives the following outward-rounded component bounds:

| Input change | Bound on ∂X | Bound on ∂Y | Bound on ∂Z | Maximum normalized RGB slope |
| --- | ---: | ---: | ---: | ---: |
| One phase radian | 0.250 | 0.0264 | 0.835 | less than 17 |
| One unit log modulus | 0.043 | 0.0266 | 0.355 | less than 5, bounded here by 10 |

For example, the red phase derivative is at most
12.92 × (3.2404542 × 0.250 + 1.5371385 × 0.0264 +
0.4985314 × 0.835) < 17. The other matrix rows give smaller bounds.
Clipping channels to [0,1] cannot enlarge these interior Lipschitz bounds.

The palette has genuine discontinuities at log-modulus decades and hue bands
of 100 degrees. Samples within the declared numerical budget of a seam receive
an explicit boundary classification. The same raw and RGB budgets still apply;
no seam exemption, automatic skip, extra RGB allowance or post-failure choice
of side is permitted. True zeros/poles use exact signed order and the canonical
black/white endpoint, with exact RGBA8 matching.

## Source arithmetic envelope for raw log modulus

The shader has five complex Horner multiplications (30 scalar operations), four
complex coefficient additions (8), and two coordinate normalizations. Each
reduced factor uses scaled coordinates, two divisions, two logarithms and
bounded scalar arithmetic; no raw product or exp(q) is formed. The current
corpus has at most 48 uncancelled factors, integer multiplicities and exact
binary32 inputs. The extreme-radius probes use 2⁶⁰ and 2⁻⁶⁰, keeping the scaled
norm between one and two and avoiding subnormal intermediates.

Use ε = 2⁻²³, a full binary32 ULP relative allowance, and
γ(n) = nε ÷ (1 − nε). A conservative reference-computable log envelope is:

    Σ |order| × (64ε + 8ε × |log(radius)|)
      + γ(number_of_factors + 2) × (|Re(q)| + Σ |order × log(radius)|)
      + γ(128) × Σ (degree + 1) × |coefficient × (z/3)^degree|.

The first term covers coordinate subtraction, the 2.5-ULP divisions, scaled
norm arithmetic, the stated log error and multiplication by integer order.
The second covers accumulation and adding q. The final term deliberately
overcounts the polynomial normalization/Horner roundoff, including cancellation
conditioning through the absolute term sum. Fused operations can reduce these
errors; they do not justify widening the bound. The verifier requires the
measured raw-log error to fit both this envelope and the 10⁻⁴ application target.
This envelope is deliberately specific to the current normal-input corpus;
it is not an arbitrary-range guarantee. Any future domain extension requires
its own source and range argument before observing that domain's output.

## Range and loss of contributions

The retained large-q/small-divisor witness demonstrates a real binary32 limit:
a nonzero divisor increment may be smaller than the ULP of q. Period reduction
before colouring can preserve a visible contribution but cannot repair a raw
measurement already erased in binary32. `produced=0` rejects such an unqualified
raw sample. It cannot pass as a successful sample, missing data, or an accepted
colour-only equivalent. All 34 required probes must actually produce both raw
and RGBA8 output from the same selected generated program.
