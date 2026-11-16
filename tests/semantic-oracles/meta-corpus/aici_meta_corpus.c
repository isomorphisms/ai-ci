#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ROWS 64
#define MAX_FIELD 160
#define MAX_LINE 1024

typedef struct {
    char scenario_id[MAX_FIELD];
    char meta_case[MAX_FIELD];
    char candidate[MAX_FIELD];
    char test[MAX_FIELD];
    char oracle_ids[MAX_FIELD];
    char selection[MAX_FIELD];
} CaseRow;

typedef struct {
    char oracle_id[MAX_FIELD];
    char kind[MAX_FIELD];
    char expected_value[MAX_FIELD];
    char provenance[MAX_FIELD];
} ExpectationRow;

typedef struct {
    char scenario_id[MAX_FIELD];
    char meta_case[MAX_FIELD];
    char selection[MAX_FIELD];
    char candidate_output[MAX_FIELD];
    int candidate_exit;
    char test_result[MAX_FIELD];
    int test_exit;
    char oracle_ids[MAX_FIELD];
} ObservationRow;

typedef struct {
    char scenario_id[MAX_FIELD];
    char meta_case[MAX_FIELD];
    char semantic_result[MAX_FIELD];
    char test_result[MAX_FIELD];
    char agreement[MAX_FIELD];
    char evidence_validity[MAX_FIELD];
    char diagnosis[MAX_FIELD];
    char disposition[MAX_FIELD];
} VerdictRow;

static void fail(const char *message, const char *detail) {
    fprintf(stderr, "AICI-META-CORPUS-ERROR %s%s%s\n", message,
            detail == NULL ? "" : " value=", detail == NULL ? "" : detail);
    exit(1);
}

static void copy_field(char *destination, const char *source) {
    size_t length = strlen(source);
    if (length >= MAX_FIELD) {
        fail("field-too-long", source);
    }
    memcpy(destination, source, length + 1);
}

static int split_tsv(char *line, char **fields, int expected) {
    int count = 0;
    char *start = line;
    for (char *cursor = line;; ++cursor) {
        if (*cursor == '\t' || *cursor == '\0') {
            if (count >= expected) {
                return -1;
            }
            fields[count++] = start;
            if (*cursor == '\0') {
                break;
            }
            *cursor = '\0';
            start = cursor + 1;
        }
    }
    return count;
}

static void trim_newline(char *line) {
    size_t length = strlen(line);
    while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
        line[--length] = '\0';
    }
}

static int valid_identifier(const char *value) {
    if (!isalnum((unsigned char)value[0])) {
        return 0;
    }
    for (const char *cursor = value; *cursor != '\0'; ++cursor) {
        if (!isalnum((unsigned char)*cursor) && *cursor != '-' && *cursor != '_' && *cursor != '.') {
            return 0;
        }
    }
    return 1;
}

static size_t read_cases(const char *path, CaseRow rows[MAX_ROWS]) {
    FILE *input = fopen(path, "r");
    if (input == NULL) {
        fail("cannot-open-cases", path);
    }
    char line[MAX_LINE];
    if (fgets(line, sizeof(line), input) == NULL) {
        fail("empty-cases", path);
    }
    trim_newline(line);
    if (strcmp(line, "scenario_id\tmeta_case\tcandidate\ttest\toracle_ids\tselection") != 0) {
        fail("cases-header", line);
    }
    size_t count = 0;
    while (fgets(line, sizeof(line), input) != NULL) {
        trim_newline(line);
        if (line[0] == '\0') {
            continue;
        }
        if (count == MAX_ROWS) {
            fail("too-many-cases", path);
        }
        char *fields[6];
        if (split_tsv(line, fields, 6) != 6) {
            fail("cases-column-count", line);
        }
        if (!valid_identifier(fields[0]) || strlen(fields[1]) != 3 || fields[1][0] != 'M') {
            fail("case-identity", fields[0]);
        }
        for (size_t prior = 0; prior < count; ++prior) {
            if (strcmp(rows[prior].scenario_id, fields[0]) == 0) {
                fail("duplicate-scenario", fields[0]);
            }
        }
        copy_field(rows[count].scenario_id, fields[0]);
        copy_field(rows[count].meta_case, fields[1]);
        copy_field(rows[count].candidate, fields[2]);
        copy_field(rows[count].test, fields[3]);
        copy_field(rows[count].oracle_ids, fields[4]);
        copy_field(rows[count].selection, fields[5]);
        ++count;
    }
    if (ferror(input)) {
        fail("read-cases", path);
    }
    fclose(input);
    if (count == 0) {
        fail("no-cases", path);
    }
    return count;
}

static size_t read_expectations(const char *path, ExpectationRow rows[MAX_ROWS]) {
    FILE *input = fopen(path, "r");
    if (input == NULL) {
        fail("cannot-open-expectations", path);
    }
    char line[MAX_LINE];
    if (fgets(line, sizeof(line), input) == NULL) {
        fail("empty-expectations", path);
    }
    trim_newline(line);
    if (strcmp(line, "oracle_id\tkind\texpected_value\tprovenance") != 0) {
        fail("expectations-header", line);
    }
    size_t count = 0;
    while (fgets(line, sizeof(line), input) != NULL) {
        trim_newline(line);
        if (line[0] == '\0') {
            continue;
        }
        if (count == MAX_ROWS) {
            fail("too-many-expectations", path);
        }
        char *fields[4];
        if (split_tsv(line, fields, 4) != 4) {
            fail("expectations-column-count", line);
        }
        if (!valid_identifier(fields[0])) {
            fail("oracle-identity", fields[0]);
        }
        if (strcmp(fields[1], "sequence") != 0 && strcmp(fields[1], "set") != 0) {
            fail("expectation-kind", fields[1]);
        }
        for (size_t prior = 0; prior < count; ++prior) {
            if (strcmp(rows[prior].oracle_id, fields[0]) == 0) {
                fail("duplicate-oracle", fields[0]);
            }
        }
        copy_field(rows[count].oracle_id, fields[0]);
        copy_field(rows[count].kind, fields[1]);
        copy_field(rows[count].expected_value, fields[2]);
        copy_field(rows[count].provenance, fields[3]);
        ++count;
    }
    if (ferror(input)) {
        fail("read-expectations", path);
    }
    fclose(input);
    if (count == 0) {
        fail("no-expectations", path);
    }
    return count;
}

static size_t read_observations(const char *path, ObservationRow rows[MAX_ROWS]) {
    FILE *input = fopen(path, "r");
    if (input == NULL) {
        fail("cannot-open-observations", path);
    }
    char line[MAX_LINE];
    if (fgets(line, sizeof(line), input) == NULL) {
        fail("empty-observations", path);
    }
    trim_newline(line);
    if (strcmp(line, "scenario_id\tmeta_case\tselection\tcandidate_output\tcandidate_exit\ttest_result\ttest_exit\toracle_ids") != 0) {
        fail("observations-header", line);
    }
    size_t count = 0;
    while (fgets(line, sizeof(line), input) != NULL) {
        trim_newline(line);
        if (line[0] == '\0') {
            continue;
        }
        if (count == MAX_ROWS) {
            fail("too-many-observations", path);
        }
        char *fields[8];
        if (split_tsv(line, fields, 8) != 8) {
            fail("observations-column-count", line);
        }
        char *end = NULL;
        long candidate_exit = strtol(fields[4], &end, 10);
        if (*fields[4] == '\0' || *end != '\0') {
            fail("candidate-exit", fields[4]);
        }
        long test_exit = strtol(fields[6], &end, 10);
        if (*fields[6] == '\0' || *end != '\0') {
            fail("test-exit", fields[6]);
        }
        for (size_t prior = 0; prior < count; ++prior) {
            if (strcmp(rows[prior].scenario_id, fields[0]) == 0) {
                fail("duplicate-observation", fields[0]);
            }
        }
        copy_field(rows[count].scenario_id, fields[0]);
        copy_field(rows[count].meta_case, fields[1]);
        copy_field(rows[count].selection, fields[2]);
        copy_field(rows[count].candidate_output, fields[3]);
        rows[count].candidate_exit = (int)candidate_exit;
        copy_field(rows[count].test_result, fields[5]);
        rows[count].test_exit = (int)test_exit;
        copy_field(rows[count].oracle_ids, fields[7]);
        ++count;
    }
    if (ferror(input)) {
        fail("read-observations", path);
    }
    fclose(input);
    if (count == 0) {
        fail("no-observations", path);
    }
    return count;
}

static void candidate_output(const char *candidate, char output[MAX_FIELD]) {
    if (strcmp(candidate, "overlap-correct") == 0) {
        copy_field(output, "0,1");
    } else if (strcmp(candidate, "overlap-wrong-offset") == 0) {
        copy_field(output, "0,2");
    } else if (strcmp(candidate, "set-correct") == 0) {
        copy_field(output, "A,B");
    } else if (strcmp(candidate, "set-reordered") == 0) {
        copy_field(output, "B,A");
    } else if (strcmp(candidate, "set-missing") == 0) {
        copy_field(output, "A");
    } else if (strcmp(candidate, "set-renamed-reordered") == 0) {
        copy_field(output, "right,left");
    } else {
        fail("unknown-candidate", candidate);
    }
}

static int token_compare(const void *left, const void *right) {
    return strcmp(*(const char *const *)left, *(const char *const *)right);
}

static void normalize_set(const char *input, char output[MAX_FIELD]) {
    char copy[MAX_FIELD];
    copy_field(copy, input);
    char *tokens[16];
    size_t count = 0;
    char *start = copy;
    for (char *cursor = copy;; ++cursor) {
        if (*cursor == ',' || *cursor == '\0') {
            char delimiter = *cursor;
            if (count == 16 || cursor == start) {
                fail("malformed-set", input);
            }
            if (delimiter == ',') {
                *cursor = '\0';
            }
            tokens[count++] = start;
            if (delimiter == '\0') {
                break;
            }
            start = cursor + 1;
        }
    }
    qsort(tokens, count, sizeof(tokens[0]), token_compare);
    output[0] = '\0';
    for (size_t index = 0; index < count; ++index) {
        if (index > 0) {
            if (strlen(output) + 1 >= MAX_FIELD) {
                fail("normalized-set-too-long", input);
            }
            strcat(output, ",");
        }
        if (strlen(output) + strlen(tokens[index]) >= MAX_FIELD) {
            fail("normalized-set-too-long", input);
        }
        strcat(output, tokens[index]);
    }
}

static int values_equal(const char *kind, const char *left, const char *right) {
    if (strcmp(kind, "sequence") == 0) {
        return strcmp(left, right) == 0;
    }
    if (strcmp(kind, "set") == 0) {
        char normalized_left[MAX_FIELD];
        char normalized_right[MAX_FIELD];
        normalize_set(left, normalized_left);
        normalize_set(right, normalized_right);
        return strcmp(normalized_left, normalized_right) == 0;
    }
    fail("unsupported-kind", kind);
    return 0;
}

static void execute_test(const char *test, const char *candidate,
                         char result[MAX_FIELD], int *exit_status) {
    int pass = 0;
    if (strcmp(test, "exact-offsets") == 0) {
        pass = strcmp(candidate, "0,1") == 0;
    } else if (strcmp(test, "set-ab") == 0) {
        pass = values_equal("set", candidate, "A,B");
    } else if (strcmp(test, "set-renamed") == 0) {
        pass = values_equal("set", candidate, "left,right");
    } else if (strcmp(test, "order-sensitive-ab") == 0) {
        pass = strcmp(candidate, "A,B") == 0;
    } else if (strcmp(test, "false-positive") == 0) {
        pass = 1;
    } else if (strcmp(test, "never-run") == 0) {
        copy_field(result, "NOT_RUN");
        *exit_status = -1;
        return;
    } else {
        fail("unknown-test", test);
    }
    copy_field(result, pass ? "PASS" : "FAIL");
    *exit_status = pass ? 0 : 1;
}

static void observe(const char *cases_path, const char *output_path) {
    CaseRow cases[MAX_ROWS];
    size_t case_count = read_cases(cases_path, cases);
    FILE *output = fopen(output_path, "w");
    if (output == NULL) {
        fail("cannot-write-observations", output_path);
    }
    fputs("scenario_id\tmeta_case\tselection\tcandidate_output\tcandidate_exit\ttest_result\ttest_exit\toracle_ids\n", output);
    size_t executed = 0;
    for (size_t index = 0; index < case_count; ++index) {
        char candidate[MAX_FIELD] = "-";
        char test_result[MAX_FIELD] = "NOT_RUN";
        int candidate_exit = -1;
        int test_exit = -1;
        if (strcmp(cases[index].selection, "selected") == 0) {
            candidate_output(cases[index].candidate, candidate);
            candidate_exit = 0;
            execute_test(cases[index].test, candidate, test_result, &test_exit);
            ++executed;
        } else if (strcmp(cases[index].selection, "missing") != 0 &&
                   strcmp(cases[index].selection, "empty") != 0) {
            fail("selection-state", cases[index].selection);
        }
        fprintf(output, "%s\t%s\t%s\t%s\t%d\t%s\t%d\t%s\n",
                cases[index].scenario_id, cases[index].meta_case,
                cases[index].selection, candidate, candidate_exit,
                test_result, test_exit, cases[index].oracle_ids);
    }
    if (fclose(output) != 0) {
        fail("write-observations", output_path);
    }
    printf("AICI-META-CORPUS-RAW-OBSERVATIONS cases=%zu executed=%zu output=%s\n",
           case_count, executed, output_path);
}

static const ObservationRow *find_observation(const ObservationRow *rows,
                                              size_t count,
                                              const char *scenario_id) {
    for (size_t index = 0; index < count; ++index) {
        if (strcmp(rows[index].scenario_id, scenario_id) == 0) {
            return &rows[index];
        }
    }
    return NULL;
}

static const ExpectationRow *find_expectation(const ExpectationRow *rows,
                                              size_t count,
                                              const char *oracle_id) {
    for (size_t index = 0; index < count; ++index) {
        if (strcmp(rows[index].oracle_id, oracle_id) == 0) {
            return &rows[index];
        }
    }
    return NULL;
}

static int verdict_compare(const void *left, const void *right) {
    const VerdictRow *left_row = left;
    const VerdictRow *right_row = right;
    return strcmp(left_row->scenario_id, right_row->scenario_id);
}

static size_t resolve_oracles(const char *oracle_ids,
                              const ExpectationRow *expectations,
                              size_t expectation_count,
                              const ExpectationRow *resolved[MAX_ROWS]) {
    char ids[MAX_FIELD];
    copy_field(ids, oracle_ids);
    size_t count = 0;
    char *start = ids;
    for (char *cursor = ids;; ++cursor) {
        if (*cursor == ',' || *cursor == '\0') {
            char delimiter = *cursor;
            if (cursor == start || count == MAX_ROWS) {
                fail("malformed-oracle-list", oracle_ids);
            }
            if (delimiter == ',') {
                *cursor = '\0';
            }
            resolved[count] = find_expectation(expectations, expectation_count, start);
            if (resolved[count] == NULL) {
                fail("missing-oracle", start);
            }
            ++count;
            if (delimiter == '\0') {
                break;
            }
            start = cursor + 1;
        }
    }
    return count;
}

static void classify_one(const CaseRow *case_row,
                         const ObservationRow *observation,
                         const ExpectationRow *expectations,
                         size_t expectation_count,
                         VerdictRow *verdict) {
    copy_field(verdict->scenario_id, case_row->scenario_id);
    copy_field(verdict->meta_case, case_row->meta_case);
    copy_field(verdict->test_result, observation->test_result);

    if (strcmp(case_row->meta_case, observation->meta_case) != 0 ||
        strcmp(case_row->selection, observation->selection) != 0 ||
        strcmp(case_row->oracle_ids, observation->oracle_ids) != 0) {
        fail("observation-does-not-match-case", case_row->scenario_id);
    }
    if (strcmp(observation->selection, "selected") != 0 ||
        strcmp(observation->test_result, "NOT_RUN") == 0) {
        copy_field(verdict->semantic_result, "NOT_VERIFIED");
        copy_field(verdict->agreement, "NOT_RUN");
        copy_field(verdict->evidence_validity, "INCOMPLETE");
        copy_field(verdict->diagnosis, "UNKNOWN");
        copy_field(verdict->disposition, "HOLD_FOR_EVIDENCE");
        return;
    }
    if (observation->candidate_exit != 0 ||
        (strcmp(observation->test_result, "PASS") != 0 &&
         strcmp(observation->test_result, "FAIL") != 0)) {
        copy_field(verdict->semantic_result, "NOT_VERIFIED");
        copy_field(verdict->agreement, "INVALID");
        copy_field(verdict->evidence_validity, "MALFORMED");
        copy_field(verdict->diagnosis, "UNKNOWN");
        copy_field(verdict->disposition, "HOLD_FOR_EVIDENCE");
        return;
    }

    const ExpectationRow *resolved[MAX_ROWS];
    size_t resolved_count = resolve_oracles(case_row->oracle_ids, expectations,
                                            expectation_count, resolved);
    for (size_t index = 0; index < resolved_count; ++index) {
        if (strcmp(resolved[index]->provenance, "candidate-output") == 0) {
            copy_field(verdict->semantic_result, "NOT_VERIFIED");
            copy_field(verdict->agreement, "NOT_VERIFIED");
            copy_field(verdict->evidence_validity, "UNTRUSTED_PRODUCER");
            copy_field(verdict->diagnosis, "ORACLE_DEFECT");
            copy_field(verdict->disposition, "HOLD_FOR_EVIDENCE");
            return;
        }
        if (strcmp(resolved[index]->kind, resolved[0]->kind) != 0) {
            fail("oracle-kind-disagreement", case_row->scenario_id);
        }
    }
    for (size_t index = 1; index < resolved_count; ++index) {
        if (!values_equal(resolved[0]->kind, resolved[0]->expected_value,
                          resolved[index]->expected_value)) {
            copy_field(verdict->semantic_result, "DISAGREEMENT");
            copy_field(verdict->agreement, "DISAGREEMENT");
            copy_field(verdict->evidence_validity, "VALID");
            copy_field(verdict->diagnosis, "UNKNOWN");
            copy_field(verdict->disposition, "HOLD_FOR_EVIDENCE");
            return;
        }
    }

    int semantic_pass = values_equal(resolved[0]->kind,
                                     observation->candidate_output,
                                     resolved[0]->expected_value);
    int test_pass = strcmp(observation->test_result, "PASS") == 0;
    copy_field(verdict->semantic_result, semantic_pass ? "PASS" : "FAIL");
    copy_field(verdict->agreement, semantic_pass == test_pass ? "AGREEMENT" : "DISAGREEMENT");
    copy_field(verdict->evidence_validity, "VALID");
    if (semantic_pass && test_pass) {
        copy_field(verdict->diagnosis, "NONE");
    } else if (!semantic_pass && !test_pass) {
        copy_field(verdict->diagnosis, "IMPLEMENTATION_DEFECT");
    } else if (semantic_pass) {
        copy_field(verdict->diagnosis, "TEST_DEFECT");
    } else {
        copy_field(verdict->diagnosis, "IMPLEMENTATION_AND_TEST_DEFECT");
    }
    copy_field(verdict->disposition, semantic_pass ? "ACCEPT_SCOPE" : "REJECT_SCOPE");
}

static void classify(const char *cases_path, const char *expectations_path,
                     const char *observations_path, const char *output_path) {
    CaseRow cases[MAX_ROWS];
    ExpectationRow expectations[MAX_ROWS];
    ObservationRow observations[MAX_ROWS];
    size_t case_count = read_cases(cases_path, cases);
    size_t expectation_count = read_expectations(expectations_path, expectations);
    size_t observation_count = read_observations(observations_path, observations);
    if (case_count != observation_count) {
        fail("selection-incomplete", observations_path);
    }

    VerdictRow verdicts[MAX_ROWS];
    size_t blocked = 0;
    size_t disagreements = 0;
    for (size_t index = 0; index < case_count; ++index) {
        const ObservationRow *observation = find_observation(
            observations, observation_count, cases[index].scenario_id);
        if (observation == NULL) {
            fail("missing-observation", cases[index].scenario_id);
        }
        classify_one(&cases[index], observation, expectations,
                     expectation_count, &verdicts[index]);
        if (strcmp(verdicts[index].disposition, "HOLD_FOR_EVIDENCE") == 0) {
            ++blocked;
        }
        if (strcmp(verdicts[index].agreement, "DISAGREEMENT") == 0) {
            ++disagreements;
        }
    }
    qsort(verdicts, case_count, sizeof(verdicts[0]), verdict_compare);
    FILE *output = fopen(output_path, "w");
    if (output == NULL) {
        fail("cannot-write-verdicts", output_path);
    }
    fputs("scenario_id\tmeta_case\tsemantic_result\ttest_result\tagreement\tevidence_validity\tdiagnosis\tdisposition\n", output);
    for (size_t index = 0; index < case_count; ++index) {
        fprintf(output, "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                verdicts[index].scenario_id, verdicts[index].meta_case,
                verdicts[index].semantic_result, verdicts[index].test_result,
                verdicts[index].agreement, verdicts[index].evidence_validity,
                verdicts[index].diagnosis, verdicts[index].disposition);
    }
    if (fclose(output) != 0) {
        fail("write-verdicts", output_path);
    }
    printf("AICI-META-CORPUS-SEMANTIC-RESULT scenarios=%zu blocked=%zu disagreements=%zu output=%s\n",
           case_count, blocked, disagreements, output_path);
}

static void verify_dispositions(const char *path) {
    FILE *input = fopen(path, "r");
    if (input == NULL) {
        fail("cannot-open-dispositions", path);
    }
    char line[MAX_LINE];
    if (fgets(line, sizeof(line), input) == NULL) {
        fail("empty-dispositions", path);
    }
    trim_newline(line);
    if (strcmp(line, "case_id\tstatus\tevidence_or_owner\tnote") != 0) {
        fail("dispositions-header", line);
    }
    int seen[27] = {0};
    size_t count = 0;
    while (fgets(line, sizeof(line), input) != NULL) {
        trim_newline(line);
        if (line[0] == '\0') {
            continue;
        }
        char *fields[4];
        if (split_tsv(line, fields, 4) != 4) {
            fail("dispositions-column-count", line);
        }
        if (fields[0][0] != 'M' || !isdigit((unsigned char)fields[0][1]) ||
            !isdigit((unsigned char)fields[0][2]) || fields[0][3] != '\0') {
            fail("disposition-case-id", fields[0]);
        }
        int id = (fields[0][1] - '0') * 10 + fields[0][2] - '0';
        if (id < 1 || id > 26 || seen[id]) {
            fail("duplicate-or-out-of-range-disposition", fields[0]);
        }
        if (strcmp(fields[1], "EXECUTED_THIS_SLICE") != 0 &&
            strcmp(fields[1], "RETAINED_EXISTING_CONTROL") != 0 &&
            strcmp(fields[1], "CONDITIONAL_CANDIDATE") != 0 &&
            strcmp(fields[1], "DEFERRED_NOT_EXECUTED") != 0) {
            fail("disposition-status", fields[1]);
        }
        if (fields[2][0] == '\0' || fields[3][0] == '\0') {
            fail("empty-disposition-evidence", fields[0]);
        }
        seen[id] = 1;
        ++count;
    }
    fclose(input);
    if (count != 26) {
        fail("dispositions-not-complete", path);
    }
    for (int id = 1; id <= 26; ++id) {
        if (!seen[id]) {
            fail("missing-disposition", path);
        }
    }
    printf("AICI-META-CORPUS-DISPOSITIONS cases=26 complete=26\n");
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s observe CASES OUTPUT\n"
            "  %s classify CASES EXPECTATIONS OBSERVATIONS OUTPUT\n"
            "  %s verify-dispositions DISPOSITIONS\n",
            program, program, program);
    exit(2);
}

int main(int argc, char **argv) {
    if (argc >= 2 && strcmp(argv[1], "observe") == 0) {
        if (argc != 4) {
            usage(argv[0]);
        }
        observe(argv[2], argv[3]);
        return 0;
    }
    if (argc >= 2 && strcmp(argv[1], "classify") == 0) {
        if (argc != 6) {
            usage(argv[0]);
        }
        classify(argv[2], argv[3], argv[4], argv[5]);
        return 0;
    }
    if (argc >= 2 && strcmp(argv[1], "verify-dispositions") == 0) {
        if (argc != 3) {
            usage(argv[0]);
        }
        verify_dispositions(argv[2]);
        return 0;
    }
    usage(argv[0]);
    return 2;
}
