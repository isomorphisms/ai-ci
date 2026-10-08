/* A stock compiler cannot produce this executable. */
int main(void)
{
    int value ← 1 × 3;
    value ← value + 4;
    return value == 7 ? 0 : 1;
}
