/* Independent, output-facing verifier for rough.framebuffer's pinned
 * mathematical-surface candidate. This does not call its surface generator's
 * sampling/projection functions or import the author's tests. It checks the
 * emitted wire format, independent analytic anchors, and actual framebuffer
 * pixels/depth. Malformed or absent evidence fails closed.
 */
#include "framebuffer.h"

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { WIDTH = 160, HEIGHT = 160, TORUS_U = 56, TORUS_V = 28 };

typedef struct {
    unsigned face_count;
    unsigned near_vertices;
    unsigned palette[TORUS_U][TORUS_V][3];
    unsigned low[3], high[3];
    double first_vertex[3];
    double min_depth, max_depth;
} scene;

static int fail(const char *reason) {
    fprintf(stderr, "FAIL %s\n", reason);
    return 1;
}

#define REQUIRE(expression, diagnostic) \
    do { if (!(expression)) return fail(diagnostic); } while (0)

static unsigned difference(unsigned a, unsigned b) {
    return a >= b ? a - b : b - a;
}

/* Check actual stream grammar and numerical invariants. The fixed mesh counts
 * are properties of this pinned candidate, not a permanent public API. */
static int inspect(const char *filename, scene *s, int torus, int near_case) {
    FILE *f = fopen(filename, "rb");
    REQUIRE(f != NULL, "MISSING_OPERATIONS");

    memset(s, 0, sizeof *s);
    for (unsigned channel = 0; channel < 3; ++channel) s->low[channel] = 255;
    s->min_depth = INFINITY;
    s->max_depth = -INFINITY;
    char line[512];
    int color_pending = 0;
    unsigned current[3] = {0, 0, 0};
    while (fgets(line, sizeof line, f)) {
        unsigned r, g, b;
        char extra;
        double values[9];
        REQUIRE(strchr(line, '\n') != NULL, "TRUNCATED_OPERATION_LINE");
        if (line[0] == 'P') {
            REQUIRE(!color_pending, "DUPLICATE_COLOR_COMMAND");
            REQUIRE(sscanf(line, "P %u %u %u %c", &r, &g, &b, &extra) == 3,
                    "INVALID_COLOR_SYNTAX");
            REQUIRE(r <= 255 && g <= 255 && b <= 255,
                    "INVALID_COLOR_RANGE");
            current[0] = r;
            current[1] = g;
            current[2] = b;
            color_pending = 1;
        } else if (line[0] == 'T') {
            REQUIRE(color_pending, "MISSING_COLOR_COMMAND");
            REQUIRE(sscanf(line,
                           "T %lf %lf %lf %lf %lf %lf %lf %lf %lf %c",
                           &values[0], &values[1], &values[2],
                           &values[3], &values[4], &values[5],
                           &values[6], &values[7], &values[8], &extra) == 9,
                    "INVALID_TRIANGLE_SYNTAX");
            for (unsigned field = 0; field < 9; ++field)
                REQUIRE(isfinite(values[field]), "NONFINITE_TRIANGLE");
            for (unsigned vertex = 2; vertex < 9; vertex += 3) {
                REQUIRE(values[vertex] >= 0.0 && values[vertex] < 1.0,
                        "DEPTH_OUT_OF_RANGE");
                if (values[vertex] == 0.0) ++s->near_vertices;
                if (values[vertex] < s->min_depth) s->min_depth = values[vertex];
                if (values[vertex] > s->max_depth) s->max_depth = values[vertex];
            }
            if (s->face_count == 0) {
                s->first_vertex[0] = values[0];
                s->first_vertex[1] = values[1];
                s->first_vertex[2] = values[2];
            }
            for (unsigned channel = 0; channel < 3; ++channel) {
                if (current[channel] < s->low[channel])
                    s->low[channel] = current[channel];
                if (current[channel] > s->high[channel])
                    s->high[channel] = current[channel];
            }
            if (torus && !near_case && s->face_count % 2u == 0u &&
                s->face_count / 2u < TORUS_U * TORUS_V) {
                unsigned cell = s->face_count / 2u;
                unsigned i = cell / TORUS_V;
                unsigned j = cell % TORUS_V;
                for (unsigned channel = 0; channel < 3; ++channel)
                    s->palette[i][j][channel] = current[channel];
            }
            ++s->face_count;
            color_pending = 0;
        } else return fail("UNEXPECTED_OPERATION");
    }
    REQUIRE(!ferror(f) && fclose(f) == 0, "OPERATIONS_READ_ERROR");
    REQUIRE(!color_pending && s->face_count > 100u,
            "MISSING_RENDERABLE_GEOMETRY");
    REQUIRE(s->max_depth - s->min_depth > 0.005, "CONSTANT_DEPTH");
    REQUIRE(s->high[0] - s->low[0] >= 35 &&
            s->high[2] - s->low[2] >= 35, "DEGENERATE_COLOR_PALETTE");

    if (torus && !near_case) {
        REQUIRE(s->face_count == 2u * TORUS_U * TORUS_V,
                "TORUS_MESH_TOPOLOGY");
        /* Torus at u=v=0 is (1.61,0,0). Fixed pitch does not displace
         * it at yaw 0. Screen center (79.5,79.5), f=0.88*160. */
        /* The analytic anchor is only applied to the zero-degree sample;
         * angle-37 and periodic-equivalent cases have separate tests. */
    }
    if (near_case) REQUIRE(s->near_vertices > 0, "NEAR_PLANE_NOT_CLIPPED");
    return 0;
}

static int check_torus_seam(const scene *s) {
    for (unsigned channel = 0; channel < 3; ++channel) {
        for (unsigned j = 0; j < TORUS_V; ++j) {
            REQUIRE(difference(s->palette[0][j][channel],
                               s->palette[TORUS_U - 1][j][channel]) <= 28u,
                    "TORUS_PALETTE_SEAM");
        }
        for (unsigned i = 0; i < TORUS_U; ++i) {
            REQUIRE(difference(s->palette[i][0][channel],
                               s->palette[i][TORUS_V - 1][channel]) <= 28u,
                    "TORUS_PALETTE_SEAM");
        }
    }
    return 0;
}

static int same_files(const char *a, const char *b, int *equal) {
    FILE *left = fopen(a, "rb");
    FILE *right = fopen(b, "rb");
    REQUIRE(left && right, "MISSING_ANGLE_COMPARISON");
    *equal = 1;
    for (;;) {
        int x = fgetc(left), y = fgetc(right);
        if (x != y) { *equal = 0; break; }
        if (x == EOF) break;
    }
    REQUIRE(!ferror(left) && !ferror(right), "ANGLE_COMPARISON_READ_ERROR");
    REQUIRE(fclose(left) == 0 && fclose(right) == 0,
            "ANGLE_COMPARISON_CLOSE_ERROR");
    return 0;
}

static int check_depth_api(void) {
    uint32_t pixels[8u * 8u];
    float depth[8u * 8u];
    for (unsigned i = 0; i < 64; ++i) {
        pixels[i] = 0xffffffffu;
        depth[i] = INFINITY;
    }
    rough_framebuffer target = {pixels, 8, 8, 8, depth, 8};
    rough_vertex a = {1, 1, 0.8}, b = {6, 1, 0.8}, c = {1, 6, 0.8};
    REQUIRE(rough_fill_triangle(&target, a, b, c, 0xffcc2211u, 1) == 0,
            "TRIANGLE_API_ERROR");
    REQUIRE(pixels[2u * 8u + 2u] == 0xffcc2211u, "FAR_TRIANGLE_MISSING");
    a.depth = b.depth = c.depth = 0.2;
    REQUIRE(rough_fill_triangle(&target, a, c, b, 0xff1133ccu, 1) == 0,
            "REVERSED_WINDING_ERROR");
    REQUIRE(pixels[2u * 8u + 2u] == 0xff1133ccu, "NEAR_TRIANGLE_MISSING");
    REQUIRE(fabsf(depth[2u * 8u + 2u] - 0.2f) < 1e-6f,
            "DEPTH_NOT_WRITTEN");
    a.depth = b.depth = c.depth = 0.95;
    REQUIRE(rough_fill_triangle(&target, a, b, c, 0xff11cc33u, 1) == 0,
            "DEPTH_API_ERROR");
    REQUIRE(pixels[2u * 8u + 2u] == 0xff1133ccu, "OCCLUDED_FACE_VISIBLE");
    a.depth = b.depth = c.depth = 0.01;
    REQUIRE(rough_fill_triangle(&target, a, b, c, 0xff11cc33u, 0) == 0,
            "TRANSPARENT_API_ERROR");
    REQUIRE(pixels[2u * 8u + 2u] == 0xff1133ccu &&
            fabsf(depth[2u * 8u + 2u] - 0.2f) < 1e-6f,
            "TRANSPARENT_FACE_OCCLUDED");
    return 0;
}

static int render_matches_ppm(const char *operations, const char *ppm,
                              unsigned *painted) {
    uint32_t pixels[WIDTH * HEIGHT];
    float depths[WIDTH * HEIGHT];
    for (unsigned i = 0; i < WIDTH * HEIGHT; ++i) {
        pixels[i] = 0xffffffffu;
        depths[i] = INFINITY;
    }
    rough_framebuffer target = {pixels, WIDTH, HEIGHT, WIDTH, depths, WIDTH};
    FILE *input = fopen(operations, "rb");
    REQUIRE(input != NULL, "MISSING_RENDER_INPUT");
    int result = rough_render_stream(input, &target);
    REQUIRE(fclose(input) == 0 && result == 0, "RENDERER_DID_NOT_CONSUME_STREAM");

    FILE *image = fopen(ppm, "rb");
    REQUIRE(image != NULL, "MISSING_FRAME");
    static const unsigned char header[] = "P6\n160 160\n255\n";
    unsigned char actual[sizeof header - 1];
    REQUIRE(fread(actual, 1, sizeof actual, image) == sizeof actual &&
            memcmp(actual, header, sizeof actual) == 0, "INVALID_FRAME_HEADER");
    *painted = 0;
    for (unsigned i = 0; i < WIDTH * HEIGHT; ++i) {
        unsigned char rgb[3];
        REQUIRE(fread(rgb, 1, 3, image) == 3, "TRUNCATED_FRAME");
        uint32_t color = pixels[i];
        REQUIRE(rgb[0] == (unsigned char)(color >> 16) &&
                rgb[1] == (unsigned char)(color >> 8) &&
                rgb[2] == (unsigned char)color,
                "FRAME_NOT_RENDERED_FROM_OPERATIONS");
        if (color != 0xffffffffu) {
            ++*painted;
            REQUIRE(isfinite(depths[i]) && depths[i] >= 0 && depths[i] < 1,
                    "DEPTH_BUFFER_NOT_POPULATED");
        } else REQUIRE(isinf(depths[i]), "BACKGROUND_WRITES_DEPTH");
    }
    REQUIRE(fgetc(image) == EOF && !ferror(image) && fclose(image) == 0,
            "FRAME_HAS_EXTRA_OR_UNREAD_DATA");
    REQUIRE(*painted > 300u, "BLANK_OR_TINY_FRAME");
    return 0;
}

static int changed_pixels(const char *a, const char *b, unsigned *changed) {
    FILE *first = fopen(a, "rb"), *second = fopen(b, "rb");
    REQUIRE(first && second, "MISSING_FRAME_COMPARISON");
    static const long header = (long)(sizeof "P6\n160 160\n255\n" - 1);
    REQUIRE(fseek(first, header, SEEK_SET) == 0 &&
            fseek(second, header, SEEK_SET) == 0,
            "FRAME_SEEK_ERROR");
    *changed = 0;
    for (unsigned i = 0; i < WIDTH * HEIGHT; ++i) {
        unsigned char p[3], q[3];
        REQUIRE(fread(p, 1, 3, first) == 3 &&
                fread(q, 1, 3, second) == 3, "FRAME_READ_ERROR");
        if (memcmp(p, q, 3) != 0) ++*changed;
    }
    REQUIRE(fclose(first) == 0 && fclose(second) == 0,
            "FRAME_COMPARISON_CLOSE_ERROR");
    return 0;
}

int main(int argc, char **argv) {
    if (argc != 9) {
        fprintf(stderr, "usage: verify-surface torus0.ops torus360.ops torus37.ops enneper25.ops near.ops torus0.ppm torus37.ppm enneper25.ppm\n");
        return 2;
    }
    scene zero, repeat, rotated, enneper, near;
    if (check_depth_api() ||
        inspect(argv[1], &zero, 1, 0) ||
        inspect(argv[2], &repeat, 1, 0) ||
        inspect(argv[3], &rotated, 1, 0) ||
        inspect(argv[4], &enneper, 0, 0) ||
        inspect(argv[5], &near, 1, 1)) return 1;

    double expected_x = 79.5 + 0.88 * 160.0 * 1.61 / 5.2;
    double expected_depth = 1.0 - 0.5 / 5.2;
    REQUIRE(fabs(zero.first_vertex[0] - expected_x) < 1e-9 &&
            fabs(zero.first_vertex[1] - 79.5) < 1e-9 &&
            fabs(zero.first_vertex[2] - expected_depth) < 1e-12,
            "ANALYTIC_TORUS_PROJECTION");
    if (check_torus_seam(&zero)) return 1;

    int same;
    if (same_files(argv[1], argv[2], &same)) return 1;
    REQUIRE(same, "FULL_ROTATION_NOT_REPRODUCIBLE");
    if (same_files(argv[1], argv[3], &same)) return 1;
    REQUIRE(!same, "ANGLE_DID_NOT_CHANGE_GEOMETRY");

    unsigned painted_zero, painted_rotated, painted_enneper, changed;
    if (render_matches_ppm(argv[1], argv[6], &painted_zero) ||
        render_matches_ppm(argv[3], argv[7], &painted_rotated) ||
        render_matches_ppm(argv[4], argv[8], &painted_enneper) ||
        changed_pixels(argv[6], argv[7], &changed)) return 1;
    REQUIRE(changed > 800u, "ROTATION_DID_NOT_CHANGE_VISIBLE_FRAME");
    REQUIRE(painted_enneper > 600u && painted_rotated > 600u,
            "SURFACE_NOT_RENDERED");

    printf("INDEPENDENT_FRAMEBUFFER_PASS torus_faces=%u near_vertices=%u torus_pixels=%u rotated_pixels=%u enneper_pixels=%u changed_pixels=%u\n",
           zero.face_count, near.near_vertices, painted_zero,
           painted_rotated, painted_enneper, changed);
    return 0;
}
