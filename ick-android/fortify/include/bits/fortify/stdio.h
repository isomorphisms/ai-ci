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
#pragma GCC poison fread fgets sprintf snprintf vsprintf vsnprintf
#endif
