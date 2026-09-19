#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define MAX_ROWS 256
#define MAX_ROOTS 64
#define MAX_BACKEND 128
#define MAX_METRIC 256
#define MAX_PATH 1024
#define MAX_NEEDLE 2048
#define MAX_LINE 4096

struct probe_row {
    char backend[MAX_BACKEND];
    char metric[MAX_METRIC];
    char path[MAX_PATH];
    char needle[MAX_NEEDLE];
};

struct root_map {
    char backend[MAX_BACKEND];
    char path[MAX_PATH];
};

struct observation {
    struct probe_row row;
    int readable;
    int present;
};

static void strip_newline(char *line) {
    size_t n = strlen(line);
    while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == '\r')) {
        line[--n] = '\0';
    }
}

static int copy_field(char *dst, size_t cap, const char *src, const char *what) {
    size_t n = strlen(src);
    if (n == 0) {
        fprintf(stderr, "probe configuration error: empty %s\n", what);
        return -1;
    }
    if (n >= cap) {
        fprintf(stderr, "probe configuration error: %s too long\n", what);
        return -1;
    }
    memcpy(dst, src, n + 1);
    return 0;
}

static int split_tsv(char *line, char **fields, size_t wanted) {
    size_t count = 0;
    char *start = line;
    for (char *p = line;; ++p) {
        if (*p == '\t' || *p == '\0') {
            if (count >= wanted) {
                return -1;
            }
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

static int row_cmp(const void *a, const void *b) {
    const struct probe_row *ra = a;
    const struct probe_row *rb = b;
    int c = strcmp(ra->backend, rb->backend);
    return c ? c : strcmp(ra->metric, rb->metric);
}

static int load_matrix_with_diagnostics(const char *path, struct probe_row *rows, size_t *row_count, int diagnostics) {
    FILE *fp = fopen(path, "r");
    if (!fp) {
        fprintf(stderr, "probe configuration error: %s: %s\n", path, strerror(errno));
        return -1;
    }

    char line[MAX_LINE];
    if (!fgets(line, sizeof line, fp)) {
        fprintf(stderr, "probe configuration error: %s: empty matrix\n", path);
        fclose(fp);
        return -1;
    }
    strip_newline(line);
    if (strcmp(line, "backend\tmetric\tpath\tneedle") != 0) {
        fprintf(stderr, "probe configuration error: %s: invalid matrix header\n", path);
        fclose(fp);
        return -1;
    }

    size_t n = 0;
    unsigned long line_number = 1;
    while (fgets(line, sizeof line, fp)) {
        ++line_number;
        if (!strchr(line, '\n') && !feof(fp)) {
            fprintf(stderr, "probe configuration error: %s:%lu: line too long\n", path, line_number);
            fclose(fp);
            return -1;
        }
        strip_newline(line);
        if (line[0] == '\0') {
            fprintf(stderr, "probe configuration error: %s:%lu: empty row\n", path, line_number);
            fclose(fp);
            return -1;
        }
        if (n >= MAX_ROWS) {
            fprintf(stderr, "probe configuration error: %s: too many rows\n", path);
            fclose(fp);
            return -1;
        }
        char *fields[4];
        if (split_tsv(line, fields, 4) != 0) {
            fprintf(stderr, "probe configuration error: %s:%lu: expected four TSV fields\n", path, line_number);
            fclose(fp);
            return -1;
        }
        if (copy_field(rows[n].backend, sizeof rows[n].backend, fields[0], "backend") ||
            copy_field(rows[n].metric, sizeof rows[n].metric, fields[1], "metric") ||
            copy_field(rows[n].path, sizeof rows[n].path, fields[2], "path") ||
            copy_field(rows[n].needle, sizeof rows[n].needle, fields[3], "needle")) {
            fclose(fp);
            return -1;
        }
        for (size_t i = 0; i < n; ++i) {
            if (strcmp(rows[i].backend, rows[n].backend) == 0 &&
                strcmp(rows[i].metric, rows[n].metric) == 0) {
                if (diagnostics) fprintf(stderr,
                        "probe configuration error: %s:%lu: duplicate backend/metric %s/%s\n",
                        path, line_number, rows[n].backend, rows[n].metric);
                fclose(fp);
                return -1;
            }
        }
        ++n;
    }
    if (ferror(fp)) {
        fprintf(stderr, "probe configuration error: %s: read failed\n", path);
        fclose(fp);
        return -1;
    }
    fclose(fp);
    qsort(rows, n, sizeof rows[0], row_cmp);
    *row_count = n;
    return 0;
}

static int load_matrix(const char *path, struct probe_row *rows, size_t *row_count) {
    return load_matrix_with_diagnostics(path, rows, row_count, 1);
}

static int parse_root(const char *value, struct root_map *root) {
    const char *eq = strchr(value, '=');
    if (!eq || eq == value || eq[1] == '\0') {
        fprintf(stderr, "probe configuration error: --root must be BACKEND=PATH, received %s\n", value);
        return -1;
    }
    size_t backend_len = (size_t)(eq - value);
    if (backend_len >= sizeof root->backend || strlen(eq + 1) >= sizeof root->path) {
        fprintf(stderr, "probe configuration error: --root value too long\n");
        return -1;
    }
    memcpy(root->backend, value, backend_len);
    root->backend[backend_len] = '\0';
    strcpy(root->path, eq + 1);
    return 0;
}

static const char *root_for(const char *backend, const struct root_map *roots, size_t root_count) {
    for (size_t i = 0; i < root_count; ++i) {
        if (strcmp(backend, roots[i].backend) == 0) {
            return roots[i].path;
        }
    }
    return NULL;
}

static int read_file(const char *path, unsigned char **data, size_t *size) {
    FILE *fp = fopen(path, "rb");
    if (!fp) {
        return -1;
    }
    if (fseek(fp, 0, SEEK_END) != 0) {
        fclose(fp);
        return -1;
    }
    long end = ftell(fp);
    if (end < 0 || fseek(fp, 0, SEEK_SET) != 0) {
        fclose(fp);
        return -1;
    }
    size_t n = (size_t)end;
    unsigned char *buf = malloc(n + 1);
    if (!buf) {
        fclose(fp);
        return -1;
    }
    if (n && fread(buf, 1, n, fp) != n) {
        free(buf);
        fclose(fp);
        return -1;
    }
    buf[n] = '\0';
    fclose(fp);
    *data = buf;
    *size = n;
    return 0;
}

static int byte_contains(const unsigned char *haystack, size_t haystack_len,
                         const unsigned char *needle, size_t needle_len) {
    if (needle_len == 0) return 1;
    if (needle_len > haystack_len) return 0;
    for (size_t i = 0; i + needle_len <= haystack_len; ++i) {
        if (memcmp(haystack + i, needle, needle_len) == 0) return 1;
    }
    return 0;
}

static int observe_rows(const struct probe_row *rows, size_t row_count,
                        const struct root_map *roots, size_t root_count,
                        struct observation *out) {
    for (size_t i = 0; i < row_count; ++i) {
        const char *root = root_for(rows[i].backend, roots, root_count);
        if (!root) {
            fprintf(stderr, "probe configuration error: matrix backend %s has no --root\n", rows[i].backend);
            return -1;
        }
        int written = snprintf(NULL, 0, "%s/%s", root, rows[i].path);
        if (written < 0) return -1;
        char *full = malloc((size_t)written + 1);
        if (!full) return -1;
        snprintf(full, (size_t)written + 1, "%s/%s", root, rows[i].path);

        out[i].row = rows[i];
        unsigned char *data = NULL;
        size_t size = 0;
        if (read_file(full, &data, &size) != 0) {
            out[i].readable = 0;
            out[i].present = 0;
        } else {
            out[i].readable = 1;
            out[i].present = byte_contains(data, size,
                                           (const unsigned char *)rows[i].needle,
                                           strlen(rows[i].needle));
            free(data);
        }
        free(full);
    }
    return 0;
}

static int write_observations(const char *path, const struct observation *obs, size_t count) {
    FILE *fp = stdout;
    if (strcmp(path, "-") != 0) {
        fp = fopen(path, "w");
        if (!fp) {
            fprintf(stderr, "probe output error: %s: %s\n", path, strerror(errno));
            return -1;
        }
    }
    fputs("backend\tmetric\treadable\tpresent\tpath\tneedle\n", fp);
    for (size_t i = 0; i < count; ++i) {
        fprintf(fp, "%s\t%s\t%d\t%d\t%s\t%s\n",
                obs[i].row.backend, obs[i].row.metric,
                obs[i].readable, obs[i].present,
                obs[i].row.path, obs[i].row.needle);
    }
    if (fp != stdout && fclose(fp) != 0) {
        fprintf(stderr, "probe output error: %s: close failed\n", path);
        return -1;
    }
    return 0;
}

static int has_metric(const struct probe_row *rows, size_t count, const char *metric) {
    for (size_t i = 0; i < count; ++i) if (strcmp(rows[i].metric, metric) == 0) return 1;
    return 0;
}

static int validate_exact_metrics(const char *path, const char *backend,
                                  const char *const *metrics, size_t expected_count) {
    struct probe_row rows[MAX_ROWS];
    size_t count = 0;
    if (load_matrix(path, rows, &count) != 0) return -1;
    if (count != expected_count) {
        fprintf(stderr, "self-test: %s: expected %zu metrics, got %zu\n", path, expected_count, count);
        return -1;
    }
    for (size_t i = 0; i < count; ++i) {
        if (strcmp(rows[i].backend, backend) != 0) {
            fprintf(stderr, "self-test: %s: unexpected backend %s\n", path, rows[i].backend);
            return -1;
        }
    }
    for (size_t i = 0; i < expected_count; ++i) {
        if (!has_metric(rows, count, metrics[i])) {
            fprintf(stderr, "self-test: %s: missing metric %s\n", path, metrics[i]);
            return -1;
        }
    }
    return 0;
}

static int self_test(void) {
    char dir[] = "/tmp/aici-probe-XXXXXX";
    if (!mkdtemp(dir)) {
        perror("mkdtemp");
        return 1;
    }
    char ir[MAX_PATH], matrix[MAX_PATH], duplicate[MAX_PATH];
    snprintf(ir, sizeof ir, "%s/IR.idr", dir);
    snprintf(matrix, sizeof matrix, "%s/matrix.tsv", dir);
    snprintf(duplicate, sizeof duplicate, "%s/duplicate.tsv", dir);

    FILE *fp = fopen(ir, "w");
    if (!fp) return 1;
    fputs("AddFloat32\n", fp);
    fclose(fp);
    fp = fopen(matrix, "w");
    if (!fp) return 1;
    fputs("backend\tmetric\tpath\tneedle\n"
          "z\tm2\tIR.idr\tSubtractFloat32\n"
          "a\tm9\tMissing.idr\tLoadFloat32\n"
          "a\tm1\tIR.idr\tAddFloat32\n", fp);
    fclose(fp);

    struct probe_row rows[MAX_ROWS];
    size_t count = 0;
    if (load_matrix(matrix, rows, &count) != 0 || count != 3) return 1;
    if (strcmp(rows[0].backend, "a") || strcmp(rows[0].metric, "m1") ||
        strcmp(rows[1].backend, "a") || strcmp(rows[1].metric, "m9") ||
        strcmp(rows[2].backend, "z") || strcmp(rows[2].metric, "m2")) {
        fprintf(stderr, "self-test: matrix sort failed\n");
        return 1;
    }
    struct root_map roots[2];
    strcpy(roots[0].backend, "a"); strcpy(roots[0].path, dir);
    strcpy(roots[1].backend, "z"); strcpy(roots[1].path, dir);
    struct observation obs[MAX_ROWS];
    if (observe_rows(rows, count, roots, 2, obs) != 0) return 1;
    if (!(obs[0].readable == 1 && obs[0].present == 1 &&
          obs[1].readable == 0 && obs[1].present == 0 &&
          obs[2].readable == 1 && obs[2].present == 0)) {
        fprintf(stderr, "self-test: present/absent/missing observation semantics failed\n");
        return 1;
    }

    fp = fopen(duplicate, "w");
    if (!fp) return 1;
    fputs("backend\tmetric\tpath\tneedle\n"
          "thumb\tarith.add\tA\tone\n"
          "thumb\tarith.add\tB\ttwo\n", fp);
    fclose(fp);
    if (load_matrix_with_diagnostics(duplicate, rows, &count, 0) == 0) {
        fprintf(stderr, "self-test: duplicate backend/metric was accepted\n");
        return 1;
    }

    static const char *const fp16_metrics[] = {
        "fp16.semantic_width_declared", "fp16.f16_selects_mediump",
        "fp16.f32_selects_highp", "fp16.default_remains_f32",
        "fp16.portable_exact_f16_not_claimed", "fp16.powervr_profile_native",
        "fp16.test_widths_distinct", "fp16.test_scalar_mediump",
        "fp16.test_vec2_mediump", "fp16.test_vec3_mediump",
        "fp16.test_vec4_mediump", "fp16.test_generic_not_native",
        "fp16.test_powervr_native", "fp16.test_powervr_vector",
        "fp16.test_no_silent_f32_demotion", "fp16.compiler_directive_parsed",
        "fp16.checked_ir_width_selected", "fp16.emitter_width_selected",
        "fp16.invalid_width_rejected", "fp16.compiler_test_f16",
        "fp16.ir_scalar_width_carried", "fp16.ir_vector_width_carried",
        "fp16.ir_array_width_carried", "fp16.explicit_f16_to_f32",
        "fp16.explicit_f32_to_f16", "fp16.emitter_width_aware",
        "fp16.source_type_exposed", "fp16.powervr_framebuffer_oracle_ci"
    };
    static const char *const consumer_metrics[] = {
        "fp16.consumer.ave.backend_declared_ref",
        "fp16.consumer.ave.backend_resolved_receipt",
        "fp16.consumer.ave.f16_compile", "fp16.consumer.ave.f32_compile",
        "fp16.consumer.ave.f16_ir_and_mediump", "fp16.consumer.ave.f32_ir_and_highp",
        "fp16.consumer.ave.glsl_validation", "fp16.consumer.ave.invalid_f64_rejected",
        "fp16.consumer.ave.evidence_retained"
    };
    if (validate_exact_metrics("compiler_backends/fp16_probes.tsv", "idris-shader-backend",
                               fp16_metrics, sizeof fp16_metrics / sizeof fp16_metrics[0]) != 0 ||
        validate_exact_metrics("compiler_backends/fp16_consumers.tsv", "algebraic-variety-explorer-mobile",
                               consumer_metrics, sizeof consumer_metrics / sizeof consumer_metrics[0]) != 0) {
        return 1;
    }

    unlink(ir); unlink(matrix); unlink(duplicate); rmdir(dir);
    puts("PASS  compiler backend observer self-test");
    return 0;
}

static void usage(const char *argv0) {
    fprintf(stderr, "usage: %s --matrix FILE --root BACKEND=PATH [--root ...] --output FILE\n"
                    "       %s --self-test\n", argv0, argv0);
}

int main(int argc, char **argv) {
    if (argc == 2 && strcmp(argv[1], "--self-test") == 0) return self_test();

    const char *matrix = NULL;
    const char *output = "-";
    struct root_map roots[MAX_ROOTS];
    size_t root_count = 0;

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--matrix") == 0 && i + 1 < argc) {
            matrix = argv[++i];
        } else if (strcmp(argv[i], "--output") == 0 && i + 1 < argc) {
            output = argv[++i];
        } else if (strcmp(argv[i], "--root") == 0 && i + 1 < argc) {
            if (root_count >= MAX_ROOTS || parse_root(argv[++i], &roots[root_count]) != 0) return 2;
            for (size_t j = 0; j < root_count; ++j) {
                if (strcmp(roots[j].backend, roots[root_count].backend) == 0) {
                    fprintf(stderr, "probe configuration error: duplicate --root for %s\n", roots[root_count].backend);
                    return 2;
                }
            }
            ++root_count;
        } else {
            usage(argv[0]);
            return 2;
        }
    }
    if (!matrix) {
        usage(argv[0]);
        return 2;
    }

    struct probe_row rows[MAX_ROWS];
    struct observation obs[MAX_ROWS];
    size_t row_count = 0;
    if (load_matrix(matrix, rows, &row_count) != 0) return 2;
    if (observe_rows(rows, row_count, roots, root_count, obs) != 0) return 2;
    return write_observations(output, obs, row_count) == 0 ? 0 : 2;
}
