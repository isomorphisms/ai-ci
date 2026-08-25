#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define PATH_MAXIMUM 4096
#define LINE_MAXIMUM (1024 * 1024)
#define FIELD_MAXIMUM 16
#define ROW_MAXIMUM 512
#define ARTIFACT_MAXIMUM 64
#define SAME_MAXIMUM 64
#define ABI_ORDER_MAXIMUM 32
#define ABI_ORDER_ITEMS 8
#define CODE_MAXIMUM 128
#define NAME_MAXIMUM 128
#define VALUE_MAXIMUM 512
#define CAPTURE_MAXIMUM (16 * 1024 * 1024)

typedef struct {
    int assertions;
    int failures;
    int quiet;
    char first_code[CODE_MAXIMUM];
} VerifyResult;

typedef enum {
    PROFILE_CANDIDATE,
    PROFILE_SUBMISSION,
    PROFILE_PUBLICATION
} Profile;

typedef enum {
    SIGNING_FDROID,
    SIGNING_UPSTREAM
} SigningMode;

typedef struct {
    char code[CODE_MAXIMUM];
    char name[NAME_MAXIMUM];
    char role[32];
    char package[VALUE_MAXIMUM];
    char version_name[VALUE_MAXIMUM];
    int version_code;
    char abis[VALUE_MAXIMUM];
} ArtifactRequirement;

typedef struct {
    char code[CODE_MAXIMUM];
    char left[NAME_MAXIMUM];
    char right[NAME_MAXIMUM];
} SameRequirement;

typedef struct {
    char code[CODE_MAXIMUM];
    int count;
    char artifacts[ABI_ORDER_ITEMS][NAME_MAXIMUM];
} AbiOrderRequirement;

typedef struct {
    char receipt_code[CODE_MAXIMUM];
    char release_code[CODE_MAXIMUM];
    char toolchain_code[CODE_MAXIMUM];
    char package[VALUE_MAXIMUM];
    char version_name[VALUE_MAXIMUM];
    int version_code;
    char source_revision[VALUE_MAXIMUM];
    char fdroiddata_revision[VALUE_MAXIMUM];
    char fdroidserver_revision[VALUE_MAXIMUM];
    char image_digest[VALUE_MAXIMUM];
    Profile profile;
    SigningMode signing;
    int native_code;
    int receipt_seen;
    int release_seen;
    int toolchain_seen;
    int profile_seen;
    int signing_seen;
    int native_seen;
    int artifact_count;
    int same_count;
    int abi_order_count;
    ArtifactRequirement artifacts[ARTIFACT_MAXIMUM];
    SameRequirement same[SAME_MAXIMUM];
    AbiOrderRequirement abi_orders[ABI_ORDER_MAXIMUM];
} Contract;

typedef struct {
    char kind[32];
    char name[NAME_MAXIMUM];
    char status[32];
    char source_revision[VALUE_MAXIMUM];
    char fdroiddata_revision[VALUE_MAXIMUM];
    char fdroidserver_revision[VALUE_MAXIMUM];
    char image_digest[VALUE_MAXIMUM];
    char package[VALUE_MAXIMUM];
    char version_name[VALUE_MAXIMUM];
    int version_code;
    char abis[VALUE_MAXIMUM];
    char witness[PATH_MAXIMUM];
    char sha256[65];
    int consumed;
} ReceiptRow;

typedef struct {
    int count;
    ReceiptRow rows[ROW_MAXIMUM];
} Receipt;

typedef struct {
    const char *name;
    const char *code;
} RequiredCheck;

static const RequiredCheck candidate_checks[] = {
    {"source-public", "FDROID-SOURCE-PUBLIC"},
    {"license-review", "FDROID-LICENSE-REVIEW"},
    {"dependency-review", "FDROID-DEPENDENCY-REVIEW"},
    {"tag-binding", "FDROID-TAG-BINDING"},
    {"version-history", "FDROID-VERSION-HISTORY"},
    {"metadata-read", "FDROID-METADATA-READ"},
    {"metadata-schema", "FDROID-METADATA-SCHEMA"},
    {"metadata-rewrite", "FDROID-METADATA-REWRITE"},
    {"metadata-lint", "FDROID-METADATA-LINT"},
    {"update-check", "FDROID-UPDATE-CHECK"},
    {"git-redirect", "FDROID-GIT-REDIRECT"},
    {"metadata-tools", "FDROID-METADATA-TOOLS"},
    {"fastlane", "FDROID-FASTLANE"},
    {"fdroid-build", "FDROID-BUILD"},
    {"gradle-audit", "FDROID-GRADLE-AUDIT"},
    {"build-input-pinning", "FDROID-BUILD-INPUT-PINNING"},
    {"source-scan", "FDROID-SOURCE-SCAN"},
    {"apk-scan", "FDROID-APK-SCAN"},
    {"apk-identity", "FDROID-APK-IDENTITY"},
    {"signing-policy", "FDROID-SIGNING-POLICY"},
    {"install-launch", "FDROID-INSTALL-LAUNCH"},
};

static const RequiredCheck submission_checks[] = {
    {"fdroiddata-pipeline", "FDROID-DATA-PIPELINE"},
    {"fdroiddata-review", "FDROID-DATA-REVIEW"},
};

static const RequiredCheck publication_checks[] = {
    {"published-index", "FDROID-PUBLISHED-INDEX"},
    {"published-install", "FDROID-PUBLISHED-INSTALL"},
};

static const RequiredCheck upstream_checks[] = {
    {"upstream-reproducible", "FDROID-UPSTREAM-REPRODUCIBLE"},
    {"signing-key", "FDROID-SIGNING-KEY"},
};

static int fixed_code(const char *code) {
    const RequiredCheck *groups[] = {
        candidate_checks, submission_checks, publication_checks, upstream_checks
    };
    const size_t counts[] = {
        sizeof(candidate_checks) / sizeof(candidate_checks[0]),
        sizeof(submission_checks) / sizeof(submission_checks[0]),
        sizeof(publication_checks) / sizeof(publication_checks[0]),
        sizeof(upstream_checks) / sizeof(upstream_checks[0]),
    };
    size_t group;
    if (strcmp(code, "AICI-FDROID-CONTRACT") == 0 ||
        strcmp(code, "FDROID-RECEIPT-EXTRA") == 0) return 1;
    for (group = 0; group < sizeof(groups) / sizeof(groups[0]); ++group) {
        size_t index;
        for (index = 0; index < counts[group]; ++index) {
            if (strcmp(code, groups[group][index].code) == 0) return 1;
        }
    }
    return 0;
}

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
        if (!(islower(*cursor) || isdigit(*cursor) || *cursor == '-')) return 0;
        ++cursor;
    }
    return 1;
}

static int valid_package(const char *package) {
    const unsigned char *cursor = (const unsigned char *)package;
    int component_start = 1;
    int dots = 0;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (*cursor == '.') {
            if (component_start) return 0;
            component_start = 1;
            ++dots;
        } else {
            if (component_start && !(isalpha(*cursor) || *cursor == '_')) return 0;
            if (!(isalnum(*cursor) || *cursor == '_')) return 0;
            component_start = 0;
        }
        ++cursor;
    }
    return !component_start && dots > 0;
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

static int pinned_image(const char *image) {
    const char *marker = strstr(image, "@sha256:");
    return marker != NULL && marker != image && strchr(marker + 1, '@') == NULL &&
           lower_hex(marker + strlen("@sha256:"), 64);
}

static int parse_positive_int(const char *text, int *value) {
    char *end = NULL;
    long parsed;
    errno = 0;
    parsed = strtol(text, &end, 10);
    if (errno != 0 || end == text || *end != '\0' || parsed < 1 || parsed > INT_MAX) {
        return 0;
    }
    *value = (int)parsed;
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
    if (!safe_relative_path(relative)) return 0;
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

static int run_status(char *const argv[]) {
    pid_t child = fork();
    if (child < 0) return 0;
    if (child == 0) {
        FILE *null_file = fopen("/dev/null", "w");
        if (null_file == NULL || dup2(fileno(null_file), STDOUT_FILENO) < 0 ||
            dup2(fileno(null_file), STDERR_FILENO) < 0) {
            _exit(126);
        }
        fclose(null_file);
        execvp(argv[0], argv);
        _exit(127);
    }
    return wait_success(child);
}

static int capture_command(char *const argv[], size_t maximum,
                           unsigned char **output, size_t *output_length) {
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
        unsigned char chunk[8192];
        ssize_t count = read(descriptors[0], chunk, sizeof(chunk));
        if (count == 0) break;
        if (count < 0) {
            if (errno == EINTR) continue;
            failed = 1;
            break;
        }
        if (length + (size_t)count > maximum) {
            failed = 1;
            break;
        }
        if (length + (size_t)count + 1 > capacity) {
            size_t next = capacity == 0 ? 16384 : capacity * 2;
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
    char *argv[] = {"sha256sum", "--", (char *)path, NULL};
    unsigned char *output = NULL;
    size_t length = 0;
    int ok;
    if (!capture_command(argv, 4096, &output, &length)) return 0;
    ok = length >= 65;
    if (ok) {
        memcpy(digest, output, 64);
        digest[64] = '\0';
        ok = lower_hex(digest, 64) && isspace(output[64]);
    }
    free(output);
    return ok;
}

static int abi_bit(const char *abi) {
    if (strcmp(abi, "armeabi-v7a") == 0) return 1;
    if (strcmp(abi, "arm64-v8a") == 0) return 2;
    if (strcmp(abi, "x86") == 0) return 4;
    if (strcmp(abi, "x86_64") == 0) return 8;
    return 0;
}

static int parse_abi_list(const char *text, int *mask) {
    char copy[VALUE_MAXIMUM];
    char *cursor;
    int observed = 0;
    if (strcmp(text, "none") == 0) {
        *mask = 0;
        return 1;
    }
    if (!copy_value(copy, sizeof(copy), text)) return 0;
    cursor = copy;
    while (cursor != NULL) {
        char *comma = strchr(cursor, ',');
        int bit;
        if (comma != NULL) *comma = '\0';
        bit = abi_bit(cursor);
        if (bit == 0 || (observed & bit) != 0) return 0;
        observed |= bit;
        cursor = comma == NULL ? NULL : comma + 1;
    }
    *mask = observed;
    return observed != 0;
}

static int apk_zip_matches(const char *path, const char *expected_abis) {
    char *test_argv[] = {"unzip", "-tqq", (char *)path, NULL};
    char *list_argv[] = {"unzip", "-Z1", (char *)path, NULL};
    unsigned char *listing = NULL;
    size_t listing_length = 0;
    char *line;
    char *save = NULL;
    int expected_mask;
    int actual_mask = 0;
    int manifest_seen = 0;
    int unknown_abi = 0;
    if (!parse_abi_list(expected_abis, &expected_mask)) return 0;
    if (!run_status(test_argv) ||
        !capture_command(list_argv, CAPTURE_MAXIMUM, &listing, &listing_length)) {
        return 0;
    }
    (void)listing_length;
    line = strtok_r((char *)listing, "\r\n", &save);
    while (line != NULL) {
        if (strcmp(line, "AndroidManifest.xml") == 0) manifest_seen = 1;
        if (strncmp(line, "lib/", 4) == 0) {
            char abi[64];
            const char *begin = line + 4;
            const char *slash = strchr(begin, '/');
            if (slash != NULL && slash[1] != '\0' &&
                (size_t)(slash - begin) < sizeof(abi)) {
                int bit;
                memcpy(abi, begin, (size_t)(slash - begin));
                abi[slash - begin] = '\0';
                bit = abi_bit(abi);
                if (bit == 0) unknown_abi = 1;
                actual_mask |= bit;
            }
        }
        line = strtok_r(NULL, "\r\n", &save);
    }
    free(listing);
    return manifest_seen && !unknown_abi && actual_mask == expected_mask;
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

static void emit_assertion(const char *status, const char *code,
                           const char *operation, const char *detail) {
    fputs("{\"kind\":\"fdroid-assertion\",\"status\":", stdout);
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
            copy_value(result->first_code, sizeof(result->first_code), code);
        }
    }
    if (!result->quiet) {
        emit_assertion(ok ? "pass" : "fail", code, operation, detail);
    }
}

static int code_already_used(const Contract *contract, const char *code) {
    int index;
    if ((contract->receipt_seen && strcmp(contract->receipt_code, code) == 0) ||
        (contract->release_seen && strcmp(contract->release_code, code) == 0) ||
        (contract->toolchain_seen && strcmp(contract->toolchain_code, code) == 0)) {
        return 1;
    }
    for (index = 0; index < contract->artifact_count; ++index) {
        if (strcmp(contract->artifacts[index].code, code) == 0) return 1;
    }
    for (index = 0; index < contract->same_count; ++index) {
        if (strcmp(contract->same[index].code, code) == 0) return 1;
    }
    for (index = 0; index < contract->abi_order_count; ++index) {
        if (strcmp(contract->abi_orders[index].code, code) == 0) return 1;
    }
    return 0;
}

static int artifact_name_used(const Contract *contract, const char *name) {
    int index;
    for (index = 0; index < contract->artifact_count; ++index) {
        if (strcmp(contract->artifacts[index].name, name) == 0) return 1;
    }
    return 0;
}

static int same_artifact_coordinates(const ArtifactRequirement *left,
                                     const ArtifactRequirement *right) {
    return strcmp(left->package, right->package) == 0 &&
           strcmp(left->version_name, right->version_name) == 0 &&
           left->version_code == right->version_code &&
           strcmp(left->abis, right->abis) == 0;
}

static int parse_contract(const char *path, Contract *contract) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int line_number = 0;
    int ok = 1;
    memset(contract, 0, sizeof(*contract));
    if (file == NULL) return 0;
    while (ok && (length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *fields[FIELD_MAXIMUM];
        int count;
        ++line_number;
        if (length > LINE_MAXIMUM || memchr(line, '\0', (size_t)length) != NULL) {
            ok = 0;
            break;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, FIELD_MAXIMUM);
        if (count < 0) {
            ok = 0;
            break;
        }
        if (strcmp(fields[0], "receipt") == 0 && count == 2 &&
            !contract->receipt_seen && valid_code(fields[1]) && !fixed_code(fields[1]) &&
            !code_already_used(contract, fields[1])) {
            contract->receipt_seen = copy_value(contract->receipt_code,
                                                sizeof(contract->receipt_code), fields[1]);
        } else if (strcmp(fields[0], "release") == 0 && count == 6 &&
                   !contract->release_seen && valid_code(fields[1]) && !fixed_code(fields[1]) &&
                   !code_already_used(contract, fields[1]) && valid_package(fields[2]) &&
                   fields[3][0] != '\0' && parse_positive_int(fields[4], &contract->version_code) &&
                   full_revision(fields[5])) {
            contract->release_seen =
                copy_value(contract->release_code, sizeof(contract->release_code), fields[1]) &&
                copy_value(contract->package, sizeof(contract->package), fields[2]) &&
                copy_value(contract->version_name, sizeof(contract->version_name), fields[3]) &&
                copy_value(contract->source_revision, sizeof(contract->source_revision), fields[5]);
        } else if (strcmp(fields[0], "toolchain") == 0 && count == 5 &&
                   !contract->toolchain_seen && valid_code(fields[1]) && !fixed_code(fields[1]) &&
                   !code_already_used(contract, fields[1]) && full_revision(fields[2]) &&
                   full_revision(fields[3]) && pinned_image(fields[4])) {
            contract->toolchain_seen =
                copy_value(contract->toolchain_code, sizeof(contract->toolchain_code), fields[1]) &&
                copy_value(contract->fdroiddata_revision,
                           sizeof(contract->fdroiddata_revision), fields[2]) &&
                copy_value(contract->fdroidserver_revision,
                           sizeof(contract->fdroidserver_revision), fields[3]) &&
                copy_value(contract->image_digest, sizeof(contract->image_digest), fields[4]);
        } else if (strcmp(fields[0], "profile") == 0 && count == 2 &&
                   !contract->profile_seen) {
            contract->profile_seen = 1;
            if (strcmp(fields[1], "candidate-v1") == 0) contract->profile = PROFILE_CANDIDATE;
            else if (strcmp(fields[1], "submission-v1") == 0) contract->profile = PROFILE_SUBMISSION;
            else if (strcmp(fields[1], "publication-v1") == 0) contract->profile = PROFILE_PUBLICATION;
            else ok = 0;
        } else if (strcmp(fields[0], "signing") == 0 && count == 2 &&
                   !contract->signing_seen) {
            contract->signing_seen = 1;
            if (strcmp(fields[1], "fdroid") == 0) contract->signing = SIGNING_FDROID;
            else if (strcmp(fields[1], "upstream") == 0) contract->signing = SIGNING_UPSTREAM;
            else ok = 0;
        } else if (strcmp(fields[0], "native") == 0 && count == 2 &&
                   !contract->native_seen) {
            contract->native_seen = 1;
            if (strcmp(fields[1], "yes") == 0) contract->native_code = 1;
            else if (strcmp(fields[1], "no") == 0) contract->native_code = 0;
            else ok = 0;
        } else if (strcmp(fields[0], "artifact") == 0 && count == 8 &&
                   contract->artifact_count < ARTIFACT_MAXIMUM && valid_code(fields[1]) &&
                   !fixed_code(fields[1]) &&
                   !code_already_used(contract, fields[1]) && valid_name(fields[2]) &&
                   !artifact_name_used(contract, fields[2]) &&
                   (strcmp(fields[3], "rebuild") == 0 || strcmp(fields[3], "upstream") == 0) &&
                   valid_package(fields[4]) && fields[5][0] != '\0') {
            ArtifactRequirement *artifact = &contract->artifacts[contract->artifact_count];
            int abi_mask;
            ok = parse_positive_int(fields[6], &artifact->version_code) &&
                 parse_abi_list(fields[7], &abi_mask) &&
                 copy_value(artifact->code, sizeof(artifact->code), fields[1]) &&
                 copy_value(artifact->name, sizeof(artifact->name), fields[2]) &&
                 copy_value(artifact->role, sizeof(artifact->role), fields[3]) &&
                 copy_value(artifact->package, sizeof(artifact->package), fields[4]) &&
                 copy_value(artifact->version_name, sizeof(artifact->version_name), fields[5]) &&
                 copy_value(artifact->abis, sizeof(artifact->abis), fields[7]);
            if (ok) ++contract->artifact_count;
        } else if (strcmp(fields[0], "same_artifact") == 0 && count == 4 &&
                   contract->same_count < SAME_MAXIMUM && valid_code(fields[1]) &&
                   !fixed_code(fields[1]) &&
                   !code_already_used(contract, fields[1]) && valid_name(fields[2]) &&
                   valid_name(fields[3])) {
            SameRequirement *same = &contract->same[contract->same_count++];
            ok = copy_value(same->code, sizeof(same->code), fields[1]) &&
                 copy_value(same->left, sizeof(same->left), fields[2]) &&
                 copy_value(same->right, sizeof(same->right), fields[3]);
        } else if (strcmp(fields[0], "abi_order") == 0 && count >= 4 &&
                   count <= ABI_ORDER_ITEMS + 2 &&
                   contract->abi_order_count < ABI_ORDER_MAXIMUM && valid_code(fields[1]) &&
                   !fixed_code(fields[1]) &&
                   !code_already_used(contract, fields[1])) {
            AbiOrderRequirement *order = &contract->abi_orders[contract->abi_order_count++];
            int field;
            order->count = count - 2;
            ok = copy_value(order->code, sizeof(order->code), fields[1]);
            for (field = 2; ok && field < count; ++field) {
                ok = valid_name(fields[field]) &&
                     copy_value(order->artifacts[field - 2],
                                sizeof(order->artifacts[field - 2]), fields[field]);
            }
        } else {
            ok = 0;
        }
        if (!ok) fprintf(stderr, "invalid F-Droid contract line %d\n", line_number);
    }
    if (ferror(file)) ok = 0;
    free(line);
    if (fclose(file) != 0) ok = 0;
    if (!ok || !contract->receipt_seen || !contract->release_seen ||
        !contract->toolchain_seen || !contract->profile_seen ||
        !contract->signing_seen || !contract->native_seen ||
        contract->artifact_count < 2 || contract->same_count < 1) {
        return 0;
    }
    {
        int index;
        int rebuilds = 0;
        int upstream = 0;
        int release_version_seen = 0;
        for (index = 0; index < contract->artifact_count; ++index) {
            int mask;
            ArtifactRequirement *artifact = &contract->artifacts[index];
            parse_abi_list(artifact->abis, &mask);
            if ((contract->native_code && mask == 0) || (!contract->native_code && mask != 0) ||
                strcmp(artifact->package, contract->package) != 0 ||
                strcmp(artifact->version_name, contract->version_name) != 0 ||
                artifact->version_code > contract->version_code) return 0;
            if (strcmp(artifact->role, "rebuild") == 0) {
                ++rebuilds;
                if (artifact->version_code == contract->version_code) {
                    release_version_seen = 1;
                }
            }
            else ++upstream;
        }
        if (rebuilds < 2 || !release_version_seen ||
            (contract->signing == SIGNING_UPSTREAM && upstream < 1) ||
            (contract->signing == SIGNING_FDROID && upstream != 0)) {
            return 0;
        }
        if (contract->signing == SIGNING_UPSTREAM) {
            for (index = 0; index < contract->artifact_count; ++index) {
                int candidate;
                int match = 0;
                ArtifactRequirement *artifact = &contract->artifacts[index];
                const char *wanted_role = strcmp(artifact->role, "rebuild") == 0
                                              ? "upstream" : "rebuild";
                for (candidate = 0; candidate < contract->artifact_count; ++candidate) {
                    ArtifactRequirement *other = &contract->artifacts[candidate];
                    if (strcmp(other->role, wanted_role) == 0 &&
                        same_artifact_coordinates(artifact, other)) {
                        match = 1;
                    }
                }
                if (!match) return 0;
            }
        }
        for (index = 0; index < contract->same_count; ++index) {
            ArtifactRequirement *left;
            ArtifactRequirement *right;
            if (strcmp(contract->same[index].left, contract->same[index].right) == 0 ||
                !artifact_name_used(contract, contract->same[index].left) ||
                !artifact_name_used(contract, contract->same[index].right)) return 0;
            left = NULL;
            right = NULL;
            {
                int artifact_index;
                for (artifact_index = 0; artifact_index < contract->artifact_count;
                     ++artifact_index) {
                    if (strcmp(contract->artifacts[artifact_index].name,
                               contract->same[index].left) == 0) {
                        left = &contract->artifacts[artifact_index];
                    }
                    if (strcmp(contract->artifacts[artifact_index].name,
                               contract->same[index].right) == 0) {
                        right = &contract->artifacts[artifact_index];
                    }
                }
            }
            if (left == NULL || right == NULL ||
                strcmp(left->role, "rebuild") != 0 ||
                strcmp(right->role, "rebuild") != 0 ||
                !same_artifact_coordinates(left, right)) return 0;
        }
        for (index = 0; index < contract->artifact_count; ++index) {
            int pair;
            int paired = strcmp(contract->artifacts[index].role, "upstream") == 0;
            for (pair = 0; !paired && pair < contract->same_count; ++pair) {
                paired = strcmp(contract->artifacts[index].name,
                                contract->same[pair].left) == 0 ||
                         strcmp(contract->artifacts[index].name,
                                contract->same[pair].right) == 0;
            }
            if (!paired) return 0;
        }
        for (index = 0; index < contract->abi_order_count; ++index) {
            int item;
            int previous_abi = 0;
            for (item = 0; item < contract->abi_orders[index].count; ++item) {
                ArtifactRequirement *artifact = NULL;
                int artifact_index;
                int abi_mask;
                int previous_item;
                for (artifact_index = 0; artifact_index < contract->artifact_count;
                     ++artifact_index) {
                    if (strcmp(contract->artifacts[artifact_index].name,
                               contract->abi_orders[index].artifacts[item]) == 0) {
                        artifact = &contract->artifacts[artifact_index];
                    }
                }
                if (artifact == NULL || strcmp(artifact->role, "rebuild") != 0 ||
                    !parse_abi_list(artifact->abis, &abi_mask) ||
                    (abi_mask & (abi_mask - 1)) != 0 || abi_mask <= previous_abi) return 0;
                previous_abi = abi_mask;
                for (previous_item = 0; previous_item < item; ++previous_item) {
                    if (strcmp(contract->abi_orders[index].artifacts[previous_item],
                               contract->abi_orders[index].artifacts[item]) == 0) return 0;
                }
            }
        }
        {
            int split_abis = 0;
            int split_count = 0;
            int order_covers_splits = 0;
            for (index = 0; index < contract->artifact_count; ++index) {
                int abi_mask;
                ArtifactRequirement *artifact = &contract->artifacts[index];
                if (strcmp(artifact->role, "rebuild") != 0 ||
                    !parse_abi_list(artifact->abis, &abi_mask) ||
                    abi_mask == 0 || (abi_mask & (abi_mask - 1)) != 0) continue;
                split_abis |= abi_mask;
            }
            {
                int mask = split_abis;
                while (mask != 0) {
                    split_count += mask & 1;
                    mask >>= 1;
                }
            }
            if (split_count > 1) {
                int order_index;
                for (order_index = 0; order_index < contract->abi_order_count;
                     ++order_index) {
                    int item;
                    int order_mask = 0;
                    for (item = 0; item < contract->abi_orders[order_index].count; ++item) {
                        ArtifactRequirement *artifact = NULL;
                        int artifact_index;
                        int abi_mask;
                        for (artifact_index = 0; artifact_index < contract->artifact_count;
                             ++artifact_index) {
                            if (strcmp(contract->artifacts[artifact_index].name,
                                       contract->abi_orders[order_index].artifacts[item]) == 0) {
                                artifact = &contract->artifacts[artifact_index];
                            }
                        }
                        if (artifact != NULL && parse_abi_list(artifact->abis, &abi_mask)) {
                            order_mask |= abi_mask;
                        }
                    }
                    if (order_mask == split_abis &&
                        contract->abi_orders[order_index].count == split_count) {
                        order_covers_splits = 1;
                    }
                }
                if (!order_covers_splits) return 0;
            }
        }
    }
    return 1;
}

static int exact_receipt_header(char *line) {
    static const char *expected[] = {
        "kind", "name", "status", "source_revision", "fdroiddata_revision",
        "fdroidserver_revision", "image_digest", "package", "version_name",
        "version_code", "abis", "witness", "sha256"
    };
    char *fields[FIELD_MAXIMUM];
    int count = split_tabs(line, fields, FIELD_MAXIMUM);
    int index;
    if (count != 13) return 0;
    for (index = 0; index < count; ++index) {
        if (strcmp(fields[index], expected[index]) != 0) return 0;
    }
    return 1;
}

static int read_receipt(const char *path, Receipt *receipt) {
    FILE *file = fopen(path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int header_seen = 0;
    int ok = 1;
    memset(receipt, 0, sizeof(*receipt));
    if (file == NULL) return 0;
    while (ok && (length = getline(&line, &capacity, file)) >= 0) {
        char *content;
        char *fields[FIELD_MAXIMUM];
        int count;
        ReceiptRow *row;
        int index;
        if (length > LINE_MAXIMUM || memchr(line, '\0', (size_t)length) != NULL) {
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
        if (count != 13 || receipt->count >= ROW_MAXIMUM ||
            !(strcmp(fields[0], "release") == 0 || strcmp(fields[0], "toolchain") == 0 ||
              strcmp(fields[0], "check") == 0 || strcmp(fields[0], "artifact") == 0) ||
            !valid_name(fields[1]) ||
            !(strcmp(fields[2], "pass") == 0 || strcmp(fields[2], "fail") == 0 ||
              strcmp(fields[2], "not-verified") == 0) ||
            !parse_positive_int(fields[9], &index) || !safe_relative_path(fields[11]) ||
            !lower_hex(fields[12], 64)) {
            ok = 0;
            break;
        }
        for (index = 0; index < receipt->count; ++index) {
            if (strcmp(receipt->rows[index].kind, fields[0]) == 0 &&
                strcmp(receipt->rows[index].name, fields[1]) == 0) {
                ok = 0;
                break;
            }
        }
        if (!ok) break;
        row = &receipt->rows[receipt->count];
        ok = copy_value(row->kind, sizeof(row->kind), fields[0]) &&
             copy_value(row->name, sizeof(row->name), fields[1]) &&
             copy_value(row->status, sizeof(row->status), fields[2]) &&
             copy_value(row->source_revision, sizeof(row->source_revision), fields[3]) &&
             copy_value(row->fdroiddata_revision, sizeof(row->fdroiddata_revision), fields[4]) &&
             copy_value(row->fdroidserver_revision, sizeof(row->fdroidserver_revision), fields[5]) &&
             copy_value(row->image_digest, sizeof(row->image_digest), fields[6]) &&
             copy_value(row->package, sizeof(row->package), fields[7]) &&
             copy_value(row->version_name, sizeof(row->version_name), fields[8]) &&
             parse_positive_int(fields[9], &row->version_code) &&
             copy_value(row->abis, sizeof(row->abis), fields[10]) &&
             copy_value(row->witness, sizeof(row->witness), fields[11]) &&
             copy_value(row->sha256, sizeof(row->sha256), fields[12]);
        if (ok) ++receipt->count;
    }
    if (ferror(file)) ok = 0;
    free(line);
    if (fclose(file) != 0) ok = 0;
    return ok && header_seen && receipt->count > 0;
}

static ReceiptRow *find_row(Receipt *receipt, const char *kind, const char *name) {
    int index;
    for (index = 0; index < receipt->count; ++index) {
        if (strcmp(receipt->rows[index].kind, kind) == 0 &&
            strcmp(receipt->rows[index].name, name) == 0) {
            return &receipt->rows[index];
        }
    }
    return NULL;
}

static int witness_matches(ReceiptRow *row, const char *root) {
    char path[PATH_MAXIMUM];
    char observed[65];
    if (!join_path(path, sizeof(path), root, row->witness) ||
        !regular_nonempty_file(path) || !sha256_file(path, observed)) {
        return 0;
    }
    return strcmp(observed, row->sha256) == 0;
}

static int common_row_matches(ReceiptRow *row, const Contract *contract,
                              const char *package, const char *version_name,
                              int version_code, const char *abis,
                              int toolchain_required, const char *root) {
    if (row == NULL || strcmp(row->status, "pass") != 0 ||
        strcmp(row->source_revision, contract->source_revision) != 0 ||
        strcmp(row->package, package) != 0 ||
        strcmp(row->version_name, version_name) != 0 ||
        row->version_code != version_code || strcmp(row->abis, abis) != 0) {
        return 0;
    }
    if (toolchain_required) {
        if (strcmp(row->fdroiddata_revision, contract->fdroiddata_revision) != 0 ||
            strcmp(row->fdroidserver_revision, contract->fdroidserver_revision) != 0 ||
            strcmp(row->image_digest, contract->image_digest) != 0) return 0;
    } else if (strcmp(row->fdroiddata_revision, "-") != 0 ||
               strcmp(row->fdroidserver_revision, "-") != 0 ||
               strcmp(row->image_digest, "-") != 0) {
        return 0;
    }
    if (!witness_matches(row, root)) return 0;
    row->consumed = 1;
    return 1;
}

static void verify_required_checks(VerifyResult *result, Receipt *receipt,
                                   const Contract *contract, const char *root,
                                   const RequiredCheck *checks, size_t count) {
    size_t index;
    for (index = 0; index < count; ++index) {
        ReceiptRow *row = find_row(receipt, "check", checks[index].name);
        int ok = common_row_matches(row, contract, contract->package,
                                    contract->version_name, contract->version_code,
                                    "-", 1, root);
        record_result(result, ok, checks[index].code, "required-check", checks[index].name);
    }
}

static ArtifactRequirement *find_artifact_requirement(Contract *contract,
                                                       const char *name) {
    int index;
    for (index = 0; index < contract->artifact_count; ++index) {
        if (strcmp(contract->artifacts[index].name, name) == 0) {
            return &contract->artifacts[index];
        }
    }
    return NULL;
}

static int artifact_receipt_ok(ReceiptRow *row, const ArtifactRequirement *artifact,
                               const Contract *contract, const char *root) {
    char path[PATH_MAXIMUM];
    if (!common_row_matches(row, contract, artifact->package, artifact->version_name,
                            artifact->version_code, artifact->abis, 1, root)) return 0;
    if (!join_path(path, sizeof(path), root, row->witness)) return 0;
    return apk_zip_matches(path, artifact->abis);
}

static int verify_files(const char *contract_path, const char *receipt_path,
                        const char *root, VerifyResult *result) {
    Contract contract;
    Receipt receipt;
    ReceiptRow *row;
    int index;
    int quiet = result->quiet;
    memset(result, 0, sizeof(*result));
    result->quiet = quiet;
    if (!parse_contract(contract_path, &contract)) {
        record_result(result, 0, "AICI-FDROID-CONTRACT", "contract",
                      "contract is unreadable, malformed, or internally inconsistent");
        return 0;
    }
    if (!read_receipt(receipt_path, &receipt)) {
        record_result(result, 0, contract.receipt_code, "receipt", "receipt is unreadable or malformed");
        return 0;
    }
    record_result(result, 1, contract.receipt_code, "receipt", "receipt structure is exact");

    row = find_row(&receipt, "release", "identity");
    record_result(result,
                  common_row_matches(row, &contract, contract.package,
                                     contract.version_name, contract.version_code,
                                     "-", 0, root),
                  contract.release_code, "release", "release identity and source revision");

    row = find_row(&receipt, "toolchain", "buildserver");
    record_result(result,
                  common_row_matches(row, &contract, contract.package,
                                     contract.version_name, contract.version_code,
                                     "-", 1, root),
                  contract.toolchain_code, "toolchain", "pinned F-Droid inputs");

    verify_required_checks(result, &receipt, &contract, root, candidate_checks,
                           sizeof(candidate_checks) / sizeof(candidate_checks[0]));
    if (contract.profile >= PROFILE_SUBMISSION) {
        verify_required_checks(result, &receipt, &contract, root, submission_checks,
                               sizeof(submission_checks) / sizeof(submission_checks[0]));
    }
    if (contract.profile >= PROFILE_PUBLICATION) {
        verify_required_checks(result, &receipt, &contract, root, publication_checks,
                               sizeof(publication_checks) / sizeof(publication_checks[0]));
    }
    if (contract.signing == SIGNING_UPSTREAM) {
        verify_required_checks(result, &receipt, &contract, root, upstream_checks,
                               sizeof(upstream_checks) / sizeof(upstream_checks[0]));
    }

    for (index = 0; index < contract.artifact_count; ++index) {
        ArtifactRequirement *artifact = &contract.artifacts[index];
        row = find_row(&receipt, "artifact", artifact->name);
        record_result(result, artifact_receipt_ok(row, artifact, &contract, root),
                      artifact->code, "artifact", artifact->name);
    }

    for (index = 0; index < contract.same_count; ++index) {
        SameRequirement *same = &contract.same[index];
        ReceiptRow *left = find_row(&receipt, "artifact", same->left);
        ReceiptRow *right = find_row(&receipt, "artifact", same->right);
        ArtifactRequirement *left_requirement = find_artifact_requirement(&contract, same->left);
        ArtifactRequirement *right_requirement = find_artifact_requirement(&contract, same->right);
        int ok = left != NULL && right != NULL && left_requirement != NULL &&
                 right_requirement != NULL && strcmp(left_requirement->role, "rebuild") == 0 &&
                 strcmp(right_requirement->role, "rebuild") == 0 &&
                 strcmp(left->sha256, right->sha256) == 0;
        record_result(result, ok, same->code, "same-artifact", same->left);
    }

    for (index = 0; index < contract.abi_order_count; ++index) {
        AbiOrderRequirement *order = &contract.abi_orders[index];
        int item;
        int previous = 0;
        int ok = 1;
        for (item = 0; ok && item < order->count; ++item) {
            ReceiptRow *artifact_row = find_row(&receipt, "artifact", order->artifacts[item]);
            if (artifact_row == NULL || artifact_row->version_code <= previous) ok = 0;
            else previous = artifact_row->version_code;
        }
        record_result(result, ok, order->code, "abi-order", order->artifacts[0]);
    }

    {
        int extras = 0;
        for (index = 0; index < receipt.count; ++index) {
            if (!receipt.rows[index].consumed) ++extras;
        }
        record_result(result, extras == 0, "FDROID-RECEIPT-EXTRA",
                      "receipt-closure", extras == 0 ? "no undeclared evidence rows" :
                      "receipt contains undeclared or unused rows");
    }

    if (!result->quiet) {
        printf("{\"kind\":\"fdroid-summary\",\"status\":\"%s\","
               "\"assertions\":%d,\"failures\":%d}\n",
               result->failures == 0 ? "pass" : "fail",
               result->assertions, result->failures);
    }
    return result->failures == 0;
}

typedef struct CodeNode {
    char code[CODE_MAXIMUM];
    struct CodeNode *next;
} CodeNode;

static int code_in_list(CodeNode *list, const char *code) {
    while (list != NULL) {
        if (strcmp(list->code, code) == 0) return 1;
        list = list->next;
    }
    return 0;
}

static int add_code(CodeNode **list, const char *code) {
    CodeNode *node;
    if (code_in_list(*list, code)) return 1;
    node = calloc(1, sizeof(*node));
    if (node == NULL || !copy_value(node->code, sizeof(node->code), code)) {
        free(node);
        return 0;
    }
    node->next = *list;
    *list = node;
    return 1;
}

static void free_codes(CodeNode *list) {
    while (list != NULL) {
        CodeNode *next = list->next;
        free(list);
        list = next;
    }
}

static int add_contract_codes(CodeNode **codes, const Contract *contract) {
    int index;
    size_t check;
    if (!add_code(codes, contract->receipt_code) ||
        !add_code(codes, contract->release_code) ||
        !add_code(codes, contract->toolchain_code) ||
        !add_code(codes, "FDROID-RECEIPT-EXTRA")) return 0;
    for (check = 0; check < sizeof(candidate_checks) / sizeof(candidate_checks[0]); ++check) {
        if (!add_code(codes, candidate_checks[check].code)) return 0;
    }
    if (contract->profile >= PROFILE_SUBMISSION) {
        for (check = 0; check < sizeof(submission_checks) / sizeof(submission_checks[0]); ++check) {
            if (!add_code(codes, submission_checks[check].code)) return 0;
        }
    }
    if (contract->profile >= PROFILE_PUBLICATION) {
        for (check = 0; check < sizeof(publication_checks) / sizeof(publication_checks[0]); ++check) {
            if (!add_code(codes, publication_checks[check].code)) return 0;
        }
    }
    if (contract->signing == SIGNING_UPSTREAM) {
        for (check = 0; check < sizeof(upstream_checks) / sizeof(upstream_checks[0]); ++check) {
            if (!add_code(codes, upstream_checks[check].code)) return 0;
        }
    }
    for (index = 0; index < contract->artifact_count; ++index) {
        if (!add_code(codes, contract->artifacts[index].code)) return 0;
    }
    for (index = 0; index < contract->same_count; ++index) {
        if (!add_code(codes, contract->same[index].code)) return 0;
    }
    for (index = 0; index < contract->abi_order_count; ++index) {
        if (!add_code(codes, contract->abi_orders[index].code)) return 0;
    }
    return 1;
}

static int self_test(const char *cases_path) {
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
    if (!add_code(&required_codes, "AICI-FDROID-CONTRACT")) {
        fclose(file);
        return 0;
    }
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[5];
        char *content;
        int count;
        int expected_pass;
        int actual_pass;
        int case_ok;
        int contract_ok;
        VerifyResult result;
        Contract contract;
        if (length > LINE_MAXIMUM) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, 5);
        if (count != 5 ||
            (strcmp(fields[0], "pass") != 0 && strcmp(fields[0], "fail") != 0)) {
            ++failures;
            continue;
        }
        expected_pass = strcmp(fields[0], "pass") == 0;
        if ((expected_pass && strcmp(fields[4], "-") != 0) ||
            (!expected_pass && !valid_code(fields[4]))) {
            ++failures;
            continue;
        }
        contract_ok = parse_contract(fields[1], &contract);
        if (contract_ok) {
            if (!add_contract_codes(&required_codes, &contract)) {
                ++failures;
                continue;
            }
        } else if (expected_pass || strcmp(fields[4], "AICI-FDROID-CONTRACT") != 0) {
            ++failures;
            continue;
        }
        memset(&result, 0, sizeof(result));
        result.quiet = 1;
        actual_pass = verify_files(fields[1], fields[2], fields[3], &result);
        case_ok = expected_pass ? actual_pass :
                  (!actual_pass && strcmp(result.first_code, fields[4]) == 0);
        if (expected_pass) ++positive_cases;
        else if (!add_code(&negative_codes, fields[4])) case_ok = 0;
        if (!case_ok) ++failures;
        ++cases;
        printf("{\"kind\":\"fdroid-self-test\",\"status\":\"%s\","
               "\"receipt\":", case_ok ? "pass" : "fail");
        json_string(fields[2]);
        fputs(",\"expected\":", stdout);
        json_string(fields[0]);
        fputs(",\"observedCode\":", stdout);
        json_string(result.first_code[0] == '\0' ? "-" : result.first_code);
        fputs("}\n", stdout);
    }
    if (ferror(file)) ++failures;
    free(line);
    if (fclose(file) != 0) ++failures;
    if (cases == 0 || positive_cases == 0) ++failures;
    {
        CodeNode *node = required_codes;
        while (node != NULL) {
            if (!code_in_list(negative_codes, node->code)) {
                ++failures;
                printf("{\"kind\":\"fdroid-self-test-coverage\",\"status\":\"fail\","
                       "\"missingDiagnostic\":");
                json_string(node->code);
                fputs("}\n", stdout);
            }
            node = node->next;
        }
    }
    printf("{\"kind\":\"fdroid-self-test-summary\",\"status\":\"%s\","
           "\"cases\":%d,\"failures\":%d}\n",
           failures == 0 ? "pass" : "fail", cases, failures);
    free_codes(required_codes);
    free_codes(negative_codes);
    return failures == 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s verify CONTRACT RECEIPT ARTIFACT_ROOT\n"
            "  %s self-test CASES\n",
            program, program);
}

int main(int argc, char **argv) {
    if (argc == 5 && strcmp(argv[1], "verify") == 0) {
        VerifyResult result = {0};
        return verify_files(argv[2], argv[3], argv[4], &result) ? 0 : 1;
    }
    if (argc == 3 && strcmp(argv[1], "self-test") == 0) {
        return self_test(argv[2]) ? 0 : 1;
    }
    usage(argv[0]);
    return 2;
}
