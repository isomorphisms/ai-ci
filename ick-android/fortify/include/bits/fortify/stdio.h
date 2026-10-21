#ifndef ICK_BIONIC_FORTIFY_STDIO_H
#define ICK_BIONIC_FORTIFY_STDIO_H
#ifndef _STDIO_H_
#error "Include stdio.h before its ICK Fortify implementation"
#endif
#include <ick_fortify_profile.h>
size_t __fwrite_chk(const void *, size_t, size_t, FILE *, size_t) __INTRODUCED_IN(24);
ICK_FORTIFY_INLINE size_t fwrite(const void *buffer, size_t size, size_t count, FILE *stream)
{
    return __fwrite_chk(buffer, size, count, stream, ICK_FORTIFY_BOS0(buffer));
}
ICK_FORTIFY_INLINE __attribute__((format(printf, 3, 0)))
int vsnprintf(char *destination, size_t size, const char *format, va_list arguments)
{
    return __builtin___vsnprintf_chk(destination, size, 0, ICK_FORTIFY_BOS1(destination), format, arguments);
}
ICK_FORTIFY_INLINE __attribute__((format(printf, 3, 4)))
int snprintf(char *destination, size_t size, const char *format, ...)
{
    return __builtin___snprintf_chk(destination, size, 0, ICK_FORTIFY_BOS1(destination), format, __builtin_va_arg_pack());
}
#pragma GCC poison fread fgets sprintf vsprintf
#endif
