#ifndef ICK_BIONIC_FORTIFY_UNISTD_H
#define ICK_BIONIC_FORTIFY_UNISTD_H
#ifndef _UNISTD_H_
#error "Include unistd.h before its ICK Fortify implementation"
#endif
#include <ick_fortify_profile.h>
ssize_t __read_chk(int, void *, size_t, size_t);
ssize_t __write_chk(int, const void *, size_t, size_t) __INTRODUCED_IN(24);
ICK_FORTIFY_INLINE ssize_t read(int descriptor, void *buffer, size_t count)
{
    return __read_chk(descriptor, buffer, count, ICK_FORTIFY_BOS0(buffer));
}
ICK_FORTIFY_INLINE ssize_t write(int descriptor, const void *buffer, size_t count)
{
    return __write_chk(descriptor, buffer, count, ICK_FORTIFY_BOS0(buffer));
}
#pragma GCC poison getcwd pread pread64 pwrite pwrite64 readlink readlinkat
#endif
