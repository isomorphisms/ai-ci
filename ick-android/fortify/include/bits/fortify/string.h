#ifndef ICK_BIONIC_FORTIFY_STRING_H
#define ICK_BIONIC_FORTIFY_STRING_H
#ifndef _STRING_H
#error "Include string.h before its ICK Fortify implementation"
#endif
#include <ick_fortify_profile.h>
/* Match Bionic's destination object-size mode and actual checked ABI. */
ICK_FORTIFY_INLINE void *memcpy(void *destination, const void *source, size_t count)
{
    return __builtin___memcpy_chk(destination, source, count, ICK_FORTIFY_BOS0(destination));
}
ICK_FORTIFY_INLINE void *memmove(void *destination, const void *source, size_t count)
{
    return __builtin___memmove_chk(destination, source, count, ICK_FORTIFY_BOS0(destination));
}
ICK_FORTIFY_INLINE void *memset(void *destination, int value, size_t count)
{
    return __builtin___memset_chk(destination, value, count, ICK_FORTIFY_BOS0(destination));
}
ICK_FORTIFY_INLINE size_t strlen(const char *source)
{
    return __strlen_chk(source, ICK_FORTIFY_BOS0(source));
}
/* These calls must not fall back to their unfortified public declarations. */
#pragma GCC poison memchr memrchr mempcpy stpcpy strcpy strcat strncat
#pragma GCC poison stpncpy strncpy strlcpy strlcat
#pragma GCC poison strchr strrchr
#endif
