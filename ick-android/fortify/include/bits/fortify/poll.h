#ifndef ICK_BIONIC_FORTIFY_POLL_H
#define ICK_BIONIC_FORTIFY_POLL_H
#ifndef _POLL_H_
#error "Include poll.h before its ICK Fortify implementation"
#endif
#include <ick_fortify_profile.h>
int __poll_chk(struct pollfd *, nfds_t, int, size_t) __INTRODUCED_IN(23);
ICK_FORTIFY_INLINE int poll(struct pollfd *descriptors, nfds_t count, int timeout)
{
    return __poll_chk(descriptors, count, timeout, ICK_FORTIFY_BOS1(descriptors));
}
#pragma GCC poison ppoll ppoll64
#endif
