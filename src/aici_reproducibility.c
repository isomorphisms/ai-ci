#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

#define ROW_MAX 96
#define KEY_MAX 64
#define VALUE_MAX PATH_MAX

typedef struct {
    char key[KEY_MAX];
    char value[VALUE_MAX];
} Row;

typedef struct {
    Row rows[ROW_MAX];
    int count;
} Table;

typedef struct {
    char field[KEY_MAX];
    char role[32];
} SchemaRow;

typedef struct {
    SchemaRow rows[ROW_MAX];
    int count;
} ReceiptSchema;

typedef struct {
    char code[64];
    char detail[256];
} VerifyError;

typedef struct {
    Table table;
    char receipt_sha256[65];
    char material_sha256[65];
    char package_toolchain_sha256[65];
    char native_sha256[65];
    char unsigned_sha256[65];
    char aligned_sha256[65];
    char signed_sha256[65];
} PackageReceipt;

typedef struct {
    Table table;
    char file_sha256[65];
    char witness_sha256[65];
    char cases_sha256[65];
    char source_root[PATH_MAX];
    char work_root[PATH_MAX];
    char output_root[PATH_MAX];
    char witness_path[PATH_MAX];
    char cases_path[PATH_MAX];
    char package_path[PATH_MAX];
    char native_path[PATH_MAX];
    char signed_path[PATH_MAX];
    PackageReceipt package;
} Attempt;

static const char *contract_fields[] = {
    "schema",
    "consumer_repository",
    "source_revision",
    "dependency_closure_sha256",
    "compiler_toolchain_sha256",
    "package_toolchain_sha256",
    "profile_sha256",
    "recipe_sha256",
    "policy_sha256",
    "signer_cert_sha256",
    "target_abi",
    "ndk_packager_revision",
    "ndk_receipt_schema_sha256",
    "witness_schema"
};

static const char *attempt_fields[] = {
    "schema",
    "attempt_id",
    "source_root",
    "work_root",
    "output_root",
    "timezone",
    "input_order",
    "input_modes",
    "consumer_repository",
    "source_revision",
    "dependency_closure_sha256",
    "compiler_toolchain_sha256",
    "profile_sha256",
    "recipe_sha256",
    "policy_sha256",
    "witness_schema",
    "witness_status",
    "witness_file",
    "witness_sha256",
    "executed_cases_file",
    "executed_cases_sha256",
    "ndk_packager_revision",
    "package_receipt",
    "native_file",
    "signed_apk"
};

static const char *package_tool_fields[] = {
    "packager_sha256",
    "verifier_sha256",
    "aapt2_sha256",
    "zipalign_sha256",
    "apksigner_sha256",
    "apksigner_jar_sha256",
    "android_jar_sha256",
    "zip_sha256"
};

static int set_error(VerifyError *error, const char *code, const char *format, ...) {
    va_list arguments;
    snprintf(error->code, sizeof(error->code), "%s", code);
    va_start(arguments, format);
    vsnprintf(error->detail, sizeof(error->detail), format, arguments);
    va_end(arguments);
    return 0;
}

static int copy_text(char *destination, size_t size, const char *source) {
    size_t length = strlen(source);
    if (length + 1 > size) return 0;
    memcpy(destination, source, length + 1);
    return 1;
}

static int append_path(char *destination, size_t size, const char *base,
                       const char *suffix) {
    size_t base_length = strlen(base);
    size_t suffix_length = strlen(suffix);
    if (suffix[0] != '/' || base_length + suffix_length + 1 > size) return 0;
    memcpy(destination, base, base_length);
    memcpy(destination + base_length, suffix, suffix_length + 1);
    return 1;
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

static int valid_key(const char *text) {
    const unsigned char *cursor = (const unsigned char *)text;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(islower(*cursor) || isdigit(*cursor) || *cursor == '_')) return 0;
        ++cursor;
    }
    return 1;
}

static int valid_token(const char *text) {
    const unsigned char *cursor = (const unsigned char *)text;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(isalnum(*cursor) || *cursor == '.' || *cursor == '_' ||
              *cursor == '-' || *cursor == '/' || *cursor == ':')) return 0;
        ++cursor;
    }
    return 1;
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
            (length == 2 && component[0] == '.' && component[1] == '.')) return 0;
        if (slash == NULL) break;
        component = slash + 1;
    }
    return 1;
}

static int join_path(char *output, size_t size, const char *root,
                     const char *relative) {
    int written;
    if (!safe_relative_path(relative)) return 0;
    written = snprintf(output, size, "%s/%s", root, relative);
    return written >= 0 && (size_t)written < size;
}

static const char *table_value(const Table *table, const char *key) {
    int index;
    for (index = 0; index < table->count; ++index) {
        if (strcmp(table->rows[index].key, key) == 0) return table->rows[index].value;
    }
    return NULL;
}

static int read_two_column_table(const char *path, Table *table, VerifyError *error) {
    FILE *file = fopen(path, "rb");
    char line[VALUE_MAX + KEY_MAX + 8];
    unsigned long line_number = 0;
    if (file == NULL) return set_error(error, "REPRO-READ", "cannot read %s", path);
    memset(table, 0, sizeof(*table));
    while (fgets(line, sizeof(line), file) != NULL) {
        char *tab;
        char *newline;
        int prior;
        ++line_number;
        newline = strchr(line, '\n');
        if (newline == NULL && !feof(file)) {
            fclose(file);
            return set_error(error, "REPRO-TSV", "%s:%lu line too long", path, line_number);
        }
        if (newline != NULL) *newline = '\0';
        if ((newline = strchr(line, '\r')) != NULL) *newline = '\0';
        tab = strchr(line, '\t');
        if (tab == NULL || strchr(tab + 1, '\t') != NULL) {
            fclose(file);
            return set_error(error, "REPRO-TSV", "%s:%lu is not strict two-column TSV", path, line_number);
        }
        *tab = '\0';
        if (!valid_key(line) || strlen(line) >= KEY_MAX || table->count >= ROW_MAX) {
            fclose(file);
            return set_error(error, "REPRO-TSV", "%s:%lu has invalid field", path, line_number);
        }
        for (prior = 0; prior < table->count; ++prior) {
            if (strcmp(table->rows[prior].key, line) == 0) {
                fclose(file);
                return set_error(error, "REPRO-TSV", "%s duplicates %s", path, line);
            }
        }
        if (!copy_text(table->rows[table->count].key, KEY_MAX, line) ||
            !copy_text(table->rows[table->count].value, VALUE_MAX, tab + 1)) {
            fclose(file);
            return set_error(error, "REPRO-TSV", "%s:%lu value is too long", path, line_number);
        }
        ++table->count;
    }
    if (ferror(file) || fclose(file) != 0) {
        return set_error(error, "REPRO-READ", "failed while reading %s", path);
    }
    if (table->count == 0) return set_error(error, "REPRO-TSV", "%s is empty", path);
    return 1;
}

static int require_exact_fields(const Table *table, const char **fields,
                                size_t field_count, const char *kind,
                                VerifyError *error) {
    size_t index;
    if ((size_t)table->count != field_count) {
        return set_error(error, "REPRO-SCHEMA", "%s has %d fields; expected %zu",
                         kind, table->count, field_count);
    }
    for (index = 0; index < field_count; ++index) {
        if (strcmp(table->rows[index].key, fields[index]) != 0) {
            return set_error(error, "REPRO-SCHEMA", "%s field %zu is %s; expected %s",
                             kind, index + 1, table->rows[index].key, fields[index]);
        }
    }
    return 1;
}

static int wait_success(pid_t child) {
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) return 0;
    }
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

static int sha256_file(const char *path, char digest[65]) {
    int descriptors[2];
    pid_t child;
    char output[256];
    size_t length = 0;
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
            dup2(fileno(null_file), STDERR_FILENO) < 0) _exit(126);
        close(descriptors[1]);
        fclose(null_file);
        execlp("sha256sum", "sha256sum", "--", path, (char *)NULL);
        _exit(127);
    }
    close(descriptors[1]);
    while (length < sizeof(output) - 1) {
        ssize_t count = read(descriptors[0], output + length,
                             sizeof(output) - 1 - length);
        if (count == 0) break;
        if (count < 0) {
            if (errno == EINTR) continue;
            close(descriptors[0]);
            wait_success(child);
            return 0;
        }
        length += (size_t)count;
    }
    close(descriptors[0]);
    if (!wait_success(child) || length < 65) return 0;
    memcpy(digest, output, 64);
    digest[64] = '\0';
    return lower_hex(digest, 64) && isspace((unsigned char)output[64]);
}

static int hash_selected_rows(const Table *table, const char **fields,
                              size_t count, char digest[65], VerifyError *error) {
    char temporary[] = "/tmp/aici-reproducibility.XXXXXX";
    int descriptor = mkstemp(temporary);
    FILE *file;
    size_t index;
    int ok = 1;
    if (descriptor < 0) return set_error(error, "REPRO-HASH", "cannot create digest input");
    file = fdopen(descriptor, "wb");
    if (file == NULL) {
        close(descriptor);
        unlink(temporary);
        return set_error(error, "REPRO-HASH", "cannot open digest input");
    }
    for (index = 0; index < count; ++index) {
        const char *value = table_value(table, fields[index]);
        if (value == NULL || fprintf(file, "%s\t%s\n", fields[index], value) < 0) {
            ok = 0;
            break;
        }
    }
    if (fclose(file) != 0) ok = 0;
    if (ok) ok = sha256_file(temporary, digest);
    unlink(temporary);
    if (!ok) return set_error(error, "REPRO-HASH", "cannot hash selected receipt rows");
    return 1;
}

static int hash_material_rows(const Table *table, const ReceiptSchema *schema,
                              char digest[65], VerifyError *error) {
    const char *fields[ROW_MAX];
    size_t count = 0;
    int index;
    for (index = 0; index < schema->count; ++index) {
        if (strcmp(schema->rows[index].role, "material") == 0) {
            fields[count++] = schema->rows[index].field;
        }
    }
    return hash_selected_rows(table, fields, count, digest, error);
}

static int read_receipt_schema(const char *path, ReceiptSchema *schema,
                               VerifyError *error) {
    FILE *file = fopen(path, "rb");
    char line[2048];
    unsigned long line_number = 0;
    if (file == NULL) return set_error(error, "REPRO-NDK-SCHEMA", "cannot read %s", path);
    memset(schema, 0, sizeof(*schema));
    while (fgets(line, sizeof(line), file) != NULL) {
        char *first;
        char *second;
        char *newline = strchr(line, '\n');
        ++line_number;
        if (newline != NULL) *newline = '\0';
        if ((newline = strchr(line, '\r')) != NULL) *newline = '\0';
        first = strchr(line, '\t');
        if (first == NULL || (second = strchr(first + 1, '\t')) == NULL ||
            strchr(second + 1, '\t') != NULL) {
            fclose(file);
            return set_error(error, "REPRO-NDK-SCHEMA", "%s:%lu malformed", path, line_number);
        }
        *first = '\0';
        *second = '\0';
        if (line_number == 1) {
            if (strcmp(line, "field") != 0 || strcmp(first + 1, "role") != 0 ||
                strcmp(second + 1, "meaning") != 0) {
                fclose(file);
                return set_error(error, "REPRO-NDK-SCHEMA", "%s has wrong header", path);
            }
            continue;
        }
        if (!valid_key(line) || strlen(line) >= KEY_MAX || schema->count >= ROW_MAX ||
            (strcmp(first + 1, "material") != 0 &&
             strcmp(first + 1, "identity") != 0 &&
             strcmp(first + 1, "observed") != 0 &&
             strcmp(first + 1, "output") != 0)) {
            fclose(file);
            return set_error(error, "REPRO-NDK-SCHEMA", "%s:%lu invalid field or role", path, line_number);
        }
        if (!copy_text(schema->rows[schema->count].field, KEY_MAX, line) ||
            !copy_text(schema->rows[schema->count].role, 32, first + 1)) {
            fclose(file);
            return set_error(error, "REPRO-NDK-SCHEMA", "%s:%lu field is too long", path, line_number);
        }
        ++schema->count;
    }
    if (ferror(file) || fclose(file) != 0 || schema->count == 0) {
        return set_error(error, "REPRO-NDK-SCHEMA", "%s could not be read completely", path);
    }
    return 1;
}

static int regular_nonempty_file(const char *path) {
    struct stat information;
    return lstat(path, &information) == 0 && S_ISREG(information.st_mode) &&
           information.st_size > 0;
}

static int same_file(const char *left, const char *right) {
    struct stat left_information;
    struct stat right_information;
    if (stat(left, &left_information) != 0 || stat(right, &right_information) != 0) return 0;
    return left_information.st_dev == right_information.st_dev &&
           left_information.st_ino == right_information.st_ino;
}

static int canonical_directory(const char *declared, char resolved[PATH_MAX],
                               VerifyError *error) {
    struct stat information;
    if (declared[0] != '/' || realpath(declared, resolved) == NULL ||
        stat(resolved, &information) != 0 || !S_ISDIR(information.st_mode) ||
        strcmp(declared, resolved) != 0) {
        return set_error(error, "REPRO-ROOT", "root is not an existing canonical absolute directory: %s", declared);
    }
    return 1;
}

static int path_contains(const char *parent, const char *child) {
    size_t length = strlen(parent);
    return strncmp(parent, child, length) == 0 && child[length] == '/';
}

static int isolated_roots(const Attempt *left, const Attempt *right,
                          VerifyError *error) {
    const char *roots[] = {
        left->source_root, left->work_root, left->output_root,
        right->source_root, right->work_root, right->output_root
    };
    size_t first;
    size_t second;
    for (first = 0; first < sizeof(roots) / sizeof(roots[0]); ++first) {
        for (second = first + 1; second < sizeof(roots) / sizeof(roots[0]); ++second) {
            if (strcmp(roots[first], roots[second]) == 0 ||
                path_contains(roots[first], roots[second]) ||
                path_contains(roots[second], roots[first])) {
                return set_error(error, "REPRO-ROOT-SHARED", "build roots overlap: %s and %s",
                                 roots[first], roots[second]);
            }
        }
    }
    return 1;
}

static int validate_package_receipt(const char *path, const char *native_path,
                                    const char *signed_path,
                                    const ReceiptSchema *schema,
                                    const Table *contract,
                                    PackageReceipt *package,
                                    VerifyError *error) {
    int index;
    const char *value;
    char observed[65];
    memset(package, 0, sizeof(*package));
    if (!read_two_column_table(path, &package->table, error)) return 0;
    if (package->table.count != schema->count) {
        return set_error(error, "REPRO-NDK-RECEIPT", "%s field count differs from S01 schema", path);
    }
    for (index = 0; index < schema->count; ++index) {
        const Row *row = &package->table.rows[index];
        if (strcmp(row->key, schema->rows[index].field) != 0) {
            return set_error(error, "REPRO-NDK-RECEIPT", "%s field %d is %s; expected %s",
                             path, index + 1, row->key, schema->rows[index].field);
        }
        if (strstr(row->key, "_sha256") != NULL && !lower_hex(row->value, 64)) {
            return set_error(error, "REPRO-NDK-RECEIPT", "%s has invalid %s", path, row->key);
        }
    }
    value = table_value(&package->table, "schema");
    if (value == NULL || strcmp(value, "android-ndk-nativeactivity-apk-v2") != 0) {
        return set_error(error, "REPRO-NDK-RECEIPT", "%s has unsupported schema", path);
    }
    if (strcmp(table_value(&package->table, "schema_sha256"),
               table_value(contract, "ndk_receipt_schema_sha256")) != 0) {
        return set_error(error, "REPRO-NDK-RECEIPT", "%s schema digest differs from contract", path);
    }
    if (!hash_material_rows(&package->table, schema, observed, error)) return 0;
    if (strcmp(observed, table_value(&package->table, "material_sha256")) != 0) {
        return set_error(error, "REPRO-NDK-MATERIAL", "%s material digest does not match its rows", path);
    }
    snprintf(package->material_sha256, 65, "%s", observed);
    if (!hash_selected_rows(&package->table, package_tool_fields,
                            sizeof(package_tool_fields) / sizeof(package_tool_fields[0]),
                            package->package_toolchain_sha256, error)) return 0;
    if (strcmp(package->package_toolchain_sha256,
               table_value(contract, "package_toolchain_sha256")) != 0) {
        return set_error(error, "REPRO-PACKAGE-TOOLCHAIN", "%s package tools differ from approved closure", path);
    }
    if (strcmp(table_value(&package->table, "source_commit"),
               table_value(contract, "source_revision")) != 0 ||
        strcmp(table_value(&package->table, "signer_cert_sha256"),
               table_value(contract, "signer_cert_sha256")) != 0 ||
        strcmp(table_value(&package->table, "abi"),
               table_value(contract, "target_abi")) != 0) {
        return set_error(error, "REPRO-PACKAGE-CONTRACT", "%s source, signer or ABI differs from contract", path);
    }
    if (!regular_nonempty_file(native_path) || !sha256_file(native_path, observed) ||
        strcmp(observed, table_value(&package->table, "native_sha256")) != 0) {
        return set_error(error, "REPRO-NATIVE-BYTES", "%s native bytes do not match receipt", native_path);
    }
    if (!regular_nonempty_file(signed_path) || !sha256_file(signed_path, observed) ||
        strcmp(observed, table_value(&package->table, "apk_sha256")) != 0) {
        return set_error(error, "REPRO-SIGNED-BYTES", "%s signed bytes do not match receipt", signed_path);
    }
    if (!sha256_file(path, package->receipt_sha256)) {
        return set_error(error, "REPRO-HASH", "cannot hash %s", path);
    }
    snprintf(package->native_sha256, 65, "%s", table_value(&package->table, "native_sha256"));
    snprintf(package->unsigned_sha256, 65, "%s", table_value(&package->table, "unsigned_apk_sha256"));
    snprintf(package->aligned_sha256, 65, "%s", table_value(&package->table, "aligned_apk_sha256"));
    snprintf(package->signed_sha256, 65, "%s", table_value(&package->table, "apk_sha256"));
    return 1;
}

static int validate_contract(const char *path, const char *schema_path,
                             Table *contract, ReceiptSchema *schema,
                             char contract_sha256[65], VerifyError *error) {
    const char *digests[] = {
        "dependency_closure_sha256", "compiler_toolchain_sha256",
        "package_toolchain_sha256", "profile_sha256", "recipe_sha256",
        "policy_sha256", "signer_cert_sha256", "ndk_receipt_schema_sha256"
    };
    size_t index;
    char schema_sha256[65];
    if (!read_two_column_table(path, contract, error) ||
        !require_exact_fields(contract, contract_fields,
                              sizeof(contract_fields) / sizeof(contract_fields[0]),
                              "contract", error)) return 0;
    if (strcmp(table_value(contract, "schema"),
               "aici-independent-build-contract-v1") != 0 ||
        !valid_token(table_value(contract, "consumer_repository")) ||
        !full_revision(table_value(contract, "source_revision")) ||
        !valid_token(table_value(contract, "target_abi")) ||
        !full_revision(table_value(contract, "ndk_packager_revision")) ||
        !valid_token(table_value(contract, "witness_schema"))) {
        return set_error(error, "REPRO-CONTRACT", "contract identity field is invalid");
    }
    for (index = 0; index < sizeof(digests) / sizeof(digests[0]); ++index) {
        if (!lower_hex(table_value(contract, digests[index]), 64)) {
            return set_error(error, "REPRO-CONTRACT", "contract %s is not SHA-256", digests[index]);
        }
    }
    if (!read_receipt_schema(schema_path, schema, error) ||
        !sha256_file(schema_path, schema_sha256)) {
        return set_error(error, "REPRO-NDK-SCHEMA", "cannot hash S01 schema");
    }
    if (strcmp(schema_sha256, table_value(contract, "ndk_receipt_schema_sha256")) != 0) {
        return set_error(error, "REPRO-NDK-SCHEMA", "S01 schema bytes differ from contract");
    }
    if (!sha256_file(path, contract_sha256)) {
        return set_error(error, "REPRO-HASH", "cannot hash contract");
    }
    return 1;
}

static int validate_attempt(const char *path, const char *root,
                            const Table *contract, const ReceiptSchema *schema,
                            Attempt *attempt, VerifyError *error) {
    const char *matching_fields[] = {
        "consumer_repository", "source_revision", "dependency_closure_sha256",
        "compiler_toolchain_sha256", "profile_sha256", "recipe_sha256",
        "policy_sha256", "witness_schema", "ndk_packager_revision"
    };
    const char *digest_fields[] = {
        "dependency_closure_sha256", "compiler_toolchain_sha256",
        "profile_sha256", "recipe_sha256", "policy_sha256",
        "witness_sha256", "executed_cases_sha256"
    };
    char canonical_root[PATH_MAX];
    size_t index;
    memset(attempt, 0, sizeof(*attempt));
    if (!read_two_column_table(path, &attempt->table, error) ||
        !require_exact_fields(&attempt->table, attempt_fields,
                              sizeof(attempt_fields) / sizeof(attempt_fields[0]),
                              "attempt", error)) return 0;
    if (strcmp(table_value(&attempt->table, "schema"),
               "aici-independent-build-attempt-v1") != 0 ||
        !valid_token(table_value(&attempt->table, "attempt_id")) ||
        !valid_token(table_value(&attempt->table, "timezone")) ||
        !valid_token(table_value(&attempt->table, "input_order")) ||
        !valid_token(table_value(&attempt->table, "input_modes")) ||
        strcmp(table_value(&attempt->table, "witness_status"), "pass") != 0) {
        return set_error(error, "REPRO-ATTEMPT", "%s identity or witness status is invalid", path);
    }
    for (index = 0; index < sizeof(digest_fields) / sizeof(digest_fields[0]); ++index) {
        if (!lower_hex(table_value(&attempt->table, digest_fields[index]), 64)) {
            return set_error(error, "REPRO-ATTEMPT", "%s has invalid %s", path, digest_fields[index]);
        }
    }
    for (index = 0; index < sizeof(matching_fields) / sizeof(matching_fields[0]); ++index) {
        if (strcmp(table_value(&attempt->table, matching_fields[index]),
                   table_value(contract, matching_fields[index])) != 0) {
            return set_error(error, "REPRO-CONTRACT-MISMATCH", "%s differs at %s",
                             path, matching_fields[index]);
        }
    }
    if (!canonical_directory(table_value(&attempt->table, "source_root"),
                             attempt->source_root, error) ||
        !canonical_directory(table_value(&attempt->table, "work_root"),
                             attempt->work_root, error) ||
        !canonical_directory(table_value(&attempt->table, "output_root"),
                             attempt->output_root, error) ||
        realpath(root, canonical_root) == NULL || strcmp(canonical_root, attempt->output_root) != 0) {
        return set_error(error, "REPRO-ROOT", "%s output root differs from supplied root", path);
    }
    if (!join_path(attempt->witness_path, sizeof(attempt->witness_path), root,
                   table_value(&attempt->table, "witness_file")) ||
        !join_path(attempt->cases_path, sizeof(attempt->cases_path), root,
                   table_value(&attempt->table, "executed_cases_file")) ||
        !join_path(attempt->package_path, sizeof(attempt->package_path), root,
                   table_value(&attempt->table, "package_receipt")) ||
        !join_path(attempt->native_path, sizeof(attempt->native_path), root,
                   table_value(&attempt->table, "native_file")) ||
        !join_path(attempt->signed_path, sizeof(attempt->signed_path), root,
                   table_value(&attempt->table, "signed_apk"))) {
        return set_error(error, "REPRO-PATH", "%s has an unsafe evidence path", path);
    }
    if (!regular_nonempty_file(attempt->witness_path) ||
        !sha256_file(attempt->witness_path, attempt->witness_sha256) ||
        strcmp(attempt->witness_sha256,
               table_value(&attempt->table, "witness_sha256")) != 0) {
        return set_error(error, "REPRO-WITNESS", "%s witness bytes differ", path);
    }
    if (!regular_nonempty_file(attempt->cases_path) ||
        !sha256_file(attempt->cases_path, attempt->cases_sha256) ||
        strcmp(attempt->cases_sha256,
               table_value(&attempt->table, "executed_cases_sha256")) != 0) {
        return set_error(error, "REPRO-CASES", "%s executed-case bytes differ", path);
    }
    if (!validate_package_receipt(attempt->package_path, attempt->native_path,
                                  attempt->signed_path, schema, contract,
                                  &attempt->package, error)) return 0;
    if (!sha256_file(path, attempt->file_sha256)) {
        return set_error(error, "REPRO-HASH", "cannot hash %s", path);
    }
    return 1;
}

static int compare_attempts(const Attempt *left, const Attempt *right,
                            VerifyError *error) {
    const char *variation_fields[] = {"timezone", "input_order", "input_modes"};
    size_t index;
    if (strcmp(table_value(&left->table, "attempt_id"),
               table_value(&right->table, "attempt_id")) == 0) {
        return set_error(error, "REPRO-ATTEMPT-REUSED", "attempt identifiers are equal");
    }
    if (!isolated_roots(left, right, error)) return 0;
    for (index = 0; index < sizeof(variation_fields) / sizeof(variation_fields[0]); ++index) {
        if (strcmp(table_value(&left->table, variation_fields[index]),
                   table_value(&right->table, variation_fields[index])) == 0) {
            return set_error(error, "REPRO-ENVIRONMENT-NOT-VARIED", "%s did not vary",
                             variation_fields[index]);
        }
    }
    if (strcmp(left->witness_sha256, right->witness_sha256) == 0 ||
        same_file(left->witness_path, right->witness_path)) {
        return set_error(error, "REPRO-WITNESS-REUSED", "attempts reuse one execution witness");
    }
    if (strcmp(left->cases_sha256, right->cases_sha256) != 0) {
        return set_error(error, "REPRO-CASES-DIFFER", "attempts did not execute the same case set");
    }
    if (same_file(left->cases_path, right->cases_path) ||
        same_file(left->package_path, right->package_path) ||
        same_file(left->native_path, right->native_path) ||
        same_file(left->signed_path, right->signed_path)) {
        return set_error(error, "REPRO-OUTPUT-SHARED", "attempts share an evidence or output inode");
    }
    if (strcmp(left->package.material_sha256, right->package.material_sha256) != 0) {
        return set_error(error, "REPRO-MATERIAL-DIFFERENCE", "package material digests differ");
    }
    if (strcmp(left->package.native_sha256, right->package.native_sha256) != 0) {
        return set_error(error, "REPRO-STAGE-DIFFERENCE", "native stage bytes differ");
    }
    if (strcmp(left->package.unsigned_sha256, right->package.unsigned_sha256) != 0) {
        return set_error(error, "REPRO-STAGE-DIFFERENCE", "unsigned package bytes differ");
    }
    if (strcmp(left->package.aligned_sha256, right->package.aligned_sha256) != 0) {
        return set_error(error, "REPRO-STAGE-DIFFERENCE", "aligned package bytes differ");
    }
    if (strcmp(left->package.signed_sha256, right->package.signed_sha256) != 0) {
        return set_error(error, "REPRO-STAGE-DIFFERENCE", "signed package bytes differ");
    }
    return 1;
}

static int verify_pair(const char *contract_path, const char *left_attempt_path,
                       const char *left_root, const char *right_attempt_path,
                       const char *right_root, const char *schema_path,
                       int emit_receipt, VerifyError *error) {
    Table contract;
    ReceiptSchema schema;
    Attempt left;
    Attempt right;
    char contract_sha256[65];
    if (!validate_contract(contract_path, schema_path, &contract, &schema,
                           contract_sha256, error) ||
        !validate_attempt(left_attempt_path, left_root, &contract, &schema,
                          &left, error) ||
        !validate_attempt(right_attempt_path, right_root, &contract, &schema,
                          &right, error) ||
        !compare_attempts(&left, &right, error)) return 0;
    if (emit_receipt) {
        printf("schema\taici-independent-build-verdict-v1\n");
        printf("contract_sha256\t%s\n", contract_sha256);
        printf("left_attempt_id\t%s\n", table_value(&left.table, "attempt_id"));
        printf("left_attempt_sha256\t%s\n", left.file_sha256);
        printf("left_witness_sha256\t%s\n", left.witness_sha256);
        printf("left_executed_cases_sha256\t%s\n", left.cases_sha256);
        printf("left_package_receipt_sha256\t%s\n", left.package.receipt_sha256);
        printf("right_attempt_id\t%s\n", table_value(&right.table, "attempt_id"));
        printf("right_attempt_sha256\t%s\n", right.file_sha256);
        printf("right_witness_sha256\t%s\n", right.witness_sha256);
        printf("right_executed_cases_sha256\t%s\n", right.cases_sha256);
        printf("right_package_receipt_sha256\t%s\n", right.package.receipt_sha256);
        printf("consumer_repository\t%s\n", table_value(&contract, "consumer_repository"));
        printf("source_revision\t%s\n", table_value(&contract, "source_revision"));
        printf("dependency_closure_sha256\t%s\n", table_value(&contract, "dependency_closure_sha256"));
        printf("compiler_toolchain_sha256\t%s\n", table_value(&contract, "compiler_toolchain_sha256"));
        printf("package_toolchain_sha256\t%s\n", table_value(&contract, "package_toolchain_sha256"));
        printf("profile_sha256\t%s\n", table_value(&contract, "profile_sha256"));
        printf("recipe_sha256\t%s\n", table_value(&contract, "recipe_sha256"));
        printf("policy_sha256\t%s\n", table_value(&contract, "policy_sha256"));
        printf("ndk_packager_revision\t%s\n", table_value(&contract, "ndk_packager_revision"));
        printf("ndk_receipt_schema_sha256\t%s\n", table_value(&contract, "ndk_receipt_schema_sha256"));
        printf("target_abi\t%s\n", table_value(&contract, "target_abi"));
        printf("package_material_sha256\t%s\n", left.package.material_sha256);
        printf("native_sha256\t%s\n", left.package.native_sha256);
        printf("unsigned_apk_sha256\t%s\n", left.package.unsigned_sha256);
        printf("aligned_apk_sha256\t%s\n", left.package.aligned_sha256);
        printf("signed_apk_sha256\t%s\n", left.package.signed_sha256);
        printf("result\tPASS\n");
    }
    return 1;
}

static int make_directory(const char *path) {
    char copy[PATH_MAX];
    char *cursor;
    if (snprintf(copy, sizeof(copy), "%s", path) < 0 || copy[0] != '/') return 0;
    for (cursor = copy + 1; *cursor != '\0'; ++cursor) {
        if (*cursor == '/') {
            *cursor = '\0';
            if (mkdir(copy, 0755) != 0 && errno != EEXIST) return 0;
            *cursor = '/';
        }
    }
    return mkdir(copy, 0755) == 0 || errno == EEXIST;
}

static int write_text(const char *path, const char *text) {
    FILE *file = fopen(path, "wb");
    size_t length = strlen(text);
    int ok = file != NULL && fwrite(text, 1, length, file) == length;
    if (file != NULL && fclose(file) != 0) ok = 0;
    return ok;
}

static void fill_digest(char output[65], char character) {
    memset(output, character, 64);
    output[64] = '\0';
}

static int set_table_value(Table *table, const char *key, const char *value) {
    int index;
    for (index = 0; index < table->count; ++index) {
        if (strcmp(table->rows[index].key, key) == 0) {
            return snprintf(table->rows[index].value, VALUE_MAX, "%s", value) >= 0;
        }
    }
    return 0;
}

static int write_table(const char *path, const Table *table) {
    FILE *file = fopen(path, "wb");
    int index;
    int ok = file != NULL;
    if (!ok) return 0;
    for (index = 0; index < table->count; ++index) {
        if (fprintf(file, "%s\t%s\n", table->rows[index].key,
                    table->rows[index].value) < 0) {
            ok = 0;
            break;
        }
    }
    if (fclose(file) != 0) ok = 0;
    return ok;
}

static int table_from_fields(Table *table, const char **fields, size_t count) {
    size_t index;
    memset(table, 0, sizeof(*table));
    if (count > ROW_MAX) return 0;
    for (index = 0; index < count; ++index) {
        snprintf(table->rows[index].key, KEY_MAX, "%s", fields[index]);
    }
    table->count = (int)count;
    return 1;
}

static int write_package_fixture(const char *path, const ReceiptSchema *schema,
                                 const char *schema_sha256, const char *native_sha256,
                                 const char *signed_sha256, int omitted_unsigned,
                                 Table *receipt_out, VerifyError *error) {
    Table receipt;
    char digest[65];
    int index;
    memset(&receipt, 0, sizeof(receipt));
    receipt.count = schema->count;
    for (index = 0; index < schema->count; ++index) {
        const char *field = schema->rows[index].field;
        char value[VALUE_MAX] = "fixture";
        snprintf(receipt.rows[index].key, KEY_MAX, "%s", field);
        if (strcmp(field, "schema") == 0) snprintf(value, sizeof(value), "android-ndk-nativeactivity-apk-v2");
        else if (strcmp(field, "schema_sha256") == 0) snprintf(value, sizeof(value), "%s", schema_sha256);
        else if (strcmp(field, "package") == 0) snprintf(value, sizeof(value), "org.example.reproducibility");
        else if (strcmp(field, "version_code") == 0) snprintf(value, sizeof(value), "1");
        else if (strcmp(field, "version_name") == 0) snprintf(value, sizeof(value), "fixture");
        else if (strcmp(field, "min_sdk") == 0) snprintf(value, sizeof(value), "26");
        else if (strcmp(field, "target_sdk") == 0) snprintf(value, sizeof(value), "35");
        else if (strcmp(field, "expected_launcher_label") == 0) snprintf(value, sizeof(value), "fixture");
        else if (strcmp(field, "require_no_dex") == 0) snprintf(value, sizeof(value), "1");
        else if (strcmp(field, "abi") == 0) snprintf(value, sizeof(value), "armeabi-v7a");
        else if (strcmp(field, "native_library") == 0) snprintf(value, sizeof(value), "libfixture.so");
        else if (strcmp(field, "source_date_epoch") == 0 || strcmp(field, "approved_source_date_epoch") == 0) snprintf(value, sizeof(value), "1710200000");
        else if (strcmp(field, "timestamp_normalization") == 0) snprintf(value, sizeof(value), "source-date-epoch-utc");
        else if (strcmp(field, "mode_normalization") == 0) snprintf(value, sizeof(value), "files-0644-directories-0755");
        else if (strcmp(field, "entry_order") == 0) snprintf(value, sizeof(value), "lc-all-c-relative-path");
        else if (strcmp(field, "zip_metadata") == 0) snprintf(value, sizeof(value), "strip-uid-gid-extra");
        else if (strcmp(field, "source_commit") == 0) snprintf(value, sizeof(value), "1111111111111111111111111111111111111111");
        else if (strcmp(field, "signature_policy") == 0) snprintf(value, sizeof(value), "apk-signature-v2-only");
        else if (strcmp(field, "signature_mode") == 0) snprintf(value, sizeof(value), "v1-false,v2-true,v3-false,v3.1-false,v4-false");
        else if (strcmp(field, "signer_cert_sha256") == 0) fill_digest(value, '7');
        else if (strcmp(field, "native_sha256") == 0) snprintf(value, sizeof(value), "%s", native_sha256);
        else if (strcmp(field, "material_sha256") == 0) fill_digest(value, '0');
        else if (strcmp(field, "launcher_label") == 0 || strcmp(field, "launcher_activity_label") == 0) snprintf(value, sizeof(value), "fixture");
        else if (strcmp(field, "unsigned_apk_sha256") == 0) {
            if (omitted_unsigned) value[0] = '\0'; else fill_digest(value, '2');
        } else if (strcmp(field, "aligned_apk_sha256") == 0) fill_digest(value, '3');
        else if (strcmp(field, "apk_sha256") == 0) snprintf(value, sizeof(value), "%s", signed_sha256);
        else if (strstr(field, "_sha256") != NULL) {
            char marker = '4';
            if (strcmp(field, "packager_sha256") == 0) marker = 'a';
            else if (strcmp(field, "verifier_sha256") == 0) marker = 'b';
            else if (strcmp(field, "aapt2_sha256") == 0) marker = 'c';
            else if (strcmp(field, "zipalign_sha256") == 0) marker = 'd';
            else if (strcmp(field, "apksigner_sha256") == 0) marker = 'e';
            else if (strcmp(field, "apksigner_jar_sha256") == 0) marker = 'f';
            else if (strcmp(field, "android_jar_sha256") == 0) marker = '8';
            else if (strcmp(field, "zip_sha256") == 0) marker = '9';
            fill_digest(value, marker);
        }
        snprintf(receipt.rows[index].value, VALUE_MAX, "%s", value);
    }
    if (!hash_material_rows(&receipt, schema, digest, error) ||
        !set_table_value(&receipt, "material_sha256", digest) ||
        !write_table(path, &receipt)) return 0;
    *receipt_out = receipt;
    return 1;
}

enum FixtureMutation {
    FIXTURE_GOOD,
    FIXTURE_REUSED_WITNESS,
    FIXTURE_HIDDEN_DEPENDENCY,
    FIXTURE_WRONG_NDK,
    FIXTURE_OMITTED_STAGE,
    FIXTURE_UNEQUAL_SIGNED,
    FIXTURE_SHARED_OUTPUT,
    FIXTURE_SAME_TIMEZONE,
    FIXTURE_UNVERIFIED_WITNESS,
    FIXTURE_CHANGED_POLICY,
    FIXTURE_MISSING_CASE
};

static int make_fixture_case(const char *schema_path, const char *case_root,
                             enum FixtureMutation mutation, VerifyError *error) {
    ReceiptSchema schema;
    Table package_left;
    Table package_right;
    Table contract;
    Table attempt;
    char left_base[PATH_MAX], right_base[PATH_MAX];
    char left_source[PATH_MAX], left_work[PATH_MAX], left_output[PATH_MAX];
    char right_source[PATH_MAX], right_work[PATH_MAX], right_output[PATH_MAX];
    char path[PATH_MAX];
    char schema_sha[65], native_left_sha[65], native_right_sha[65];
    char signed_left_sha[65], signed_right_sha[65], package_tools_sha[65];
    char witness_left_sha[65], witness_right_sha[65], cases_left_sha[65], cases_right_sha[65];
    char digest[65];
    const char *left_signed = "signed stable bytes\n";
    const char *right_signed = mutation == FIXTURE_UNEQUAL_SIGNED ? "signed changed bytes\n" : left_signed;
    if (!read_receipt_schema(schema_path, &schema, error) || !sha256_file(schema_path, schema_sha)) return 0;
    if (!append_path(left_base, sizeof(left_base), case_root, "/left") ||
        !append_path(right_base, sizeof(right_base), case_root, "/right") ||
        !append_path(left_source, sizeof(left_source), left_base, "/source") ||
        !append_path(left_work, sizeof(left_work), left_base, "/work") ||
        !append_path(left_output, sizeof(left_output), left_base, "/output") ||
        !append_path(right_source, sizeof(right_source), right_base, "/source") ||
        !append_path(right_work, sizeof(right_work), right_base, "/work") ||
        !append_path(right_output, sizeof(right_output), right_base, "/output")) return 0;
    if (!make_directory(left_source) || !make_directory(left_work) || !make_directory(left_output) ||
        !make_directory(right_source) || !make_directory(right_work) || !make_directory(right_output)) return 0;
    if (!append_path(path, sizeof(path), left_output, "/native.so")) return 0;
    if (!write_text(path, "native stable bytes\n") || !sha256_file(path, native_left_sha)) return 0;
    if (!append_path(path, sizeof(path), right_output, "/native.so")) return 0;
    if (!write_text(path, "native stable bytes\n") || !sha256_file(path, native_right_sha)) return 0;
    if (!append_path(path, sizeof(path), left_output, "/app.apk")) return 0;
    if (!write_text(path, left_signed) || !sha256_file(path, signed_left_sha)) return 0;
    if (!append_path(path, sizeof(path), right_output, "/app.apk")) return 0;
    if (!write_text(path, right_signed) || !sha256_file(path, signed_right_sha)) return 0;
    if (!append_path(path, sizeof(path), left_output, "/witness.tsv")) return 0;
    if (!write_text(path, "schema\tp01-stage-roles-v1\nattempt\tleft\nresult\tPASS\n") || !sha256_file(path, witness_left_sha)) return 0;
    if (!append_path(path, sizeof(path), right_output, "/witness.tsv")) return 0;
    if (!write_text(path, mutation == FIXTURE_REUSED_WITNESS ?
                    "schema\tp01-stage-roles-v1\nattempt\tleft\nresult\tPASS\n" :
                    "schema\tp01-stage-roles-v1\nattempt\tright\nresult\tPASS\n") ||
        !sha256_file(path, witness_right_sha)) return 0;
    if (!append_path(path, sizeof(path), left_output, "/cases.tsv")) return 0;
    if (!write_text(path, "case\tresult\ncompile\tPASS\npackage\tPASS\n") || !sha256_file(path, cases_left_sha)) return 0;
    if (!append_path(path, sizeof(path), right_output, "/cases.tsv")) return 0;
    if (!write_text(path, mutation == FIXTURE_MISSING_CASE ?
                    "case\tresult\ncompile\tPASS\n" :
                    "case\tresult\ncompile\tPASS\npackage\tPASS\n") ||
        !sha256_file(path, cases_right_sha)) return 0;
    if (!append_path(path, sizeof(path), left_output, "/package.receipt.tsv")) return 0;
    if (!write_package_fixture(path, &schema, schema_sha, native_left_sha, signed_left_sha, 0,
                               &package_left, error)) return 0;
    if (!append_path(path, sizeof(path), right_output, "/package.receipt.tsv")) return 0;
    if (!write_package_fixture(path, &schema, schema_sha, native_right_sha, signed_right_sha,
                               mutation == FIXTURE_OMITTED_STAGE, &package_right, error)) return 0;
    if (!hash_selected_rows(&package_left, package_tool_fields,
                            sizeof(package_tool_fields) / sizeof(package_tool_fields[0]),
                            package_tools_sha, error)) return 0;
    table_from_fields(&contract, contract_fields,
                      sizeof(contract_fields) / sizeof(contract_fields[0]));
    set_table_value(&contract, "schema", "aici-independent-build-contract-v1");
    set_table_value(&contract, "consumer_repository", "isomorphismes/wegert");
    set_table_value(&contract, "source_revision", "1111111111111111111111111111111111111111");
    fill_digest(digest, '5'); set_table_value(&contract, "dependency_closure_sha256", digest);
    fill_digest(digest, '6'); set_table_value(&contract, "compiler_toolchain_sha256", digest);
    set_table_value(&contract, "package_toolchain_sha256", package_tools_sha);
    fill_digest(digest, 'a'); set_table_value(&contract, "profile_sha256", digest);
    fill_digest(digest, 'b'); set_table_value(&contract, "recipe_sha256", digest);
    fill_digest(digest, 'c'); set_table_value(&contract, "policy_sha256", digest);
    fill_digest(digest, '7'); set_table_value(&contract, "signer_cert_sha256", digest);
    set_table_value(&contract, "target_abi", "armeabi-v7a");
    set_table_value(&contract, "ndk_packager_revision", "75d2c6b88443c9cf865c30146a06b89868a182c5");
    set_table_value(&contract, "ndk_receipt_schema_sha256", schema_sha);
    set_table_value(&contract, "witness_schema", "p01-stage-roles-v1");
    if (!append_path(path, sizeof(path), case_root, "/contract.tsv")) return 0;
    if (!write_table(path, &contract)) return 0;

#define WRITE_ATTEMPT(SIDE, ROOT, SOURCE, WORK, OUTPUT, WITNESS_SHA, CASES_SHA, IS_RIGHT) do { \
    table_from_fields(&attempt, attempt_fields, sizeof(attempt_fields) / sizeof(attempt_fields[0])); \
    set_table_value(&attempt, "schema", "aici-independent-build-attempt-v1"); \
    set_table_value(&attempt, "attempt_id", IS_RIGHT ? "attempt-b" : "attempt-a"); \
    set_table_value(&attempt, "source_root", SOURCE); \
    set_table_value(&attempt, "work_root", WORK); \
    set_table_value(&attempt, "output_root", OUTPUT); \
    set_table_value(&attempt, "timezone", IS_RIGHT && mutation != FIXTURE_SAME_TIMEZONE ? "Pacific/Kiritimati" : "UTC"); \
    set_table_value(&attempt, "input_order", IS_RIGHT ? "reverse" : "forward"); \
    set_table_value(&attempt, "input_modes", IS_RIGHT ? "files-0600-dirs-0700" : "files-0644-dirs-0755"); \
    set_table_value(&attempt, "consumer_repository", "isomorphismes/wegert"); \
    set_table_value(&attempt, "source_revision", "1111111111111111111111111111111111111111"); \
    fill_digest(digest, (IS_RIGHT && mutation == FIXTURE_HIDDEN_DEPENDENCY) ? 'd' : '5'); set_table_value(&attempt, "dependency_closure_sha256", digest); \
    fill_digest(digest, '6'); set_table_value(&attempt, "compiler_toolchain_sha256", digest); \
    fill_digest(digest, 'a'); set_table_value(&attempt, "profile_sha256", digest); \
    fill_digest(digest, 'b'); set_table_value(&attempt, "recipe_sha256", digest); \
    fill_digest(digest, (IS_RIGHT && mutation == FIXTURE_CHANGED_POLICY) ? 'd' : 'c'); set_table_value(&attempt, "policy_sha256", digest); \
    set_table_value(&attempt, "witness_schema", "p01-stage-roles-v1"); \
    set_table_value(&attempt, "witness_status", IS_RIGHT && mutation == FIXTURE_UNVERIFIED_WITNESS ? "not_verified" : "pass"); \
    set_table_value(&attempt, "witness_file", "witness.tsv"); \
    set_table_value(&attempt, "witness_sha256", WITNESS_SHA); \
    set_table_value(&attempt, "executed_cases_file", "cases.tsv"); \
    set_table_value(&attempt, "executed_cases_sha256", CASES_SHA); \
    set_table_value(&attempt, "ndk_packager_revision", IS_RIGHT && mutation == FIXTURE_WRONG_NDK ? "2222222222222222222222222222222222222222" : "75d2c6b88443c9cf865c30146a06b89868a182c5"); \
    set_table_value(&attempt, "package_receipt", "package.receipt.tsv"); \
    set_table_value(&attempt, "native_file", "native.so"); \
    set_table_value(&attempt, "signed_apk", "app.apk"); \
    if (!append_path(path, sizeof(path), case_root, IS_RIGHT ? "/right-attempt.tsv" : "/left-attempt.tsv")) return 0; \
    if (!write_table(path, &attempt)) return 0; \
} while (0)

    WRITE_ATTEMPT("left", left_base, left_source, left_work, left_output,
                  witness_left_sha, cases_left_sha, 0);
    WRITE_ATTEMPT("right", right_base, right_source, right_work, right_output,
                  witness_right_sha, cases_right_sha, 1);
#undef WRITE_ATTEMPT

    if (mutation == FIXTURE_SHARED_OUTPUT) {
        char left_native[PATH_MAX];
        char right_native[PATH_MAX];
        if (!append_path(left_native, sizeof(left_native), left_output, "/native.so") ||
            !append_path(right_native, sizeof(right_native), right_output, "/native.so")) return 0;
        if (unlink(right_native) != 0 || link(left_native, right_native) != 0) return 0;
    }
    return 1;
}

static int run_self_test(const char *schema_path, const char *work_root) {
    struct TestCase {
        const char *name;
        enum FixtureMutation mutation;
        int should_pass;
        const char *code;
    } cases[] = {
        {"equal-independent-builds", FIXTURE_GOOD, 1, ""},
        {"copied-first-output", FIXTURE_REUSED_WITNESS, 0, "REPRO-WITNESS-REUSED"},
        {"hidden-mutable-dependency", FIXTURE_HIDDEN_DEPENDENCY, 0, "REPRO-CONTRACT-MISMATCH"},
        {"wrong-inherited-ndk", FIXTURE_WRONG_NDK, 0, "REPRO-CONTRACT-MISMATCH"},
        {"omitted-stage", FIXTURE_OMITTED_STAGE, 0, "REPRO-NDK-RECEIPT"},
        {"unequal-promised-bytes", FIXTURE_UNEQUAL_SIGNED, 0, "REPRO-STAGE-DIFFERENCE"},
        {"shared-output-inode", FIXTURE_SHARED_OUTPUT, 0, "REPRO-OUTPUT-SHARED"},
        {"environment-not-varied", FIXTURE_SAME_TIMEZONE, 0, "REPRO-ENVIRONMENT-NOT-VARIED"},
        {"unverified-witness", FIXTURE_UNVERIFIED_WITNESS, 0, "REPRO-ATTEMPT"},
        {"changed-policy-stale-verdict", FIXTURE_CHANGED_POLICY, 0, "REPRO-CONTRACT-MISMATCH"},
        {"missing-executed-case", FIXTURE_MISSING_CASE, 0, "REPRO-CASES-DIFFER"}
    };
    size_t index;
    if (!make_directory(work_root)) {
        fprintf(stderr, "cannot create self-test root: %s\n", work_root);
        return 1;
    }
    for (index = 0; index < sizeof(cases) / sizeof(cases[0]); ++index) {
        char case_root[PATH_MAX];
        char contract[PATH_MAX];
        char left_attempt[PATH_MAX];
        char right_attempt[PATH_MAX];
        char left_output[PATH_MAX];
        char right_output[PATH_MAX];
        VerifyError error = {{0}, {0}};
        int passed;
        {
            char suffix[128];
            if (snprintf(suffix, sizeof(suffix), "/%s", cases[index].name) < 0 ||
                !append_path(case_root, sizeof(case_root), work_root, suffix)) return 1;
        }
        if (!make_fixture_case(schema_path, case_root, cases[index].mutation, &error)) {
            fprintf(stderr, "fixture generation failed for %s: %s %s\n",
                    cases[index].name, error.code, error.detail);
            return 1;
        }
        if (!append_path(contract, sizeof(contract), case_root, "/contract.tsv") ||
            !append_path(left_attempt, sizeof(left_attempt), case_root, "/left-attempt.tsv") ||
            !append_path(right_attempt, sizeof(right_attempt), case_root, "/right-attempt.tsv") ||
            !append_path(left_output, sizeof(left_output), case_root, "/left/output") ||
            !append_path(right_output, sizeof(right_output), case_root, "/right/output")) return 1;
        memset(&error, 0, sizeof(error));
        passed = verify_pair(contract, left_attempt, left_output, right_attempt,
                             right_output, schema_path, 0, &error);
        if ((cases[index].should_pass && !passed) ||
            (!cases[index].should_pass &&
             (passed || strcmp(error.code, cases[index].code) != 0))) {
            fprintf(stderr, "self-test %s failed: result=%s code=%s detail=%s\n",
                    cases[index].name, passed ? "PASS" : "FAIL", error.code, error.detail);
            return 1;
        }
        printf("CASE\t%s\tPASS\n", cases[index].name);
    }
    printf("AICI_REPRODUCIBILITY_SELF_TEST\tPASS\n");
    return 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s verify CONTRACT LEFT_ATTEMPT LEFT_OUTPUT_ROOT RIGHT_ATTEMPT RIGHT_OUTPUT_ROOT NDK_RECEIPT_SCHEMA\n"
            "  %s self-test NDK_RECEIPT_SCHEMA WORK_ROOT\n",
            program, program);
}

int main(int argc, char **argv) {
    if (argc == 8 && strcmp(argv[1], "verify") == 0) {
        VerifyError error = {{0}, {0}};
        if (verify_pair(argv[2], argv[3], argv[4], argv[5], argv[6], argv[7],
                        1, &error)) return 0;
        fprintf(stderr, "AICI_REPRODUCIBILITY_FAILURE\t%s\t%s\n",
                error.code, error.detail);
        return 1;
    }
    if (argc == 4 && strcmp(argv[1], "self-test") == 0) {
        return run_self_test(argv[2], argv[3]);
    }
    usage(argv[0]);
    return 2;
}
