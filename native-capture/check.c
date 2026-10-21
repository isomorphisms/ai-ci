#define _POSIX_C_SOURCE 200809L
/* Independent artifact/fixture verifier. Deliberately links no exporter code,
 * JSON parser, graph normalizer, TLS provider or capture coordinator. */
#include <dirent.h>
#include <fcntl.h>
#include <openssl/evp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static int hash(const void *bytes, size_t n, char out[65])
{
    unsigned char digest[32]; unsigned used;
    if (!EVP_Digest(bytes, n, digest, &used, EVP_sha256(), NULL) || used != 32) return 0;
    for (unsigned i = 0; i < 32; ++i) (void)snprintf(out + 2 * i, 3, "%02x", digest[i]);
    return 1;
}
static size_t read_file(const char *path, char *out, size_t capacity, int private)
{
    int fd = open(path, O_RDONLY | O_NOFOLLOW); struct stat st;
    if (fd < 0) return 0;
    if (fstat(fd, &st) || !S_ISREG(st.st_mode) || st.st_nlink != 1 || st.st_size < 1
        || (unsigned long long)st.st_size >= capacity
        || (private && (st.st_uid != geteuid() || (st.st_mode & 077)))) { close(fd); return 0; }
    size_t used = 0;
    while (used < (size_t)st.st_size) {
        ssize_t n = read(fd, out + used, (size_t)st.st_size - used);
        if (n <= 0) { close(fd); return 0; } used += (size_t)n;
    }
    close(fd); out[used] = 0; return used;
}
static int private_directory(const char *path)
{
    struct stat st; return !lstat(path, &st) && S_ISDIR(st.st_mode) && st.st_uid == geteuid() && !(st.st_mode & 077);
}
static int workflow(const char *bytes)
{
    /* This contract intentionally admits only the simple unfiltered exporter
     * workflow. A new YAML form needs review rather than a guessed parser. */
    return strstr(bytes, "\non:\n  pull_request:\n  push:\n")
        && !strstr(bytes, "paths:") && !strstr(bytes, "paths-ignore:") && !strstr(bytes, "continue-on-error")
        && strstr(bytes, "github.event.pull_request.head.sha || github.sha")
        && strstr(bytes, "check-capture") && strstr(bytes, "check-capture-mutants")
        && strstr(bytes, "npm run check") && strstr(bytes, "check-store") && strstr(bytes, "check-https");
}
static const char *last_error;
static const char *location_name = "capture-success";
static const char *expected_source;
static int fail(const char *message) { last_error = message; fprintf(stderr, "FAIL %s\n", message); return 1; }
static int run(int argc, char **argv)
{
    if (argc == 3 && !strcmp(argv[1], "--check-workflow")) {
        char bytes[32768];
        if (!read_file(argv[2], bytes, sizeof(bytes), 0) || !workflow(bytes)) return fail("eligible workflow positive fixture rejected");
        puts("PASS eligible exact-head workflow positive fixture"); return 0;
    }
    if (argc == 3 && !strcmp(argv[1], "--reject-skipped-trigger")) {
        char bytes[32768];
        if (!read_file(argv[2], bytes, sizeof(bytes), 0)) return fail("trigger mutant missing");
        if (workflow(bytes)) return fail("SKIPPED_TRIGGER mutant survived");
        puts("PASS rejected SKIPPED_TRIGGER fixture"); return 0;
    }
    if (argc != 4) return fail("usage: check NATIVE_DIRECTORY FIXTURE_DIRECTORY EXPORTER_WORKFLOW");
    char path[2048], location[512], root[2048], bytes[32768];
    (void)snprintf(path, sizeof(path), "%s/build/%s.path", argv[1], location_name);
    size_t n = read_file(path, location, sizeof(location), 1);
    if (!n || location[n - 1] != '\n') return fail("capture location is missing or not private");
    location[--n] = 0;
    if (strncmp(location, "build/capture-", 14) || strspn(location + 14, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") != strlen(location + 14)) return fail("capture location is outside the fixture boundary");
    if (snprintf(root, sizeof(root), "%s/%s", argv[1], location) >= (int)sizeof(root) || !private_directory(root)) return fail("private capture root refused");
    if (snprintf(path, sizeof(path), "%s/objects", root) >= (int)sizeof(path) || !private_directory(path)) return fail("private object directory refused");
    char workspace_hash[65]; (void)hash("selected_fixture_workspace", strlen("selected_fixture_workspace"), workspace_hash);
    if (snprintf(path, sizeof(path), "%s/validation-%s.tsv", root, workspace_hash) >= (int)sizeof(path)
        || !read_file(path, bytes, sizeof(bytes), 1)) return fail("validation report missing or not private");
    if (expected_source) {
        char required[80]; (void)snprintf(required, sizeof(required), "\nsource\t%s\n", expected_source);
        if (!strstr(bytes, required)) return fail("validation report is not bound to the qualified source head");
    }
    if (strstr(bytes, "\nexpected\t4\n") && strstr(bytes, "\ncompleted\t4\n") && strstr(bytes, "\nscope_result\tCOMPLETE_BOUNDED_MAIN_ARCHIVED\n")) return fail("premature inventory completion");
    if (strstr(bytes, "\nexpected\t5\n") && strstr(bytes, "\ncompleted\t4\n") && strstr(bytes, "\nscope_result\tCOMPLETE_BOUNDED_MAIN_ARCHIVED\n")) return fail("silent expected-record omission");
    if (!strstr(bytes, "\nfull_account_export_complete\tfalse\n") || !strstr(bytes, "\nexpected\t5\n")
        || !strstr(bytes, "\ncompleted\t5\n") || !strstr(bytes, "\nscope_result\tCOMPLETE_BOUNDED_MAIN_ARCHIVED\n")
        || !strstr(bytes, "\natomic_provider_snapshot_proven\tfalse\n")) return fail("completion/report scope is wrong");
    char report_hash[65]; (void)hash(bytes, strlen(bytes), report_hash);
    const char *inventory = strstr(bytes, "\ninventory_sha256\t"); char inventory_hash[65];
    if (!inventory || strlen(inventory + 18) < 65) return fail("inventory identity missing");
    memcpy(inventory_hash, inventory + 18, 64); inventory_hash[64] = 0;
    if (snprintf(path, sizeof(path), "%s/journal-%s.tsv", root, workspace_hash) >= (int)sizeof(path)) return fail("journal path exceeds bound");
    char *journal = malloc(4194305);
    if (!journal || !read_file(path, journal, 4194305, 1)) { free(journal); return fail("journal missing or not private"); }
    const char *ids[] = { "conversation-1", "conversation-2", "archived-1", "archived-2", "archived-3" };
    int result = 0;
    for (unsigned i = 0; i < 5 && !result; ++i) {
        char expected[16384], actual[16384], id_hash[65], object_hash[65];
        if (snprintf(path, sizeof(path), "%s/%s.json", argv[2], ids[i]) >= (int)sizeof(path)) { result = fail("oracle path exceeds bound"); break; }
        size_t expected_size = read_file(path, expected, sizeof(expected), 0);
        if (!expected_size || !hash(expected, expected_size, object_hash) || !hash(ids[i], strlen(ids[i]), id_hash)) { result = fail("independent oracle missing"); break; }
        if (snprintf(path, sizeof(path), "%s/objects/%s", root, object_hash) >= (int)sizeof(path)) { result = fail("object path exceeds bound"); break; }
        size_t actual_size = read_file(path, actual, sizeof(actual), 1);
        if (actual_size != expected_size) { result = fail("expected raw graph omitted or truncated"); break; }
        if (memcmp(actual, expected, expected_size)) { result = fail("corrupt immutable raw graph"); break; }
        char measured[65]; (void)hash(actual, actual_size, measured);
        if (strcmp(measured, object_hash)) { result = fail("object SHA-256 differs from independent oracle"); break; }
        if (snprintf(path, sizeof(path), "%s/complete-%s-%s.tsv", root, workspace_hash, id_hash) >= (int)sizeof(path)) { result = fail("marker path exceeds bound"); break; }
        if (!read_file(path, actual, sizeof(actual), 1)) { result = fail("completion marker absent or not private"); break; }
        (void)snprintf(expected, sizeof(expected), "CGW1\t%s\t%s\t%s\n", inventory_hash, id_hash, object_hash);
        if (strcmp(actual, expected)) { result = fail("marker is stale or detached from expected inventory/raw object"); break; }
        (void)snprintf(expected, sizeof(expected), "EXPECTED\t%s\t%s\t%s\n", inventory_hash, id_hash, ids[i]);
        if (!strstr(journal, expected)) { result = fail("expected semantic ID silently omitted from journal"); break; }
        printf("raw_object\t%s\t%s\n", ids[i], object_hash);
    }
    free(journal);
    if (result) return result;
    if (!read_file(argv[3], bytes, sizeof(bytes), 0) || !workflow(bytes)) return fail("required workflow can skip a material capture change");
    printf("PASS independent raw oracle, expected IDs, markers, private modes, report scope and trigger coverage\nvalidation_sha256\t%s\nevidence\thost-loopback-artifacts-only\nfull_account_export_complete\tfalse\n", report_hash);
    return 0;
}
int main(int argc, char **argv)
{
    if (argc >= 3 && !strcmp(argv[1], "--source")) {
        if (strlen(argv[2]) != 40 || strspn(argv[2], "0123456789abcdef") != 40) return fail("expected source must be an exact commit");
        expected_source = argv[2]; argc -= 2; argv += 2;
    }
    if (argc == 5 && !strcmp(argv[1], "--reject-mutants")) {
        const char *cases[] = { "mutant-premature", "mutant-omission", "mutant-marker" };
        const char *diagnostics[] = { "premature inventory completion", "silent expected-record omission", "corrupt immutable raw graph" };
        char *inputs[] = { argv[0], argv[2], argv[3], argv[4] };
        for (unsigned i = 0; i < 3; ++i) {
            location_name = cases[i]; last_error = NULL;
            int status = run(4, inputs);
            if (status != 1 || !last_error || strcmp(last_error, diagnostics[i])) return fail("behavioral mutant did not fail its independent diagnostic");
            printf("PASS independent mutant rejection\t%s\t%s\n", cases[i], diagnostics[i]);
        }
        return 0;
    }
    return run(argc, argv);
}
