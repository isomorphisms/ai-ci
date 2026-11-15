/* Independent Subpixel geometry acceptance oracle.
 *
 * This file belongs to ai-ci, NOT rough.framebuffer. It computes exact rational
 * subpixel occupancy from the chosen analytic curves, independently from the
 * implementation's local frame, pixel_mask or stored reference fixtures.
 * Compiled exclusively by pinned owned ICK in the acceptance workflow.
 */
#include "subpixel/curve_patch.h"
#include "subpixel/coverage_plane.h"
#include "subpixel_framebuffer.h"

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void fail(const char *message, int y, int x, double actual, double expected) {
    fprintf(stderr, "AICI_SUBPIXEL_REJECT %s cell=(%d,%d) got=%.17g expected=%.17g\n",
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


/* Independent integer/rational checks for the new global occupancy consumer.
 * No producer test arrays or image hashes are consulted. */
static void test_coverage_plane_and_framebuffer(void) {
    uint64_t occupied[35] = {0};
    cp_coverage_plane plane = {occupied, 35, 7, 5, 5, -2, -2};
    cp_curve_patch first, second;
    require(cp_patch_from_segment(&first, point(-3, 0), point(3, 0),
                                  0.25) == CP_OK, "coverage first band");
    require(cp_patch_from_segment(&second, point(-3, 0.375), point(3, 0.375),
                                  0.0625) == CP_OK, "coverage second band");
    require(cp_coverage_plane_accumulate_3x3(&plane, &first, 0, 0) == CP_OK,
            "coverage first neighborhood");
    require(cp_coverage_plane_accumulate_5x5(&plane, &second, 0, 0) == CP_OK,
            "coverage second neighborhood");
    for (int row = 0; row < 5; ++row)
        for (int column = 0; column < 7; ++column) {
            uint64_t expected = 0;
            if (column < 5)
                for (int sample_y = 0; sample_y < 8; ++sample_y)
                    for (int sample_x = 0; sample_x < 8; ++sample_x) {
                        int y16 = 16 * (row - 2) + 2 * sample_y - 7;
                        int in_first_grid = row >= 1 && row <= 3 &&
                                            column >= 1 && column <= 3;
                        int first_hit = in_first_grid && y16 >= -4 && y16 <= 4;
                        int second_hit = y16 - 6 >= -1 && y16 - 6 <= 1;
                        if (first_hit || second_hit)
                            expected |= UINT64_C(1) << (sample_y * 8 + sample_x);
                    }
            require(occupied[row * 7 + column] == expected,
                    "coverage plane rational union");
        }
    uint64_t before[35];
    memcpy(before, occupied, sizeof before);
    first.a2 = NAN;
    require(cp_coverage_plane_accumulate_3x3(&plane, &first, 0, 0) == CP_INVALID,
            "coverage plane invalid patch");
    require(memcmp(before, occupied, sizeof before) == 0,
            "coverage plane transactional failure");

    for (unsigned count = 0; count <= 64; ++count) {
        uint64_t mask = count == 64 ? UINT64_MAX :
            count == 0 ? 0 : (UINT64_C(1) << count) - 1;
        cp_coverage_plane one = {&mask, 1, 1, 1, 1, 1, 0};
        uint32_t pixels[4] = {UINT32_C(0xffabcdef), UINT32_C(0x800000ff),
                              UINT32_C(0x12345678), UINT32_C(0x87654321)};
        rough_framebuffer target = {
            .pixels = pixels, .width = 2, .height = 1, .stride_pixels = 4
        };
        require(rough_blend_subpixel_coverage(&target, &one,
                    UINT32_C(0xffff0000), 1.0) == 0, "framebuffer composition");
        /* Alpha numerator has denominator 64 after multiplication by 255.
         * RGB divides the independent premultiplied red/blue numerators by
         * the total alpha numerator. Round rational values to nearest byte. */
        unsigned total = 255 * count + 128 * (64 - count);
        unsigned alpha = (total + 32) / 64;
        unsigned red = (255 * 255 * count + total / 2) / total;
        unsigned blue = (255 * 128 * (64 - count) + total / 2) / total;
        uint32_t expected = (uint32_t)(alpha << 24) |
                            (uint32_t)(red << 16) | blue;
        require(pixels[1] == expected, "framebuffer rational alpha");
        require(pixels[0] == UINT32_C(0xffabcdef) &&
                pixels[2] == UINT32_C(0x12345678) &&
                pixels[3] == UINT32_C(0x87654321), "framebuffer padded clipping");
    }
}

static unsigned rational_byte(uint64_t numerator,uint64_t denominator) {
    return (unsigned)((numerator+denominator/2)/denominator);
}
static void test_translucent_rounding(void) {
    const unsigned alphas[]={0,1,64,128,136,254,255};
    const unsigned destination_alphas[]={0,1,128,255};
    const unsigned opacity_denominators[]={1,2,8};
    const uint32_t colors[]={0xff0000,0x0000ff,0x1a7fc3};
    const uint32_t backgrounds[]={0xf4e9d8,0x695bcd,0x000000,0xffffff};
    unsigned cases=0;
    for(unsigned source_alpha_index=0;source_alpha_index<7;source_alpha_index++)
    for(unsigned destination_alpha_index=0;destination_alpha_index<4;destination_alpha_index++)
    for(unsigned opacity_index=0;opacity_index<3;opacity_index++)
    for(unsigned color_index=0;color_index<3;color_index++)
    for(unsigned background_index=0;background_index<4;background_index++)
    for(unsigned count=0;count<=64;count++) {
        unsigned source_alpha=alphas[source_alpha_index],destination_alpha=destination_alphas[destination_alpha_index];
        unsigned opacity_denominator=opacity_denominators[opacity_index];
        uint64_t mask=count==64?UINT64_MAX:count?(UINT64_C(1)<<count)-1:0;
        uint32_t source=(source_alpha<<24)|colors[color_index];
        uint32_t actual=(destination_alpha<<24)|backgrounds[background_index],before=actual;
        cp_coverage_plane plane={&mask,1,1,1,1,0,0};
        rough_framebuffer target={&actual,1,1,1};
        require(rough_blend_subpixel_coverage(&target,&plane,source,1.0/opacity_denominator)==0,"translucent rational invocation");
        uint32_t expected=before;
        if(source_alpha&&count) {
            uint64_t common=255*64*opacity_denominator;
            uint64_t source_weight=255*source_alpha*count;
            uint64_t destination_weight=destination_alpha*(common-source_alpha*count);
            uint64_t total=source_weight+destination_weight;
            expected=rational_byte(total,common)<<24;
            for(unsigned shift=0;shift<24;shift+=8)
                expected|=rational_byte(((source>>shift)&255)*source_weight+((before>>shift)&255)*destination_weight,total)<<shift;
        }
        if(actual!=expected)fail("translucent integer-rational byte rounding",(int)source_alpha,(int)count,actual,expected);
        cases++;
    }
    printf("independent translucent rational cases: %u PASS\n",cases);
}

int main(void) {
    test_3x3();
    test_5x5();
    test_accumulation_and_failure();
    test_coverage_plane_and_framebuffer();
    test_translucent_rounding();
    puts("aici independent subpixel curvature oracle: PASS");
    return 0;
}
