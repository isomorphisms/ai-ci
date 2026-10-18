#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXIMUM_ROWS 64
#define MAXIMUM_FIELDS 24
#define IDENTIFIER_SIZE 160
#define REFERENCE_SIZE 1024
#define TEXT_SIZE 2048
#define LINE_SIZE 16384
#define PATH_SIZE 4096

typedef struct {
    char schema[IDENTIFIER_SIZE];
    char incident_id[IDENTIFIER_SIZE];
    int expected_specimens;
    int expected_seeds;
    int expected_candidates;
    int expected_confirmed;
    int expected_benign;
    int expected_unknown;
    int expected_inaccessible;
    int expected_obligations;
    int expected_consumers;
    char coverage_scope[TEXT_SIZE];
} Registration;

typedef struct {
    char schema[IDENTIFIER_SIZE];
    char incident_id[IDENTIFIER_SIZE];
    char specimen_id[IDENTIFIER_SIZE];
    char source_repository[IDENTIFIER_SIZE];
    char source_revision[IDENTIFIER_SIZE];
    char source_path[REFERENCE_SIZE];
    char source_sha256[IDENTIFIER_SIZE];
    char original_test_path[REFERENCE_SIZE];
    char original_test_sha256[IDENTIFIER_SIZE];
    char defect_case[IDENTIFIER_SIZE];
    char claimed_property[TEXT_SIZE];
    char original_claim_scope[IDENTIFIER_SIZE];
    char oracle_owner[IDENTIFIER_SIZE];
    char oracle_revision[IDENTIFIER_SIZE];
    char oracle_path[REFERENCE_SIZE];
    char oracle_provenance[TEXT_SIZE];
    char human_confirmation[REFERENCE_SIZE];
    char evidence_class[IDENTIFIER_SIZE];
} Specimen;

typedef struct {
    char seed_id[IDENTIFIER_SIZE];
    char repository[IDENTIFIER_SIZE];
    char revision[IDENTIFIER_SIZE];
    char role[IDENTIFIER_SIZE];
    char boundary[TEXT_SIZE];
} Seed;

typedef struct {
    char search_id[IDENTIFIER_SIZE];
    char category[IDENTIFIER_SIZE];
    int page;
    char last[16];
    char repository_scope[TEXT_SIZE];
    int inventory_rows;
    char evidence_ref[REFERENCE_SIZE];
} SearchPage;

typedef struct {
    char candidate_id[IDENTIFIER_SIZE];
    char seed_id[IDENTIFIER_SIZE];
    char search_id[IDENTIFIER_SIZE];
    char repository[IDENTIFIER_SIZE];
    char revision[IDENTIFIER_SIZE];
    char source_kind[IDENTIFIER_SIZE];
    char locator[REFERENCE_SIZE];
    char claim_scope[TEXT_SIZE];
    char accessible[16];
} Candidate;

typedef struct {
    char candidate_id[IDENTIFIER_SIZE];
    char disposition[IDENTIFIER_SIZE];
    char evidence_ref[REFERENCE_SIZE];
    char basis[TEXT_SIZE];
    char causal_status[TEXT_SIZE];
} Disposition;

typedef struct {
    char obligation_id[IDENTIFIER_SIZE];
    char candidate_id[IDENTIFIER_SIZE];
    char owner_repository[IDENTIFIER_SIZE];
    char owner_record[REFERENCE_SIZE];
    char source_revision[IDENTIFIER_SIZE];
    char dependency_state[IDENTIFIER_SIZE];
    char action[TEXT_SIZE];
    char evidence_limit[TEXT_SIZE];
} Obligation;

typedef struct {
    char consumer_id[IDENTIFIER_SIZE];
    char repository[IDENTIFIER_SIZE];
    char job_id[IDENTIFIER_SIZE];
    char release_path[REFERENCE_SIZE];
    char state[IDENTIFIER_SIZE];
} Consumer;

typedef struct {
    Registration registration;
    Specimen specimens[MAXIMUM_ROWS];
    Seed seeds[MAXIMUM_ROWS];
    SearchPage pages[MAXIMUM_ROWS];
    Candidate candidates[MAXIMUM_ROWS];
    Disposition dispositions[MAXIMUM_ROWS];
    Obligation obligations[MAXIMUM_ROWS];
    Consumer consumers[MAXIMUM_ROWS];
    size_t specimen_count;
    size_t seed_count;
    size_t page_count;
    size_t candidate_count;
    size_t disposition_count;
    size_t obligation_count;
    size_t consumer_count;
    char root[PATH_SIZE];
} Registry;

static const char *const required_seed_ids[] = {
    "aici", "catfood", "coxswain", "flexible-pipes", "holomorphic",
    "idris-shader-backend", "indras-pearls", "kitchen", "pauli", "surfer",
    "wegert"
};

static const char *const required_categories[] = {
    "promotion-caller", "source-test", "template", "wrapper"
};

static const char *const required_consumers[] = {
    "bc-a05-s02", "bc-a05-s03", "bc-s01-s01"
};

static char last_error_code[IDENTIFIER_SIZE];

static int fail(const char *code, const char *detail) {
    snprintf(last_error_code, sizeof(last_error_code), "%s", code);
    fprintf(stderr, "%s: %s\n", code, detail);
    return 0;
}

static int copy_text(char *target, size_t size, const char *source) {
    int result = snprintf(target, size, "%s", source);
    return result >= 0 && (size_t)result < size;
}

static int join_path(char *target, size_t size, const char *root,
                     const char *relative) {
    int result = snprintf(target, size, "%s/%s", root, relative);
    return result >= 0 && (size_t)result < size;
}

static void trim_line(char *line) {
    size_t length = strlen(line);
    while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
        line[--length] = '\0';
    }
}

static int split_tabs(char *line, char **fields, int maximum) {
    int count = 1;
    char *cursor = line;
    fields[0] = line;
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

static int parse_number(const char *value, int *result) {
    char *end = NULL;
    long parsed;
    if (*value == '\0') return 0;
    errno = 0;
    parsed = strtol(value, &end, 10);
    if (errno != 0 || *end != '\0' || parsed < 0 || parsed > 1000000) return 0;
    *result = (int)parsed;
    return 1;
}

static int lower_hex(const char *value, size_t length) {
    size_t index;
    if (strlen(value) != length) return 0;
    for (index = 0; index < length; ++index) {
        if (!(isdigit((unsigned char)value[index]) ||
              (value[index] >= 'a' && value[index] <= 'f'))) return 0;
    }
    return 1;
}

static int present(const char *value) {
    return value[0] != '\0' && strcmp(value, "-") != 0;
}

static int identifier(const char *value) {
    const unsigned char *cursor = (const unsigned char *)value;
    if (*cursor == '\0') return 0;
    while (*cursor != '\0') {
        if (!(isalnum(*cursor) || *cursor == '-' || *cursor == '_' ||
              *cursor == '.')) return 0;
        ++cursor;
    }
    return 1;
}

static int one_of(const char *value, const char *const *items, size_t count) {
    size_t index;
    for (index = 0; index < count; ++index) {
        if (strcmp(value, items[index]) == 0) return 1;
    }
    return 0;
}

typedef int (*RowReader)(char **, void *);

static int load_table(const char *path, const char *header, int field_count,
                      void *rows, size_t row_size, size_t *row_count,
                      RowReader reader) {
    FILE *file = fopen(path, "r");
    char line[LINE_SIZE];
    int line_number = 0;
    if (file == NULL) return fail("AICI-DEFECT-INPUT", path);
    if (fgets(line, sizeof(line), file) == NULL) {
        fclose(file);
        return fail("AICI-DEFECT-EMPTY", path);
    }
    ++line_number;
    if (strchr(line, '\n') == NULL && !feof(file)) {
        fclose(file);
        return fail("AICI-DEFECT-LINE-LONG", path);
    }
    trim_line(line);
    if (strcmp(line, header) != 0) {
        fclose(file);
        return fail("AICI-DEFECT-HEADER", path);
    }
    while (fgets(line, sizeof(line), file) != NULL) {
        char *fields[MAXIMUM_FIELDS];
        int count;
        void *row;
        ++line_number;
        if (strchr(line, '\n') == NULL && !feof(file)) {
            fclose(file);
            return fail("AICI-DEFECT-LINE-LONG", path);
        }
        trim_line(line);
        if (line[0] == '\0') {
            fclose(file);
            return fail("AICI-DEFECT-BLANK-ROW", path);
        }
        count = split_tabs(line, fields, MAXIMUM_FIELDS);
        if (count != field_count || *row_count >= MAXIMUM_ROWS) {
            fclose(file);
            return fail("AICI-DEFECT-FIELD-COUNT", path);
        }
        row = (char *)rows + (*row_count * row_size);
        memset(row, 0, row_size);
        if (!reader(fields, row)) {
            char detail[PATH_SIZE + 64];
            snprintf(detail, sizeof(detail), "%s:%d", path, line_number);
            fclose(file);
            return fail("AICI-DEFECT-VALUE-LONG", detail);
        }
        ++*row_count;
    }
    if (ferror(file)) {
        fclose(file);
        return fail("AICI-DEFECT-READ", path);
    }
    fclose(file);
    return 1;
}

#define COPY_FIELD(ROW, MEMBER, INDEX) \
    copy_text((ROW)->MEMBER, sizeof((ROW)->MEMBER), fields[(INDEX)])

static int read_registration(char **fields, void *record) {
    Registration *row = record;
    return COPY_FIELD(row, schema, 0) && COPY_FIELD(row, incident_id, 1) &&
        parse_number(fields[2], &row->expected_specimens) &&
        parse_number(fields[3], &row->expected_seeds) &&
        parse_number(fields[4], &row->expected_candidates) &&
        parse_number(fields[5], &row->expected_confirmed) &&
        parse_number(fields[6], &row->expected_benign) &&
        parse_number(fields[7], &row->expected_unknown) &&
        parse_number(fields[8], &row->expected_inaccessible) &&
        parse_number(fields[9], &row->expected_obligations) &&
        parse_number(fields[10], &row->expected_consumers) &&
        COPY_FIELD(row, coverage_scope, 11);
}

static int read_specimen(char **fields, void *record) {
    Specimen *row = record;
    return COPY_FIELD(row, schema, 0) && COPY_FIELD(row, incident_id, 1) &&
        COPY_FIELD(row, specimen_id, 2) && COPY_FIELD(row, source_repository, 3) &&
        COPY_FIELD(row, source_revision, 4) && COPY_FIELD(row, source_path, 5) &&
        COPY_FIELD(row, source_sha256, 6) && COPY_FIELD(row, original_test_path, 7) &&
        COPY_FIELD(row, original_test_sha256, 8) && COPY_FIELD(row, defect_case, 9) &&
        COPY_FIELD(row, claimed_property, 10) && COPY_FIELD(row, original_claim_scope, 11) &&
        COPY_FIELD(row, oracle_owner, 12) && COPY_FIELD(row, oracle_revision, 13) &&
        COPY_FIELD(row, oracle_path, 14) && COPY_FIELD(row, oracle_provenance, 15) &&
        COPY_FIELD(row, human_confirmation, 16) && COPY_FIELD(row, evidence_class, 17);
}

static int read_seed(char **fields, void *record) {
    Seed *row = record;
    return COPY_FIELD(row, seed_id, 0) && COPY_FIELD(row, repository, 1) &&
        COPY_FIELD(row, revision, 2) && COPY_FIELD(row, role, 3) &&
        COPY_FIELD(row, boundary, 4);
}

static int read_page(char **fields, void *record) {
    SearchPage *row = record;
    return COPY_FIELD(row, search_id, 0) && COPY_FIELD(row, category, 1) &&
        parse_number(fields[2], &row->page) && COPY_FIELD(row, last, 3) &&
        COPY_FIELD(row, repository_scope, 4) &&
        parse_number(fields[5], &row->inventory_rows) &&
        COPY_FIELD(row, evidence_ref, 6);
}

static int read_candidate(char **fields, void *record) {
    Candidate *row = record;
    return COPY_FIELD(row, candidate_id, 0) && COPY_FIELD(row, seed_id, 1) &&
        COPY_FIELD(row, search_id, 2) && COPY_FIELD(row, repository, 3) &&
        COPY_FIELD(row, revision, 4) && COPY_FIELD(row, source_kind, 5) &&
        COPY_FIELD(row, locator, 6) && COPY_FIELD(row, claim_scope, 7) &&
        COPY_FIELD(row, accessible, 8);
}

static int read_disposition(char **fields, void *record) {
    Disposition *row = record;
    return COPY_FIELD(row, candidate_id, 0) && COPY_FIELD(row, disposition, 1) &&
        COPY_FIELD(row, evidence_ref, 2) && COPY_FIELD(row, basis, 3) &&
        COPY_FIELD(row, causal_status, 4);
}

static int read_obligation(char **fields, void *record) {
    Obligation *row = record;
    return COPY_FIELD(row, obligation_id, 0) && COPY_FIELD(row, candidate_id, 1) &&
        COPY_FIELD(row, owner_repository, 2) && COPY_FIELD(row, owner_record, 3) &&
        COPY_FIELD(row, source_revision, 4) && COPY_FIELD(row, dependency_state, 5) &&
        COPY_FIELD(row, action, 6) && COPY_FIELD(row, evidence_limit, 7);
}

static int read_consumer(char **fields, void *record) {
    Consumer *row = record;
    return COPY_FIELD(row, consumer_id, 0) && COPY_FIELD(row, repository, 1) &&
        COPY_FIELD(row, job_id, 2) && COPY_FIELD(row, release_path, 3) &&
        COPY_FIELD(row, state, 4);
}

#undef COPY_FIELD

static int load_registry(const char *root, Registry *registry) {
    char path[PATH_SIZE];
    size_t count = 0;
    memset(registry, 0, sizeof(*registry));
    if (!copy_text(registry->root, sizeof(registry->root), root)) return 0;
    if (!join_path(path, sizeof(path), root, "registration.tsv") ||
        !load_table(path,
            "schema\tincident_id\texpected_specimens\texpected_seeds\texpected_candidates\texpected_confirmed\texpected_benign\texpected_unknown\texpected_inaccessible\texpected_obligations\texpected_consumers\tcoverage_scope",
            12, &registry->registration, sizeof(registry->registration), &count,
            read_registration) || count != 1) {
        if (count != 1) fail("AICI-DEFECT-REGISTRATION-COUNT", path);
        return 0;
    }
    if (!join_path(path, sizeof(path), root, "specimens.tsv") ||
        !load_table(path,
            "schema\tincident_id\tspecimen_id\tsource_repository\tsource_revision\tsource_path\tsource_sha256\toriginal_test_path\toriginal_test_sha256\tdefect_case\tclaimed_property\toriginal_claim_scope\toracle_owner\toracle_revision\toracle_path\toracle_provenance\thuman_confirmation\tevidence_class",
            18, registry->specimens, sizeof(registry->specimens[0]),
            &registry->specimen_count, read_specimen)) return 0;
    if (!join_path(path, sizeof(path), root, "seeds.tsv") ||
        !load_table(path, "seed_id\trepository\trevision\trole\tboundary", 5,
            registry->seeds, sizeof(registry->seeds[0]), &registry->seed_count,
            read_seed)) return 0;
    if (!join_path(path, sizeof(path), root, "search-pages.tsv") ||
        !load_table(path,
            "search_id\tcategory\tpage\tlast\trepository_scope\tinventory_rows\tevidence_ref",
            7, registry->pages, sizeof(registry->pages[0]), &registry->page_count,
            read_page)) return 0;
    if (!join_path(path, sizeof(path), root, "inventory.tsv") ||
        !load_table(path,
            "candidate_id\tseed_id\tsearch_id\trepository\trevision\tsource_kind\tlocator\tclaim_scope\taccessible",
            9, registry->candidates, sizeof(registry->candidates[0]),
            &registry->candidate_count, read_candidate)) return 0;
    if (!join_path(path, sizeof(path), root, "dispositions.tsv") ||
        !load_table(path,
            "candidate_id\tdisposition\tevidence_ref\tbasis\tcausal_status",
            5, registry->dispositions, sizeof(registry->dispositions[0]),
            &registry->disposition_count, read_disposition)) return 0;
    if (!join_path(path, sizeof(path), root, "obligations.tsv") ||
        !load_table(path,
            "obligation_id\tcandidate_id\towner_repository\towner_record\tsource_revision\tdependency_state\taction\tevidence_limit",
            8, registry->obligations, sizeof(registry->obligations[0]),
            &registry->obligation_count, read_obligation)) return 0;
    if (!join_path(path, sizeof(path), root, "consumers.tsv") ||
        !load_table(path, "consumer_id\trepository\tjob_id\trelease_path\tstate", 5,
            registry->consumers, sizeof(registry->consumers[0]),
            &registry->consumer_count, read_consumer)) return 0;
    return 1;
}

static Seed *find_seed(Registry *registry, const char *id) {
    size_t index;
    for (index = 0; index < registry->seed_count; ++index) {
        if (strcmp(registry->seeds[index].seed_id, id) == 0) return &registry->seeds[index];
    }
    return NULL;
}

static SearchPage *find_page(Registry *registry, const char *id) {
    size_t index;
    for (index = 0; index < registry->page_count; ++index) {
        if (strcmp(registry->pages[index].search_id, id) == 0) return &registry->pages[index];
    }
    return NULL;
}

static Candidate *find_candidate(Registry *registry, const char *id) {
    size_t index;
    for (index = 0; index < registry->candidate_count; ++index) {
        if (strcmp(registry->candidates[index].candidate_id, id) == 0) return &registry->candidates[index];
    }
    return NULL;
}

static Disposition *find_disposition(Registry *registry, const char *id) {
    size_t index;
    for (index = 0; index < registry->disposition_count; ++index) {
        if (strcmp(registry->dispositions[index].candidate_id, id) == 0)
            return &registry->dispositions[index];
    }
    return NULL;
}

static int same_specimen(const Specimen *left, const Specimen *right) {
    return memcmp(left, right, sizeof(*left)) == 0;
}

static int validate_specimens(Registry *registry) {
    size_t index, earlier;
    int unique = 0;
    Specimen *first = NULL;
    for (index = 0; index < registry->specimen_count; ++index) {
        Specimen *row = &registry->specimens[index];
        int duplicate = 0;
        if (strcmp(row->schema, "aici-defect-specimen-v1") != 0 ||
            strcmp(row->incident_id, registry->registration.incident_id) != 0 ||
            !identifier(row->specimen_id) || !present(row->source_repository) ||
            !lower_hex(row->source_revision, 40) || !present(row->source_path) ||
            !lower_hex(row->source_sha256, 64) || !present(row->original_test_path) ||
            !lower_hex(row->original_test_sha256, 64) || !present(row->defect_case) ||
            !present(row->claimed_property) || !present(row->human_confirmation) ||
            strcmp(row->evidence_class, "host-cpu") != 0)
            return fail("AICI-DEFECT-SPECIMEN", row->specimen_id);
        if (strcmp(row->original_claim_scope, "smoke-only") != 0 ||
            strstr(row->claimed_property, "mathematical-certification") != NULL)
            return fail("AICI-DEFECT-CLAIM-PROMOTION", row->specimen_id);
        if (strcmp(row->oracle_owner, "isomorphisms/ai-ci") != 0 ||
            !lower_hex(row->oracle_revision, 40) || !present(row->oracle_path) ||
            strcmp(row->oracle_provenance,
                   "independent-hand-derived-six-values") != 0 ||
            strcmp(row->oracle_path, row->source_path) == 0 ||
            strcmp(row->oracle_path, row->original_test_path) == 0)
            return fail("AICI-DEFECT-COPIED-ORACLE", row->specimen_id);
        if (strncmp(row->human_confirmation, "https://", 8) != 0)
            return fail("AICI-DEFECT-HUMAN-CONFIRMATION", row->specimen_id);
        for (earlier = 0; earlier < index; ++earlier) {
            if (strcmp(row->specimen_id, registry->specimens[earlier].specimen_id) == 0) {
                duplicate = 1;
                if (!same_specimen(row, &registry->specimens[earlier]))
                    return fail("AICI-DEFECT-DUPLICATE-CONFLICT", row->specimen_id);
            }
        }
        if (!duplicate) {
            ++unique;
            if (first == NULL) first = row;
        }
    }
    if (unique != registry->registration.expected_specimens || first == NULL)
        return fail("AICI-DEFECT-SPECIMEN-COUNT", "unique specimen count mismatch");
    return 1;
}

static int validate_seeds(Registry *registry) {
    size_t index, other;
    Specimen *specimen = &registry->specimens[0];
    if (registry->seed_count != (sizeof(required_seed_ids) / sizeof(required_seed_ids[0])) ||
        registry->registration.expected_seeds != (int)registry->seed_count)
        return fail("AICI-DEFECT-SEED-COUNT", "known owner inventory is incomplete");
    for (index = 0; index < registry->seed_count; ++index) {
        Seed *row = &registry->seeds[index];
        if (!one_of(row->seed_id, required_seed_ids,
                    sizeof(required_seed_ids) / sizeof(required_seed_ids[0])) ||
            !present(row->repository) || !lower_hex(row->revision, 40) ||
            !present(row->role) || !present(row->boundary))
            return fail("AICI-DEFECT-SEED", row->seed_id);
        for (other = 0; other < index; ++other) {
            if (strcmp(row->seed_id, registry->seeds[other].seed_id) == 0)
                return fail("AICI-DEFECT-SEED-DUPLICATE", row->seed_id);
        }
    }
    for (index = 0; index < sizeof(required_seed_ids) / sizeof(required_seed_ids[0]); ++index) {
        if (find_seed(registry, required_seed_ids[index]) == NULL)
            return fail("AICI-DEFECT-SEED-MISSING", required_seed_ids[index]);
    }
    {
        Seed *holomorphic = find_seed(registry, "holomorphic");
        if (holomorphic == NULL ||
            strcmp(holomorphic->revision, specimen->source_revision) != 0 ||
            strcmp(holomorphic->repository, specimen->source_repository) != 0)
            return fail("AICI-DEFECT-STALE-SOURCE", "specimen and seed revision differ");
    }
    return 1;
}

static int validate_pages(Registry *registry) {
    size_t category_index, page_index, candidate_index, other;
    for (page_index = 0; page_index < registry->page_count; ++page_index) {
        SearchPage *row = &registry->pages[page_index];
        int actual_rows = 0;
        if (!identifier(row->search_id) ||
            !one_of(row->category, required_categories,
                    sizeof(required_categories) / sizeof(required_categories[0])) ||
            row->page < 1 || (strcmp(row->last, "yes") != 0 && strcmp(row->last, "no") != 0) ||
            !present(row->repository_scope) || !present(row->evidence_ref))
            return fail("AICI-DEFECT-SEARCH-PAGE", row->search_id);
        for (other = 0; other < page_index; ++other) {
            if (strcmp(row->search_id, registry->pages[other].search_id) == 0)
                return fail("AICI-DEFECT-SEARCH-DUPLICATE", row->search_id);
        }
        for (candidate_index = 0; candidate_index < registry->candidate_count; ++candidate_index) {
            if (strcmp(registry->candidates[candidate_index].search_id, row->search_id) == 0)
                ++actual_rows;
        }
        if (actual_rows != row->inventory_rows)
            return fail("AICI-DEFECT-SEARCH-ROW-COUNT", row->search_id);
    }
    for (category_index = 0;
         category_index < sizeof(required_categories) / sizeof(required_categories[0]);
         ++category_index) {
        const char *category = required_categories[category_index];
        int maximum = 0;
        int last_count = 0;
        int page;
        for (page_index = 0; page_index < registry->page_count; ++page_index) {
            SearchPage *row = &registry->pages[page_index];
            if (strcmp(row->category, category) == 0) {
                if (row->page > maximum) maximum = row->page;
                if (strcmp(row->last, "yes") == 0) ++last_count;
            }
        }
        if (maximum == 0 || last_count != 1)
            return fail("AICI-DEFECT-SEARCH-INCOMPLETE", category);
        for (page = 1; page <= maximum; ++page) {
            int found = 0;
            for (page_index = 0; page_index < registry->page_count; ++page_index) {
                if (strcmp(registry->pages[page_index].category, category) == 0 &&
                    registry->pages[page_index].page == page) ++found;
            }
            if (found != 1) return fail("AICI-DEFECT-SEARCH-PAGE-MISSING", category);
        }
    }
    return 1;
}

static int validate_candidates(Registry *registry) {
    size_t index, other, seed_index;
    if (registry->candidate_count != (size_t)registry->registration.expected_candidates)
        return fail("AICI-DEFECT-CANDIDATE-COUNT", "inventory count mismatch");
    for (index = 0; index < registry->candidate_count; ++index) {
        Candidate *row = &registry->candidates[index];
        Seed *seed = find_seed(registry, row->seed_id);
        SearchPage *page = find_page(registry, row->search_id);
        if (!identifier(row->candidate_id) || seed == NULL || page == NULL ||
            strcmp(row->repository, seed->repository) != 0 ||
            strcmp(row->revision, seed->revision) != 0 ||
            strcmp(row->source_kind, page->category) != 0 ||
            !present(row->locator) || !present(row->claim_scope) ||
            (strcmp(row->accessible, "yes") != 0 && strcmp(row->accessible, "no") != 0))
            return fail("AICI-DEFECT-CANDIDATE", row->candidate_id);
        for (other = 0; other < index; ++other) {
            if (strcmp(row->candidate_id, registry->candidates[other].candidate_id) == 0)
                return fail("AICI-DEFECT-CANDIDATE-DUPLICATE", row->candidate_id);
        }
    }
    for (seed_index = 0; seed_index < registry->seed_count; ++seed_index) {
        int found = 0;
        for (index = 0; index < registry->candidate_count; ++index) {
            if (strcmp(registry->candidates[index].seed_id,
                       registry->seeds[seed_index].seed_id) == 0) ++found;
        }
        if (found == 0)
            return fail("AICI-DEFECT-KNOWN-CONSUMER-OMITTED",
                        registry->seeds[seed_index].seed_id);
    }
    return 1;
}

static int validate_dispositions(Registry *registry) {
    static const char *const values[] = {"confirmed", "benign", "unknown", "inaccessible"};
    int confirmed = 0, benign = 0, unknown = 0, inaccessible = 0;
    size_t index, other, candidate_index;
    if (registry->disposition_count != registry->candidate_count)
        return fail("AICI-DEFECT-DISPOSITION-COUNT", "candidate/disposition mismatch");
    for (index = 0; index < registry->disposition_count; ++index) {
        Disposition *row = &registry->dispositions[index];
        Candidate *candidate = find_candidate(registry, row->candidate_id);
        if (candidate == NULL || !one_of(row->disposition, values, 4) ||
            !present(row->evidence_ref) || !present(row->basis) ||
            !present(row->causal_status))
            return fail("AICI-DEFECT-DISPOSITION", row->candidate_id);
        for (other = 0; other < index; ++other) {
            if (strcmp(row->candidate_id, registry->dispositions[other].candidate_id) == 0)
                return fail("AICI-DEFECT-DISPOSITION-DUPLICATE", row->candidate_id);
        }
        if ((strcmp(candidate->accessible, "no") == 0) !=
            (strcmp(row->disposition, "inaccessible") == 0))
            return fail("AICI-DEFECT-ACCESS-DISPOSITION", row->candidate_id);
        if (strcmp(row->disposition, "confirmed") == 0) ++confirmed;
        else if (strcmp(row->disposition, "benign") == 0) ++benign;
        else if (strcmp(row->disposition, "unknown") == 0) ++unknown;
        else ++inaccessible;
    }
    for (candidate_index = 0; candidate_index < registry->candidate_count; ++candidate_index) {
        if (find_disposition(registry, registry->candidates[candidate_index].candidate_id) == NULL)
            return fail("AICI-DEFECT-DISPOSITION-MISSING",
                        registry->candidates[candidate_index].candidate_id);
    }
    if (confirmed != registry->registration.expected_confirmed ||
        benign != registry->registration.expected_benign ||
        unknown != registry->registration.expected_unknown ||
        inaccessible != registry->registration.expected_inaccessible)
        return fail("AICI-DEFECT-DISPOSITION-TOTALS", "classification counts changed");
    return 1;
}

static int disposition_needs_obligation(const Disposition *row) {
    return strcmp(row->disposition, "confirmed") == 0 ||
           strcmp(row->disposition, "unknown") == 0;
}

static int validate_obligations(Registry *registry) {
    static const char *const states[] = {"ready", "pending", "blocked"};
    size_t index, other, disposition_index;
    if (registry->obligation_count != (size_t)registry->registration.expected_obligations)
        return fail("AICI-DEFECT-OBLIGATION-COUNT", "declared count mismatch");
    for (index = 0; index < registry->obligation_count; ++index) {
        Obligation *row = &registry->obligations[index];
        Candidate *candidate = find_candidate(registry, row->candidate_id);
        Disposition *disposition = find_disposition(registry, row->candidate_id);
        char expected[IDENTIFIER_SIZE];
        if (candidate == NULL || disposition == NULL || !disposition_needs_obligation(disposition))
            return fail("AICI-DEFECT-UNSUPPORTED-OBLIGATION", row->candidate_id);
        if (snprintf(expected, sizeof(expected), "a05-%s", row->candidate_id) < 0 ||
            strcmp(row->obligation_id, expected) != 0 ||
            strcmp(row->owner_repository, candidate->repository) != 0 ||
            strcmp(row->source_revision, candidate->revision) != 0 ||
            !present(row->owner_record) ||
            !one_of(row->dependency_state, states, 3) || !present(row->action) ||
            !present(row->evidence_limit))
            return fail("AICI-DEFECT-OBLIGATION", row->candidate_id);
        if (index > 0 && strcmp(registry->obligations[index - 1].candidate_id,
                                row->candidate_id) >= 0)
            return fail("AICI-DEFECT-OBLIGATION-ORDER", row->candidate_id);
        for (other = 0; other < index; ++other) {
            if (strcmp(row->obligation_id, registry->obligations[other].obligation_id) == 0 ||
                strcmp(row->candidate_id, registry->obligations[other].candidate_id) == 0)
                return fail("AICI-DEFECT-OBLIGATION-DUPLICATE", row->candidate_id);
        }
    }
    for (disposition_index = 0; disposition_index < registry->disposition_count;
         ++disposition_index) {
        Disposition *disposition = &registry->dispositions[disposition_index];
        int found = 0;
        for (index = 0; index < registry->obligation_count; ++index) {
            if (strcmp(registry->obligations[index].candidate_id,
                       disposition->candidate_id) == 0) ++found;
        }
        if ((disposition_needs_obligation(disposition) && found != 1) ||
            (!disposition_needs_obligation(disposition) && found != 0))
            return fail("AICI-DEFECT-OBLIGATION-COVERAGE", disposition->candidate_id);
    }
    return 1;
}

static int render_obligations(Registry *registry, FILE *output) {
    size_t index;
    if (fputs("obligation_id\tcandidate_id\towner_repository\towner_record\tsource_revision\tdependency_state\taction\tevidence_limit\n", output) == EOF)
        return 0;
    for (index = 0; index < registry->obligation_count; ++index) {
        Obligation *row = &registry->obligations[index];
        if (fprintf(output, "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                    row->obligation_id, row->candidate_id, row->owner_repository,
                    row->owner_record, row->source_revision, row->dependency_state,
                    row->action, row->evidence_limit) < 0) return 0;
    }
    return 1;
}

static int streams_equal(FILE *left, FILE *right) {
    int l, r;
    rewind(left);
    rewind(right);
    do {
        l = fgetc(left);
        r = fgetc(right);
        if (l != r) return 0;
    } while (l != EOF && r != EOF);
    return !ferror(left) && !ferror(right);
}

static int rendered_matches_path(Registry *registry, const char *path) {
    FILE *rendered = tmpfile();
    FILE *actual = fopen(path, "r");
    int result;
    if (rendered == NULL || actual == NULL) {
        if (rendered != NULL) fclose(rendered);
        if (actual != NULL) fclose(actual);
        return fail("AICI-DEFECT-RELEASE-OPEN", path);
    }
    if (!render_obligations(registry, rendered)) {
        fclose(rendered);
        fclose(actual);
        return fail("AICI-DEFECT-RENDER", path);
    }
    result = streams_equal(rendered, actual);
    fclose(rendered);
    fclose(actual);
    return result || fail("AICI-DEFECT-RELEASE-BYTES", path);
}

static int validate_consumers_and_release(Registry *registry) {
    size_t index, other, required;
    char obligations_path[PATH_SIZE];
    char release_path[PATH_SIZE];
    if (registry->consumer_count != (size_t)registry->registration.expected_consumers)
        return fail("AICI-DEFECT-CONSUMER-COUNT", "release consumer count mismatch");
    for (index = 0; index < registry->consumer_count; ++index) {
        Consumer *row = &registry->consumers[index];
        if (!one_of(row->consumer_id, required_consumers,
                    sizeof(required_consumers) / sizeof(required_consumers[0])) ||
            !present(row->repository) || !present(row->job_id) ||
            strcmp(row->release_path, "release/obligations.tsv") != 0 ||
            (strcmp(row->state, "ready") != 0 && strcmp(row->state, "pending") != 0 &&
             strcmp(row->state, "blocked") != 0))
            return fail("AICI-DEFECT-CONSUMER", row->consumer_id);
        for (other = 0; other < index; ++other) {
            if (strcmp(row->consumer_id, registry->consumers[other].consumer_id) == 0)
                return fail("AICI-DEFECT-CONSUMER-DUPLICATE", row->consumer_id);
        }
    }
    for (required = 0; required < sizeof(required_consumers) / sizeof(required_consumers[0]);
         ++required) {
        int found = 0;
        for (index = 0; index < registry->consumer_count; ++index) {
            if (strcmp(registry->consumers[index].consumer_id,
                       required_consumers[required]) == 0) ++found;
        }
        if (found != 1) return fail("AICI-DEFECT-CONSUMER-MISSING",
                                    required_consumers[required]);
    }
    if (!join_path(obligations_path, sizeof(obligations_path), registry->root,
                   "obligations.tsv") ||
        !join_path(release_path, sizeof(release_path), registry->root,
                   "release/obligations.tsv"))
        return fail("AICI-DEFECT-PATH", registry->root);
    if (!rendered_matches_path(registry, obligations_path) ||
        !rendered_matches_path(registry, release_path)) return 0;
    return 1;
}

static int validate_registry(Registry *registry, int announce) {
    if (strcmp(registry->registration.schema, "aici-defect-registration-v1") != 0 ||
        !identifier(registry->registration.incident_id) ||
        !present(registry->registration.coverage_scope))
        return fail("AICI-DEFECT-REGISTRATION", registry->registration.incident_id);
    last_error_code[0] = '\0';
    if (!validate_specimens(registry) || !validate_seeds(registry) ||
        !validate_pages(registry) || !validate_candidates(registry) ||
        !validate_dispositions(registry) || !validate_obligations(registry) ||
        !validate_consumers_and_release(registry)) return 0;
    if (announce) {
        printf("AICI-DEFECT-REGISTRATION-ACCEPTED incident=%s specimens=%d seeds=%zu candidates=%zu obligations=%zu consumers=%zu\n",
               registry->registration.incident_id,
               registry->registration.expected_specimens, registry->seed_count,
               registry->candidate_count, registry->obligation_count,
               registry->consumer_count);
    }
    return 1;
}

static int expect_rejection(Registry *candidate, const char *name,
                            const char *expected_code) {
    int accepted;
    accepted = validate_registry(candidate, 0);
    if (accepted) return fail("AICI-DEFECT-SELF-TEST-FALSE-ACCEPT", name);
    if (strcmp(last_error_code, expected_code) != 0) {
        char detail[REFERENCE_SIZE];
        snprintf(detail, sizeof(detail), "%s expected=%s observed=%s", name,
                 expected_code, last_error_code);
        return fail("AICI-DEFECT-SELF-TEST-WRONG-DIAGNOSTIC", detail);
    }
    printf("AICI-DEFECT-SELF-TEST-KILLED case=%s\n", name);
    return 1;
}

static Registry *clone_registry(const Registry *source) {
    Registry *copy = malloc(sizeof(*copy));
    if (copy != NULL) memcpy(copy, source, sizeof(*copy));
    return copy;
}

static int deterministic_render(Registry *registry) {
    FILE *first = tmpfile();
    FILE *second = tmpfile();
    int result;
    if (first == NULL || second == NULL) {
        if (first != NULL) fclose(first);
        if (second != NULL) fclose(second);
        return fail("AICI-DEFECT-SELF-TEST", "tmpfile unavailable");
    }
    result = render_obligations(registry, first) && render_obligations(registry, second) &&
             streams_equal(first, second);
    fclose(first);
    fclose(second);
    return result || fail("AICI-DEFECT-NONDETERMINISTIC", "repeated obligation bytes differ");
}

static int run_self_test(Registry *good) {
    Registry *test;
    int killed = 0;
    if (!validate_registry(good, 1) || !deterministic_render(good)) return 0;

    test = clone_registry(good);
    if (test == NULL || test->specimen_count >= MAXIMUM_ROWS) return 0;
    test->specimens[test->specimen_count] = test->specimens[0];
    ++test->specimen_count;
    if (!validate_registry(test, 0) || !deterministic_render(test)) {
        free(test);
        return fail("AICI-DEFECT-IDENTICAL-REREGISTRATION", "identical specimen changed output");
    }
    free(test);

#define MUTATION(NAME, CODE, STATEMENT) \
    do { \
        test = clone_registry(good); \
        if (test == NULL) return 0; \
        STATEMENT; \
        if (!expect_rejection(test, NAME, CODE)) { free(test); return 0; } \
        free(test); \
        ++killed; \
    } while (0)

    MUTATION("conflicting-specimen", "AICI-DEFECT-DUPLICATE-CONFLICT", {
        test->specimens[test->specimen_count] = test->specimens[0];
        copy_text(test->specimens[test->specimen_count].claimed_property,
                  sizeof(test->specimens[test->specimen_count].claimed_property),
                  "conflicting-property");
        ++test->specimen_count;
    });
    MUTATION("omitted-known-consumer", "AICI-DEFECT-KNOWN-CONSUMER-OMITTED", {
        size_t i;
        for (i = 0; i < test->candidate_count; ++i) {
            if (strcmp(test->candidates[i].seed_id, "surfer") == 0) {
                memmove(&test->candidates[i], &test->candidates[i + 1],
                        (test->candidate_count - i - 1) * sizeof(test->candidates[0]));
                --test->candidate_count;
                break;
            }
        }
        for (i = 0; i < test->disposition_count; ++i) {
            if (strcmp(test->dispositions[i].candidate_id,
                       "surfer-native-raytracer") == 0) {
                memmove(&test->dispositions[i], &test->dispositions[i + 1],
                        (test->disposition_count - i - 1) * sizeof(test->dispositions[0]));
                --test->disposition_count;
                break;
            }
        }
        for (i = 0; i < test->obligation_count; ++i) {
            if (strcmp(test->obligations[i].candidate_id,
                       "surfer-native-raytracer") == 0) {
                memmove(&test->obligations[i], &test->obligations[i + 1],
                        (test->obligation_count - i - 1) * sizeof(test->obligations[0]));
                --test->obligation_count;
                break;
            }
        }
        --test->registration.expected_candidates;
        --test->registration.expected_unknown;
        --test->registration.expected_obligations;
        for (i = 0; i < test->page_count; ++i) {
            if (strcmp(test->pages[i].search_id, "source-test-1") == 0)
                --test->pages[i].inventory_rows;
        }
    });
    MUTATION("missing-search-page", "AICI-DEFECT-SEARCH-INCOMPLETE", {
        size_t i;
        for (i = 0; i < test->page_count; ++i) {
            if (strcmp(test->pages[i].category, "promotion-caller") == 0) {
                memmove(&test->pages[i], &test->pages[i + 1],
                        (test->page_count - i - 1) * sizeof(test->pages[0]));
                --test->page_count;
                break;
            }
        }
    });
    MUTATION("copied-oracle", "AICI-DEFECT-COPIED-ORACLE", {
        copy_text(test->specimens[0].oracle_provenance,
                  sizeof(test->specimens[0].oracle_provenance), "copied-from-producer");
    });
    MUTATION("stale-source", "AICI-DEFECT-STALE-SOURCE", {
        copy_text(test->specimens[0].source_revision,
                  sizeof(test->specimens[0].source_revision),
                  "0000000000000000000000000000000000000000");
    });
    MUTATION("unjustified-benign", "AICI-DEFECT-DISPOSITION", {
        size_t i;
        for (i = 0; i < test->disposition_count; ++i) {
            if (strcmp(test->dispositions[i].disposition, "benign") == 0) {
                copy_text(test->dispositions[i].basis,
                          sizeof(test->dispositions[i].basis), "-");
                break;
            }
        }
    });
    MUTATION("duplicate-obligation", "AICI-DEFECT-OBLIGATION-ORDER", {
        test->obligations[test->obligation_count] = test->obligations[0];
        ++test->obligation_count;
        ++test->registration.expected_obligations;
    });
    MUTATION("missing-obligation", "AICI-DEFECT-OBLIGATION-COVERAGE", {
        --test->obligation_count;
        --test->registration.expected_obligations;
    });
    MUTATION("promoted-smoke-claim", "AICI-DEFECT-CLAIM-PROMOTION", {
        copy_text(test->specimens[0].original_claim_scope,
                  sizeof(test->specimens[0].original_claim_scope),
                  "mathematical-certification");
    });
    MUTATION("inaccessible-called-benign", "AICI-DEFECT-ACCESS-DISPOSITION", {
        size_t i;
        for (i = 0; i < test->disposition_count; ++i) {
            if (strcmp(test->dispositions[i].disposition, "inaccessible") == 0) {
                copy_text(test->dispositions[i].disposition,
                          sizeof(test->dispositions[i].disposition), "benign");
                break;
            }
        }
    });
#undef MUTATION

    printf("AICI-DEFECT-REGISTRATION-SELF-TEST pass=1 killed=%d identical_reregistration=stable\n",
           killed);
    return killed == 10;
}

static void usage(const char *program) {
    fprintf(stderr, "usage: %s verify|self-test|render INCIDENT_DIRECTORY\n", program);
}

int main(int argc, char **argv) {
    Registry *registry;
    int result = 0;
    if (argc != 3) {
        usage(argv[0]);
        return 2;
    }
    registry = malloc(sizeof(*registry));
    if (registry == NULL) return 2;
    if (!load_registry(argv[2], registry)) {
        free(registry);
        return 1;
    }
    if (strcmp(argv[1], "verify") == 0) result = validate_registry(registry, 1);
    else if (strcmp(argv[1], "self-test") == 0) result = run_self_test(registry);
    else if (strcmp(argv[1], "render") == 0) {
        if (validate_registry(registry, 0)) result = render_obligations(registry, stdout);
    } else {
        usage(argv[0]);
        free(registry);
        return 2;
    }
    free(registry);
    return result ? 0 : 1;
}
