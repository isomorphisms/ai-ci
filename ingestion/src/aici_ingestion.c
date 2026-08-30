#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define LINE_MAX_LOCAL 16384
#define VALUE_MAX 4096
#define FIXTURE_MAX 128
#define STAGE_COUNT 7

static const char *stage_names[STAGE_COUNT] = {
    "input_acquisition",
    "network",
    "decompression",
    "decoding",
    "html_recovery",
    "document_construction",
    "downstream_extraction"
};

typedef struct {
    char status[8];
    char code[VALUE_MAX];
    char owner[VALUE_MAX];
    char evidence[VALUE_MAX];
    int seen;
} stage_result;

typedef struct {
    char schema[VALUE_MAX];
    char corpus_revision[VALUE_MAX];
    char corpus_repository_revision[VALUE_MAX];
    char fixture_id[FIXTURE_MAX];
    char implementation_role[VALUE_MAX];
    char implementation_name[VALUE_MAX];
    char implementation_revision[VALUE_MAX];
    char executable_sha256[VALUE_MAX];
    char fallback[VALUE_MAX];
    char scope[VALUE_MAX];
    char producer[VALUE_MAX];
    char first_failure[VALUE_MAX];
    char first_incomplete[VALUE_MAX];
    stage_result stages[STAGE_COUNT];
} receipt;

typedef struct {
    int quiet;
    char first_code[VALUE_MAX];
} result;

static void fail(result *out, const char *code, const char *detail) {
    if (out->first_code[0] == '\0') {
        snprintf(out->first_code, sizeof(out->first_code), "%s", code);
    }
    if (!out->quiet) {
        fprintf(stderr, "FAIL\t%s\t%s\n", code, detail);
    }
}

static int regular_file(const char *path) {
    struct stat info;
    return stat(path, &info) == 0 && S_ISREG(info.st_mode);
}

static int join_path(char *out, size_t capacity, const char *root, const char *relative) {
    int count = snprintf(out, capacity, "%s/%s", root, relative);
    return count >= 0 && (size_t)count < capacity;
}

static void trim_line(char *line) {
    size_t length = strlen(line);
    while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
        line[--length] = '\0';
    }
}

static int split_tabs(char *line, char **fields, int capacity) {
    int count = 0;
    char *cursor = line;
    while (count < capacity) {
        fields[count++] = cursor;
        char *tab = strchr(cursor, '\t');
        if (tab == NULL) break;
        *tab = '\0';
        cursor = tab + 1;
    }
    return count;
}

static int copy_once(char *destination, size_t capacity, const char *value) {
    if (destination[0] != '\0' || value[0] == '\0' || strlen(value) >= capacity) return 0;
    strcpy(destination, value);
    return 1;
}

static int stage_index(const char *name) {
    for (int index = 0; index < STAGE_COUNT; ++index) {
        if (strcmp(name, stage_names[index]) == 0) return index;
    }
    return -1;
}

static int assign_meta(receipt *parsed, const char *key, const char *value) {
    if (strcmp(key, "schema") == 0) return copy_once(parsed->schema, sizeof(parsed->schema), value);
    if (strcmp(key, "corpus_revision") == 0) return copy_once(parsed->corpus_revision, sizeof(parsed->corpus_revision), value);
    if (strcmp(key, "corpus_repository_revision") == 0) return copy_once(parsed->corpus_repository_revision, sizeof(parsed->corpus_repository_revision), value);
    if (strcmp(key, "fixture_id") == 0) return copy_once(parsed->fixture_id, sizeof(parsed->fixture_id), value);
    if (strcmp(key, "implementation_role") == 0) return copy_once(parsed->implementation_role, sizeof(parsed->implementation_role), value);
    if (strcmp(key, "implementation_name") == 0) return copy_once(parsed->implementation_name, sizeof(parsed->implementation_name), value);
    if (strcmp(key, "implementation_revision") == 0) return copy_once(parsed->implementation_revision, sizeof(parsed->implementation_revision), value);
    if (strcmp(key, "executable_sha256") == 0) return copy_once(parsed->executable_sha256, sizeof(parsed->executable_sha256), value);
    if (strcmp(key, "fallback") == 0) return copy_once(parsed->fallback, sizeof(parsed->fallback), value);
    if (strcmp(key, "scope") == 0) return copy_once(parsed->scope, sizeof(parsed->scope), value);
    if (strcmp(key, "producer") == 0) return copy_once(parsed->producer, sizeof(parsed->producer), value);
    return 0;
}

static int parse_receipt_file(const char *path, receipt *parsed, result *out) {
    memset(parsed, 0, sizeof(*parsed));
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        fail(out, "receipt_open", path);
        return 0;
    }
    char line[LINE_MAX_LOCAL];
    int line_number = 0;
    while (fgets(line, sizeof(line), file) != NULL) {
        ++line_number;
        if (strchr(line, '\n') == NULL && !feof(file)) {
            fail(out, "receipt_line_too_long", path);
            fclose(file);
            return 0;
        }
        trim_line(line);
        if (line[0] == '\0' || line[0] == '#') continue;
        char *fields[8];
        int count = split_tabs(line, fields, 8);
        if (count == 3 && strcmp(fields[0], "meta") == 0) {
            if (!assign_meta(parsed, fields[1], fields[2])) {
                char detail[VALUE_MAX];
                snprintf(detail, sizeof(detail), "line %d unknown/duplicate meta %s", line_number, fields[1]);
                fail(out, "receipt_meta", detail);
                fclose(file);
                return 0;
            }
        } else if (count == 7 && strcmp(fields[0], "stage") == 0) {
            int index = stage_index(fields[2]);
            if (index < 0 || parsed->stages[index].seen ||
                (parsed->fixture_id[0] != '\0' && strcmp(fields[1], parsed->fixture_id) != 0) ||
                strlen(fields[3]) >= sizeof(parsed->stages[index].status) ||
                strlen(fields[4]) >= sizeof(parsed->stages[index].code) ||
                strlen(fields[5]) >= sizeof(parsed->stages[index].owner) ||
                strlen(fields[6]) >= sizeof(parsed->stages[index].evidence)) {
                fail(out, "receipt_stage", "unknown, duplicate, mismatched, or oversized stage row");
                fclose(file);
                return 0;
            }
            strcpy(parsed->stages[index].status, fields[3]);
            strcpy(parsed->stages[index].code, fields[4]);
            strcpy(parsed->stages[index].owner, fields[5]);
            strcpy(parsed->stages[index].evidence, fields[6]);
            parsed->stages[index].seen = 1;
        } else if (count == 3 && strcmp(fields[0], "summary") == 0) {
            int ok = 0;
            if (strcmp(fields[1], "first_failure") == 0) {
                ok = copy_once(parsed->first_failure, sizeof(parsed->first_failure), fields[2]);
            } else if (strcmp(fields[1], "first_incomplete") == 0) {
                ok = copy_once(parsed->first_incomplete, sizeof(parsed->first_incomplete), fields[2]);
            }
            if (!ok) {
                fail(out, "receipt_summary", "unknown or duplicate summary row");
                fclose(file);
                return 0;
            }
        } else {
            fail(out, "receipt_shape", "row is not meta, stage, or summary");
            fclose(file);
            return 0;
        }
    }
    if (ferror(file)) {
        fail(out, "receipt_read", path);
        fclose(file);
        return 0;
    }
    fclose(file);
    return 1;
}

static int valid_hex(const char *value, size_t exact_length) {
    if (strlen(value) != exact_length) return 0;
    for (size_t index = 0; index < exact_length; ++index) {
        if (!isxdigit((unsigned char)value[index])) return 0;
    }
    return 1;
}

static int valid_revision(const char *value) {
    if (valid_hex(value, 40)) return 1;
    if (strncmp(value, "version:", 8) != 0 || value[8] == '\0') return 0;
    for (const unsigned char *cursor = (const unsigned char *)value; *cursor != '\0'; ++cursor) {
        if (*cursor == '\t' || *cursor == '\r' || *cursor == '\n') return 0;
    }
    return 1;
}

static int contains_insensitive(const char *text, const char *needle) {
    size_t needle_length = strlen(needle);
    for (const char *cursor = text; *cursor != '\0'; ++cursor) {
        size_t index = 0;
        while (index < needle_length && cursor[index] != '\0' &&
               tolower((unsigned char)cursor[index]) == tolower((unsigned char)needle[index])) {
            ++index;
        }
        if (index == needle_length) return 1;
    }
    return 0;
}

static int read_revision(const char *corpus_root, char *revision, size_t capacity, result *out) {
    char path[VALUE_MAX];
    if (!join_path(path, sizeof(path), corpus_root, "REVISION")) {
        fail(out, "corpus_path", "REVISION path too long");
        return 0;
    }
    FILE *file = fopen(path, "r");
    if (file == NULL || fgets(revision, (int)capacity, file) == NULL) {
        if (file != NULL) fclose(file);
        fail(out, "corpus_revision", "cannot read REVISION");
        return 0;
    }
    fclose(file);
    trim_line(revision);
    if (revision[0] == '\0') {
        fail(out, "corpus_revision", "REVISION is empty");
        return 0;
    }
    return 1;
}

static int manifest_has_fixture(const char *corpus_root, const char *fixture_id, result *out) {
    char path[VALUE_MAX];
    if (!join_path(path, sizeof(path), corpus_root, "fixtures.tsv")) return 0;
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        fail(out, "corpus_manifest", "cannot open fixtures.tsv");
        return 0;
    }
    char line[LINE_MAX_LOCAL];
    int first = 1;
    int found = 0;
    while (fgets(line, sizeof(line), file) != NULL) {
        trim_line(line);
        if (first) {
            first = 0;
            if (strcmp(line, "fixture_id\tscheme\tpath\tresponse\tcontent_encoding\tcharset\texpected_boundary") != 0) {
                fail(out, "corpus_manifest_header", "unexpected fixtures.tsv header");
                fclose(file);
                return 0;
            }
            continue;
        }
        char *tab = strchr(line, '\t');
        if (tab == NULL) continue;
        *tab = '\0';
        if (strcmp(line, fixture_id) == 0) found = 1;
    }
    fclose(file);
    if (!found) fail(out, "fixture_unknown", fixture_id);
    return found;
}

static int verify_corpus(const char *corpus_root, result *out) {
    static const char *required[] = {
        "REVISION", "CORPUS.sha256", "fixtures.tsv", "README.md", "bodies/valid.html",
        "bodies/malformed.html", "bodies/empty.html", "bodies/not-found.html",
        "bodies/invalid-utf8.hex", "bodies/truncated-gzip.hex"
    };
    char revision[VALUE_MAX];
    if (!read_revision(corpus_root, revision, sizeof(revision), out)) return 0;
    for (size_t index = 0; index < sizeof(required) / sizeof(required[0]); ++index) {
        char path[VALUE_MAX];
        if (!join_path(path, sizeof(path), corpus_root, required[index]) || !regular_file(path)) {
            fail(out, "corpus_file", required[index]);
            return 0;
        }
    }
    const char *fixtures[] = {
        "valid_utf8", "malformed_html", "empty_success", "redirect_utf8",
        "truncated_body", "invalid_utf8", "unknown_charset", "truncated_gzip",
        "not_found", "tls_plaintext"
    };
    for (size_t index = 0; index < sizeof(fixtures) / sizeof(fixtures[0]); ++index) {
        if (!manifest_has_fixture(corpus_root, fixtures[index], out)) return 0;
    }
    return 1;
}

static int skip_blocks(const char *code) {
    return strncmp(code, "not_implemented", 15) == 0 ||
           strncmp(code, "blocked_by_", 11) == 0;
}

static int verify_trace(const char *trace_path, const receipt *parsed, result *out) {
    if (trace_path == NULL || strcmp(trace_path, "-") == 0) {
        fail(out, "candidate_trace_required", "implementation-under-test needs an exec trace");
        return 0;
    }
    FILE *file = fopen(trace_path, "r");
    if (file == NULL) {
        fail(out, "candidate_trace_open", trace_path);
        return 0;
    }
    char line[LINE_MAX_LOCAL];
    int lines = 0;
    while (fgets(line, sizeof(line), file) != NULL) {
        ++lines;
        if (contains_insensitive(line, "curl") || contains_insensitive(line, "xmllint") ||
            contains_insensitive(line, "html5lib") || contains_insensitive(line, "warcio") ||
            contains_insensitive(line, "python")) {
            fail(out, "candidate_oracle_exec", line);
            fclose(file);
            return 0;
        }
    }
    fclose(file);
    if (lines == 0) {
        fail(out, "candidate_trace_empty", parsed->implementation_name);
        return 0;
    }
    return 1;
}

static int verify_receipt(const char *corpus_root, const char *receipt_path,
                          const char *expected_role, const char *trace_path,
                          receipt *parsed, result *out) {
    if (!parse_receipt_file(receipt_path, parsed, out)) return 0;
    char revision[VALUE_MAX];
    if (!read_revision(corpus_root, revision, sizeof(revision), out)) return 0;
    if (strcmp(parsed->schema, "aici-ingestion-receipt-v1") != 0) fail(out, "meta_schema", parsed->schema);
    if (strcmp(parsed->corpus_revision, revision) != 0) fail(out, "meta_corpus_revision", parsed->corpus_revision);
    if (!valid_hex(parsed->corpus_repository_revision, 40)) fail(out, "meta_corpus_repository_revision", parsed->corpus_repository_revision);
    if (!manifest_has_fixture(corpus_root, parsed->fixture_id, out)) return 0;
    if (strcmp(parsed->implementation_role, expected_role) != 0) fail(out, "meta_role", parsed->implementation_role);
    if (parsed->implementation_name[0] == '\0') fail(out, "meta_implementation_name", "missing");
    if (!valid_revision(parsed->implementation_revision)) fail(out, "meta_implementation_revision", parsed->implementation_revision);
    if (strcmp(parsed->fallback, "none") != 0) fail(out, "oracle_fallback", parsed->fallback);
    if (parsed->scope[0] == '\0') fail(out, "meta_scope", "missing");
    if (parsed->producer[0] == '\0') fail(out, "meta_producer", "missing");

    if (strcmp(expected_role, "implementation-under-test") == 0) {
        if (!valid_hex(parsed->executable_sha256, 64)) fail(out, "candidate_executable_sha256", parsed->executable_sha256);
        if (contains_insensitive(parsed->implementation_name, "oracle") ||
            contains_insensitive(parsed->implementation_name, "curl") ||
            contains_insensitive(parsed->implementation_name, "xmllint") ||
            contains_insensitive(parsed->producer, "oracle") ||
            contains_insensitive(parsed->producer, "curl")) {
            fail(out, "candidate_oracle_identity", parsed->implementation_name);
        }
        (void)verify_trace(trace_path, parsed, out);
    } else if (strcmp(expected_role, "oracle") == 0) {
        if (!valid_hex(parsed->executable_sha256, 64)) fail(out, "oracle_executable_sha256", parsed->executable_sha256);
        if (!contains_insensitive(parsed->implementation_name, "curl")) fail(out, "oracle_identity", parsed->implementation_name);
    } else if (strcmp(expected_role, "consumer") == 0) {
        if (strcmp(parsed->executable_sha256, "none") != 0 &&
            !valid_hex(parsed->executable_sha256, 64)) {
            fail(out, "consumer_executable_sha256", parsed->executable_sha256);
        }
    }

    const char *calculated_failure = "none";
    const char *calculated_incomplete = "none";
    int blocked = 0;
    const char *block_stage = NULL;
    for (int index = 0; index < STAGE_COUNT; ++index) {
        const stage_result *stage = &parsed->stages[index];
        if (!stage->seen) {
            fail(out, "stage_missing", stage_names[index]);
            continue;
        }
        if (stage->code[0] == '\0' || stage->owner[0] == '\0' || stage->evidence[0] == '\0') {
            fail(out, "stage_fields", stage_names[index]);
        }
        if (blocked) {
            char expected[VALUE_MAX];
            snprintf(expected, sizeof(expected), "blocked_by_%s", block_stage);
            if (strcmp(stage->status, "SKIP") != 0 || strcmp(stage->code, expected) != 0) {
                fail(out, "stage_after_boundary", stage_names[index]);
            }
            continue;
        }
        if (strcmp(stage->status, "PASS") == 0) {
            continue;
        } else if (strcmp(stage->status, "FAIL") == 0) {
            calculated_failure = stage_names[index];
            calculated_incomplete = stage_names[index];
            blocked = 1;
            block_stage = stage_names[index];
        } else if (strcmp(stage->status, "SKIP") == 0) {
            if (strncmp(stage->code, "not_applicable", 14) == 0) continue;
            if (!skip_blocks(stage->code)) fail(out, "skip_reason", stage->code);
            calculated_incomplete = stage_names[index];
            blocked = 1;
            block_stage = stage_names[index];
        } else {
            fail(out, "stage_status", stage->status);
        }
    }
    if (strcmp(parsed->first_failure, calculated_failure) != 0) fail(out, "summary_first_failure", parsed->first_failure);
    if (strcmp(parsed->first_incomplete, calculated_incomplete) != 0) fail(out, "summary_first_incomplete", parsed->first_incomplete);
    return out->first_code[0] == '\0';
}

static int compare_receipts(const receipt *candidate, const receipt *oracle, result *out) {
    if (strcmp(candidate->fixture_id, oracle->fixture_id) != 0 ||
        strcmp(candidate->corpus_revision, oracle->corpus_revision) != 0 ||
        strcmp(candidate->corpus_repository_revision, oracle->corpus_repository_revision) != 0) {
        fail(out, "compare_identity", "candidate and oracle do not describe the same fixture revision");
        return 0;
    }
    const int exact_stages[] = {1, 2, 3, 5};
    for (size_t item = 0; item < sizeof(exact_stages) / sizeof(exact_stages[0]); ++item) {
        int index = exact_stages[item];
        const stage_result *left = &candidate->stages[index];
        const stage_result *right = &oracle->stages[index];
        if (strcmp(left->status, right->status) != 0) {
            fail(out, "compare_status", stage_names[index]);
            return 0;
        }
        if (strcmp(left->status, "PASS") == 0 && strcmp(left->evidence, right->evidence) != 0) {
            fail(out, "compare_evidence", stage_names[index]);
            return 0;
        }
    }
    return out->first_code[0] == '\0';
}

static void usage(const char *program) {
    fprintf(stderr,
        "usage:\n"
        "  %s verify-corpus CORPUS_ROOT\n"
        "  %s verify CORPUS_ROOT RECEIPT ROLE [EXEC_TRACE|-]\n"
        "  %s compare CORPUS_ROOT CANDIDATE CANDIDATE_TRACE ORACLE\n",
        program, program, program);
}

int main(int argc, char **argv) {
    result out;
    memset(&out, 0, sizeof(out));
    if (argc == 3 && strcmp(argv[1], "verify-corpus") == 0) {
        if (verify_corpus(argv[2], &out)) {
            puts("PASS\tcorpus\tcanonical hostile fixture corpus is complete");
            return 0;
        }
        return 1;
    }
    if ((argc == 5 || argc == 6) && strcmp(argv[1], "verify") == 0) {
        receipt parsed;
        const char *trace = argc == 6 ? argv[5] : NULL;
        if (verify_receipt(argv[2], argv[3], argv[4], trace, &parsed, &out)) {
            printf("PASS\treceipt\t%s\t%s\n", parsed.fixture_id, parsed.implementation_role);
            return 0;
        }
        return 1;
    }
    if (argc == 6 && strcmp(argv[1], "compare") == 0) {
        receipt candidate;
        receipt oracle;
        if (!verify_receipt(argv[2], argv[3], "implementation-under-test", argv[4], &candidate, &out)) return 1;
        if (!verify_receipt(argv[2], argv[5], "oracle", NULL, &oracle, &out)) return 1;
        if (!compare_receipts(&candidate, &oracle, &out)) return 1;
        printf("PASS\tcompare\t%s\tcandidate and oracle semantics agree\n", candidate.fixture_id);
        return 0;
    }
    usage(argv[0]);
    return 2;
}
