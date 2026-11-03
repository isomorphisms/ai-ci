#define _GNU_SOURCE
#include "ib_browser_dom_source.h"
#include "ib_shizuku_arena_publish.h"
#include "appendfat_arena.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static void require(int condition, const char *label) {
    if (!condition) { fprintf(stderr, "FAIL %s\n", label); exit(1); }
}

static void path(char *out, size_t capacity, const char *root, const char *leaf) {
    int count = snprintf(out, capacity, "%s/%s", root, leaf);
    require(count > 0 && (size_t)count < capacity, "bounded test path");
}

/* Independently constructed, explicit deterministic HTTP controls. They do not
 * claim a public Google capture or Android execution. The maintained publisher
 * must validate and retain the same framed source used by the real ICU path. */
static void original(ib_ingress_arena *arena, const char *id, const char *requested,
                     const char *resolved, const char *body, char digest[65]) {
    size_t size = strlen(body);
    char metadata[4096];
    int count = snprintf(metadata, sizeof(metadata),
        "http_status\t200\ncontent_type\ttext/html; charset=utf-8\ncontent_encoding\tidentity\n"
        "declared_length\t%zu\nreceived_length\t%zu\nutf8\tvalid\nresolved_url\t%s\n"
        "redirect_count\t1\ncontent_range\tabsent\ntransfer_decoding\tidentity\n"
        "redirect_chain\tR1 %zu %s302 %zu %s\n", size, size, resolved,
        strlen(requested), requested, strlen(resolved), resolved);
    require(count > 0 && (size_t)count < sizeof(metadata), "bounded original metadata");
    size_t bytes = (size_t)count + size + 26U;
    unsigned char *frame = malloc(bytes + 1U);
    require(frame != NULL, "test frame allocation");
    require(snprintf((char *)frame, bytes + 1U, "IBICU01 %08d %08zu\n", count, size) == 26,
        "exact original frame prefix");
    memcpy(frame + 26U, metadata, (size_t)count);
    memcpy(frame + 26U + count, body, size);
    char frame_digest[65];
    ib_reader_sha256_hex(frame, bytes, frame_digest);
    require(ib_ingress_arena_publish_frame(arena, id, 7, requested, frame, bytes, frame_digest) == 0,
        "canonical original publication");
    ib_reader_sha256_hex((const unsigned char *)body, size, digest);
    free(frame);
}

static int reopen(ib_arena_source_owner *owner, const char *id, unsigned generation,
                  unsigned navigation, ib_browser_dom_metadata *metadata,
                  ib_reader_source *source) {
    ib_reader_source_ticket ticket;
    int fd = -1;
    int result = ib_browser_dom_open(owner, id, generation, navigation, metadata, &ticket, &fd);
    if (result == 0) {
        ib_reader_source_want(source, navigation);
        result = ib_reader_source_accept_fd(source, &ticket, fd);
    }
    if (fd >= 0) close(fd);
    return result;
}

int main(void) {
    char root[] = "/tmp/aici-browser-dom-XXXXXX";
    require(mkdtemp(root) != NULL, "private test directory");
    char name[4096];
    path(name, sizeof(name), root, "receipts"); require(mkdir(name, 0700) == 0, "receipts directory");
    path(name, sizeof(name), root, "locks"); require(mkdir(name, 0700) == 0, "locks directory");
    path(name, sizeof(name), root, "responses.arena");
    require(appendfat_arena_create(name, 16777216U) == 0, "canonical Arena creation");
    ib_ingress_arena publisher;
    ib_arena_source_owner owner;
    require(ib_ingress_arena_init(&publisher, root) == 0 && ib_arena_source_owner_init(&owner, root) == 0,
        "maintained source owners initialize");
    const char *query = "https://google.com/search?q=music";
    const char *google = "https://www.google.com/search?q=music";
    const char *redirect = "https://www.google.com/url?q=CAESDcontrol_token";
    char parent_digest[65], target_digest[65];
    original(&publisher, "parent", query, google, "<html><body>JavaScript required</body></html>", parent_digest);
    original(&publisher, "target", redirect, "https://example.org/music", "<h1>Music</h1>", target_digest);
    ib_arena_source_owner_want(&owner, 7);
    ib_browser_dom_metadata metadata = {0};
    strcpy(metadata.request_id, "rendered"); metadata.source_generation = metadata.parent_generation = 7;
    strcpy(metadata.requested_url, query); strcpy(metadata.resolved_url, google);
    strcpy(metadata.parent_id, "parent"); strcpy(metadata.parent_sha256, parent_digest);
    strcpy(metadata.provider_package, "com.android.webview"); strcpy(metadata.provider_version, "74.0.3729.185");
    const unsigned char dom[] = "<a href=\"/url?q=CAESDcontrol_token\"><h3>Music</h3></a>";
    ib_browser_dom_metadata wrong = metadata;
    wrong.parent_sha256[0] = wrong.parent_sha256[0] == '0' ? '1' : '0';
    require(ib_browser_dom_append(&owner, 7, &wrong, dom, sizeof(dom)-1U) != 0, "changed parent digest refusal");
    require(ib_browser_dom_append(&owner, 7, &metadata, dom, sizeof(dom)-1U) == 0,
        "canonical browser serialization append and independent FIFO readback");
    require(ib_browser_dom_seal(&owner, 7, &metadata) != 0, "missing verified targets refusal");
    metadata.target_count = 1;
    metadata.targets[0].occurrence = 0;
    strcpy(metadata.targets[0].original_href, "/url?q=CAESDcontrol_token");
    strcpy(metadata.targets[0].requested_url, redirect); strcpy(metadata.targets[0].request_id, "target");
    wrong = metadata; strcpy(wrong.targets[0].requested_url, "https://example.net/fabricated");
    require(ib_browser_dom_seal(&owner, 7, &wrong) != 0, "changed destination request refusal");
    wrong = metadata; wrong.target_count = 2; wrong.targets[1] = wrong.targets[0];
    require(ib_browser_dom_seal(&owner, 7, &wrong) != 0, "duplicate destination mapping refusal");
    require(ib_browser_dom_seal(&owner, 7, &metadata) == 0, "complete immutable browser receipt");
    require(ib_browser_dom_seal(&owner, 7, &metadata) != 0, "browser receipt replacement refusal");
    ib_reader_source_ticket ticket;
    ib_arena_source_observations observations;
    int fd = -1;
    require(ib_arena_source_owner_open_decode_input(&owner, "rendered", 7, 7, &ticket, &observations, &fd) != 0 && fd == -1,
        "browser derivative never admitted as original ICU response");
    ib_reader_source source; ib_reader_source_init(&source);
    ib_browser_dom_metadata reopened;
    ib_arena_source_owner_want(&owner, 12);
    require(reopen(&owner, "rendered", 7, 12, &reopened, &source) == 0 && source.byte_count == sizeof(dom)-1U &&
        memcmp(source.bytes, dom, sizeof(dom)-1U) == 0 && reopened.source_generation == 7 &&
        reopened.parent_generation == 7 && !strcmp(reopened.parent_sha256, parent_digest),
        "retained browser generation and exact bytes survive newer navigation");
    require(reopen(&owner, "rendered", 8, 12, &reopened, &source) != 0, "wrong rendered source generation refusal");
    require(reopen(&owner, "rendered", 7, 11, &reopened, &source) != 0, "stale navigation refusal");
    path(name, sizeof(name), root, "responses.arena");
    fd = open(name, O_WRONLY | O_NOFOLLOW | O_CLOEXEC);
    require(fd >= 0 && pwrite(fd, "X", 1, (off_t)metadata.arena_offset) == 1 && close(fd) == 0, "deterministic changed-byte control");
    require(reopen(&owner, "rendered", 7, 12, &reopened, &source) != 0,
        "changed committed DOM byte rejected by digest");
    ib_reader_source_clear(&source);
    puts("PASS independent browser DOM ownership original-source separation retained generations and corruption controls");
    return 0;
}
