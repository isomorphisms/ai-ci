#ifndef ICK_BIONIC_FORTIFY_FCNTL_H
#define ICK_BIONIC_FORTIFY_FCNTL_H
#include <ick_fortify_profile.h>

/* GNU always-inline varargs preserve the public arguments exactly once. A
 * missing mode for dynamic creation flags uses Bionic's checked ABI; constant
 * misuse and extra arguments are compile-time errors. Never read an absent
 * variadic mode, and never route unchecked dynamic flags around __open*_2. */
int __open_2(const char *, int);
int __openat_2(int, const char *, int);
int __ick_open_real(const char *, int, ...) __asm__("open");
int __ick_open64_real(const char *, int, ...) __asm__("open64");
int __ick_openat_real(int, const char *, int, ...) __asm__("openat");
int __ick_openat64_real(int, const char *, int, ...) __asm__("openat64");
void __ick_open_missing_mode(void) __attribute__((__error__("ICK Fortify open requires mode for creation flags")));
void __ick_open_extra_mode(void) __attribute__((__error__("ICK Fortify open accepts at most one mode argument")));

#define ICK_OPEN_NEEDS_MODE(flags) (((flags) & O_CREAT) != 0 || ((flags) & O_TMPFILE) == O_TMPFILE)

ICK_FORTIFY_INLINE int open(const char *path, int flags, ...)
{
    if (__builtin_va_arg_pack_len() > 1) __ick_open_extra_mode();
    if (__builtin_va_arg_pack_len() == 0) {
        if (__builtin_constant_p(flags) && ICK_OPEN_NEEDS_MODE(flags)) __ick_open_missing_mode();
        return __open_2(path, flags);
    }
    return __ick_open_real(path, flags, __builtin_va_arg_pack());
}

ICK_FORTIFY_INLINE int open64(const char *path, int flags, ...)
{
    if (__builtin_va_arg_pack_len() > 1) __ick_open_extra_mode();
    if (__builtin_va_arg_pack_len() == 0) {
        if (__builtin_constant_p(flags) && ICK_OPEN_NEEDS_MODE(flags)) __ick_open_missing_mode();
        return __open_2(path, flags);
    }
    return __ick_open64_real(path, flags, __builtin_va_arg_pack());
}

ICK_FORTIFY_INLINE int openat(int directory, const char *path, int flags, ...)
{
    if (__builtin_va_arg_pack_len() > 1) __ick_open_extra_mode();
    if (__builtin_va_arg_pack_len() == 0) {
        if (__builtin_constant_p(flags) && ICK_OPEN_NEEDS_MODE(flags)) __ick_open_missing_mode();
        return __openat_2(directory, path, flags);
    }
    return __ick_openat_real(directory, path, flags, __builtin_va_arg_pack());
}

ICK_FORTIFY_INLINE int openat64(int directory, const char *path, int flags, ...)
{
    if (__builtin_va_arg_pack_len() > 1) __ick_open_extra_mode();
    if (__builtin_va_arg_pack_len() == 0) {
        if (__builtin_constant_p(flags) && ICK_OPEN_NEEDS_MODE(flags)) __ick_open_missing_mode();
        return __openat_2(directory, path, flags);
    }
    return __ick_openat64_real(directory, path, flags, __builtin_va_arg_pack());
}
#undef ICK_OPEN_NEEDS_MODE
#endif
