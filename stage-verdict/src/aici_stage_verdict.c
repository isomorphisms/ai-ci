#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LINE_CAP 16384
#define VALUE_CAP 4096
#define STAGE_CAP 64
#define OBSERVATION_CAP 256

typedef struct {
    char first_code[VALUE_CAP];
    char detail[VALUE_CAP];
    int quiet;
} check_result;

typedef struct {
    char stage_id[VALUE_CAP];
    char actor[VALUE_CAP];
    int required;
    int selected;
    char depends_on[VALUE_CAP];
    char claim[VALUE_CAP];
} stage_plan;

typedef struct {
    int attempt;
    int stage_index;
    char actor[VALUE_CAP];
    char observation[VALUE_CAP];
    char declared_validity[VALUE_CAP];
    char effective_validity[VALUE_CAP];
    char raw_exit[VALUE_CAP];
    char raw_signal[VALUE_CAP];
    char command[VALUE_CAP];
    char source_identity[VALUE_CAP];
    char producer_digest[VALUE_CAP];
    char log_digest[VALUE_CAP];
    char native_code[VALUE_CAP];
    char detail[VALUE_CAP];
} observation;

typedef struct {
    stage_plan stages[STAGE_CAP];
    int stage_count;
    observation observations[OBSERVATION_CAP];
    int observation_count;
} verdict_input;

typedef struct {
    char input_schema[VALUE_CAP];
    char corpus_revision[VALUE_CAP];
    char corpus_repository_revision[VALUE_CAP];
    char fixture_id[VALUE_CAP];
    char implementation_role[VALUE_CAP];
    char implementation_name[VALUE_CAP];
    char source_identity[VALUE_CAP];
    char producer[VALUE_CAP];
    char producer_digest[VALUE_CAP];
    char fallback[VALUE_CAP];
    char scope[VALUE_CAP];
    char first_failure[VALUE_CAP];
    char first_incomplete[VALUE_CAP];
} outer_metadata;

static const char *ingestion_stages[] = {
    "input_acquisition",
    "network",
    "decompression",
    "decoding",
    "html_recovery",
    "document_construction",
    "downstream_extraction"
};

static void reject(check_result *result, const char *code, const char *detail) {
    if (result->first_code[0] == '\0') {
        snprintf(result->first_code, sizeof(result->first_code), "%s", code);
        snprintf(result->detail, sizeof(result->detail), "%s", detail);
    }
    if (!result->quiet) fprintf(stderr, "FAIL\t%s\t%s\n", code, detail);
}

static void trim_line(char *line) {
    size_t length = strlen(line);
    while (length > 0 && (line[length - 1] == '\n' || line[length - 1] == '\r')) {
        line[--length] = '\0';
    }
}

static int split_tabs(char *line, char **fields, int capacity) {
    int count = 0;
    char *cursor = line;
    while (count < capacity) {
        fields[count++] = cursor;
        char *tab = strchr(cursor, '\t');
        if (tab == NULL) break;
        *tab = '\0';
        cursor = tab + 1;
    }
    return count;
}

static int copy_value(char *destination, size_t capacity, const char *source) {
    size_t length = strlen(source);
    if (length == 0 || length >= capacity) return 0;
    memcpy(destination, source, length + 1);
    return 1;
}

static int valid_sha256_or_absent(const char *value) {
    if (strcmp(value, "-") == 0) return 1;
    if (strlen(value) != 64) return 0;
    for (const unsigned char *cursor = (const unsigned char *)value; *cursor != '\0'; ++cursor) {
        if (!isxdigit(*cursor)) return 0;
    }
    return 1;
}

static int parse_boolean(const char *value, int *parsed) {
    if (strcmp(value, "yes") == 0) {
        *parsed = 1;
        return 1;
    }
    if (strcmp(value, "no") == 0) {
        *parsed = 0;
        return 1;
    }
    return 0;
}

static int find_stage(const verdict_input *input, const char *stage_id) {
    for (int index = 0; index < input->stage_count; ++index) {
        if (strcmp(input->stages[index].stage_id, stage_id) == 0) return index;
    }
    return -1;
}

static int valid_observation(const char *value) {
    static const char *values[] = {
        "PASS", "FAIL", "NOT_RUN", "SKIPPED", "INTERRUPTED", "TIMEOUT"
    };
    for (size_t index = 0; index < sizeof(values) / sizeof(values[0]); ++index) {
        if (strcmp(value, values[index]) == 0) return 1;
    }
    return 0;
}

static int valid_evidence_validity(const char *value) {
    static const char *values[] = {
        "VALID", "INCOMPLETE", "MALFORMED", "STALE", "WRONG_TARGET",
        "WRONG_LAYER", "UNTRUSTED_PRODUCER"
    };
    for (size_t index = 0; index < sizeof(values) / sizeof(values[0]); ++index) {
        if (strcmp(value, values[index]) == 0) return 1;
    }
    return 0;
}

static int valid_raw_exit(const char *value) {
    if (strcmp(value, "-") == 0) return 1;
    if (*value == '\0') return 0;
    errno = 0;
    char *end = NULL;
    long parsed = strtol(value, &end, 10);
    return errno == 0 && end != value && *end == '\0' && parsed >= 0 && parsed <= 255;
}

static int parse_plan(const char *path, verdict_input *input, check_result *result) {
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        reject(result, "PLAN-OPEN", path);
        return 0;
    }
    char line[LINE_CAP];
    int header_seen = 0;
    while (fgets(line, sizeof(line), file) != NULL) {
        if (strchr(line, '\n') == NULL && !feof(file)) {
            reject(result, "PLAN-LINE-LONG", path);
            fclose(file);
            return 0;
        }
        trim_line(line);
        if (line[0] == '\0' || line[0] == '#') continue;
        if (!header_seen) {
            header_seen = 1;
            if (strcmp(line, "stage_id\tactor\trequired\tselected\tdepends_on\tclaim") != 0) {
                reject(result, "PLAN-HEADER", line);
                fclose(file);
                return 0;
            }
            continue;
        }
        if (input->stage_count == STAGE_CAP) {
            reject(result, "PLAN-TOO-MANY-STAGES", path);
            fclose(file);
            return 0;
        }
        char *fields[7];
        int count = split_tabs(line, fields, 7);
        if (count != 6) {
            reject(result, "PLAN-SHAPE", line);
            fclose(file);
            return 0;
        }
        stage_plan *stage = &input->stages[input->stage_count];
        memset(stage, 0, sizeof(*stage));
        if (!copy_value(stage->stage_id, sizeof(stage->stage_id), fields[0]) ||
            !copy_value(stage->actor, sizeof(stage->actor), fields[1]) ||
            !copy_value(stage->depends_on, sizeof(stage->depends_on), fields[4]) ||
            !copy_value(stage->claim, sizeof(stage->claim), fields[5])) {
            reject(result, "PLAN-FIELD", line);
            fclose(file);
            return 0;
        }
        if (!parse_boolean(fields[2], &stage->required)) {
            reject(result, "PLAN-REQUIRED", stage->stage_id);
            fclose(file);
            return 0;
        }
        if (!parse_boolean(fields[3], &stage->selected)) {
            reject(result, "PLAN-SELECTION", stage->stage_id);
            fclose(file);
            return 0;
        }
        if (find_stage(input, stage->stage_id) >= 0) {
            reject(result, "PLAN-DUPLICATE-STAGE", stage->stage_id);
            fclose(file);
            return 0;
        }
        if (strcmp(stage->depends_on, "-") != 0 && find_stage(input, stage->depends_on) < 0) {
            reject(result, "PLAN-DEPENDENCY", stage->stage_id);
            fclose(file);
            return 0;
        }
        ++input->stage_count;
    }
    fclose(file);
    if (!header_seen || input->stage_count == 0) {
        reject(result, "PLAN-EMPTY", path);
        return 0;
    }
    return 1;
}

static int parse_attempt(const char *value, int *attempt) {
    errno = 0;
    char *end = NULL;
    long parsed = strtol(value, &end, 10);
    if (errno != 0 || end == value || *end != '\0' || parsed < 1 || parsed > 2147483647L) return 0;
    *attempt = (int)parsed;
    return 1;
}

static int duplicate_observation(const verdict_input *input, int stage_index, int attempt) {
    for (int index = 0; index < input->observation_count; ++index) {
        if (input->observations[index].stage_index == stage_index &&
            input->observations[index].attempt == attempt) return 1;
    }
    return 0;
}

static void classify_effective_validity(observation *observed, const stage_plan *stage) {
    strcpy(observed->effective_validity, observed->declared_validity);
    if (strcmp(observed->effective_validity, "VALID") != 0) return;
    if (strcmp(observed->actor, stage->actor) != 0) {
        snprintf(observed->effective_validity, sizeof(observed->effective_validity), "WRONG_TARGET");
        return;
    }
    int has_exit = strcmp(observed->raw_exit, "-") != 0;
    int has_signal = strcmp(observed->raw_signal, "-") != 0;
    int exit_value = has_exit ? atoi(observed->raw_exit) : -1;
    int malformed = 0;
    if (strcmp(observed->observation, "PASS") == 0) {
        malformed = has_signal || (has_exit && exit_value != 0);
    } else if (strcmp(observed->observation, "FAIL") == 0) {
        malformed = has_exit && exit_value == 0 && !has_signal;
    } else if (strcmp(observed->observation, "NOT_RUN") == 0 ||
               strcmp(observed->observation, "SKIPPED") == 0) {
        malformed = has_exit || has_signal;
    } else if (strcmp(observed->observation, "INTERRUPTED") == 0 ||
               strcmp(observed->observation, "TIMEOUT") == 0) {
        malformed = !has_signal && (!has_exit || exit_value == 0);
    }
    if (malformed) {
        snprintf(observed->effective_validity, sizeof(observed->effective_validity), "MALFORMED");
    }
}

static int parse_observations(const char *path, verdict_input *input, check_result *result) {
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        reject(result, "OBS-OPEN", path);
        return 0;
    }
    char line[LINE_CAP];
    int header_seen = 0;
    while (fgets(line, sizeof(line), file) != NULL) {
        if (strchr(line, '\n') == NULL && !feof(file)) {
            reject(result, "OBS-LINE-LONG", path);
            fclose(file);
            return 0;
        }
        trim_line(line);
        if (line[0] == '\0' || line[0] == '#') continue;
        if (!header_seen) {
            header_seen = 1;
            if (strcmp(line, "attempt\tstage_id\tactor\tobservation\tevidence_validity\texit\tsignal\tcommand\tsource_identity\tproducer_digest\tlog_digest\tnative_code\tdetail") != 0) {
                reject(result, "OBS-HEADER", line);
                fclose(file);
                return 0;
            }
            continue;
        }
        if (input->observation_count == OBSERVATION_CAP) {
            reject(result, "OBS-TOO-MANY", path);
            fclose(file);
            return 0;
        }
        char *fields[14];
        int count = split_tabs(line, fields, 14);
        if (count != 13) {
            reject(result, "OBS-SHAPE", line);
            fclose(file);
            return 0;
        }
        observation *observed = &input->observations[input->observation_count];
        memset(observed, 0, sizeof(*observed));
        if (!parse_attempt(fields[0], &observed->attempt)) {
            reject(result, "OBS-ATTEMPT", fields[0]);
            fclose(file);
            return 0;
        }
        observed->stage_index = find_stage(input, fields[1]);
        if (observed->stage_index < 0) {
            reject(result, "OBS-STAGE", fields[1]);
            fclose(file);
            return 0;
        }
        if (duplicate_observation(input, observed->stage_index, observed->attempt)) {
            reject(result, "OBS-DUPLICATE-ATTEMPT", fields[1]);
            fclose(file);
            return 0;
        }
        if (!valid_observation(fields[3])) {
            reject(result, "OBS-STATUS", fields[3]);
            fclose(file);
            return 0;
        }
        if (!valid_evidence_validity(fields[4])) {
            reject(result, "OBS-VALIDITY", fields[4]);
            fclose(file);
            return 0;
        }
        if (!valid_raw_exit(fields[5])) {
            reject(result, "OBS-EXIT", fields[5]);
            fclose(file);
            return 0;
        }
        if (!valid_sha256_or_absent(fields[9]) || !valid_sha256_or_absent(fields[10])) {
            reject(result, "OBS-DIGEST", fields[1]);
            fclose(file);
            return 0;
        }
        char *destinations[] = {
            observed->actor, observed->observation, observed->declared_validity,
            observed->raw_exit, observed->raw_signal, observed->command,
            observed->source_identity, observed->producer_digest, observed->log_digest,
            observed->native_code, observed->detail
        };
        size_t capacities[] = {
            sizeof(observed->actor), sizeof(observed->observation), sizeof(observed->declared_validity),
            sizeof(observed->raw_exit), sizeof(observed->raw_signal), sizeof(observed->command),
            sizeof(observed->source_identity), sizeof(observed->producer_digest), sizeof(observed->log_digest),
            sizeof(observed->native_code), sizeof(observed->detail)
        };
        for (int index = 0; index < 11; ++index) {
            if (!copy_value(destinations[index], capacities[index], fields[index + 2])) {
                reject(result, "OBS-FIELD", fields[1]);
                fclose(file);
                return 0;
            }
        }
        classify_effective_validity(observed, &input->stages[observed->stage_index]);
        ++input->observation_count;
    }
    fclose(file);
    if (!header_seen) {
        reject(result, "OBS-EMPTY", path);
        return 0;
    }
    return 1;
}

static int compare_observation_order(const void *left_value, const void *right_value) {
    const observation *left = left_value;
    const observation *right = right_value;
    if (left->stage_index != right->stage_index) return left->stage_index - right->stage_index;
    return left->attempt - right->attempt;
}

static const char *stage_disposition(const stage_plan *stage, const observation *observed) {
    if (strcmp(observed->effective_validity, "VALID") != 0) return "HOLD_FOR_EVIDENCE";
    if (strcmp(observed->observation, "PASS") == 0) return "ACCEPT_SCOPE";
    if (strcmp(observed->observation, "SKIPPED") == 0 && !stage->required) {
        return "NOT_APPLICABLE_WITH_REASON";
    }
    if (strcmp(observed->observation, "FAIL") == 0 ||
        strcmp(observed->observation, "INTERRUPTED") == 0 ||
        strcmp(observed->observation, "TIMEOUT") == 0) return "REJECT_SCOPE";
    return "HOLD_FOR_EVIDENCE";
}

static int stage_has_observation(const verdict_input *input, int stage_index) {
    for (int index = 0; index < input->observation_count; ++index) {
        if (input->observations[index].stage_index == stage_index) return 1;
    }
    return 0;
}

static int render_verdict(FILE *output, verdict_input *input, const outer_metadata *metadata) {
    qsort(input->observations, (size_t)input->observation_count,
          sizeof(input->observations[0]), compare_observation_order);
    const char *first_failure = "none";
    const char *first_incomplete = "none";
    int selected_complete = 1;
    for (int stage_index = 0; stage_index < input->stage_count; ++stage_index) {
        const stage_plan *stage = &input->stages[stage_index];
        if (!stage->selected) continue;
        if (!stage_has_observation(input, stage_index)) selected_complete = 0;
        if (!stage->required) continue;
        int found = 0;
        int failed = 0;
        int incomplete = 0;
        for (int index = 0; index < input->observation_count; ++index) {
            const observation *observed = &input->observations[index];
            if (observed->stage_index != stage_index) continue;
            found = 1;
            if (strcmp(observed->effective_validity, "VALID") != 0) incomplete = 1;
            if (strcmp(observed->observation, "FAIL") == 0 ||
                strcmp(observed->observation, "INTERRUPTED") == 0 ||
                strcmp(observed->observation, "TIMEOUT") == 0) {
                if (strcmp(observed->effective_validity, "VALID") == 0) failed = 1;
                incomplete = 1;
            } else if (strcmp(observed->observation, "NOT_RUN") == 0 ||
                       strcmp(observed->observation, "SKIPPED") == 0) {
                incomplete = 1;
            }
        }
        if (!found) incomplete = 1;
        if (failed && strcmp(first_failure, "none") == 0) first_failure = stage->stage_id;
        if (incomplete && strcmp(first_incomplete, "none") == 0) first_incomplete = stage->stage_id;
    }
    const char *aggregate = strcmp(first_failure, "none") != 0 ? "REJECT_SCOPE" :
        (strcmp(first_incomplete, "none") != 0 ? "HOLD_FOR_EVIDENCE" : "ACCEPT_SCOPE");

    fprintf(output, "meta\tschema\taici-stage-verdict-v1\n");
    if (metadata != NULL) {
        const char *normalized_producer_digest =
            strcmp(metadata->producer_digest, "none") == 0 ? "-" : metadata->producer_digest;
        fprintf(output, "meta\tinput_schema\t%s\n", metadata->input_schema);
        fprintf(output, "meta\tfixture_id\t%s\n", metadata->fixture_id);
        fprintf(output, "meta\tsource_identity\t%s\n", metadata->source_identity);
        fprintf(output, "meta\tproducer\t%s\n", metadata->producer);
        fprintf(output, "meta\tproducer_digest\t%s\n", normalized_producer_digest);
        fprintf(output, "source_meta\tschema\t%s\n", metadata->input_schema);
        fprintf(output, "source_meta\tcorpus_revision\t%s\n", metadata->corpus_revision);
        fprintf(output, "source_meta\tcorpus_repository_revision\t%s\n",
                metadata->corpus_repository_revision);
        fprintf(output, "source_meta\tfixture_id\t%s\n", metadata->fixture_id);
        fprintf(output, "source_meta\timplementation_role\t%s\n",
                metadata->implementation_role);
        fprintf(output, "source_meta\timplementation_name\t%s\n",
                metadata->implementation_name);
        fprintf(output, "source_meta\timplementation_revision\t%s\n",
                metadata->source_identity);
        fprintf(output, "source_meta\texecutable_sha256\t%s\n", metadata->producer_digest);
        fprintf(output, "source_meta\tfallback\t%s\n", metadata->fallback);
        fprintf(output, "source_meta\tscope\t%s\n", metadata->scope);
        fprintf(output, "source_meta\tproducer\t%s\n", metadata->producer);
        fprintf(output, "source_summary\tfirst_failure\t%s\n", metadata->first_failure);
        fprintf(output, "source_summary\tfirst_incomplete\t%s\n", metadata->first_incomplete);
    }
    fprintf(output, "summary\tselected_complete\t%s\n", selected_complete ? "yes" : "no");
    fprintf(output, "summary\tfirst_required_failure\t%s\n", first_failure);
    fprintf(output, "summary\tfirst_required_incomplete\t%s\n", first_incomplete);
    fprintf(output, "summary\tdisposition\t%s\n", aggregate);
    fprintf(output, "kind\tstage_id\tattempt\tactor\trequired\tselected\tdepends_on\tclaim\tobservation\tdeclared_evidence_validity\tevidence_validity\tdiagnosis\tdisposition\texit\tsignal\tcommand\tsource_identity\tproducer_digest\tlog_digest\tnative_code\tdetail\n");
    for (int stage_index = 0; stage_index < input->stage_count; ++stage_index) {
        const stage_plan *stage = &input->stages[stage_index];
        int found = 0;
        for (int index = 0; index < input->observation_count; ++index) {
            const observation *observed = &input->observations[index];
            if (observed->stage_index != stage_index) continue;
            found = 1;
            fprintf(output,
                "verdict\t%s\t%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\tUNKNOWN\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                stage->stage_id, observed->attempt, observed->actor,
                stage->required ? "yes" : "no", stage->selected ? "yes" : "no",
                stage->depends_on, stage->claim, observed->observation,
                observed->declared_validity, observed->effective_validity,
                stage_disposition(stage, observed), observed->raw_exit,
                observed->raw_signal, observed->command, observed->source_identity,
                observed->producer_digest, observed->log_digest, observed->native_code,
                observed->detail);
        }
        if (!found && stage->selected) {
            fprintf(output,
                "verdict\t%s\t0\t%s\t%s\tyes\t%s\t%s\tNOT_RUN\tINCOMPLETE\tINCOMPLETE\tUNKNOWN\tHOLD_FOR_EVIDENCE\t-\t-\t-\t-\t-\t-\tabsent_receipt\tno observation for selected stage\n",
                stage->stage_id, stage->actor, stage->required ? "yes" : "no",
                stage->depends_on, stage->claim);
        }
    }
    return strcmp(aggregate, "ACCEPT_SCOPE") == 0 ? 0 : 1;
}

static int normalize_files(const char *plan_path, const char *observations_path,
                           FILE *output, check_result *result) {
    verdict_input *input = calloc(1, sizeof(*input));
    if (input == NULL) {
        reject(result, "MEMORY", "cannot allocate verdict input");
        return 2;
    }
    if (!parse_plan(plan_path, input, result)) {
        free(input);
        return 2;
    }
    if (!parse_observations(observations_path, input, result)) {
        free(input);
        return 2;
    }
    int status = render_verdict(output, input, NULL);
    free(input);
    return status;
}

static int ingestion_stage_index(const char *name) {
    for (int index = 0; index < 7; ++index) {
        if (strcmp(name, ingestion_stages[index]) == 0) return index;
    }
    return -1;
}

static int assign_outer_meta(outer_metadata *metadata, const char *key, const char *value) {
    char *destination = NULL;
    size_t capacity = 0;
    if (strcmp(key, "schema") == 0) {
        destination = metadata->input_schema;
        capacity = sizeof(metadata->input_schema);
    } else if (strcmp(key, "corpus_revision") == 0) {
        destination = metadata->corpus_revision;
        capacity = sizeof(metadata->corpus_revision);
    } else if (strcmp(key, "corpus_repository_revision") == 0) {
        destination = metadata->corpus_repository_revision;
        capacity = sizeof(metadata->corpus_repository_revision);
    } else if (strcmp(key, "fixture_id") == 0) {
        destination = metadata->fixture_id;
        capacity = sizeof(metadata->fixture_id);
    } else if (strcmp(key, "implementation_role") == 0) {
        destination = metadata->implementation_role;
        capacity = sizeof(metadata->implementation_role);
    } else if (strcmp(key, "implementation_name") == 0) {
        destination = metadata->implementation_name;
        capacity = sizeof(metadata->implementation_name);
    } else if (strcmp(key, "implementation_revision") == 0) {
        destination = metadata->source_identity;
        capacity = sizeof(metadata->source_identity);
    } else if (strcmp(key, "producer") == 0) {
        destination = metadata->producer;
        capacity = sizeof(metadata->producer);
    } else if (strcmp(key, "executable_sha256") == 0) {
        destination = metadata->producer_digest;
        capacity = sizeof(metadata->producer_digest);
    } else if (strcmp(key, "fallback") == 0) {
        destination = metadata->fallback;
        capacity = sizeof(metadata->fallback);
    } else if (strcmp(key, "scope") == 0) {
        destination = metadata->scope;
        capacity = sizeof(metadata->scope);
    } else {
        return -1;
    }
    if (destination[0] != '\0' || !copy_value(destination, capacity, value)) return 0;
    return 1;
}

static int map_ingestion_receipt(const char *path, verdict_input *input,
                                 outer_metadata *metadata, check_result *result) {
    memset(input, 0, sizeof(*input));
    memset(metadata, 0, sizeof(*metadata));
    for (int index = 0; index < 7; ++index) {
        stage_plan *stage = &input->stages[index];
        snprintf(stage->stage_id, sizeof(stage->stage_id), "%s", ingestion_stages[index]);
        snprintf(stage->actor, sizeof(stage->actor), "pending-native-owner");
        stage->required = index != 6;
        stage->selected = 1;
        snprintf(stage->depends_on, sizeof(stage->depends_on), "%s",
                 index == 0 ? "-" : ingestion_stages[index - 1]);
        snprintf(stage->claim, sizeof(stage->claim), "%s", ingestion_stages[index]);
    }
    input->stage_count = 7;

    FILE *file = fopen(path, "r");
    if (file == NULL) {
        reject(result, "INGESTION-OPEN", path);
        return 0;
    }
    char line[LINE_CAP];
    while (fgets(line, sizeof(line), file) != NULL) {
        trim_line(line);
        if (line[0] == '\0' || line[0] == '#') continue;
        char *fields[8];
        int count = split_tabs(line, fields, 8);
        if (count == 3 && strcmp(fields[0], "meta") == 0) {
            if (assign_outer_meta(metadata, fields[1], fields[2]) != 1) {
                reject(result, "INGESTION-META", fields[1]);
                fclose(file);
                return 0;
            }
            continue;
        }
        if (count == 3 && strcmp(fields[0], "summary") == 0) {
            char *destination = NULL;
            size_t capacity = 0;
            if (strcmp(fields[1], "first_failure") == 0) {
                destination = metadata->first_failure;
                capacity = sizeof(metadata->first_failure);
            } else if (strcmp(fields[1], "first_incomplete") == 0) {
                destination = metadata->first_incomplete;
                capacity = sizeof(metadata->first_incomplete);
            }
            if (destination == NULL || destination[0] != '\0' ||
                !copy_value(destination, capacity, fields[2])) {
                reject(result, "INGESTION-SUMMARY", fields[1]);
                fclose(file);
                return 0;
            }
            continue;
        }
        if (count != 7 || strcmp(fields[0], "stage") != 0) {
            reject(result, "INGESTION-SHAPE", line);
            fclose(file);
            return 0;
        }
        int stage_index = ingestion_stage_index(fields[2]);
        if (stage_index < 0 || stage_has_observation(input, stage_index)) {
            reject(result, "INGESTION-STAGE", fields[2]);
            fclose(file);
            return 0;
        }
        if (strcmp(fields[3], "PASS") != 0 && strcmp(fields[3], "FAIL") != 0 &&
            strcmp(fields[3], "SKIP") != 0) {
            reject(result, "INGESTION-STATUS", fields[3]);
            fclose(file);
            return 0;
        }
        observation *observed = &input->observations[input->observation_count++];
        memset(observed, 0, sizeof(*observed));
        observed->attempt = 1;
        observed->stage_index = stage_index;
        if (!copy_value(observed->actor, sizeof(observed->actor), fields[5]) ||
            !copy_value(input->stages[stage_index].actor,
                        sizeof(input->stages[stage_index].actor), fields[5])) {
            reject(result, "INGESTION-ACTOR", fields[2]);
            fclose(file);
            return 0;
        }
        const char *mapped = strcmp(fields[3], "PASS") == 0 ? "PASS" :
            (strcmp(fields[3], "FAIL") == 0 ? "FAIL" :
             (strncmp(fields[4], "not_applicable", 14) == 0 ? "SKIPPED" : "NOT_RUN"));
        snprintf(observed->observation, sizeof(observed->observation), "%s", mapped);
        snprintf(observed->declared_validity, sizeof(observed->declared_validity), "VALID");
        snprintf(observed->effective_validity, sizeof(observed->effective_validity), "VALID");
        snprintf(observed->raw_exit, sizeof(observed->raw_exit), "-");
        snprintf(observed->raw_signal, sizeof(observed->raw_signal), "-");
        snprintf(observed->command, sizeof(observed->command), "-");
        snprintf(observed->log_digest, sizeof(observed->log_digest), "-");
        if (!copy_value(observed->native_code, sizeof(observed->native_code), fields[4]) ||
            !copy_value(observed->detail, sizeof(observed->detail), fields[6])) {
            reject(result, "INGESTION-FIELD", fields[2]);
            fclose(file);
            return 0;
        }
    }
    fclose(file);
    if (strcmp(metadata->input_schema, "aici-ingestion-receipt-v1") != 0 ||
        metadata->corpus_revision[0] == '\0' ||
        metadata->corpus_repository_revision[0] == '\0' ||
        metadata->fixture_id[0] == '\0' || metadata->implementation_role[0] == '\0' ||
        metadata->implementation_name[0] == '\0' || metadata->source_identity[0] == '\0' ||
        metadata->producer[0] == '\0' || metadata->fallback[0] == '\0' ||
        metadata->scope[0] == '\0' || metadata->first_failure[0] == '\0' ||
        metadata->first_incomplete[0] == '\0' ||
        (strcmp(metadata->producer_digest, "none") != 0 &&
         !valid_sha256_or_absent(metadata->producer_digest))) {
        reject(result, "INGESTION-IDENTITY", path);
        return 0;
    }
    const char *mapped_digest = strcmp(metadata->producer_digest, "none") == 0 ?
        "-" : metadata->producer_digest;
    for (int index = 0; index < input->observation_count; ++index) {
        if (!copy_value(input->observations[index].source_identity,
                        sizeof(input->observations[index].source_identity),
                        metadata->source_identity) ||
            !copy_value(input->observations[index].producer_digest,
                        sizeof(input->observations[index].producer_digest),
                        mapped_digest)) {
            reject(result, "INGESTION-IDENTITY", path);
            return 0;
        }
    }
    for (int index = 0; index < 7; ++index) {
        if (!stage_has_observation(input, index)) {
            reject(result, "INGESTION-STAGE-MISSING", ingestion_stages[index]);
            return 0;
        }
    }
    return 1;
}

static int compare_files(FILE *actual, const char *expected_path) {
    FILE *expected = fopen(expected_path, "r");
    if (expected == NULL) return 0;
    rewind(actual);
    int left = 0;
    int right = 0;
    do {
        left = fgetc(actual);
        right = fgetc(expected);
        if (left != right) {
            fclose(expected);
            return 0;
        }
    } while (left != EOF && right != EOF);
    fclose(expected);
    return left == EOF && right == EOF;
}

static int join_path(char *output, size_t capacity, const char *root, const char *relative) {
    int count = snprintf(output, capacity, "%s/%s", root, relative);
    return count >= 0 && (size_t)count < capacity;
}

static int self_test(const char *cases_path, const char *root) {
    FILE *cases = fopen(cases_path, "r");
    if (cases == NULL) {
        fprintf(stderr, "FAIL\tSELF-TEST-OPEN\t%s\n", cases_path);
        return 1;
    }
    char line[LINE_CAP];
    int header_seen = 0;
    int count = 0;
    while (fgets(line, sizeof(line), cases) != NULL) {
        trim_line(line);
        if (line[0] == '\0' || line[0] == '#') continue;
        if (!header_seen) {
            header_seen = 1;
            if (strcmp(line, "case_id\tplan\tobservations\texpected\texit\tdiagnostic") != 0) {
                fprintf(stderr, "FAIL\tSELF-TEST-HEADER\t%s\n", line);
                fclose(cases);
                return 1;
            }
            continue;
        }
        char *fields[7];
        if (split_tabs(line, fields, 7) != 6) {
            fprintf(stderr, "FAIL\tSELF-TEST-SHAPE\t%s\n", line);
            fclose(cases);
            return 1;
        }
        char plan_path[VALUE_CAP];
        char observations_path[VALUE_CAP];
        char expected_path[VALUE_CAP];
        if (!join_path(plan_path, sizeof(plan_path), root, fields[1]) ||
            !join_path(observations_path, sizeof(observations_path), root, fields[2]) ||
            (strcmp(fields[3], "-") != 0 &&
             !join_path(expected_path, sizeof(expected_path), root, fields[3]))) {
            fprintf(stderr, "FAIL\tSELF-TEST-PATH\t%s\n", fields[0]);
            fclose(cases);
            return 1;
        }
        FILE *actual = tmpfile();
        if (actual == NULL) {
            fprintf(stderr, "FAIL\tSELF-TEST-TEMP\t%s\n", fields[0]);
            fclose(cases);
            return 1;
        }
        check_result result;
        memset(&result, 0, sizeof(result));
        result.quiet = 1;
        int actual_exit = normalize_files(plan_path, observations_path, actual, &result);
        int expected_exit = atoi(fields[4]);
        int diagnostic_ok = (strcmp(fields[5], "-") == 0 && result.first_code[0] == '\0') ||
            strcmp(fields[5], result.first_code) == 0;
        int output_ok = strcmp(fields[3], "-") == 0 ? ftell(actual) == 0 :
            compare_files(actual, expected_path);
        fclose(actual);
        if (actual_exit != expected_exit || !diagnostic_ok || !output_ok) {
            fprintf(stderr, "FAIL\tSELF-TEST-CASE\t%s exit=%d diagnostic=%s output=%s\n",
                    fields[0], actual_exit, result.first_code[0] == '\0' ? "-" : result.first_code,
                    output_ok ? "match" : "mismatch");
            fclose(cases);
            return 1;
        }
        ++count;
    }
    fclose(cases);
    if (!header_seen || count == 0) {
        fprintf(stderr, "FAIL\tSELF-TEST-EMPTY\t%s\n", cases_path);
        return 1;
    }
    printf("PASS\tstage-verdict-self-test\t%d cases\n", count);
    return 0;
}

static void usage(const char *program) {
    fprintf(stderr,
        "usage:\n"
        "  %s normalize PLAN.tsv OBSERVATIONS.tsv\n"
        "  %s ingestion INGESTION-RECEIPT.tsv\n"
        "  %s self-test CASES.tsv TEST-ROOT\n",
        program, program, program);
}

int main(int argc, char **argv) {
    if (argc == 4 && strcmp(argv[1], "normalize") == 0) {
        check_result result;
        memset(&result, 0, sizeof(result));
        return normalize_files(argv[2], argv[3], stdout, &result);
    }
    if (argc == 3 && strcmp(argv[1], "ingestion") == 0) {
        verdict_input *input = calloc(1, sizeof(*input));
        outer_metadata metadata;
        check_result result;
        memset(&result, 0, sizeof(result));
        if (input == NULL) {
            reject(&result, "MEMORY", "cannot allocate verdict input");
            return 2;
        }
        if (!map_ingestion_receipt(argv[2], input, &metadata, &result)) {
            free(input);
            return 2;
        }
        int status = render_verdict(stdout, input, &metadata);
        free(input);
        return status;
    }
    if (argc == 4 && strcmp(argv[1], "self-test") == 0) return self_test(argv[2], argv[3]);
    usage(argv[0]);
    return 2;
}
