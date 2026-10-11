/* Independent Sublixel geometry acceptance oracle.
 *
 * This file belongs to ai-ci, NOT rough.framebuffer. It computes exact rational
 * subpixel occupancy from the chosen analytic curves, independently from the
 * implementation's local frame, pixel_mask or stored reference fixtures.
 * Compiled exclusively by pinned owned ICK in the acceptance workflow.
 */
#include "sublixel/curve_patch.h"

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void fail(const char *message, int y, int x, double actual, double expected) {
    fprintf(stderr, "AICI_SUBLIXEL_REJECT %s cell=(%d,%d) got=%.17g expected=%.17g\n",
            message, y, x, actual, expected);
    exit(1);
}
static void require(int expression, const char *message) {
    if (!expression) fail(message, 0, 0, 0, 1);
}
static void near(double actual, double expected, const char *message) {
    if (!isfinite(actual) || fabs(actual - expected) > 1e-12)
        fail(message, 0, 0, actual, expected);
}
static cp_vec2 point(double x, double y) { return (cp_vec2){x, y}; }

static unsigned occupancy3(int x, int y, int origin_x16, int origin_y16,
                           int curvature_sign) {
    unsigned result = 0;
    for (int sy = 0; sy != 8; ++sy)
        for (int sx = 0; sx != 8; ++sx) {
            int64_t u16 = 16 * x + 2 * sx - 7 - origin_x16;
            int64_t v16 = 16 * y + 2 * sy - 7 - origin_y16;
            int64_t residual1024 = 64 * v16 - curvature_sign * u16 * u16;
            if (u16 >= -48 && u16 <= 48 &&
                residual1024 >= -192 && residual1024 <= 192)
                ++result;
        }
    return result;
}
static unsigned occupancy5(int x, int y, int origin_x16, int origin_y16,
                           int quadratic_sign, int cubic_sign) {
    unsigned result = 0;
    for (int sy = 0; sy != 8; ++sy)
        for (int sx = 0; sx != 8; ++sx) {
            int64_t u16 = 16 * x + 2 * sx - 7 - origin_x16;
            int64_t v16 = 16 * y + 2 * sy - 7 - origin_y16;
            int64_t residual65536 = 4096 * v16 -
                                    64 * quadratic_sign * u16 * u16 -
                                    cubic_sign * u16 * u16 * u16;
            if (u16 >= -48 && u16 <= 48 &&
                residual65536 >= -12288 && residual65536 <= 12288)
                ++result;
        }
    return result;
}

static void verify_grid3(cp_curve_patch *patch, int x16, int y16, int sign) {
    double coverage[3][3];
    require(cp_patch_cover_3x3(patch, 0, 0, coverage) == CP_OK,
            "3x3 coverage refused");
    for (int y = 0; y != 3; ++y)
        for (int x = 0; x != 3; ++x) {
            double expected = (double)occupancy3(x - 1, y - 1, x16, y16, sign) / 64.0;
            if (coverage[y][x] != expected)
                fail("3x3 integer-rational oracle", y, x, coverage[y][x], expected);
            double individual = -1;
            require(cp_patch_coverage_pixel(patch, x - 1, y - 1, &individual) == CP_OK,
                    "3x3 single pixel refused");
            if (individual != expected)
                fail("3x3 individual pixel", y, x, individual, expected);
        }
}

static void verify_grid5(cp_curve_patch *patch, int x16, int y16,
                         int quadratic_sign, int cubic_sign) {
    double coverage[5][5];
    require(cp_patch_cover_5x5(patch, 0, 0, coverage) == CP_OK,
            "5x5 coverage refused");
    for (int y = 0; y != 5; ++y)
        for (int x = 0; x != 5; ++x) {
            double expected = (double)occupancy5(x - 2, y - 2, x16, y16,
                                                  quadratic_sign, cubic_sign) / 64.0;
            if (coverage[y][x] != expected)
                fail("5x5 integer-rational oracle", y, x, coverage[y][x], expected);
            double individual = -1;
            require(cp_patch_coverage_pixel_cubic(patch, x - 2, y - 2,
                                                   &individual) == CP_OK,
                    "5x5 single pixel refused");
            if (individual != expected)
                fail("5x5 individual pixel", y, x, individual, expected);
        }
}

static void test_3x3(void) {
    /* The exact parabola y = (x-.25)^2/4 - .125.
       a2=1/4, half_width=3/16, tangent domain [-3,3]. */
    cp_vec2 origin = point(0.25, -0.125);
    cp_curve_patch p;
    require(cp_patch_from_jet2(&p, origin, point(1, 0), point(0, 0.5),
                               3.0 / 16.0, 3) == CP_OK,
            "3x3 regular jet refused");
    near(p.a2, 0.25, "3x3 curvature coefficient");
    verify_grid3(&p, 4, -2, 1);

    /* Chain rule for t = 2s + s^2: D1=(2,0), D2=(2,2). */
    require(cp_patch_from_jet2(&p, origin, point(2, 0), point(2, 2),
                               3.0 / 16.0, 3) == CP_OK,
            "3x3 nonlinear reparameterization refused");
    verify_grid3(&p, 4, -2, 1);

    /* Reverse orientation: normal and signed curvature both change sign,
       but the world-space occupancy is identical. */
    require(cp_patch_from_jet2(&p, origin, point(-1, 0), point(0, 0.5),
                               3.0 / 16.0, 3) == CP_OK,
            "3x3 reverse curve refused");
    near(p.a2, -0.25, "3x3 reverse curvature");
    verify_grid3(&p, 4, -2, 1);

    /* Negative physical curvature (a2=-1/4). */
    require(cp_patch_from_jet2(&p, origin, point(1, 0), point(0, -0.5),
                               3.0 / 16.0, 3) == CP_OK,
            "3x3 negative curvature refused");
    verify_grid3(&p, 4, -2, -1);
}

static void test_5x5(void) {
    /* The exact local polynomial:
       y = ((x-.25)^2)/4 + ((x-.25)^3)/16 - .125.
       D1=(1,0), D2=(0,1/2), D3=(0,3/8). */
    cp_vec2 origin = point(0.25, -0.125);
    cp_curve_patch p;
    require(cp_patch_from_jet3(&p, origin, point(1, 0), point(0, 0.5),
                               point(0, 0.375), 3.0 / 16.0, 3) == CP_OK,
            "5x5 regular cubic jet refused");
    near(p.a2, 0.25, "5x5 quadratic coefficient");
    near(p.a3, 1.0 / 16.0, "5x5 cubic coefficient");
    verify_grid5(&p, 4, -2, 1, 1);

    /* Independent chain-rule values for t = 2s + s^2. */
    require(cp_patch_from_jet3(&p, origin, point(2, 0), point(2, 2),
                               point(0, 9), 3.0 / 16.0, 3) == CP_OK,
            "5x5 nonlinear reparameterization refused");
    verify_grid5(&p, 4, -2, 1, 1);

    /* Reversed t = -2s + s^2. */
    require(cp_patch_from_jet3(&p, origin, point(-2, 0), point(2, 2),
                               point(0, -9), 3.0 / 16.0, 3) == CP_OK,
            "5x5 reversed nonlinear parameter refused");
    near(p.a2, -0.25, "5x5 reverse quadratic");
    near(p.a3, 1.0 / 16.0, "5x5 reverse cubic");
    verify_grid5(&p, 4, -2, 1, 1);

    /* Cubic sign reversal, tested at every subpixel. */
    require(cp_patch_from_jet3(&p, origin, point(1, 0), point(0, 0.5),
                               point(0, -0.375), 3.0 / 16.0, 3) == CP_OK,
            "5x5 negative cubic refused");
    verify_grid5(&p, 4, -2, 1, -1);
}

static void test_accumulation_and_failure(void) {
    cp_curve_patch whole, first, second;
    require(cp_patch_from_segment(&whole, point(-3, 0), point(3, 0),
                                  0.25) == CP_OK, "segment whole");
    require(cp_patch_from_segment(&first, point(-3, 0), point(0, 0),
                                  0.25) == CP_OK, "segment first");
    require(cp_patch_from_segment(&second, point(0, 0), point(3, 0),
                                  0.25) == CP_OK, "segment second");
    cp_accumulator_3x3 once, split;
    cp_patch_accumulator_3x3_init(&once, 0, 0);
    cp_patch_accumulator_3x3_init(&split, 0, 0);
    require(cp_patch_accumulate_3x3(&once, &whole) == CP_OK, "accumulate whole3");
    cp_accumulator_3x3 copy = once;
    require(cp_patch_accumulate_3x3(&once, &whole) == CP_OK, "accumulate twice3");
    require(memcmp(&once, &copy, sizeof once) == 0, "3x3 duplicate darkening");
    require(cp_patch_accumulate_3x3(&split, &first) == CP_OK, "3x3 first half");
    require(cp_patch_accumulate_3x3(&split, &second) == CP_OK, "3x3 second half");
    require(memcmp(&split, &copy, sizeof split) == 0, "3x3 partition mismatch");

    cp_accumulator_5x5 once5, split5;
    cp_patch_accumulator_5x5_init(&once5, 0, 0);
    cp_patch_accumulator_5x5_init(&split5, 0, 0);
    require(cp_patch_accumulate_5x5(&once5, &whole) == CP_OK, "accumulate whole5");
    cp_accumulator_5x5 copy5 = once5;
    require(cp_patch_accumulate_5x5(&once5, &whole) == CP_OK, "accumulate twice5");
    require(memcmp(&once5, &copy5, sizeof once5) == 0, "5x5 duplicate darkening");
    require(cp_patch_accumulate_5x5(&split5, &first) == CP_OK, "5x5 first half");
    require(cp_patch_accumulate_5x5(&split5, &second) == CP_OK, "5x5 second half");
    require(memcmp(&split5, &copy5, sizeof split5) == 0, "5x5 partition mismatch");

    whole.a3 = 1e308;  /* Valid field, invalid sampled cubic graph. */
    require(cp_patch_accumulate_5x5(&once5, &whole) == CP_OVERFLOW,
            "5x5 overflow not rejected");
    require(memcmp(&once5, &copy5, sizeof once5) == 0,
            "5x5 partial write after failure");

    cp_curve_patch sentinel = {0};
    sentinel.origin.x = 91;
    require(cp_patch_from_jet3(&sentinel, point(0, 0), point(0, 0),
                               point(0, 1), point(0, 1), 0.2, 2) == CP_SINGULAR,
            "5x5 cusp not rejected");
    near(sentinel.origin.x, 91, "5x5 cusp mutated output");
    require(cp_patch_from_jet2(&sentinel, point(0, 0), point(NAN, 0),
                               point(0, 1), 0.2, 2) == CP_INVALID,
            "3x3 nonfinite not rejected");
    near(sentinel.origin.x, 91, "3x3 nonfinite mutated output");
}

int main(void) {
    test_3x3();
    test_5x5();
    test_accumulation_and_failure();
    puts("aici independent subpixel curvature oracle: PASS");
    return 0;
}
