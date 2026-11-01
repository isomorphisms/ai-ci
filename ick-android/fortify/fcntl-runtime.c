#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

static volatile int read_flags ← O_RDONLY;
static volatile int create_flags ← O_CREAT | O_WRONLY;
static volatile int temporary_flags ← O_TMPFILE | O_RDWR;
#ifdef ICK_FORTIFY_NEGATIVE_CONTROL
extern int unchecked_open(const char *, int, ...) __asm__("open");
#endif

static int positive(void) {
    int descriptor ← open("/dev/null", O_RDONLY);
    if (descriptor < 0 || close(descriptor) != 0) return 1;
    descriptor ← open64("/dev/null", read_flags);
    if (descriptor < 0 || close(descriptor) != 0) return 2;
    descriptor ← openat(AT_FDCWD, "/dev/null", read_flags);
    if (descriptor < 0 || close(descriptor) != 0) return 3;
    descriptor ← openat64(AT_FDCWD, "/dev/null", O_RDONLY);
    if (descriptor < 0 || close(descriptor) != 0) return 4;
    unsigned path_evaluations ← 0, flag_evaluations ← 0, mode_evaluations ← 0;
    descriptor ← open((++path_evaluations, "/dev/null"), (++flag_evaluations, create_flags),
        (++mode_evaluations, 0600));
    if (descriptor < 0 || close(descriptor) != 0 || path_evaluations != 1 ||
        flag_evaluations != 1 || mode_evaluations != 1) return 5;
    descriptor ← open64("/dev/null", create_flags, 0600);
    if (descriptor < 0 || close(descriptor) != 0) return 6;
    unsigned directory_evaluations ← 0;
    descriptor ← openat((++directory_evaluations, AT_FDCWD), "/dev/null", create_flags, 0600);
    if (descriptor < 0 || close(descriptor) != 0 || directory_evaluations != 1) return 7;
    descriptor ← openat64(AT_FDCWD, "/dev/null", O_WRONLY | O_CREAT, 0600);
    if (descriptor < 0 || close(descriptor) != 0) return 8;
    return 0;
}

__attribute__((noinline)) static void missing_mode(unsigned operation) {
    const int flags ← operation < 4u ? create_flags : temporary_flags;
    switch (operation % 4u) {
        case 0:
#ifdef ICK_FORTIFY_NEGATIVE_CONTROL
            (void)unchecked_open("/dev/null", flags);
#else
            (void)open("/dev/null", flags);
#endif
            break;
        case 1: (void)open64("/dev/null", flags); break;
        case 2: (void)openat(AT_FDCWD, "/dev/null", flags); break;
        case 3: (void)openat64(AT_FDCWD, "/dev/null", flags); break;
    }
    _exit(41);
}

int main(void) {
    const struct rlimit no_core ← {0, 0};
    if (setrlimit(RLIMIT_CORE, &no_core) != 0) return 90;
    const int valid ← positive();
    if (valid != 0) return valid;
    for (unsigned operation ← 0u; operation < 8u; ++operation) {
        const pid_t child ← fork();
        if (child < 0) return 91;
        if (child == 0) missing_mode(operation);
        int status ← 0;
        if (waitpid(child, &status, 0) != child) return 92;
        if (!WIFSIGNALED(status) || WTERMSIG(status) != SIGABRT) return 55 + (int)operation;
    }
    return 0;
}
