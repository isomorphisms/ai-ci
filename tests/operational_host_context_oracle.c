#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_MAXIMUM (1024 * 1024)
#define FIELD_MAXIMUM 7
#define NAME_MAXIMUM 256
#define ITEM_MAXIMUM 128
#define CODE_MAXIMUM 96

typedef struct {
    char name[NAME_MAXIMUM];
    int present_known;
    int present;
    int acquisition_known;
    int acquisition_proven;
    int installed_since_probe;
} CommandState;

typedef struct {
    char path[NAME_MAXIMUM];
    int present;
} CredentialState;

typedef struct {
    int passed;
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

static int evidence_grounded(const char *text) {
    return strncmp(text, "observed:", 9) == 0 ||
           strncmp(text, "declared:", 9) == 0;
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
    return count == 7 &&
           strcmp(fields[0], "event") == 0 &&
           strcmp(fields[1], "status") == 0 &&
           strcmp(fields[2], "host") == 0 &&
           strcmp(fields[3], "role") == 0 &&
           strcmp(fields[4], "subject") == 0 &&
           strcmp(fields[5], "value") == 0 &&
           strcmp(fields[6], "evidence") == 0;
}

static CommandState *command_state(CommandState *items, int *count,
                                   const char *name) {
    int i;
    for (i = 0; i < *count; ++i) {
        if (strcmp(items[i].name, name) == 0) return &items[i];
    }
    if (*count >= ITEM_MAXIMUM || strlen(name) >= NAME_MAXIMUM) return NULL;
    memset(&items[*count], 0, sizeof(items[*count]));
    snprintf(items[*count].name, sizeof(items[*count].name), "%s", name);
    ++*count;
    return &items[*count - 1];
}

static CredentialState *credential_state(CredentialState *items, int *count,
                                         const char *path) {
    int i;
    for (i = 0; i < *count; ++i) {
        if (strcmp(items[i].path, path) == 0) return &items[i];
    }
    if (*count >= ITEM_MAXIMUM || strlen(path) >= NAME_MAXIMUM) return NULL;
    memset(&items[*count], 0, sizeof(items[*count]));
    snprintf(items[*count].path, sizeof(items[*count].path), "%s", path);
    ++*count;
    return &items[*count - 1];
}

static int role_seen(const char roles[][NAME_MAXIMUM], int count,
                     const char *role, const char *host) {
    int i;
    char wanted[NAME_MAXIMUM];
    int written = snprintf(wanted, sizeof(wanted), "%s:%s", role, host);
    if (written < 0 || (size_t)written >= sizeof(wanted)) return 0;
    for (i = 0; i < count; ++i) {
        if (strcmp(roles[i], wanted) == 0) return 1;
    }
    return 0;
}

static int add_role(char roles[][NAME_MAXIMUM], int *count,
                    const char *role, const char *host) {
    int written;
    if (role_seen(roles, *count, role, host)) return 1;
    if (*count >= ITEM_MAXIMUM) return 0;
    written = snprintf(roles[*count], NAME_MAXIMUM, "%s:%s", role, host);
    if (written < 0 || written >= NAME_MAXIMUM) return 0;
    ++*count;
    return 1;
}

static int check_trace(const char *path, CheckResult *result) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int line_number = 0;
    int header_seen = 0;
    int execution_role_seen = 0;
    int os_seen = 0;
    int arch_seen = 0;
    char execution_host[NAME_MAXIMUM] = "";
    char roles[ITEM_MAXIMUM][NAME_MAXIMUM];
    int role_count = 0;
    CommandState commands[ITEM_MAXIMUM];
    int command_count = 0;
    CredentialState credentials[ITEM_MAXIMUM];
    int credential_count = 0;

    memset(result, 0, sizeof(*result));
    result->passed = 1;
    memset(commands, 0, sizeof(commands));
    memset(credentials, 0, sizeof(credentials));

    if (file == NULL) {
        fail(result, "HOST-CONTEXT-TRACE-UNREADABLE", 0);
        return 0;
    }

    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *fields[FIELD_MAXIMUM];
        int count;
        const char *event;
        const char *status;
        const char *host;
        const char *role;
        const char *subject;
        const char *value;
        const char *evidence;

        ++line_number;
        if (length > LINE_MAXIMUM ||
            memchr(line, '\0', (size_t)length) != NULL) {
            fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
            break;
        }
        while (length > 0 &&
               (line[length - 1] == '\n' || line[length - 1] == '\r')) {
            line[--length] = '\0';
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;

        if (!header_seen) {
            if (!exact_header(content)) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            header_seen = 1;
            continue;
        }

        count = split_tabs(content, fields, FIELD_MAXIMUM);
        if (count != 7) {
            fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
            break;
        }
        event = trim(fields[0]);
        status = trim(fields[1]);
        host = trim(fields[2]);
        role = trim(fields[3]);
        subject = trim(fields[4]);
        value = trim(fields[5]);
        evidence = trim(fields[6]);

        if (*event == '\0' || *status == '\0' || *host == '\0' ||
            *role == '\0' || *subject == '\0' || *value == '\0' ||
            *evidence == '\0' ||
            (strcmp(status, "pass") != 0 && strcmp(status, "fail") != 0)) {
            fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
            break;
        }

        if (strcmp(status, "pass") != 0) {
            fail(result, "HOST-CONTEXT-PREFLIGHT-FAILED", line_number);
            break;
        }

        if (strcmp(event, "host-role") == 0) {
            if (!evidence_grounded(evidence) ||
                (strcmp(role, "execution") != 0 &&
                 strcmp(role, "source") != 0 &&
                 strcmp(role, "destination") != 0 &&
                 strcmp(role, "build") != 0)) {
                fail(result, "HOST-CONTEXT-ROLE-UNVERIFIED", line_number);
                break;
            }
            if (!add_role(roles, &role_count, role, host)) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            if (strcmp(role, "execution") == 0) {
                if (execution_role_seen && strcmp(execution_host, host) != 0) {
                    fail(result, "HOST-CONTEXT-MULTIPLE-EXECUTION-HOSTS", line_number);
                    break;
                }
                execution_role_seen = 1;
                snprintf(execution_host, sizeof(execution_host), "%s", host);
            }
        } else if (strcmp(event, "host-fact") == 0) {
            if (!execution_role_seen || strcmp(host, execution_host) != 0 ||
                strcmp(role, "execution") != 0 || !evidence_grounded(evidence)) {
                fail(result, "HOST-CONTEXT-PLATFORM-EVIDENCE", line_number);
                break;
            }
            if (strcmp(subject, "os") == 0) os_seen = 1;
            else if (strcmp(subject, "arch") == 0) arch_seen = 1;
            else {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
        } else if (strcmp(event, "command-presence") == 0) {
            CommandState *state;
            if (!execution_role_seen || strcmp(host, execution_host) != 0 ||
                strcmp(role, "execution") != 0 ||
                strcmp(evidence, "observed:command-v") != 0 ||
                (strcmp(value, "present") != 0 &&
                 strcmp(value, "absent") != 0)) {
                fail(result, "HOST-CONTEXT-COMMAND-EVIDENCE", line_number);
                break;
            }
            state = command_state(commands, &command_count, subject);
            if (state == NULL) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            state->present_known = 1;
            state->present = strcmp(value, "present") == 0;
            if (state->present) state->installed_since_probe = 0;
        } else if (strcmp(event, "command-acquisition") == 0) {
            CommandState *state;
            if (!execution_role_seen || strcmp(host, execution_host) != 0 ||
                strcmp(role, "execution") != 0 || !evidence_grounded(evidence) ||
                (strcmp(value, "not-needed") != 0 &&
                 strcmp(value, "proven-for-host") != 0 &&
                 strcmp(value, "unknown") != 0 &&
                 strcmp(value, "unsupported") != 0)) {
                fail(result, "HOST-CONTEXT-ACQUISITION-EVIDENCE", line_number);
                break;
            }
            state = command_state(commands, &command_count, subject);
            if (state == NULL) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            state->acquisition_known = 1;
            state->acquisition_proven = strcmp(value, "proven-for-host") == 0;
        } else if (strcmp(event, "command-install") == 0) {
            CommandState *state = command_state(commands, &command_count, subject);
            if (state == NULL) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            if (!state->present_known || state->present ||
                !state->acquisition_known || !state->acquisition_proven ||
                !evidence_grounded(evidence)) {
                fail(result, "HOST-CONTEXT-ACQUISITION-UNVERIFIED", line_number);
                break;
            }
            state->installed_since_probe = 1;
            state->present_known = 0;
            state->present = 0;
        } else if (strcmp(event, "command-use") == 0) {
            CommandState *state = command_state(commands, &command_count, subject);
            if (state == NULL) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            if (state->installed_since_probe) {
                fail(result, "HOST-CONTEXT-REPROBE-REQUIRED", line_number);
                break;
            }
            if (!state->present_known || !state->present) {
                fail(result, "HOST-CONTEXT-COMMAND-UNVERIFIED", line_number);
                break;
            }
        } else if (strcmp(event, "credential-presence") == 0) {
            CredentialState *state;
            if (!execution_role_seen || strcmp(host, execution_host) != 0 ||
                strcmp(role, "execution") != 0 ||
                strcmp(evidence, "observed:test-r") != 0 ||
                (strcmp(value, "present") != 0 &&
                 strcmp(value, "absent") != 0)) {
                fail(result, "HOST-CONTEXT-CREDENTIAL-EVIDENCE", line_number);
                break;
            }
            state = credential_state(credentials, &credential_count, subject);
            if (state == NULL) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            state->present = strcmp(value, "present") == 0;
        } else if (strcmp(event, "credential-use") == 0) {
            CredentialState *state = credential_state(credentials, &credential_count, subject);
            if (state == NULL) {
                fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
                break;
            }
            if (!state->present) {
                fail(result, "HOST-CONTEXT-CREDENTIAL-UNVERIFIED", line_number);
                break;
            }
        } else if (strcmp(event, "transfer") == 0) {
            if (!execution_role_seen || strcmp(host, execution_host) != 0 ||
                strcmp(role, "execution") != 0 ||
                !role_seen(roles, role_count, "source", subject) ||
                !role_seen(roles, role_count, "destination", value)) {
                fail(result, "HOST-CONTEXT-TRANSFER-ROLE-UNVERIFIED", line_number);
                break;
            }
            if (strcmp(subject, value) == 0 &&
                strcmp(evidence, "declared:self-transfer-required") != 0) {
                fail(result, "HOST-CONTEXT-SELF-TRANSFER", line_number);
                break;
            }
        } else {
            fail(result, "HOST-CONTEXT-TRACE-MALFORMED", line_number);
            break;
        }
    }

    free(line);
    fclose(file);

    if (result->passed && !header_seen) {
        fail(result, "HOST-CONTEXT-TRACE-MALFORMED", 0);
    }
    if (result->passed && !execution_role_seen) {
        fail(result, "HOST-CONTEXT-EXECUTION-HOST-MISSING", 0);
    }
    if (result->passed && (!os_seen || !arch_seen)) {
        fail(result, "HOST-CONTEXT-PLATFORM-EVIDENCE", 0);
    }
    return result->passed;
}

static void print_result(const CheckResult *result) {
    printf("{\"status\":\"%s\",\"code\":\"%s\",\"line\":%d}\n",
           result->passed ? "pass" : "fail",
           result->passed ? "-" : result->code,
           result->line);
}

static int run_self_test(const char *cases_path) {
    FILE *cases = fopen(cases_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int cases_seen = 0;
    int failures = 0;

    if (cases == NULL) {
        fprintf(stderr, "cannot read host-context cases: %s\n", cases_path);
        return 0;
    }

    while ((length = getline(&line, &capacity, cases)) >= 0) {
        char *fields[3];
        char *content;
        int count;
        int expected_pass;
        int actual_pass;
        int case_ok;
        CheckResult result;

        if (length > LINE_MAXIMUM) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, 3);
        if (count != 3 ||
            (strcmp(fields[0], "pass") != 0 && strcmp(fields[0], "fail") != 0) ||
            (strcmp(fields[0], "pass") == 0 && strcmp(fields[2], "-") != 0) ||
            (strcmp(fields[0], "fail") == 0 &&
             (fields[2][0] == '\0' || strcmp(fields[2], "-") == 0))) {
            ++failures;
            continue;
        }

        ++cases_seen;
        expected_pass = strcmp(fields[0], "pass") == 0;
        actual_pass = check_trace(fields[1], &result);
        case_ok = expected_pass ? actual_pass :
                  (!actual_pass && strcmp(result.code, fields[2]) == 0);
        if (!case_ok) ++failures;

        printf("{\"kind\":\"host-context-self-test\",\"status\":\"%s\","
               "\"fixture\":\"%s\",\"expected\":\"%s\",\"observedCode\":\"%s\"}\n",
               case_ok ? "pass" : "fail", fields[1], fields[0],
               result.passed ? "-" : result.code);
    }

    free(line);
    fclose(cases);
    if (cases_seen == 0) ++failures;
    printf("{\"kind\":\"host-context-self-test-summary\",\"status\":\"%s\","
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
