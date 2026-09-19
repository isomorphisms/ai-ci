#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAX_GROUPS 128
#define MAX_CONCEPTS 512
#define MAX_ROWS 4096
#define MAX_NAME 256
#define MAX_CONCEPT 512
#define MAX_LINE 8192
#define MAX_TEXT (1024 * 1024)

struct concept_set {
    char name[MAX_NAME];
    char concepts[MAX_CONCEPTS][MAX_CONCEPT];
    size_t count;
};

struct map_row {
    char hardware[MAX_NAME];
    char software[MAX_NAME];
    int hardware_only;
};

struct output_row {
    char hardware[MAX_NAME];
    char software[MAX_NAME];
    char relation[64];
    char concept[MAX_CONCEPT];
};

static void strip_newline(char *line) {
    size_t n = strlen(line);
    while (n && (line[n - 1] == '\n' || line[n - 1] == '\r')) line[--n] = '\0';
}

static void trim(char *s) {
    char *start = s;
    while (*start && isspace((unsigned char)*start)) ++start;
    if (start != s) memmove(s, start, strlen(start) + 1);
    size_t n = strlen(s);
    while (n && isspace((unsigned char)s[n - 1])) s[--n] = '\0';
}

static int copy_text(char *dst, size_t cap, const char *src) {
    size_t n = strlen(src);
    if (n >= cap) return -1;
    memcpy(dst, src, n + 1);
    return 0;
}

static int read_all(const char *path, char **out) {
    FILE *fp = fopen(path, "rb");
    if (!fp) return -1;
    if (fseek(fp, 0, SEEK_END) != 0) { fclose(fp); return -1; }
    long end = ftell(fp);
    if (end < 0 || end > MAX_TEXT || fseek(fp, 0, SEEK_SET) != 0) { fclose(fp); return -1; }
    char *buf = malloc((size_t)end + 1);
    if (!buf) { fclose(fp); return -1; }
    if (end && fread(buf, 1, (size_t)end, fp) != (size_t)end) { free(buf); fclose(fp); return -1; }
    buf[end] = '\0';
    fclose(fp); *out = buf; return 0;
}

static int is_identifier_char(unsigned char c) {
    return isalnum(c) || c == '_';
}

static const char *skip_space(const char *p) {
    while (*p && isspace((unsigned char)*p)) ++p;
    return p;
}

static int parse_quoted(const char **cursor, char *out, size_t cap) {
    const char *p = skip_space(*cursor);
    if (*p != '"') return -1;
    ++p;
    size_t n = 0;
    while (*p && *p != '"') {
        unsigned char c = (unsigned char)*p++;
        if (c == '\\') {
            unsigned char e = (unsigned char)*p++;
            if (!e) return -1;
            if (e == 'n') c = '\n';
            else if (e == 'r') c = '\r';
            else if (e == 't') c = '\t';
            else if (e == '\\') c = '\\';
            else if (e == '"') c = '"';
            else {
                if (n + 2 >= cap) return -1;
                out[n++] = '\\'; c = e;
            }
        }
        if (n + 1 >= cap) return -1;
        out[n++] = (char)c;
    }
    if (*p != '"') return -1;
    out[n] = '\0';
    *cursor = p + 1;
    return 0;
}

static int first_line_is_display(const char *line) {
    if (strcmp(line, "DD") == 0 || strcmp(line, "CC") == 0 || strcmp(line, "SS") == 0 ||
        strcmp(line, "𝔽") == 0) return 1;
    for (const unsigned char *p = (const unsigned char *)line; *p; ++p) {
        if (*p < 128 && isalnum(*p)) return 0;
    }
    return line[0] != '\0';
}

static const char *alias_word(const char *word) {
    if (strcmp(word, "PAIRED") == 0) return "PAIR";
    if (strcmp(word, "QUOTES") == 0) return "QUOTE";
    if (strcmp(word, "DELIMITERS") == 0) return "DELIMITER";
    if (strcmp(word, "SPACES") == 0) return "SPACE";
    if (strcmp(word, "CHARACTERS") == 0) return "CHARACTER";
    return word;
}

static int append_word(char *out, size_t cap, const char *word) {
    const char *mapped = alias_word(word);
    size_t have = strlen(out), n = strlen(mapped);
    if (have + (have ? 1 : 0) + n >= cap) return -1;
    if (have) out[have++] = ' ';
    memcpy(out + have, mapped, n + 1);
    return 0;
}

static void fold_compatibility_digits(char *text) {
    const unsigned char *src = (const unsigned char *)text;
    char *dst = text;
    while (*src) {
        if (src[0] == 0xE2 && src[1] == 0x82 && src[2] >= 0x80 && src[2] <= 0x89) {
            *dst++ = (char)('0' + (src[2] - 0x80));
            src += 3;
        } else if (src[0] == 0xE2 && src[1] == 0x81 && src[2] == 0xB0) {
            *dst++ = '0'; src += 3;
        } else if (src[0] == 0xE2 && src[1] == 0x81 && src[2] >= 0xB4 && src[2] <= 0xB9) {
            *dst++ = (char)('4' + (src[2] - 0xB4)); src += 3;
        } else if (src[0] == 0xC2 && src[1] == 0xB9) {
            *dst++ = '1'; src += 2;
        } else if (src[0] == 0xC2 && src[1] == 0xB2) {
            *dst++ = '2'; src += 2;
        } else if (src[0] == 0xC2 && src[1] == 0xB3) {
            *dst++ = '3'; src += 2;
        } else {
            *dst++ = (char)*src++;
        }
    }
    *dst = '\0';
}

static int normalize_concept(const char *label, char *out, size_t cap) {
    out[0] = '\0';
    if (strcmp(label, "λ") == 0) return copy_text(out, cap, "LAMBDA");
    if (strcmp(label, "ƒ") == 0) return copy_text(out, cap, "FUNCTION");
    if (strcmp(label, "χ") == 0) return copy_text(out, cap, "Χ");

    char buf[MAX_CONCEPT * 2];
    if (copy_text(buf, sizeof buf, label) != 0) return -1;
    fold_compatibility_digits(buf);
    char *segments[64];
    size_t segment_count = 0;
    char *save = NULL;
    for (char *part = strtok_r(buf, "\n", &save); part && segment_count < 64; part = strtok_r(NULL, "\n", &save)) {
        trim(part);
        if (*part) segments[segment_count++] = part;
    }
    if (!segment_count) return 0;
    size_t first = segment_count > 1 && first_line_is_display(segments[0]) ? 1 : 0;

    int last_kind = 0;
    char word[MAX_CONCEPT];
    size_t wn = 0;
    for (size_t si = first; si < segment_count; ++si) {
        const unsigned char *p = (const unsigned char *)segments[si];
        while (*p) {
            int kind = (*p < 128 && isalpha(*p)) ? 1 : (*p < 128 && isdigit(*p)) ? 2 : 0;
            if (kind == 0) {
                if (wn) { word[wn] = '\0'; if (append_word(out, cap, word) != 0) return -1; wn = 0; }
                last_kind = 0; ++p; continue;
            }
            if (wn && last_kind != kind) {
                word[wn] = '\0'; if (append_word(out, cap, word) != 0) return -1; wn = 0;
            }
            if (wn + 1 >= sizeof word) return -1;
            word[wn++] = (char)(kind == 1 ? toupper(*p) : *p);
            last_kind = kind;
            ++p;
        }
        if (wn) { word[wn] = '\0'; if (append_word(out, cap, word) != 0) return -1; wn = 0; }
        last_kind = 0;
    }
    return 0;
}

static int add_concept(struct concept_set *set, const char *concept) {
    if (!*concept) return 0;
    for (size_t i = 0; i < set->count; ++i) if (strcmp(set->concepts[i], concept) == 0) return 0;
    if (set->count >= MAX_CONCEPTS || copy_text(set->concepts[set->count], MAX_CONCEPT, concept) != 0) return -1;
    ++set->count; return 0;
}

static struct concept_set *find_group(struct concept_set *sets, size_t count, const char *name) {
    for (size_t i = 0; i < count; ++i) if (strcmp(sets[i].name, name) == 0) return &sets[i];
    return NULL;
}

static int parse_board_header(const char *line, char *name, size_t cap) {
    char local[MAX_LINE];
    if (copy_text(local, sizeof local, line) != 0) return 0;
    trim(local);
    char *colon = strstr(local, ": Board");
    if (!colon || colon[7] != '\0') return 0;
    *colon = '\0'; trim(local);
    if (!*local || !(isalpha((unsigned char)local[0]) || local[0] == '_')) return 0;
    for (char *p = local; *p; ++p) if (!is_identifier_char((unsigned char)*p)) return 0;
    return copy_text(name, cap, local) == 0;
}

static int line_has_board_definition(const char *line, const char *name) {
    char prefix[MAX_NAME + 32];
    snprintf(prefix, sizeof prefix, "%s = MkBoard", name);
    char local[MAX_LINE];
    if (copy_text(local, sizeof local, line) != 0) return 0;
    trim(local);
    return strncmp(local, prefix, strlen(prefix)) == 0;
}

static int parse_hardware_text(const char *text, struct concept_set *boards, size_t *board_count) {
    char *copy = strdup(text);
    if (!copy) return -1;
    size_t count = 0;
    char pending[MAX_NAME] = "";
    struct concept_set *current = NULL;
    char *save = NULL;
    for (char *line = strtok_r(copy, "\n", &save); line; line = strtok_r(NULL, "\n", &save)) {
        char name[MAX_NAME];
        if (parse_board_header(line, name, sizeof name)) {
            if (find_group(boards, count, name)) { free(copy); return -1; }
            if (count >= MAX_GROUPS || copy_text(pending, sizeof pending, name) != 0) { free(copy); return -1; }
            current = NULL;
            continue;
        }
        if (*pending && line_has_board_definition(line, pending)) {
            memset(&boards[count], 0, sizeof boards[count]);
            if (copy_text(boards[count].name, sizeof boards[count].name, pending) != 0) { free(copy); return -1; }
            current = &boards[count++]; pending[0] = '\0';
            continue;
        }
        if (!current) continue;

        for (const char *p = line; *p; ++p) {
            int labels = 0;
            size_t advance = 0;
            if ((p == line || !is_identifier_char((unsigned char)p[-1])) && strncmp(p, "one", 3) == 0 && !is_identifier_char((unsigned char)p[3])) { labels = 1; advance = 3; }
            else if ((p == line || !is_identifier_char((unsigned char)p[-1])) && strncmp(p, "two", 3) == 0 && !is_identifier_char((unsigned char)p[3])) { labels = 2; advance = 3; }
            else if ((p == line || !is_identifier_char((unsigned char)p[-1])) && strncmp(p, "three", 5) == 0 && !is_identifier_char((unsigned char)p[5])) { labels = 3; advance = 5; }
            if (!labels) continue;
            const char *q = p + advance;
            char joined[MAX_CONCEPT * 2] = "";
            for (int i = 0; i < labels; ++i) {
                char piece[MAX_CONCEPT];
                if (parse_quoted(&q, piece, sizeof piece) != 0) { free(copy); return -1; }
                if (strlen(joined) + strlen(piece) + 2 >= sizeof joined) { free(copy); return -1; }
                if (*joined) strcat(joined, " ");
                strcat(joined, piece);
            }
            char concept[MAX_CONCEPT];
            if (normalize_concept(joined, concept, sizeof concept) != 0 || add_concept(current, concept) != 0) { free(copy); return -1; }
            p = q - 1;
        }
    }
    free(copy);
    if (count == 0) return -1;
    *board_count = count; return 0;
}

static int match_token(const char *base, const char *p, const char *token) {
    size_t n = strlen(token);
    if (strncmp(p, token, n) != 0) return 0;
    if (p != base && is_identifier_char((unsigned char)p[-1])) return 0;
    return !is_identifier_char((unsigned char)p[n]);
}

static int parse_software_text(const char *text, struct concept_set *pages, size_t *page_count) {
    size_t count = 0;
    struct concept_set *current = NULL;
    const char *p = text;
    while (*p) {
        if (match_token(text, p, "Page")) {
            const char *q = p + 4;
            char name[MAX_NAME];
            if (parse_quoted(&q, name, sizeof name) == 0) {
                if (find_group(pages, count, name) || count >= MAX_GROUPS) return -1;
                memset(&pages[count], 0, sizeof pages[count]);
                if (copy_text(pages[count].name, sizeof pages[count].name, name) != 0) return -1;
                current = &pages[count++]; p = q; continue;
            }
        }
        if (current && (match_token(text, p, "text_key") || match_token(text, p, "pair_key") || match_token(text, p, "Key"))) {
            size_t n = match_token(text, p, "text_key") ? 8 : match_token(text, p, "pair_key") ? 8 : 3;
            const char *q = p + n;
            char label[MAX_CONCEPT * 2], concept[MAX_CONCEPT];
            if (parse_quoted(&q, label, sizeof label) != 0 || normalize_concept(label, concept, sizeof concept) != 0 ||
                add_concept(current, concept) != 0) return -1;
            p = q; continue;
        }
        ++p;
    }
    if (count == 0) return -1;
    *page_count = count; return 0;
}

static int split_tsv(char *line, char **fields, size_t wanted) {
    size_t count = 0; char *start = line;
    for (char *p = line;; ++p) {
        if (*p == '\t' || *p == '\0') {
            if (count >= wanted) return -1;
            if (*p == '\t') { *p = '\0'; fields[count++] = start; start = p + 1; continue; }
            fields[count++] = start; break;
        }
    }
    return count == wanted ? 0 : -1;
}

static int load_map(const char *path, struct map_row *rows, size_t *count, int diagnostics) {
    FILE *fp = fopen(path, "r");
    if (!fp) { if (diagnostics) fprintf(stderr, "keyboard cross-reference error: %s: %s\n", path, strerror(errno)); return -1; }
    char line[MAX_LINE];
    if (!fgets(line, sizeof line, fp)) { fclose(fp); return -1; }
    strip_newline(line);
    if (strcmp(line, "hardware_board\tsoftware_page\tmode") != 0) { fclose(fp); return -1; }
    size_t n = 0; unsigned long line_number = 1;
    while (fgets(line, sizeof line, fp)) {
        ++line_number; strip_newline(line); char *f[3];
        if (n >= MAX_ROWS || split_tsv(line, f, 3) != 0 || !*f[0] || !*f[1] || !*f[2]) goto bad;
        for (size_t i = 0; i < n; ++i) {
            if (strcmp(rows[i].hardware, f[0]) == 0) goto bad;
            if (strcmp(f[2], "mirror") == 0 && !rows[i].hardware_only && strcmp(rows[i].software, f[1]) == 0) goto bad;
        }
        if (copy_text(rows[n].hardware, sizeof rows[n].hardware, f[0]) != 0 ||
            copy_text(rows[n].software, sizeof rows[n].software, f[1]) != 0) goto bad;
        if (strcmp(f[2], "mirror") == 0) {
            if (strcmp(f[1], "-") == 0) goto bad;
            rows[n].hardware_only = 0;
        } else if (strcmp(f[2], "hardware_only") == 0) {
            if (strcmp(f[1], "-") != 0) goto bad;
            rows[n].hardware_only = 1;
        } else goto bad;
        ++n; continue;
    bad:
        if (diagnostics) fprintf(stderr, "keyboard cross-reference error: %s:%lu: invalid map row\n", path, line_number);
        fclose(fp); return -1;
    }
    fclose(fp); *count = n; return 0;
}

static int concept_has(const struct concept_set *set, const char *concept) {
    for (size_t i = 0; i < set->count; ++i) if (strcmp(set->concepts[i], concept) == 0) return 1;
    return 0;
}

static int add_output(struct output_row *rows, size_t *count, const char *hardware,
                      const char *software, const char *relation, const char *concept) {
    if (*count >= MAX_ROWS) return -1;
    struct output_row *r = &rows[(*count)++];
    return copy_text(r->hardware, sizeof r->hardware, hardware) ||
           copy_text(r->software, sizeof r->software, software) ||
           copy_text(r->relation, sizeof r->relation, relation) ||
           copy_text(r->concept, sizeof r->concept, concept) ? -1 : 0;
}

static int output_cmp(const void *a, const void *b) {
    const struct output_row *x = a, *y = b;
    int c = strcmp(x->hardware, y->hardware); if (c) return c;
    c = strcmp(x->software, y->software); if (c) return c;
    c = strcmp(x->relation, y->relation); if (c) return c;
    return strcmp(x->concept, y->concept);
}

static int map_has_hardware(const struct map_row *map, size_t count, const char *name) {
    for (size_t i = 0; i < count; ++i) if (strcmp(map[i].hardware, name) == 0) return 1;
    return 0;
}

static int map_mirrors_software(const struct map_row *map, size_t count, const char *name) {
    for (size_t i = 0; i < count; ++i) if (!map[i].hardware_only && strcmp(map[i].software, name) == 0) return 1;
    return 0;
}

static int observe(const struct concept_set *boards, size_t board_count,
                   const struct concept_set *pages, size_t page_count,
                   const struct map_row *map, size_t map_count,
                   struct output_row *rows, size_t *row_count) {
    size_t n = 0;
    for (size_t i = 0; i < map_count; ++i) {
        struct concept_set *board = find_group((struct concept_set *)boards, board_count, map[i].hardware);
        if (!board) { fprintf(stderr, "keyboard cross-reference error: mapped hardware board %s is absent\n", map[i].hardware); return -1; }
        if (map[i].hardware_only) {
            if (add_output(rows, &n, map[i].hardware, "", "hardware_only_board", "") != 0) return -1;
            continue;
        }
        struct concept_set *page = find_group((struct concept_set *)pages, page_count, map[i].software);
        if (!page) { fprintf(stderr, "keyboard cross-reference error: mapped software page %s is absent\n", map[i].software); return -1; }
        for (size_t j = 0; j < board->count; ++j)
            if (add_output(rows, &n, board->name, page->name,
                           concept_has(page, board->concepts[j]) ? "shared" : "hardware_only",
                           board->concepts[j]) != 0) return -1;
        for (size_t j = 0; j < page->count; ++j)
            if (!concept_has(board, page->concepts[j]) &&
                add_output(rows, &n, board->name, page->name, "software_only", page->concepts[j]) != 0) return -1;
    }
    for (size_t i = 0; i < board_count; ++i)
        if (!map_has_hardware(map, map_count, boards[i].name) &&
            add_output(rows, &n, boards[i].name, "", "unmapped_hardware_board", "") != 0) return -1;
    for (size_t i = 0; i < page_count; ++i)
        if (!map_mirrors_software(map, map_count, pages[i].name) &&
            add_output(rows, &n, "", pages[i].name, "unmapped_software_page", "") != 0) return -1;
    qsort(rows, n, sizeof rows[0], output_cmp); *row_count = n; return 0;
}

static int write_rows(FILE *fp, const struct output_row *rows, size_t count) {
    fputs("hardware_board\tsoftware_page\trelation\tconcept\n", fp);
    for (size_t i = 0; i < count; ++i)
        fprintf(fp, "%s\t%s\t%s\t%s\n", rows[i].hardware, rows[i].software, rows[i].relation, rows[i].concept);
    return ferror(fp) ? -1 : 0;
}

static int relation_present(const struct output_row *rows, size_t count, const char *rel,
                            const char *hardware, const char *software, const char *concept) {
    for (size_t i = 0; i < count; ++i)
        if (!strcmp(rows[i].relation, rel) && !strcmp(rows[i].hardware, hardware) &&
            !strcmp(rows[i].software, software) && !strcmp(rows[i].concept, concept)) return 1;
    return 0;
}

static int self_test(void) {
    static const char *hardware =
        "movement : Board\n"
        "movement = MkBoard \"cursor\"\n"
        "  [ [ one \"MOVE\" ] ]\n\n"
        "programming : Board\n"
        "programming = MkBoard \"program\"\n"
        "  [ [ two \"ASSIGN\" \"LEFT\", one \"LAMBDA\", one \"FLOAT\", two \"NEW\" \"THING\" ] ]\n";
    static const char *software =
        "pages =\n"
        "  [ Page \"Programming\"\n"
        "      [ Row\n"
        "          [ text_key \"←\\nASSIGN\" \"←\", text_key \"λ\" \"λ\"\n"
        "          , text_key \"𝔽\\nFLOAT\" \"𝔽\", text_key \"THIN\\nSPACE\" \" \"\n"
        "          ]\n"
        "      ]\n"
        "  , Page \"Unicode\"\n"
        "      [ Row [ text_key \"∞\" \"∞\" ] ]\n"
        "  ]\n";
    struct concept_set *boards = calloc(MAX_GROUPS, sizeof *boards);
    struct concept_set *pages = calloc(MAX_GROUPS, sizeof *pages);
    struct map_row *map = calloc(MAX_ROWS, sizeof *map);
    struct output_row *rows = calloc(MAX_ROWS, sizeof *rows);
    if (!boards || !pages || !map || !rows) return 1;
    size_t bc = 0, pc = 0;
    if (parse_hardware_text(hardware, boards, &bc) != 0 || parse_software_text(software, pages, &pc) != 0) return 1;
    struct concept_set *programming = find_group(boards, bc, "programming");
    struct concept_set *software_programming = find_group(pages, pc, "Programming");
    if (!programming || !software_programming ||
        !concept_has(programming, "ASSIGN LEFT") || !concept_has(programming, "LAMBDA") ||
        !concept_has(programming, "FLOAT") || !concept_has(programming, "NEW THING") ||
        !concept_has(software_programming, "ASSIGN") || !concept_has(software_programming, "LAMBDA") ||
        !concept_has(software_programming, "FLOAT") || !concept_has(software_programming, "THIN SPACE")) {
        fprintf(stderr, "self-test: parser/normalizer failed\n"); return 1;
    }
    char normalized[MAX_CONCEPT];
    if (normalize_concept("VIEW₁", normalized, sizeof normalized) != 0 || strcmp(normalized, "VIEW 1") != 0 ||
        normalize_concept("χ", normalized, sizeof normalized) != 0 || strcmp(normalized, "Χ") != 0) {
        fprintf(stderr, "self-test: Unicode compatibility normalization failed\n"); return 1;
    }

    char dir[] = "/tmp/aici-keyboard-XXXXXX";
    if (!mkdtemp(dir)) return 1;
    char map_path[1024]; snprintf(map_path, sizeof map_path, "%s/map.tsv", dir);
    FILE *fp = fopen(map_path, "w"); if (!fp) return 1;
    fputs("hardware_board\tsoftware_page\tmode\nmovement\t-\thardware_only\nprogramming\tProgramming\tmirror\n", fp); fclose(fp);
    size_t mc = 0;
    if (load_map(map_path, map, &mc, 1) != 0) return 1;
    size_t rc = 0;
    if (observe(boards, bc, pages, pc, map, mc, rows, &rc) != 0) return 1;
    if (!relation_present(rows, rc, "shared", "programming", "Programming", "FLOAT") ||
        !relation_present(rows, rc, "shared", "programming", "Programming", "LAMBDA") ||
        !relation_present(rows, rc, "hardware_only", "programming", "Programming", "NEW THING") ||
        !relation_present(rows, rc, "software_only", "programming", "Programming", "THIN SPACE") ||
        !relation_present(rows, rc, "hardware_only_board", "movement", "", "") ||
        !relation_present(rows, rc, "unmapped_software_page", "", "Unicode", "")) {
        fprintf(stderr, "self-test: directional relation output failed\n"); return 1;
    }

    struct map_row only_programming[] = {{{"programming"}, {"Programming"}, 0}};
    if (observe(boards, bc, pages, pc, only_programming, 1, rows, &rc) != 0 ||
        !relation_present(rows, rc, "unmapped_hardware_board", "movement", "", "")) {
        fprintf(stderr, "self-test: unmapped hardware board was ignored\n"); return 1;
    }

    fp = fopen(map_path, "w"); if (!fp) return 1;
    fputs("hardware_board\tsoftware_page\tmode\nprogramming\tProgramming\tmirror\nprogramming\t-\thardware_only\n", fp); fclose(fp);
    if (load_map(map_path, map, &mc, 0) == 0) { fprintf(stderr, "self-test: duplicate hardware map accepted\n"); return 1; }

    struct output_row one[] = {{{"programming"}, {"Programming"}, {"shared"}, {"FLOAT"}}};
    fp = tmpfile(); if (!fp) return 1; if (write_rows(fp, one, 1) != 0) return 1;
    fflush(fp); rewind(fp); char got[256]; size_t gn = fread(got, 1, sizeof got - 1, fp); got[gn] = '\0'; fclose(fp);
    const char *wanted = "hardware_board\tsoftware_page\trelation\tconcept\nprogramming\tProgramming\tshared\tFLOAT\n";
    if (strcmp(got, wanted) != 0) { fprintf(stderr, "self-test: TSV output unstable\n"); return 1; }

    unlink(map_path); rmdir(dir);
    free(rows); free(map); free(pages); free(boards);
    puts("PASS  keyboard cross-reference self-test"); return 0;
}

static void usage(const char *argv0) {
    fprintf(stderr, "usage: %s --hardware FILE --software FILE --map FILE --output FILE\n       %s --self-test\n", argv0, argv0);
}

int main(int argc, char **argv) {
    if (argc == 2 && strcmp(argv[1], "--self-test") == 0) return self_test();
    const char *hardware_path = NULL, *software_path = NULL, *map_path = NULL, *output_path = "-";
    for (int i = 1; i < argc; ++i) {
        if (!strcmp(argv[i], "--hardware") && i + 1 < argc) hardware_path = argv[++i];
        else if (!strcmp(argv[i], "--software") && i + 1 < argc) software_path = argv[++i];
        else if (!strcmp(argv[i], "--map") && i + 1 < argc) map_path = argv[++i];
        else if (!strcmp(argv[i], "--output") && i + 1 < argc) output_path = argv[++i];
        else { usage(argv[0]); return 2; }
    }
    if (!hardware_path || !software_path || !map_path) { usage(argv[0]); return 2; }

    char *hardware_text = NULL, *software_text = NULL;
    if (read_all(hardware_path, &hardware_text) != 0) {
        fprintf(stderr, "keyboard cross-reference error: cannot read hardware source %s\n", hardware_path); return 2;
    }
    if (read_all(software_path, &software_text) != 0) {
        fprintf(stderr, "keyboard cross-reference error: cannot read software source %s\n", software_path); free(hardware_text); return 2;
    }
    struct concept_set *boards = calloc(MAX_GROUPS, sizeof *boards);
    struct concept_set *pages = calloc(MAX_GROUPS, sizeof *pages);
    struct map_row *map = calloc(MAX_ROWS, sizeof *map);
    struct output_row *rows = calloc(MAX_ROWS, sizeof *rows);
    if (!boards || !pages || !map || !rows) { free(hardware_text); free(software_text); return 2; }
    size_t board_count = 0, page_count = 0;
    if (parse_hardware_text(hardware_text, boards, &board_count) != 0) {
        fprintf(stderr, "keyboard cross-reference error: hardware source contains no usable Board definitions\n"); free(hardware_text); free(software_text); return 2;
    }
    if (parse_software_text(software_text, pages, &page_count) != 0) {
        fprintf(stderr, "keyboard cross-reference error: software source contains no usable Page definitions\n"); free(hardware_text); free(software_text); return 2;
    }
    free(hardware_text); free(software_text);

    size_t map_count = 0;
    if (load_map(map_path, map, &map_count, 1) != 0) return 2;
    size_t row_count = 0;
    if (observe(boards, board_count, pages, page_count, map, map_count, rows, &row_count) != 0) return 2;

    FILE *fp = stdout;
    if (strcmp(output_path, "-") != 0) {
        fp = fopen(output_path, "w");
        if (!fp) { fprintf(stderr, "keyboard cross-reference error: cannot open output %s\n", output_path); return 2; }
    }
    int rc = write_rows(fp, rows, row_count);
    if (fp != stdout) fclose(fp);
    free(rows); free(map); free(pages); free(boards);
    return rc == 0 ? 0 : 2;
}
