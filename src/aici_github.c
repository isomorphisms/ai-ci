#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define PATH_MAX_AICI 4096
#define LINE_MAX_AICI (1024 * 1024)

typedef struct Exception {
    char *workflow;
    char *job;
    char *runs_on;
    char *reason;
    int used;
    struct Exception *next;
} Exception;

typedef struct {
    int failures;
    int workflows;
    int jobs;
} Result;

static char *trim(char *s) {
    char *end;
    while (isspace((unsigned char)*s)) ++s;
    end = s + strlen(s);
    while (end > s && isspace((unsigned char)end[-1])) --end;
    *end = '\0';
    return s;
}

static int regular_file(const char *path) {
    struct stat st;
    return lstat(path, &st) == 0 && S_ISREG(st.st_mode);
}

static int directory(const char *path) {
    struct stat st;
    return lstat(path, &st) == 0 && S_ISDIR(st.st_mode);
}

static int ends_with(const char *s, const char *suffix) {
    size_t ns = strlen(s), nx = strlen(suffix);
    return ns >= nx && strcmp(s + ns - nx, suffix) == 0;
}

static int join_path(char *out, size_t n, const char *a, const char *b) {
    int written;
    if (strcmp(a, ".") == 0) written = snprintf(out, n, "%s", b);
    else written = snprintf(out, n, "%s/%s", a, b);
    return written >= 0 && (size_t)written < n;
}

static void fail(Result *result, const char *code, const char *workflow,
                 const char *job, const char *detail) {
    ++result->failures;
    fprintf(stderr, "%s\t%s\t%s\t%s\n", code,
            workflow != NULL ? workflow : "-",
            job != NULL ? job : "-",
            detail != NULL ? detail : "-");
}

static int split_tabs(char *line, char **fields, int max_fields) {
    int count = 0;
    char *p = line;
    if (max_fields < 1) return 0;
    fields[count++] = p;
    while (*p != '\0') {
        if (*p == '\t') {
            *p = '\0';
            if (count >= max_fields) return -1;
            fields[count++] = p + 1;
        }
        ++p;
    }
    return count;
}

static void free_exceptions(Exception *head) {
    while (head != NULL) {
        Exception *next = head->next;
        free(head->workflow);
        free(head->job);
        free(head->runs_on);
        free(head->reason);
        free(head);
        head = next;
    }
}

static int hosted_runner(const char *value) {
    return strncmp(value, "ubuntu-", 7) == 0 ||
           strncmp(value, "windows-", 8) == 0 ||
           strncmp(value, "macos-", 6) == 0;
}

static Exception *find_exception(Exception *head, const char *workflow,
                                 const char *job, const char *runs_on) {
    while (head != NULL) {
        if (strcmp(head->workflow, workflow) == 0 &&
            strcmp(head->job, job) == 0 &&
            strcmp(head->runs_on, runs_on) == 0) {
            return head;
        }
        head = head->next;
    }
    return NULL;
}

static int load_exceptions(const char *root, const char *relative,
                           Exception **out, Result *result) {
    FILE *file;
    char path[PATH_MAX_AICI];
    char *line = NULL;
    size_t cap = 0;
    ssize_t len;
    int row = 0;
    Exception *head = NULL;

    *out = NULL;
    if (strcmp(relative, "-") == 0) return 1;
    if (!join_path(path, sizeof(path), root, relative)) {
        fail(result, "GITHUB-EXCEPTION-MALFORMED", relative, NULL,
             "exception path too long");
        return 0;
    }
    if (!regular_file(path)) {
        fail(result, "GITHUB-EXCEPTION-MALFORMED", relative, NULL,
             "exception file missing");
        return 0;
    }
    file = fopen(path, "r");
    if (file == NULL) {
        fail(result, "GITHUB-EXCEPTION-MALFORMED", relative, NULL,
             "cannot open exception file");
        return 0;
    }
    while ((len = getline(&line, &cap, file)) >= 0) {
        char *fields[4];
        int count;
        char *content;
        Exception *item;
        if (len > LINE_MAX_AICI) {
            fail(result, "GITHUB-EXCEPTION-MALFORMED", relative, NULL,
                 "exception line too long");
            break;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        ++row;
        count = split_tabs(content, fields, 4);
        if (row == 1 && count == 4 && strcmp(fields[0], "workflow") == 0 &&
            strcmp(fields[1], "job") == 0 && strcmp(fields[2], "runs_on") == 0 &&
            strcmp(fields[3], "reason") == 0) {
            continue;
        }
        if (count != 4 || *trim(fields[0]) == '\0' || *trim(fields[1]) == '\0' ||
            *trim(fields[2]) == '\0' || *trim(fields[3]) == '\0' ||
            !hosted_runner(trim(fields[2]))) {
            fail(result, "GITHUB-EXCEPTION-MALFORMED", relative, NULL,
                 "expected workflow, job, concrete hosted runs_on, reason");
            continue;
        }
        item = calloc(1, sizeof(*item));
        if (item == NULL) {
            fclose(file);
            free(line);
            free_exceptions(head);
            return 0;
        }
        item->workflow = strdup(trim(fields[0]));
        item->job = strdup(trim(fields[1]));
        item->runs_on = strdup(trim(fields[2]));
        item->reason = strdup(trim(fields[3]));
        if (item->workflow == NULL || item->job == NULL || item->runs_on == NULL ||
            item->reason == NULL) {
            fclose(file);
            free(line);
            free_exceptions(item);
            free_exceptions(head);
            return 0;
        }
        if (find_exception(head, item->workflow, item->job, item->runs_on) != NULL) {
            fail(result, "GITHUB-EXCEPTION-MALFORMED", relative, NULL,
                 "duplicate exception");
            free_exceptions(item);
            continue;
        }
        item->next = head;
        head = item;
    }
    free(line);
    fclose(file);
    *out = head;
    return 1;
}

static size_t indent_of(const char *line) {
    size_t n = 0;
    while (line[n] == ' ') ++n;
    return n;
}

static void strip_comment(char *line) {
    int single = 0, doubleq = 0;
    char *p;
    for (p = line; *p != '\0'; ++p) {
        if (*p == '\'' && !doubleq) single = !single;
        else if (*p == '"' && !single && (p == line || p[-1] != '\\')) doubleq = !doubleq;
        else if (*p == '#' && !single && !doubleq &&
                 (p == line || isspace((unsigned char)p[-1]))) {
            *p = '\0';
            return;
        }
    }
}

static char *yaml_scalar(char *text) {
    char *s = trim(text);
    size_t n = strlen(s);
    if (n >= 2 && ((s[0] == '"' && s[n - 1] == '"') ||
                   (s[0] == '\'' && s[n - 1] == '\''))) {
        s[n - 1] = '\0';
        ++s;
    }
    return trim(s);
}

static int canonical_guard(const char *value) {
    char buf[2048];
    char *s;
    size_t n;
    if (strlen(value) >= sizeof(buf)) return 0;
    strcpy(buf, value);
    s = trim(buf);
    n = strlen(s);
    if (n >= 5 && strncmp(s, "${{", 3) == 0 && strcmp(s + n - 2, "}}") == 0) {
        s[n - 2] = '\0';
        s = trim(s + 3);
    }
    return strcmp(s,
        "github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository") == 0 ||
           strcmp(s,
        "github.event_name != \"pull_request\" || github.event.pull_request.head.repo.full_name == github.repository") == 0;
}

static int parse_inline_labels(const char *value, int *self_hosted, int *linux_label,
                               int *debian_label, int *extra) {
    char buf[1024];
    char *p, *end;
    *self_hosted = *linux_label = *debian_label = *extra = 0;
    if (strlen(value) >= sizeof(buf)) return 0;
    strcpy(buf, value);
    p = trim(buf);
    if (*p != '[') return 0;
    end = strrchr(p, ']');
    if (end == NULL || *trim(end + 1) != '\0') return 0;
    *end = '\0';
    ++p;
    while (*p != '\0') {
        char *comma = strchr(p, ',');
        char *item;
        if (comma != NULL) *comma = '\0';
        item = yaml_scalar(p);
        if (*item == '\0') return 0;
        if (strcmp(item, "self-hosted") == 0) ++*self_hosted;
        else if (strcmp(item, "linux") == 0) ++*linux_label;
        else if (strcmp(item, "debian") == 0) ++*debian_label;
        else ++*extra;
        if (comma == NULL) break;
        p = comma + 1;
    }
    return 1;
}

static int exact_debian_labels(int self_hosted, int linux_label, int debian_label,
                               int extra) {
    return self_hosted == 1 && linux_label == 1 && debian_label == 1 && extra == 0;
}

typedef struct {
    char name[256];
    size_t indent;
    size_t child_indent;
    int child_indent_set;
    int has_runs_on;
    int collecting_runs_on;
    size_t runs_on_indent;
    int self_hosted;
    int linux_label;
    int debian_label;
    int extra_label;
    int exact_debian;
    int hosted;
    int dynamic;
    char scalar_runs_on[512];
    int has_guard;
} Job;

static void clear_job(Job *job) {
    memset(job, 0, sizeof(*job));
    job->child_indent = (size_t)-1;
}

static void finish_job(Result *result, Exception *exceptions,
                       const char *workflow, int public_repo, int pull_request,
                       Job *job) {
    Exception *exception;
    if (job->name[0] == '\0') return;
    ++result->jobs;
    if (!job->has_runs_on) {
        fail(result, "GITHUB-RUNNER-MISSING", workflow, job->name,
             "job has no runs-on");
        return;
    }
    if (job->dynamic) {
        fail(result, "GITHUB-RUNNER-DYNAMIC", workflow, job->name,
             job->scalar_runs_on);
        return;
    }
    if (job->hosted) {
        exception = find_exception(exceptions, workflow, job->name,
                                   job->scalar_runs_on);
        if (exception == NULL) {
            fail(result, "GITHUB-RUNNER-FORBIDDEN", workflow, job->name,
                 job->scalar_runs_on);
        } else {
            exception->used = 1;
        }
        return;
    }
    if (!job->exact_debian) {
        fail(result, "GITHUB-RUNNER-DEBIAN-LABELS", workflow, job->name,
             "Linux jobs require exactly [self-hosted, linux, debian]");
        return;
    }
    if (public_repo && pull_request && !job->has_guard) {
        fail(result, "GITHUB-FORK-GUARD", workflow, job->name,
             "public pull_request self-hosted job lacks canonical same-repository guard");
    }
}

static int line_is_job_key(const char *content, char *name, size_t name_size) {
    const char *colon = strchr(content, ':');
    size_t n;
    if (colon == NULL || colon[1] != '\0') return 0;
    n = (size_t)(colon - content);
    if (n == 0 || n >= name_size) return 0;
    memcpy(name, content, n);
    name[n] = '\0';
    if (strchr(name, ' ') != NULL || strchr(name, '\t') != NULL) return 0;
    return 1;
}

static int workflow_has_pull_request_line(const char *content) {
    return strcmp(content, "pull_request:") == 0 ||
           strncmp(content, "pull_request:", 13) == 0;
}

static int scan_workflow(Result *result, Exception *exceptions, const char *root,
                         const char *relative, int public_repo) {
    char path[PATH_MAX_AICI];
    FILE *file;
    char *line = NULL;
    size_t cap = 0;
    ssize_t len;
    int in_on = 0;
    size_t on_indent = 0;
    int pull_request = 0;
    int in_jobs = 0;
    size_t jobs_indent = 0;
    Job job;

    clear_job(&job);
    if (!join_path(path, sizeof(path), root, relative)) {
        fail(result, "GITHUB-WORKFLOW-PARSE", relative, NULL, "path too long");
        return 0;
    }
    file = fopen(path, "r");
    if (file == NULL) {
        fail(result, "GITHUB-WORKFLOW-PARSE", relative, NULL, "cannot open workflow");
        return 0;
    }
    ++result->workflows;
    while ((len = getline(&line, &cap, file)) >= 0) {
        char *content;
        size_t indent;
        char raw[LINE_MAX_AICI > 65536 ? 65536 : LINE_MAX_AICI];
        if (len > LINE_MAX_AICI || (size_t)len >= sizeof(raw)) {
            fail(result, "GITHUB-WORKFLOW-PARSE", relative, NULL, "line too long");
            break;
        }
        memcpy(raw, line, (size_t)len + 1);
        strip_comment(raw);
        indent = indent_of(raw);
        content = trim(raw);
        if (*content == '\0') continue;

        if (indent == 0 && strncmp(content, "on:", 3) == 0) {
            in_on = 1;
            on_indent = indent;
            if (strstr(content + 3, "pull_request") != NULL) pull_request = 1;
            continue;
        }
        if (in_on && indent > on_indent) {
            if (workflow_has_pull_request_line(content)) pull_request = 1;
        } else if (in_on && indent <= on_indent) {
            in_on = 0;
        }

        if (indent == 0 && strcmp(content, "jobs:") == 0) {
            in_jobs = 1;
            jobs_indent = indent;
            continue;
        }
        if (!in_jobs) continue;
        if (indent <= jobs_indent) {
            finish_job(result, exceptions, relative, public_repo, pull_request, &job);
            clear_job(&job);
            in_jobs = 0;
            continue;
        }

        if (job.name[0] == '\0') {
            char name[256];
            if (line_is_job_key(content, name, sizeof(name))) {
                snprintf(job.name, sizeof(job.name), "%s", name);
                job.indent = indent;
            }
            continue;
        }

        if (indent == job.indent) {
            char name[256];
            if (line_is_job_key(content, name, sizeof(name))) {
                finish_job(result, exceptions, relative, public_repo, pull_request, &job);
                clear_job(&job);
                snprintf(job.name, sizeof(job.name), "%s", name);
                job.indent = indent;
                continue;
            }
        }

        if (indent <= job.indent) continue;
        if (!job.child_indent_set || indent < job.child_indent) {
            job.child_indent = indent;
            job.child_indent_set = 1;
        }

        if (job.collecting_runs_on) {
            if (indent > job.runs_on_indent && content[0] == '-') {
                char *item = yaml_scalar(content + 1);
                if (strcmp(item, "self-hosted") == 0) ++job.self_hosted;
                else if (strcmp(item, "linux") == 0) ++job.linux_label;
                else if (strcmp(item, "debian") == 0) ++job.debian_label;
                else ++job.extra_label;
                job.exact_debian = exact_debian_labels(job.self_hosted, job.linux_label,
                                                       job.debian_label, job.extra_label);
                continue;
            }
            job.collecting_runs_on = 0;
        }

        if (job.child_indent_set && indent == job.child_indent &&
            strncmp(content, "runs-on:", 8) == 0) {
            char *value = trim(content + 8);
            int sh, linux_label, debian_label, extra;
            job.has_runs_on = 1;
            job.runs_on_indent = indent;
            if (*value == '\0') {
                job.collecting_runs_on = 1;
            } else if (strstr(value, "${{") != NULL) {
                job.dynamic = 1;
                snprintf(job.scalar_runs_on, sizeof(job.scalar_runs_on), "%s", value);
            } else if (parse_inline_labels(value, &sh, &linux_label, &debian_label, &extra)) {
                job.self_hosted = sh;
                job.linux_label = linux_label;
                job.debian_label = debian_label;
                job.extra_label = extra;
                job.exact_debian = exact_debian_labels(sh, linux_label, debian_label, extra);
            } else {
                char *scalar = yaml_scalar(value);
                snprintf(job.scalar_runs_on, sizeof(job.scalar_runs_on), "%s", scalar);
                job.hosted = hosted_runner(scalar);
            }
            continue;
        }
        if (job.child_indent_set && indent == job.child_indent &&
            strncmp(content, "if:", 3) == 0) {
            char *value = trim(content + 3);
            if (canonical_guard(value)) job.has_guard = 1;
        }
    }
    finish_job(result, exceptions, relative, public_repo, pull_request, &job);
    free(line);
    fclose(file);
    return 1;
}

static int scan_workflows(Result *result, Exception *exceptions, const char *root,
                          int public_repo) {
    char dirpath[PATH_MAX_AICI];
    DIR *dir;
    struct dirent *entry;
    if (!join_path(dirpath, sizeof(dirpath), root, ".github/workflows")) {
        fail(result, "GITHUB-WORKFLOW-PARSE", ".github/workflows", NULL,
             "path too long");
        return 0;
    }
    if (!directory(dirpath)) return 1;
    dir = opendir(dirpath);
    if (dir == NULL) {
        fail(result, "GITHUB-WORKFLOW-PARSE", ".github/workflows", NULL,
             "cannot open workflow directory");
        return 0;
    }
    while ((entry = readdir(dir)) != NULL) {
        char relative[PATH_MAX_AICI];
        char full[PATH_MAX_AICI];
        if (entry->d_name[0] == '.') continue;
        if (!ends_with(entry->d_name, ".yml") && !ends_with(entry->d_name, ".yaml")) continue;
        if (snprintf(relative, sizeof(relative), ".github/workflows/%s", entry->d_name) < 0 ||
            !join_path(full, sizeof(full), root, relative) || !regular_file(full)) continue;
        scan_workflow(result, exceptions, root, relative, public_repo);
    }
    closedir(dir);
    return 1;
}

static void check_stale_exceptions(Result *result, Exception *head) {
    while (head != NULL) {
        if (!head->used) {
            char detail[1024];
            snprintf(detail, sizeof(detail), "%s: %s", head->runs_on, head->reason);
            fail(result, "GITHUB-EXCEPTION-STALE", head->workflow, head->job, detail);
        }
        head = head->next;
    }
}

static int verify(const char *root, const char *exceptions_path, const char *visibility) {
    Result result = {0, 0, 0};
    Exception *exceptions = NULL;
    int public_repo;
    if (strcmp(visibility, "public") == 0) public_repo = 1;
    else if (strcmp(visibility, "private") == 0) public_repo = 0;
    else {
        fprintf(stderr, "usage: aici-github verify ROOT EXCEPTIONS public|private\n");
        return 2;
    }
    if (!load_exceptions(root, exceptions_path, &exceptions, &result)) {
        free_exceptions(exceptions);
        return result.failures ? 1 : 2;
    }
    scan_workflows(&result, exceptions, root, public_repo);
    check_stale_exceptions(&result, exceptions);
    if (result.failures == 0) {
        printf("PASS\tGITHUB-RUNNER-POLICY\tworkflows=%d\tjobs=%d\n",
               result.workflows, result.jobs);
    }
    free_exceptions(exceptions);
    return result.failures == 0 ? 0 : 1;
}

int main(int argc, char **argv) {
    if (argc == 5 && strcmp(argv[1], "verify") == 0) {
        return verify(argv[2], argv[3], argv[4]);
    }
    fprintf(stderr, "usage: aici-github verify ROOT EXCEPTIONS public|private\n");
    return 2;
}
