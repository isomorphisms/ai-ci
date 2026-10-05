#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define PATH_LIMIT 4096
#define LINE_LIMIT (1024 * 1024)

typedef struct {
    char first_code[64];
} VerifyResult;

static char *trim(char *text) {
    char *end;
    while (isspace((unsigned char)*text)) ++text;
    end = text + strlen(text);
    while (end > text && isspace((unsigned char)end[-1])) --end;
    *end = '\0';
    return text;
}

static int regular_file(const char *path) {
    struct stat info;
    return lstat(path, &info) == 0 && S_ISREG(info.st_mode);
}

static int safe_name(const char *name) {
    const unsigned char *p = (const unsigned char *)name;
    size_t length = strlen(name);
    if (length == 0 || length > 128) return 0;
    for (; *p != '\0'; ++p) {
        if (!isalnum(*p) && *p != '_' && *p != '-') return 0;
    }
    return 1;
}

static int exact_revision(const char *revision) {
    size_t i;
    if (strlen(revision) != 40) return 0;
    for (i = 0; i < 40; ++i) {
        if (!isxdigit((unsigned char)revision[i])) return 0;
    }
    return 1;
}

static int join_path(char *out, size_t out_size,
                     const char *root, const char *suffix) {
    int n = snprintf(out, out_size, "%s/%s", root, suffix);
    return n >= 0 && (size_t)n < out_size;
}

static int fail(VerifyResult *result, int quiet,
                const char *code, const char *detail) {
    if (result->first_code[0] == '\0') {
        snprintf(result->first_code, sizeof(result->first_code), "%s", code);
    }
    if (!quiet) fprintf(stderr, "%s\t%s\n", code, detail);
    return 0;
}

static int read_one_line(const char *path, char *out, size_t out_size) {
    FILE *file;
    char *line = NULL;
    char *extra = NULL;
    size_t capacity = 0;
    size_t extra_capacity = 0;
    ssize_t length;
    ssize_t extra_length;
    char *content;
    int ok = 0;

    if (!regular_file(path)) return 0;
    file = fopen(path, "r");
    if (file == NULL) return 0;
    length = getline(&line, &capacity, file);
    if (length >= 0 && length <= LINE_LIMIT) {
        content = trim(line);
        if (*content != '\0' && strlen(content) < out_size) {
            strcpy(out, content);
            ok = 1;
        }
    }
    if (ok) {
        extra_length = getline(&extra, &extra_capacity, file);
        if (extra_length >= 0 && *trim(extra) != '\0') ok = 0;
    }
    free(extra);
    free(line);
    fclose(file);
    return ok;
}

static int parse_status(const char *text, int *value) {
    char *end = NULL;
    long parsed;
    errno = 0;
    parsed = strtol(text, &end, 10);
    if (errno != 0 || end == text || *end != '\0' ||
        parsed < 0 || parsed > 255) {
        return 0;
    }
    *value = (int)parsed;
    return 1;
}

static int parse_failure_token(const char *start, size_t length,
                               char *task, size_t task_size, int *status) {
    char token[192];
    char *equals;

    if (length == 0 || length >= sizeof(token)) return 0;
    memcpy(token, start, length);
    token[length] = '\0';
    equals = strchr(token, '=');
    if (equals == NULL || equals == token || equals[1] == '\0' ||
        strchr(equals + 1, '=') != NULL) {
        return 0;
    }
    *equals = '\0';
    if (!safe_name(token) || strlen(token) >= task_size ||
        !parse_status(equals + 1, status) || *status == 0) {
        return 0;
    }
    strcpy(task, token);
    return 1;
}

static int valid_failure_spec(const char *spec) {
    const char *p = spec;
    if (*p == '\0') return 1;

    while (*p != '\0') {
        const char *end = strchr(p, ',');
        size_t length = end == NULL ? strlen(p) : (size_t)(end - p);
        char task[129];
        int status;

        if (!parse_failure_token(p, length, task, sizeof(task), &status)) {
            return 0;
        }
        if (end == NULL) return 1;
        p = end + 1;
        if (*p == '\0') return 0;
    }
    return 1;
}

static int failure_allowed(const char *spec, const char *task, int status) {
    const char *p = spec;

    while (*p != '\0') {
        const char *end = strchr(p, ',');
        size_t length = end == NULL ? strlen(p) : (size_t)(end - p);
        char allowed_task[129];
        int allowed_status;

        if (!parse_failure_token(p, length, allowed_task,
                                 sizeof(allowed_task), &allowed_status)) {
            return 0;
        }
        if (strcmp(allowed_task, task) == 0 && allowed_status == status) {
            return 1;
        }
        if (end == NULL) break;
        p = end + 1;
    }
    return 0;
}

static int split_tabs(char *line, char **fields, int maximum) {
    int count = 0;
    char *p = line;
    fields[count++] = p;
    while (*p != '\0') {
        if (*p == '\t') {
            *p = '\0';
            if (count >= maximum) return -1;
            fields[count++] = p + 1;
        }
        ++p;
    }
    return count;
}

static int verify_index(const char *root, const char *path,
                        const char *allowed_failures,
                        int quiet, VerifyResult *result,
                        int *task_count_out, int *max_status_out,
                        int *allowed_failure_count_out) {
    FILE *file;
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int task_count = 0;
    int max_status = 0;
    int allowed_failure_count = 0;

    if (!regular_file(path)) {
        return fail(result, quiet, "AICI-SOIL-INDEX", "INDEX.tsv missing");
    }
    file = fopen(path, "r");
    if (file == NULL) {
        return fail(result, quiet, "AICI-SOIL-INDEX", "INDEX.tsv unreadable");
    }

    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[6];
        char *content;
        char suffix[PATH_LIMIT];
        char log_path[PATH_LIMIT];
        int status;
        int count;
        int n;

        if (length > LINE_LIMIT) {
            free(line);
            fclose(file);
            return fail(result, quiet, "AICI-SOIL-INDEX", "INDEX.tsv line too long");
        }
        content = trim(line);
        if (*content == '\0') continue;
        count = split_tabs(content, fields, 6);
        if (count != 6 ||
            !parse_status(fields[0], &status) ||
            fields[1][0] == '\0' ||
            !safe_name(fields[2]) ||
            fields[3][0] == '\0' ||
            fields[4][0] == '\0' ||
            fields[5][0] == '\0') {
            free(line);
            fclose(file);
            return fail(result, quiet, "AICI-SOIL-INDEX", "INDEX.tsv row malformed");
        }

        n = snprintf(suffix, sizeof(suffix), "_tmp/soil/logs/%s.txt", fields[2]);
        if (n < 0 || (size_t)n >= sizeof(suffix) ||
            !join_path(log_path, sizeof(log_path), root, suffix) ||
            !regular_file(log_path)) {
            free(line);
            fclose(file);
            return fail(result, quiet, "AICI-SOIL-LOG", fields[2]);
        }

        ++task_count;
        if (status > max_status) max_status = status;
        if (status != 0) {
            if (!failure_allowed(allowed_failures, fields[2], status)) {
                free(line);
                fclose(file);
                return fail(result, quiet, "AICI-SOIL-TASK", fields[2]);
            }
            ++allowed_failure_count;
        }
    }

    free(line);
    fclose(file);
    if (task_count == 0) {
        return fail(result, quiet, "AICI-SOIL-INDEX", "INDEX.tsv has no tasks");
    }
    *task_count_out = task_count;
    *max_status_out = max_status;
    *allowed_failure_count_out = allowed_failure_count;
    return 1;
}

static int verify_summary(const char *path, int quiet,
                          VerifyResult *result, int *status_out) {
    char line[512];
    char status_text[32];
    char job_id[256];
    char extra[2];
    int count;
    int status;

    if (!read_one_line(path, line, sizeof(line))) {
        return fail(result, quiet, "AICI-SOIL-STATUS", "job status missing");
    }
    count = sscanf(line, "%31s %255s %1s", status_text, job_id, extra);
    if (count != 2 || !parse_status(status_text, &status)) {
        return fail(result, quiet, "AICI-SOIL-STATUS", "job status malformed");
    }
    *status_out = status;
    return 1;
}

static int verify(const char *root, const char *job,
                  const char *expected_revision,
                  const char *allowed_failures, int quiet,
                  VerifyResult *result, FILE *receipt) {
    char path[PATH_LIMIT];
    char suffix[PATH_LIMIT];
    char actual_revision[128];
    char actual_job[256];
    int task_count = 0;
    int max_task_status = 0;
    int job_status = 0;
    int allowed_failure_count = 0;
    int n;

    memset(result, 0, sizeof(*result));
    if (!safe_name(job)) {
        return fail(result, quiet, "AICI-SOIL-JOB", "invalid job name");
    }
    if (!exact_revision(expected_revision)) {
        return fail(result, quiet, "AICI-SOIL-REVISION", "revision is not exact 40-hex");
    }
    if (!valid_failure_spec(allowed_failures)) {
        return fail(result, quiet, "AICI-SOIL-ALLOW",
                    "allowed task failure specification is malformed");
    }

    if (!join_path(path, sizeof(path), root, "_tmp/soil/commit-hash.txt") ||
        !read_one_line(path, actual_revision, sizeof(actual_revision)) ||
        strcmp(actual_revision, expected_revision) != 0) {
        return fail(result, quiet, "AICI-SOIL-REVISION", "commit record mismatch");
    }

    if (!join_path(path, sizeof(path), root, "_tmp/soil/job-name.txt") ||
        !read_one_line(path, actual_job, sizeof(actual_job)) ||
        strcmp(actual_job, job) != 0) {
        return fail(result, quiet, "AICI-SOIL-JOB", "job record mismatch");
    }

    if (!join_path(path, sizeof(path), root, "_tmp/soil/INDEX.tsv") ||
        !verify_index(root, path, allowed_failures, quiet, result,
                      &task_count, &max_task_status,
                      &allowed_failure_count)) {
        return 0;
    }

    n = snprintf(suffix, sizeof(suffix), "_soil-jobs/%s.status.txt", job);
    if (n < 0 || (size_t)n >= sizeof(suffix) ||
        !join_path(path, sizeof(path), root, suffix) ||
        !verify_summary(path, quiet, result, &job_status)) {
        return 0;
    }

    if (job_status != max_task_status) {
        return fail(result, quiet, "AICI-SOIL-STATUS",
                    "job summary disagrees with tasks");
    }

    if (receipt != NULL) {
        fprintf(receipt, "source_revision\t%s\n", actual_revision);
        fprintf(receipt, "job\t%s\n", actual_job);
        fprintf(receipt, "task_count\t%d\n", task_count);
        fprintf(receipt, "max_task_status\t%d\n", max_task_status);
        fprintf(receipt, "job_status\t%d\n", job_status);
        fprintf(receipt, "allowed_task_failures\t%s\n",
                *allowed_failures == '\0' ? "-" : allowed_failures);
        fprintf(receipt, "observed_allowed_failures\t%d\n",
                allowed_failure_count);
        fprintf(receipt, "publisher\tnot_run\n");
    }
    return 1;
}

static int make_dir(const char *path) {
    return mkdir(path, 0777) == 0 || errno == EEXIST;
}

static int write_text(const char *path, const char *text) {
    FILE *file = fopen(path, "w");
    if (file == NULL) return 0;
    if (fputs(text, file) == EOF) {
        fclose(file);
        return 0;
    }
    return fclose(file) == 0;
}

static int make_fixture(const char *root, const char *revision,
                        const char *job, const char *index_text,
                        const char *summary_text, int include_log) {
    char path[PATH_LIMIT];
    const char *dirs[] = {
        "_tmp", "_tmp/soil", "_tmp/soil/logs", "_soil-jobs"
    };
    size_t i;

    if (!make_dir(root)) return 0;
    for (i = 0; i < sizeof(dirs) / sizeof(dirs[0]); ++i) {
        if (!join_path(path, sizeof(path), root, dirs[i]) || !make_dir(path)) return 0;
    }
    if (!join_path(path, sizeof(path), root, "_tmp/soil/commit-hash.txt") ||
        !write_text(path, revision)) return 0;
    if (!join_path(path, sizeof(path), root, "_tmp/soil/job-name.txt") ||
        !write_text(path, job)) return 0;
    if (!join_path(path, sizeof(path), root, "_tmp/soil/INDEX.tsv") ||
        !write_text(path, index_text)) return 0;
    if (!join_path(path, sizeof(path), root, "_soil-jobs/cpp-spec.status.txt") ||
        !write_text(path, summary_text)) return 0;
    if (include_log) {
        if (!join_path(path, sizeof(path), root, "_tmp/soil/logs/task-one.txt") ||
            !write_text(path, "fixture log\n")) return 0;
    }
    return 1;
}

static int one_case(const char *base, const char *name,
                    const char *revision, const char *job,
                    const char *index_text, const char *summary_text,
                    int include_log, const char *allowed_failures,
                    int expected_pass, const char *expected_code) {
    char root[PATH_LIMIT];
    VerifyResult result;
    int actual_pass;
    int ok;

    if (!join_path(root, sizeof(root), base, name) ||
        !make_fixture(root, revision, job, index_text,
                      summary_text, include_log)) {
        fprintf(stderr, "fixture setup failed: %s\n", name);
        return 0;
    }
    actual_pass = verify(root, "cpp-spec",
        "0123456789abcdef0123456789abcdef01234567",
        allowed_failures, 1, &result, NULL);
    ok = expected_pass
        ? actual_pass
        : (!actual_pass && strcmp(result.first_code, expected_code) == 0);
    printf("soil-self-test\t%s\t%s\t%s\n",
           ok ? "pass" : "fail", name,
           actual_pass ? "-" : result.first_code);
    return ok;
}

static int self_test(void) {
    char template_path[] = "/tmp/aici-soil-XXXXXX";
    char *base = mkdtemp(template_path);
    const char *good_rev =
        "0123456789abcdef0123456789abcdef01234567\n";
    const char *bad_rev =
        "1123456789abcdef0123456789abcdef01234567\n";
    const char *good_index =
        "0\t0.010000\ttask-one\ttest/run.sh\trun\t-\n";
    const char *bad_index =
        "1\t0.010000\ttask-one\ttest/run.sh\trun\t-\n";
    int failures = 0;

    if (base == NULL) {
        perror("mkdtemp");
        return 0;
    }

    if (!one_case(base, "good", good_rev, "cpp-spec\n",
                  good_index, "0 fixture\n", 1, "", 1, "-")) ++failures;
    if (!one_case(base, "wrong-revision", bad_rev, "cpp-spec\n",
                  good_index, "0 fixture\n", 1, "", 0,
                  "AICI-SOIL-REVISION")) ++failures;
    if (!one_case(base, "wrong-job", good_rev, "cpp-small\n",
                  good_index, "0 fixture\n", 1, "", 0,
                  "AICI-SOIL-JOB")) ++failures;
    if (!one_case(base, "malformed-index", good_rev, "cpp-spec\n",
                  "0\t0.010000\ttask-one\n", "0 fixture\n", 1, "", 0,
                  "AICI-SOIL-INDEX")) ++failures;
    if (!one_case(base, "missing-log", good_rev, "cpp-spec\n",
                  good_index, "0 fixture\n", 0, "", 0,
                  "AICI-SOIL-LOG")) ++failures;
    if (!one_case(base, "task-failure", good_rev, "cpp-spec\n",
                  bad_index, "1 fixture\n", 1, "", 0,
                  "AICI-SOIL-TASK")) ++failures;
    if (!one_case(base, "false-green", good_rev, "cpp-spec\n",
                  bad_index, "0 fixture\n", 1, "", 0,
                  "AICI-SOIL-TASK")) ++failures;
    if (!one_case(base, "bad-summary", good_rev, "cpp-spec\n",
                  good_index, "7 fixture\n", 1, "", 0,
                  "AICI-SOIL-STATUS")) ++failures;
    if (!one_case(base, "allowed-task-failure", good_rev, "cpp-spec\n",
                  bad_index, "1 fixture\n", 1, "task-one=1", 1,
                  "-")) ++failures;
    if (!one_case(base, "wrong-allowed-status", good_rev, "cpp-spec\n",
                  bad_index, "1 fixture\n", 1, "task-one=2", 0,
                  "AICI-SOIL-TASK")) ++failures;
    if (!one_case(base, "allowed-false-summary", good_rev, "cpp-spec\n",
                  bad_index, "0 fixture\n", 1, "task-one=1", 0,
                  "AICI-SOIL-STATUS")) ++failures;
    if (!one_case(base, "malformed-allowlist", good_rev, "cpp-spec\n",
                  good_index, "0 fixture\n", 1, "task-one", 0,
                  "AICI-SOIL-ALLOW")) ++failures;

    printf("soil-self-test-summary\tcases=12\tfailures=%d\n", failures);
    return failures == 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s verify ROOT JOB EXPECTED_REVISION [ALLOWED_TASK_FAILURES]\n"
            "  %s self-test\n",
            program, program);
}

int main(int argc, char **argv) {
    VerifyResult result;
    if ((argc == 5 || argc == 6) && strcmp(argv[1], "verify") == 0) {
        return verify(argv[2], argv[3], argv[4],
                      argc == 6 ? argv[5] : "",
                      0, &result, stdout) ? 0 : 1;
    }
    if (argc == 2 && strcmp(argv[1], "self-test") == 0) {
        return self_test() ? 0 : 1;
    }
    usage(argv[0]);
    return 2;
}
