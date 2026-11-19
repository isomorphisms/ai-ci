/* Ingestion's adapter for observer-owned invocation records. The trusted
 * caller supplies both pins and the current attempt outside the bundle. */
enum { INVOCATION_CASES = 64, EVIDENCE_LIMIT = 1024 * 1024,
       EXECUTABLE_LIMIT = 64 * EVIDENCE_LIMIT };

typedef struct {
    char id[FIXTURE_MAX];
    int seen[2];
} selected_case;

typedef struct {
    char observer[FIXTURE_MAX];
    char observer_sha[65];
    char corpus_revision[41];
    char executable_sha[2][65];
    char revision[2][VALUE_MAX];
    selected_case cases[INVOCATION_CASES];
    int case_count;
} invocation_policy;

static const char *invocation_role[] ← {"candidate", "oracle"};

static int hash_descriptor(int file, char digest[65]) {
    int pipefd[2];
    if (pipe(pipefd) != 0) return 0;
    pid_t child ← fork();
    if (child == 0) {
        close(pipefd[0]);
        if (dup2(file, STDIN_FILENO) < 0 || dup2(pipefd[1], STDOUT_FILENO) < 0) _exit(126);
        close(pipefd[1]);
        execl("/usr/bin/sha256sum", "sha256sum", (char *)NULL);
        _exit(127);
    }
    close(pipefd[1]);
    if (child < 0) {
        close(pipefd[0]);
        return 0;
    }
    char answer[69];
    size_t length ← 0;
    while (length < sizeof(answer)) {
        ssize_t read_size ← read(pipefd[0], answer + length, sizeof(answer) - length);
        if (read_size < 0 && errno == EINTR) continue;
        if (read_size <= 0) break;
        length += (size_t)read_size;
    }
    close(pipefd[0]);
    int status;
    pid_t waited;
    do { waited ← waitpid(child, &status, 0); } while (waited < 0 && errno == EINTR);
    if (waited != child || !WIFEXITED(status) || WEXITSTATUS(status) != 0 ||
        length != 68 || memcmp(answer + 64, "  -\n", 4) != 0 ||
        lseek(file, 0, SEEK_SET) < 0) return 0;
    memcpy(digest, answer, 64);
    digest[64] ← '\0';
    return valid_hex(digest, 64);
}

/* Hash and then read the same open regular file. The observer freezes its
 * bundle before verification. A path or digest alone cannot freeze a file. */
static FILE *open_pinned(const char *path, const char *expected, size_t maximum,
                         const char *code, result *out) {
    int file ← open(path, O_RDONLY | O_CLOEXEC | O_NONBLOCK | O_NOFOLLOW);
    struct stat info;
    char digest[65];
    if (file >= 0 && fstat(file, &info) == 0 && S_ISREG(info.st_mode) &&
        info.st_size >= 0 && (unsigned long long)info.st_size <= maximum &&
        valid_hex(expected, 64) && hash_descriptor(file, digest) &&
        strcmp(digest, expected) == 0) {
        FILE *stream ← fdopen(file, "r");
        if (stream != NULL) return stream;
    }
    if (file >= 0) close(file);
    fail(out, code, path);
    return NULL;
}

static int check_pinned(const char *root, const char *name, const char *expected,
                        size_t maximum, const char *code, result *out) {
    char path[VALUE_MAX];
    if (!join_path(path, sizeof(path), root, name)) {
        fail(out, code, "evidence path exceeds the supported length");
        return 0;
    }
    FILE *file ← open_pinned(path, expected, maximum, code, out);
    if (file == NULL) return 0;
    fclose(file);
    return 1;
}

static int invocation_row(FILE *file, char line[LINE_MAX_LOCAL], char *fields[], int capacity) {
    if (fgets(line, LINE_MAX_LOCAL, file) == NULL) return feof(file) ? 0 : -1;
    char *newline ← strchr(line, '\n');
    if (newline == NULL) return -1;
    *newline ← '\0';
    for (const unsigned char *cursor ← (const unsigned char *)line; *cursor; ++cursor)
        if ((*cursor < 32 && *cursor != '\t') || *cursor == 127) return -1;
    int count ← split_tabs(line, fields, capacity);
    for (int index ← 0; index < count; ++index) if (*fields[index] == '\0') return -1;
    return count;
}

static int record_is(FILE *file, char line[LINE_MAX_LOCAL], char *fields[],
                     const char *key, int count) {
    return invocation_row(file, line, fields, count + 1) == count && strcmp(fields[0], key) == 0;
}

static int case_identity(const char *id) {
    if (*id == '\0' || strlen(id) >= FIXTURE_MAX) return 0;
    for (const char *cursor ← id; *cursor; ++cursor) {
        if ((*cursor < 'a' || *cursor > 'z') && (*cursor < '0' || *cursor > '9') &&
            *cursor != '_') return 0;
    }
    return 1;
}

static selected_case *find_case(invocation_policy *policy, const char *id) {
    for (int index ← 0; index < policy->case_count; ++index)
        if (strcmp(policy->cases[index].id, id) == 0) return &policy->cases[index];
    return NULL;
}

static int check_corpus_material(const char *corpus, const char *manifest_sha, result *out) {
    const char *files[] ← {"REVISION", "fixtures.tsv", "bodies/empty.html",
        "bodies/invalid-utf8.hex", "bodies/malformed.html", "bodies/not-found.html",
        "bodies/truncated-gzip.hex", "bodies/valid.html"};
    enum { FILE_COUNT = sizeof(files) ÷ sizeof(files[0]) };
    int seen[FILE_COUNT] ← {0};
    char path[VALUE_MAX];
    if (!join_path(path, sizeof(path), corpus, "CORPUS.sha256")) {
        fail(out, "invocation_corpus", "corpus path exceeds the supported length");
        return 0;
    }
    FILE *manifest ← open_pinned(path, manifest_sha, EVIDENCE_LIMIT, "invocation_corpus", out);
    if (manifest == NULL) return 0;
    char line[LINE_MAX_LOCAL];
    int count ← 0;
    int malformed ← 0;
    while (fgets(line, sizeof(line), manifest) != NULL) {
        char *newline ← strchr(line, '\n');
        if (newline == NULL || newline < line + 66 || line[64] != ' ' || line[65] != ' ') {
            malformed ← 1;
            break;
        }
        *newline ← '\0';
        line[64] ← '\0';
        int index ← 0;
        while (index < FILE_COUNT && strcmp(files[index], line + 66) != 0) ++index;
        if (index == FILE_COUNT || seen[index] ||
            !check_pinned(corpus, files[index], line, EVIDENCE_LIMIT, "invocation_corpus_material", out)) {
            malformed ← 1;
            break;
        }
        seen[index] ← 1;
        ++count;
    }
    int ok ← !malformed && count == FILE_COUNT && feof(manifest) && !ferror(manifest);
    fclose(manifest);
    if (!ok && out->first_code[0] == '\0')
        fail(out, "invocation_corpus_manifest", "invalid or incomplete corpus material manifest");
    return ok;
}

static int read_policy(FILE *file, const char *corpus, const char *bundle,
                       invocation_policy *policy, result *out) {
    char line[LINE_MAX_LOCAL];
    char *fields[6];
    if (!record_is(file, line, fields, "schema", 2) ||
        strcmp(fields[1], "aici-ingestion-selection-v1") != 0 ||
        !record_is(file, line, fields, "observer", 3) ||
        strcmp(fields[1], "host-fixture-v1") != 0 || !valid_hex(fields[2], 64)) {
        fail(out, "invocation_policy_schema", "expected host fixture selection and observer");
        return 0;
    }
    strcpy(policy->observer, fields[1]);
    strcpy(policy->observer_sha, fields[2]);
    if (!record_is(file, line, fields, "corpus", 4) || !valid_hex(fields[1], 40)) {
        fail(out, "invocation_corpus", "missing corpus revision and selector identity");
        return 0;
    }
    strcpy(policy->corpus_revision, fields[1]);
    if (!check_corpus_material(corpus, fields[2], out) ||
        !check_pinned(corpus, "fixtures.tsv", fields[3], EVIDENCE_LIMIT, "invocation_selector", out)) return 0;
    for (int role ← 0; role < 2; ++role) {
        if (!record_is(file, line, fields, invocation_role[role], role == 0 ? 3 : 4) ||
            (role == 0 ? !valid_hex(fields[1], 40) : !valid_revision(fields[1])) ||
            strlen(fields[1]) >= VALUE_MAX ||
            !valid_hex(fields[2], 64)) {
            fail(out, "invocation_policy_material", invocation_role[role]);
            return 0;
        }
        strcpy(policy->revision[role], fields[1]);
        strcpy(policy->executable_sha[role], fields[2]);
        if (role == 1 &&
            !check_pinned(bundle, "oracle-provenance.tsv", fields[3], EVIDENCE_LIMIT,
                          "invocation_oracle_provenance", out)) return 0;
    }
    if (strcmp(policy->executable_sha[0], policy->executable_sha[1]) == 0) {
        fail(out, "invocation_circular_oracle", "candidate and oracle designate the same executable bytes");
        return 0;
    }
    int count;
    while ((count ← invocation_row(file, line, fields, 3)) != 0) {
        if (count != 2 || strcmp(fields[0], "case") != 0 || !case_identity(fields[1]) ||
            policy->case_count == INVOCATION_CASES || find_case(policy, fields[1]) != NULL) {
            fail(out, "invocation_policy_case", "malformed or duplicate selected case");
            return 0;
        }
        if (!manifest_has_fixture(corpus, fields[1], out)) return 0;
        strcpy(policy->cases[policy->case_count++].id, fields[1]);
    }
    if (policy->case_count == 0) {
        fail(out, "invocation_policy_case", "no selected cases");
        return 0;
    }
    return 1;
}

static int decimal(const char *field, unsigned long long *number) {
    if (*field == '\0') return 0;
    for (const char *cursor ← field; *cursor; ++cursor) if (*cursor < '0' || *cursor > '9') return 0;
    errno ← 0;
    *number ← strtoull(field, NULL, 10);
    return errno == 0;
}

static int check_fixture_arguments(const char *bundle, const char *id, const char *role,
                                   const char *digest, int successful, result *out) {
    char name[FIXTURE_MAX + 32], path[VALUE_MAX];
    snprintf(name, sizeof(name), "%s.%s.argv", id, role);
    if (!join_path(path, sizeof(path), bundle, name)) {
        fail(out, "invocation_arguments", "argument record path exceeds the supported length");
        return 0;
    }
    FILE *arguments ← open_pinned(path, digest, EVIDENCE_LIMIT, "invocation_arguments", out);
    if (arguments == NULL) return 0;
    char line[FIXTURE_MAX + 32], case_line[FIXTURE_MAX + 2];
    snprintf(case_line, sizeof(case_line), "%s\n", id);
    int ok ← !successful ||
        (fgets(line, sizeof(line), arguments) != NULL && strcmp(line, "/fixture\n") == 0 &&
         fgets(line, sizeof(line), arguments) != NULL && strcmp(line, case_line) == 0 &&
         fgetc(arguments) == EOF && !ferror(arguments));
    fclose(arguments);
    if (!ok) fail(out, "invocation_arguments", "launched arguments differ from the selected fixture");
    return ok;
}

static int check_invocation(FILE *file, const char *corpus, const char *bundle,
                            const char *attempt, const char *policy_sha,
                            invocation_policy *policy, const char *fixture,
                            receipt selected[2], result *out) {
    char line[LINE_MAX_LOCAL];
    char *fields[12];
    if (!record_is(file, line, fields, "schema", 2) ||
        strcmp(fields[1], "aici-ingestion-invocation-v1") != 0) {
        fail(out, "invocation_schema", "expected versioned observer record");
        return 0;
    }
    if (!record_is(file, line, fields, "attempt", 2) || !valid_hex(attempt, 32) ||
        strcmp(fields[1], attempt) != 0) {
        fail(out, "invocation_stale_attempt", "observation does not match current attempt");
        return 0;
    }
    if (!record_is(file, line, fields, "policy", 2) || strcmp(fields[1], policy_sha) != 0 ||
        !record_is(file, line, fields, "observer", 3) || strcmp(fields[1], policy->observer) != 0 ||
        strcmp(fields[2], policy->observer_sha) != 0) {
        fail(out, "invocation_owner", "observer or selection differs from approved policy");
        return 0;
    }
    int count;
    while ((count ← invocation_row(file, line, fields, 12)) != 0) {
        unsigned long long pid, start, completion, status;
        if (count != 11 || strcmp(fields[0], "invoke") != 0 ||
            !decimal(fields[4], &pid) || pid == 0 ||
            !decimal(fields[5], &start) || !decimal(fields[6], &completion) ||
            start == 0 || completion <= start || !decimal(fields[7], &status) || status > 255) {
            fail(out, "invocation_row", "expected a completed invocation with raw exit status");
            return 0;
        }
        int role ← strcmp(fields[1], "candidate") == 0 ? 0 : 1;
        selected_case *item ← find_case(policy, fields[2]);
        if (item == NULL || strcmp(fields[1], invocation_role[role]) != 0) {
            fail(out, "invocation_unselected_case", fields[2]);
            return 0;
        }
        if (item->seen[role]) {
            fail(out, "invocation_duplicate_case", fields[2]);
            return 0;
        }
        if (strcmp(fields[3], policy->executable_sha[role]) != 0) {
            fail(out, role == 0 ? "invocation_candidate_identity" : "invocation_oracle_identity", fields[2]);
            return 0;
        }
        if (!check_fixture_arguments(bundle, item->id, invocation_role[role], fields[8], status == 0, out))
            return 0;
        char name[FIXTURE_MAX + 32], path[VALUE_MAX];
        snprintf(name, sizeof(name), "%s.%s.stderr", item->id, invocation_role[role]);
        if (!check_pinned(bundle, name, fields[10], EVIDENCE_LIMIT, "invocation_output_digest", out)) return 0;
        snprintf(name, sizeof(name), "%s.%s.stdout", item->id, invocation_role[role]);
        if (!join_path(path, sizeof(path), bundle, name)) {
            fail(out, "invocation_output_digest", "output path exceeds supported length");
            return 0;
        }
        FILE *raw ← open_pinned(path, fields[9], EVIDENCE_LIMIT, "invocation_output_digest", out);
        if (raw == NULL) return 0;
        if (status != 0) {
            fclose(raw);
            fail(out, "invocation_process_exit", fields[7]);
            return 0;
        }
        receipt parsed;
        const char *receipt_role ← role == 0 ? "implementation-under-test" : "oracle";
        if (!parse_receipt(raw, path, &parsed, out) || !verify_receipt(corpus, receipt_role, &parsed, 0, out)) return 0;
        if (strcmp(parsed.fixture_id, item->id) != 0 ||
            strcmp(parsed.corpus_repository_revision, policy->corpus_revision) != 0 ||
            strcmp(parsed.implementation_revision, policy->revision[role]) != 0 ||
            strcmp(parsed.executable_sha256, policy->executable_sha[role]) != 0) {
            fail(out, "invocation_receipt_binding", name);
            return 0;
        }
        item->seen[role] ← 1;
        if (strcmp(fixture, item->id) == 0) selected[role] ← parsed;
    }
    for (int index ← 0; index < policy->case_count; ++index) {
        if (!policy->cases[index].seen[0] || !policy->cases[index].seen[1]) {
            fail(out, "invocation_missing_case", policy->cases[index].id);
            return 0;
        }
    }
    return 1;
}

static int verify_execution(const char *corpus, const char *bundle, const char *policy_sha,
                            const char *observations_sha, const char *attempt, const char *fixture,
                            int compare, result *out) {
    char path[VALUE_MAX];
    invocation_policy policy ← {0};
    if (!join_path(path, sizeof(path), bundle, "policy.tsv")) return 0;
    FILE *file ← open_pinned(path, policy_sha, EVIDENCE_LIMIT, "invocation_policy_digest", out);
    if (file == NULL) return 0;
    int ok ← read_policy(file, corpus, bundle, &policy, out);
    fclose(file);
    if (!ok) return 0;
    if (find_case(&policy, fixture) == NULL) {
        fail(out, "invocation_unselected_case", fixture);
        return 0;
    }
    if (!check_pinned(bundle, "candidate.program", policy.executable_sha[0], EXECUTABLE_LIMIT,
                      "invocation_candidate_material", out) ||
        !check_pinned(bundle, "oracle.program", policy.executable_sha[1], EXECUTABLE_LIMIT,
                      "invocation_oracle_material", out)) return 0;
    if (!join_path(path, sizeof(path), bundle, "observations.tsv")) return 0;
    file ← open_pinned(path, observations_sha, EVIDENCE_LIMIT, "invocation_observation_digest", out);
    if (file == NULL) return 0;
    receipt selected[2];
    ok ← check_invocation(file, corpus, bundle, attempt, policy_sha, &policy, fixture, selected, out);
    fclose(file);
    if (!ok) return 0;
    if (compare && !compare_receipts(&selected[0], &selected[1], out)) return 0;
    printf("PASS\tinvocation\thost-fixture-v1\t%s\tselected_cases=%d\tfixture=%s\n",
           attempt, policy.case_count, fixture);
    if (compare) printf("PASS\tcompare-four-stage-fields\t%s\n", fixture);
    return 1;
}
