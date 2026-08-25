#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAXIMUM (1024 * 1024)
#define FIELD_MAXIMUM 5
#define CODE_MAXIMUM 96
#define REVISION_MAXIMUM 65
#define SOURCE_MAXIMUM 256

typedef struct {
    int passed;
    int mutation_before_source;
    char code[CODE_MAXIMUM];
    int line;
} CheckResult;

static char *trim(char *text) {
    char *end;
    while (isspace((unsigned char)*text)) ++text;
    end = text + strlen(text);
    while (end > text && isspace((unsigned char)end[-1])) --end;
    *end = '\0';
    return text;
}

static int split_tabs(char *line, char **fields, int maximum) {
    int count = 0;
    char *cursor = line;
    if (maximum < 1) return 0;
    fields[count++] = cursor;
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

static int full_revision(const char *revision) {
    size_t length = strlen(revision);
    size_t i;
    if (length != 40 && length != 64) return 0;
    for (i = 0; i < length; ++i) {
        if (!isxdigit((unsigned char)revision[i])) return 0;
    }
    return 1;
}

static int named_remote_ref(const char *source) {
    static const char *prefixes[] = {"refs/heads/", "refs/tags/"};
    size_t i;
    for (i = 0; i < sizeof(prefixes) / sizeof(prefixes[0]); ++i) {
        size_t prefix_length = strlen(prefixes[i]);
        if (strncmp(source, prefixes[i], prefix_length) == 0 &&
            source[prefix_length] != '\0') {
            return 1;
        }
    }
    return 0;
}

static void fail(CheckResult *result, const char *code, int line) {
    if (result->passed) {
        result->passed = 0;
        snprintf(result->code, sizeof(result->code), "%s", code);
        result->line = line;
    }
}

static int exact_header(char *line) {
    char *fields[FIELD_MAXIMUM];
    int count = split_tabs(trim(line), fields, FIELD_MAXIMUM);
    return count == 5 &&
           strcmp(fields[0], "event") == 0 &&
           strcmp(fields[1], "status") == 0 &&
           strcmp(fields[2], "source") == 0 &&
           strcmp(fields[3], "revision") == 0 &&
           strcmp(fields[4], "command") == 0;
}

static int check_trace(const char *path, CheckResult *result) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int line_number = 0;
    int header_seen = 0;
    int valid_preflight_seen = 0;
    int mutation_seen = 0;
    int acquire_seen = 0;
    int build_seen = 0;
    char preflight_source[SOURCE_MAXIMUM] = "";
    char preflight_revision[REVISION_MAXIMUM] = "";

    memset(result, 0, sizeof(*result));
    result->passed = 1;
    if (file == NULL) {
        fail(result, "BUILD-PREFLIGHT-TRACE-UNREADABLE", 0);
        return 0;
    }

    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *fields[FIELD_MAXIMUM];
        int count;
        const char *event;
        const char *status;
        const char *source;
        const char *revision;
        const char *command;

        ++line_number;
        if (length > LINE_MAXIMUM || memchr(line, '\0', (size_t)length) != NULL) {
            fail(result, "BUILD-PREFLIGHT-TRACE-MALFORMED", line_number);
            break;
        }
        while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
            line[--length] = '\0';
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;

        if (!header_seen) {
            if (!exact_header(content)) {
                fail(result, "BUILD-PREFLIGHT-TRACE-MALFORMED", line_number);
                break;
            }
            header_seen = 1;
            continue;
        }

        count = split_tabs(content, fields, FIELD_MAXIMUM);
        if (count != 5) {
            fail(result, "BUILD-PREFLIGHT-TRACE-MALFORMED", line_number);
            break;
        }
        event = trim(fields[0]);
        status = trim(fields[1]);
        source = trim(fields[2]);
        revision = trim(fields[3]);
        command = trim(fields[4]);
        if (*event == '\0' || *status == '\0' || *source == '\0' ||
            *revision == '\0' || *command == '\0' ||
            (strcmp(status, "pass") != 0 && strcmp(status, "fail") != 0)) {
            fail(result, "BUILD-PREFLIGHT-TRACE-MALFORMED", line_number);
            break;
        }

        if (strcmp(event, "source-preflight") == 0) {
            if (strcmp(status, "pass") == 0 && named_remote_ref(source) &&
                full_revision(revision)) {
                if (!valid_preflight_seen) {
                    snprintf(preflight_source, sizeof(preflight_source), "%s", source);
                    snprintf(preflight_revision, sizeof(preflight_revision), "%s", revision);
                } else if (strcmp(preflight_source, source) != 0 ||
                           strcmp(preflight_revision, revision) != 0) {
                    fail(result, "BUILD-PREFLIGHT-REVISION-MISMATCH", line_number);
                    break;
                }
                valid_preflight_seen = 1;
            }
        } else if (strcmp(event, "heavyweight-mutation") == 0) {
            mutation_seen = 1;
            if (!valid_preflight_seen) {
                result->mutation_before_source = 1;
                fail(result, "BUILD-PREFLIGHT-MUTATION-BEFORE-SOURCE", line_number);
                break;
            }
        } else if (strcmp(event, "source-acquire") == 0) {
            acquire_seen = 1;
            if (!valid_preflight_seen || strcmp(status, "pass") != 0 ||
                strcmp(source, preflight_source) != 0 ||
                strcmp(revision, preflight_revision) != 0) {
                fail(result, "BUILD-PREFLIGHT-REVISION-MISMATCH", line_number);
                break;
            }
        } else if (strcmp(event, "build") == 0) {
            build_seen = 1;
            if (!valid_preflight_seen || strcmp(status, "pass") != 0 ||
                strcmp(source, preflight_source) != 0 ||
                strcmp(revision, preflight_revision) != 0) {
                fail(result, "BUILD-PREFLIGHT-REVISION-MISMATCH", line_number);
                break;
            }
        } else {
            fail(result, "BUILD-PREFLIGHT-TRACE-MALFORMED", line_number);
            break;
        }
    }

    free(line);
    fclose(file);

    if (result->passed && !header_seen) {
        fail(result, "BUILD-PREFLIGHT-TRACE-MALFORMED", 0);
    }
    if (result->passed && !valid_preflight_seen) {
        fail(result, "BUILD-PREFLIGHT-SOURCE-UNVERIFIED", 0);
    }
    if (result->passed && (!mutation_seen || !acquire_seen || !build_seen)) {
        fail(result, "BUILD-PREFLIGHT-TRACE-INCOMPLETE", 0);
    }
    return result->passed;
}

static void print_result(const CheckResult *result) {
    printf("{\"status\":\"%s\",\"code\":\"%s\",\"line\":%d,"
           "\"heavyweightMutationBeforeSource\":%s}\n",
           result->passed ? "pass" : "fail",
           result->passed ? "-" : result->code,
           result->line,
           result->mutation_before_source ? "true" : "false");
}

static int run_self_test(const char *cases_path) {
    FILE *cases = fopen(cases_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int cases_seen = 0;
    int failures = 0;
    if (cases == NULL) {
        fprintf(stderr, "cannot read build-preflight cases: %s\n", cases_path);
        return 0;
    }
    while ((length = getline(&line, &capacity, cases)) >= 0) {
        char *fields[4];
        char *content;
        int count;
        int expected_pass;
        int actual_pass;
        int case_ok;
        int expected_mutation_before_source;
        CheckResult result;
        if (length > LINE_MAXIMUM) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, 4);
        if (count != 4 ||
            (strcmp(fields[0], "pass") != 0 && strcmp(fields[0], "fail") != 0) ||
            (strcmp(fields[0], "pass") == 0 && strcmp(fields[2], "-") != 0) ||
            (strcmp(fields[0], "fail") == 0 &&
             (fields[2][0] == '\0' || strcmp(fields[2], "-") == 0)) ||
            (strcmp(fields[3], "true") != 0 && strcmp(fields[3], "false") != 0)) {
            ++failures;
            continue;
        }
        ++cases_seen;
        expected_pass = strcmp(fields[0], "pass") == 0;
        expected_mutation_before_source = strcmp(fields[3], "true") == 0;
        actual_pass = check_trace(fields[1], &result);
        case_ok = (expected_pass ? actual_pass :
                   (!actual_pass && strcmp(result.code, fields[2]) == 0)) &&
                  result.mutation_before_source == expected_mutation_before_source;
        if (!case_ok) ++failures;
        printf("{\"kind\":\"build-preflight-self-test\",\"status\":\"%s\","
               "\"fixture\":\"%s\",\"expected\":\"%s\",\"observedCode\":\"%s\","
               "\"heavyweightMutationBeforeSource\":%s}\n",
               case_ok ? "pass" : "fail", fields[1], fields[0],
               result.passed ? "-" : result.code,
               result.mutation_before_source ? "true" : "false");
    }
    free(line);
    fclose(cases);
    if (cases_seen == 0) ++failures;
    printf("{\"kind\":\"build-preflight-self-test-summary\",\"status\":\"%s\","
           "\"cases\":%d,\"failures\":%d}\n",
           failures == 0 ? "pass" : "fail", cases_seen, failures);
    return failures == 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s check TRACE\n"
            "  %s self-test CASES\n",
            program, program);
}

int main(int argc, char **argv) {
    CheckResult result;
    if (argc == 3 && strcmp(argv[1], "check") == 0) {
        int passed = check_trace(argv[2], &result);
        print_result(&result);
        return passed ? 0 : 1;
    }
    if (argc == 3 && strcmp(argv[1], "self-test") == 0) {
        return run_self_test(argv[2]) ? 0 : 1;
    }
    usage(argv[0]);
    return 2;
}
