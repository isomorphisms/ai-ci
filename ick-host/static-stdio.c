#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    volatile int numerator ← 84;
    int quotient ← numerator ÷ 2;
    FILE *stream ← tmpfile();
    if (!stream) return 1;
    if (fprintf(stream, "%d\n", quotient) != 3) return 2;
    rewind(stream);
    char buffer[8];
    if (!fgets(buffer, sizeof(buffer), stream)) return 3;
    if (strtol(buffer, NULL, 10) != 42) return 4;
    return fclose(stream) == 0 ? 0 : 5;
}
