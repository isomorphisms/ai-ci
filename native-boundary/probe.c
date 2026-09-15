/* Native libc boundary observations, not Idric/DEX/JNI acceptance. */
#define _GNU_SOURCE 1
#define _LARGEFILE64_SOURCE 1
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <limits.h>
#include <pthread.h>
#include <poll.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#if defined(AICI_REQUIRE_BIONIC) && !defined(__BIONIC__)
#error "Android lane must use Bionic headers and ABI"
#endif
#ifdef AICI_EXPECT_POINTER_SIZE
_Static_assert(sizeof(void *) == AICI_EXPECT_POINTER_SIZE, "target pointer width");
#endif
_Static_assert(sizeof(off64_t) >= 8, "64-bit file offsets required");

#ifndef AICI_NATIVE_REVISION
#define AICI_NATIVE_REVISION "unbound-local-source"
#endif
#ifdef AICI_NATIVE_SELF_TEST
static int sabotage;
#else
/* Fault injection is absent from the shipped probe. */
#define sabotage 0
#endif
static size_t page_size;
static const char *library_path;
static const char *case_name;
#define REQUIRE(x) do { if (!(x)) { \
    fprintf(stderr, "SETUP\t%s\tline=%d\terrno=%d\t%s\n", \
            case_name, __LINE__, errno, #x); return 2; } } while (0)
#define EXPECT(x) do { if (!(x)) { \
    fprintf(stderr, "REJECT\t%s\tline=%d\terrno=%d\t%s\n", \
            case_name, __LINE__, errno, #x); return 1; } } while (0)

/* Each case runs in its own process. Even setup failure releases descriptors
 * and mappings. Unlink immediately so crashes leave no large sparse files. */
static int scratch_file(void) {
    char name[] = "aici-native-XXXXXX";
    int fd = mkstemp(name);
    if (fd >= 0 && unlink(name) != 0) { close(fd); return -1; }
    return fd;
}

static int anonymous_memory(void) {
    unsigned char *p = mmap(NULL, 2 * page_size, PROT_READ | PROT_WRITE,
                            MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    REQUIRE(p != MAP_FAILED);
    if (sabotage) p[page_size] = 1;
    for (size_t i = 0; i < 2 * page_size; ++i) EXPECT(p[i] == 0);
    p[page_size - 1] = 31; p[page_size] = 79;
    EXPECT(p[page_size - 1] == 31 && p[page_size] == 79);
    EXPECT(munmap(p, 2 * page_size) == 0);
    return 0;
}

static int mapping_errors(void) {
    int fd = scratch_file();
    REQUIRE(fd >= 0 && ftruncate(fd, (off_t)page_size) == 0);
    errno = 0;
    void *p = mmap(NULL, 0, PROT_READ, MAP_PRIVATE, fd, 0);
    int e = errno;
    if (sabotage) e = EBADF; /* Wrong libc error translation. */
    EXPECT(p == MAP_FAILED && e == EINVAL);
    errno = 0;
    p = mmap64(NULL, page_size, PROT_READ, MAP_PRIVATE, fd, 1);
    e = errno;
    EXPECT(p == MAP_FAILED && e == EINVAL);
    EXPECT(close(fd) == 0);
    return 0;
}

static int file_offset(void) {
    int fd = scratch_file();
    REQUIRE(fd >= 0 && ftruncate(fd, (off_t)(2 * page_size)) == 0);
    REQUIRE(pwrite(fd, "L", 1, 0) == 1);
    REQUIRE(pwrite(fd, "H", 1, (off_t)page_size) == 1);
    off_t offset = sabotage ? 0 : (off_t)page_size;
    const char *p = mmap(NULL, page_size, PROT_READ, MAP_PRIVATE, fd, offset);
    REQUIRE(p != MAP_FAILED);
    EXPECT(p[0] == 'H');
    EXPECT(munmap((void *)p, page_size) == 0);
    p = mmap64(NULL, page_size, PROT_READ, MAP_PRIVATE, fd, (off64_t)page_size);
    REQUIRE(p != MAP_FAILED);
    EXPECT(p[0] == 'H');
    EXPECT(munmap((void *)p, page_size) == 0 && close(fd) == 0);
    return 0;
}

static int large_offset(void) {
    /* Two distinguishable locations with equal low 32 bits. Sparse, not a
     * 4-GiB allocation. Compute alignment from the actual runtime page size. */
    off64_t high = (((off64_t)UINT32_MAX + 1 + (off64_t)page_size - 1)
                    / (off64_t)page_size + 1) * (off64_t)page_size;
    off64_t low = (off64_t)(uint32_t)high;
    int fd = scratch_file();
    REQUIRE(fd >= 0 && ftruncate64(fd, high + (off64_t)page_size) == 0);
    REQUIRE(pwrite64(fd, "L", 1, low) == 1);
    REQUIRE(pwrite64(fd, "H", 1, high) == 1);
    struct stat64 st;
    REQUIRE(fstat64(fd, &st) == 0);
    EXPECT(st.st_size == high + (off64_t)page_size);
    EXPECT(lseek64(fd, high, SEEK_SET) == high);
    char byte = 0;
    EXPECT(read(fd, &byte, 1) == 1 && byte == 'H');
    const char *p = mmap64(NULL, page_size, PROT_READ, MAP_PRIVATE, fd,
                          sabotage ? low : high);
    REQUIRE(p != MAP_FAILED);
    EXPECT(p[0] == 'H');
    EXPECT(munmap((void *)p, page_size) == 0);
    if (sizeof(off_t) >= 8) {
        p = mmap(NULL, page_size, PROT_READ, MAP_PRIVATE, fd, (off_t)high);
        REQUIRE(p != MAP_FAILED);
        EXPECT(p[0] == 'H');
        EXPECT(munmap((void *)p, page_size) == 0);
    }
    EXPECT(close(fd) == 0);
    return 0;
}

static int private_mapping(void) {
    int fd = scratch_file();
    REQUIRE(fd >= 0 && ftruncate(fd, (off_t)page_size) == 0);
    REQUIRE(pwrite(fd, "A", 1, 0) == 1);
    char *p = mmap(NULL, page_size, PROT_READ | PROT_WRITE,
                   sabotage ? MAP_SHARED : MAP_PRIVATE, fd, 0);
    REQUIRE(p != MAP_FAILED);
    p[0] = 'B';
    REQUIRE(msync(p, page_size, MS_SYNC) == 0);
    char byte = 0;
    REQUIRE(pread(fd, &byte, 1, 0) == 1);
    EXPECT(p[0] == 'B' && byte == 'A');
    EXPECT(munmap(p, page_size) == 0 && close(fd) == 0);
    return 0;
}

static int shared_mapping(void) {
    int fd = scratch_file();
    REQUIRE(fd >= 0 && ftruncate(fd, (off_t)page_size) == 0);
    REQUIRE(pwrite(fd, "A", 1, 0) == 1);
    char *p = mmap(NULL, page_size, PROT_READ | PROT_WRITE,
                   sabotage ? MAP_PRIVATE : MAP_SHARED, fd, 0);
    REQUIRE(p != MAP_FAILED);
    p[0] = 'B';
    REQUIRE(msync(p, page_size, MS_SYNC) == 0);
    char byte = 0;
    REQUIRE(pread(fd, &byte, 1, 0) == 1);
    EXPECT(byte == 'B');
    EXPECT(munmap(p, page_size) == 0 && close(fd) == 0);
    return 0;
}

static int protection(void) {
    volatile unsigned char *p = mmap(NULL, page_size, PROT_READ | PROT_WRITE,
                                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    REQUIRE((const void *)p != MAP_FAILED);
    *p = 17;
    REQUIRE(mprotect((void *)p, page_size,
                      sabotage ? (PROT_READ | PROT_WRITE) : PROT_READ) == 0);
    EXPECT(*p == 17);
    pid_t child = fork();
    REQUIRE(child >= 0);
    if (child == 0) { alarm(2); *p = 18; _exit(0); }
    int status;
    pid_t got;
    do { got = waitpid(child, &status, 0); } while (got < 0 && errno == EINTR);
    REQUIRE(got == child);
    EXPECT(WIFSIGNALED(status) &&
           (WTERMSIG(status) == SIGSEGV || WTERMSIG(status) == SIGBUS));
    REQUIRE(mprotect((void *)p, page_size, PROT_READ | PROT_WRITE) == 0);
    *p = 19;
    EXPECT(*p == 19 && munmap((void *)p, page_size) == 0);
    return 0;
}

static int advice(void) {
    unsigned char *p = mmap(NULL, page_size, PROT_READ | PROT_WRITE,
                            MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    REQUIRE(p != MAP_FAILED);
    memset(p, 23, page_size);
    EXPECT(madvise(p, page_size, MADV_NORMAL) == 0);
    if (sabotage) p[page_size - 1] = 24;
    for (size_t i = 0; i < page_size; ++i) EXPECT(p[i] == 23);
    EXPECT(munmap(p, page_size) == 0);
    return 0;
}

static int files(void) {
    char name[] = "aici-openat-XXXXXX";
    int original = mkstemp(name);
    REQUIRE(original >= 0);
    int directory = open(".", O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (directory < 0) { unlink(name); close(original); return 2; }
    int fd = openat(directory, name, O_RDWR | O_CLOEXEC);
    int unlinked = unlink(name);
    REQUIRE(fd >= 0 && unlinked == 0);
    struct stat a, b;
    REQUIRE(fstat(original, &a) == 0 && fstat(fd, &b) == 0);
    EXPECT(a.st_ino == b.st_ino && a.st_dev == b.st_dev);
    int flags = fcntl(fd, F_GETFD);
    EXPECT(flags >= 0 && (flags & FD_CLOEXEC) != 0);
    REQUIRE(write(fd, "native", 6) == 6 && lseek(fd, 0, SEEK_SET) == 0);
    char text[6];
    REQUIRE(read(fd, text, sizeof text) == (ssize_t)sizeof text);
    if (sabotage) text[0] = 'X';
    EXPECT(memcmp(text, "native", sizeof text) == 0);
    EXPECT(close(original) == 0 && close(fd) == 0 && close(directory) == 0);
    return 0;
}

static int error_translation(void) {
    char byte;
    errno = 0;
    ssize_t n = read(-1, &byte, 1);
    int e = errno;
    if (sabotage) e = 0;
    EXPECT(n == -1 && e == EBADF);
    return 0;
}

static int pipe_poll(void) {
    int fd[2];
    REQUIRE(pipe(fd) == 0);
    struct pollfd p = {fd[0], POLLIN, 0};
    EXPECT(poll(&p, 1, 20) == 0);
    REQUIRE(write(fd[1], "P", 1) == 1);
    int n = poll(&p, 1, 1000);
    if (sabotage) p.revents = 0;
    EXPECT(n == 1 && (p.revents & POLLIN) != 0);
    char byte;
    EXPECT(read(fd[0], &byte, 1) == 1 && byte == 'P');
    EXPECT(close(fd[0]) == 0 && close(fd[1]) == 0);
    return 0;
}

static int pipe_select(void) {
    int fd[2];
    REQUIRE(pipe(fd) == 0 && fd[0] < FD_SETSIZE);
    fd_set set;
    FD_ZERO(&set); FD_SET(fd[0], &set);
    struct timeval timeout = {0, 20000};
    EXPECT(select(fd[0] + 1, &set, NULL, NULL, &timeout) == 0);
    REQUIRE(write(fd[1], "S", 1) == 1);
    FD_ZERO(&set); FD_SET(fd[0], &set);
    timeout.tv_sec = 1; timeout.tv_usec = 0;
    int n = select(fd[0] + 1, &set, NULL, NULL, &timeout);
    if (sabotage) FD_ZERO(&set);
    EXPECT(n == 1 && FD_ISSET(fd[0], &set));
    char byte;
    EXPECT(read(fd[0], &byte, 1) == 1 && byte == 'S');
    EXPECT(close(fd[0]) == 0 && close(fd[1]) == 0);
    return 0;
}

static int socket_epoll(void) {
    int fd[2];
    REQUIRE(socketpair(AF_UNIX, SOCK_STREAM, 0, fd) == 0);
    int queue = epoll_create1(EPOLL_CLOEXEC);
    REQUIRE(queue >= 0);
    struct epoll_event event;
    memset(&event, 0, sizeof event);
    event.events = EPOLLIN; event.data.u64 = UINT64_C(0x1122334455667788);
    REQUIRE(epoll_ctl(queue, EPOLL_CTL_ADD, fd[0], &event) == 0);
    struct epoll_event result;
    EXPECT(epoll_wait(queue, &result, 1, 20) == 0);
    REQUIRE(write(fd[1], "E", 1) == 1);
    int n = epoll_wait(queue, &result, 1, 1000);
    if (sabotage) result.data.u64 = (uint32_t)result.data.u64;
    EXPECT(n == 1 && (result.events & EPOLLIN) != 0 &&
           result.data.u64 == event.data.u64);
    char byte;
    EXPECT(read(fd[0], &byte, 1) == 1 && byte == 'E');
    EXPECT(close(queue) == 0 && close(fd[0]) == 0 && close(fd[1]) == 0);
    return 0;
}

static int loading(void) {
    void *handle = dlopen(library_path, RTLD_NOW | RTLD_LOCAL);
    if (!handle) {
        fprintf(stderr, "loader: %s\n", dlerror());
        return 2;
    }
    dlerror();
    void *symbol = dlsym(handle, "aici_native_transform");
    const char *error = dlerror();
    EXPECT(error == NULL && symbol != NULL);
    /* POSIX dlsym permits function symbols; memcpy avoids an ISO C cast. */
    int (*transform)(int);
    _Static_assert(sizeof transform == sizeof symbol, "POSIX dlsym ABI");
    memcpy(&transform, &symbol, sizeof transform);
    int result = transform(sabotage ? 22 : 21);
    EXPECT(result == 64);
    dlerror();
    symbol = dlsym(handle, "aici_native_missing_symbol");
    error = dlerror();
    EXPECT(symbol == NULL && error != NULL);
    EXPECT(dlclose(handle) == 0);
    return 0;
}

struct thread_state {
    pthread_mutex_t mutex;
    pthread_cond_t condition;
    int ready;
    int observed_errno;
    int error;
};
static void *thread_worker(void *argument) {
    struct thread_state *state = argument;
    if ((state->error = pthread_mutex_lock(&state->mutex)) != 0) return NULL;
    char byte;
    errno = 0;
    ssize_t n = read(-1, &byte, 1);
    state->observed_errno = n == -1 ? errno : 0;
    state->ready = 1;
    int e = pthread_cond_signal(&state->condition);
    int u = pthread_mutex_unlock(&state->mutex);
    state->error = e != 0 ? e : u;
    return argument;
}
static int threads(void) {
    struct thread_state state = {
        PTHREAD_MUTEX_INITIALIZER, PTHREAD_COND_INITIALIZER, 0, 0, 0
    };
    pthread_t thread;
    REQUIRE(pthread_mutex_lock(&state.mutex) == 0);
    REQUIRE(pthread_create(&thread, NULL, thread_worker, &state) == 0);
    errno = EDOM;
    while (!state.ready) REQUIRE(pthread_cond_wait(&state.condition, &state.mutex) == 0);
    int own_errno = errno;
    REQUIRE(pthread_mutex_unlock(&state.mutex) == 0);
    void *returned = NULL;
    REQUIRE(pthread_join(thread, &returned) == 0);
    if (sabotage) own_errno = state.observed_errno;
    EXPECT(returned == &state && state.error == 0 &&
           state.observed_errno == EBADF && own_errno == EDOM);
    EXPECT(pthread_cond_destroy(&state.condition) == 0 &&
           pthread_mutex_destroy(&state.mutex) == 0);
    return 0;
}

static int clocks(void) {
    struct timespec a, b, delay = {0, 20000000};
    REQUIRE(clock_gettime(CLOCK_MONOTONIC, &a) == 0);
    while (nanosleep(&delay, &delay) != 0) REQUIRE(errno == EINTR);
    REQUIRE(clock_gettime(CLOCK_MONOTONIC, &b) == 0);
    if (sabotage) b.tv_sec = a.tv_sec - 1;
    EXPECT(a.tv_nsec >= 0 && a.tv_nsec < 1000000000 &&
           b.tv_nsec >= 0 && b.tv_nsec < 1000000000);
    EXPECT(b.tv_sec > a.tv_sec || (b.tv_sec == a.tv_sec && b.tv_nsec > a.tv_nsec));
    return 0;
}

static int random_input(void) {
    /* API-24-safe byte acquisition; no statistical/cryptographic quality claim. */
    int fd = open("/dev/urandom", O_RDONLY | O_CLOEXEC);
    REQUIRE(fd >= 0);
    unsigned char bytes[32];
    size_t count = 0;
    while (count < sizeof bytes) {
        ssize_t n = read(fd, bytes + count, sizeof bytes - count);
        if (n < 0 && errno == EINTR) continue;
        REQUIRE(n > 0);
        count += (size_t)n;
    }
    if (sabotage) --count;
    EXPECT(count == sizeof bytes);
    EXPECT(close(fd) == 0);
    return 0;
}

static const struct native_case { const char *name; int (*run)(void); } cases[] = {
    {"mmap-anonymous", anonymous_memory}, {"mmap-errors", mapping_errors},
    {"mmap-file-offset", file_offset}, {"mmap-large-offset", large_offset},
    {"mmap-private", private_mapping}, {"mmap-shared", shared_mapping},
    {"mprotect", protection}, {"madvise", advice}, {"files", files},
    {"errno", error_translation}, {"poll", pipe_poll}, {"select", pipe_select},
    {"epoll-socket", socket_epoll}, {"dlopen-dlsym", loading},
    {"pthread-errno", threads}, {"clock", clocks}, {"random-read", random_input}
};

static int execute_case(size_t index, int bad) {
    fflush(NULL);
    pid_t child = fork();
    if (child < 0) { perror("fork"); return 1; }
    if (child == 0) {
        alarm(10);
        case_name = cases[index].name;
#ifdef AICI_NATIVE_SELF_TEST
        sabotage = bad;
#else
        (void)bad;
#endif
        _exit(cases[index].run());
    }
    int status;
    pid_t got;
    do { got = waitpid(child, &status, 0); } while (got < 0 && errno == EINTR);
    if (got != child) { perror("waitpid"); return 1; }
    int ok = WIFEXITED(status) && WEXITSTATUS(status) == (bad ? 1 : 0);
    printf("case\t%s\t%s\t%s\twait_status=%d\n", cases[index].name,
           bad ? "known-bad" : "native", ok ? "PASS" : "FAIL", status);
    return !ok;
}

int main(int argc, char **argv) {
    int self_test = 0;
#ifdef AICI_NATIVE_SELF_TEST
    if (argc == 3 && strcmp(argv[1], "--self-test") == 0) self_test = 1;
#endif
    if ((!self_test && argc != 2) || (self_test && argc != 3)) {
        fprintf(stderr, "usage: probe /absolute/path/libnative-fixture.so\n");
        return 2;
    }
    library_path = argv[self_test ? 2 : 1];
    long pages = sysconf(_SC_PAGESIZE);
    if (pages <= 0 || (uintmax_t)pages > SIZE_MAX / 2) return 2;
    page_size = (size_t)pages;
    struct rlimit no_core = {0, 0};
    if (setrlimit(RLIMIT_CORE, &no_core) != 0) { perror("setrlimit"); return 2; }
    struct utsname system;
    if (uname(&system) != 0) { perror("uname"); return 2; }
#ifdef __BIONIC__
    const char *libc_name = "bionic";
#elif defined(__GLIBC__)
    const char *libc_name = "glibc";
#else
    const char *libc_name = "other";
#endif
    printf("schema\taici-native-boundary-v1\nsource\t%s\nlibc\t%s\n"
           "machine\t%s\nkernel\t%s\npage_size\t%zu\n"
           "sizeof_pointer\t%zu\nsizeof_long\t%zu\nsizeof_off_t\t%zu\n"
           "sizeof_off64_t\t%zu\nsizeof_time_t\t%zu\n",
           AICI_NATIVE_REVISION, libc_name, system.machine, system.release,
           page_size, sizeof(void *), sizeof(long), sizeof(off_t),
           sizeof(off64_t), sizeof(time_t));
#ifdef __ANDROID_API__
    printf("compile_api\t%d\n", __ANDROID_API__);
#else
    printf("compile_api\tnot-android\n");
#endif
    printf("mode\t%s\n", self_test ? "harness-self-test" : "native-execution");
    int failures = 0;
    for (size_t i = 0; i < sizeof cases / sizeof cases[0]; ++i) {
        failures += execute_case(i, 0);
        if (self_test) failures += execute_case(i, 1);
    }
    printf("summary\t%s\tfailures=%d\n", failures ? "FAIL" : "PASS", failures);
    return failures ? 1 : 0;
}
