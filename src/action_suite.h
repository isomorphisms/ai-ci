/* The core action's observation hook. A04 alone computes stage dispositions.
 * This is a trusted local owner, not an independent execution attestation. */
typedef struct {
    char contract[AICI_PATH_MAX];
    char root[AICI_PATH_MAX];
} ActionCase;

static int action_field(const char *value) {
    if (*value == '\0') return 0;
    for (const unsigned char *p ← (const unsigned char *)value; *p; ++p)
        if (*p < 32 || *p == 127) return 0;
    return strlen(value) < AICI_PATH_MAX;
}

static int action_wait(pid_t child, int *signal_number) {
    int status;
    pid_t observed;
    do { observed ← waitpid(child, &status, 0); } while (observed < 0 && errno == EINTR);
    *signal_number ← 0;
    if (observed != child) return 125;
    if (WIFEXITED(status)) return WEXITSTATUS(status);
    if (WIFSIGNALED(status)) {
        *signal_number ← WTERMSIG(status);
        return 128 + *signal_number;
    }
    return 125;
}

/* Same declared sha256sum host boundary as the existing fdroid verifier. */
static int action_digest(const char *path, char digest[65]) {
    int descriptors[2];
    if (pipe(descriptors) != 0) return 0;
    pid_t child ← fork();
    if (child == 0) {
        close(descriptors[0]);
        if (dup2(descriptors[1], STDOUT_FILENO) < 0) _exit(125);
        close(descriptors[1]);
        execlp("sha256sum", "sha256sum", "--", path, (char *)NULL);
        _exit(127);
    }
    close(descriptors[1]);
    if (child < 0) { close(descriptors[0]); return 0; }
    char bytes[4096];
    size_t used ← 0;
    ssize_t count;
    while (used < sizeof(bytes) && (count ← read(descriptors[0], bytes + used, sizeof(bytes) - used)) != 0) {
        if (count < 0) { if (errno == EINTR) continue; break; }
        used += (size_t)count;
    }
    close(descriptors[0]);
    int signal_number;
    if (action_wait(child, &signal_number) != 0 || used < 65 || bytes[64] != ' ') return 0;
    for (int index ← 0; index < 64; ++index) if (!isxdigit((unsigned char)bytes[index])) return 0;
    memcpy(digest, bytes, 64);
    digest[64] ← '\0';
    return 1;
}

static int action_process(char *const arguments[], const char *log_path, int *signal_number) {
    int log ← open(log_path, O_WRONLY | O_CREAT | O_EXCL, 0600);
    if (log < 0) return 125;
    fflush(NULL);
    pid_t child ← fork();
    if (child == 0) {
        if (dup2(log, STDOUT_FILENO) < 0 || dup2(log, STDERR_FILENO) < 0) _exit(125);
        close(log);
        execv(arguments[0], arguments);
        perror("cannot execute required action command");
        _exit(127);
    }
    close(log);
    if (child < 0) return 125;
    return action_wait(child, signal_number);
}

static int action_suite(const char *self, const char *suite_path, const char *base_root,
                        const char *layout_checker, const char *stage_checker,
                        const char *output, const char *source) {
    ActionCase cases[63];
    int count ← 0;
    int malformed ← 0;
    const char *fields_to_check[] ← {self, suite_path, base_root, layout_checker, stage_checker, output, source};
    for (size_t index ← 0; index < sizeof(fields_to_check) / sizeof(fields_to_check[0]); ++index)
        if (!action_field(fields_to_check[index])) return 2;
    if (strlen(source) != 40) return 2;
    for (int index ← 0; index < 40; ++index) if (!isxdigit((unsigned char)source[index])) return 2;
    FILE *suite ← fopen(suite_path, "r");
    if (suite == NULL) return 2;
    char *line ← NULL;
    size_t capacity ← 0;
    ssize_t length;
    while ((length ← getline(&line, &capacity, suite)) >= 0) {
        char *content ← trim(line);
        if (*content == '\0' || *content == '#') continue;
        char *fields[3];
        if (length > AICI_LINE_MAX || count == 63 || split_tabs(content, fields, 3) != 2 ||
            !action_field(fields[0]) || !action_field(fields[1]) ||
            !join_path(cases[count].root, sizeof(cases[count].root), base_root, fields[1])) {
            malformed ← 1;
            break;
        }
        snprintf(cases[count].contract, sizeof(cases[count].contract), "%s", fields[0]);
        ++count;
    }
    if (ferror(suite)) malformed ← 1;
    free(line);
    fclose(suite);
    if (malformed || count == 0) return 2;
    if (mkdir(output, 0700) != 0) {
        fprintf(stderr, "cannot create fresh action evidence directory: %s\n", strerror(errno));
        return 2;
    }
    char plan_path[AICI_PATH_MAX], observations_path[AICI_PATH_MAX], log_path[AICI_PATH_MAX];
    if (!join_path(plan_path, sizeof(plan_path), output, "plan.tsv") ||
        !join_path(observations_path, sizeof(observations_path), output, "observations.tsv")) return 2;
    FILE *plan ← fopen(plan_path, "wx");
    FILE *observations ← fopen(observations_path, "wx");
    if (plan == NULL || observations == NULL) {
        if (plan != NULL) fclose(plan);
        if (observations != NULL) fclose(observations);
        return 2;
    }
    fputs("stage_id\tactor\trequired\tselected\tdepends_on\tclaim\n", plan);
    fputs("source-layout\taici-core-action\tyes\tyes\t-\tsource-layout-policy\n", plan);
    for (int index ← 0; index < count; ++index)
        fprintf(plan, "contract-%03d\taici-core-action\tyes\tyes\tsource-layout\tsource-policy:%s:%s\n",
                index + 1, cases[index].contract, cases[index].root);
    int plan_ok ← !ferror(plan);
    if (fclose(plan) != 0) plan_ok ← 0;
    fputs("attempt\tstage_id\tactor\tobservation\tevidence_validity\texit\tsignal\tcommand\tsource_identity\tproducer_digest\tlog_digest\tnative_code\tdetail\n", observations);
    if (!plan_ok) { fclose(observations); return 2; }
    int first_failure ← 0;
    for (int index ← 0; index <= count; ++index) {
        char id[32], filename[40], producer_digest[65], log_digest[65];
        if (index == 0) snprintf(id, sizeof(id), "source-layout");
        else snprintf(id, sizeof(id), "contract-%03d", index);
        snprintf(filename, sizeof(filename), "%s.log", id);
        if (!join_path(log_path, sizeof(log_path), output, filename)) { first_failure ← 2; break; }
        char *layout_arguments[] ← {(char *)layout_checker, (char *)base_root, NULL};
        char *contract_arguments[] ← {(char *)self, "verify", index ? cases[index - 1].contract : NULL,
                                     index ? cases[index - 1].root : NULL, NULL};
        char **arguments ← index == 0 ? layout_arguments : contract_arguments;
        if (!action_digest(arguments[0], producer_digest)) { first_failure ← 2; break; }
        int signal_number ← 0;
        int raw_exit ← action_process(arguments, log_path, &signal_number);
        if (!action_digest(log_path, log_digest)) { first_failure ← 2; break; }
        fprintf(observations, "1\t%s\taici-core-action\t%s\tVALID\t", id, raw_exit == 0 ? "PASS" : "FAIL");
        if (signal_number) fprintf(observations, "-\t%d\t", signal_number);
        else fprintf(observations, "%d\t-\t", raw_exit);
        for (int arg ← 0; arguments[arg] != NULL; ++arg) fprintf(observations, "%s%s", arg ? " " : "", arguments[arg]);
        fprintf(observations, "\t%s\t%s\t%s\tprocess_exit\tactual core-action invocation; case=%s\n",
                source, producer_digest, log_digest, id);
        if (raw_exit != 0 && first_failure == 0) first_failure ← raw_exit;
        /* Preserve the source-layout gate; A04 renders remaining selected cases NOT_RUN. */
        if (index == 0 && raw_exit != 0) break;
    }
    int observed_ok ← !ferror(observations);
    if (fclose(observations) != 0) observed_ok ← 0;
    if (!observed_ok) return 2;
    char *normalize[] ← {(char *)stage_checker, "normalize", plan_path, observations_path, NULL};
    pid_t child ← fork();
    if (child == 0) { execv(normalize[0], normalize); _exit(127); }
    if (child < 0) return 2;
    int signal_number;
    int verdict ← action_wait(child, &signal_number);
    if (first_failure != 0) return first_failure;
    return verdict;
}
