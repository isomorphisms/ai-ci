#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { MAX_LINES = 32, MAX_LINE = 4096 };

struct receipt {
    size_t count;
    char lines[MAX_LINES][MAX_LINE];
};

static const char *stitch_recipes[] = {
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-stitch-self-test-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_STITCH_CHECKER]\" --self-test",
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-increasing-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_STITCH_CHECKER]\" \"$[ENV.FLOWER_WORKSPACE]/build\" increasing \"$[ENV.FLOWER_WORKSPACE]/build/flower-stitch-test\"",
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-control-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_STITCH_CHECKER]\" \"$[ENV.FLOWER_WORKSPACE]/build\" control \"$[ENV.FLOWER_WORKSPACE]/build/flower-stitch-test\""
};

static const char *metric_recipes[] = {
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-metric-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_METRIC_CHECKER]\" \"$[ENV.FLOWER_WORKSPACE]/build/metric.tsv\" --self-test"
};

static const char *topology_recipes[] = {
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-topology-self-test-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_TOPOLOGY_CHECKER]\" --self-test",
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-coarse-topology-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_TOPOLOGY_CHECKER]\" \"$[ENV.FLOWER_WORKSPACE]/build/mesh.obj\" annulus",
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-fine-topology-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_TOPOLOGY_CHECKER]\" \"$[ENV.FLOWER_WORKSPACE]/build/mesh-fine.obj\" annulus"
};

static const char *realization_recipes[] = {
    "env ITHON_CHECK_RECEIPT=\"$[ENV.FLOWER_WORKSPACE]/build/ike-realization-frontend.json\" \"$[ENV.FLOWER_GREASE]\" \"$[ENV.FLOWER_KITCHEN_RECIPE]\" \"$[ENV.FLOWER_ITHON]\" \"$[ENV.FLOWER_REALIZATION_CHECKER]\" \"$[ENV.FLOWER_WORKSPACE]/build/markers.tsv\" \"$[ENV.FLOWER_WORKSPACE]/build/mesh.obj\" \"$[ENV.FLOWER_WORKSPACE]/build/mesh-fine.obj\" \"$[ENV.FLOWER_WORKSPACE]/build/material-edges.tsv\""
};

static void reject(const char *message)
{
    fprintf(stderr, "AICI_FLOWER_IKE_RECEIPT_REJECT %s\n", message);
    exit(1);
}

static void hex_encode(const char *text, char *output, size_t output_size)
{
    static const char digits[] = "0123456789abcdef";
    size_t length = strlen(text);
    if (length > (output_size - 1) / 2)
        reject("expected value too long");
    for (size_t i = 0; i < length; i++) {
        unsigned char byte = (unsigned char)text[i];
        output[2 * i] = digits[byte >> 4];
        output[2 * i + 1] = digits[byte & 15];
    }
    output[2 * length] = '\0';
}

static void read_receipt(const char *path, struct receipt *receipt)
{
    FILE *file = fopen(path, "r");
    if (file == NULL) {
        perror("AICI Flower Ike receipt open");
        exit(1);
    }
    receipt->count = 0;
    while (receipt->count < MAX_LINES &&
           fgets(receipt->lines[receipt->count], MAX_LINE, file) != NULL) {
        char *line = receipt->lines[receipt->count];
        size_t length = strlen(line);
        if (length == MAX_LINE - 1 && line[length - 1] != '\n')
            reject("receipt line too long");
        while (length > 0 &&
               (line[length - 1] == '\n' || line[length - 1] == '\r'))
            line[--length] = '\0';
        receipt->count++;
    }
    if (ferror(file))
        reject("receipt read failed");
    if (fgetc(file) != EOF)
        reject("too many receipt lines");
    if (fclose(file) != 0)
        reject("receipt close failed");
}

static const char *expect(const struct receipt *receipt, size_t index,
                          const char *line, const char *diagnostic)
{
    if (index >= receipt->count || strcmp(receipt->lines[index], line) != 0)
        return diagnostic;
    return NULL;
}

static void text_line(char *output, size_t size, const char *key,
                      const char *value)
{
    char encoded[MAX_LINE / 2];
    hex_encode(value, encoded, sizeof encoded);
    if (snprintf(output, size, "%s\t%s", key, encoded) >= (int)size)
        reject("expected line too long");
}

static void rule_line(char *output, size_t size, size_t event,
                      const char *target)
{
    char encoded[MAX_LINE / 2];
    hex_encode(target, encoded, sizeof encoded);
    if (snprintf(output, size, "rule\t%zu\t%s", event, encoded) >=
        (int)size)
        reject("expected rule too long");
}

static void recipe_line(char *output, size_t size, size_t event,
                        const char *target, const char *recipe)
{
    char target_hex[MAX_LINE / 2];
    char recipe_hex[MAX_LINE / 2];
    hex_encode(target, target_hex, sizeof target_hex);
    hex_encode(recipe, recipe_hex, sizeof recipe_hex);
    if (snprintf(output, size, "recipe\t%zu\t%s\t%s\t0",
                 event, target_hex, recipe_hex) >= (int)size)
        reject("expected recipe too long");
}

static const char *inspect_rule(const struct receipt *receipt, size_t *line,
                                size_t *event, const char *target,
                                const char *const *recipes,
                                size_t recipe_count)
{
    char expected[MAX_LINE];
    rule_line(expected, sizeof expected, (*event)++, target);
    const char *error = expect(receipt, (*line)++, expected, "rule mismatch");
    if (error != NULL)
        return error;
    for (size_t i = 0; i < recipe_count; i++) {
        recipe_line(expected, sizeof expected, (*event)++, target, recipes[i]);
        error = expect(receipt, (*line)++, expected, "recipe mismatch");
        if (error != NULL)
            return error;
    }
    return NULL;
}

static const char *inspect(const struct receipt *receipt,
                           const char *ikefile_identity,
                           const char *runner_identity)
{
    char expected[MAX_LINE];
    size_t line = 0;
    const char *error = expect(receipt, line++, "schema\tike-build-v1",
                               "schema mismatch");
    if (error != NULL)
        return error;
    text_line(expected, sizeof expected, "selected_target_hex", "accept");
    error = expect(receipt, line++, expected, "selected target mismatch");
    if (error != NULL)
        return error;
    text_line(expected, sizeof expected, "ikefile_identity_hex",
              ikefile_identity);
    error = expect(receipt, line++, expected, "Ikefile identity mismatch");
    if (error != NULL)
        return error;
    error = expect(receipt, line++, "recipe_runner_mode\texternal-source-file",
                   "recipe runner mode mismatch");
    if (error != NULL)
        return error;
    text_line(expected, sizeof expected, "recipe_runner_identity_hex",
              runner_identity);
    error = expect(receipt, line++, expected, "recipe runner identity mismatch");
    if (error != NULL)
        return error;

    size_t event = 0;
    error = inspect_rule(receipt, &line, &event, "stitch", stitch_recipes, 3);
    if (error != NULL)
        return error;
    error = inspect_rule(receipt, &line, &event, "metric", metric_recipes, 1);
    if (error != NULL)
        return error;
    error = inspect_rule(receipt, &line, &event, "topology",
                         topology_recipes, 3);
    if (error != NULL)
        return error;
    error = inspect_rule(receipt, &line, &event, "realization",
                         realization_recipes, 1);
    if (error != NULL)
        return error;
    error = inspect_rule(receipt, &line, &event, "accept", NULL, 0);
    if (error != NULL)
        return error;
    error = expect(receipt, line++, "final_result\tPASS",
                   "final result mismatch");
    if (error != NULL)
        return error;
    if (line != receipt->count)
        return "unexpected trailing data";
    return NULL;
}

static void verify(const struct receipt *receipt, const char *identity,
                   const char *runner)
{
    const char *error = inspect(receipt, identity, runner);
    if (error != NULL)
        reject(error);
}

static void self_test(const struct receipt *valid, const char *identity,
                      const char *runner)
{
    struct receipt forged = *valid;
    verify(valid, identity, runner);

    strcpy(forged.lines[1], "selected_target_hex\t00");
    const char *error = inspect(&forged, identity, runner);
    if (error == NULL || strcmp(error, "selected target mismatch") != 0)
        reject("forged selected target was not rejected precisely");
    puts("REJECT forged selected target: selected target mismatch");

    forged = *valid;
    strcpy(forged.lines[forged.count - 1], "final_result\tFAIL");
    error = inspect(&forged, identity, runner);
    if (error == NULL || strcmp(error, "final result mismatch") != 0)
        reject("forged final result was not rejected precisely");
    puts("REJECT forged final result: final result mismatch");
    puts("PASS digest-bound Ike receipt and two targeted forgeries");
}

int main(int argc, char **argv)
{
    if (argc != 5 ||
        (strcmp(argv[1], "verify") != 0 &&
         strcmp(argv[1], "self-test") != 0)) {
        fprintf(stderr,
                "usage: %s verify|self-test RECEIPT IKEFILE_IDENTITY RUNNER\n",
                argv[0]);
        return 2;
    }
    struct receipt receipt;
    read_receipt(argv[2], &receipt);
    if (strcmp(argv[1], "verify") == 0) {
        verify(&receipt, argv[3], argv[4]);
        puts("PASS digest-bound Flower Ike receipt");
    } else {
        self_test(&receipt, argv[3], argv[4]);
    }
    return 0;
}
