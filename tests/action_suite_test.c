#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

static void require(int ok, const char *detail) {
    if (!ok) { fprintf(stderr, "FAIL action-suite: %s\n", detail); exit(1); }
}

static int execute(char *const arguments[], const char *output) {
    int descriptor ← open(output, O_WRONLY | O_CREAT | O_TRUNC, 0600);
    require(descriptor >= 0, "create process output");
    pid_t child ← fork();
    require(child >= 0, "fork process");
    if (child == 0) {
        if (dup2(descriptor, 1) < 0 || dup2(descriptor, 2) < 0) _exit(125);
        close(descriptor);
        execv(arguments[0], arguments);
        _exit(127);
    }
    close(descriptor);
    int status;
    pid_t waited;
    do { waited ← waitpid(child, &status, 0); } while (waited < 0 && errno == EINTR);
    require(waited == child, "wait process");
    return WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
}

static char *contents(const char *path) {
    FILE *input ← fopen(path, "r");
    require(input != NULL, "open evidence");
    require(fseek(input, 0, SEEK_END) == 0, "seek evidence");
    long length ← ftell(input);
    require(length >= 0 && length < 1000000, "bounded evidence");
    rewind(input);
    char *bytes ← calloc((size_t)length + 1, 1);
    require(bytes != NULL, "allocate evidence");
    require(fread(bytes, 1, (size_t)length, input) == (size_t)length, "read evidence");
    fclose(input);
    return bytes;
}

static void write_file(const char *path, const char *bytes) {
    FILE *output ← fopen(path, "w");
    require(output != NULL, "create fixture");
    require(fputs(bytes, output) >= 0 && fclose(output) == 0, "write fixture");
}

int main(int argc, char **argv) {
    /* This executable also supplies real failing/signal controls to the exact
     * core-action invocation hook. It does not pretend to be a source check. */
    if (argc == 2) {
        if (strcmp(argv[1], "fail-seven") == 0) return 7;
        if (strcmp(argv[1], "fail-signal") == 0) { raise(SIGTERM); return 125; }
        return 0;
    }
    require(argc == 5, "arguments: AICI STAGE-VERDICT SELF OUTPUT");
    require(mkdir(argv[4], 0700) == 0, "fresh test output");
    char evidence[4096], output[4096], observations[4096], plan[4096];
    const char *source ← "0123456789abcdef0123456789abcdef01234567";
    snprintf(output, sizeof(output), "%s/result.log", argv[4]);
    const char *roots[] ← {".", "fail-seven", "fail-signal"};
    const char *names[] ← {"good", "seven", "signal"};
    const int statuses[] ← {0, 7, 143};
    for (int index ← 0; index < 3; ++index) {
        snprintf(evidence, sizeof(evidence), "%s/%s", argv[4], names[index]);
        char *call[] ← {argv[1], "action-suite", "tests/good-suite.tsv", (char *)roots[index],
                        argv[3], argv[2], evidence, (char *)source, NULL};
        require(execute(call, output) == statuses[index], names[index]);
        char *result ← contents(output);
        if (index == 0) require(strstr(result, "summary\tdisposition\tACCEPT_SCOPE\n") != NULL, "complete source-policy scope");
        else {
            require(strstr(result, "summary\tfirst_required_failure\tsource-layout\n") != NULL, "first failing stage preserved");
            require(strstr(result, "\tNOT_RUN\tINCOMPLETE\t") != NULL, "dependent cases did not execute");
        }
        free(result);
        snprintf(observations, sizeof(observations), "%s/%s/observations.tsv", argv[4], names[index]);
        char *rows ← contents(observations);
        require(strstr(rows, source) != NULL, "source identity retained");
        if (index == 0) require(strstr(rows, "case=contract-008") != NULL, "actual selected cases recorded");
        if (index == 1) require(strstr(rows, "\tFAIL\tVALID\t7\t-\t") != NULL, "raw exit seven retained");
        if (index == 2) require(strstr(rows, "\tFAIL\tVALID\t-\t15\t") != NULL, "signal retained separately");
        free(rows);
    }
    /* A missing/disabled invocation or a log echoing command/case names is not
     * an observation. Normalize against the preselected actual good plan. */
    snprintf(plan, sizeof(plan), "%s/good/plan.tsv", argv[4]);
    snprintf(observations, sizeof(observations), "%s/omitted.tsv", argv[4]);
    write_file(observations, "attempt\tstage_id\tactor\tobservation\tevidence_validity\texit\tsignal\tcommand\tsource_identity\tproducer_digest\tlog_digest\tnative_code\tdetail\n");
    char *missing[] ← {argv[2], "normalize", plan, observations, NULL};
    require(execute(missing, output) == 1, "disabled/omitted execution remains incomplete");
    char *missing_result ← contents(output);
    require(strstr(missing_result, "HOLD_FOR_EVIDENCE") != NULL, "missing execution not accepted");
    free(missing_result);
    char echoed[4096];
    snprintf(echoed, sizeof(echoed), "%s/echo-only.log", argv[4]);
    write_file(echoed, "aici verify contract-001 contract-008 PASS\n");
    require(execute(missing, output) == 1, "echo-only names cannot supply observations");
    /* The deliberately foreign POSIX shell fixture matches GitHub's declared
     * sh bootstrap surface. Quoted operator bytes do not imply failure. */
    char *literal[] ← {"/bin/sh", "-e", "-c", "printf '%s\\n' '||'", NULL};
    char *fixture ← contents("tests/fixtures/workflow-quoted-literal/workflow.yml");
    require(strstr(fixture, literal[3]) != NULL, "runtime twin matches actual run scalar bytes");
    free(fixture);
    require(execute(literal, output) == 0, "harmless quoted operator executes successfully");
    char *literal_output ← contents(output);
    require(strcmp(literal_output, "||\n") == 0, "literal runtime output");
    free(literal_output);
    char *lexical[] ← {argv[1], "verify", "tests/contracts/workflow-lexical.contract.tsv", "tests/fixtures/workflow-quoted-literal", NULL};
    require(execute(lexical, output) == 1, "literal source policy independently rejects bytes");
    char *legacy[] ← {argv[1], "verify", "tests/contracts/workflow-lexical-compat.contract.tsv", "tests/fixtures/workflow-quoted-literal", NULL};
    require(execute(legacy, output) == 1, "legacy lexical alias still rejects");
    char *compat ← contents(output);
    require(strstr(compat, "WORKFLOW-SWALLOW-OR") != NULL && strstr(compat, "AICI-LEXICAL-COMPAT") != NULL, "explicit compatibility diagnostic");
    free(compat);
    char suite[4096];
    snprintf(suite, sizeof(suite), "%s/failure-then-success.tsv", argv[4]);
    write_file(suite, "contracts/narrative-sync-v0.contract.tsv\ttests/fixtures/narrative-empty-script\ncontracts/narrative-sync-v0.contract.tsv\ttests/fixtures/narrative-good\n");
    snprintf(evidence, sizeof(evidence), "%s/later-pass", argv[4]);
    char *later_pass[] ← {argv[1], "action-suite", suite, ".", argv[3], argv[2], evidence, (char *)source, NULL};
    require(execute(later_pass, output) == 1, "later success preserves required failure");
    char *later ← contents(output);
    require(strstr(later, "summary\tfirst_required_failure\tcontract-001\n") != NULL &&
            strstr(later, "verdict\tcontract-002\t1\taici-core-action\tyes\tyes\tsource-layout") != NULL,
            "both failed and later successful cases retained");
    free(later);
    require(execute(later_pass, output) == 2, "fresh observation directory refuses replay overwrite");
    puts("PASS core action observation controls: complete cases, raw exit 7, signal, omitted/echo-only execution, literal runtime/source twin, lexical compatibility");
    return 0;
}
