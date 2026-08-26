#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define ROW_MAX 128
#define VALUE_MAX 4096
#define LINE_MAXIMUM (1024 * 1024)

typedef struct {
    char kind[16];
    char name[128];
    char role[32];
    char repository[VALUE_MAX];
    char revision[65];
    char target[128];
    char code[128];
    int consumed;
} ContractRow;

typedef struct {
    ContractRow rows[ROW_MAX];
    int count;
} Contract;

typedef struct {
    ContractRow identity;
    char status[16];
    char witness[VALUE_MAX];
    char sha256[65];
} ReceiptRow;

typedef struct {
    ReceiptRow rows[ROW_MAX];
    int count;
} Receipt;

typedef struct {
    int assertions;
    int failures;
    char first_code[128];
} Result;

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
    return lower_hex(text, 40) || lower_hex(text, 64);
}

static int token(const char *text) {
    const unsigned char *cursor = (const unsigned char *)text;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(islower(*cursor) || isdigit(*cursor) || *cursor == '-' ||
              *cursor == '_' || *cursor == '.')) return 0;
        ++cursor;
    }
    return 1;
}

static int valid_code(const char *text) {
    const unsigned char *cursor = (const unsigned char *)text;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(isupper(*cursor) || isdigit(*cursor) || *cursor == '-')) return 0;
        ++cursor;
    }
    return 1;
}

static int component_role(const char *role) {
    static const char *roles[] = {
        "consumer", "language", "command-language", "backend", "runtime",
        "toolchain", "bridge", "library"
    };
    size_t index;
    for (index = 0; index < sizeof(roles) / sizeof(roles[0]); ++index) {
        if (strcmp(role, roles[index]) == 0) return 1;
    }
    return 0;
}

static int repository_url(const char *text) {
    const char *cursor;
    if (strncmp(text, "https://", 8) != 0 || strchr(text, '\t') != NULL ||
        strchr(text, ' ') != NULL) return 0;
    cursor = text + 8;
    return *cursor != '\0' && strchr(cursor, '/') != NULL;
}

static int safe_relative_path(const char *path) {
    const char *component = path;
    const char *slash;
    if (*path == '\0' || *path == '/') return 0;
    while (1) {
        size_t length;
        slash = strchr(component, '/');
        length = slash == NULL ? strlen(component) : (size_t)(slash - component);
        if (length == 0 || (length == 1 && component[0] == '.') ||
            (length == 2 && component[0] == '.' && component[1] == '.')) return 0;
        if (slash == NULL) break;
        component = slash + 1;
    }
    return 1;
}

static int join_path(char *output, size_t size, const char *root,
                     const char *relative) {
    int written;
    if (*root == '\0' || !safe_relative_path(relative)) return 0;
    written = snprintf(output, size, "%s/%s", root, relative);
    return written >= 0 && (size_t)written < size;
}

static int regular_nonempty_file(const char *path) {
    struct stat information;
    return lstat(path, &information) == 0 && S_ISREG(information.st_mode) &&
           information.st_size > 0;
}

static int wait_success(pid_t child) {
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) return 0;
    }
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

static int sha256_file(const char *path, char digest[65]) {
    int pipefd[2];
    pid_t child;
    ssize_t got;
    char output[128];
    size_t used = 0;
    if (pipe(pipefd) != 0) return 0;
    child = fork();
    if (child < 0) {
        close(pipefd[0]); close(pipefd[1]); return 0;
    }
    if (child == 0) {
        char *argv[] = {"sha256sum", "--", (char *)path, NULL};
        if (dup2(pipefd[1], STDOUT_FILENO) < 0) _exit(126);
        close(pipefd[0]); close(pipefd[1]);
        execvp(argv[0], argv);
        _exit(127);
    }
    close(pipefd[1]);
    while ((got = read(pipefd[0], output + used, sizeof(output) - 1 - used)) > 0) {
        used += (size_t)got;
        if (used == sizeof(output) - 1) break;
    }
    close(pipefd[0]);
    output[used] = '\0';
    if (!wait_success(child) || used < 64) return 0;
    memcpy(digest, output, 64);
    digest[64] = '\0';
    return lower_hex(digest, 64);
}

static int same_identity(const ContractRow *left, const ContractRow *right) {
    return strcmp(left->kind, right->kind) == 0 &&
           strcmp(left->name, right->name) == 0 &&
           strcmp(left->role, right->role) == 0 &&
           strcmp(left->repository, right->repository) == 0 &&
           strcmp(left->revision, right->revision) == 0 &&
           strcmp(left->target, right->target) == 0 &&
           strcmp(left->code, right->code) == 0;
}

static int duplicate_identity(const Contract *contract, const ContractRow *row) {
    int index;
    for (index = 0; index < contract->count; ++index) {
        if (same_identity(&contract->rows[index], row) ||
            strcmp(contract->rows[index].code, row->code) == 0 ||
            (strcmp(contract->rows[index].kind, row->kind) == 0 &&
             strcmp(contract->rows[index].name, row->name) == 0)) return 1;
    }
    return 0;
}

static int fill_identity(ContractRow *row, char **fields) {
    return copy_value(row->kind, sizeof(row->kind), fields[0]) &&
           copy_value(row->name, sizeof(row->name), fields[1]) &&
           copy_value(row->role, sizeof(row->role), fields[2]) &&
           copy_value(row->repository, sizeof(row->repository), fields[3]) &&
           copy_value(row->revision, sizeof(row->revision), fields[4]) &&
           copy_value(row->target, sizeof(row->target), fields[5]) &&
           copy_value(row->code, sizeof(row->code), fields[6]);
}

static int valid_identity(const ContractRow *row) {
    if (!token(row->name) || !token(row->target) || !valid_code(row->code)) return 0;
    if (strcmp(row->kind, "component") == 0) {
        return component_role(row->role) && repository_url(row->repository) &&
               full_revision(row->revision);
    }
    if (strcmp(row->kind, "probe") == 0) {
        return strcmp(row->role, "acceptance") == 0 &&
               strcmp(row->repository, "-") == 0 && strcmp(row->revision, "-") == 0;
    }
    return 0;
}

static int read_contract(const char *path, Contract *contract) {
    static const char *header = "kind\tname\trole\trepository\trevision\ttarget\tcode";
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int header_seen = 0, consumers = 0, languages = 0, backends = 0, probes = 0;
    memset(contract, 0, sizeof(*contract));
    if (file == NULL) return 0;
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *fields[7];
        ContractRow row;
        if (length > LINE_MAXIMUM) goto bad;
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        if (!header_seen) {
            if (strcmp(content, header) != 0) goto bad;
            header_seen = 1;
            continue;
        }
        memset(&row, 0, sizeof(row));
        if (split_tabs(content, fields, 7) != 7 || !fill_identity(&row, fields) ||
            !valid_identity(&row) || contract->count >= ROW_MAX ||
            duplicate_identity(contract, &row)) goto bad;
        contract->rows[contract->count++] = row;
        if (strcmp(row.kind, "probe") == 0) ++probes;
        if (strcmp(row.role, "consumer") == 0) ++consumers;
        if (strcmp(row.role, "language") == 0) ++languages;
        if (strcmp(row.role, "backend") == 0) ++backends;
    }
    free(line); fclose(file);
    return header_seen && contract->count > 0 && consumers == 1 &&
           languages >= 1 && backends >= 1 && probes >= 1;
bad:
    free(line); fclose(file); return 0;
}

static int valid_status(const char *status) {
    return strcmp(status, "PASS") == 0 || strcmp(status, "FAIL") == 0 ||
           strcmp(status, "NOT_VERIFIED") == 0;
}

static int read_receipt(const char *path, Receipt *receipt) {
    static const char *header = "kind\tname\tstatus\trole\trepository\trevision\ttarget\tcode\twitness\tsha256";
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int header_seen = 0;
    memset(receipt, 0, sizeof(*receipt));
    if (file == NULL) return 0;
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *fields[10];
        ReceiptRow row;
        Contract identity_set;
        int index;
        if (length > LINE_MAXIMUM) goto bad;
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        if (!header_seen) {
            if (strcmp(content, header) != 0) goto bad;
            header_seen = 1;
            continue;
        }
        memset(&row, 0, sizeof(row));
        if (split_tabs(content, fields, 10) != 10) goto bad;
        {
            char *identity_fields[7] = {fields[0], fields[1], fields[3], fields[4],
                                        fields[5], fields[6], fields[7]};
            if (!fill_identity(&row.identity, identity_fields)) goto bad;
        }
        if (!valid_identity(&row.identity) || !valid_status(fields[2]) ||
            !copy_value(row.status, sizeof(row.status), fields[2]) ||
            !copy_value(row.witness, sizeof(row.witness), fields[8]) ||
            !copy_value(row.sha256, sizeof(row.sha256), fields[9]) ||
            receipt->count >= ROW_MAX) goto bad;
        if (strcmp(row.status, "PASS") == 0 || strcmp(row.status, "FAIL") == 0) {
            if (!safe_relative_path(row.witness) || !lower_hex(row.sha256, 64)) goto bad;
        } else if (strcmp(row.witness, "-") != 0 || strcmp(row.sha256, "-") != 0) {
            goto bad;
        }
        memset(&identity_set, 0, sizeof(identity_set));
        for (index = 0; index < receipt->count; ++index) {
            identity_set.rows[identity_set.count++] = receipt->rows[index].identity;
        }
        if (duplicate_identity(&identity_set, &row.identity)) goto bad;
        receipt->rows[receipt->count++] = row;
    }
    free(line); fclose(file);
    return header_seen && receipt->count > 0;
bad:
    free(line); fclose(file); return 0;
}

static void json_string(const char *text) {
    const unsigned char *cursor = (const unsigned char *)text;
    putchar('"');
    while (*cursor != '\0') {
        if (*cursor == '"' || *cursor == '\\') { putchar('\\'); putchar(*cursor); }
        else if (*cursor == '\n') fputs("\\n", stdout);
        else if (*cursor == '\r') fputs("\\r", stdout);
        else if (*cursor == '\t') fputs("\\t", stdout);
        else putchar(*cursor);
        ++cursor;
    }
    putchar('"');
}

static void record(Result *result, int ok, const char *code,
                   const char *name, const char *detail) {
    ++result->assertions;
    if (!ok) {
        ++result->failures;
        if (result->first_code[0] == '\0') copy_value(result->first_code,
                                                       sizeof(result->first_code), code);
    }
    fputs("{\"kind\":\"compatibility\",\"status\":", stdout);
    json_string(ok ? "pass" : "fail");
    fputs(",\"code\":", stdout); json_string(code);
    fputs(",\"name\":", stdout); json_string(name);
    fputs(",\"detail\":", stdout); json_string(detail);
    fputs("}\n", stdout);
}

static ReceiptRow *find_receipt(Receipt *receipt, const ContractRow *required) {
    int index;
    for (index = 0; index < receipt->count; ++index) {
        if (same_identity(&receipt->rows[index].identity, required)) {
            receipt->rows[index].identity.consumed = 1;
            return &receipt->rows[index];
        }
    }
    return NULL;
}

static int witness_matches(const ReceiptRow *row, const char *root) {
    char path[VALUE_MAX * 2];
    char digest[65];
    return join_path(path, sizeof(path), root, row->witness) &&
           regular_nonempty_file(path) && sha256_file(path, digest) &&
           strcmp(digest, row->sha256) == 0;
}

static int verify(const char *contract_path, const char *receipt_path,
                  const char *root, Result *result) {
    Contract contract;
    Receipt receipt;
    int index, extras = 0;
    memset(result, 0, sizeof(*result));
    if (!read_contract(contract_path, &contract)) {
        record(result, 0, "COMPAT-CONTRACT", "contract", "contract is unreadable or malformed");
        return 0;
    }
    record(result, 1, "COMPAT-CONTRACT", "contract", "exact compatibility tuple declared");
    if (!read_receipt(receipt_path, &receipt)) {
        record(result, 0, "COMPAT-RECEIPT", "receipt", "receipt is unreadable or malformed");
        return 0;
    }
    record(result, 1, "COMPAT-RECEIPT", "receipt", "receipt structure is exact");
    for (index = 0; index < contract.count; ++index) {
        ReceiptRow *row = find_receipt(&receipt, &contract.rows[index]);
        int witnessed = row != NULL && strcmp(row->status, "NOT_VERIFIED") != 0 &&
                        witness_matches(row, root);
        int ok = row != NULL && strcmp(row->status, "PASS") == 0 && witnessed;
        const char *detail = row == NULL ? "required tuple row is missing" :
                             strcmp(row->status, "FAIL") == 0 ?
                                 (witnessed ? "FAIL (witness verified)" :
                                              "FAIL (witness missing or digest differs)") :
                             strcmp(row->status, "NOT_VERIFIED") == 0 ? "NOT_VERIFIED" :
                             ok ? "exact row and witness verified" : "witness missing or digest differs";
        record(result, ok, contract.rows[index].code, contract.rows[index].name, detail);
    }
    for (index = 0; index < receipt.count; ++index) {
        if (!receipt.rows[index].identity.consumed) ++extras;
    }
    record(result, extras == 0, "COMPAT-RECEIPT-EXTRA", "receipt-closure",
           extras == 0 ? "no undeclared compatibility rows" : "receipt has undeclared rows");
    printf("{\"kind\":\"compatibility-summary\",\"status\":\"%s\",\"assertions\":%d,\"failures\":%d}\n",
           result->failures == 0 ? "pass" : "fail", result->assertions, result->failures);
    return result->failures == 0;
}

static int self_test(const char *cases_path) {
    FILE *file = fopen(cases_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int cases = 0, failures = 0;
    if (file == NULL) {
        fprintf(stderr, "cannot read compatibility cases: %s\n", cases_path);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *fields[5];
        Result result;
        int observed, expected, case_ok;
        if (length > LINE_MAXIMUM) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        ++cases;
        if (split_tabs(content, fields, 5) != 5 ||
            (strcmp(fields[0], "pass") != 0 && strcmp(fields[0], "fail") != 0)) {
            ++failures;
            continue;
        }
        expected = strcmp(fields[0], "pass") == 0;
        observed = verify(fields[1], fields[2], fields[3], &result);
        case_ok = observed == expected &&
                  ((expected && strcmp(fields[4], "-") == 0) ||
                   (!expected && strcmp(result.first_code, fields[4]) == 0));
        if (!case_ok) ++failures;
        fputs("{\"kind\":\"compatibility-self-test\",\"status\":", stdout);
        json_string(case_ok ? "pass" : "fail");
        fputs(",\"receipt\":", stdout); json_string(fields[2]);
        fputs(",\"expected_first_code\":", stdout); json_string(fields[4]);
        fputs(",\"observed_first_code\":", stdout);
        json_string(result.first_code[0] == '\0' ? "-" : result.first_code);
        fputs("}\n", stdout);
    }
    free(line);
    fclose(file);
    printf("{\"kind\":\"compatibility-self-test-summary\",\"status\":\"%s\",\"cases\":%d,\"failures\":%d}\n",
           failures == 0 && cases > 0 ? "pass" : "fail", cases, failures);
    return failures == 0 && cases > 0;
}

static void usage(const char *program) {
    fprintf(stderr, "usage:\n  %s verify CONTRACT RECEIPT ROOT\n  %s self-test CASES\n",
            program, program);
}

int main(int argc, char **argv) {
    Result result;
    if (argc == 5 && strcmp(argv[1], "verify") == 0)
        return verify(argv[2], argv[3], argv[4], &result) ? 0 : 1;
    if (argc == 3 && strcmp(argv[1], "self-test") == 0)
        return self_test(argv[2]) ? 0 : 1;
    usage(argv[0]);
    return 2;
}
