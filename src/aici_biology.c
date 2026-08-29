#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>

#define LINE_CAP 8192
#define PATH_CAP 4096
#define ARG_CAP 1024
#define OUT_CAP 4096

typedef struct {
    uint32_t h[5];
    uint64_t bits;
    unsigned char block[64];
    size_t used;
} Sha1;

static uint32_t rol32(uint32_t x, unsigned n) {
    return (x << n) | (x >> (32U - n));
}

static void sha1_block(Sha1 *s, const unsigned char block[64]) {
    uint32_t w[80];
    uint32_t a, b, c, d, e;
    unsigned i;

    for (i = 0; i < 16; ++i) {
        size_t j = (size_t)i * 4U;
        w[i] = ((uint32_t)block[j] << 24) |
               ((uint32_t)block[j + 1] << 16) |
               ((uint32_t)block[j + 2] << 8) |
               (uint32_t)block[j + 3];
    }
    for (i = 16; i < 80; ++i) {
        w[i] = rol32(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);
    }

    a = s->h[0];
    b = s->h[1];
    c = s->h[2];
    d = s->h[3];
    e = s->h[4];

    for (i = 0; i < 80; ++i) {
        uint32_t f;
        uint32_t k;
        uint32_t t;
        if (i < 20) {
            f = (b & c) | ((~b) & d);
            k = UINT32_C(0x5a827999);
        } else if (i < 40) {
            f = b ^ c ^ d;
            k = UINT32_C(0x6ed9eba1);
        } else if (i < 60) {
            f = (b & c) | (b & d) | (c & d);
            k = UINT32_C(0x8f1bbcdc);
        } else {
            f = b ^ c ^ d;
            k = UINT32_C(0xca62c1d6);
        }
        t = rol32(a, 5) + f + e + k + w[i];
        e = d;
        d = c;
        c = rol32(b, 30);
        b = a;
        a = t;
    }

    s->h[0] += a;
    s->h[1] += b;
    s->h[2] += c;
    s->h[3] += d;
    s->h[4] += e;
}

static void sha1_init(Sha1 *s) {
    s->h[0] = UINT32_C(0x67452301);
    s->h[1] = UINT32_C(0xefcdab89);
    s->h[2] = UINT32_C(0x98badcfe);
    s->h[3] = UINT32_C(0x10325476);
    s->h[4] = UINT32_C(0xc3d2e1f0);
    s->bits = 0;
    s->used = 0;
}

static void sha1_update(Sha1 *s, const void *data, size_t len) {
    const unsigned char *p = data;
    while (len > 0) {
        size_t room = sizeof(s->block) - s->used;
        size_t take = len < room ? len : room;
        memcpy(s->block + s->used, p, take);
        s->used += take;
        s->bits += (uint64_t)take * 8U;
        p += take;
        len -= take;
        if (s->used == sizeof(s->block)) {
            sha1_block(s, s->block);
            s->used = 0;
        }
    }
}

static void sha1_final(Sha1 *s, unsigned char out[20]) {
    uint64_t original_bits = s->bits;
    unsigned char pad = 0x80;
    unsigned char zero = 0;
    unsigned char length[8];
    unsigned i;

    sha1_update(s, &pad, 1);
    while (s->used != 56) {
        sha1_update(s, &zero, 1);
    }
    for (i = 0; i < 8; ++i) {
        length[7U - i] = (unsigned char)(original_bits >> (i * 8U));
    }
    sha1_update(s, length, sizeof(length));

    for (i = 0; i < 5; ++i) {
        out[i * 4U] = (unsigned char)(s->h[i] >> 24);
        out[i * 4U + 1U] = (unsigned char)(s->h[i] >> 16);
        out[i * 4U + 2U] = (unsigned char)(s->h[i] >> 8);
        out[i * 4U + 3U] = (unsigned char)s->h[i];
    }
}

static int join_path(char *out, size_t cap, const char *root, const char *path) {
    int n = snprintf(out, cap, "%s/%s", root, path);
    return n >= 0 && (size_t)n < cap;
}

static int git_blob_sha1(const char *path, char hex[41]) {
    FILE *f = fopen(path, "rb");
    Sha1 s;
    unsigned char digest[20];
    unsigned char buf[16384];
    long size;
    char header[64];
    int header_len;
    size_t n;
    unsigned i;

    if (f == NULL) {
        fprintf(stderr, "cannot open %s: %s\n", path, strerror(errno));
        return 0;
    }
    if (fseek(f, 0, SEEK_END) != 0 || (size = ftell(f)) < 0 || fseek(f, 0, SEEK_SET) != 0) {
        fprintf(stderr, "cannot size %s\n", path);
        fclose(f);
        return 0;
    }
    header_len = snprintf(header, sizeof(header), "blob %ld", size);
    if (header_len < 0 || (size_t)header_len + 1U > sizeof(header)) {
        fclose(f);
        return 0;
    }
    sha1_init(&s);
    sha1_update(&s, header, (size_t)header_len + 1U);
    while ((n = fread(buf, 1, sizeof(buf), f)) > 0) {
        sha1_update(&s, buf, n);
    }
    if (ferror(f)) {
        fprintf(stderr, "cannot read %s\n", path);
        fclose(f);
        return 0;
    }
    fclose(f);
    sha1_final(&s, digest);
    for (i = 0; i < 20; ++i) {
        snprintf(hex + i * 2U, 3, "%02x", digest[i]);
    }
    hex[40] = '\0';
    return 1;
}

static size_t split_tsv(char *line, char **field, size_t max_fields) {
    size_t count = 0;
    char *p = line;
    if (*p == '\0') {
        return 0;
    }
    field[count++] = p;
    while (*p != '\0' && count < max_fields) {
        if (*p == '\t') {
            *p = '\0';
            field[count++] = p + 1;
        }
        ++p;
    }
    return count;
}

static void trim_eol(char *line) {
    size_t n = strlen(line);
    while (n > 0 && (line[n - 1] == '\n' || line[n - 1] == '\r')) {
        line[--n] = '\0';
    }
}

static int verify_corpus(const char *sources_path, const char *root) {
    FILE *f = fopen(sources_path, "r");
    char line[LINE_CAP];
    unsigned line_no = 0;
    unsigned checked = 0;

    if (f == NULL) {
        fprintf(stderr, "cannot open sources manifest %s: %s\n", sources_path, strerror(errno));
        return 0;
    }
    while (fgets(line, sizeof(line), f) != NULL) {
        char *field[5];
        size_t count;
        char path[PATH_CAP];
        char actual[41];
        ++line_no;
        trim_eol(line);
        if (line[0] == '\0' || line[0] == '#') {
            continue;
        }
        count = split_tsv(line, field, 5);
        if (count != 5) {
            fprintf(stderr, "%s:%u: expected 5 TSV fields\n", sources_path, line_no);
            fclose(f);
            return 0;
        }
        if (strcmp(field[3], "blob_sha") == 0 && strcmp(field[4], "local_path") == 0) {
            continue;
        }
        if (!join_path(path, sizeof(path), root, field[4])) {
            fprintf(stderr, "%s:%u: path too long\n", sources_path, line_no);
            fclose(f);
            return 0;
        }
        if (!git_blob_sha1(path, actual)) {
            fclose(f);
            return 0;
        }
        if (strcmp(actual, field[3]) != 0) {
            fprintf(stderr, "corpus mismatch: %s expected %s got %s\n", field[4], field[3], actual);
            fclose(f);
            return 0;
        }
        ++checked;
    }
    if (ferror(f)) {
        fprintf(stderr, "cannot read %s\n", sources_path);
        fclose(f);
        return 0;
    }
    fclose(f);
    if (checked == 0) {
        fprintf(stderr, "sources manifest is empty\n");
        return 0;
    }
    printf("corpus\tPASS\t%u files\n", checked);
    return 1;
}

static int append_byte(unsigned char **data, size_t *len, size_t *cap, unsigned char c) {
    if (*len == *cap) {
        size_t new_cap = *cap == 0 ? 4096U : *cap * 2U;
        unsigned char *p = realloc(*data, new_cap);
        if (p == NULL) {
            return 0;
        }
        *data = p;
        *cap = new_cap;
    }
    (*data)[(*len)++] = c;
    return 1;
}

static int read_all(const char *path, unsigned char **data, size_t *len) {
    FILE *f = fopen(path, "rb");
    unsigned char buf[16384];
    size_t cap = 0;
    size_t n;
    *data = NULL;
    *len = 0;
    if (f == NULL) {
        fprintf(stderr, "cannot open %s: %s\n", path, strerror(errno));
        return 0;
    }
    while ((n = fread(buf, 1, sizeof(buf), f)) > 0) {
        size_t i;
        for (i = 0; i < n; ++i) {
            if (!append_byte(data, len, &cap, buf[i])) {
                fprintf(stderr, "out of memory\n");
                fclose(f);
                free(*data);
                return 0;
            }
        }
    }
    if (ferror(f)) {
        fprintf(stderr, "cannot read %s\n", path);
        fclose(f);
        free(*data);
        return 0;
    }
    fclose(f);
    return 1;
}

static uint64_t count_overlapping(const unsigned char *data, size_t len, const char *needle) {
    size_t nlen = strlen(needle);
    uint64_t count = 0;
    size_t i;
    if (nlen == 0 || nlen > len) {
        return 0;
    }
    for (i = 0; i + nlen <= len; ++i) {
        if (memcmp(data + i, needle, nlen) == 0) {
            ++count;
        }
    }
    return count;
}

static int load_fasta_sequence(const char *path, unsigned char **data, size_t *len) {
    FILE *f = fopen(path, "rb");
    char line[LINE_CAP];
    size_t cap = 0;
    int saw_header = 0;
    *data = NULL;
    *len = 0;
    if (f == NULL) {
        fprintf(stderr, "cannot open %s: %s\n", path, strerror(errno));
        return 0;
    }
    while (fgets(line, sizeof(line), f) != NULL) {
        size_t i;
        if (line[0] == '>') {
            saw_header = 1;
            if (*len > 0 && !append_byte(data, len, &cap, 0)) {
                fclose(f);
                free(*data);
                return 0;
            }
            continue;
        }
        for (i = 0; line[i] != '\0'; ++i) {
            unsigned char c = (unsigned char)line[i];
            if (isspace(c)) {
                continue;
            }
            if (!append_byte(data, len, &cap, (unsigned char)toupper(c))) {
                fprintf(stderr, "out of memory\n");
                fclose(f);
                free(*data);
                return 0;
            }
        }
    }
    if (ferror(f) || !saw_header) {
        fprintf(stderr, "%s is not readable FASTA\n", path);
        fclose(f);
        free(*data);
        return 0;
    }
    fclose(f);
    return 1;
}

static int oracle_value(const char *kind, const char *path, const char *arg, char out[OUT_CAP]) {
    unsigned char *data = NULL;
    size_t len = 0;

    if (strcmp(kind, "bytes-count") == 0) {
        uint64_t count;
        if (!read_all(path, &data, &len)) {
            return 0;
        }
        count = count_overlapping(data, len, arg);
        snprintf(out, OUT_CAP, "%llu", (unsigned long long)count);
        free(data);
        return 1;
    }

    if (strcmp(kind, "fasta-motif-count") == 0) {
        char upper_arg[ARG_CAP];
        size_t i;
        uint64_t count;
        if (strlen(arg) >= sizeof(upper_arg)) {
            fprintf(stderr, "motif too long\n");
            return 0;
        }
        strcpy(upper_arg, arg);
        for (i = 0; upper_arg[i] != '\0'; ++i) {
            upper_arg[i] = (char)toupper((unsigned char)upper_arg[i]);
        }
        if (!load_fasta_sequence(path, &data, &len)) {
            return 0;
        }
        count = count_overlapping(data, len, upper_arg);
        snprintf(out, OUT_CAP, "%llu", (unsigned long long)count);
        free(data);
        return 1;
    }

    if (strcmp(kind, "fasta-base-histogram") == 0) {
        uint64_t a = 0, c = 0, g = 0, t = 0, n = 0, other = 0;
        size_t i;
        if (arg[0] != '\0' && strcmp(arg, "-") != 0) {
            fprintf(stderr, "fasta-base-histogram takes '-' as its argument\n");
            return 0;
        }
        if (!load_fasta_sequence(path, &data, &len)) {
            return 0;
        }
        for (i = 0; i < len; ++i) {
            switch (data[i]) {
                case 0: break;
                case 'A': ++a; break;
                case 'C': ++c; break;
                case 'G': ++g; break;
                case 'T': ++t; break;
                case 'N': ++n; break;
                default: ++other; break;
            }
        }
        snprintf(out, OUT_CAP, "A=%llu,C=%llu,G=%llu,T=%llu,N=%llu,other=%llu",
                 (unsigned long long)a, (unsigned long long)c,
                 (unsigned long long)g, (unsigned long long)t,
                 (unsigned long long)n, (unsigned long long)other);
        free(data);
        return 1;
    }

    fprintf(stderr, "unknown biology operation: %s\n", kind);
    return 0;
}

static int shell_quote(char *out, size_t cap, const char *s) {
    size_t used = 0;
    if (used + 1 >= cap) return 0;
    out[used++] = '\'';
    while (*s != '\0') {
        if (*s == '\'') {
            const char *q = "'\\''";
            size_t qlen = strlen(q);
            if (used + qlen >= cap) return 0;
            memcpy(out + used, q, qlen);
            used += qlen;
        } else {
            if (used + 1 >= cap) return 0;
            out[used++] = *s;
        }
        ++s;
    }
    if (used + 2 > cap) return 0;
    out[used++] = '\'';
    out[used] = '\0';
    return 1;
}

static int candidate_value(const char *candidate, const char *kind, const char *path,
                           const char *arg, char out[OUT_CAP]) {
    char qc[PATH_CAP * 2];
    char qk[ARG_CAP * 2];
    char qp[PATH_CAP * 2];
    char qa[ARG_CAP * 2];
    char command[PATH_CAP * 6];
    FILE *p;
    int status;
    size_t n;

    if (!shell_quote(qc, sizeof(qc), candidate) ||
        !shell_quote(qk, sizeof(qk), kind) ||
        !shell_quote(qp, sizeof(qp), path) ||
        !shell_quote(qa, sizeof(qa), arg)) {
        fprintf(stderr, "candidate command too long\n");
        return 0;
    }
    if (snprintf(command, sizeof(command), "%s %s %s %s", qc, qk, qp, qa) >= (int)sizeof(command)) {
        fprintf(stderr, "candidate command too long\n");
        return 0;
    }
    p = popen(command, "r");
    if (p == NULL) {
        fprintf(stderr, "cannot run candidate %s\n", candidate);
        return 0;
    }
    if (fgets(out, OUT_CAP, p) == NULL) {
        out[0] = '\0';
    }
    if (fgetc(p) != EOF) {
        fprintf(stderr, "candidate emitted more than one output line\n");
        pclose(p);
        return 0;
    }
    status = pclose(p);
    if (status == -1 || !WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        fprintf(stderr, "candidate failed for %s\n", kind);
        return 0;
    }
    trim_eol(out);
    n = strlen(out);
    if (n == 0) {
        fprintf(stderr, "candidate emitted empty result for %s\n", kind);
        return 0;
    }
    return 1;
}

static int run_cases(const char *cases_path, const char *root, const char *candidate,
                     int check_expected) {
    FILE *f = fopen(cases_path, "r");
    char line[LINE_CAP];
    unsigned line_no = 0;
    unsigned passed = 0;
    if (f == NULL) {
        fprintf(stderr, "cannot open cases %s: %s\n", cases_path, strerror(errno));
        return 0;
    }
    while (fgets(line, sizeof(line), f) != NULL) {
        char *field[5];
        size_t count;
        char path[PATH_CAP];
        char expected[OUT_CAP];
        char actual[OUT_CAP];
        ++line_no;
        trim_eol(line);
        if (line[0] == '\0' || line[0] == '#') continue;
        count = split_tsv(line, field, 5);
        if ((check_expected && count != 5) || (!check_expected && count != 4 && count != 5)) {
            fprintf(stderr, "%s:%u: bad case row\n", cases_path, line_no);
            fclose(f);
            return 0;
        }
        if (!join_path(path, sizeof(path), root, field[2])) {
            fprintf(stderr, "%s:%u: path too long\n", cases_path, line_no);
            fclose(f);
            return 0;
        }
        if (!oracle_value(field[1], path, field[3], expected)) {
            fclose(f);
            return 0;
        }
        if (check_expected) {
            if (strcmp(expected, field[4]) != 0) {
                fprintf(stderr, "%s: oracle mismatch: expected %s got %s\n", field[0], field[4], expected);
                fclose(f);
                return 0;
            }
            printf("%s\tPASS\t%s\n", field[0], expected);
        } else if (candidate != NULL) {
            if (!candidate_value(candidate, field[1], path, field[3], actual)) {
                fclose(f);
                return 0;
            }
            if (strcmp(expected, actual) != 0) {
                fprintf(stderr, "%s: candidate mismatch: oracle %s candidate %s\n",
                        field[0], expected, actual);
                fclose(f);
                return 0;
            }
            printf("%s\tPASS\t%s\n", field[0], actual);
        } else {
            printf("%s\t%s\n", field[0], expected);
        }
        ++passed;
    }
    fclose(f);
    if (passed == 0) {
        fprintf(stderr, "case manifest is empty\n");
        return 0;
    }
    return 1;
}

static void usage(const char *argv0) {
    fprintf(stderr,
            "usage:\n"
            "  %s verify-corpus SOURCES.tsv CORPUS_ROOT\n"
            "  %s oracle CASES.tsv CORPUS_ROOT\n"
            "  %s compare CASES.tsv CORPUS_ROOT CANDIDATE\n"
            "  %s self-test CASES.tsv FIXTURE_ROOT\n"
            "  %s OPERATION FILE ARG\n",
            argv0, argv0, argv0, argv0, argv0);
}

int main(int argc, char **argv) {
    if (argc == 4 && strcmp(argv[1], "verify-corpus") == 0) {
        return verify_corpus(argv[2], argv[3]) ? 0 : 1;
    }
    if (argc == 4 && strcmp(argv[1], "oracle") == 0) {
        return run_cases(argv[2], argv[3], NULL, 0) ? 0 : 1;
    }
    if (argc == 5 && strcmp(argv[1], "compare") == 0) {
        return run_cases(argv[2], argv[3], argv[4], 0) ? 0 : 1;
    }
    if (argc == 4 && strcmp(argv[1], "self-test") == 0) {
        return run_cases(argv[2], argv[3], NULL, 1) ? 0 : 1;
    }
    if (argc == 4) {
        char value[OUT_CAP];
        if (oracle_value(argv[1], argv[2], argv[3], value)) {
            printf("%s\n", value);
            return 0;
        }
    }
    usage(argv[0]);
    return 2;
}
