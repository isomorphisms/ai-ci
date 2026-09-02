#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define AICI_EQUALITY_TEXT_MAX (4 * 1024 * 1024)
#define AICI_EQUALITY_WARNING_MAX 8192

static const char *TYPE_DISCREPANCY = "𝕋 discrepancy";
static const char *WARNING_MARKER = "𝕎 warning";

typedef struct {
    int has_discrepancy;
    double discrepancy;
    int has_warning;
    char warning[AICI_EQUALITY_WARNING_MAX];
} EqualitySignal;

static int line_equals(const char *line, size_t length, const char *expected) {
    size_t expected_length = strlen(expected);
    if (length > 0 && line[length - 1] == '\r') --length;
    return length == expected_length && memcmp(line, expected, length) == 0;
}

static int copy_line(char *out, size_t out_size, const char *line, size_t length) {
    if (length > 0 && line[length - 1] == '\r') --length;
    if (length + 1 > out_size) return 0;
    memcpy(out, line, length);
    out[length] = '\0';
    return 1;
}

static int parse_number_line(const char *line, size_t length, double *value) {
    char number[256];
    char *end;
    if (!copy_line(number, sizeof(number), line, length)) return 0;
    errno = 0;
    *value = strtod(number, &end);
    if (end == number) return 0;
    while (*end == ' ' || *end == '\t') ++end;
    return *end == '\0' && errno != ERANGE;
}

static int marker_line(const char *line, size_t length) {
    return line_equals(line, length, TYPE_DISCREPANCY) ||
           line_equals(line, length, WARNING_MARKER) ||
           (length >= 4 && memcmp(line, "𝕋", 4) == 0) ||
           (length >= 4 && memcmp(line, "𝕎", 4) == 0);
}

static int parse_signal_text(const char *text, size_t size, EqualitySignal *signal) {
    const char *cursor = text;
    const char *end = text + size;
    int expect_discrepancy = 0;
    int expect_warning = 0;

    memset(signal, 0, sizeof(*signal));
    while (cursor < end) {
        const char *newline = memchr(cursor, '\n', (size_t)(end - cursor));
        const char *line_end = newline != NULL ? newline : end;
        size_t length = (size_t)(line_end - cursor);

        if (line_equals(cursor, length, TYPE_DISCREPANCY)) {
            expect_discrepancy = 1;
            expect_warning = 0;
        } else if (line_equals(cursor, length, WARNING_MARKER)) {
            expect_warning = 1;
            expect_discrepancy = 0;
        } else if (expect_discrepancy) {
            if (!marker_line(cursor, length)) {
                if (!parse_number_line(cursor, length, &signal->discrepancy)) return 0;
                signal->has_discrepancy = 1;
                expect_discrepancy = 0;
            }
        } else if (expect_warning) {
            if (!marker_line(cursor, length)) {
                if (!copy_line(signal->warning, sizeof(signal->warning), cursor, length)) {
                    return 0;
                }
                signal->has_warning = signal->warning[0] != '\0';
                expect_warning = 0;
            }
        }

        cursor = newline != NULL ? newline + 1 : end;
    }
    return signal->has_discrepancy && signal->has_warning;
}

static char *read_text(const char *path, size_t *size_out) {
    FILE *file = fopen(path, "rb");
    long size;
    char *text;
    size_t got;
    if (file == NULL) return NULL;
    if (fseek(file, 0, SEEK_END) != 0 || (size = ftell(file)) < 0 ||
        size > AICI_EQUALITY_TEXT_MAX || fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }
    text = malloc((size_t)size + 1);
    if (text == NULL) {
        fclose(file);
        return NULL;
    }
    got = fread(text, 1, (size_t)size, file);
    if (got != (size_t)size || ferror(file)) {
        free(text);
        fclose(file);
        return NULL;
    }
    fclose(file);
    text[got] = '\0';
    *size_out = got;
    return text;
}

static void emit_field(const char *marker, const char *value) {
    printf("%s\n%s\n", marker, value);
}

static void emit_discrepancy(double discrepancy) {
    puts(TYPE_DISCREPANCY);
    if (isinf(discrepancy)) {
        puts(discrepancy > 0 ? "inf" : "-inf");
    } else {
        printf("%.17g\n", discrepancy);
    }
}

static int load_signal(const char *path, EqualitySignal *signal, char **text_out,
                       size_t *size_out) {
    char *text = read_text(path, size_out);
    if (text == NULL) {
        fprintf(stderr, "cannot read equality signal: %s\n", path);
        return 0;
    }
    if (!parse_signal_text(text, *size_out, signal)) {
        fprintf(stderr, "equality signal is missing a discrepancy or warning: %s\n", path);
        free(text);
        return 0;
    }
    *text_out = text;
    return 1;
}

static int observe_assignment(const char *signal_path, const char *lhs,
                              const char *rhs) {
    EqualitySignal signal;
    char *text = NULL;
    size_t size = 0;
    if (!load_signal(signal_path, &signal, &text, &size)) return 2;

    emit_field("𝕋 lhs", lhs);
    emit_field("𝕋 rhs", rhs);
    emit_discrepancy(signal.discrepancy);
    emit_field(WARNING_MARKER, signal.warning);
    free(text);

    /* A discrepancy is evidence, not a build verdict. This first slice never
       fails merely because the discrepancy is large. */
    return 0;
}

static int self_test(const char *rubber_path, const char *wolf_path) {
    EqualitySignal rubber;
    EqualitySignal wolf;
    char *rubber_text = NULL;
    char *wolf_text = NULL;
    size_t rubber_size = 0;
    size_t wolf_size = 0;
    int ok;

    if (!load_signal(rubber_path, &rubber, &rubber_text, &rubber_size) ||
        !load_signal(wolf_path, &wolf, &wolf_text, &wolf_size)) {
        free(rubber_text);
        free(wolf_text);
        return 0;
    }

    ok = rubber.discrepancy == 0.0 &&
         isinf(wolf.discrepancy) && wolf.discrepancy > 0.0 &&
         strstr(rubber.warning, "THIS INFORMATION IS NOT TRUE") != NULL &&
         strstr(wolf.warning, "THIS INFORMATION IS NOT TRUE") != NULL;

    emit_field("𝕋 self-test", ok ? "pass" : "fail");
    emit_discrepancy(rubber.discrepancy);
    emit_field(WARNING_MARKER, rubber.warning);
    emit_discrepancy(wolf.discrepancy);
    emit_field(WARNING_MARKER, wolf.warning);

    free(rubber_text);
    free(wolf_text);
    return ok;
}

static int parse_positive_long(const char *text, long *value) {
    char *end;
    long parsed;
    errno = 0;
    parsed = strtol(text, &end, 10);
    if (end == text || *end != '\0' || errno == ERANGE || parsed <= 0 ||
        parsed > 10000000L) {
        return 0;
    }
    *value = parsed;
    return 1;
}

static long long elapsed_ns(struct timespec start, struct timespec end) {
    return (long long)(end.tv_sec - start.tv_sec) * 1000000000LL +
           (long long)(end.tv_nsec - start.tv_nsec);
}

static int benchmark(const char *signal_path, const char *iterations_text) {
    EqualitySignal signal;
    EqualitySignal scratch;
    char *text = NULL;
    size_t size = 0;
    long iterations;
    long i;
    struct timespec start;
    struct timespec end;
    long long ns;
    double per_assignment;

    if (!parse_positive_long(iterations_text, &iterations)) {
        fprintf(stderr, "iterations must be in 1..10000000\n");
        return 2;
    }
    if (!load_signal(signal_path, &signal, &text, &size)) return 2;

    if (clock_gettime(CLOCK_MONOTONIC, &start) != 0) {
        free(text);
        return 2;
    }
    for (i = 0; i < iterations; ++i) {
        if (!parse_signal_text(text, size, &scratch)) {
            free(text);
            return 2;
        }
    }
    if (clock_gettime(CLOCK_MONOTONIC, &end) != 0) {
        free(text);
        return 2;
    }
    ns = elapsed_ns(start, end);
    per_assignment = (double)ns / (double)iterations;

    printf("𝕋 benchmark.assignments\n%ld\n", iterations);
    printf("𝕋 benchmark.elapsed_ns\n%lld\n", ns);
    printf("𝕋 benchmark.ns_per_assignment\n%.3f\n", per_assignment);
    emit_field(WARNING_MARKER,
               "benchmark measures the AICI signal-adapter path only; it does not include a future vector index, model, IPC, or process-start cost");

    free(text);
    return 0;
}

/*
Future language-level instrumentation sketch, intentionally disabled until the
cost and semantics are understood:

    assignment(lhs, rhs):
        value = evaluate(rhs)
        equality_observe(lhs, value)   # warning only; preserve discrepancy
        lhs <- value

The point is to make the wrapper ordinary and eventually cheap enough that a
language can choose to make it the default. AICI is only measuring and testing
the acceptance boundary here; it is not pretending to instrument arbitrary C,
Idris, Idriç, IR, or other languages yet.
*/

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s assignment SIGNAL LHS RHS\n"
            "  %s self-test RUBBER_STAMP_SIGNAL CRY_WOLF_SIGNAL\n"
            "  %s bench SIGNAL ITERATIONS\n",
            program, program, program);
}

int main(int argc, char **argv) {
    if (argc == 5 && strcmp(argv[1], "assignment") == 0) {
        return observe_assignment(argv[2], argv[3], argv[4]);
    }
    if (argc == 4 && strcmp(argv[1], "self-test") == 0) {
        return self_test(argv[2], argv[3]) ? 0 : 1;
    }
    if (argc == 4 && strcmp(argv[1], "bench") == 0) {
        return benchmark(argv[2], argv[3]);
    }
    usage(argv[0]);
    return 2;
}
