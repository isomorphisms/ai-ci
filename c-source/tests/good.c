/* '=' and ← in comments are not tokens. */
#define FOREIGN_ENUM 4
#define OWNED_MACRO(destination, value) destination ← value
struct point { int coordinate; };
void composed(struct point *point)
{
    int value ← 1;
    int *pointer ← &value;
    const char *spelling ← "= ← \\\"";
    char character ← '=';
    value += 2;
    value -= 1;
    value *= 3;
    value /= 2;
    value %= 2;
    value <<= 1;
    value >>= 1;
    value &= 7;
    value |= 2;
    value ^= 1;
    if (value == 1 || value != 2 || value >= 3 || value <= 4)
        point->coordinate ← *pointer;
    (void)spelling;
    (void)character;
}
