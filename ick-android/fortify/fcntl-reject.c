#include <fcntl.h>
int main(void) {
#if ICK_OPEN_CASE == 0
    return open("/dev/null", O_CREAT);
#elif ICK_OPEN_CASE == 1
    return open64("/dev/null", O_CREAT);
#elif ICK_OPEN_CASE == 2
    return openat(AT_FDCWD, "/dev/null", O_CREAT);
#elif ICK_OPEN_CASE == 3
    return openat64(AT_FDCWD, "/dev/null", O_CREAT);
#elif ICK_OPEN_CASE == 4
    return open("/dev/null", O_TMPFILE);
#elif ICK_OPEN_CASE == 5
    return open64("/dev/null", O_TMPFILE);
#elif ICK_OPEN_CASE == 6
    return openat(AT_FDCWD, "/dev/null", O_TMPFILE);
#elif ICK_OPEN_CASE == 7
    return openat64(AT_FDCWD, "/dev/null", O_TMPFILE);
#elif ICK_OPEN_CASE == 8
    return open("/dev/null", O_CREAT, 0600, 0600);
#elif ICK_OPEN_CASE == 9
    return open64("/dev/null", O_CREAT, 0600, 0600);
#elif ICK_OPEN_CASE == 10
    return openat(AT_FDCWD, "/dev/null", O_CREAT, 0600, 0600);
#elif ICK_OPEN_CASE == 11
    return openat64(AT_FDCWD, "/dev/null", O_CREAT, 0600, 0600);
#else
#error undeclared open rejection case
#endif
}
