/* Independent AICI witness. Hand-derived values for six polynomial cases,
 * independent of Holomorphic's generated case set and cpow oracle.
 * Production holomorphic_walk.c is compiled via -include before this file.
 * This does NOT observe GLSL or choose a CPU sampling policy.
 */
#include <math.h>
#include <stdio.h>

static int check_observation(const char *label, const float coefficients[5][2],
                             float ux, float uy, double vr, double vi,
                             double dr, double di) {
    float value[2], du[2];
    direction_at(coefficients, ux, uy, value, du);
    double values[4] = {value[0], value[1], du[0], du[1]};
    double expected[4] = {vr, vi, dr, di};
    const char *kinds[4] = {"Re(delta_q)", "Im(delta_q)", "Re(dq/du)", "Im(dq/du)"};
    int errors = 0;
    for (int channel = 0; channel < 4; ++channel) {
        if (!isfinite(values[channel]) || fabs(values[channel] - expected[channel]) > 2e-6) {
            fprintf(stderr, "AICI-SEMANTIC-MISMATCH case=%s channel=%s actual=%.9g expected=%.17g\n",
                    label, kinds[channel], values[channel], expected[channel]);
            ++errors;
        }
    }
    return errors;
}

int main(void) {
    _Static_assert(HOLOMORPHIC_WALK_COEFFICIENT_COUNT == 5,
                   "witness only qualifies a five-term polynomial");
    float c[5][2] = {{0}};
    int bad = 0;
    c[4][0] = 1.0f;
    bad += check_observation("fifth-real-z1-u=z/3", c, 1.0f/3.0f, 0,
                             1.0/243.0, 0, 5.0/81.0, 0);
    bad += check_observation("fifth-pure-imag", c, 0, 0.5f,
                             0, 1.0/32.0, 5.0/16.0, 0);
    c[4][0] = 0;
    c[0][0] = 2; c[0][1] = -1;
    bad += check_observation("linear-complex", c, -0.25f, 0.5f,
                             0, 1.25, 2, -1);
    c[0][0] = 0; c[0][1] = 0;
    c[1][1] = 1;
    bad += check_observation("quadratic-imaginary-coefficient", c, 0, 0.5f,
                             0, -0.25, -1, 0);
    c[1][1] = 0;
    c[2][0] = 1; c[2][1] = 1;
    bad += check_observation("cubic-complex-coefficient", c, 0.5f, 0,
                             0.125, 0.125, 0.75, 0.75);
    c[2][0] = 0; c[2][1] = 0;
    c[3][0] = -2;
    bad += check_observation("quartic-negative-real", c, -0.5f, 0,
                             -0.125, 0, 1, 0);
    if (bad) {
        fprintf(stderr, "AICI-SEMANTIC-FAIL errors=%d\n", bad);
        return 1;
    }
    puts("AICI-SEMANTIC-PASS cases=6 oracle=hand-derived-binary64-polynomial target=host-CPU-direction-at");
    return 0;
}
