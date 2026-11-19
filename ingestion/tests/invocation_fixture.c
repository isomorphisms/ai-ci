#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/* Host fixture transport. The inputs are independent receipt examples,
 * not an implementation of hostile-web ingestion. */
int main(int argc, char **argv) {
    if (argc != 2 && argc != 3) return 2;
    int visible ← open("/protected-marker", O_RDONLY);
    if (visible < 0) return 3;
    close(visible);
    int marker ← open("/protected-marker", O_WRONLY);
    if (marker >= 0) {
        close(marker);
        fputs("observer marker was writable\n", stderr);
        return 3;
    }
    if (errno != EROFS) return 3;
    /* The observer's status channel must disappear across exec. */
    for (int fd ← 3; fd < 256; ++fd) {
        if (fcntl(fd, F_GETFD) == -1) continue;
        fputs("unexpected inherited descriptor\n", stderr);
        return 4;
    }
    FILE *input ← fopen("/selected-receipt", "r");
    if (input == NULL) return 5;
    char expected[256], row[4096];
    int written ← snprintf(expected, sizeof(expected), "meta\tfixture_id\t%s\n", argv[1]);
    if (written <= 0 || (size_t)written >= sizeof(expected)) {
        fclose(input);
        return 2;
    }
    int selected ← 0;
    while (fgets(row, sizeof(row), input) != NULL) {
        if (strcmp(row, expected) == 0) selected ← 1;
        if (fputs(row, stdout) == EOF) break;
    }
    int ok ← selected && feof(input) && !ferror(input) && fflush(stdout) == 0;
    fclose(input);
#ifdef AICI_REFERENCE_FIXTURE
    fputs("host reference fixture receipt emitted\n", stderr);
#else
    fputs("host candidate fixture receipt emitted\n", stderr);
#endif
    if (!ok) return 6;
    return argc == 3 && strcmp(argv[2], "exit-seven") == 0 ? 7 : 0;
}
