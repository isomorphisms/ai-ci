int k3_negative(void)
{
#if defined(K3_NEIGHBOR)
    int target;
    return __builtin_icky(target ↚ 010);
#elif defined(K3_MALFORMED)
    return __builtin_icky(010 + 1);
#elif defined(K3_STALE_MAP)
#line 71 "unapproved-source-map.c"
    return __builtin_icky(010);
#else
    return __builtin_icky(010);
#endif
}
