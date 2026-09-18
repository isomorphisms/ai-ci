#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define AICI_PATH_MAX 4096
#define AICI_LINE_MAX (1024 * 1024)
#define AICI_FILE_MAX (32 * 1024 * 1024)
#define AICI_FIELDS_MAX 16

typedef struct {
    int assertions;
    int failures;
    int quiet;
    char first_code[128];
} VerifyResult;

typedef struct StringNode {
    char *value;
    struct StringNode *next;
} StringNode;

typedef struct ContractCoverage {
    char *path;
    int has_positive;
    StringNode *negative_codes;
    struct ContractCoverage *next;
} ContractCoverage;

static char *trim(char *s);

static int regular_file(const char *path) {
    struct stat info;
    return lstat(path, &info) == 0 && S_ISREG(info.st_mode);
}

static int string_set_contains(const StringNode *set, const char *value) {
    while (set != NULL) {
        if (strcmp(set->value, value) == 0) return 1;
        set = set->next;
    }
    return 0;
}

static int string_set_add(StringNode **set, const char *value) {
    StringNode *node;
    if (string_set_contains(*set, value)) return 1;
    node = malloc(sizeof(*node));
    if (node == NULL) return 0;
    node->value = strdup(value);
    if (node->value == NULL) {
        free(node);
        return 0;
    }
    node->next = *set;
    *set = node;
    return 1;
}

static void string_set_free(StringNode *set) {
    while (set != NULL) {
        StringNode *next = set->next;
        free(set->value);
        free(set);
        set = next;
    }
}

static ContractCoverage *coverage_get(ContractCoverage **coverage,
                                      const char *path) {
    ContractCoverage *item = *coverage;
    while (item != NULL) {
        if (strcmp(item->path, path) == 0) return item;
        item = item->next;
    }
    item = calloc(1, sizeof(*item));
    if (item == NULL) return NULL;
    item->path = strdup(path);
    if (item->path == NULL) {
        free(item);
        return NULL;
    }
    item->next = *coverage;
    *coverage = item;
    return item;
}

static void coverage_free(ContractCoverage *coverage) {
    while (coverage != NULL) {
        ContractCoverage *next = coverage->next;
        free(coverage->path);
        string_set_free(coverage->negative_codes);
        free(coverage);
        coverage = next;
    }
}

static void json_string(const char *s) {
    const unsigned char *p = (const unsigned char *)s;
    putchar('"');
    while (*p != '\0') {
        switch (*p) {
            case '"': fputs("\\\"", stdout); break;
            case '\\': fputs("\\\\", stdout); break;
            case '\n': fputs("\\n", stdout); break;
            case '\r': fputs("\\r", stdout); break;
            case '\t': fputs("\\t", stdout); break;
            default:
                if (*p < 0x20) {
                    printf("\\u%04x", (unsigned int)*p);
                } else {
                    putchar((int)*p);
                }
        }
        ++p;
    }
    putchar('"');
}

static void emit_assertion(const char *status, const char *code,
                           const char *operation, const char *detail) {
    fputs("{\"kind\":\"assertion\",\"status\":", stdout);
    json_string(status);
    fputs(",\"code\":", stdout);
    json_string(code);
    fputs(",\"operation\":", stdout);
    json_string(operation);
    fputs(",\"detail\":", stdout);
    json_string(detail);
    fputs("}\n", stdout);
}

static void record_result(VerifyResult *result, int ok, const char *code,
                          const char *operation, const char *detail) {
    ++result->assertions;
    if (!ok) {
        ++result->failures;
        if (result->first_code[0] == '\0') {
            snprintf(result->first_code, sizeof(result->first_code), "%s", code);
        }
    }
    if (!result->quiet) {
        emit_assertion(ok ? "pass" : "fail", code, operation, detail);
    }
}

static int safe_relative_path(const char *path) {
    const char *p;
    if (path[0] == '\0' || path[0] == '/') {
        return 0;
    }
    for (p = path; *p != '\0'; ++p) {
        if ((p == path || p[-1] == '/') && p[0] == '.' && p[1] == '.' &&
            (p[2] == '/' || p[2] == '\0')) {
            return 0;
        }
    }
    return 1;
}

static int join_path(char *out, size_t out_size, const char *root,
                     const char *relative) {
    int written;
    if (root[0] == '\0' || !safe_relative_path(relative)) {
        return 0;
    }
    if (strcmp(root, ".") == 0) {
        written = snprintf(out, out_size, "%s", relative);
    } else {
        written = snprintf(out, out_size, "%s/%s", root, relative);
    }
    return written >= 0 && (size_t)written < out_size;
}

static char *read_file(const char *path, size_t *size_out) {
    FILE *file;
    long size;
    char *data;
    size_t got;

    if (!regular_file(path)) {
        return NULL;
    }
    file = fopen(path, "rb");
    if (file == NULL) {
        return NULL;
    }
    if (fseek(file, 0, SEEK_END) != 0) {
        fclose(file);
        return NULL;
    }
    size = ftell(file);
    if (size < 0 || size > AICI_FILE_MAX || fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }
    data = malloc((size_t)size + 1);
    if (data == NULL) {
        fclose(file);
        return NULL;
    }
    got = fread(data, 1, (size_t)size, file);
    if (got != (size_t)size || ferror(file)) {
        free(data);
        fclose(file);
        return NULL;
    }
    data[got] = '\0';
    fclose(file);
    *size_out = got;
    return data;
}

static int file_nonempty(const char *path) {
    struct stat info;
    return lstat(path, &info) == 0 && S_ISREG(info.st_mode) && info.st_size > 0;
}

static int files_equal(const char *left_path, const char *right_path) {
    if (!regular_file(left_path) || !regular_file(right_path)) return 0;
    FILE *left = fopen(left_path, "rb");
    FILE *right = fopen(right_path, "rb");
    int left_byte;
    int right_byte;
    if (left == NULL || right == NULL) {
        if (left != NULL) fclose(left);
        if (right != NULL) fclose(right);
        return 0;
    }
    do {
        left_byte = fgetc(left);
        right_byte = fgetc(right);
        if (left_byte != right_byte) {
            fclose(left);
            fclose(right);
            return 0;
        }
    } while (left_byte != EOF);
    fclose(left);
    fclose(right);
    return 1;
}

static int file_contains(const char *path, const char *needle, int wanted) {
    size_t size = 0;
    char *data = read_file(path, &size);
    int found;
    (void)size;
    if (data == NULL) {
        return 0;
    }
    found = strstr(data, needle) != NULL;
    free(data);
    return wanted ? found : !found;
}

static int scoped_file_contains(const char *path, const char *scope,
                                const char *needle, int wanted) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int scope_seen = 0;
    int found = 0;
    int ok = 1;
    if (file == NULL || !regular_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *separator;
        char *record_scope;
        char *message;
        if (length > AICI_LINE_MAX ||
            memchr(line, '\0', (size_t)length) != NULL) {
            ok = 0;
            break;
        }
        while (length > 0 &&
               (line[length - 1] == '\n' || line[length - 1] == '\r')) {
            line[--length] = '\0';
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        separator = strchr(content, '\t');
        if (separator == NULL) {
            ok = 0;
            break;
        }
        *separator = '\0';
        record_scope = trim(content);
        message = separator + 1;
        if (*record_scope == '\0' || *message == '\0') {
            ok = 0;
            break;
        }
        if (strcmp(record_scope, scope) != 0) continue;
        scope_seen = 1;
        if (strstr(message, needle) != NULL) found = 1;
    }
    free(line);
    fclose(file);
    return ok && scope_seen && (wanted ? found : !found);
}

static char *trim(char *s) {
    char *end;
    while (isspace((unsigned char)*s)) ++s;
    end = s + strlen(s);
    while (end > s && isspace((unsigned char)end[-1])) --end;
    *end = '\0';
    return s;
}

static char *yaml_value(char *content, const char *key) {
    char *p = content;
    size_t key_length = strlen(key);
    if (*p == '-') {
        if (p[1] != '\0' && !isspace((unsigned char)p[1])) return NULL;
        p = trim(p + 1);
    }
    if (*p == '\0' || *p == '#') return NULL;
    if (strncmp(p, key, key_length) != 0 || p[key_length] != ':') return NULL;
    if (p[key_length + 1] != '\0' &&
        !isspace((unsigned char)p[key_length + 1])) {
        return NULL;
    }
    return trim(p + key_length + 1);
}

static int has_noncanonical_yaml_key(const char *content, const char *key) {
    const char *segment = content;
    size_t key_length = strlen(key);
    if (*segment == '-') {
        ++segment;
    }
    for (;;) {
        const char *p;
        const char *after_key = NULL;
        const char *comma;
        while (isspace((unsigned char)*segment) || *segment == '{') ++segment;
        p = segment;
        if (*p == '\'' || *p == '"') {
            int quote = (unsigned char)*p++;
            const char *end = strchr(p, quote);
            if (end != NULL && (size_t)(end - p) == key_length &&
                strncmp(p, key, key_length) == 0) {
                after_key = end + 1;
            }
        } else if (strncmp(p, key, key_length) == 0 &&
                   (p[key_length] == ':' ||
                    isspace((unsigned char)p[key_length]))) {
            after_key = p + key_length;
        }
        if (after_key != NULL) {
            while (isspace((unsigned char)*after_key)) ++after_key;
            if (*after_key == ':') return 1;
        }
        comma = strchr(segment, ',');
        if (comma == NULL) return 0;
        segment = comma + 1;
    }
}

static int split_tabs(char *line, char **fields, int maximum) {
    int count = 0;
    char *p = line;
    if (maximum <= 0) return 0;
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

static int parse_positive_int(const char *text, int *value) {
    char *end = NULL;
    long parsed;
    errno = 0;
    parsed = strtol(text, &end, 10);
    if (errno != 0 || end == text || *end != '\0' || parsed < 1 || parsed > 1000000) {
        return 0;
    }
    *value = (int)parsed;
    return 1;
}

static int tsv_shape(const char *path, int minimum_fields, int minimum_rows) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int rows = 0;
    int ok = 1;
    if (file == NULL || !regular_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[AICI_FIELDS_MAX];
        int count;
        int i;
        char *content;
        if (length > AICI_LINE_MAX) {
            ok = 0;
            break;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, AICI_FIELDS_MAX);
        if (count < minimum_fields) {
            ok = 0;
            break;
        }
        for (i = 0; i < minimum_fields; ++i) {
            if (*trim(fields[i]) == '\0') {
                ok = 0;
                break;
            }
        }
        if (!ok) break;
        ++rows;
    }
    free(line);
    fclose(file);
    return ok && rows >= minimum_rows;
}

static int tsv_header_is(const char *path, const char *expected_csv) {
    FILE *file;
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    char *expected;
    char *actual_fields[AICI_FIELDS_MAX];
    char *expected_fields[AICI_FIELDS_MAX];
    int actual_count;
    int expected_count;
    int i;
    int ok = 1;
    if (!regular_file(path)) return 0;
    file = fopen(path, "r");
    if (file == NULL) return 0;
    length = getline(&line, &capacity, file);
    fclose(file);
    if (length < 0 || length > AICI_LINE_MAX) {
        free(line);
        return 0;
    }
    expected = strdup(expected_csv);
    if (expected == NULL) {
        free(line);
        return 0;
    }
    actual_count = split_tabs(trim(line), actual_fields, AICI_FIELDS_MAX);
    expected_count = 0;
    expected_fields[expected_count++] = expected;
    for (i = 0; expected[i] != '\0'; ++i) {
        if (expected[i] == ',') {
            expected[i] = '\0';
            if (expected_count >= AICI_FIELDS_MAX) {
                ok = 0;
                break;
            }
            expected_fields[expected_count++] = expected + i + 1;
        }
    }
    if (ok && (actual_count != expected_count || actual_count < 1)) ok = 0;
    for (i = 0; ok && i < actual_count; ++i) {
        if (*expected_fields[i] == '\0' ||
            strcmp(trim(actual_fields[i]), expected_fields[i]) != 0) {
            ok = 0;
        }
    }
    free(expected);
    free(line);
    return ok;
}

static int workflow_has_declared_path(const char *workflow_path,
                                      const char *required_path,
                                      const char *event_name) {
    FILE *workflow = fopen(workflow_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int in_on = 0;
    int in_event = 0;
    int in_paths = 0;
    int have_on_child_indent = 0;
    int have_event_child_indent = 0;
    int target_event_count = 0;
    int target_paths_count = 0;
    size_t on_child_indent = 0;
    size_t event_indent = 0;
    size_t event_child_indent = 0;
    size_t paths_indent = 0;
    int included = 0;
    int valid = 1;
    char event_header[128];
    int event_written;
    if (workflow == NULL || !regular_file(workflow_path)) {
        if (workflow != NULL) fclose(workflow);
        return 0;
    }
    event_written = snprintf(event_header, sizeof(event_header), "%s:", event_name);
    if (event_written < 0 || (size_t)event_written >= sizeof(event_header)) {
        fclose(workflow);
        return 0;
    }
    while ((length = getline(&line, &capacity, workflow)) >= 0) {
        char *content;
        char *item;
        char *end_quote;
        char *comment;
        size_t indent = 0;
        if (length > AICI_LINE_MAX) {
            valid = 0;
            break;
        }
        while (line[indent] == ' ') ++indent;
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        if (indent == 0 && strcmp(content, "on:") == 0) {
            in_on = 1;
            in_event = 0;
            in_paths = 0;
            have_on_child_indent = 0;
            continue;
        }
        if (!in_on) continue;
        if (indent == 0) {
            in_on = 0;
            in_event = 0;
            in_paths = 0;
            continue;
        }
        if (!have_on_child_indent) {
            on_child_indent = indent;
            have_on_child_indent = 1;
        }
        if (indent == on_child_indent) {
            in_event = strcmp(content, event_header) == 0;
            if (in_event && ++target_event_count > 1) valid = 0;
            event_indent = indent;
            have_event_child_indent = 0;
            in_paths = 0;
            continue;
        }
        if (!in_event || indent <= event_indent) continue;
        if (!have_event_child_indent) {
            event_child_indent = indent;
            have_event_child_indent = 1;
        }
        if (indent == event_child_indent) {
            in_paths = strcmp(content, "paths:") == 0;
            if (in_paths) {
                if (++target_paths_count > 1) valid = 0;
                paths_indent = indent;
            }
            continue;
        }
        if (!in_paths) continue;
        if (indent <= paths_indent) {
            in_paths = 0;
            continue;
        }
        if (*content != '-' ||
            (!isspace((unsigned char)content[1]) && content[1] != '\0')) {
            continue;
        }
        item = trim(content + 1);
        if (*item == '\'' || *item == '"') {
            int quote = (unsigned char)*item++;
            end_quote = strchr(item, quote);
            if (end_quote == NULL) continue;
            *end_quote = '\0';
            if (*trim(end_quote + 1) != '\0' && *trim(end_quote + 1) != '#') {
                continue;
            }
        } else {
            comment = strchr(item, '#');
            if (comment != NULL &&
                (comment == item || isspace((unsigned char)comment[-1]))) {
                *comment = '\0';
                item = trim(item);
            }
        }
        if (*item == '!') {
            valid = 0;
            continue;
        }
        if (strcmp(item, required_path) == 0) included = 1;
    }
    free(line);
    fclose(workflow);
    return valid && included;
}

static int every_yaml_path_is_declared(const char *list_path,
                                       const char *workflow_path,
                                       const char *event_name) {
    FILE *list = fopen(list_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int items = 0;
    int ok = 1;
    if (list == NULL || !regular_file(list_path)) {
        if (list != NULL) fclose(list);
        return 0;
    }
    while ((length = getline(&line, &capacity, list)) >= 0) {
        char *item;
        if (length > AICI_LINE_MAX) {
            ok = 0;
            break;
        }
        item = trim(line);
        if (*item == '\0' || *item == '#') continue;
        ++items;
        if (!workflow_has_declared_path(workflow_path, item, event_name)) {
            ok = 0;
            break;
        }
    }
    free(line);
    fclose(list);
    return ok && items > 0;
}

static int has_suffix(const char *name, const char *suffix) {
    size_t name_length = strlen(name);
    size_t suffix_length = strlen(suffix);
    return suffix_length <= name_length &&
           strcmp(name + name_length - suffix_length, suffix) == 0;
}

static int name_has_forbidden_suffix(const char *name, const char *csv) {
    char *copy = strdup(csv);
    char *part;
    char *save = NULL;
    int forbidden = 0;
    if (copy == NULL) return 1;
    for (part = strtok_r(copy, ",", &save); part != NULL;
         part = strtok_r(NULL, ",", &save)) {
        part = trim(part);
        if (*part != '\0' && has_suffix(name, part)) {
            forbidden = 1;
            break;
        }
    }
    free(copy);
    return forbidden;
}

static int scan_suffixes(const char *path, const char *csv, int *files_seen) {
    DIR *directory = opendir(path);
    struct dirent *entry;
    if (directory == NULL) return 0;
    while ((entry = readdir(directory)) != NULL) {
        char child[AICI_PATH_MAX];
        struct stat info;
        int written;
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0 ||
            strcmp(entry->d_name, ".git") == 0) {
            continue;
        }
        written = snprintf(child, sizeof(child), "%s/%s", path, entry->d_name);
        if (written < 0 || (size_t)written >= sizeof(child) || lstat(child, &info) != 0) {
            closedir(directory);
            return 0;
        }
        if (name_has_forbidden_suffix(entry->d_name, csv)) {
            closedir(directory);
            return 0;
        }
        if (S_ISDIR(info.st_mode)) {
            if (!scan_suffixes(child, csv, files_seen)) {
                closedir(directory);
                return 0;
            }
        } else if (S_ISREG(info.st_mode)) {
            ++*files_seen;
        }
    }
    closedir(directory);
    return 1;
}

static int no_forbidden_suffix(const char *path, const char *csv) {
    int files_seen = 0;
    return scan_suffixes(path, csv, &files_seen) && files_seen > 0;
}

static int first_line_is(const char *path, const char *expected) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int ok = 0;
    if (file == NULL || !regular_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    length = getline(&line, &capacity, file);
    if (length >= 0) {
        while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
            line[--length] = '\0';
        }
        ok = strcmp(line, expected) == 0;
    }
    free(line);
    fclose(file);
    return ok;
}

static int scan_suffix_first_line(const char *path, const char *suffix,
                                  const char *expected, int *files_seen) {
    DIR *directory = opendir(path);
    struct dirent *entry;
    if (directory == NULL) return 0;
    while ((entry = readdir(directory)) != NULL) {
        char child[AICI_PATH_MAX];
        struct stat info;
        int written;
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0 ||
            strcmp(entry->d_name, ".git") == 0) {
            continue;
        }
        written = snprintf(child, sizeof(child), "%s/%s", path, entry->d_name);
        if (written < 0 || (size_t)written >= sizeof(child) || lstat(child, &info) != 0) {
            closedir(directory);
            return 0;
        }
        if (S_ISDIR(info.st_mode)) {
            if (!scan_suffix_first_line(child, suffix, expected, files_seen)) {
                closedir(directory);
                return 0;
            }
        } else if (has_suffix(entry->d_name, suffix)) {
            if (!S_ISREG(info.st_mode) || !first_line_is(child, expected)) {
                closedir(directory);
                return 0;
            }
            ++*files_seen;
        }
    }
    closedir(directory);
    return 1;
}

static int suffix_first_line_is(const char *path, const char *suffix,
                                const char *expected) {
    int files_seen = 0;
    return scan_suffix_first_line(path, suffix, expected, &files_seen) &&
           files_seen > 0;
}

static int all_actions_pinned(const char *path) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int remote_actions = 0;
    int ok = 1;
    if (file == NULL || !regular_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *comment;
        char *value;
        char *at;
        char *end;
        int i;
        if (length > AICI_LINE_MAX) {
            ok = 0;
            break;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        comment = strchr(content, '#');
        if (comment != NULL &&
            (*content == '#' || (comment > content && comment[-1] == '-'))) {
            continue;
        }
        value = yaml_value(content, "uses");
        if (value == NULL) {
            if (has_noncanonical_yaml_key(content, "uses")) {
                ok = 0;
                break;
            }
            continue;
        }
        if (*value == '\'' || *value == '"') ++value;
        if (strncmp(value, "./", 2) == 0) {
            continue;
        }
        if (strncmp(value, "docker://", 9) == 0) {
            ok = 0;
            break;
        }
        at = strchr(value, '@');
        if (at == NULL) {
            ok = 0;
            break;
        }
        ++remote_actions;
        ++at;
        end = at;
        while (isxdigit((unsigned char)*end)) ++end;
        if (end - at != 40) {
            ok = 0;
            break;
        }
        for (i = 0; i < 40; ++i) {
            if (!isxdigit((unsigned char)at[i])) {
                ok = 0;
                break;
            }
        }
        if (!ok) break;
        while (*end == '\'' || *end == '"' || isspace((unsigned char)*end)) ++end;
        if (*end != '\0' && *end != '#') {
            ok = 0;
            break;
        }
    }
    free(line);
    fclose(file);
    return ok && remote_actions > 0;
}

static int yaml_lacks_key(const char *path, const char *key) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int ok = 1;
    if (file == NULL || !regular_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        if (length > AICI_LINE_MAX) {
            ok = 0;
            break;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        if (yaml_value(content, key) != NULL ||
            has_noncanonical_yaml_key(content, key)) {
            ok = 0;
            break;
        }
    }
    free(line);
    fclose(file);
    return ok;
}

static char *unquote_scalar(char *value) {
    size_t length = strlen(value);
    if (length >= 2 &&
        ((value[0] == '\'' && value[length - 1] == '\'') ||
         (value[0] == '"' && value[length - 1] == '"'))) {
        value[length - 1] = '\0';
        return value + 1;
    }
    return value;
}

static int script_uses_runner(const char *path, const char *script,
                              const char *runner) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    char expected[AICI_PATH_MAX * 2];
    int matches = 0;
    int ok = 1;
    int in_run_block = 0;
    size_t run_indent = 0;
    int written;
    if (file == NULL || !regular_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    written = snprintf(expected, sizeof(expected), "%s %s", runner, script);
    if (written < 0 || (size_t)written >= sizeof(expected)) {
        fclose(file);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *value;
        size_t indent = 0;
        if (length > AICI_LINE_MAX) {
            ok = 0;
            break;
        }
        while (line[indent] == ' ') ++indent;
        content = trim(line);
        if (*content == '\0') continue;
        if (in_run_block && indent > run_indent) {
            if (*content != '#' && strstr(content, script) != NULL) {
                ok = 0;
                break;
            }
            continue;
        }
        in_run_block = 0;
        if (*content == '#') continue;
        value = yaml_value(content, "run");
        if (value == NULL) {
            if (strstr(content, script) != NULL &&
                has_noncanonical_yaml_key(content, "run")) {
                ok = 0;
                break;
            }
            continue;
        }
        if (strcmp(value, "|") == 0 || strcmp(value, "|-") == 0 ||
            strcmp(value, "|+") == 0 || strcmp(value, ">") == 0 ||
            strcmp(value, ">-") == 0 || strcmp(value, ">+") == 0) {
            in_run_block = 1;
            run_indent = indent;
            continue;
        }
        value = unquote_scalar(value);
        if (strstr(value, script) == NULL) continue;
        ++matches;
        if (strcmp(value, expected) != 0) {
            ok = 0;
            break;
        }
    }
    free(line);
    fclose(file);
    return ok && matches > 0;
}

static int valid_code(const char *code) {
    const unsigned char *p = (const unsigned char *)code;
    if (*p == '\0') return 0;
    while (*p != '\0') {
        if (!(isupper(*p) || isdigit(*p) || *p == '-')) return 0;
        ++p;
    }
    return 1;
}

static int verify_contract(const char *contract_path, const char *root,
                           int quiet, VerifyResult *result) {
    FILE *contract = fopen(contract_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int line_number = 0;

    memset(result, 0, sizeof(*result));
    result->quiet = quiet;
    if (contract == NULL) {
        record_result(result, 0, "AICI-CONTRACT-UNREADABLE", "contract", contract_path);
        return 0;
    }
    while ((length = getline(&line, &capacity, contract)) >= 0) {
        char *fields[AICI_FIELDS_MAX];
        char *content;
        int count;
        const char *operation;
        const char *code;
        char left[AICI_PATH_MAX];
        char right[AICI_PATH_MAX];
        char detail[AICI_PATH_MAX * 2];
        int ok = 0;
        int malformed = 0;

        ++line_number;
        if (length > AICI_LINE_MAX) {
            record_result(result, 0, "AICI-CONTRACT-LINE-LONG", "contract", contract_path);
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, AICI_FIELDS_MAX);
        if (count < 3) {
            record_result(result, 0, "AICI-CONTRACT-MALFORMED", "contract", contract_path);
            continue;
        }
        operation = fields[0];
        code = fields[1];
        if (!valid_code(code)) {
            record_result(result, 0, "AICI-CONTRACT-CODE", "contract", contract_path);
            continue;
        }

        if (strcmp(operation, "nonempty") == 0 && count == 3) {
            malformed = !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = file_nonempty(left);
            snprintf(detail, sizeof(detail), "%s", fields[2]);
        } else if (strcmp(operation, "equal") == 0 && count == 4) {
            malformed = !join_path(left, sizeof(left), root, fields[2]) ||
                        !join_path(right, sizeof(right), root, fields[3]);
            if (!malformed) ok = files_equal(left, right);
            snprintf(detail, sizeof(detail), "%s == %s", fields[2], fields[3]);
        } else if (strcmp(operation, "contains") == 0 && count == 4) {
            malformed = !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = file_contains(left, fields[3], 1);
            snprintf(detail, sizeof(detail), "%s", fields[2]);
        } else if (strcmp(operation, "not_contains") == 0 && count == 4) {
            malformed = fields[3][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = file_contains(left, fields[3], 0);
            snprintf(detail, sizeof(detail), "%s :: %s", fields[2], fields[3]);
        } else if (strcmp(operation, "scoped_contains") == 0 && count == 5) {
            malformed = fields[3][0] == '\0' || fields[4][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) {
                ok = scoped_file_contains(left, fields[3], fields[4], 1);
            }
            snprintf(detail, sizeof(detail), "%s scope=%s :: %s",
                     fields[2], fields[3], fields[4]);
        } else if (strcmp(operation, "scoped_not_contains") == 0 && count == 5) {
            malformed = fields[3][0] == '\0' || fields[4][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) {
                ok = scoped_file_contains(left, fields[3], fields[4], 0);
            }
            snprintf(detail, sizeof(detail), "%s scope=%s excludes %s",
                     fields[2], fields[3], fields[4]);
        } else if (strcmp(operation, "tsv") == 0 && count == 5) {
            int minimum_fields = 0;
            int minimum_rows = 0;
            malformed = !join_path(left, sizeof(left), root, fields[2]) ||
                        !parse_positive_int(fields[3], &minimum_fields) ||
                        !parse_positive_int(fields[4], &minimum_rows);
            if (!malformed) ok = tsv_shape(left, minimum_fields, minimum_rows);
            snprintf(detail, sizeof(detail), "%s fields=%s rows=%s",
                     fields[2], fields[3], fields[4]);
        } else if (strcmp(operation, "tsv_header") == 0 && count == 4) {
            malformed = fields[3][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = tsv_header_is(left, fields[3]);
            snprintf(detail, sizeof(detail), "%s header=%s", fields[2], fields[3]);
        } else if (strcmp(operation, "yaml_paths") == 0 && count == 5) {
            malformed = !join_path(left, sizeof(left), root, fields[2]) ||
                        !join_path(right, sizeof(right), root, fields[3]) ||
                        fields[4][0] == '\0';
            if (!malformed) ok = every_yaml_path_is_declared(left, right, fields[4]);
            snprintf(detail, sizeof(detail), "%s in %s.paths of %s",
                     fields[2], fields[4], fields[3]);
        } else if (strcmp(operation, "no_suffix") == 0 && count == 4) {
            malformed = fields[3][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = no_forbidden_suffix(left, fields[3]);
            snprintf(detail, sizeof(detail), "%s excludes %s", fields[2], fields[3]);
        } else if (strcmp(operation, "suffix_first_line") == 0 && count == 5) {
            malformed = fields[3][0] == '\0' || fields[4][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = suffix_first_line_is(left, fields[3], fields[4]);
            snprintf(detail, sizeof(detail), "%s *%s starts %s",
                     fields[2], fields[3], fields[4]);
        } else if (strcmp(operation, "actions_pinned") == 0 && count == 3) {
            malformed = !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = all_actions_pinned(left);
            snprintf(detail, sizeof(detail), "%s", fields[2]);
        } else if (strcmp(operation, "yaml_forbid_key") == 0 && count == 4) {
            malformed = fields[3][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = yaml_lacks_key(left, fields[3]);
            snprintf(detail, sizeof(detail), "%s excludes key %s",
                     fields[2], fields[3]);
        } else if (strcmp(operation, "script_runner") == 0 && count == 5) {
            malformed = fields[3][0] == '\0' || fields[4][0] == '\0' ||
                        !join_path(left, sizeof(left), root, fields[2]);
            if (!malformed) ok = script_uses_runner(left, fields[3], fields[4]);
            snprintf(detail, sizeof(detail), "%s runs %s with %s",
                     fields[2], fields[3], fields[4]);
        } else {
            malformed = 1;
            snprintf(detail, sizeof(detail), "%s:%d", contract_path, line_number);
        }

        if (malformed) {
            record_result(result, 0, "AICI-CONTRACT-MALFORMED", operation, detail);
        } else {
            record_result(result, ok, code, operation, detail);
        }
    }
    free(line);
    fclose(contract);
    if (result->assertions == 0) {
        record_result(result, 0, "AICI-NO-ASSERTIONS", "contract", contract_path);
    }
    if (!quiet) {
        printf("{\"kind\":\"summary\",\"status\":\"%s\",\"assertions\":%d,\"failures\":%d}\n",
               result->failures == 0 ? "pass" : "fail",
               result->assertions, result->failures);
    }
    return result->failures == 0;
}

static void emit_coverage_result(const char *status, const char *contract,
                                 const char *code, const char *detail) {
    fputs("{\"kind\":\"self-test-coverage\",\"status\":", stdout);
    json_string(status);
    fputs(",\"contract\":", stdout);
    json_string(contract);
    fputs(",\"code\":", stdout);
    json_string(code);
    fputs(",\"detail\":", stdout);
    json_string(detail);
    fputs("}\n", stdout);
}

static int audit_contract_coverage(ContractCoverage *coverage) {
    ContractCoverage *item;
    int failures = 0;
    for (item = coverage; item != NULL; item = item->next) {
        FILE *contract;
        char *line = NULL;
        size_t capacity = 0;
        ssize_t length;
        StringNode *seen_codes = NULL;
        if (!item->has_positive) {
            ++failures;
            emit_coverage_result("fail", item->path, "", "missing positive fixture");
        } else {
            emit_coverage_result("pass", item->path, "", "positive fixture");
        }
        contract = fopen(item->path, "r");
        if (contract == NULL || !regular_file(item->path)) {
            if (contract != NULL) fclose(contract);
            ++failures;
            emit_coverage_result("fail", item->path, "", "contract unreadable");
            continue;
        }
        while ((length = getline(&line, &capacity, contract)) >= 0) {
            char *fields[AICI_FIELDS_MAX];
            char *content;
            int count;
            const char *code;
            if (length > AICI_LINE_MAX) {
                ++failures;
                emit_coverage_result("fail", item->path, "", "contract line too long");
                continue;
            }
            content = trim(line);
            if (*content == '\0' || *content == '#') continue;
            count = split_tabs(content, fields, AICI_FIELDS_MAX);
            if (count < 2) continue;
            code = fields[1];
            if (string_set_contains(seen_codes, code)) {
                ++failures;
                emit_coverage_result("fail", item->path, code,
                                     "diagnostic code is not unique");
                continue;
            }
            if (!string_set_add(&seen_codes, code)) {
                ++failures;
                emit_coverage_result("fail", item->path, code,
                                     "coverage allocation failed");
                continue;
            }
            if (!string_set_contains(item->negative_codes, code)) {
                ++failures;
                emit_coverage_result("fail", item->path, code,
                                     "missing targeted bad fixture");
            } else {
                emit_coverage_result("pass", item->path, code,
                                     "targeted bad fixture");
            }
        }
        free(line);
        fclose(contract);
        string_set_free(seen_codes);
    }
    return failures;
}

static int register_contract_files(const char *path, ContractCoverage **coverage,
                                   int *files_seen) {
    DIR *directory = opendir(path);
    struct dirent *entry;
    if (directory == NULL) return 0;
    while ((entry = readdir(directory)) != NULL) {
        char child[AICI_PATH_MAX];
        struct stat info;
        int written;
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0 ||
            strcmp(entry->d_name, ".git") == 0) {
            continue;
        }
        written = snprintf(child, sizeof(child), "%s/%s", path, entry->d_name);
        if (written < 0 || (size_t)written >= sizeof(child) || lstat(child, &info) != 0) {
            closedir(directory);
            return 0;
        }
        if (S_ISDIR(info.st_mode)) {
            if (!register_contract_files(child, coverage, files_seen)) {
                closedir(directory);
                return 0;
            }
        } else if (has_suffix(entry->d_name, ".contract.tsv")) {
            if (!S_ISREG(info.st_mode) || coverage_get(coverage, child) == NULL) {
                closedir(directory);
                return 0;
            }
            ++*files_seen;
        }
    }
    closedir(directory);
    return 1;
}

static int run_self_test(const char *cases_path) {
    FILE *cases = fopen(cases_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int total = 0;
    int failures = 0;
    int contract_files = 0;
    ContractCoverage *coverage = NULL;
    if (cases == NULL) {
        fprintf(stderr, "cannot read self-test cases: %s\n", cases_path);
        return 0;
    }
    if (!register_contract_files("contracts", &coverage, &contract_files) ||
        contract_files == 0) {
        ++failures;
    }
    while ((length = getline(&line, &capacity, cases)) >= 0) {
        char *fields[4];
        char *content;
        int count;
        int expected_pass;
        int actual_pass;
        int case_ok;
        ContractCoverage *coverage_item;
        VerifyResult result;
        if (length > AICI_LINE_MAX) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, 4);
        if (count != 4 ||
            (strcmp(fields[0], "pass") != 0 && strcmp(fields[0], "fail") != 0) ||
            (strcmp(fields[0], "pass") == 0 && strcmp(fields[3], "-") != 0) ||
            (strcmp(fields[0], "fail") == 0 &&
             (fields[3][0] == '\0' || strcmp(fields[3], "-") == 0))) {
            ++failures;
            continue;
        }
        ++total;
        expected_pass = strcmp(fields[0], "pass") == 0;
        if (strncmp(fields[1], "contracts/", 10) == 0) {
            coverage_item = coverage_get(&coverage, fields[1]);
            if (coverage_item == NULL) {
                ++failures;
            } else if (expected_pass) {
                coverage_item->has_positive = 1;
            } else if (!string_set_add(&coverage_item->negative_codes, fields[3])) {
                ++failures;
            }
        }
        actual_pass = verify_contract(fields[1], fields[2], 1, &result);
        case_ok = expected_pass ? actual_pass :
                  (!actual_pass && strcmp(result.first_code, fields[3]) == 0);
        if (!case_ok) ++failures;
        fputs("{\"kind\":\"self-test\",\"status\":", stdout);
        json_string(case_ok ? "pass" : "fail");
        fputs(",\"contract\":", stdout);
        json_string(fields[1]);
        fputs(",\"fixture\":", stdout);
        json_string(fields[2]);
        fputs(",\"expected\":", stdout);
        json_string(fields[0]);
        fputs(",\"observedCode\":", stdout);
        json_string(result.first_code);
        fputs("}\n", stdout);
    }
    free(line);
    fclose(cases);
    if (total == 0) ++failures;
    failures += audit_contract_coverage(coverage);
    coverage_free(coverage);
    printf("{\"kind\":\"self-test-summary\",\"status\":\"%s\",\"cases\":%d,\"failures\":%d}\n",
           failures == 0 ? "pass" : "fail", total, failures);
    return failures == 0;
}

static int run_suite(const char *suite_path, const char *base_root) {
    FILE *suite = fopen(suite_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int contracts = 0;
    int failures = 0;
    if (suite == NULL) {
        fprintf(stderr, "cannot read suite: %s\n", suite_path);
        return 0;
    }
    while ((length = getline(&line, &capacity, suite)) >= 0) {
        char *fields[2];
        char *content;
        int count;
        char root[AICI_PATH_MAX];
        VerifyResult result;
        if (length > AICI_LINE_MAX) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, 2);
        if (count != 2 || !join_path(root, sizeof(root), base_root, fields[1])) {
            ++failures;
            continue;
        }
        ++contracts;
        if (!verify_contract(fields[0], root, 0, &result)) ++failures;
    }
    free(line);
    fclose(suite);
    if (contracts == 0) ++failures;
    printf("{\"kind\":\"suite-summary\",\"status\":\"%s\",\"contracts\":%d,\"failures\":%d}\n",
           failures == 0 ? "pass" : "fail", contracts, failures);
    return failures == 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s verify CONTRACT ROOT\n"
            "  %s suite SUITE ROOT\n"
            "  %s self-test CASES\n",
            program, program, program);
}

int main(int argc, char **argv) {
    VerifyResult result;
    if (argc == 4 && strcmp(argv[1], "verify") == 0) {
        return verify_contract(argv[2], argv[3], 0, &result) ? 0 : 1;
    }
    if (argc == 4 && strcmp(argv[1], "suite") == 0) {
        return run_suite(argv[2], argv[3]) ? 0 : 1;
    }
    if (argc == 3 && strcmp(argv[1], "self-test") == 0) {
        return run_self_test(argv[2]) ? 0 : 1;
    }
    usage(argv[0]);
    return 2;
}
