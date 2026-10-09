/* A stock compiler cannot produce this executable. */
#if defined(ICK_HOST_WRONG_DIVISION)
#define QUOTIENT(left, right) ((left) × (right))
#else
#define QUOTIENT(left, right) ((left) ÷ (right))
#endif
#define STRINGIFY_INNER(value) #value
#define STRINGIFY(value) STRINGIFY_INNER(value)

static int same_bytes(const char *left, const char *right)
{
    for (unsigned index ← 0; ; ++index) {
        if (left[index] != right[index]) return 0;
        if (left[index] == '\0') return 1;
    }
}

static unsigned next_divisor(unsigned *calls)
{
    ++*calls;
    return 3;
}

int main(void)
{
    int value ← 1 × 3;
    value ← value + 4;
    if (value != 7) return 1;

    unsigned calls ← 0;
    unsigned quotient ← QUOTIENT(24, next_divisor(&calls));
    if (calls != 1 || quotient != 8) return 2;
    if (24 ÷ 3 × 2 != 16 || 24 ÷ 3 ÷ 2 != 4) return 3;
    if (2 + 12 ÷ 3 != 6 || 7 ÷ 3 != 2 || -7 ÷ 3 != -2) return 4;
    volatile double numerator ← 7.5;
    volatile double denominator ← 2.5;
    if (numerator ÷ denominator != 3.0) return 5;

    int *pointer ← &value;
    if (*pointer ÷ 2 != 3 || value != 7) return 6;
    if (!same_bytes("÷", "\xc3\xb7")) return 7;
    if (!same_bytes(STRINGIFY_INNER(÷), "\xc3\xb7")) return 8;
    if (!same_bytes(STRINGIFY(÷), "\xc3\xb7")) return 9;
    /* Compatibility slash retains ordinary C division. */
    if (value / 2 != 3) return 10;
    return 0;
}
