#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void fail(const char *message)
{
    fprintf(stderr, "aici-ike-receipt: %s\n", message);
    exit(1);
}

static void hex_encode(const char *text, char *output, size_t output_size)
{
    static const char digits[] = "0123456789abcdef";
    size_t length = strlen(text);
    if (length > (output_size - 1) / 2)
        fail("expected value too long");

    for (size_t i = 0; i < length; i++) {
        unsigned char byte = (unsigned char)text[i];
        output[i * 2] = digits[byte >> 4];
        output[i * 2 + 1] = digits[byte & 15];
    }
    output[length * 2] = '\0';
}

static void require_line(FILE *file, const char *expected,
                         const char *diagnostic)
{
    char line[4096];
    if (fgets(line, sizeof line, file) == NULL)
        fail(diagnostic);

    size_t length = strlen(line);
    if (length > 0 && line[length - 1] == '\n')
        line[--length] = '\0';
    if (length > 0 && line[length - 1] == '\r')
        line[--length] = '\0';

    if (strcmp(line, expected) != 0)
        fail(diagnostic);
}

static void text_line(char *output, size_t output_size, const char *key,
                      const char *text)
{
    char encoded[2048];
    hex_encode(text, encoded, sizeof encoded);
    if (snprintf(output, output_size, "%s\t%s", key, encoded) >=
        (int)output_size)
        fail("expected line too long");
}

static void rule_line(char *output, size_t output_size, size_t event,
                      const char *target)
{
    char encoded[2048];
    hex_encode(target, encoded, sizeof encoded);
    if (snprintf(output, output_size, "rule\t%zu\t%s", event, encoded) >=
        (int)output_size)
        fail("expected rule too long");
}

static void recipe_line(char *output, size_t output_size, size_t event,
                        const char *target, const char *recipe, int status)
{
    char target_hex[2048];
    char recipe_hex[2048];
    hex_encode(target, target_hex, sizeof target_hex);
    hex_encode(recipe, recipe_hex, sizeof recipe_hex);
    if (snprintf(output, output_size, "recipe\t%zu\t%s\t%s\t%d",
                 event, target_hex, recipe_hex, status) >= (int)output_size)
        fail("expected recipe too long");
}

static void verify(const char *path, const char *ikefile_identity)
{
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        perror("aici-ike-receipt: cannot open receipt");
        exit(1);
    }

    char expected[4096];

    require_line(file, "schema\tike-build-v1", "schema mismatch");

    text_line(expected, sizeof expected, "selected_target_hex",
              "aici-self-test");
    require_line(file, expected, "selected target mismatch");

    text_line(expected, sizeof expected, "ikefile_identity_hex",
              ikefile_identity);
    require_line(file, expected, "Ikefile identity mismatch");

    require_line(file, "recipe_runner_mode\tposix-system",
                 "recipe runner mode mismatch");

    text_line(expected, sizeof expected, "recipe_runner_identity_hex",
              "POSIX-system()");
    require_line(file, expected, "recipe runner identity mismatch");

    rule_line(expected, sizeof expected, 0, "/tmp/aici-ike");
    require_line(file, expected, "compile rule mismatch");

    recipe_line(expected, sizeof expected, 1, "/tmp/aici-ike",
                "cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 "
                "-o /tmp/aici-ike ../src/aici.c", 0);
    require_line(file, expected, "compile recipe mismatch");

    rule_line(expected, sizeof expected, 2, "aici-self-test");
    require_line(file, expected, "self-test rule mismatch");

    recipe_line(expected, sizeof expected, 3, "aici-self-test",
                "cd .. && /tmp/aici-ike self-test tests/cases.tsv", 0);
    require_line(file, expected, "self-test recipe mismatch");

    require_line(file, "final_result\tPASS", "final result mismatch");

    char trailing[2];
    if (fgets(trailing, sizeof trailing, file) != NULL)
        fail("unexpected trailing data");

    if (fclose(file) != 0)
        fail("cannot close receipt");
}

int main(int argc, char **argv)
{
    if (argc != 4 || strcmp(argv[1], "verify") != 0) {
        fprintf(stderr,
                "usage: %s verify RECEIPT IKEFILE_IDENTITY\n", argv[0]);
        return 2;
    }

    verify(argv[2], argv[3]);
    return 0;
}
