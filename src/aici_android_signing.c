#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_CAP 1024
#define PACKAGE_CAP 256
#define LANE_CAP 64
#define DIGEST_CAP 65
#define DIAG_CAP 512

static void trim_line(char *text) {
    size_t n = strlen(text);
    while (n > 0 && (text[n - 1] == '\n' || text[n - 1] == '\r')) {
        text[--n] = '\0';
    }
}

static int normalize_digest(
    const char *input,
    char output[DIGEST_CAP]
) {
    size_t j = 0;

    for (size_t i = 0; input[i] != '\0'; ++i) {
        unsigned char c = (unsigned char)input[i];

        if (c == ':' || isspace(c)) {
            continue;
        }
        if (!isxdigit(c) || j >= 64) {
            return 0;
        }

        output[j++] = (char)tolower(c);
    }

    if (j != 64) {
        return 0;
    }

    output[64] = '\0';
    return 1;
}

static int split_registry_line(
    char *line,
    char **package,
    char **lane,
    char **digest
) {
    char *first = strchr(line, '\t');
    if (first == NULL) {
        return 0;
    }

    *first = '\0';
    *package = line;
    *lane = first + 1;

    char *second = strchr(*lane, '\t');
    if (second == NULL) {
        return 0;
    }

    *second = '\0';
    *digest = second + 1;

    if (strchr(*digest, '\t') != NULL) {
        return 0;
    }

    return
        (*package)[0] != '\0' &&
        (*lane)[0] != '\0' &&
        (*digest)[0] != '\0';
}

static int verify_identity(
    const char *registry_path,
    const char *package,
    const char *lane,
    const char *observed_digest_input,
    char diagnostic[DIAG_CAP]
) {
    char observed[DIGEST_CAP];
    if (!normalize_digest(observed_digest_input, observed)) {
        snprintf(
            diagnostic,
            DIAG_CAP,
            "INVALID_OBSERVED_SHA256 package=%s lane=%s",
            package,
            lane
        );
        return 0;
    }

    FILE *registry = fopen(registry_path, "r");
    if (registry == NULL) {
        snprintf(
            diagnostic,
            DIAG_CAP,
            "REGISTRY_OPEN_FAILED path=%s",
            registry_path
        );
        return 0;
    }

    char line[LINE_CAP];
    unsigned long line_number = 0;
    int matches = 0;
    char expected[DIGEST_CAP] = {0};

    while (fgets(line, sizeof(line), registry) != NULL) {
        ++line_number;

        if (strchr(line, '\n') == NULL && !feof(registry)) {
            fclose(registry);
            snprintf(
                diagnostic,
                DIAG_CAP,
                "REGISTRY_LINE_TOO_LONG line=%lu",
                line_number
            );
            return 0;
        }

        trim_line(line);

        char *cursor = line;
        while (*cursor != '\0' && isspace((unsigned char)*cursor)) {
            ++cursor;
        }

        if (*cursor == '\0' || *cursor == '#') {
            continue;
        }

        char *entry_package = NULL;
        char *entry_lane = NULL;
        char *entry_digest_input = NULL;

        if (!split_registry_line(
                cursor,
                &entry_package,
                &entry_lane,
                &entry_digest_input
            )) {
            fclose(registry);
            snprintf(
                diagnostic,
                DIAG_CAP,
                "MALFORMED_REGISTRY_LINE line=%lu",
                line_number
            );
            return 0;
        }

        char entry_digest[DIGEST_CAP];
        if (!normalize_digest(entry_digest_input, entry_digest)) {
            fclose(registry);
            snprintf(
                diagnostic,
                DIAG_CAP,
                "INVALID_REGISTRY_SHA256 line=%lu",
                line_number
            );
            return 0;
        }

        if (strcmp(entry_package, package) == 0 &&
            strcmp(entry_lane, lane) == 0) {
            ++matches;
            if (matches == 1) {
                memcpy(expected, entry_digest, sizeof(expected));
            }
        }
    }

    if (ferror(registry)) {
        fclose(registry);
        snprintf(
            diagnostic,
            DIAG_CAP,
            "REGISTRY_READ_FAILED path=%s",
            registry_path
        );
        return 0;
    }

    fclose(registry);

    if (matches == 0) {
        snprintf(
            diagnostic,
            DIAG_CAP,
            "UNREGISTERED_PACKAGE_LANE package=%s lane=%s",
            package,
            lane
        );
        return 0;
    }

    if (matches != 1) {
        snprintf(
            diagnostic,
            DIAG_CAP,
            "DUPLICATE_REGISTRY_ENTRY package=%s lane=%s count=%d",
            package,
            lane,
            matches
        );
        return 0;
    }

    if (strcmp(expected, observed) != 0) {
        snprintf(
            diagnostic,
            DIAG_CAP,
            "SIGNER_MISMATCH package=%s lane=%s expected=%s observed=%s",
            package,
            lane,
            expected,
            observed
        );
        return 0;
    }

    snprintf(
        diagnostic,
        DIAG_CAP,
        "PASS package=%s lane=%s signer=%s",
        package,
        lane,
        observed
    );
    return 1;
}

static int run_verify(int argc, char **argv) {
    if (argc != 6) {
        fprintf(
            stderr,
            "usage: %s verify REGISTRY PACKAGE LANE SHA256\n",
            argv[0]
        );
        return 2;
    }

    char diagnostic[DIAG_CAP];
    int ok = verify_identity(
        argv[2],
        argv[3],
        argv[4],
        argv[5],
        diagnostic
    );

    FILE *stream = ok ? stdout : stderr;
    fprintf(stream, "%s\n", diagnostic);
    return ok ? 0 : 1;
}

static int split_case_line(
    char *line,
    char **name,
    char **expected_result,
    char **package,
    char **lane,
    char **digest,
    char **expected_diagnostic
) {
    char *fields[6];
    fields[0] = line;

    for (int i = 1; i < 6; ++i) {
        char *tab = strchr(fields[i - 1], '\t');
        if (tab == NULL) {
            return 0;
        }
        *tab = '\0';
        fields[i] = tab + 1;
    }

    if (strchr(fields[5], '\t') != NULL) {
        return 0;
    }

    *name = fields[0];
    *expected_result = fields[1];
    *package = fields[2];
    *lane = fields[3];
    *digest = fields[4];
    *expected_diagnostic = fields[5];

    for (int i = 0; i < 6; ++i) {
        if (fields[i][0] == '\0') {
            return 0;
        }
    }

    return 1;
}

static int run_self_test(int argc, char **argv) {
    if (argc != 4) {
        fprintf(
            stderr,
            "usage: %s self-test CASES REGISTRY\n",
            argv[0]
        );
        return 2;
    }

    FILE *cases = fopen(argv[2], "r");
    if (cases == NULL) {
        fprintf(stderr, "SELF_TEST_CASES_OPEN_FAILED path=%s\n", argv[2]);
        return 2;
    }

    char line[LINE_CAP];
    unsigned long line_number = 0;
    int failures = 0;
    int count = 0;

    while (fgets(line, sizeof(line), cases) != NULL) {
        ++line_number;
        trim_line(line);

        char *cursor = line;
        while (*cursor != '\0' && isspace((unsigned char)*cursor)) {
            ++cursor;
        }
        if (*cursor == '\0' || *cursor == '#') {
            continue;
        }

        char *name = NULL;
        char *expected_result = NULL;
        char *package = NULL;
        char *lane = NULL;
        char *digest = NULL;
        char *expected_diagnostic = NULL;

        if (!split_case_line(
                cursor,
                &name,
                &expected_result,
                &package,
                &lane,
                &digest,
                &expected_diagnostic
            )) {
            fprintf(
                stderr,
                "SELF_TEST_MALFORMED_CASE line=%lu\n",
                line_number
            );
            ++failures;
            continue;
        }

        char diagnostic[DIAG_CAP];
        int ok = verify_identity(
            argv[3],
            package,
            lane,
            digest,
            diagnostic
        );

        int expected_ok = strcmp(expected_result, "PASS") == 0;
        int expected_fail = strcmp(expected_result, "FAIL") == 0;
        if (!expected_ok && !expected_fail) {
            fprintf(
                stderr,
                "SELF_TEST_BAD_EXPECTATION case=%s value=%s\n",
                name,
                expected_result
            );
            ++failures;
            continue;
        }

        ++count;

        if (ok != expected_ok ||
            strcmp(diagnostic, expected_diagnostic) != 0) {
            fprintf(
                stderr,
                "SELF_TEST_FAIL case=%s expected_result=%s actual_result=%s expected_diag=%s actual_diag=%s\n",
                name,
                expected_result,
                ok ? "PASS" : "FAIL",
                expected_diagnostic,
                diagnostic
            );
            ++failures;
        } else {
            printf("SELF_TEST_PASS case=%s\n", name);
        }
    }

    fclose(cases);

    if (count == 0) {
        fprintf(stderr, "SELF_TEST_EMPTY\n");
        return 1;
    }

    if (failures != 0) {
        fprintf(
            stderr,
            "SELF_TEST_SUMMARY cases=%d failures=%d\n",
            count,
            failures
        );
        return 1;
    }

    printf("SELF_TEST_SUMMARY cases=%d failures=0\n", count);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(
            stderr,
            "usage: %s verify|self-test ...\n",
            argv[0]
        );
        return 2;
    }

    if (strcmp(argv[1], "verify") == 0) {
        return run_verify(argc, argv);
    }

    if (strcmp(argv[1], "self-test") == 0) {
        return run_self_test(argc, argv);
    }

    fprintf(stderr, "unknown command: %s\n", argv[1]);
    return 2;
}
