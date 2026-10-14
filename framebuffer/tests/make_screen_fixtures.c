#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DIM 160u
#define SIZE (DIM * DIM * 3u)
static unsigned char before[SIZE], after[SIZE], tiny[SIZE], blank[SIZE];

static void pixel(unsigned char *buffer, unsigned x, unsigned y,
                  unsigned char r, unsigned char g, unsigned char b) {
    size_t at = ((size_t)y * DIM + x) * 3u;
    buffer[at] = r;
    buffer[at + 1] = g;
    buffer[at + 2] = b;
}

static void save(const char *root, const char *name,
                 const unsigned char *buffer) {
    char path[1024];
    if (snprintf(path, sizeof path, "%s/%s.rgb", root, name) >=
        (int)sizeof path) exit(1);
    FILE *f = fopen(path, "wb");
    if (!f || fwrite(buffer, 1, SIZE, f) != SIZE || fclose(f)) exit(1);
}

int main(int argc, char **argv) {
    if (argc != 2) return 2;
    memset(before, 255, SIZE);
    memset(after, 255, SIZE);
    memset(blank, 255, SIZE);
    for (unsigned y = 45; y < 115; ++y) {
        for (unsigned x = 35; x < 105; ++x) {
            pixel(before, x, y, 40, 80, 180);
            pixel(after, x + 28, y, 180, 60, 50);
        }
    }
    memcpy(tiny, before, SIZE);
    pixel(tiny, 35, 45, 180, 60, 50);
    save(argv[1], "before", before);
    save(argv[1], "after", after);
    save(argv[1], "tiny", tiny);
    save(argv[1], "blank", blank);
    return 0;
}
