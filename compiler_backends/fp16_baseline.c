#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ROWS 256
#define MAX_METRIC 256
#define MAX_LINE 4096

enum { EXPECTED_FIELDS = 2, OBS_FIELDS = 6 };

struct expected_row {
    char metric[MAX_METRIC];
    int present;
};

struct observed_row {
    char metric[MAX_METRIC];
    int readable;
    int present;
};

static void strip_newline(char *line) {
    size_t n = strlen(line);
    while (n && (line[n - 1] == '\n' || line[n - 1] == '\r')) line[--n] = '\0';
}

static int split_tsv(char *line, char **fields, size_t wanted) {
    size_t count = 0;
    char *start = line;
    for (char *p = line;; ++p) {
        if (*p == '\t' || *p == '\0') {
            if (count >= wanted) return -1;
            if (*p == '\t') {
                *p = '\0';
                fields[count++] = start;
                start = p + 1;
                continue;
            }
            fields[count++] = start;
            break;
        }
    }
    return count == wanted ? 0 : -1;
}

static int copy_metric(char *dst, const char *src) {
    size_t n = strlen(src);
    if (n == 0 || n >= MAX_METRIC) return -1;
    memcpy(dst, src, n + 1);
    return 0;
}

static int bit_value(const char *text, int *out) {
    if (strcmp(text, "0") == 0) { *out = 0; return 0; }
    if (strcmp(text, "1") == 0) { *out = 1; return 0; }
    return -1;
}

static int load_expected(const char *path, struct expected_row *rows, size_t *count) {
    FILE *fp = fopen(path, "r");
    if (!fp) {
        fprintf(stderr, "FP16 baseline error: %s: %s\n", path, strerror(errno));
        return -1;
    }
    char line[MAX_LINE];
    if (!fgets(line, sizeof line, fp)) { fclose(fp); return -1; }
    strip_newline(line);
    if (strcmp(line, "metric\texpected_present") != 0) {
        fprintf(stderr, "FP16 baseline error: %s: invalid expected-baseline header\n", path);
        fclose(fp); return -1;
    }
    size_t n = 0;
    unsigned long line_number = 1;
    while (fgets(line, sizeof line, fp)) {
        ++line_number; strip_newline(line);
        char *f[EXPECTED_FIELDS];
        if (n >= MAX_ROWS || split_tsv(line, f, EXPECTED_FIELDS) != 0 ||
            copy_metric(rows[n].metric, f[0]) != 0 || bit_value(f[1], &rows[n].present) != 0) {
            fprintf(stderr, "FP16 baseline error: %s:%lu: invalid baseline row\n", path, line_number);
            fclose(fp); return -1;
        }
        for (size_t i = 0; i < n; ++i) {
            if (strcmp(rows[i].metric, rows[n].metric) == 0) {
                fprintf(stderr, "FP16 baseline error: %s:%lu: duplicate metric %s\n",
                        path, line_number, rows[n].metric);
                fclose(fp); return -1;
            }
        }
        ++n;
    }
    fclose(fp); *count = n; return 0;
}

static int load_observations(const char *path, struct observed_row *rows, size_t *count) {
    FILE *fp = fopen(path, "r");
    if (!fp) {
        fprintf(stderr, "FP16 baseline error: %s: %s\n", path, strerror(errno));
        return -1;
    }
    char line[MAX_LINE];
    if (!fgets(line, sizeof line, fp)) { fclose(fp); return -1; }
    strip_newline(line);
    if (strcmp(line, "backend\tmetric\treadable\tpresent\tpath\tneedle") != 0) {
        fprintf(stderr, "FP16 baseline error: %s: invalid observation header\n", path);
        fclose(fp); return -1;
    }
    size_t n = 0;
    unsigned long line_number = 1;
    while (fgets(line, sizeof line, fp)) {
        ++line_number; strip_newline(line);
        char *f[OBS_FIELDS];
        if (n >= MAX_ROWS || split_tsv(line, f, OBS_FIELDS) != 0 ||
            strcmp(f[0], "idris-shader-backend") != 0 ||
            copy_metric(rows[n].metric, f[1]) != 0 ||
            bit_value(f[2], &rows[n].readable) != 0 ||
            bit_value(f[3], &rows[n].present) != 0) {
            fprintf(stderr, "FP16 baseline error: %s:%lu: invalid observation row\n", path, line_number);
            fclose(fp); return -1;
        }
        for (size_t i = 0; i < n; ++i) {
            if (strcmp(rows[i].metric, rows[n].metric) == 0) {
                fprintf(stderr, "FP16 baseline error: %s:%lu: duplicate metric %s\n",
                        path, line_number, rows[n].metric);
                fclose(fp); return -1;
            }
        }
        ++n;
    }
    fclose(fp); *count = n; return 0;
}

static const struct observed_row *find_observation(const struct observed_row *rows,
                                                    size_t count, const char *metric) {
    for (size_t i = 0; i < count; ++i) if (strcmp(rows[i].metric, metric) == 0) return &rows[i];
    return NULL;
}

static size_t regressions(const struct expected_row *expected, size_t expected_count,
                          const struct observed_row *observed, size_t observed_count,
                          int print) {
    size_t failures = 0;
    for (size_t i = 0; i < expected_count; ++i) {
        const struct observed_row *row = find_observation(observed, observed_count, expected[i].metric);
        if (!row) {
            ++failures;
            if (print) printf("FAIL  %s: missing observation\n", expected[i].metric);
        } else if (!row->readable) {
            ++failures;
            if (print) printf("FAIL  %s: source unreadable\n", expected[i].metric);
        } else if (row->present != expected[i].present) {
            ++failures;
            if (print) printf("FAIL  %s: expected present=%d, observed present=%d\n",
                              expected[i].metric, expected[i].present, row->present);
        }
    }
    return failures;
}

static int self_test(void) {
    struct expected_row e1[] = {{"fp16.test", 1}};
    struct observed_row o1[] = {{"fp16.test", 1, 1}};
    if (regressions(e1, 1, o1, 1, 0) != 0) return 1;

    struct expected_row e2[] = {{"fp16.present", 1}, {"fp16.missing", 1}};
    struct observed_row o2[] = {{"fp16.present", 1, 0}};
    if (regressions(e2, 2, o2, 1, 0) != 2) return 1;

    struct expected_row e3[] = {{"fp16.test", 0}};
    struct observed_row o3[] = {{"fp16.test", 0, 0}};
    if (regressions(e3, 1, o3, 1, 0) != 1) return 1;

    puts("PASS  FP16 baseline self-test");
    return 0;
}

static void usage(const char *argv0) {
    fprintf(stderr, "usage: %s --expected FILE --observations FILE\n"
                    "       %s --self-test\n", argv0, argv0);
}

int main(int argc, char **argv) {
    if (argc == 2 && strcmp(argv[1], "--self-test") == 0) return self_test();
    const char *expected_path = NULL, *observations_path = NULL;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--expected") == 0 && i + 1 < argc) expected_path = argv[++i];
        else if (strcmp(argv[i], "--observations") == 0 && i + 1 < argc) observations_path = argv[++i];
        else { usage(argv[0]); return 2; }
    }
    if (!expected_path || !observations_path) { usage(argv[0]); return 2; }

    struct expected_row expected[MAX_ROWS];
    struct observed_row observed[MAX_ROWS];
    size_t expected_count = 0, observed_count = 0;
    if (load_expected(expected_path, expected, &expected_count) != 0 ||
        load_observations(observations_path, observed, &observed_count) != 0) return 2;
    size_t failures = regressions(expected, expected_count, observed, observed_count, 1);
    if (failures) return 1;
    printf("PASS  %zu established FP16/PowerVR observations\n", expected_count);
    return 0;
}
