# Separate large-q coverage, declared before GPU output

The original 34 positive GPU samples use small q; their extreme-radius cases
sample z = 0 and therefore also have q = 0. They cannot establish that the
generated shader detects an erased divisor increment or retains it in the
coordinates passed to Wegert. This diagnostic supplements those cases. Their
existing inputs, counts, phase/log/RGBA8 budgets and policy digest stay unchanged.

Both draws use the same selected live generated program, world point
1000 + 1000i, c₁ = 3 and all other coefficients zero, with no remote poles.
The baseline has no divisor. The pair has one zero at 0 and one pole at the
actual binary32 upload value of 0.04. Independent binary64 evaluation of
z ÷ (z − pole) gives a negative phase increment of approximately −2×10⁻⁵
and a positive log-modulus increment of approximately 2×10⁻⁵. They are real
divisor contributions, not an exact cancellable pair.

At q ≈ 1000 + 1000i a binary32 ULP is 2⁻¹⁴ ≈ 6.1035×10⁻⁵. Each increment
is below half an ULP. The expected raw result is therefore an explicitly
unqualified range, rejected by the shader's `produced=0` marker. The baseline
must produce marker one. Both must still return finite q-sized phase/log
channels, exact zero singularity order and no graphics error. At least one raw
pair channel must equal the corresponding baseline channel: the output is an
executed, observable loss-of-increment case, not missing data labelled as a
successful rejection. NaN/sentinel clear values, absent rows, compile failure
or graphics failure can never satisfy this diagnostic.

The q-identity guard permits eight binary32 ULPs per raw component. This is a
source-operation guard on the rejected-domain diagnostic, not acceptance of
the pair's raw mathematical field or a relaxation of the original 34 samples.
For this one-term polynomial, the normalization/division and final multiply
have a conservative component bound
2.5×ULP(1/3)×1000×3 + ULP(1000/3)×3 + ULP(1000)
≈ 0.0003761, below eight ULPs of 1000 ≈ 0.0004883. This covers the stated
GLSL highp arithmetic allowances. The normal raw-field policy remains separate.

Mode three returns the actual `colour_measure` coordinates already consumed
by the shared Wegert function, plus order and a finite-output marker. It must
produce marker one for both inputs. Compare each coordinate with the binary64
reference at the original 10⁻⁴ absolute budget, and compare the baseline-to-pair
increment at a new, stricter 2×10⁻⁶ absolute budget per channel. Phase differences
use circular distance. Each observed increment must be nonzero and have the
independent divisor's sign. A dropped increment or its negative cannot pass.

The delta target is about one tenth of the known nonzero signal. After period
reduction the coordinates are bounded by 2π and log(10), so the two-output
binary32 subtraction contributes less than approximately 2×10⁻⁶ by itself;
the application target deliberately demands that the complete calculation also
meet 2×10⁻⁶. For the actual q≈1000 residues, the output spacing is about
6×10⁻⁸, roughly 33 times smaller than the target. The platform does not promise
atan accuracy, and worst-case primitive log allowances can be larger. This is
therefore a predeclared application increment-accuracy requirement to qualify
the tested implementation, not a claim of guaranteed vendor accuracy. Failure
must cause implementation repair or an explicit unqualified-domain result;
the target must not be widened after reading output.

Finally read actual RGBA8 output from mode two of the same program for both
inputs and compare the existing canonical binary64 Wegert reference at the
unchanged one-level channel budget and exact alpha 255. Colour bytes alone
cannot prove the tiny increment survived, which is why mode three and its
independent delta comparison are mandatory. A successful guard/retention
diagnostic still does not qualify the raw large-q pair, other large-q values,
physical devices or sustained performance.
