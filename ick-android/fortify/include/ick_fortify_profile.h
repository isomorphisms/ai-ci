#ifndef ICK_BIONIC_FORTIFY_PROFILE_H
#define ICK_BIONIC_FORTIFY_PROFILE_H
/* Deliberately bounded C profile. Public declarations remain NDK-owned. */
#if defined(__cplusplus)
#error "ICK Bionic Fortify profile is C-only"
#endif
#if !defined(__ANDROID__) || !defined(__BIONIC__)
#error "ICK Bionic Fortify profile requires the Android Bionic headers"
#endif
#if !defined(_FORTIFY_SOURCE) || _FORTIFY_SOURCE != 2
#error "ICK Bionic Fortify profile requires the existing _FORTIFY_SOURCE=2"
#endif
#if !defined(__ANDROID_API__) || __ANDROID_API__ < 26
#error "ICK Bionic Fortify profile currently requires Android API 26 or later"
#endif
#if !defined(__BIONIC_FORTIFY) || !__BIONIC_FORTIFY_RUNTIME_CHECKS_ENABLED
#error "ICK Bionic Fortify profile requires active Bionic runtime checks"
#endif
/* Inlining retains object sizes after argument side effects are evaluated. */
#define ICK_FORTIFY_INLINE extern __inline __attribute__((__always_inline__, __gnu_inline__, __artificial__))
#define ICK_FORTIFY_BOS0(pointer) __builtin_object_size((pointer), 0)
#define ICK_FORTIFY_BOS1(pointer) __builtin_object_size((pointer), 1)
#endif
