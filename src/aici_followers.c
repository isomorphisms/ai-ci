#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define PATH_MAXIMUM 4096
#define VALUE_MAXIMUM 4096
#define JOB_MAXIMUM 512
#define FIELD_MAXIMUM 32

typedef struct {
    char schema[64];
    char job_id[256];
    char repository[256];
    char branch[256];
    char pr[64];
    char trigger_commit[128];
    char leader_platform[128];
    char leader_arch[128];
    char leader_evidence[PATH_MAXIMUM];
    char artifact[PATH_MAXIMUM];
    char artifact_sha256[128];
    char follower_platform[128];
    char follower_arch[128];
    char required[32];
    char action[VALUE_MAXIMUM];
    char acceptance_kind[64];
    char acceptance_action[VALUE_MAXIMUM];
    char state[64];
    char last_attempt_commit[128];
    char blocker[VALUE_MAXIMUM];
    char evidence[PATH_MAXIMUM];
    char depends_on[VALUE_MAXIMUM];
    char reason[VALUE_MAXIMUM];
    char superseded_by[256];
    char follow_policy[64];
    char path[PATH_MAXIMUM];
} Job;

typedef struct {
    char schema[64];
    char job_id[256];
    char repository[256];
    char trigger_commit[128];
    char follower_platform[128];
    char follower_arch[128];
    char acceptance_kind[64];
    char result[32];
    char attempt_commit[128];
    char os_runtime[VALUE_MAXIMUM];
    char build_command[VALUE_MAXIMUM];
    char test_command[VALUE_MAXIMUM];
    char artifact[PATH_MAXIMUM];
    char artifact_sha256[128];
    char evidence_url[VALUE_MAXIMUM];
    char recorded_at[128];
    char note[VALUE_MAXIMUM];
} Receipt;

typedef struct {
    Job jobs[JOB_MAXIMUM];
    int count;
} Ledger;

static int copy_value(char *destination, size_t size, const char *source) {
    int written = snprintf(destination, size, "%s", source);
    return written >= 0 && (size_t)written < size;
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

static void strip_line_end(char *line) {
    size_t length = strlen(line);
    while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
        line[--length] = '\0';
    }
}

static int present(const char *value) {
    return value[0] != '\0';
}

static int dash(const char *value) {
    return strcmp(value, "-") == 0;
}

static int lower_hex(const char *value, size_t length) {
    size_t index;
    if (strlen(value) != length) return 0;
    for (index = 0; index < length; ++index) {
        if (!(isdigit((unsigned char)value[index]) ||
              (value[index] >= 'a' && value[index] <= 'f'))) return 0;
    }
    return 1;
}

static int valid_commit(const char *value) {
    return lower_hex(value, 40) || lower_hex(value, 64);
}

static int valid_sha256_or_dash(const char *value) {
    return dash(value) || lower_hex(value, 64);
}

static int valid_job_id(const char *value) {
    const unsigned char *cursor = (const unsigned char *)value;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(isalnum(*cursor) || *cursor == '-' || *cursor == '_' || *cursor == '.')) return 0;
        ++cursor;
    }
    return 1;
}

static int safe_filename(const char *value) {
    return valid_job_id(value) && strstr(value, "..") == NULL;
}

static int one_of(const char *value, const char *const *items, size_t count) {
    size_t index;
    for (index = 0; index < count; ++index) {
        if (strcmp(value, items[index]) == 0) return 1;
    }
    return 0;
}

#define SET_FIELD(KEY, MEMBER) \
    if (strcmp(key, KEY) == 0) { \
        if (present(record->MEMBER)) return 0; \
        return copy_value(record->MEMBER, sizeof(record->MEMBER), value); \
    }

static int set_job_field(Job *record, const char *key, const char *value) {
    SET_FIELD("schema", schema)
    SET_FIELD("job_id", job_id)
    SET_FIELD("repository", repository)
    SET_FIELD("branch", branch)
    SET_FIELD("pr", pr)
    SET_FIELD("trigger_commit", trigger_commit)
    SET_FIELD("leader_platform", leader_platform)
    SET_FIELD("leader_arch", leader_arch)
    SET_FIELD("leader_evidence", leader_evidence)
    SET_FIELD("artifact", artifact)
    SET_FIELD("artifact_sha256", artifact_sha256)
    SET_FIELD("follower_platform", follower_platform)
    SET_FIELD("follower_arch", follower_arch)
    SET_FIELD("required", required)
    SET_FIELD("action", action)
    SET_FIELD("acceptance_kind", acceptance_kind)
    SET_FIELD("acceptance_action", acceptance_action)
    SET_FIELD("state", state)
    SET_FIELD("last_attempt_commit", last_attempt_commit)
    SET_FIELD("blocker", blocker)
    SET_FIELD("evidence", evidence)
    SET_FIELD("depends_on", depends_on)
    SET_FIELD("reason", reason)
    SET_FIELD("superseded_by", superseded_by)
    SET_FIELD("follow_policy", follow_policy)
    return 0;
}

static int set_receipt_field(Receipt *record, const char *key, const char *value) {
    SET_FIELD("schema", schema)
    SET_FIELD("job_id", job_id)
    SET_FIELD("repository", repository)
    SET_FIELD("trigger_commit", trigger_commit)
    SET_FIELD("follower_platform", follower_platform)
    SET_FIELD("follower_arch", follower_arch)
    SET_FIELD("acceptance_kind", acceptance_kind)
    SET_FIELD("result", result)
    SET_FIELD("attempt_commit", attempt_commit)
    SET_FIELD("os_runtime", os_runtime)
    SET_FIELD("build_command", build_command)
    SET_FIELD("test_command", test_command)
    SET_FIELD("artifact", artifact)
    SET_FIELD("artifact_sha256", artifact_sha256)
    SET_FIELD("evidence_url", evidence_url)
    SET_FIELD("recorded_at", recorded_at)
    SET_FIELD("note", note)
    return 0;
}

#undef SET_FIELD

typedef int (*FieldSetter)(void *, const char *, const char *);

static int load_record(const char *path, void *record, FieldSetter setter) {
    FILE *file = fopen(path, "r");
    char line[VALUE_MAXIMUM * 2];
    int line_number = 0;
    if (file == NULL) {
        fprintf(stderr, "%s: %s\n", path, strerror(errno));
        return 0;
    }
    while (fgets(line, sizeof(line), file) != NULL) {
        char *fields[2];
        int count;
        ++line_number;
        if (strchr(line, '\n') == NULL && !feof(file)) {
            fprintf(stderr, "%s:%d: line too long\n", path, line_number);
            fclose(file);
            return 0;
        }
        strip_line_end(line);
        if (line[0] == '\0' || line[0] == '#') continue;
        count = split_tabs(line, fields, 2);
        if (count != 2 || fields[0][0] == '\0' || fields[1][0] == '\0') {
            fprintf(stderr, "%s:%d: expected key<TAB>value\n", path, line_number);
            fclose(file);
            return 0;
        }
        if (!setter(record, fields[0], fields[1])) {
            fprintf(stderr, "%s:%d: unknown, duplicate, or oversized field: %s\n",
                    path, line_number, fields[0]);
            fclose(file);
            return 0;
        }
    }
    if (ferror(file)) {
        fprintf(stderr, "%s: read failed\n", path);
        fclose(file);
        return 0;
    }
    fclose(file);
    return 1;
}

static int set_job_field_adapter(void *record, const char *key, const char *value) {
    return set_job_field((Job *)record, key, value);
}

static int set_receipt_field_adapter(void *record, const char *key, const char *value) {
    return set_receipt_field((Receipt *)record, key, value);
}

static int required_job_fields(const Job *job) {
    return present(job->schema) && present(job->job_id) && present(job->repository) &&
           present(job->branch) && present(job->pr) && present(job->trigger_commit) &&
           present(job->leader_platform) && present(job->leader_arch) &&
           present(job->leader_evidence) && present(job->artifact) &&
           present(job->artifact_sha256) && present(job->follower_platform) &&
           present(job->follower_arch) && present(job->required) && present(job->action) &&
           present(job->acceptance_kind) && present(job->acceptance_action) &&
           present(job->state) && present(job->last_attempt_commit) &&
           present(job->blocker) && present(job->evidence) && present(job->depends_on) &&
           present(job->reason) && present(job->superseded_by) && present(job->follow_policy);
}

static int validate_job_shape(const Job *job) {
    static const char *const states[] = {
        "accepted", "pending", "blocked", "n/a", "unsupported", "superseded"
    };
    static const char *const required_values[] = {"yes", "conditional"};
    static const char *const kinds[] = {
        "build", "runtime", "artifact", "physical-device", "publication"
    };
    if (!required_job_fields(job)) {
        fprintf(stderr, "%s: missing required field\n", job->path);
        return 0;
    }
    if (strcmp(job->schema, "aici-follower-job-v1") != 0) {
        fprintf(stderr, "%s: unsupported schema %s\n", job->path, job->schema);
        return 0;
    }
    if (!valid_job_id(job->job_id)) {
        fprintf(stderr, "%s: invalid job_id %s\n", job->path, job->job_id);
        return 0;
    }
    if (!valid_commit(job->trigger_commit)) {
        fprintf(stderr, "%s: invalid trigger_commit\n", job->path);
        return 0;
    }
    if (!dash(job->last_attempt_commit) && !valid_commit(job->last_attempt_commit)) {
        fprintf(stderr, "%s: invalid last_attempt_commit\n", job->path);
        return 0;
    }
    if (!valid_sha256_or_dash(job->artifact_sha256)) {
        fprintf(stderr, "%s: invalid artifact_sha256\n", job->path);
        return 0;
    }
    if (!one_of(job->state, states, sizeof(states) / sizeof(states[0])) ||
        !one_of(job->required, required_values,
                sizeof(required_values) / sizeof(required_values[0])) ||
        !one_of(job->acceptance_kind, kinds, sizeof(kinds) / sizeof(kinds[0]))) {
        fprintf(stderr, "%s: invalid state, required value, or acceptance kind\n", job->path);
        return 0;
    }
    if (strcmp(job->follow_policy, "exact") != 0) {
        fprintf(stderr, "%s: v1 requires follow_policy=exact\n", job->path);
        return 0;
    }
    if (!dash(job->evidence) && !safe_filename(job->evidence)) {
        fprintf(stderr, "%s: evidence must be '-' or a receipt filename\n", job->path);
        return 0;
    }
    if (strcmp(job->state, "accepted") == 0 && dash(job->evidence)) {
        fprintf(stderr, "%s: accepted job has no receipt\n", job->path);
        return 0;
    }
    if (strcmp(job->state, "accepted") == 0 && !dash(job->blocker)) {
        fprintf(stderr, "%s: accepted job still has a blocker\n", job->path);
        return 0;
    }
    if (strcmp(job->state, "n/a") == 0) {
        if (strcmp(job->required, "conditional") != 0 || dash(job->reason)) {
            fprintf(stderr, "%s: n/a requires conditional scope and a reason\n", job->path);
            return 0;
        }
    }
    if (strcmp(job->state, "superseded") == 0 && dash(job->superseded_by)) {
        fprintf(stderr, "%s: superseded job has no successor\n", job->path);
        return 0;
    }
    if (strcmp(job->state, "unsupported") == 0 && dash(job->reason)) {
        fprintf(stderr, "%s: unsupported job needs an explicit reason\n", job->path);
        return 0;
    }
    if ((dash(job->artifact) && !dash(job->artifact_sha256)) ||
        (!dash(job->artifact) && dash(job->artifact_sha256))) {
        fprintf(stderr, "%s: artifact and artifact_sha256 must be supplied together\n", job->path);
        return 0;
    }
    return 1;
}

static int required_receipt_fields(const Receipt *receipt) {
    return present(receipt->schema) && present(receipt->job_id) &&
           present(receipt->repository) && present(receipt->trigger_commit) &&
           present(receipt->follower_platform) && present(receipt->follower_arch) &&
           present(receipt->acceptance_kind) && present(receipt->result) &&
           present(receipt->attempt_commit) && present(receipt->os_runtime) &&
           present(receipt->build_command) && present(receipt->test_command) &&
           present(receipt->artifact) && present(receipt->artifact_sha256) &&
           present(receipt->evidence_url) && present(receipt->recorded_at) &&
           present(receipt->note);
}

static int validate_receipt_shape(const Receipt *receipt, const char *path) {
    static const char *const results[] = {"pass", "fail"};
    static const char *const kinds[] = {
        "build", "runtime", "artifact", "physical-device", "publication"
    };
    if (!required_receipt_fields(receipt)) {
        fprintf(stderr, "%s: missing required receipt field\n", path);
        return 0;
    }
    if (strcmp(receipt->schema, "aici-follower-receipt-v1") != 0 ||
        !valid_job_id(receipt->job_id) || !valid_commit(receipt->trigger_commit) ||
        !valid_commit(receipt->attempt_commit) ||
        !one_of(receipt->result, results, sizeof(results) / sizeof(results[0])) ||
        !one_of(receipt->acceptance_kind, kinds, sizeof(kinds) / sizeof(kinds[0])) ||
        !valid_sha256_or_dash(receipt->artifact_sha256)) {
        fprintf(stderr, "%s: invalid receipt shape\n", path);
        return 0;
    }
    if ((dash(receipt->artifact) && !dash(receipt->artifact_sha256)) ||
        (!dash(receipt->artifact) && dash(receipt->artifact_sha256))) {
        fprintf(stderr, "%s: receipt artifact and hash must be supplied together\n", path);
        return 0;
    }
    return 1;
}

static int has_tsv_suffix(const char *name) {
    size_t length = strlen(name);
    return length > 4 && strcmp(name + length - 4, ".tsv") == 0;
}

static int compare_jobs(const void *left, const void *right) {
    const Job *a = (const Job *)left;
    const Job *b = (const Job *)right;
    return strcmp(a->job_id, b->job_id);
}

static int load_ledger(const char *jobs_dir, Ledger *ledger) {
    DIR *directory = opendir(jobs_dir);
    struct dirent *entry;
    if (directory == NULL) {
        fprintf(stderr, "%s: %s\n", jobs_dir, strerror(errno));
        return 0;
    }
    memset(ledger, 0, sizeof(*ledger));
    while ((entry = readdir(directory)) != NULL) {
        Job *job;
        if (entry->d_name[0] == '.' || !has_tsv_suffix(entry->d_name)) continue;
        if (ledger->count >= JOB_MAXIMUM) {
            fprintf(stderr, "%s: too many follower jobs\n", jobs_dir);
            closedir(directory);
            return 0;
        }
        job = &ledger->jobs[ledger->count];
        if (snprintf(job->path, sizeof(job->path), "%s/%s", jobs_dir, entry->d_name) >=
            (int)sizeof(job->path)) {
            fprintf(stderr, "%s/%s: path too long\n", jobs_dir, entry->d_name);
            closedir(directory);
            return 0;
        }
        if (!load_record(job->path, job, set_job_field_adapter) || !validate_job_shape(job)) {
            closedir(directory);
            return 0;
        }
        ++ledger->count;
    }
    closedir(directory);
    qsort(ledger->jobs, (size_t)ledger->count, sizeof(ledger->jobs[0]), compare_jobs);
    return 1;
}

static int find_job(const Ledger *ledger, const char *job_id) {
    int index;
    for (index = 0; index < ledger->count; ++index) {
        if (strcmp(ledger->jobs[index].job_id, job_id) == 0) return index;
    }
    return -1;
}

static int validate_links(const Ledger *ledger) {
    int index;
    for (index = 0; index < ledger->count; ++index) {
        const Job *job = &ledger->jobs[index];
        char dependencies[VALUE_MAXIMUM];
        char *save = NULL;
        char *token;
        if (index > 0 && strcmp(job->job_id, ledger->jobs[index - 1].job_id) == 0) {
            fprintf(stderr, "%s: duplicate job_id %s\n", job->path, job->job_id);
            return 0;
        }
        if (!dash(job->superseded_by) && find_job(ledger, job->superseded_by) < 0) {
            fprintf(stderr, "%s: missing superseded_by job %s\n", job->path, job->superseded_by);
            return 0;
        }
        if (dash(job->depends_on)) continue;
        if (!copy_value(dependencies, sizeof(dependencies), job->depends_on)) return 0;
        token = strtok_r(dependencies, ",", &save);
        while (token != NULL) {
            if (strcmp(token, job->job_id) == 0 || find_job(ledger, token) < 0) {
                fprintf(stderr, "%s: invalid dependency %s\n", job->path, token);
                return 0;
            }
            token = strtok_r(NULL, ",", &save);
        }
    }
    return 1;
}

static int load_receipt_for_job(const char *receipts_dir, const Job *job,
                                Receipt *receipt, char *path, size_t path_size) {
    if (dash(job->evidence)) return 0;
    if (snprintf(path, path_size, "%s/%s", receipts_dir, job->evidence) >= (int)path_size) {
        fprintf(stderr, "%s: receipt path too long\n", job->path);
        return -1;
    }
    memset(receipt, 0, sizeof(*receipt));
    if (!load_record(path, receipt, set_receipt_field_adapter) ||
        !validate_receipt_shape(receipt, path)) return -1;
    return 1;
}

static int receipt_matches_job(const Job *job, const Receipt *receipt, const char *path) {
    if (strcmp(receipt->job_id, job->job_id) != 0 ||
        strcmp(receipt->repository, job->repository) != 0 ||
        strcmp(receipt->trigger_commit, job->trigger_commit) != 0 ||
        strcmp(receipt->follower_platform, job->follower_platform) != 0 ||
        strcmp(receipt->follower_arch, job->follower_arch) != 0 ||
        strcmp(receipt->acceptance_kind, job->acceptance_kind) != 0) {
        fprintf(stderr, "%s: receipt identity does not match job %s\n", path, job->job_id);
        return 0;
    }
    if (strcmp(receipt->artifact, job->artifact) != 0 ||
        strcmp(receipt->artifact_sha256, job->artifact_sha256) != 0) {
        fprintf(stderr, "%s: receipt artifact does not match job %s\n", path, job->job_id);
        return 0;
    }
    return 1;
}

static int verify_ledger(const Ledger *ledger, const char *receipts_dir) {
    int index;
    if (!validate_links(ledger)) return 0;
    for (index = 0; index < ledger->count; ++index) {
        const Job *job = &ledger->jobs[index];
        Receipt receipt;
        char path[PATH_MAXIMUM];
        int loaded = load_receipt_for_job(receipts_dir, job, &receipt, path, sizeof(path));
        if (loaded < 0) return 0;
        if (loaded > 0 && !receipt_matches_job(job, &receipt, path)) return 0;
        if (strcmp(job->state, "accepted") == 0) {
            if (loaded == 0 || strcmp(receipt.result, "pass") != 0 ||
                strcmp(receipt.attempt_commit, job->trigger_commit) != 0) {
                fprintf(stderr, "%s: accepted job lacks an exact passing receipt\n", job->path);
                return 0;
            }
        }
        if (loaded > 0 && strcmp(receipt.result, "pass") == 0 &&
            strcmp(job->state, "accepted") != 0) {
            fprintf(stderr, "%s: passing receipt exists but state is %s\n", job->path, job->state);
            return 0;
        }
    }
    return 1;
}

static int unresolved(const Job *job) {
    return strcmp(job->state, "pending") == 0 || strcmp(job->state, "blocked") == 0 ||
           strcmp(job->state, "unsupported") == 0;
}

static int command_verify(const Ledger *ledger, const char *receipts_dir) {
    int index;
    int accepted = 0;
    int pending = 0;
    int other = 0;
    if (!verify_ledger(ledger, receipts_dir)) return 1;
    for (index = 0; index < ledger->count; ++index) {
        if (strcmp(ledger->jobs[index].state, "accepted") == 0) ++accepted;
        else if (unresolved(&ledger->jobs[index])) ++pending;
        else ++other;
    }
    printf("verified %d follower jobs: %d accepted, %d unresolved, %d not-required/superseded\n",
           ledger->count, accepted, pending, other);
    return 0;
}

static int trigger_selected(const Job *job, const char *trigger) {
    return trigger == NULL || strcmp(job->trigger_commit, trigger) == 0;
}

static int command_pending(const Ledger *ledger, const char *receipts_dir, const char *trigger) {
    int index;
    if (!verify_ledger(ledger, receipts_dir)) return 1;
    puts("job_id\trepository\ttrigger_commit\tfollower_platform\tfollower_arch\tacceptance_kind\tstate\taction\tblocker");
    for (index = 0; index < ledger->count; ++index) {
        const Job *job = &ledger->jobs[index];
        if (!unresolved(job) || !trigger_selected(job, trigger)) continue;
        printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
               job->job_id, job->repository, job->trigger_commit,
               job->follower_platform, job->follower_arch, job->acceptance_kind,
               job->state, job->action, job->blocker);
    }
    return 0;
}

static int command_matrix(const Ledger *ledger, const char *receipts_dir, const char *trigger) {
    int index;
    if (!verify_ledger(ledger, receipts_dir)) return 1;
    puts("job_id\ttrigger_commit\tleader_platform\tleader_arch\tfollower_platform\tfollower_arch\trequired\tacceptance_kind\tstate\tevidence\treason");
    for (index = 0; index < ledger->count; ++index) {
        const Job *job = &ledger->jobs[index];
        if (!trigger_selected(job, trigger)) continue;
        printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
               job->job_id, job->trigger_commit, job->leader_platform, job->leader_arch,
               job->follower_platform, job->follower_arch, job->required,
               job->acceptance_kind, job->state, job->evidence, job->reason);
    }
    return 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage: %s verify JOBS_DIR RECEIPTS_DIR\n"
            "       %s pending JOBS_DIR RECEIPTS_DIR [TRIGGER_COMMIT]\n"
            "       %s matrix JOBS_DIR RECEIPTS_DIR [TRIGGER_COMMIT]\n",
            program, program, program);
}

int main(int argc, char **argv) {
    Ledger *ledger;
    const char *trigger = NULL;
    int result;
    if (argc < 4 || argc > 5) {
        usage(argv[0]);
        return 2;
    }
    ledger = calloc(1, sizeof(*ledger));
    if (ledger == NULL) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }
    if (!load_ledger(argv[2], ledger)) {
        free(ledger);
        return 1;
    }
    if (argc == 5) {
        trigger = argv[4];
        if (!valid_commit(trigger)) {
            fprintf(stderr, "invalid trigger commit filter\n");
            free(ledger);
            return 2;
        }
    }
    if (strcmp(argv[1], "verify") == 0 && argc == 4) result = command_verify(ledger, argv[3]);
    else if (strcmp(argv[1], "pending") == 0) result = command_pending(ledger, argv[3], trigger);
    else if (strcmp(argv[1], "matrix") == 0) result = command_matrix(ledger, argv[3], trigger);
    else {
        usage(argv[0]);
        result = 2;
    }
    free(ledger);
    return result;
}
