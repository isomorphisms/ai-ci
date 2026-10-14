/* Independent real-image witness for an Android NativeActivity.
 * Input is RGB24 from FFmpeg-decoded screencap PNG, cropped to the
 * central mathematical drawing area and scaled to exactly 160x160.
 * This verifier does not import the candidate renderer or gesture code.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define WIDTH 160u
#define HEIGHT 160u
#define CHANNELS 3u
#define FRAME_BYTES (WIDTH * HEIGHT * CHANNELS)

static unsigned char before[FRAME_BYTES];
static unsigned char after[FRAME_BYTES];

static int fail(const char *what) {
    fprintf(stderr, "ANDROID_FRAME_DIFF_FAIL %s\n", what);
    return 1;
}

static int read_frame(const char *path, unsigned char *buffer) {
    FILE *input = fopen(path, "rb");
    if (!input) return fail("MISSING_SCREENSHOT");
    if (fread(buffer, 1, FRAME_BYTES, input) != FRAME_BYTES) {
        fclose(input);
        return fail("TRUNCATED_SCREENSHOT");
    }
    int extra = fgetc(input);
    int error = ferror(input);
    if (fclose(input) || error || extra != EOF)
        return fail("INVALID_SCREENSHOT_LENGTH");
    return 0;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: aici-android-frame-diff before.rgb after.rgb\n");
        return 2;
    }
    if (read_frame(argv[1], before) || read_frame(argv[2], after)) return 1;

    unsigned changed = 0;
    unsigned foreground_before = 0;
    unsigned foreground_after = 0;
    uint64_t sum = 0;
    for (size_t index = 0; index < WIDTH * HEIGHT; ++index) {
        unsigned largest = 0;
        int allwhite_before = 1;
        int allwhite_after = 1;
        for (size_t channel = 0; channel < CHANNELS; ++channel) {
            size_t offset = index * CHANNELS + channel;
            unsigned a = before[offset];
            unsigned b = after[offset];
            unsigned delta = a > b ? a - b : b - a;
            sum += delta;
            if (delta > largest) largest = delta;
            if (a != 255u) allwhite_before = 0;
            if (b != 255u) allwhite_after = 0;
        }
        if (largest >= 15u) ++changed;
        if (!allwhite_before) ++foreground_before;
        if (!allwhite_after) ++foreground_after;
    }
    double mean = (double)sum / (double)FRAME_BYTES;
    printf("ANDROID_FRAME_DIFF changed_pixels=%u foreground_before=%u "
           "foreground_after=%u mean_absolute_rgb=%.6f\n",
           changed, foreground_before, foreground_after, mean);
    if (foreground_before < 150 || foreground_after < 150)
        return fail("BLANK_MATH_CROP");
    if (changed < 100 || mean < 0.6)
        return fail("INPUT_DID_NOT_CHANGE_MATH_PIXELS");
    puts("ANDROID_FRAME_DIFF_PASS");
    return 0;
}
