#ifndef ICK_BIONIC_FORTIFY_STRINGS_H
#define ICK_BIONIC_FORTIFY_STRINGS_H
#include <ick_fortify_profile.h>
#undef bcopy
#undef bzero
#pragma GCC poison bcopy bzero __bionic_bcopy __bionic_bzero
#endif
