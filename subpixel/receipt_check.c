/* Independent, schema-exact verifier for the one-step Subpixel Ike receipt.
 * Do not trust the producer's terminal PASS or the recipe's own stdout.
 * Compiled by ICK together with the independent curvature oracle.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void error(const char *description) {
    fprintf(stderr, "AICI_SUBPIXEL_RECEIPT_REJECT %s\n", description);
    exit(1);
}

static void encoded(const char *input, char *output, size_t size) {
    static const char hex[] = "0123456789abcdef";
    size_t len = strlen(input);
    if (len > (size - 1) / 2) error("expected field overflow");
    for (size_t i = 0; i < len; ++i) {
        unsigned char byte = (unsigned char)input[i];
        output[2 * i] = hex[byte >> 4];
        output[2 * i + 1] = hex[byte & 15u];
    }
    output[2 * len] = 0;
}

static void require_line(FILE *file, const char *wanted, const char *field) {
    char buffer[4096];
    if (!fgets(buffer, sizeof buffer, file)) error(field);
    size_t len = strlen(buffer);
    if (len == 0 || buffer[len - 1] != '\n') error("unterminated or oversized line");
    buffer[len - 1] = 0;
    if (strcmp(buffer, wanted) != 0) error(field);
}

static void field_line(char *buffer, size_t size, const char *field,
                       const char *value) {
    char hex[2048];
    encoded(value, hex, sizeof hex);
    if (snprintf(buffer, size, "%s\t%s", field, hex) >= (int)size)
        error("field too long");
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fputs("usage: receipt-check RECEIPT EXPECTED_IKEFILE_IDENTITY\n", stderr);
        return 2;
    }
    const char *identity = argv[2];
    if (strncmp(identity, "sha256:", 7) != 0 || strlen(identity) != 71)
        error("expected digest identity");
    for (const char *c = identity + 7; *c; ++c)
        if (!(('0' <= *c && *c <= '9') || ('a' <= *c && *c <= 'f')))
            error("malformed identity");

    FILE *input = fopen(argv[1], "rb");
    if (!input) error("cannot open receipt");
    char line[4096], hex_target[2048], hex_recipe[2048];
    encoded("accept", hex_target, sizeof hex_target);
    encoded("sh accept.sh", hex_recipe, sizeof hex_recipe);

    require_line(input, "schema\tike-build-v1", "schema");
    field_line(line, sizeof line, "selected_target_hex", "accept");
    require_line(input, line, "selected target");
    field_line(line, sizeof line, "ikefile_identity_hex", identity);
    require_line(input, line, "Ikefile digest");
    require_line(input, "recipe_runner_mode\tposix-system", "runner mode");
    field_line(line, sizeof line, "recipe_runner_identity_hex", "POSIX-system()");
    require_line(input, line, "recipe runner identity");
    if (snprintf(line, sizeof line, "rule\t0\t%s", hex_target) >= (int)sizeof line)
        error("rule overflow");
    require_line(input, line, "rule order");
    if (snprintf(line, sizeof line, "recipe\t1\t%s\t%s\t0",
                 hex_target, hex_recipe) >= (int)sizeof line)
        error("recipe overflow");
    require_line(input, line, "recipe and actual exit status");
    require_line(input, "final_result\tPASS", "final result");

    if (fgetc(input) != EOF || ferror(input)) error("unexpected trailing bytes");
    if (fclose(input) != 0) error("cannot close receipt");
    puts("AICI_SUBPIXEL_RECEIPT independent exact Ike receipt: PASS");
    return 0;
}
