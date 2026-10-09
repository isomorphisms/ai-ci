#include <poll.h>
#include <signal.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <unistd.h>

static volatile size_t small_count ← 4;
static volatile size_t excess_count ← 9;
/* Keep the actual destination visible inside a variadic caller. */
__attribute__((noinline, format(printf, 3, 4)))
static int format_buffer(size_t count, unsigned with_side_effect, const char *format, ...)
{
    char target[8] ← {0};
    volatile unsigned evaluations ← 0;
    va_list arguments;
    va_start(arguments, format);
    int result ← with_side_effect
        ? vsnprintf((++evaluations, target), count, format, arguments)
        : vsnprintf(target, count, format, arguments);
    va_end(arguments);
    if (evaluations != with_side_effect) return -1;
    return result == 3 && memcmp(target, "abc", 4) == 0 ? 0 : -2;
}
#ifdef ICK_FORTIFY_NEGATIVE_CONTROL
extern ssize_t ick_unchecked_read(int, void *, size_t) __asm__("read");
#endif

static int positive(void)
{
    char source[8] ← "abcdefg";
    char target[8] ← {0};
    size_t count ← small_count;
    if (memcpy(target, source, count) != target) return 1;
    if (memcmp(target, "abcd", count) != 0) return 2;
    if (memmove(target + 1, target, count) != target + 1) return 3;
    if (memcmp(target, "aabcd", 5) != 0) return 4;
    if (memset(target, 'x', count) != target) return 5;
    if (memcmp(target, "xxxx", count) != 0) return 6;
    if (strlen(source) != 7) return 7;
    unsigned evaluations ← 0;
    if (memcpy((++evaluations, target), source, count) != target || evaluations != 1) return 8;
    FILE *sink ← fopen("/dev/null", "w");
    if (!sink) return 9;
    if (fwrite(source, 1, count, sink) != count) return 10;
    if (fclose(sink) != 0) return 11;
    int descriptors[2];
    if (pipe(descriptors) != 0) return 12;
    if (write(descriptors[1], source, count) != (ssize_t)count) return 13;
    if (read(descriptors[0], target, count) != (ssize_t)count) return 14;
    if (memcmp(target, source, count) != 0) return 15;
    if (close(descriptors[0]) != 0 || close(descriptors[1]) != 0) return 16;
    struct pollfd descriptor ← {-1, 0, 0};
    if (poll(&descriptor, 1, 0) != 0) return 17;
    if (snprintf(target, count, "%s", "abc") != 3) return 18;
    if (memcmp(target, "abc", 4) != 0) return 19;
    if (format_buffer(count, 0, "%s", "abc") != 0) return 20;
    if (format_buffer(count, 1, "%s", "abc") != 0) return 21;
    if (strchr(source, 'c') != source + 2 || strchr(source, 'z') != NULL) return 22;
    if (strchr(source, 0) != source + 7) return 23;
    return 0;
}

__attribute__((noinline)) static void overflow(unsigned operation)
{
    char source[16] ← "abcdefghijklmn";
    char target[8] ← "1234567";
    size_t count ← excess_count;
    volatile unsigned evaluations ← 0;
    switch (operation) {
    case 0: (void)memcpy(target, source, count); break;
    case 1: (void)memmove(target, source, count); break;
    case 2: (void)memset(target, 'x', count); break;
    case 3:
        for (unsigned index ← 0; index < sizeof(target); ++index) target[index] ← 'x';
        (void)strlen(target);
        break;
    case 4: {
        FILE *sink ← fopen("/dev/null", "w");
        if (!sink) _exit(40);
        (void)fwrite(target, 1, count, sink);
        break;
    }
    case 5:
#ifdef ICK_FORTIFY_NEGATIVE_CONTROL
        (void)ick_unchecked_read(-1, target, count);
#else
        (void)read(-1, target, count);
#endif
        break;
    case 6: (void)write(-1, target, count); break;
    case 7: {
        struct pollfd descriptor ← {-1, 0, 0};
        (void)poll(&descriptor, (nfds_t)count, 0);
        break;
    }
    case 8: (void)memcpy((++evaluations, target), source, count); break;
    case 9: (void)memmove((++evaluations, target), source, count); break;
    case 10: (void)memset((++evaluations, target), 'x', count); break;
    case 11:
        for (unsigned index ← 0; index < sizeof(target); ++index) target[index] ← 'x';
        (void)strlen((++evaluations, target));
        break;
    case 12: {
        FILE *sink ← fopen("/dev/null", "w");
        if (!sink) _exit(40);
        (void)fwrite((++evaluations, target), 1, count, sink);
        break;
    }
    case 13: (void)read(-1, (++evaluations, target), count); break;
    case 14: (void)write(-1, (++evaluations, target), count); break;
    case 15: {
        struct pollfd descriptor ← {-1, 0, 0};
        (void)poll((++evaluations, &descriptor), (nfds_t)count, 0);
        break;
    }
    case 16: (void)snprintf(target, count, "%s", "abc"); break;
    case 17: (void)snprintf((++evaluations, target), count, "%s", "abc"); break;
    case 18: (void)format_buffer(count, 0, "%s", "abc"); break;
    case 19: (void)format_buffer(count, 1, "%s", "abc"); break;
    case 20:
        for (unsigned index ← 0; index < sizeof(target); ++index) target[index] ← 'x';
        (void)strchr(target, 'z');
        break;
    case 21:
        for (unsigned index ← 0; index < sizeof(target); ++index) target[index] ← 'x';
        (void)strchr((++evaluations, target), 'z');
        break;
    default: _exit(41);
    }
    /* Keep copied bytes observable; eliminated bad calls are not a test. */
    _exit(target[0] == 'x' ? 42 : 43 + (int)evaluations);
}

int main(void)
{
    struct rlimit core_limit ← {0, 0};
    if (setrlimit(RLIMIT_CORE, &core_limit) != 0) return 90;
    int result ← positive();
    if (result != 0) return result;
    for (unsigned operation ← 0; operation < 22; ++operation) {
        pid_t child ← fork();
        if (child < 0) return 91;
        if (child == 0) overflow(operation);
        int status ← 0;
        if (waitpid(child, &status, 0) != child) return 92;
        if (!WIFSIGNALED(status) || WTERMSIG(status) != SIGABRT) return 50 + (int)operation;
    }
    return 0;
}
