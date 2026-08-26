#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAXIMUM (1024 * 1024)
#define FIELD_MAXIMUM 16
#define ROW_MAXIMUM 256
#define VALUE_MAXIMUM 512
#define CODE_MAXIMUM 64

typedef struct {
    int quiet;
    char first_code[CODE_MAXIMUM];
} Verdict;

typedef struct {
    char project[VALUE_MAXIMUM];
    char classification[64];
    char default_ref[128];
    char survey_ref[41];
    int current_seen;
} ScopeRow;

typedef struct {
    char gap[CODE_MAXIMUM];
    char project[VALUE_MAXIMUM];
    char state[32];
    char tracking_url[VALUE_MAXIMUM];
    char summary[VALUE_MAXIMUM];
    char acceptance[VALUE_MAXIMUM];
} GapRow;

typedef struct {
    char backend[64];
    char kind[32];
    char repository[VALUE_MAXIMUM];
    char revision[128];
    char compiler_repository[VALUE_MAXIMUM];
    char compiler_revision[128];
    char components[VALUE_MAXIMUM];
    char status[32];
    char gap[CODE_MAXIMUM];
} BackendRow;

typedef struct {
    char project[VALUE_MAXIMUM];
    char project_revision[41];
    char relation[32];
    char idric_revision[128];
    char components[VALUE_MAXIMUM];
    char backend[64];
    char backend_revision[128];
    char result[32];
    char evidence[VALUE_MAXIMUM];
    char gap[CODE_MAXIMUM];
} MatrixRow;

typedef struct {
    ScopeRow rows[ROW_MAXIMUM];
    int count;
} Scope;

typedef struct {
    GapRow rows[ROW_MAXIMUM];
    int count;
} Gaps;

typedef struct {
    BackendRow rows[ROW_MAXIMUM];
    int count;
} Backends;

typedef struct {
    MatrixRow rows[ROW_MAXIMUM];
    int count;
} Matrix;

static int fail(Verdict *verdict, const char *code, const char *path,
                long line, const char *detail) {
    if (verdict->first_code[0] == '\0') {
        snprintf(verdict->first_code, sizeof(verdict->first_code), "%s", code);
    }
    if (!verdict->quiet) {
        if (line > 0) {
            fprintf(stderr, "%s: %s:%ld: %s\n", code, path, line, detail);
        } else {
            fprintf(stderr, "%s: %s: %s\n", code, path, detail);
        }
    }
    return 0;
}

static void strip_eol(char *line) {
    size_t length = strlen(line);
    while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
        line[--length] = '\0';
    }
}

static int split_tabs(char *line, char **fields, int maximum) {
    int count = 1;
    char *cursor = line;
    fields[0] = line;
    while (*cursor != '\0') {
        if (*cursor == '\t') {
            *cursor = '\0';
            if (count >= maximum) return -1;
            fields[count++] = cursor + 1;
        }
        ++cursor;
    }
    return count;
}

static int copy_value(char *destination, size_t size, const char *source) {
    int written = snprintf(destination, size, "%s", source);
    return written >= 0 && (size_t)written < size;
}

static int lower_hex(const char *text, size_t length) {
    size_t index;
    if (strlen(text) != length) return 0;
    for (index = 0; index < length; ++index) {
        if (!(isdigit((unsigned char)text[index]) ||
              (text[index] >= 'a' && text[index] <= 'f'))) return 0;
    }
    return 1;
}

static int full_revision(const char *text) {
    return lower_hex(text, 40);
}

static int simple_name(const char *text) {
    const unsigned char *cursor = (const unsigned char *)text;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(isalnum(*cursor) || *cursor == '-' || *cursor == '_' ||
              *cursor == '.')) return 0;
        ++cursor;
    }
    return 1;
}

static int repository_name(const char *text) {
    const char *slash = strchr(text, '/');
    if (slash == NULL || slash == text || slash[1] == '\0' ||
        strchr(slash + 1, '/') != NULL) return 0;
    {
        char owner[VALUE_MAXIMUM];
        size_t length = (size_t)(slash - text);
        if (length >= sizeof(owner)) return 0;
        memcpy(owner, text, length);
        owner[length] = '\0';
        return simple_name(owner) && simple_name(slash + 1);
    }
}

static int one_of(const char *value, const char *const *allowed, size_t count) {
    size_t index;
    for (index = 0; index < count; ++index) {
        if (strcmp(value, allowed[index]) == 0) return 1;
    }
    return 0;
}

static int valid_components(const char *value, int allow_none) {
    static const char *const allowed[] = {
        "compiler", "prelude", "base", "network", "compiler-api",
        "support", "chez-toolchain", "source-extension", "float32"
    };
    char copy[VALUE_MAXIMUM];
    char *item;
    char *state = NULL;
    char seen[9][32];
    int seen_count = 0;
    if (strcmp(value, "-") == 0) return allow_none;
    if (!copy_value(copy, sizeof(copy), value)) return 0;
    for (item = strtok_r(copy, ",", &state); item != NULL;
         item = strtok_r(NULL, ",", &state)) {
        int index;
        if (!one_of(item, allowed, sizeof(allowed) / sizeof(allowed[0]))) return 0;
        for (index = 0; index < seen_count; ++index) {
            if (strcmp(item, seen[index]) == 0) return 0;
        }
        if (seen_count >= 9 || !copy_value(seen[seen_count], sizeof(seen[0]), item)) {
            return 0;
        }
        ++seen_count;
    }
    return seen_count > 0;
}

static int moving_ref(const char *revision) {
    return strcmp(revision, "main") == 0 || strcmp(revision, "master") == 0 ||
           strcmp(revision, "trunk") == 0 || strcmp(revision, "develop") == 0;
}

static int upstream_ref(const char *revision) {
    return strncmp(revision, "upstream:", 9) == 0 && revision[9] != '\0';
}

static int read_scope(const char *path, Scope *scope, Verdict *verdict) {
    static const char header[] = "project\tclassification\tdefault_ref\tsurvey_ref";
    static const char *const classes[] = {
        "compiler-provider", "backend-provider", "registry", "direct-consumer",
        "integration-target", "upstream-idris", "no-direct-dependency"
    };
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    long number = 0;
    int header_seen = 0;
    if (file == NULL) return fail(verdict, "IDRIC-SCOPE-READ", path, 0, "cannot open scope");
    memset(scope, 0, sizeof(*scope));
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        int count;
        int index;
        ++number;
        if (length > LINE_MAXIMUM) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-SCOPE-FORMAT", path, number, "line is too long");
        }
        strip_eol(line);
        if (!header_seen) {
            if (strcmp(line, header) != 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-SCOPE-HEADER", path, number, "wrong header");
            }
            header_seen = 1;
            continue;
        }
        if (line[0] == '\0' || line[0] == '#') continue;
        count = split_tabs(line, fields, FIELD_MAXIMUM);
        if (count != 4 || scope->count >= ROW_MAXIMUM ||
            !repository_name(fields[0]) ||
            !one_of(fields[1], classes, sizeof(classes) / sizeof(classes[0])) ||
            !simple_name(fields[2]) || !full_revision(fields[3])) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-SCOPE-FORMAT", path, number, "invalid scope row");
        }
        for (index = 0; index < scope->count; ++index) {
            if (strcmp(fields[0], scope->rows[index].project) == 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-SCOPE-DUPLICATE", path, number,
                            "duplicate project");
            }
        }
        if (!copy_value(scope->rows[scope->count].project,
                        sizeof(scope->rows[scope->count].project), fields[0]) ||
            !copy_value(scope->rows[scope->count].classification,
                        sizeof(scope->rows[scope->count].classification), fields[1]) ||
            !copy_value(scope->rows[scope->count].default_ref,
                        sizeof(scope->rows[scope->count].default_ref), fields[2]) ||
            !copy_value(scope->rows[scope->count].survey_ref,
                        sizeof(scope->rows[scope->count].survey_ref), fields[3])) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-SCOPE-FORMAT", path, number, "field is too long");
        }
        ++scope->count;
    }
    free(line);
    fclose(file);
    if (!header_seen || scope->count == 0) {
        return fail(verdict, "IDRIC-SCOPE-EMPTY", path, 0, "scope has no projects");
    }
    return 1;
}

static ScopeRow *find_scope(Scope *scope, const char *project) {
    int index;
    for (index = 0; index < scope->count; ++index) {
        if (strcmp(scope->rows[index].project, project) == 0) return &scope->rows[index];
    }
    return NULL;
}

static int read_gaps(const char *path, Scope *scope, Gaps *gaps, Verdict *verdict) {
    static const char header[] =
        "gap\tproject\tstate\ttracking_url\tsummary\tacceptance";
    static const char *const states[] = {"open", "blocked", "closed"};
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    long number = 0;
    int header_seen = 0;
    if (file == NULL) return fail(verdict, "IDRIC-GAP-READ", path, 0, "cannot open gaps");
    memset(gaps, 0, sizeof(*gaps));
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        int count;
        int index;
        ++number;
        if (length > LINE_MAXIMUM) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-GAP-FORMAT", path, number, "line is too long");
        }
        strip_eol(line);
        if (!header_seen) {
            if (strcmp(line, header) != 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-GAP-HEADER", path, number, "wrong header");
            }
            header_seen = 1;
            continue;
        }
        if (line[0] == '\0' || line[0] == '#') continue;
        count = split_tabs(line, fields, FIELD_MAXIMUM);
        if (count != 6 || gaps->count >= ROW_MAXIMUM || !simple_name(fields[0]) ||
            !(strcmp(fields[1], "*") == 0 || find_scope(scope, fields[1]) != NULL) ||
            !one_of(fields[2], states, sizeof(states) / sizeof(states[0])) ||
            strncmp(fields[3], "https://github.com/", 19) != 0 ||
            fields[4][0] == '\0' || fields[5][0] == '\0') {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-GAP-FORMAT", path, number, "invalid gap row");
        }
        for (index = 0; index < gaps->count; ++index) {
            if (strcmp(fields[0], gaps->rows[index].gap) == 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-GAP-DUPLICATE", path, number, "duplicate gap");
            }
        }
#define COPY_GAP(member, field) \
        if (!copy_value(gaps->rows[gaps->count].member, \
                        sizeof(gaps->rows[gaps->count].member), field)) { \
            free(line); fclose(file); \
            return fail(verdict, "IDRIC-GAP-FORMAT", path, number, "field is too long"); \
        }
        COPY_GAP(gap, fields[0]);
        COPY_GAP(project, fields[1]);
        COPY_GAP(state, fields[2]);
        COPY_GAP(tracking_url, fields[3]);
        COPY_GAP(summary, fields[4]);
        COPY_GAP(acceptance, fields[5]);
#undef COPY_GAP
        ++gaps->count;
    }
    free(line);
    fclose(file);
    if (!header_seen || gaps->count == 0) {
        return fail(verdict, "IDRIC-GAP-EMPTY", path, 0, "gap ledger is empty");
    }
    return 1;
}

static GapRow *find_gap(Gaps *gaps, const char *gap) {
    int index;
    for (index = 0; index < gaps->count; ++index) {
        if (strcmp(gaps->rows[index].gap, gap) == 0) return &gaps->rows[index];
    }
    return NULL;
}

static int unresolved_gap(const char *gap, Gaps *gaps, const char *project) {
    GapRow *row = find_gap(gaps, gap);
    return row != NULL && strcmp(row->state, "closed") != 0 &&
           (strcmp(row->project, "*") == 0 || strcmp(row->project, project) == 0);
}

static int read_backends(const char *path, Gaps *gaps, Backends *backends,
                         Verdict *verdict) {
    static const char header[] =
        "backend\tkind\trepository\trevision\tcompiler_repository\tcompiler_revision\tcomponents\tstatus\tgap";
    static const char *const kinds[] = {"builtin", "builtin-internal", "external"};
    static const char *const statuses[] = {
        "available", "upstream-only", "local-only", "idric-probed"
    };
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    long number = 0;
    int header_seen = 0;
    if (file == NULL) return fail(verdict, "IDRIC-BACKEND-READ", path, 0,
                                  "cannot open backend inventory");
    memset(backends, 0, sizeof(*backends));
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        int count;
        int index;
        ++number;
        if (length > LINE_MAXIMUM) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-BACKEND-FORMAT", path, number, "line is too long");
        }
        strip_eol(line);
        if (!header_seen) {
            if (strcmp(line, header) != 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-BACKEND-HEADER", path, number, "wrong header");
            }
            header_seen = 1;
            continue;
        }
        if (line[0] == '\0' || line[0] == '#') continue;
        count = split_tabs(line, fields, FIELD_MAXIMUM);
        if (count != 9 || backends->count >= ROW_MAXIMUM || !simple_name(fields[0]) ||
            !one_of(fields[1], kinds, sizeof(kinds) / sizeof(kinds[0])) ||
            !repository_name(fields[2]) || !repository_name(fields[4]) ||
            !valid_components(fields[6], 0) ||
            !one_of(fields[7], statuses, sizeof(statuses) / sizeof(statuses[0]))) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-BACKEND-FORMAT", path, number,
                        "invalid backend row");
        }
        if (strcmp(fields[1], "external") == 0) {
            if (!full_revision(fields[3]) ||
                !(full_revision(fields[5]) || strcmp(fields[5], "v0.8.0") == 0)) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-BACKEND-REVISION", path, number,
                            "external backend/compiler revisions are not immutable");
            }
        } else if (strcmp(fields[3], "same-as-compiler") != 0 ||
                   strcmp(fields[5], "per-project") != 0) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-BACKEND-REVISION", path, number,
                        "built-in backend must move with its compiler");
        }
        if (strcmp(fields[7], "available") == 0) {
            if (strcmp(fields[8], "-") != 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-BACKEND-GAP", path, number,
                            "available backend cannot carry an open gap");
            }
        } else if (!unresolved_gap(fields[8], gaps, fields[2])) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-BACKEND-GAP", path, number,
                        "unresolved backend has no matching open gap");
        }
        for (index = 0; index < backends->count; ++index) {
            if (strcmp(fields[0], backends->rows[index].backend) == 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-BACKEND-DUPLICATE", path, number,
                            "duplicate backend");
            }
        }
#define COPY_BACKEND(member, field) \
        if (!copy_value(backends->rows[backends->count].member, \
                        sizeof(backends->rows[backends->count].member), field)) { \
            free(line); fclose(file); \
            return fail(verdict, "IDRIC-BACKEND-FORMAT", path, number, "field is too long"); \
        }
        COPY_BACKEND(backend, fields[0]);
        COPY_BACKEND(kind, fields[1]);
        COPY_BACKEND(repository, fields[2]);
        COPY_BACKEND(revision, fields[3]);
        COPY_BACKEND(compiler_repository, fields[4]);
        COPY_BACKEND(compiler_revision, fields[5]);
        COPY_BACKEND(components, fields[6]);
        COPY_BACKEND(status, fields[7]);
        COPY_BACKEND(gap, fields[8]);
#undef COPY_BACKEND
        ++backends->count;
    }
    free(line);
    fclose(file);
    if (!header_seen || backends->count == 0) {
        return fail(verdict, "IDRIC-BACKEND-EMPTY", path, 0,
                    "backend inventory is empty");
    }
    return 1;
}

static BackendRow *find_backend(Backends *backends, const char *backend) {
    int index;
    for (index = 0; index < backends->count; ++index) {
        if (strcmp(backends->rows[index].backend, backend) == 0) {
            return &backends->rows[index];
        }
    }
    return NULL;
}

static int relation_matches(const char *classification, const char *relation) {
    if (strcmp(classification, "compiler-provider") == 0)
        return strcmp(relation, "compiler-provider") == 0;
    if (strcmp(classification, "backend-provider") == 0)
        return strcmp(relation, "backend-provider") == 0;
    if (strcmp(classification, "registry") == 0)
        return strcmp(relation, "registry") == 0;
    if (strcmp(classification, "direct-consumer") == 0)
        return strcmp(relation, "direct") == 0;
    if (strcmp(classification, "integration-target") == 0)
        return strcmp(relation, "planned") == 0 || strcmp(relation, "indirect") == 0;
    if (strcmp(classification, "upstream-idris") == 0)
        return strcmp(relation, "upstream") == 0;
    return strcmp(classification, "no-direct-dependency") == 0 &&
           strcmp(relation, "none") == 0;
}

static int valid_result(const char *result) {
    static const char *const results[] = {
        "pass", "fail", "pass-unbound", "upstream-pass", "local-pass", "not-run",
        "planned", "decision-open", "not-applicable", "inventory"
    };
    return one_of(result, results, sizeof(results) / sizeof(results[0]));
}

static int validate_matrix_row(const char *path, long number, MatrixRow *row,
                               Scope *scope, Backends *backends, Gaps *gaps,
                               Verdict *verdict) {
    ScopeRow *scope_row = find_scope(scope, row->project);
    BackendRow *backend_row = NULL;
    int unresolved;
    if (scope_row == NULL) {
        return fail(verdict, "IDRIC-PROJECT-UNKNOWN", path, number,
                    "matrix project is outside the reviewed scope");
    }
    if (!full_revision(row->project_revision)) {
        return fail(verdict, "IDRIC-REVISION", path, number,
                    "project observation lacks a full revision");
    }
    if (!relation_matches(scope_row->classification, row->relation)) {
        return fail(verdict, "IDRIC-RELATION", path, number,
                    "matrix relation disagrees with scope classification");
    }
    if (!valid_components(row->components,
                          strcmp(row->relation, "none") == 0 ||
                          strcmp(row->relation, "planned") == 0 ||
                          strcmp(row->relation, "indirect") == 0 ||
                          strcmp(row->relation, "registry") == 0)) {
        return fail(verdict, "IDRIC-COMPONENTS", path, number,
                    "invalid or missing Idric component set");
    }
    if (strcmp(row->backend, "-") != 0) {
        backend_row = find_backend(backends, row->backend);
        if (backend_row == NULL) {
            return fail(verdict, "IDRIC-BACKEND-UNKNOWN", path, number,
                        "matrix names an unregistered backend");
        }
        if (strcmp(backend_row->kind, "external") == 0) {
            if (!full_revision(row->backend_revision) ||
                strcmp(row->backend_revision, backend_row->revision) != 0) {
                return fail(verdict, "IDRIC-BACKEND-PIN", path, number,
                            "external backend revision differs from inventory");
            }
        } else if (strcmp(row->backend_revision, "same-as-idric") != 0 &&
                   strcmp(row->backend_revision, "same-as-compiler") != 0) {
            return fail(verdict, "IDRIC-BACKEND-PIN", path, number,
                        "built-in backend must move with its compiler");
        }
    } else if (strcmp(row->backend_revision, "-") != 0) {
        return fail(verdict, "IDRIC-BACKEND-PIN", path, number,
                    "backend revision exists without a backend");
    }
    if (!valid_result(row->result) || row->evidence[0] == '\0') {
        return fail(verdict, "IDRIC-MATRIX-FORMAT", path, number,
                    "invalid result or empty evidence");
    }

    if (strcmp(row->relation, "none") == 0) {
        if (strcmp(row->idric_revision, "-") != 0 ||
            strcmp(row->components, "-") != 0 || strcmp(row->backend, "-") != 0 ||
            strcmp(row->backend_revision, "-") != 0 ||
            !(strcmp(row->result, "not-applicable") == 0 ||
              strcmp(row->result, "decision-open") == 0)) {
            return fail(verdict, "IDRIC-NO-DEPENDENCY", path, number,
                        "no-dependency row makes a dependency or compatibility claim");
        }
    } else if (strcmp(row->relation, "registry") == 0) {
        if (strcmp(row->idric_revision, "-") != 0 || strcmp(row->backend, "-") != 0 ||
            strcmp(row->result, "inventory") != 0 || strcmp(row->gap, "-") != 0) {
            return fail(verdict, "IDRIC-REGISTRY-ROW", path, number,
                        "registry row must only record inventory ownership");
        }
    } else if (strcmp(row->relation, "compiler-provider") == 0) {
        if (strcmp(row->idric_revision, "same-as-project") != 0 ||
            strcmp(row->result, "inventory") != 0 || strcmp(row->gap, "-") != 0) {
            return fail(verdict, "IDRIC-PROVIDER-ROW", path, number,
                        "compiler provider must bind inventory to its project revision");
        }
    } else if (strcmp(row->relation, "upstream") == 0) {
        if (!upstream_ref(row->idric_revision) ||
            strcmp(row->result, "upstream-pass") != 0) {
            return fail(verdict, "IDRIC-UPSTREAM-ROW", path, number,
                        "upstream Idris row must be explicit");
        }
    } else if (strcmp(row->relation, "backend-provider") == 0) {
        if (!(upstream_ref(row->idric_revision) || full_revision(row->idric_revision) ||
              moving_ref(row->idric_revision))) {
            return fail(verdict, "IDRIC-REVISION", path, number,
                        "backend provider has no compiler revision");
        }
    } else if (strcmp(row->relation, "direct") == 0) {
        if (!(full_revision(row->idric_revision) || moving_ref(row->idric_revision))) {
            return fail(verdict, "IDRIC-REVISION", path, number,
                        "direct consumer has no Idric revision");
        }
    } else if (!(strcmp(row->idric_revision, "-") == 0 ||
                 full_revision(row->idric_revision) || moving_ref(row->idric_revision))) {
        return fail(verdict, "IDRIC-REVISION", path, number,
                    "integration row has an invalid Idric revision");
    }

    unresolved = strcmp(row->result, "fail") == 0 ||
                 strcmp(row->result, "pass-unbound") == 0 ||
                 strcmp(row->result, "upstream-pass") == 0 ||
                 strcmp(row->result, "local-pass") == 0 ||
                 strcmp(row->result, "not-run") == 0 ||
                 strcmp(row->result, "planned") == 0 ||
                 strcmp(row->result, "decision-open") == 0;
    if (unresolved) {
        if (!unresolved_gap(row->gap, gaps, row->project)) {
            return fail(verdict, "IDRIC-UNRESOLVED-GAP", path, number,
                        "unresolved tuple has no matching open gap");
        }
    } else if (strcmp(row->gap, "-") != 0) {
        return fail(verdict, "IDRIC-RESOLVED-GAP", path, number,
                    "resolved tuple still carries a gap");
    }
    if (strcmp(row->result, "pass") == 0) {
        if (!full_revision(row->idric_revision) ||
            strncmp(row->evidence, "https://github.com/", 19) != 0 ||
            strstr(row->evidence, "/actions/runs/") == NULL) {
            return fail(verdict, "IDRIC-PASS-EVIDENCE", path, number,
                        "pass is not bound to immutable compiler and workflow evidence");
        }
    }
    if (strcmp(row->result, "pass-unbound") == 0 && !moving_ref(row->idric_revision)) {
        return fail(verdict, "IDRIC-MOVING-REF", path, number,
                    "pass-unbound must name the moving compiler ref");
    }
    if (strcmp(row->project_revision, scope_row->survey_ref) == 0) {
        scope_row->current_seen = 1;
    }
    return 1;
}

static int read_matrix(const char *path, Scope *scope, Backends *backends,
                       Gaps *gaps, Matrix *matrix, Verdict *verdict) {
    static const char header[] =
        "project\tproject_revision\trelation\tidric_revision\tcomponents\tbackend\tbackend_revision\tresult\tevidence\tgap";
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    long number = 0;
    int header_seen = 0;
    if (file == NULL) return fail(verdict, "IDRIC-MATRIX-READ", path, 0,
                                  "cannot open compatibility matrix");
    memset(matrix, 0, sizeof(*matrix));
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        int count;
        int index;
        MatrixRow row;
        ++number;
        if (length > LINE_MAXIMUM) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-MATRIX-FORMAT", path, number, "line is too long");
        }
        strip_eol(line);
        if (!header_seen) {
            if (strcmp(line, header) != 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-MATRIX-HEADER", path, number, "wrong header");
            }
            header_seen = 1;
            continue;
        }
        if (line[0] == '\0' || line[0] == '#') continue;
        count = split_tabs(line, fields, FIELD_MAXIMUM);
        if (count != 10 || matrix->count >= ROW_MAXIMUM) {
            free(line); fclose(file);
            return fail(verdict, "IDRIC-MATRIX-FORMAT", path, number,
                        "matrix row must have ten fields");
        }
        memset(&row, 0, sizeof(row));
#define COPY_MATRIX(member, field) \
        if (!copy_value(row.member, sizeof(row.member), field)) { \
            free(line); fclose(file); \
            return fail(verdict, "IDRIC-MATRIX-FORMAT", path, number, "field is too long"); \
        }
        COPY_MATRIX(project, fields[0]);
        COPY_MATRIX(project_revision, fields[1]);
        COPY_MATRIX(relation, fields[2]);
        COPY_MATRIX(idric_revision, fields[3]);
        COPY_MATRIX(components, fields[4]);
        COPY_MATRIX(backend, fields[5]);
        COPY_MATRIX(backend_revision, fields[6]);
        COPY_MATRIX(result, fields[7]);
        COPY_MATRIX(evidence, fields[8]);
        COPY_MATRIX(gap, fields[9]);
#undef COPY_MATRIX
        if (!validate_matrix_row(path, number, &row, scope, backends, gaps, verdict)) {
            free(line); fclose(file); return 0;
        }
        for (index = 0; index < matrix->count; ++index) {
            MatrixRow *other = &matrix->rows[index];
            if (strcmp(row.project, other->project) == 0 &&
                strcmp(row.project_revision, other->project_revision) == 0 &&
                strcmp(row.idric_revision, other->idric_revision) == 0 &&
                strcmp(row.backend, other->backend) == 0 &&
                strcmp(row.backend_revision, other->backend_revision) == 0) {
                free(line); fclose(file);
                return fail(verdict, "IDRIC-MATRIX-DUPLICATE", path, number,
                            "duplicate compatibility tuple");
            }
        }
        matrix->rows[matrix->count++] = row;
    }
    free(line);
    fclose(file);
    if (!header_seen || matrix->count == 0) {
        return fail(verdict, "IDRIC-MATRIX-EMPTY", path, 0,
                    "compatibility matrix is empty");
    }
    {
        int index;
        for (index = 0; index < scope->count; ++index) {
            if (!scope->rows[index].current_seen) {
                return fail(verdict, "IDRIC-SCOPE-COVERAGE", path, 0,
                            scope->rows[index].project);
            }
        }
    }
    return 1;
}

static int verify_fleet(const char *scope_path, const char *backend_path,
                        const char *matrix_path, const char *gap_path,
                        Verdict *verdict) {
    Scope scope;
    Gaps gaps;
    Backends backends;
    Matrix matrix;
    if (!read_scope(scope_path, &scope, verdict)) return 0;
    if (!read_gaps(gap_path, &scope, &gaps, verdict)) return 0;
    if (!read_backends(backend_path, &gaps, &backends, verdict)) return 0;
    if (!read_matrix(matrix_path, &scope, &backends, &gaps, &matrix, verdict)) return 0;
    if (!verdict->quiet) {
        printf("Idric compatibility registry passes: %d projects, %d backends, "
               "%d tuples, %d tracked gaps.\n",
               scope.count, backends.count, matrix.count, gaps.count);
    }
    return 1;
}

static int self_test(const char *path) {
    static const char header[] =
        "expected\tscope\tbackends\tmatrix\tgaps\tcode";
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    long number = 0;
    int cases = 0;
    if (file == NULL) {
        fprintf(stderr, "IDRIC-SELF-TEST-READ: %s\n", path);
        return 1;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        int count;
        Verdict verdict;
        int passed;
        ++number;
        if (length > LINE_MAXIMUM) {
            fprintf(stderr, "IDRIC-SELF-TEST-FORMAT: %s:%ld\n", path, number);
            free(line); fclose(file); return 1;
        }
        strip_eol(line);
        if (number == 1) {
            if (strcmp(line, header) != 0) {
                fprintf(stderr, "IDRIC-SELF-TEST-HEADER: %s\n", path);
                free(line); fclose(file); return 1;
            }
            continue;
        }
        if (line[0] == '\0' || line[0] == '#') continue;
        count = split_tabs(line, fields, FIELD_MAXIMUM);
        if (count != 6 ||
            !(strcmp(fields[0], "pass") == 0 || strcmp(fields[0], "fail") == 0)) {
            fprintf(stderr, "IDRIC-SELF-TEST-FORMAT: %s:%ld\n", path, number);
            free(line); fclose(file); return 1;
        }
        memset(&verdict, 0, sizeof(verdict));
        verdict.quiet = 1;
        passed = verify_fleet(fields[1], fields[2], fields[3], fields[4], &verdict);
        if ((strcmp(fields[0], "pass") == 0 && !passed) ||
            (strcmp(fields[0], "fail") == 0 &&
             (passed || strcmp(verdict.first_code, fields[5]) != 0))) {
            fprintf(stderr,
                    "IDRIC-SELF-TEST-CASE: %s:%ld expected=%s/%s actual=%s/%s\n",
                    path, number, fields[0], fields[5], passed ? "pass" : "fail",
                    verdict.first_code[0] == '\0' ? "-" : verdict.first_code);
            free(line); fclose(file); return 1;
        }
        ++cases;
    }
    free(line);
    fclose(file);
    if (cases == 0) {
        fprintf(stderr, "IDRIC-SELF-TEST-EMPTY: %s\n", path);
        return 1;
    }
    printf("Idric compatibility self-test passes: %d cases.\n", cases);
    return 0;
}

static int list_heads(const char *path) {
    Scope scope;
    Verdict verdict;
    int index;
    memset(&verdict, 0, sizeof(verdict));
    if (!read_scope(path, &scope, &verdict)) return 1;
    for (index = 0; index < scope.count; ++index) {
        if (strcmp(scope.rows[index].classification, "registry") == 0) continue;
        printf("%s\t%s\t%s\n", scope.rows[index].project,
               scope.rows[index].default_ref, scope.rows[index].survey_ref);
    }
    return 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage: %s verify SCOPE BACKENDS MATRIX GAPS\n"
            "       %s self-test CASES\n"
            "       %s list-heads SCOPE\n",
            program, program, program);
}

int main(int argc, char **argv) {
    Verdict verdict;
    memset(&verdict, 0, sizeof(verdict));
    if (argc == 6 && strcmp(argv[1], "verify") == 0) {
        return verify_fleet(argv[2], argv[3], argv[4], argv[5], &verdict) ? 0 : 1;
    }
    if (argc == 3 && strcmp(argv[1], "self-test") == 0) return self_test(argv[2]);
    if (argc == 3 && strcmp(argv[1], "list-heads") == 0) return list_heads(argv[2]);
    usage(argv[0]);
    return 2;
}
