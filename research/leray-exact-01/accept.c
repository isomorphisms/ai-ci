/* Independent MOON oracle for the bounded Leray exact-flow benchmark.
 * C11; no producer source, finite-difference loop or saved reference is used.
 */
#include <errno.h>
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { ROWS = 16, COLUMNS = 18, VALUES = 15, CAPACITY = 65536 };

static const char header[] =
    "case\tgrid\tsteps\tnu\ttime\tvelocity_error\ttemporal_error\t"
    "laplace_error\tcurl_error\tparticle_error\tenergy\tenergy_exact\t"
    "energy_semidiscrete\thelicity\thelicity_exact\thelicity_semidiscrete\t"
    "divergence_max\tdisplacement";

static const char *const names[VALUES] = {
    "nu", "time", "velocity_error", "temporal_error", "laplace_error",
    "curl_error", "particle_error", "energy", "energy_exact",
    "energy_semidiscrete", "helicity", "helicity_exact",
    "helicity_semidiscrete", "divergence_max", "displacement"
};

struct specification {
    const char *name;
    unsigned grid, steps;
    long double nu, time;
};

static const struct specification cases[ROWS] = {
    {"spatial", 16, 1, 0.0L, 0.0L},
    {"spatial", 32, 1, 0.0L, 0.0L},
    {"spatial", 64, 1, 0.0L, 0.0L},
    {"spatial", 128, 1, 0.0L, 0.0L},
    {"temporal", 64, 64, 0.2L, 1.0L},
    {"temporal", 64, 128, 0.2L, 1.0L},
    {"temporal", 64, 256, 0.2L, 1.0L},
    {"temporal", 64, 512, 0.2L, 1.0L},
    {"combined", 16, 1024, 0.2L, 1.0L},
    {"combined", 32, 4096, 0.2L, 1.0L},
    {"combined", 64, 16384, 0.2L, 1.0L},
    {"combined", 128, 65536, 0.2L, 1.0L},
    {"inviscid", 64, 512, 0.0L, 1.0L},
    {"decay", 64, 512, 0.2L, 0.5L},
    {"decay", 64, 512, 0.2L, 1.0L},
    {"decay", 64, 512, 0.2L, 2.0L}
};

struct result {
    const char *diagnostic;
    unsigned row, column;
    long double observed, expected;
};

static struct result failure(const char *diagnostic, unsigned row,
                             unsigned column, long double observed,
                             long double expected)
{
    const struct result result = {diagnostic, row, column, observed, expected};
    return result;
}

/* Derive scalar eigenvalues, then solve the scalar recurrence analytically.
 * log1p/expm1 avoid the cancellation caused by 65536 tiny Euler steps.
 */
static void oracle(const struct specification *spec, long double out[VALUES])
{
    const long double h = 2.0L * acosl(-1.0L) / spec->grid;
    const long double sine_half = sinl(h / 2.0L);
    const long double lambda = 4.0L * sine_half * sine_half / (h * h);
    const long double curl = sinl(h) / h;
    const long double rate = spec->nu * lambda;
    const long double dt = spec->time / spec->steps;
    const long double log_amplitude = spec->steps * log1pl(-rate * dt);
    const long double amplitude = expl(log_amplitude);
    const long double continuum = expl(-spec->nu * spec->time);
    const long double semidiscrete = expl(-rate * spec->time);
    const long double integral = spec->nu == 0.0L ? spec->time :
        -expm1l(-spec->nu * spec->time) / spec->nu;
    const long double displacement = rate == 0.0L ? spec->time :
        -expm1l(log_amplitude) * (1.0L - rate * dt / 2.0L) / rate;

    out[0] = spec->nu;
    out[1] = spec->time;
    out[2] = fabsl(expm1l(log_amplitude + spec->nu * spec->time));
    out[3] = fabsl(expm1l(log_amplitude + rate * spec->time));
    out[4] = fabsl(1.0L - lambda);
    out[5] = fabsl(1.0L - curl);
    out[6] = fabsl(displacement - integral);
    out[7] = amplitude * amplitude / 2.0L;
    out[8] = continuum * continuum / 2.0L;
    out[9] = semidiscrete * semidiscrete / 2.0L;
    out[10] = curl * amplitude * amplitude;
    out[11] = continuum * continuum;
    out[12] = curl * semidiscrete * semidiscrete;
    out[13] = 0.0L;
    out[14] = displacement;
}

static int unsigned_integer(const char *text, unsigned *value)
{
    unsigned result = 0;
    const unsigned char *cursor = (const unsigned char *)text;
    if (*cursor == '\0') return 0;
    for (; *cursor != '\0'; ++cursor) {
        if (*cursor < '0' || *cursor > '9') return 0;
        if (result > 1000000U) return 0;
        result = result * 10U + (unsigned)(*cursor - '0');
    }
    *value = result;
    return 1;
}

/* Decimal notation only: no whitespace, hex numbers, NaN, infinity or suffix.
 * All quantities in this particular contract must be nonnegative.
 */
static const char *nonnegative_decimal(const char *text, long double *value)
{
    const unsigned char *cursor = (const unsigned char *)text;
    char *end;
    if (*cursor == '-') return "nonnegative";
    if (*cursor < '0' || *cursor > '9') return "number";
    while (*cursor >= '0' && *cursor <= '9') ++cursor;
    if (*cursor == '.') {
        ++cursor;
        if (*cursor < '0' || *cursor > '9') return "number";
        while (*cursor >= '0' && *cursor <= '9') ++cursor;
    }
    if (*cursor == 'e' || *cursor == 'E') {
        ++cursor;
        if (*cursor == '+' || *cursor == '-') ++cursor;
        if (*cursor < '0' || *cursor > '9') return "number";
        while (*cursor >= '0' && *cursor <= '9') ++cursor;
    }
    if (*cursor != '\0') return "number";
    errno = 0;
    *value = strtold(text, &end);
    if (errno == ERANGE || *end != '\0' || !isfinite(*value)) return "number";
    return NULL;
}

static struct result verify(const char *bytes, size_t length)
{
    char copy[CAPACITY];
    long double actual[ROWS][VALUES];
    char *line, *end;
    unsigned row = 0;

    if (length == 0 || length >= sizeof(copy))
        return failure("size", 0, 0, (long double)length, CAPACITY - 1);
    if (bytes[length - 1] != '\n') return failure("newline", 0, 0, 0, 0);
    if (memchr(bytes, '\0', length) != NULL || memchr(bytes, '\r', length) != NULL)
        return failure("text", 0, 0, 0, 0);
    memcpy(copy, bytes, length);
    copy[length] = '\0';
    line = copy;
    end = strchr(line, '\n');
    if (end == NULL) return failure("header", 0, 0, 0, 0);
    *end = '\0';
    if (strcmp(line, header) != 0) return failure("header", 0, 0, 0, 0);
    line = end + 1;
    while (*line != '\0') {
        char *fields[COLUMNS];
        char *cursor;
        unsigned count = 1, grid = 0, steps = 0, column;
        const struct specification *spec;
        if (row == ROWS) return failure("row-count", row + 1, 0, row + 1, ROWS);
        end = strchr(line, '\n');
        if (end == NULL) return failure("newline", row + 1, 0, 0, 0);
        *end = '\0';
        fields[0] = line;
        for (cursor = line; *cursor != '\0'; ++cursor) {
            if (*cursor == '\t') {
                *cursor = '\0';
                if (count == COLUMNS)
                    return failure("field-count", row + 1, count + 1, 0, COLUMNS);
                fields[count++] = cursor + 1;
            }
        }
        if (count != COLUMNS)
            return failure("field-count", row + 1, count, count, COLUMNS);
        spec = &cases[row];
        if (strcmp(fields[0], spec->name) != 0)
            return failure("case-order", row + 1, 1, 0, 0);
        if (!unsigned_integer(fields[1], &grid) || grid != spec->grid)
            return failure("grid", row + 1, 2, grid, spec->grid);
        if (!unsigned_integer(fields[2], &steps) || steps != spec->steps)
            return failure("steps", row + 1, 3, steps, spec->steps);
        for (column = 0; column < VALUES; ++column) {
            const char *diagnostic = nonnegative_decimal(fields[column + 3],
                                                         &actual[row][column]);
            if (diagnostic != NULL)
                return failure(diagnostic, row + 1, column + 4, 0, 0);
        }
        /* Parameters are checked before derived convergence predicates. */
        if ((spec->nu == 0.0L && actual[row][0] != 0.0L) ||
            fabsl(actual[row][0] - spec->nu) > 2.0e-17L)
            return failure("nu", row + 1, 4, actual[row][0], spec->nu);
        if (actual[row][1] != spec->time)
            return failure("time", row + 1, 5, actual[row][1], spec->time);
        ++row;
        line = end + 1;
    }
    if (row != ROWS) return failure("row-count", row, 0, row, ROWS);

    /* Refinement changes one cause at a time: initial spatial operator error,
     * fixed-grid temporal error against the semidiscrete exact solution,
     * then h and dt together with dt proportional to h squared.
     */
    for (row = 0; row < 3; ++row) {
        unsigned column;
        for (column = 4; column <= 5; ++column) {
            const long double ratio = actual[row][column] / actual[row + 1][column];
            if (!(ratio > 3.8L && ratio < 4.1L))
                return failure("spatial-order", row + 1, column + 4, ratio, 4.0L);
        }
    }
    for (row = 4; row < 7; ++row) {
        const long double ratio = actual[row][3] / actual[row + 1][3];
        if (!(ratio > 1.98L && ratio < 2.02L))
            return failure("temporal-order", row + 1, 7, ratio, 2.0L);
    }
    for (row = 8; row < 11; ++row) {
        const long double ratio = actual[row][2] / actual[row + 1][2];
        if (!(ratio > 3.8L && ratio < 4.1L))
            return failure("combined-order", row + 1, 6, ratio, 4.0L);
    }
    for (row = 0; row < ROWS; ++row) {
        long double expected[VALUES];
        unsigned column;
        oracle(&cases[row], expected);
        for (column = 2; column < VALUES; ++column) {
            /* This accounts for double array/stencil accumulation and up to
             * 65536 steps. It stays below 0.004% of the smallest nonzero
             * error whose convergence is asserted by this case matrix.
             */
            const long double tolerance = 5.0e-11L + 2.0e-8L * fabsl(expected[column]);
            if (fabsl(actual[row][column] - expected[column]) > tolerance)
                return failure(names[column], row + 1, column + 4,
                               actual[row][column], expected[column]);
        }
    }
    return failure(NULL, 0, 0, 0, 0);
}

static int read_file(const char *path, char bytes[CAPACITY], size_t *length)
{
    FILE *stream = fopen(path, "rb");
    size_t count;
    int failed;
    if (stream == NULL) {
        fprintf(stderr, "FAIL\tread\tCannot open input: %s\n", path);
        return 0;
    }
    count = fread(bytes, 1, CAPACITY, stream);
    failed = ferror(stream);
    if (fclose(stream) != 0) failed = 1;
    if (failed || count == CAPACITY) {
        fprintf(stderr, "FAIL\tread\tInput cannot be read within %u bytes\n", (unsigned)CAPACITY - 1U);
        return 0;
    }
    *length = count;
    return 1;
}

/* Change the captured bytes, not an internal result object. row=0 is header;
 * data rows are 1..16, columns 0..17. No producer fixture generator is used.
 */
static int replace_field(const char *original, size_t length, unsigned row,
                         unsigned column, const char *replacement,
                         char altered[CAPACITY], size_t *altered_length)
{
    size_t start = 0, finish, new_size;
    unsigned seen = 0;
    while (seen < row && start < length) {
        if (original[start++] == '\n') ++seen;
    }
    if (seen != row || start == length) return 0;
    seen = 0;
    while (seen < column && start < length && original[start] != '\n') {
        if (original[start++] == '\t') ++seen;
    }
    if (seen != column || start == length) return 0;
    finish = start;
    while (finish < length && original[finish] != '\t' && original[finish] != '\n') ++finish;
    new_size = length - (finish - start) + strlen(replacement);
    if (new_size >= CAPACITY) return 0;
    memcpy(altered, original, start);
    memcpy(altered + start, replacement, strlen(replacement));
    memcpy(altered + start + strlen(replacement), original + finish, length - finish);
    *altered_length = new_size;
    return 1;
}

static int rejected(const char *label, const char *expected_diagnostic,
                    const char *bytes, size_t length)
{
    const struct result result = verify(bytes, length);
    if (result.diagnostic == NULL || strcmp(result.diagnostic, expected_diagnostic) != 0) {
        fprintf(stderr, "FAIL\tmutant\t%s\texpected=%s\tactual=%s\n", label,
                expected_diagnostic, result.diagnostic == NULL ? "ACCEPTED" : result.diagnostic);
        return 0;
    }
    printf("PASS\tmutant\t%s\tdiagnostic=%s\n", label, result.diagnostic);
    return 1;
}

static int self_test(const char *original, size_t length)
{
    static const struct mutation {
        const char *name;
        unsigned row, column;
        const char *replacement, *diagnostic;
    } mutations[] = {
        {"changed-header", 0, 0, "flow", "header"},
        {"unexpected-case", 13, 0, "unrecorded", "case-order"},
        {"invalid-grid", 13, 1, "0", "grid"},
        {"invalid-steps", 13, 2, "0", "steps"},
        {"changed-nu", 13, 3, "0.1", "nu"},
        {"changed-time", 13, 4, "2", "time"},
        {"velocity-error", 13, 5, "0.125", "velocity_error"},
        {"temporal-error", 13, 6, "0.125", "temporal_error"},
        {"laplace-error", 13, 7, "0.125", "laplace_error"},
        {"curl-error", 13, 8, "0.125", "curl_error"},
        {"particle-error", 13, 9, "0.125", "particle_error"},
        {"numeric-energy", 13, 10, "0.125", "energy"},
        {"corrupt-energy-reference", 13, 11, "0.125", "energy_exact"},
        {"corrupt-semidiscrete-energy", 13, 12, "0.125", "energy_semidiscrete"},
        {"numeric-helicity", 13, 13, "0.125", "helicity"},
        {"corrupt-helicity-reference", 13, 14, "0.125", "helicity_exact"},
        {"corrupt-semidiscrete-helicity", 13, 15, "0.125", "helicity_semidiscrete"},
        {"nonzero-divergence", 13, 16, "0.125", "divergence_max"},
        {"numeric-displacement", 13, 17, "0.125", "displacement"},
        {"nonfinite-nan", 13, 11, "nan", "number"},
        {"nonfinite-infinity", 13, 11, "inf", "number"},
        {"decimal-overflow", 13, 11, "1e999999", "number"},
        {"trailing-junk", 13, 11, "0.5junk", "number"},
        {"leading-space", 13, 11, " 0.5", "number"},
        {"hexadecimal-number", 13, 11, "0x1p-1", "number"},
        {"empty-number", 13, 11, "", "number"},
        {"negative-diagnostic", 13, 5, "-1", "nonnegative"},
        {"negative-zero", 13, 5, "-0", "nonnegative"},
        {"extra-field", 13, 17, "1\t1", "field-count"},
        {"missing-field", 13, 17, "", "number"},
        {"lost-spatial-convergence", 1, 7, "0", "spatial-order"},
        {"lost-temporal-convergence", 5, 6, "0", "temporal-order"},
        {"lost-combined-convergence", 9, 5, "0", "combined-order"}
    };
    char altered[CAPACITY];
    size_t changed_length, i, first_end, second_end, last_start;
    for (i = 0; i < sizeof(mutations) / sizeof(mutations[0]); ++i) {
        const struct mutation *mutation = &mutations[i];
        if (!replace_field(original, length, mutation->row, mutation->column,
                           mutation->replacement, altered, &changed_length)) {
            fprintf(stderr, "FAIL\tmutant-construction\t%s\n", mutation->name);
            return 0;
        }
        if (!rejected(mutation->name, mutation->diagnostic, altered, changed_length)) return 0;
    }
    /* Structural mutants exercise the parser independently of decimal checks. */
    if (!rejected("empty-input", "size", original, 0)) return 0;
    if (!rejected("missing-final-newline", "newline", original, length - 1)) return 0;
    memcpy(altered, original, length);
    altered[5] = '\0';
    if (!rejected("embedded-nul", "text", altered, length)) return 0;
    memcpy(altered, original, length);
    altered[5] = '\r';
    if (!rejected("embedded-cr", "text", altered, length)) return 0;
    last_start = length - 1;
    while (last_start != 0 && original[last_start - 1] != '\n') --last_start;
    if (!rejected("missing-row", "row-count", original, last_start)) return 0;
    memcpy(altered, original, length);
    altered[length] = '\n';
    if (!rejected("extra-blank-row", "row-count", altered, length + 1)) return 0;
    first_end = 0;
    while (first_end < length && original[first_end] != '\n') ++first_end;
    ++first_end;
    second_end = first_end;
    while (second_end < length && original[second_end] != '\n') ++second_end;
    ++second_end;
    if (length + second_end - first_end >= CAPACITY) return 0;
    memcpy(altered, original, length);
    memcpy(altered + length, original + first_end, second_end - first_end);
    if (!rejected("duplicate-row", "row-count", altered,
                  length + second_end - first_end)) return 0;
    /* A tab removed in the inviscid row must fail before interpreting fields. */
    if (!replace_field(original, length, 13, 16, "", altered, &changed_length)) return 0;
    for (i = 0; i + 1 < changed_length; ++i) {
        if (altered[i] == '\t' && altered[i + 1] == '\t') {
            memmove(altered + i, altered + i + 1, changed_length - i - 1);
            --changed_length;
            break;
        }
    }
    if (!rejected("removed-field", "field-count", altered, changed_length)) return 0;
    printf("PASS\tself-test\t41 targeted captured-output mutations rejected\n");
    return 1;
}

int main(int argc, char **argv)
{
    char bytes[CAPACITY];
    size_t length = 0;
    struct result result;
    int test = 0;
    const char *path;
    if (argc == 3 && strcmp(argv[1], "--self-test") == 0) test = 1;
    else if (argc != 2) {
        fprintf(stderr, "Usage: %s [--self-test] OUTPUT.tsv\n", argv[0]);
        return 2;
    }
    path = argv[test ? 2 : 1];
    if (!read_file(path, bytes, &length)) return 2;
    result = verify(bytes, length);
    if (result.diagnostic != NULL) {
        fprintf(stderr, "FAIL\t%s\trow=%u\tcolumn=%u\tobserved=%.21Lg\texpected=%.21Lg\n",
                result.diagnostic, result.row, result.column, result.observed, result.expected);
        return 1;
    }
    printf("PASS\tleray-exact-01\t16 rows independently recomputed\n");
    if (test && !self_test(bytes, length)) return 1;
    return 0;
}
