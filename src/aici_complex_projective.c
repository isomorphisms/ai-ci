#define _XOPEN_SOURCE 700

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define PATH_MAXIMUM 4096
#define LINE_MAXIMUM (1024 * 1024)
#define FILE_MAXIMUM (32 * 1024 * 1024)
#define FIELD_MAXIMUM 32
#define ROW_MAXIMUM 256
#define REQUIREMENT_MAXIMUM 64
#define CODE_MAXIMUM 128
#define NAME_MAXIMUM 160
#define VALUE_MAXIMUM 512

static const char *contract_schema = "complex-projective-backend-contract-v1";
static const char *corpus_schema_marker =
    "\"schema\": \"edric-complex-projective-corpus-v1\"";

typedef struct {
    int assertions;
    int failures;
    int quiet;
    char first_code[CODE_MAXIMUM];
} VerifyResult;

typedef struct {
    char code[CODE_MAXIMUM];
    char category[32];
    char stage[NAME_MAXIMUM];
    char environment[NAME_MAXIMUM];
    char expected_status[16];
} Requirement;

typedef struct {
    char identity_code[CODE_MAXIMUM];
    char corpus_code[CODE_MAXIMUM];
    char provenance_code[CODE_MAXIMUM];
    char gpu_code[CODE_MAXIMUM];
    char target[NAME_MAXIMUM];
    char family[32];
    char role[16];
    char corpus_repository[VALUE_MAXIMUM];
    char corpus_ref[VALUE_MAXIMUM];
    char corpus_revision[65];
    char corpus_path[PATH_MAXIMUM];
    char corpus_sha256[65];
    char compiler_repository[VALUE_MAXIMUM];
    char compiler_ref[VALUE_MAXIMUM];
    char compiler_revision[65];
    char backend_repository[VALUE_MAXIMUM];
    char backend_ref[VALUE_MAXIMUM];
    char backend_revision[65];
    char application_repository[VALUE_MAXIMUM];
    char application_ref[VALUE_MAXIMUM];
    char application_revision[65];
    char gpu_ceiling[NAME_MAXIMUM];
    int schema_seen;
    int identity_seen;
    int corpus_seen;
    int provenance_seen;
    int gpu_seen;
    int requirement_count;
    Requirement requirements[REQUIREMENT_MAXIMUM];
} Contract;

typedef struct {
    char target[NAME_MAXIMUM];
    char family[32];
    char role[16];
    char category[32];
    char stage[NAME_MAXIMUM];
    char status[16];
    char corpus_repository[VALUE_MAXIMUM];
    char corpus_ref[VALUE_MAXIMUM];
    char corpus_revision[65];
    char corpus_path[PATH_MAXIMUM];
    char corpus_sha256[65];
    char compiler_repository[VALUE_MAXIMUM];
    char compiler_ref[VALUE_MAXIMUM];
    char compiler_revision[65];
    char backend_repository[VALUE_MAXIMUM];
    char backend_ref[VALUE_MAXIMUM];
    char backend_revision[65];
    char application_repository[VALUE_MAXIMUM];
    char application_ref[VALUE_MAXIMUM];
    char application_revision[65];
    char environment[NAME_MAXIMUM];
    char witness[PATH_MAXIMUM];
    char sha256[65];
    int consumed;
} ReceiptRow;

typedef struct {
    int count;
    ReceiptRow rows[ROW_MAXIMUM];
} Receipt;

typedef struct CodeNode {
    char code[CODE_MAXIMUM];
    struct CodeNode *next;
} CodeNode;

static const char *gpu_stages[] = {
    "shader-generated",
    "shader-inspected",
    "shader-compiled",
    "shader-linked",
    "shader-loaded",
    "shader-executed",
    "render-captured",
    "vendor-device-receipt",
};

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

static int copy_value(char *destination, size_t size, const char *source) {
    int written = snprintf(destination, size, "%s", source);
    return written >= 0 && (size_t)written < size;
}

static int valid_code(const char *code) {
    const unsigned char *cursor = (const unsigned char *)code;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(isupper(*cursor) || isdigit(*cursor) || *cursor == '-')) return 0;
        ++cursor;
    }
    return 1;
}

static int valid_name(const char *name) {
    const unsigned char *cursor = (const unsigned char *)name;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(islower(*cursor) || isdigit(*cursor) || *cursor == '-' ||
              *cursor == '_' || *cursor == '.')) {
            return 0;
        }
        ++cursor;
    }
    return 1;
}

static int valid_repository(const char *repository) {
    const unsigned char *cursor = (const unsigned char *)repository;
    int slash_count = 0;
    int component_start = 1;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (*cursor == '/') {
            if (component_start || slash_count != 0) return 0;
            component_start = 1;
            ++slash_count;
        } else {
            if (!(isalnum(*cursor) || *cursor == '-' || *cursor == '_' ||
                  *cursor == '.')) {
                return 0;
            }
            component_start = 0;
        }
        ++cursor;
    }
    return slash_count == 1 && !component_start;
}

static int lower_hex(const char *text, size_t length) {
    size_t index;
    if (strlen(text) != length) return 0;
    for (index = 0; index < length; ++index) {
        if (!(isdigit((unsigned char)text[index]) ||
              (text[index] >= 'a' && text[index] <= 'f'))) {
            return 0;
        }
    }
    return 1;
}

static int full_revision(const char *revision) {
    return lower_hex(revision, 40) || lower_hex(revision, 64);
}

static int safe_relative_path(const char *path) {
    const char *component;
    const char *slash;
    if (path == NULL || *path == '\0' || *path == '/') return 0;
    component = path;
    while (1) {
        size_t length;
        slash = strchr(component, '/');
        length = slash == NULL ? strlen(component) : (size_t)(slash - component);
        if (length == 0 || (length == 1 && component[0] == '.') ||
            (length == 2 && component[0] == '.' && component[1] == '.')) {
            return 0;
        }
        if (slash == NULL) break;
        component = slash + 1;
    }
    return 1;
}

static int join_path(char *output, size_t size, const char *root,
                     const char *relative) {
    int written;
    if (root == NULL || *root == '\0' || !safe_relative_path(relative)) return 0;
    written = snprintf(output, size, "%s/%s", root, relative);
    return written >= 0 && (size_t)written < size;
}

static int regular_nonempty_file(const char *path) {
    struct stat information;
    return lstat(path, &information) == 0 && S_ISREG(information.st_mode) &&
           information.st_size > 0;
}

static int path_is_below_root(const char *path, const char *root) {
    char canonical_path[PATH_MAXIMUM];
    char canonical_root[PATH_MAXIMUM];
    size_t root_length;
    if (realpath(path, canonical_path) == NULL ||
        realpath(root, canonical_root) == NULL) {
        return 0;
    }
    root_length = strlen(canonical_root);
    if (strncmp(canonical_path, canonical_root, root_length) != 0) return 0;
    if (root_length == 1 && canonical_root[0] == '/') return 1;
    return canonical_path[root_length] == '/';
}

static int wait_success(pid_t child) {
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) return 0;
    }
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

static int capture_command(char *const argv[], unsigned char **output,
                           size_t *output_length) {
    int descriptors[2];
    pid_t child;
    unsigned char *buffer = NULL;
    size_t length = 0;
    size_t capacity = 0;
    int failed = 0;
    if (pipe(descriptors) != 0) return 0;
    child = fork();
    if (child < 0) {
        close(descriptors[0]);
        close(descriptors[1]);
        return 0;
    }
    if (child == 0) {
        FILE *null_file;
        close(descriptors[0]);
        null_file = fopen("/dev/null", "w");
        if (null_file == NULL || dup2(descriptors[1], STDOUT_FILENO) < 0 ||
            dup2(fileno(null_file), STDERR_FILENO) < 0) {
            _exit(126);
        }
        close(descriptors[1]);
        fclose(null_file);
        execvp(argv[0], argv);
        _exit(127);
    }
    close(descriptors[1]);
    while (!failed) {
        unsigned char chunk[4096];
        ssize_t count = read(descriptors[0], chunk, sizeof(chunk));
        if (count == 0) break;
        if (count < 0) {
            if (errno == EINTR) continue;
            failed = 1;
            break;
        }
        if (length + (size_t)count > 4096) {
            failed = 1;
            break;
        }
        if (length + (size_t)count + 1 > capacity) {
            size_t next = capacity == 0 ? 512 : capacity * 2;
            unsigned char *grown;
            while (next < length + (size_t)count + 1) next *= 2;
            grown = realloc(buffer, next);
            if (grown == NULL) {
                failed = 1;
                break;
            }
            buffer = grown;
            capacity = next;
        }
        memcpy(buffer + length, chunk, (size_t)count);
        length += (size_t)count;
    }
    close(descriptors[0]);
    if (!wait_success(child)) failed = 1;
    if (failed) {
        free(buffer);
        return 0;
    }
    if (buffer == NULL) {
        buffer = malloc(1);
        if (buffer == NULL) return 0;
    }
    buffer[length] = '\0';
    *output = buffer;
    *output_length = length;
    return 1;
}

static int sha256_file(const char *path, char digest[65]) {
    char *arguments[] = {"sha256sum", "--", (char *)path, NULL};
    unsigned char *output = NULL;
    size_t length = 0;
    int ok;
    if (!capture_command(arguments, &output, &length)) return 0;
    ok = length >= 65;
    if (ok) {
        memcpy(digest, output, 64);
        digest[64] = '\0';
        ok = lower_hex(digest, 64) && isspace(output[64]);
    }
    free(output);
    return ok;
}

static int file_contains(const char *path, const char *needle) {
    FILE *file;
    long length;
    char *content;
    int found;
    file = fopen(path, "rb");
    if (file == NULL || !regular_nonempty_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    if (fseek(file, 0, SEEK_END) != 0 || (length = ftell(file)) < 0 ||
        length > FILE_MAXIMUM || fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return 0;
    }
    content = malloc((size_t)length + 1);
    if (content == NULL) {
        fclose(file);
        return 0;
    }
    if (fread(content, 1, (size_t)length, file) != (size_t)length ||
        fclose(file) != 0) {
        free(content);
        return 0;
    }
    content[length] = '\0';
    found = strstr(content, needle) != NULL;
    free(content);
    return found;
}

static void json_string(const char *text) {
    const unsigned char *cursor = (const unsigned char *)text;
    putchar('"');
    while (*cursor != '\0') {
        switch (*cursor) {
            case '"': fputs("\\\"", stdout); break;
            case '\\': fputs("\\\\", stdout); break;
            case '\n': fputs("\\n", stdout); break;
            case '\r': fputs("\\r", stdout); break;
            case '\t': fputs("\\t", stdout); break;
            default:
                if (*cursor < 0x20) printf("\\u%04x", (unsigned int)*cursor);
                else putchar((int)*cursor);
        }
        ++cursor;
    }
    putchar('"');
}

static void record_result(VerifyResult *result, int ok, const char *code,
                          const char *operation, const char *detail) {
    ++result->assertions;
    if (!ok) {
        ++result->failures;
        if (result->first_code[0] == '\0') {
            copy_value(result->first_code, sizeof(result->first_code), code);
        }
    }
    if (!result->quiet) {
        fputs("{\"kind\":\"complex-projective-assertion\",\"status\":", stdout);
        json_string(ok ? "pass" : "fail");
        fputs(",\"code\":", stdout);
        json_string(code);
        fputs(",\"operation\":", stdout);
        json_string(operation);
        fputs(",\"detail\":", stdout);
        json_string(detail);
        fputs("}\n", stdout);
    }
}

static int category_valid(const char *category) {
    return strcmp(category, "exact") == 0 ||
           strcmp(category, "numeric") == 0 ||
           strcmp(category, "projective") == 0 ||
           strcmp(category, "render") == 0 ||
           strcmp(category, "pipeline") == 0;
}

static int expected_status_valid(const char *status) {
    return strcmp(status, "pass") == 0 || strcmp(status, "skip") == 0 ||
           strcmp(status, "blocked") == 0;
}

static int receipt_status_valid(const char *status) {
    return expected_status_valid(status) || strcmp(status, "fail") == 0;
}

static int gpu_stage_index(const char *stage) {
    size_t index;
    for (index = 0; index < sizeof(gpu_stages) / sizeof(gpu_stages[0]); ++index) {
        if (strcmp(stage, gpu_stages[index]) == 0) return (int)index;
    }
    return -1;
}

static int code_in_contract(const Contract *contract, const char *code) {
    int index;
    if ((contract->identity_seen && strcmp(contract->identity_code, code) == 0) ||
        (contract->corpus_seen && strcmp(contract->corpus_code, code) == 0) ||
        (contract->provenance_seen && strcmp(contract->provenance_code, code) == 0) ||
        (contract->gpu_seen && strcmp(contract->gpu_code, code) == 0)) {
        return 1;
    }
    for (index = 0; index < contract->requirement_count; ++index) {
        if (strcmp(contract->requirements[index].code, code) == 0) return 1;
    }
    return 0;
}

static int fixed_code(const char *code) {
    return strcmp(code, "AICI-CP-CONTRACT") == 0 ||
           strcmp(code, "CP-RECEIPT") == 0 ||
           strcmp(code, "CP-CORPUS-BINDING") == 0 ||
           strcmp(code, "CP-RECEIPT-EXTRA") == 0;
}

static int add_contract_code(Contract *contract, const char *code) {
    return valid_code(code) && !fixed_code(code) && !code_in_contract(contract, code);
}

static int same_application_shape(const Contract *contract) {
    int repository_absent = strcmp(contract->application_repository, "-") == 0;
    int ref_absent = strcmp(contract->application_ref, "-") == 0;
    int revision_absent = strcmp(contract->application_revision, "-") == 0;
    if (repository_absent || ref_absent || revision_absent) {
        return repository_absent && ref_absent && revision_absent;
    }
    return valid_repository(contract->application_repository) &&
           contract->application_ref[0] != '\0' &&
           full_revision(contract->application_revision);
}

static int requirement_exists(const Contract *contract, const char *category,
                              const char *stage, const char *status) {
    int index;
    for (index = 0; index < contract->requirement_count; ++index) {
        const Requirement *requirement = &contract->requirements[index];
        if ((category == NULL || strcmp(requirement->category, category) == 0) &&
            (stage == NULL || strcmp(requirement->stage, stage) == 0) &&
            (status == NULL || strcmp(requirement->expected_status, status) == 0)) {
            return 1;
        }
    }
    return 0;
}

static int requirement_key_unique(const Contract *contract,
                                  const Requirement *candidate) {
    int index;
    for (index = 0; index < contract->requirement_count; ++index) {
        const Requirement *existing = &contract->requirements[index];
        if (strcmp(existing->category, candidate->category) == 0 &&
            strcmp(existing->stage, candidate->stage) == 0 &&
            strcmp(existing->environment, candidate->environment) == 0) {
            return 0;
        }
    }
    return 1;
}

static int contract_complete(const Contract *contract) {
    int category;
    const char *required_categories[] = {"exact", "numeric", "projective", "render"};
    if (!contract->schema_seen || !contract->identity_seen ||
        !contract->corpus_seen || !contract->provenance_seen ||
        contract->requirement_count == 0) {
        return 0;
    }
    if (strcmp(contract->corpus_repository, contract->compiler_repository) != 0 ||
        strcmp(contract->corpus_ref, contract->compiler_ref) != 0 ||
        strcmp(contract->corpus_revision, contract->compiler_revision) != 0) {
        return 0;
    }
    if (!same_application_shape(contract)) return 0;
    if (strcmp(contract->family, "x86-64-cpu") == 0) {
        if (strcmp(contract->role, "leader") != 0 || contract->gpu_seen ||
            strcmp(contract->application_repository, "-") == 0) {
            return 0;
        }
        if (!requirement_exists(contract, "exact", "exact-corpus", "pass") ||
            !requirement_exists(contract, "numeric", "numerical-corpus", "pass") ||
            !requirement_exists(contract, "projective",
                                "projective-equivalence-corpus", "pass") ||
            !requirement_exists(contract, "render", "headless-render", "pass") ||
            !requirement_exists(contract, "pipeline", "direct-build", "pass") ||
            !requirement_exists(contract, "pipeline", "native-execution", "pass") ||
            !requirement_exists(contract, "pipeline", "thin-debian-execution", "pass") ||
            !requirement_exists(contract, "pipeline",
                                "github-actions-execution", "pass")) {
            return 0;
        }
    } else if (strcmp(contract->family, "arm-thumb2") == 0) {
        if (strcmp(contract->role, "follower") != 0 || contract->gpu_seen) return 0;
    } else if (strcmp(contract->family, "gpu") == 0) {
        if (strcmp(contract->role, "follower") != 0 || !contract->gpu_seen ||
            gpu_stage_index(contract->gpu_ceiling) < 0) {
            return 0;
        }
    } else {
        return 0;
    }
    for (category = 0; category < 4; ++category) {
        if (!requirement_exists(contract, required_categories[category], NULL, NULL))
            return 0;
    }
    return 1;
}

static int parse_contract(const char *path, Contract *contract) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int ok = 1;
    memset(contract, 0, sizeof(*contract));
    if (file == NULL || !regular_nonempty_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    while (ok && (length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        char *content;
        int count;
        if (length > LINE_MAXIMUM) {
            ok = 0;
            break;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, FIELD_MAXIMUM);
        if (count < 0) {
            ok = 0;
        } else if (strcmp(fields[0], "schema") == 0 && count == 2 &&
                   !contract->schema_seen && strcmp(fields[1], contract_schema) == 0) {
            contract->schema_seen = 1;
        } else if (strcmp(fields[0], "identity") == 0 && count == 5 &&
                   !contract->identity_seen && add_contract_code(contract, fields[1]) &&
                   valid_name(fields[2]) && valid_name(fields[3]) &&
                   (strcmp(fields[4], "leader") == 0 ||
                    strcmp(fields[4], "follower") == 0)) {
            ok = copy_value(contract->identity_code, sizeof(contract->identity_code), fields[1]) &&
                 copy_value(contract->target, sizeof(contract->target), fields[2]) &&
                 copy_value(contract->family, sizeof(contract->family), fields[3]) &&
                 copy_value(contract->role, sizeof(contract->role), fields[4]);
            contract->identity_seen = ok;
        } else if (strcmp(fields[0], "corpus") == 0 && count == 7 &&
                   !contract->corpus_seen && add_contract_code(contract, fields[1]) &&
                   valid_repository(fields[2]) && fields[3][0] != '\0' &&
                   full_revision(fields[4]) && safe_relative_path(fields[5]) &&
                   lower_hex(fields[6], 64)) {
            ok = copy_value(contract->corpus_code, sizeof(contract->corpus_code), fields[1]) &&
                 copy_value(contract->corpus_repository,
                            sizeof(contract->corpus_repository), fields[2]) &&
                 copy_value(contract->corpus_ref, sizeof(contract->corpus_ref), fields[3]) &&
                 copy_value(contract->corpus_revision,
                            sizeof(contract->corpus_revision), fields[4]) &&
                 copy_value(contract->corpus_path, sizeof(contract->corpus_path), fields[5]) &&
                 copy_value(contract->corpus_sha256,
                            sizeof(contract->corpus_sha256), fields[6]);
            contract->corpus_seen = ok;
        } else if (strcmp(fields[0], "provenance") == 0 && count == 11 &&
                   !contract->provenance_seen && add_contract_code(contract, fields[1]) &&
                   valid_repository(fields[2]) && fields[3][0] != '\0' &&
                   full_revision(fields[4]) && valid_repository(fields[5]) &&
                   fields[6][0] != '\0' && full_revision(fields[7])) {
            ok = copy_value(contract->provenance_code,
                            sizeof(contract->provenance_code), fields[1]) &&
                 copy_value(contract->compiler_repository,
                            sizeof(contract->compiler_repository), fields[2]) &&
                 copy_value(contract->compiler_ref, sizeof(contract->compiler_ref), fields[3]) &&
                 copy_value(contract->compiler_revision,
                            sizeof(contract->compiler_revision), fields[4]) &&
                 copy_value(contract->backend_repository,
                            sizeof(contract->backend_repository), fields[5]) &&
                 copy_value(contract->backend_ref, sizeof(contract->backend_ref), fields[6]) &&
                 copy_value(contract->backend_revision,
                            sizeof(contract->backend_revision), fields[7]) &&
                 copy_value(contract->application_repository,
                            sizeof(contract->application_repository), fields[8]) &&
                 copy_value(contract->application_ref,
                            sizeof(contract->application_ref), fields[9]) &&
                 copy_value(contract->application_revision,
                            sizeof(contract->application_revision), fields[10]);
            contract->provenance_seen = ok;
        } else if (strcmp(fields[0], "require") == 0 && count == 6 &&
                   contract->requirement_count < REQUIREMENT_MAXIMUM &&
                   add_contract_code(contract, fields[1]) && category_valid(fields[2]) &&
                   valid_name(fields[3]) && gpu_stage_index(fields[3]) < 0 &&
                   valid_name(fields[4]) && expected_status_valid(fields[5])) {
            Requirement candidate;
            memset(&candidate, 0, sizeof(candidate));
            ok = copy_value(candidate.code, sizeof(candidate.code), fields[1]) &&
                 copy_value(candidate.category, sizeof(candidate.category), fields[2]) &&
                 copy_value(candidate.stage, sizeof(candidate.stage), fields[3]) &&
                 copy_value(candidate.environment, sizeof(candidate.environment), fields[4]) &&
                 copy_value(candidate.expected_status,
                            sizeof(candidate.expected_status), fields[5]);
            if (ok && requirement_key_unique(contract, &candidate)) {
                contract->requirements[contract->requirement_count++] = candidate;
            } else {
                ok = 0;
            }
        } else if (strcmp(fields[0], "gpu_ceiling") == 0 && count == 3 &&
                   !contract->gpu_seen && add_contract_code(contract, fields[1]) &&
                   gpu_stage_index(fields[2]) >= 0) {
            ok = copy_value(contract->gpu_code, sizeof(contract->gpu_code), fields[1]) &&
                 copy_value(contract->gpu_ceiling, sizeof(contract->gpu_ceiling), fields[2]);
            contract->gpu_seen = ok;
        } else {
            ok = 0;
        }
    }
    if (ferror(file)) ok = 0;
    free(line);
    if (fclose(file) != 0) ok = 0;
    return ok && contract_complete(contract);
}

static int exact_receipt_header(char *line) {
    static const char *fields[] = {
        "target", "family", "role", "category", "stage", "status",
        "corpus_repository", "corpus_ref", "corpus_revision", "corpus_path",
        "corpus_sha256", "compiler_repository", "compiler_ref",
        "compiler_revision", "backend_repository", "backend_ref",
        "backend_revision", "application_repository", "application_ref",
        "application_revision", "environment", "witness", "sha256"
    };
    char *actual[FIELD_MAXIMUM];
    int count = split_tabs(line, actual, FIELD_MAXIMUM);
    size_t index;
    if (count != (int)(sizeof(fields) / sizeof(fields[0]))) return 0;
    for (index = 0; index < sizeof(fields) / sizeof(fields[0]); ++index) {
        if (strcmp(actual[index], fields[index]) != 0) return 0;
    }
    return 1;
}

static int receipt_row_copy(ReceiptRow *row, char **fields) {
    return copy_value(row->target, sizeof(row->target), fields[0]) &&
           copy_value(row->family, sizeof(row->family), fields[1]) &&
           copy_value(row->role, sizeof(row->role), fields[2]) &&
           copy_value(row->category, sizeof(row->category), fields[3]) &&
           copy_value(row->stage, sizeof(row->stage), fields[4]) &&
           copy_value(row->status, sizeof(row->status), fields[5]) &&
           copy_value(row->corpus_repository, sizeof(row->corpus_repository), fields[6]) &&
           copy_value(row->corpus_ref, sizeof(row->corpus_ref), fields[7]) &&
           copy_value(row->corpus_revision, sizeof(row->corpus_revision), fields[8]) &&
           copy_value(row->corpus_path, sizeof(row->corpus_path), fields[9]) &&
           copy_value(row->corpus_sha256, sizeof(row->corpus_sha256), fields[10]) &&
           copy_value(row->compiler_repository, sizeof(row->compiler_repository), fields[11]) &&
           copy_value(row->compiler_ref, sizeof(row->compiler_ref), fields[12]) &&
           copy_value(row->compiler_revision, sizeof(row->compiler_revision), fields[13]) &&
           copy_value(row->backend_repository, sizeof(row->backend_repository), fields[14]) &&
           copy_value(row->backend_ref, sizeof(row->backend_ref), fields[15]) &&
           copy_value(row->backend_revision, sizeof(row->backend_revision), fields[16]) &&
           copy_value(row->application_repository,
                      sizeof(row->application_repository), fields[17]) &&
           copy_value(row->application_ref, sizeof(row->application_ref), fields[18]) &&
           copy_value(row->application_revision,
                      sizeof(row->application_revision), fields[19]) &&
           copy_value(row->environment, sizeof(row->environment), fields[20]) &&
           copy_value(row->witness, sizeof(row->witness), fields[21]) &&
           copy_value(row->sha256, sizeof(row->sha256), fields[22]);
}

static int duplicate_receipt_key(const Receipt *receipt, const ReceiptRow *candidate) {
    int index;
    for (index = 0; index < receipt->count; ++index) {
        const ReceiptRow *row = &receipt->rows[index];
        if (strcmp(row->category, candidate->category) == 0 &&
            strcmp(row->stage, candidate->stage) == 0 &&
            strcmp(row->environment, candidate->environment) == 0) {
            return 1;
        }
    }
    return 0;
}

static int read_receipt(const char *path, Receipt *receipt) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int header_seen = 0;
    int ok = 1;
    memset(receipt, 0, sizeof(*receipt));
    if (file == NULL || !regular_nonempty_file(path)) {
        if (file != NULL) fclose(file);
        return 0;
    }
    while (ok && (length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        char *content;
        int count;
        ReceiptRow candidate;
        if (length > LINE_MAXIMUM) {
            ok = 0;
            break;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        if (!header_seen) {
            header_seen = exact_receipt_header(content);
            if (!header_seen) ok = 0;
            continue;
        }
        count = split_tabs(content, fields, FIELD_MAXIMUM);
        memset(&candidate, 0, sizeof(candidate));
        if (count != 23 || receipt->count >= ROW_MAXIMUM ||
            !receipt_row_copy(&candidate, fields) ||
            !valid_name(candidate.target) || !valid_name(candidate.family) ||
            (strcmp(candidate.role, "leader") != 0 &&
             strcmp(candidate.role, "follower") != 0) ||
            !category_valid(candidate.category) || !valid_name(candidate.stage) ||
            !receipt_status_valid(candidate.status) ||
            !valid_repository(candidate.corpus_repository) ||
            candidate.corpus_ref[0] == '\0' || !full_revision(candidate.corpus_revision) ||
            !safe_relative_path(candidate.corpus_path) ||
            !lower_hex(candidate.corpus_sha256, 64) ||
            !valid_repository(candidate.compiler_repository) ||
            candidate.compiler_ref[0] == '\0' ||
            !full_revision(candidate.compiler_revision) ||
            !valid_repository(candidate.backend_repository) ||
            candidate.backend_ref[0] == '\0' ||
            !full_revision(candidate.backend_revision) ||
            !valid_name(candidate.environment) ||
            !safe_relative_path(candidate.witness) || !lower_hex(candidate.sha256, 64) ||
            duplicate_receipt_key(receipt, &candidate)) {
            ok = 0;
            break;
        }
        if ((strcmp(candidate.application_repository, "-") == 0 ||
             strcmp(candidate.application_ref, "-") == 0 ||
             strcmp(candidate.application_revision, "-") == 0)) {
            if (!(strcmp(candidate.application_repository, "-") == 0 &&
                  strcmp(candidate.application_ref, "-") == 0 &&
                  strcmp(candidate.application_revision, "-") == 0)) {
                ok = 0;
                break;
            }
        } else if (!valid_repository(candidate.application_repository) ||
                   candidate.application_ref[0] == '\0' ||
                   !full_revision(candidate.application_revision)) {
            ok = 0;
            break;
        }
        receipt->rows[receipt->count++] = candidate;
    }
    if (ferror(file)) ok = 0;
    free(line);
    if (fclose(file) != 0) ok = 0;
    return ok && header_seen && receipt->count > 0;
}

static int row_identity_matches(const ReceiptRow *row, const Contract *contract) {
    return strcmp(row->target, contract->target) == 0 &&
           strcmp(row->family, contract->family) == 0 &&
           strcmp(row->role, contract->role) == 0;
}

static int row_corpus_matches(const ReceiptRow *row, const Contract *contract) {
    return strcmp(row->corpus_repository, contract->corpus_repository) == 0 &&
           strcmp(row->corpus_ref, contract->corpus_ref) == 0 &&
           strcmp(row->corpus_revision, contract->corpus_revision) == 0 &&
           strcmp(row->corpus_path, contract->corpus_path) == 0 &&
           strcmp(row->corpus_sha256, contract->corpus_sha256) == 0;
}

static int row_provenance_matches(const ReceiptRow *row, const Contract *contract) {
    return strcmp(row->compiler_repository, contract->compiler_repository) == 0 &&
           strcmp(row->compiler_ref, contract->compiler_ref) == 0 &&
           strcmp(row->compiler_revision, contract->compiler_revision) == 0 &&
           strcmp(row->backend_repository, contract->backend_repository) == 0 &&
           strcmp(row->backend_ref, contract->backend_ref) == 0 &&
           strcmp(row->backend_revision, contract->backend_revision) == 0 &&
           strcmp(row->application_repository, contract->application_repository) == 0 &&
           strcmp(row->application_ref, contract->application_ref) == 0 &&
           strcmp(row->application_revision, contract->application_revision) == 0;
}

static int witness_matches(const ReceiptRow *row, const char *root) {
    char path[PATH_MAXIMUM];
    char observed[65];
    return join_path(path, sizeof(path), root, row->witness) &&
           regular_nonempty_file(path) && path_is_below_root(path, root) &&
           sha256_file(path, observed) &&
           strcmp(observed, row->sha256) == 0;
}

static ReceiptRow *find_requirement_row(Receipt *receipt,
                                        const Requirement *requirement) {
    int index;
    for (index = 0; index < receipt->count; ++index) {
        ReceiptRow *row = &receipt->rows[index];
        if (strcmp(row->category, requirement->category) == 0 &&
            strcmp(row->stage, requirement->stage) == 0 &&
            strcmp(row->environment, requirement->environment) == 0) {
            return row;
        }
    }
    return NULL;
}

static int verify_gpu_stages(Receipt *receipt, const Contract *contract,
                             const char *root) {
    size_t stage;
    int ceiling = gpu_stage_index(contract->gpu_ceiling);
    int ok = ceiling >= 0;
    for (stage = 0; stage < sizeof(gpu_stages) / sizeof(gpu_stages[0]); ++stage) {
        int index;
        int matches = 0;
        ReceiptRow *found = NULL;
        for (index = 0; index < receipt->count; ++index) {
            ReceiptRow *row = &receipt->rows[index];
            if (strcmp(row->stage, gpu_stages[stage]) == 0) {
                ++matches;
                found = row;
            }
        }
        if (matches != 1 || found == NULL || strcmp(found->category, "pipeline") != 0 ||
            !witness_matches(found, root)) {
            ok = 0;
            continue;
        }
        if ((int)stage <= ceiling) {
            if (strcmp(found->status, "pass") != 0) ok = 0;
        } else if (strcmp(found->status, "skip") != 0 &&
                   strcmp(found->status, "blocked") != 0) {
            ok = 0;
        }
        found->consumed = 1;
    }
    return ok;
}

static void emit_summary(const VerifyResult *result) {
    if (!result->quiet) {
        printf("{\"kind\":\"complex-projective-summary\",\"status\":\"%s\","
               "\"assertions\":%d,\"failures\":%d}\n",
               result->failures == 0 ? "pass" : "fail",
               result->assertions, result->failures);
    }
}

static int verify_files(const char *contract_path, const char *receipt_path,
                        const char *corpus_path, const char *root,
                        VerifyResult *result) {
    Contract contract;
    Receipt receipt;
    char observed_corpus_sha256[65];
    int corpus_ok;
    int index;
    int identity_ok = 1;
    int provenance_ok = 1;
    int receipt_corpus_ok = 1;
    if (!parse_contract(contract_path, &contract)) {
        record_result(result, 0, "AICI-CP-CONTRACT", "contract",
                      "contract is unreadable, incomplete, or inconsistent");
        emit_summary(result);
        return 0;
    }
    corpus_ok = regular_nonempty_file(corpus_path) &&
                file_contains(corpus_path, corpus_schema_marker) &&
                sha256_file(corpus_path, observed_corpus_sha256) &&
                strcmp(observed_corpus_sha256, contract.corpus_sha256) == 0;
    record_result(result, corpus_ok, contract.corpus_code, "corpus",
                  "canonical schema and bytes match the pinned compiler corpus");
    if (!corpus_ok) {
        emit_summary(result);
        return 0;
    }
    if (!read_receipt(receipt_path, &receipt)) {
        record_result(result, 0, "CP-RECEIPT", "receipt",
                      "receipt is unreadable, malformed, duplicated, or open-ended");
        emit_summary(result);
        return 0;
    }
    record_result(result, 1, "CP-RECEIPT", "receipt", "receipt structure is exact");
    for (index = 0; index < receipt.count; ++index) {
        if (!row_identity_matches(&receipt.rows[index], &contract)) identity_ok = 0;
        if (!row_corpus_matches(&receipt.rows[index], &contract)) receipt_corpus_ok = 0;
        if (!row_provenance_matches(&receipt.rows[index], &contract)) provenance_ok = 0;
    }
    record_result(result, identity_ok, contract.identity_code, "identity",
                  "every row names the contracted target family and leader/follower role");
    record_result(result, receipt_corpus_ok, "CP-CORPUS-BINDING", "corpus-binding",
                  "every row names the same corpus repository, ref, revision, path, and bytes");
    record_result(result, provenance_ok, contract.provenance_code, "provenance",
                  "every row names the contracted compiler, backend, and application revisions");
    for (index = 0; index < contract.requirement_count; ++index) {
        Requirement *requirement = &contract.requirements[index];
        ReceiptRow *row = find_requirement_row(&receipt, requirement);
        char detail[NAME_MAXIMUM * 2];
        int ok = row != NULL &&
                 strcmp(row->status, requirement->expected_status) == 0 &&
                 strcmp(row->status, "fail") != 0 && witness_matches(row, root);
        snprintf(detail, sizeof(detail), "%s expected=%s observed=%s",
                 requirement->stage, requirement->expected_status,
                 row == NULL ? "missing" : row->status);
        if (row != NULL) row->consumed = 1;
        record_result(result, ok, requirement->code, requirement->category,
                      detail);
    }
    if (strcmp(contract.family, "gpu") == 0) {
        record_result(result, verify_gpu_stages(&receipt, &contract, root),
                      contract.gpu_code, "gpu-stage-ceiling", contract.gpu_ceiling);
    }
    {
        int extras = 0;
        for (index = 0; index < receipt.count; ++index) {
            if (!receipt.rows[index].consumed) ++extras;
        }
        record_result(result, extras == 0, "CP-RECEIPT-EXTRA", "receipt-closure",
                      extras == 0 ? "no undeclared evidence rows" :
                                    "receipt contains undeclared evidence rows");
    }
    emit_summary(result);
    return result->failures == 0;
}

static int code_list_contains(const CodeNode *list, const char *code) {
    while (list != NULL) {
        if (strcmp(list->code, code) == 0) return 1;
        list = list->next;
    }
    return 0;
}

static int code_list_add(CodeNode **list, const char *code) {
    CodeNode *node;
    if (code_list_contains(*list, code)) return 1;
    node = calloc(1, sizeof(*node));
    if (node == NULL || !copy_value(node->code, sizeof(node->code), code)) {
        free(node);
        return 0;
    }
    node->next = *list;
    *list = node;
    return 1;
}

static void code_list_free(CodeNode *list) {
    while (list != NULL) {
        CodeNode *next = list->next;
        free(list);
        list = next;
    }
}

static int add_contract_codes(CodeNode **codes, const Contract *contract) {
    int index;
    if (!code_list_add(codes, contract->identity_code) ||
        !code_list_add(codes, contract->corpus_code) ||
        !code_list_add(codes, contract->provenance_code)) {
        return 0;
    }
    if (contract->gpu_seen && !code_list_add(codes, contract->gpu_code)) return 0;
    for (index = 0; index < contract->requirement_count; ++index) {
        if (!code_list_add(codes, contract->requirements[index].code)) return 0;
    }
    return 1;
}

static int run_self_test(const char *cases_path) {
    FILE *file = fopen(cases_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int cases = 0;
    int failures = 0;
    int positive_cases = 0;
    CodeNode *required_codes = NULL;
    CodeNode *negative_codes = NULL;
    if (file == NULL) return 0;
    if (!code_list_add(&required_codes, "AICI-CP-CONTRACT") ||
        !code_list_add(&required_codes, "CP-RECEIPT") ||
        !code_list_add(&required_codes, "CP-CORPUS-BINDING") ||
        !code_list_add(&required_codes, "CP-RECEIPT-EXTRA")) {
        fclose(file);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[FIELD_MAXIMUM];
        char *content;
        int count;
        int expected_pass;
        int actual_pass;
        int case_ok;
        Contract contract;
        VerifyResult result;
        if (length > LINE_MAXIMUM) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, FIELD_MAXIMUM);
        if (count != 6 ||
            (strcmp(fields[0], "pass") != 0 && strcmp(fields[0], "fail") != 0)) {
            ++failures;
            continue;
        }
        expected_pass = strcmp(fields[0], "pass") == 0;
        if ((expected_pass && strcmp(fields[5], "-") != 0) ||
            (!expected_pass && !valid_code(fields[5]))) {
            ++failures;
            continue;
        }
        if (parse_contract(fields[1], &contract)) {
            if (!add_contract_codes(&required_codes, &contract)) {
                ++failures;
                continue;
            }
        } else if (expected_pass || strcmp(fields[5], "AICI-CP-CONTRACT") != 0) {
            ++failures;
            continue;
        }
        memset(&result, 0, sizeof(result));
        result.quiet = 1;
        actual_pass = verify_files(fields[1], fields[2], fields[3], fields[4], &result);
        case_ok = expected_pass ? actual_pass :
                  (!actual_pass && strcmp(result.first_code, fields[5]) == 0);
        if (expected_pass) ++positive_cases;
        else if (!code_list_add(&negative_codes, fields[5])) case_ok = 0;
        if (!case_ok) ++failures;
        ++cases;
        fputs("{\"kind\":\"complex-projective-self-test\",\"status\":", stdout);
        json_string(case_ok ? "pass" : "fail");
        fputs(",\"expected\":", stdout);
        json_string(fields[0]);
        fputs(",\"observedCode\":", stdout);
        json_string(result.first_code[0] == '\0' ? "-" : result.first_code);
        fputs("}\n", stdout);
    }
    if (ferror(file)) ++failures;
    free(line);
    if (fclose(file) != 0) ++failures;
    if (cases == 0 || positive_cases < 2) ++failures;
    {
        CodeNode *node = required_codes;
        while (node != NULL) {
            if (!code_list_contains(negative_codes, node->code)) {
                ++failures;
                fputs("{\"kind\":\"complex-projective-self-test-coverage\","
                      "\"status\":\"fail\",\"missingDiagnostic\":", stdout);
                json_string(node->code);
                fputs("}\n", stdout);
            }
            node = node->next;
        }
    }
    printf("{\"kind\":\"complex-projective-self-test-summary\","
           "\"status\":\"%s\",\"cases\":%d,\"failures\":%d}\n",
           failures == 0 ? "pass" : "fail", cases, failures);
    code_list_free(required_codes);
    code_list_free(negative_codes);
    return failures == 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s verify CONTRACT RECEIPT CORPUS ARTIFACT_ROOT\n"
            "  %s self-test CASES\n",
            program, program);
}

int main(int argc, char **argv) {
    if (argc == 6 && strcmp(argv[1], "verify") == 0) {
        VerifyResult result = {0};
        return verify_files(argv[2], argv[3], argv[4], argv[5], &result) ? 0 : 1;
    }
    if (argc == 3 && strcmp(argv[1], "self-test") == 0) {
        return run_self_test(argv[2]) ? 0 : 1;
    }
    usage(argv[0]);
    return 2;
}
