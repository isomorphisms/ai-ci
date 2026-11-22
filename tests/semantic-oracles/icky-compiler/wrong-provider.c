#include <stdio.h>
#include <string.h>

/* A fixed negative provider for one input. The V3 record shapes are valid. */
int main(int argc, char **argv)
{
    if (argc != 3 || strcmp(argv[1], "--parse-v3") != 0)
        return 2;
    FILE *input ← fopen(argv[2], "rb");
    if (!input)
        return 2;
    char bytes[4];
    size_t length ← fread(bytes, 1, sizeof bytes, input);
    int had_error ← ferror(input);
    int close_status ← fclose(input);
    if (had_error || close_status || length != 3 || memcmp(bytes, "010", 3))
        return 2;

#ifdef K3_WRONG_FRAME
    const char source_frame[] ← "313030";
    const char decimal_value[] ← "100";
    const char written[] ← "313030";
#else
    const char source_frame[] ← "303130";
    const char decimal_value[] ← "11";
    const char written[] ← "303130";
#endif
    int written_count ← printf(
        "ICKY-LOCATED\t3\tchar-and-utf8-byte-offset\n"
        "source\t3\t3\t%s\n"
        "ok\t1\n"
        "expr\t0\t0\t1\t1\t3\t1\t4\t0\t3\n"
        "natural\t0.0\t0\t1\t1\t3\t1\t4\t0\t3\t%s\t%s\n",
        source_frame, decimal_value, written);
    return written_count < 0 || fflush(stdout) != 0;
}
