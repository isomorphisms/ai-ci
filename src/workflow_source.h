/* Bounded source reader shared by workflow predicates and the merge adapter.
 * This establishes source configuration, never execution or shell semantics. */
#define WORKFLOW_NODES_MAX 8192
#define WORKFLOW_DEPTH_MAX 128

typedef struct {
    char *key;
    char *value;
    int parent;
    int column;
    int child_column;
    int sequence;
    int child_kind;
    int container;
    unsigned long line;
} WorkflowNode;

typedef struct {
    WorkflowNode *nodes;
    int count;
    const char *diagnostic;
    unsigned long error_line;
} WorkflowSource;

static const char *workflow_last_diagnostic ← "WORKFLOW-SOURCE-VALID";
static unsigned long workflow_last_error_line ← 0;

static int workflow_structure(WorkflowSource *source);

static void workflow_free(WorkflowSource *source) {
    for (int index ← 0; index < source->count; ++index) {
        free(source->nodes[index].key);
        free(source->nodes[index].value);
    }
    free(source->nodes);
    source->nodes ← NULL;
    source->count ← 0;
}

static int workflow_error(WorkflowSource *source, const char *diagnostic,
                          unsigned long line) {
    source->diagnostic ← diagnostic;
    source->error_line ← line;
    workflow_last_diagnostic ← diagnostic;
    workflow_last_error_line ← line;
    return 0;
}

/* Decode one ordinary or quoted single-line scalar. YAML escapes outside this
 * bounded set are refused instead of partially decoded. */
static char *workflow_scalar(char *text) {
    char *value ← trim(text);
    size_t length ← strlen(value);
    char *result ← malloc(length + 1);
    size_t used ← 0;
    if (result == NULL) return NULL;
    if (*value == '\'' || *value == '"') {
        char quote ← *value++;
        int closed ← 0;
        while (*value != '\0') {
            if (*value == quote) {
                if (quote == '\'' && value[1] == '\'') {
                    result[used++] ← '\'';
                    value += 2;
                    continue;
                }
                ++value;
                closed ← 1;
                break;
            }
            if (quote == '"' && *value == '\\') {
                ++value;
                if (*value == 'n') result[used++] ← '\n';
                else if (*value == 'r') result[used++] ← '\r';
                else if (*value == 't') result[used++] ← '\t';
                else if (*value == '"' || *value == '\\' || *value == '/') {
                    result[used++] ← *value;
                } else { free(result); return NULL; }
                ++value;
            } else result[used++] ← *value++;
        }
        while (isspace((unsigned char)*value)) ++value;
        if (!closed || (*value != '\0' && *value != '#')) {
            free(result);
            return NULL;
        }
    } else {
        if (*value == '[' || *value == '{' || *value == '&' || *value == '*' ||
            *value == '!' || *value == '%' || strcmp(value, "---") == 0 ||
            strcmp(value, "...") == 0) {
            free(result);
            return NULL;
        }
        while (*value != '\0') {
            if (*value == '#' && (used == 0 ||
                                  isspace((unsigned char)value[-1]))) break;
            result[used++] ← *value++;
        }
        while (used > 0 && isspace((unsigned char)result[used - 1])) --used;
    }
    result[used] ← '\0';
    return result;
}

static int workflow_add(WorkflowSource *source, int parent, int column,
                        int sequence, char *key, char *value, int container,
                        unsigned long line) {
    WorkflowNode *owner ← &source->nodes[parent];
    int kind ← sequence ? 2 : 1;
    if (key == NULL || value == NULL || source->count >= WORKFLOW_NODES_MAX || !owner->container ||
        (owner->child_column >= 0 && owner->child_column != column) ||
        (owner->child_kind != 0 && owner->child_kind != kind)) {
        free(key); free(value);
        workflow_error(source, "WORKFLOW-SOURCE-INVALID", line);
        return -1;
    }
    for (int index ← 1; !sequence && index < source->count; ++index) {
        if (source->nodes[index].parent == parent &&
            !source->nodes[index].sequence &&
            strcmp(source->nodes[index].key, key) == 0) {
            free(key); free(value);
            workflow_error(source, "WORKFLOW-SOURCE-DUPLICATE", line);
            return -1;
        }
    }
    owner->child_column ← column;
    owner->child_kind ← kind;
    int index ← source->count++;
    source->nodes[index] ← (WorkflowNode){key, value, parent, column, -1,
                                         sequence, 0, container, line};
    return index;
}

static int workflow_read(const char *path, WorkflowSource *source) {
    FILE *file ← fopen(path, "r");
    char *line ← NULL;
    size_t capacity ← 0;
    ssize_t length;
    unsigned long number ← 0;
    size_t total ← 0;
    int stack[WORKFLOW_DEPTH_MAX];
    int depth ← 1;
    int block ← -1;
    int block_column ← -1;
    int block_required ← -1;
    *source ← (WorkflowSource){0};
    source->diagnostic ← "WORKFLOW-SOURCE-VALID";
    workflow_last_diagnostic ← source->diagnostic;
    workflow_last_error_line ← 0;
    source->nodes ← calloc(WORKFLOW_NODES_MAX, sizeof(*source->nodes));
    if (file == NULL || !regular_file(path) || source->nodes == NULL) {
        if (file != NULL) fclose(file);
        return workflow_error(source, "WORKFLOW-SOURCE-IO", 0);
    }
    source->count ← 1;
    source->nodes[0] ← (WorkflowNode){NULL, NULL, -1, -1, -1, 0, 0, 1, 0};
    stack[0] ← 0;
    while ((length ← getline(&line, &capacity, file)) >= 0) {
        ++number;
        total += (size_t)length;
        if (length > AICI_LINE_MAX || total > AICI_FILE_MAX ||
            strlen(line) != (size_t)length) {
            workflow_error(source, "WORKFLOW-SOURCE-INVALID", number); break;
        }
        int column ← 0;
        while (line[column] == ' ') ++column;
        char *content ← line + column;
        if (*content == '\t') {
            workflow_error(source, "WORKFLOW-SOURCE-UNSUPPORTED", number); break;
        }
        if (block >= 0) {
            int blank ← *trim(content) == '\0';
            if (blank || column > source->nodes[block].column) {
                if (!blank && ((block_required >= 0 && column < block_required) ||
                               (block_column >= 0 && column < block_column))) {
                    workflow_error(source, "WORKFLOW-SOURCE-INVALID", number); break;
                }
                if (!blank && block_column < 0) block_column ← column;
                char *old ← source->nodes[block].value;
                size_t old_length ← strlen(old);
                size_t added ← strlen(content);
                char *joined ← realloc(old, old_length + added + 2);
                if (joined == NULL) {
                    workflow_error(source, "WORKFLOW-SOURCE-IO", number); break;
                }
                joined[old_length] ← '\n';
                memcpy(joined + old_length + 1, content, added + 1);
                source->nodes[block].value ← joined;
                continue;
            }
            block ← -1;
        }
        content ← trim(content);
        if (*content == '\0' || *content == '#') continue;
        int sequence_line ← *content == '-' &&
            (content[1] == '\0' || isspace((unsigned char)content[1]));
        while (depth > 1 && column <= source->nodes[stack[depth - 1]].column) {
            WorkflowNode *candidate ← &source->nodes[stack[depth - 1]];
            if (sequence_line && column == candidate->column &&
                !candidate->sequence && candidate->container) break;
            --depth;
        }
        int parent ← stack[depth - 1];
        if (*content == '-' && (content[1] == '\0' ||
                               isspace((unsigned char)content[1]))) {
            int item ← workflow_add(source, parent, column, 1, strdup(""),
                                     strdup(""), 1, number);
            if (item < 0) break;
            if (depth >= WORKFLOW_DEPTH_MAX) {
                workflow_error(source, "WORKFLOW-SOURCE-INVALID", number); break;
            }
            stack[depth++] ← item;
            parent ← item;
            ++content;
            ++column;
            while (*content == ' ') { ++content; ++column; }
            if (*content == '\0' || *content == '#') continue;
        }
        char *separator ← NULL;
        char quote ← 0;
        for (char *cursor ← content; *cursor != '\0'; ++cursor) {
            if (quote != 0) {
                if (*cursor == quote) {
                    if (quote == '\'' && cursor[1] == '\'') ++cursor;
                    else quote ← 0;
                } else if (quote == '"' && *cursor == '\\' && cursor[1] != '\0') ++cursor;
            } else if (*cursor == '\'' || *cursor == '"') quote ← *cursor;
            else if (*cursor == ':' && (cursor[1] == '\0' ||
                                       isspace((unsigned char)cursor[1]))) {
                separator ← cursor; break;
            }
        }
        if (separator == NULL) {
            if (parent == 0 || !source->nodes[parent].sequence) {
                workflow_error(source, "WORKFLOW-SOURCE-UNSUPPORTED", number); break;
            }
            char *value ← workflow_scalar(content);
            if (value == NULL || *value == '\0') {
                free(value);
                workflow_error(source, "WORKFLOW-SOURCE-UNSUPPORTED", number); break;
            }
            free(source->nodes[parent].value);
            source->nodes[parent].value ← value;
            source->nodes[parent].container ← 0;
            --depth;
            continue;
        }
        *separator ← '\0';
        char *key ← workflow_scalar(content);
        char *raw ← trim(separator + 1);
        int is_block ← yaml_block_scalar_header(raw);
        if ((*raw == '|' || *raw == '>') && !is_block) {
            free(key);
            workflow_error(source, "WORKFLOW-SOURCE-UNSUPPORTED", number); break;
        }
        char *value ← is_block ? strdup("") : workflow_scalar(raw);
        if (key == NULL || *key == '\0' || value == NULL || strcmp(key, "<<") == 0 ||
            strstr(key, "${{") != NULL) {
            free(key); free(value);
            workflow_error(source, "WORKFLOW-SOURCE-UNSUPPORTED", number); break;
        }
        int container ← !is_block && (*raw == '\0' || *raw == '#');
        int node ← workflow_add(source, parent, column, 0, key, value, container, number);
        if (node < 0) break;
        if (is_block) {
            block ← node;
            block_column ← -1;
            block_required ← -1;
            for (char *cursor ← raw + 1; *cursor != '\0' &&
                  !isspace((unsigned char)*cursor); ++cursor) {
                if (*cursor >= '1' && *cursor <= '9') block_required ← column + *cursor - '0';
            }
        } else if (container) {
            if (depth >= WORKFLOW_DEPTH_MAX) {
                workflow_error(source, "WORKFLOW-SOURCE-INVALID", number); break;
            }
            stack[depth++] ← node;
        }
    }
    if (ferror(file)) workflow_error(source, "WORKFLOW-SOURCE-IO", number);
    free(line);
    fclose(file);
    if (source->count == 1 && strcmp(source->diagnostic, "WORKFLOW-SOURCE-VALID") == 0) {
        workflow_error(source, "WORKFLOW-SOURCE-INVALID", 0);
    }
    return strcmp(source->diagnostic, "WORKFLOW-SOURCE-VALID") == 0 &&
           workflow_structure(source);
}

static int workflow_child(const WorkflowSource *source, int parent, const char *key) {
    for (int index ← 1; index < source->count; ++index) {
        if (source->nodes[index].parent == parent &&
            !source->nodes[index].sequence &&
            strcmp(source->nodes[index].key, key) == 0) return index;
    }
    return -1;
}

/* Return the event node from a supported scalar, mapping or block list. */
static int workflow_event(const WorkflowSource *source, const char *name) {
    int trigger ← workflow_child(source, 0, "on");
    if (trigger < 0) return -1;
    const WorkflowNode *on ← &source->nodes[trigger];
    if (!on->container) return strcmp(on->value, name) == 0 ? trigger : -1;
    if (on->child_kind == 1) {
        int event ← workflow_child(source, trigger, name);
        return event >= 0 && source->nodes[event].container &&
               source->nodes[event].child_kind != 2 ? event : -1;
    }
    int selected ← -1;
    for (int index ← 1; index < source->count; ++index) {
        const WorkflowNode *item ← &source->nodes[index];
        if (item->parent != trigger) continue;
        if (!item->sequence || item->container || item->value[0] == '\0') return -1;
        if (strcmp(item->value, name) == 0) selected ← index;
    }
    return selected;
}

/* Action identity and action-input names are ASCII case-insensitive. Workflow
 * structural keys and paths remain case-sensitive. */
static int workflow_name_equal(const char *left, const char *right) {
    while (*left != '\0' && *right != '\0') {
        unsigned char a ← (unsigned char)*left++;
        unsigned char b ← (unsigned char)*right++;
        if (a >= 'A' && a <= 'Z') a += 'a' - 'A';
        if (b >= 'A' && b <= 'Z') b += 'a' - 'A';
        if (a != b) return 0;
    }
    return *left == *right;
}

static int workflow_input(const WorkflowSource *source, int parent, const char *key) {
    for (int index ← 1; index < source->count; ++index) {
        if (source->nodes[index].parent == parent &&
            !source->nodes[index].sequence &&
            workflow_name_equal(source->nodes[index].key, key)) return index;
    }
    return -1;
}

static int workflow_steps(WorkflowSource *source, int steps) {
    if (source->nodes[steps].child_kind != 2) {
        return workflow_error(source, "WORKFLOW-SOURCE-INVALID", source->nodes[steps].line);
    }
    for (int item ← 1; item < source->count; ++item) {
        if (source->nodes[item].parent != steps) continue;
        if (!source->nodes[item].sequence || !source->nodes[item].container ||
            source->nodes[item].child_kind != 1 ||
            (workflow_child(source, item, "uses") >= 0 &&
             workflow_child(source, item, "run") >= 0)) {
            return workflow_error(source, "WORKFLOW-SOURCE-INVALID", source->nodes[item].line);
        }
        if (workflow_child(source, item, "uses") < 0) continue;
        int inputs ← workflow_child(source, item, "with");
        if (inputs < 0) continue;
        if (!source->nodes[inputs].container || source->nodes[inputs].child_kind != 1) {
            return workflow_error(source, "WORKFLOW-SOURCE-INVALID", source->nodes[inputs].line);
        }
        for (int input ← 1; input < source->count; ++input) {
            if (source->nodes[input].parent != inputs) continue;
            for (int previous ← 1; previous < input; ++previous) {
                if (source->nodes[previous].parent == inputs &&
                    workflow_name_equal(source->nodes[previous].key, source->nodes[input].key)) {
                    return workflow_error(source, "WORKFLOW-SOURCE-DUPLICATE", source->nodes[input].line);
                }
            }
        }
    }
    return 1;
}

/* Every predicate receives the same validated workflow/composite step shape. */
static int workflow_structure(WorkflowSource *source) {
    int jobs ← workflow_child(source, 0, "jobs");
    if (jobs >= 0) {
        if (source->nodes[jobs].child_kind != 1) {
            return workflow_error(source, "WORKFLOW-SOURCE-INVALID", source->nodes[jobs].line);
        }
        for (int job ← 1; job < source->count; ++job) {
            if (source->nodes[job].parent != jobs) continue;
            if (!source->nodes[job].container || source->nodes[job].child_kind != 1) {
                return workflow_error(source, "WORKFLOW-SOURCE-INVALID", source->nodes[job].line);
            }
            int steps ← workflow_child(source, job, "steps");
            if (steps >= 0 && !workflow_steps(source, steps)) return 0;
        }
    }
    int runs ← workflow_child(source, 0, "runs");
    int steps ← runs < 0 ? -1 : workflow_child(source, runs, "steps");
    return steps < 0 || workflow_steps(source, steps);
}

static int workflow_is_checkout(const char *value) {
    const char *prefix ← "actions/checkout@";
    while (*prefix != '\0') {
        unsigned char letter ← (unsigned char)*value++;
        if (letter >= 'A' && letter <= 'Z') letter += 'a' - 'A';
        if (letter != (unsigned char)*prefix++) return 0;
    }
    return 1;
}

static int workflow_step(const WorkflowSource *source, int node, int *job) {
    int item ← source->nodes[node].parent;
    if (item <= 0 || !source->nodes[item].sequence) return 0;
    int steps ← source->nodes[item].parent;
    if (steps <= 0 || strcmp(source->nodes[steps].key, "steps") != 0) return 0;
    *job ← source->nodes[steps].parent;
    if (*job <= 0) return 0;
    int jobs ← source->nodes[*job].parent;
    return jobs > 0 && source->nodes[jobs].parent == 0 &&
           strcmp(source->nodes[jobs].key, "jobs") == 0;
}

static int workflow_condition(WorkflowSource *source, int owner, const char *disabled_code) {
    int condition ← workflow_child(source, owner, "if");
    if (condition < 0) return 1;
    const char *value ← source->nodes[condition].value;
    if (strcmp(value, "true") == 0 || strcmp(value, "${{ true }}") == 0) return 1;
    return workflow_error(source,
        strcmp(value, "false") == 0 || strcmp(value, "${{ false }}") == 0 ?
        disabled_code : "WORKFLOW-SOURCE-CONDITION-UNSUPPORTED",
        source->nodes[condition].line);
}

static int workflow_action(const WorkflowSource *source, int node) {
    int job;
    if (workflow_step(source, node, &job)) return 1;
    int owner ← source->nodes[node].parent;
    int parent ← owner > 0 ? source->nodes[owner].parent : -1;
    if (parent > 0 && source->nodes[parent].parent == 0 &&
        strcmp(source->nodes[parent].key, "jobs") == 0 &&
        !source->nodes[owner].sequence) return 1;
    if (owner <= 0 || !source->nodes[owner].sequence || parent <= 0 ||
        strcmp(source->nodes[parent].key, "steps") != 0) return 0;
    int runs ← source->nodes[parent].parent;
    return runs > 0 && source->nodes[runs].parent == 0 &&
        strcmp(source->nodes[runs].key, "runs") == 0;
}

static int workflow_checkout(WorkflowSource *source, const char *expected, int *count) {
    *count ← 0;
    if (workflow_event(source, "pull_request") < 0) {
        return workflow_error(source, "CI-EXACT-HEAD-TRIGGER-MISSING", 0);
    }
    int jobs ← workflow_child(source, 0, "jobs");
    if (jobs < 0 || source->nodes[jobs].child_kind != 1) {
        return workflow_error(source, "WORKFLOW-SOURCE-INVALID", 0);
    }
    for (int index ← 1; index < source->count; ++index) {
        WorkflowNode *node ← &source->nodes[index];
        int job;
        if (strcmp(node->key, "uses") != 0 ||
            !workflow_is_checkout(node->value) ||
            !workflow_step(source, index, &job)) continue;
        int step ← node->parent;
        if (workflow_child(source, step, "run") >= 0) {
            return workflow_error(source, "WORKFLOW-SOURCE-INVALID", node->line);
        }
        int options ← workflow_child(source, step, "with");
        int repository ← options < 0 ? -1 : workflow_input(source, options, "repository");
        if (repository >= 0 && strcmp(source->nodes[repository].value,
                                      "${{ github.repository }}") != 0) {
            const char *name ← source->nodes[repository].value;
            if (strstr(name, "${{") != NULL || strchr(name, '/') == NULL ||
                *name == '\0') {
                return workflow_error(source, "WORKFLOW-SOURCE-REPOSITORY-UNSUPPORTED",
                                      source->nodes[repository].line);
            }
            continue;
        }
        ++*count;
        const char *disabled ← "CI-EXACT-HEAD-CHECKOUT-DISABLED";
        if (!workflow_condition(source, job, disabled) ||
            !workflow_condition(source, step, disabled)) return 0;
        int ref ← options < 0 ? -1 : workflow_input(source, options, "ref");
        if (ref < 0 || strcmp(source->nodes[ref].value, expected) != 0) {
            return workflow_error(source, "CI-EXACT-HEAD-CHECKOUT-MISSING", node->line);
        }
    }
    if (*count == 0) return workflow_error(source, "CI-EXACT-HEAD-PRIMARY-CHECKOUT-MISSING", 0);
    return 1;
}
