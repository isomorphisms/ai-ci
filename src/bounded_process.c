#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

/* Native process boundary, not an acceptance oracle. Files are private and
 * exclusive. Never buffer an unbounded child stream or execute a shell string. */
static volatile sig_atomic_t interrupted;
static void stop(int signal_number) { interrupted = signal_number; }
static double now(void) {
    struct timespec t;
    if (clock_gettime(CLOCK_MONOTONIC, &t)) exit(125);
    return (double)t.tv_sec + (double)t.tv_nsec / 1e9;
}
static long number(const char *text, long maximum) {
    char *end;
    errno = 0;
    long n = strtol(text, &end, 10);
    if (errno || !*text || *end || n < 1 || n > maximum) exit(125);
    return n;
}
int main(int argc, char **argv) {
    if (argc < 8 || strcmp(argv[6], "--")) {
        fprintf(stderr, "usage: bounded-process SECONDS BYTES STDOUT STDERR STATUS -- ABSOLUTE_EXECUTABLE [ARG ...]\n");
        return 125;
    }
    long seconds = number(argv[1], 2700), limit = number(argv[2], 16777216);
    if (argv[7][0] != '/') { fprintf(stderr, "MISSING_INPUT:absolute executable\n"); return 125; }
    umask(077);
    int out = open(argv[3], O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW, 0600);
    int err = open(argv[4], O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW, 0600);
    int report = open(argv[5], O_WRONLY|O_CREAT|O_EXCL|O_NOFOLLOW, 0600);
    if (out < 0 || err < 0 || report < 0) { perror("exclusive capture output"); return 125; }
    signal(SIGINT, stop); signal(SIGTERM, stop); signal(SIGHUP, stop);
    pid_t child = fork();
    if (child < 0) { perror("fork"); return 125; }
    if (!child) {
        struct rlimit file_limit = {(rlim_t)limit + 1, (rlim_t)limit + 1};
        if (setrlimit(RLIMIT_FSIZE, &file_limit)) _exit(125);
        if (setpgid(0, 0) || dup2(out, 1) < 0 || dup2(err, 2) < 0) _exit(125);
        close(out); close(err); close(report);
        execv(argv[7], &argv[7]);
        int execution_errno = errno;
        perror("execute capture producer"); _exit(execution_errno == EACCES ? 126 : 127);
    }
    (void)setpgid(child, child);
    double deadline = now() + (double)seconds;
    const char *state = "EXIT";
    int status = 0;
    struct stat a = {0}, b = {0};
    for (;;) {
        /* Check bounds even if the child just exited. A fast output flood is
         * a limit failure too. The files also receive an RLIMIT in v2 below. */
        if (fstat(out, &a) || fstat(err, &b)) { state = "IO_FAILURE"; break; }
        if (a.st_size > limit || b.st_size > limit) { state = "OUTPUT_LIMIT"; break; }
        if (interrupted) { state = "INTERRUPTED"; break; }
        if (now() >= deadline) { state = "TIMEOUT"; break; }
        pid_t got = waitpid(child, &status, WNOHANG);
        if (got == child) break;
        if (got < 0 && errno != EINTR) { state = "WAIT_FAILURE"; break; }
        struct timespec tick = {0, 10000000};
        nanosleep(&tick, NULL);
    }
    if (strcmp(state, "EXIT")) {
        kill(-child, SIGKILL);
        while (waitpid(child, &status, 0) < 0 && errno == EINTR) {}
    } else {
        /* A child may leave grandchildren holding resources after returning. */
        kill(-child, SIGKILL);
    }
    int code = WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
    if (!strcmp(state, "TIMEOUT")) code = 124;
    else if (!strcmp(state, "OUTPUT_LIMIT")) code = 122;
    else if (!strcmp(state, "INTERRUPTED")) code = 128 + interrupted;
    else if (strcmp(state, "EXIT")) code = 125;
    dprintf(report, "schema\taici-bounded-process-v1\nstate\t%s\nexit_code\t%d\nsignal\t%d\nstdout_bytes\t%lld\nstderr_bytes\t%lld\n",
            state, code, WIFSIGNALED(status) ? WTERMSIG(status) : 0,
            (long long)a.st_size, (long long)b.st_size);
    close(out); close(err); close(report);
    return code;
}
