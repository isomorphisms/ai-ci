#define _XOPEN_SOURCE 700

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define PATH_MAXIMUM 4096
#define CHECK_COUNT 26
#define CANDIDATE_CHECK_COUNT 20

static const char *source_revision = "1111111111111111111111111111111111111111";
static const char *fdroiddata_revision = "4498e27635a1c3b737510342c1f2355c25ce0211";
static const char *fdroidserver_revision = "6af4c4216e43d0fcb29e33919cd0fe8fef7e7400";
static const char *image_digest =
    "registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie@sha256:"
    "9bae53bb4ddbf8fa5bb7385bf2e62e7c6318f99ab0d25b2a551ad38abb528068";
static const char *package_name = "org.example.game";
static const char *version_name = "1.0.0";
static const int version_code = 100;
static const char *abis = "armeabi-v7a,arm64-v8a,x86_64";

typedef struct {
    const char *name;
    const char *code;
} Check;

static const Check checks[CHECK_COUNT] = {
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
    {"source-scan", "FDROID-SOURCE-SCAN"},
    {"apk-scan", "FDROID-APK-SCAN"},
    {"apk-identity", "FDROID-APK-IDENTITY"},
    {"signing-policy", "FDROID-SIGNING-POLICY"},
    {"install-launch", "FDROID-INSTALL-LAUNCH"},
    {"upstream-reproducible", "FDROID-UPSTREAM-REPRODUCIBLE"},
    {"signing-key", "FDROID-SIGNING-KEY"},
    {"fdroiddata-pipeline", "FDROID-DATA-PIPELINE"},
    {"fdroiddata-review", "FDROID-DATA-REVIEW"},
    {"published-index", "FDROID-PUBLISHED-INDEX"},
    {"published-install", "FDROID-PUBLISHED-INSTALL"},
};

typedef enum {
    MUTATION_NONE,
    MUTATION_MALFORMED_RECEIPT,
    MUTATION_RELEASE,
    MUTATION_TOOLCHAIN,
    MUTATION_ARTIFACT_ONE,
    MUTATION_ARTIFACT_TWO,
    MUTATION_UPSTREAM_ARTIFACT,
    MUTATION_DIFFERENT_REBUILD,
    MUTATION_EXTRA_ROW,
    MUTATION_CHECK_BASE = 100
} Mutation;

typedef enum {
    SPLIT_NONE,
    SPLIT_ARMV7_ONE,
    SPLIT_ARMV7_TWO,
    SPLIT_ARM64_ONE,
    SPLIT_ARM64_TWO,
    SPLIT_ARMV7_DIFFERENT,
    SPLIT_ARM64_DIFFERENT
} SplitMutation;

static int path_join(char *output, size_t size, const char *left,
                     const char *right) {
    int written = snprintf(output, size, "%s/%s", left, right);
    return written >= 0 && (size_t)written < size;
}

static int make_directory(const char *path) {
    char copy[PATH_MAXIMUM];
    char *cursor;
    if (snprintf(copy, sizeof(copy), "%s", path) < 0 || strlen(path) >= sizeof(copy)) {
        return 0;
    }
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
    FILE *file = fopen(path, "w");
    size_t length = strlen(text);
    int ok;
    if (file == NULL) return 0;
    ok = fwrite(text, 1, length, file) == length;
    if (fclose(file) != 0) ok = 0;
    return ok;
}

static int append_text(const char *path, const char *text) {
    FILE *file = fopen(path, "a");
    size_t length = strlen(text);
    int ok;
    if (file == NULL) return 0;
    ok = fwrite(text, 1, length, file) == length;
    if (fclose(file) != 0) ok = 0;
    return ok;
}

static int copy_file(const char *source, const char *destination) {
    int input = open(source, O_RDONLY);
    int output;
    int ok = 1;
    if (input < 0) return 0;
    output = open(destination, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (output < 0) {
        close(input);
        return 0;
    }
    while (1) {
        unsigned char buffer[8192];
        ssize_t count = read(input, buffer, sizeof(buffer));
        ssize_t written = 0;
        if (count == 0) break;
        if (count < 0) {
            if (errno == EINTR) continue;
            ok = 0;
            break;
        }
        while (written < count) {
            ssize_t result = write(output, buffer + written, (size_t)(count - written));
            if (result < 0) {
                if (errno == EINTR) continue;
                ok = 0;
                break;
            }
            written += result;
        }
        if (!ok) break;
    }
    if (close(input) != 0 || close(output) != 0) ok = 0;
    return ok;
}

static int wait_success(pid_t child) {
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) return 0;
    }
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

static int run_zip(const char *working_directory, const char *artifact,
                   const char *first, const char *second) {
    pid_t child = fork();
    if (child < 0) return 0;
    if (child == 0) {
        if (chdir(working_directory) != 0) _exit(126);
        if (second == NULL) execlp("zip", "zip", "-X", "-q", "-r", artifact, first, (char *)NULL);
        else execlp("zip", "zip", "-X", "-q", "-r", artifact, first, second, (char *)NULL);
        _exit(127);
    }
    return wait_success(child);
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
        close(descriptors[0]);
        if (dup2(descriptors[1], STDOUT_FILENO) < 0) _exit(126);
        close(descriptors[1]);
        execlp("sha256sum", "sha256sum", "--", path, (char *)NULL);
        _exit(127);
    }
    close(descriptors[1]);
    while (length < sizeof(output) - 1) {
        ssize_t count = read(descriptors[0], output + length, sizeof(output) - 1 - length);
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
    return 1;
}

static int make_apks(const char *directory, int different_rebuild,
                     char artifact_one[PATH_MAXIMUM],
                     char artifact_two[PATH_MAXIMUM],
                     char upstream[PATH_MAXIMUM]) {
    char staging[PATH_MAXIMUM];
    char signing[PATH_MAXIMUM];
    char path[PATH_MAXIMUM];
    char extra[PATH_MAXIMUM];
    if (!path_join(staging, sizeof(staging), directory, "staging") ||
        !path_join(signing, sizeof(signing), directory, "signing") ||
        !path_join(artifact_one, PATH_MAXIMUM, directory, "fdroid-rebuild-1.apk") ||
        !path_join(artifact_two, PATH_MAXIMUM, directory, "fdroid-rebuild-2.apk") ||
        !path_join(upstream, PATH_MAXIMUM, directory, "upstream-release.apk") ||
        !make_directory(staging)) return 0;
    if (!path_join(path, sizeof(path), staging, "AndroidManifest.xml") ||
        !write_text(path, "fixture manifest\n")) return 0;
    if (!path_join(path, sizeof(path), staging, "lib/armeabi-v7a") ||
        !make_directory(path) || !path_join(path, sizeof(path), staging,
                                            "lib/armeabi-v7a/libgame.so") ||
        !write_text(path, "armv7\n")) return 0;
    if (!path_join(path, sizeof(path), staging, "lib/arm64-v8a") ||
        !make_directory(path) || !path_join(path, sizeof(path), staging,
                                            "lib/arm64-v8a/libgame.so") ||
        !write_text(path, "arm64\n")) return 0;
    if (!path_join(path, sizeof(path), staging, "lib/x86_64") ||
        !make_directory(path) || !path_join(path, sizeof(path), staging,
                                            "lib/x86_64/libgame.so") ||
        !write_text(path, "x86_64\n")) return 0;
    if (!run_zip(staging, artifact_one, "AndroidManifest.xml", "lib") ||
        !copy_file(artifact_one, artifact_two) || !copy_file(artifact_one, upstream)) return 0;

    if (different_rebuild) {
        if (!path_join(extra, sizeof(extra), directory, "different") ||
            !make_directory(extra) || !path_join(path, sizeof(path), extra, "extra.txt") ||
            !write_text(path, "different build\n") ||
            !run_zip(extra, artifact_two, "extra.txt", NULL)) return 0;
    }

    if (!path_join(path, sizeof(path), signing, "META-INF") || !make_directory(path) ||
        !path_join(path, sizeof(path), signing, "META-INF/SIGNATURE.RSA") ||
        !write_text(path, "fixture signature\n") ||
        !run_zip(signing, upstream, "META-INF", NULL)) return 0;
    return 1;
}

static int make_split_pair(const char *directory, const char *prefix,
                           const char *abi, int different_second,
                           char first[PATH_MAXIMUM], char second[PATH_MAXIMUM]) {
    char staging_name[256];
    char first_name[256];
    char second_name[256];
    char staging[PATH_MAXIMUM];
    char path[PATH_MAXIMUM];
    char library_directory[PATH_MAXIMUM];
    char library_file[PATH_MAXIMUM];
    char different[PATH_MAXIMUM];
    if (snprintf(staging_name, sizeof(staging_name), "%s-staging", prefix) < 0 ||
        snprintf(first_name, sizeof(first_name), "%s-1.apk", prefix) < 0 ||
        snprintf(second_name, sizeof(second_name), "%s-2.apk", prefix) < 0 ||
        !path_join(staging, sizeof(staging), directory, staging_name) ||
        !path_join(first, PATH_MAXIMUM, directory, first_name) ||
        !path_join(second, PATH_MAXIMUM, directory, second_name) ||
        !make_directory(staging) ||
        !path_join(path, sizeof(path), staging, "AndroidManifest.xml") ||
        !write_text(path, "split fixture manifest\n") ||
        snprintf(library_directory, sizeof(library_directory), "%s/lib/%s", staging, abi) < 0 ||
        strlen(library_directory) >= sizeof(library_directory) ||
        !make_directory(library_directory) ||
        snprintf(library_file, sizeof(library_file), "%s/libgame.so", library_directory) < 0 ||
        strlen(library_file) >= sizeof(library_file) ||
        !write_text(library_file, abi) ||
        !run_zip(staging, first, "AndroidManifest.xml", "lib") ||
        !copy_file(first, second)) return 0;
    if (different_second) {
        if (snprintf(staging_name, sizeof(staging_name), "%s-different", prefix) < 0 ||
            !path_join(different, sizeof(different), directory, staging_name) ||
            !make_directory(different) ||
            !path_join(path, sizeof(path), different, "extra.txt") ||
            !write_text(path, "different split build\n") ||
            !run_zip(different, second, "extra.txt", NULL)) return 0;
    }
    return 1;
}

static int write_split_contract(const char *path, int mode) {
    FILE *file = fopen(path, "w");
    int armv7_code = mode == 1 ? 1002 : 1001;
    int arm64_code = mode == 1 ? 1001 : 1002;
    const char *first_order = mode == 2 ? "arm64-rebuild-1" : "armv7-rebuild-1";
    const char *second_order = mode == 2 ? "armv7-rebuild-1" : "arm64-rebuild-1";
    if (file == NULL) return 0;
    fprintf(file,
            "receipt\tFDROID-RECEIPT\n"
            "release\tFDROID-RELEASE-IDENTITY\t%s\t%s\t1002\t%s\n"
            "toolchain\tFDROID-TOOLCHAIN\t%s\t%s\t%s\n"
            "profile\tcandidate-v1\n"
            "signing\tfdroid\n"
            "native\tyes\n",
            package_name, version_name, source_revision, fdroiddata_revision,
            fdroidserver_revision, image_digest);
    fprintf(file,
            "artifact\tFDROID-SPLIT-ARMV7-ONE\tarmv7-rebuild-1\trebuild\t%s\t%s\t%d\tarmeabi-v7a\n"
            "artifact\tFDROID-SPLIT-ARMV7-TWO\tarmv7-rebuild-2\trebuild\t%s\t%s\t%d\tarmeabi-v7a\n"
            "artifact\tFDROID-SPLIT-ARM64-ONE\tarm64-rebuild-1\trebuild\t%s\t%s\t%d\tarm64-v8a\n"
            "artifact\tFDROID-SPLIT-ARM64-TWO\tarm64-rebuild-2\trebuild\t%s\t%s\t%d\tarm64-v8a\n"
            "same_artifact\tFDROID-SPLIT-ARMV7-REBUILD\tarmv7-rebuild-1\tarmv7-rebuild-2\n"
            "same_artifact\tFDROID-SPLIT-ARM64-REBUILD\tarm64-rebuild-1\tarm64-rebuild-2\n"
            "abi_order\tFDROID-ABI-VERSION-ORDER\t%s\t%s\n",
            package_name, version_name, armv7_code,
            package_name, version_name, armv7_code,
            package_name, version_name, arm64_code,
            package_name, version_name, arm64_code, first_order, second_order);
    return fclose(file) == 0;
}

static void write_row(FILE *file, const char *kind, const char *name,
                      const char *status, const char *data_revision,
                      const char *server_revision, const char *image,
                      const char *package, const char *version, int code,
                      const char *abi_list, const char *witness,
                      const char *digest) {
    fprintf(file, "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\t%s\t%s\t%s\n",
            kind, name, status, source_revision, data_revision, server_revision,
            image, package, version, code, abi_list, witness, digest);
}

static int write_receipt(const char *directory, Mutation mutation,
                         const char *evidence_digest, const char *artifact_one_digest,
                         const char *artifact_two_digest, const char *upstream_digest) {
    char path[PATH_MAXIMUM];
    FILE *file;
    int index;
    if (!path_join(path, sizeof(path), directory, "receipt.tsv")) return 0;
    file = fopen(path, "w");
    if (file == NULL) return 0;
    if (mutation == MUTATION_MALFORMED_RECEIPT) {
        fputs("broken\theader\n", file);
    } else {
        fputs("kind\tname\tstatus\tsource_revision\tfdroiddata_revision\t"
              "fdroidserver_revision\timage_digest\tpackage\tversion_name\t"
              "version_code\tabis\twitness\tsha256\n", file);
    }
    write_row(file, "release", "identity", "pass", "-", "-", "-",
              package_name, mutation == MUTATION_RELEASE ? "9.9.9" : version_name,
              version_code, "-", "evidence.txt", evidence_digest);
    write_row(file, "toolchain", "buildserver", "pass", fdroiddata_revision,
              mutation == MUTATION_TOOLCHAIN
                  ? "5555555555555555555555555555555555555555"
                  : fdroidserver_revision,
              image_digest, package_name, version_name, version_code, "-",
              "evidence.txt", evidence_digest);
    for (index = 0; index < CHECK_COUNT; ++index) {
        const char *status = mutation == (Mutation)(MUTATION_CHECK_BASE + index)
                                 ? "not-verified"
                                 : "pass";
        write_row(file, "check", checks[index].name, status, fdroiddata_revision,
                  fdroidserver_revision, image_digest, package_name, version_name,
                  version_code, "-", "evidence.txt", evidence_digest);
    }
    write_row(file, "artifact", "fdroid-rebuild-1", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name,
              version_code, abis, "fdroid-rebuild-1.apk", artifact_one_digest);
    write_row(file, "artifact", "fdroid-rebuild-2", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name,
              version_code, mutation == MUTATION_ARTIFACT_TWO ? "arm64-v8a" : abis,
              "fdroid-rebuild-2.apk", artifact_two_digest);
    write_row(file, "artifact", "upstream-release", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name,
              version_code, abis, "upstream-release.apk", upstream_digest);
    if (mutation == MUTATION_EXTRA_ROW) {
        write_row(file, "check", "undeclared", "pass", fdroiddata_revision,
                  fdroidserver_revision, image_digest, package_name, version_name,
                  version_code, "-", "evidence.txt", evidence_digest);
    }
    return fclose(file) == 0;
}

static int write_split_receipt(const char *directory, SplitMutation mutation,
                               int bad_order, const char *evidence_digest,
                               const char *armv7_one_digest,
                               const char *armv7_two_digest,
                               const char *arm64_one_digest,
                               const char *arm64_two_digest) {
    char path[PATH_MAXIMUM];
    FILE *file;
    int index;
    int armv7_code = bad_order ? 1002 : 1001;
    int arm64_code = bad_order ? 1001 : 1002;
    if (!path_join(path, sizeof(path), directory, "receipt.tsv")) return 0;
    file = fopen(path, "w");
    if (file == NULL) return 0;
    fputs("kind\tname\tstatus\tsource_revision\tfdroiddata_revision\t"
          "fdroidserver_revision\timage_digest\tpackage\tversion_name\t"
          "version_code\tabis\twitness\tsha256\n", file);
    write_row(file, "release", "identity", "pass", "-", "-", "-",
              package_name, version_name, 1002, "-", "evidence.txt", evidence_digest);
    write_row(file, "toolchain", "buildserver", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name, 1002,
              "-", "evidence.txt", evidence_digest);
    for (index = 0; index < CANDIDATE_CHECK_COUNT; ++index) {
        write_row(file, "check", checks[index].name, "pass", fdroiddata_revision,
                  fdroidserver_revision, image_digest, package_name, version_name,
                  1002, "-", "evidence.txt", evidence_digest);
    }
    write_row(file, "artifact", "armv7-rebuild-1", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name,
              armv7_code, "armeabi-v7a", "armv7-rebuild-1.apk", armv7_one_digest);
    write_row(file, "artifact", "armv7-rebuild-2", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name,
              armv7_code,
              mutation == SPLIT_ARMV7_TWO ? "arm64-v8a" : "armeabi-v7a",
              "armv7-rebuild-2.apk", armv7_two_digest);
    write_row(file, "artifact", "arm64-rebuild-1", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name,
              arm64_code, "arm64-v8a", "arm64-rebuild-1.apk", arm64_one_digest);
    write_row(file, "artifact", "arm64-rebuild-2", "pass", fdroiddata_revision,
              fdroidserver_revision, image_digest, package_name, version_name,
              arm64_code,
              mutation == SPLIT_ARM64_TWO ? "armeabi-v7a" : "arm64-v8a",
              "arm64-rebuild-2.apk", arm64_two_digest);
    return fclose(file) == 0;
}

static int create_fixture(const char *directory, Mutation mutation) {
    char evidence[PATH_MAXIMUM];
    char artifact_one[PATH_MAXIMUM];
    char artifact_two[PATH_MAXIMUM];
    char upstream[PATH_MAXIMUM];
    char evidence_digest[65];
    char artifact_one_digest[65];
    char artifact_two_digest[65];
    char upstream_digest[65];
    if (!make_directory(directory) || !path_join(evidence, sizeof(evidence), directory,
                                                 "evidence.txt") ||
        !write_text(evidence, "independent F-Droid evidence\n") ||
        !make_apks(directory, mutation == MUTATION_DIFFERENT_REBUILD,
                   artifact_one, artifact_two, upstream) ||
        !sha256_file(evidence, evidence_digest) ||
        !sha256_file(artifact_one, artifact_one_digest) ||
        !sha256_file(artifact_two, artifact_two_digest) ||
        !sha256_file(upstream, upstream_digest) ||
        !write_receipt(directory, mutation, evidence_digest, artifact_one_digest,
                       artifact_two_digest, upstream_digest)) return 0;
    if (mutation == MUTATION_ARTIFACT_ONE && !append_text(artifact_one, "changed\n")) return 0;
    if (mutation == MUTATION_UPSTREAM_ARTIFACT && unlink(upstream) != 0) return 0;
    return 1;
}

static int create_split_fixture(const char *directory, SplitMutation mutation,
                                int bad_order) {
    char evidence[PATH_MAXIMUM];
    char armv7_one[PATH_MAXIMUM];
    char armv7_two[PATH_MAXIMUM];
    char arm64_one[PATH_MAXIMUM];
    char arm64_two[PATH_MAXIMUM];
    char evidence_digest[65];
    char armv7_one_digest[65];
    char armv7_two_digest[65];
    char arm64_one_digest[65];
    char arm64_two_digest[65];
    if (!make_directory(directory) ||
        !path_join(evidence, sizeof(evidence), directory, "evidence.txt") ||
        !write_text(evidence, "independent split-APK evidence\n") ||
        !make_split_pair(directory, "armv7-rebuild", "armeabi-v7a",
                         mutation == SPLIT_ARMV7_DIFFERENT,
                         armv7_one, armv7_two) ||
        !make_split_pair(directory, "arm64-rebuild", "arm64-v8a",
                         mutation == SPLIT_ARM64_DIFFERENT,
                         arm64_one, arm64_two) ||
        !sha256_file(evidence, evidence_digest) ||
        !sha256_file(armv7_one, armv7_one_digest) ||
        !sha256_file(armv7_two, armv7_two_digest) ||
        !sha256_file(arm64_one, arm64_one_digest) ||
        !sha256_file(arm64_two, arm64_two_digest) ||
        !write_split_receipt(directory, mutation, bad_order, evidence_digest,
                             armv7_one_digest, armv7_two_digest,
                             arm64_one_digest, arm64_two_digest)) return 0;
    if (mutation == SPLIT_ARMV7_ONE && !append_text(armv7_one, "changed\n")) return 0;
    if (mutation == SPLIT_ARM64_ONE && !append_text(arm64_one, "changed\n")) return 0;
    return 1;
}

static int write_case(FILE *cases, const char *expected, const char *contract,
                      const char *directory, const char *diagnostic) {
    char receipt[PATH_MAXIMUM];
    if (!path_join(receipt, sizeof(receipt), directory, "receipt.tsv")) return 0;
    return fprintf(cases, "%s\t%s\t%s\t%s\t%s\n", expected, contract,
                   receipt, directory, diagnostic) > 0;
}

int main(int argc, char **argv) {
    char output[PATH_MAXIMUM];
    char cases_path[PATH_MAXIMUM];
    char contract[PATH_MAXIMUM];
    char split_contract[PATH_MAXIMUM];
    char split_bad_order_contract[PATH_MAXIMUM];
    char split_invalid_order_contract[PATH_MAXIMUM];
    FILE *cases;
    int index;
    struct {
        const char *name;
        Mutation mutation;
        const char *code;
    } fixed[] = {
        {"bad-receipt", MUTATION_MALFORMED_RECEIPT, "FDROID-RECEIPT"},
        {"bad-release", MUTATION_RELEASE, "FDROID-RELEASE-IDENTITY"},
        {"bad-toolchain", MUTATION_TOOLCHAIN, "FDROID-TOOLCHAIN"},
        {"bad-artifact-one", MUTATION_ARTIFACT_ONE, "FDROID-REBUILD-ONE"},
        {"bad-artifact-two", MUTATION_ARTIFACT_TWO, "FDROID-REBUILD-TWO"},
        {"bad-upstream-artifact", MUTATION_UPSTREAM_ARTIFACT, "FDROID-UPSTREAM-APK"},
        {"bad-rebuild-difference", MUTATION_DIFFERENT_REBUILD,
         "FDROID-DETERMINISTIC-REBUILD"},
        {"bad-extra-row", MUTATION_EXTRA_ROW, "FDROID-RECEIPT-EXTRA"},
    };
    struct {
        const char *name;
        SplitMutation mutation;
        const char *code;
    } split_fixed[] = {
        {"bad-split-armv7-one", SPLIT_ARMV7_ONE, "FDROID-SPLIT-ARMV7-ONE"},
        {"bad-split-armv7-two", SPLIT_ARMV7_TWO, "FDROID-SPLIT-ARMV7-TWO"},
        {"bad-split-arm64-one", SPLIT_ARM64_ONE, "FDROID-SPLIT-ARM64-ONE"},
        {"bad-split-arm64-two", SPLIT_ARM64_TWO, "FDROID-SPLIT-ARM64-TWO"},
        {"bad-split-armv7-rebuild", SPLIT_ARMV7_DIFFERENT,
         "FDROID-SPLIT-ARMV7-REBUILD"},
        {"bad-split-arm64-rebuild", SPLIT_ARM64_DIFFERENT,
         "FDROID-SPLIT-ARM64-REBUILD"},
    };
    if (argc != 3 || !make_directory(argv[2]) || realpath(argv[1], contract) == NULL ||
        realpath(argv[2], output) == NULL ||
        !path_join(cases_path, sizeof(cases_path), output, "cases.tsv") ||
        !path_join(split_contract, sizeof(split_contract), output,
                   "split-good.contract.tsv") ||
        !path_join(split_bad_order_contract, sizeof(split_bad_order_contract), output,
                   "split-bad-order.contract.tsv") ||
        !path_join(split_invalid_order_contract, sizeof(split_invalid_order_contract), output,
                   "split-invalid-order.contract.tsv") ||
        !write_split_contract(split_contract, 0) ||
        !write_split_contract(split_bad_order_contract, 1) ||
        !write_split_contract(split_invalid_order_contract, 2)) {
        fprintf(stderr, "usage: %s CONTRACT OUTPUT_DIRECTORY\n", argv[0]);
        return 2;
    }
    cases = fopen(cases_path, "w");
    if (cases == NULL) return 1;
    fputs("# expected\tcontract\treceipt\tartifact-root\texpected-first-diagnostic\n", cases);
    {
        char directory[PATH_MAXIMUM];
        if (!path_join(directory, sizeof(directory), output, "good") ||
            !create_fixture(directory, MUTATION_NONE) ||
            !write_case(cases, "pass", contract, directory, "-")) return 1;
    }
    for (index = 0; index < (int)(sizeof(fixed) / sizeof(fixed[0])); ++index) {
        char directory[PATH_MAXIMUM];
        if (!path_join(directory, sizeof(directory), output, fixed[index].name) ||
            !create_fixture(directory, fixed[index].mutation) ||
            !write_case(cases, "fail", contract, directory, fixed[index].code)) return 1;
    }
    for (index = 0; index < CHECK_COUNT; ++index) {
        char directory[PATH_MAXIMUM];
        char name[PATH_MAXIMUM];
        if (snprintf(name, sizeof(name), "bad-check-%s", checks[index].name) < 0 ||
            !path_join(directory, sizeof(directory), output, name) ||
            !create_fixture(directory, (Mutation)(MUTATION_CHECK_BASE + index)) ||
            !write_case(cases, "fail", contract, directory, checks[index].code)) return 1;
    }
    {
        char directory[PATH_MAXIMUM];
        if (!path_join(directory, sizeof(directory), output, "split-good") ||
            !create_split_fixture(directory, SPLIT_NONE, 0) ||
            !write_case(cases, "pass", split_contract, directory, "-") ||
            !write_case(cases, "fail", split_invalid_order_contract, directory,
                        "AICI-FDROID-CONTRACT")) return 1;
    }
    for (index = 0; index < (int)(sizeof(split_fixed) / sizeof(split_fixed[0])); ++index) {
        char directory[PATH_MAXIMUM];
        if (!path_join(directory, sizeof(directory), output, split_fixed[index].name) ||
            !create_split_fixture(directory, split_fixed[index].mutation, 0) ||
            !write_case(cases, "fail", split_contract, directory,
                        split_fixed[index].code)) return 1;
    }
    {
        char directory[PATH_MAXIMUM];
        if (!path_join(directory, sizeof(directory), output, "bad-abi-version-order") ||
            !create_split_fixture(directory, SPLIT_NONE, 1) ||
            !write_case(cases, "fail", split_bad_order_contract, directory,
                        "FDROID-ABI-VERSION-ORDER")) return 1;
    }
    if (fclose(cases) != 0) return 1;
    puts(cases_path);
    return 0;
}
