#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#define MOCK_FIELDS 6
#define MOCK_LINE_MAX (1024 * 1024)

static int split_tabs(char *line, char **fields) {
    int count = 0;
    char *p = line;
    fields[count++] = p;
    while (*p != '\0') {
        if (*p == '\t') {
            *p = '\0';
            if (count >= MOCK_FIELDS) return -1;
            fields[count++] = p + 1;
        }
        ++p;
    }
    return count;
}

static void strip_line_end(char *line, ssize_t *length) {
    while (*length > 0 &&
           (line[*length - 1] == '\n' || line[*length - 1] == '\r')) {
        line[--*length] = '\0';
    }
}

static int header_is_valid(char *line) {
    static const char *expected[MOCK_FIELDS] = {
        "mock_id",
        "result_kind",
        "substantive_effect",
        "evidence_status",
        "run_status",
        "response"
    };
    char *fields[MOCK_FIELDS];
    int count = split_tabs(line, fields);
    int i;
    if (count != MOCK_FIELDS) return 0;
    for (i = 0; i < MOCK_FIELDS; ++i) {
        if (strcmp(fields[i], expected[i]) != 0) return 0;
    }
    return 1;
}

static void usage(const char *program) {
    fprintf(stderr, "usage: %s MOCKS_TSV MOCK_ID\n", program);
}

int main(int argc, char **argv) {
    FILE *file;
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;

    if (argc != 3) {
        usage(argv[0]);
        return 2;
    }

    file = fopen(argv[1], "r");
    if (file == NULL) {
        fprintf(stderr, "cannot read mock table: %s\n", argv[1]);
        return 3;
    }

    length = getline(&line, &capacity, file);
    if (length < 0 || length > MOCK_LINE_MAX) {
        fprintf(stderr, "cannot read mock header\n");
        free(line);
        fclose(file);
        return 3;
    }
    strip_line_end(line, &length);
    if (!header_is_valid(line)) {
        fprintf(stderr, "invalid mock header\n");
        free(line);
        fclose(file);
        return 3;
    }

    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *fields[MOCK_FIELDS];
        int count;
        if (length > MOCK_LINE_MAX) {
            fprintf(stderr, "mock row too long\n");
            free(line);
            fclose(file);
            return 3;
        }
        strip_line_end(line, &length);
        if (length == 0) continue;
        count = split_tabs(line, fields);
        if (count != MOCK_FIELDS) {
            fprintf(stderr, "malformed mock row\n");
            free(line);
            fclose(file);
            return 3;
        }
        if (strcmp(fields[0], argv[2]) != 0) continue;

        if (strcmp(fields[4], "failed") == 0) {
            fprintf(stderr, "%s\n", fields[5]);
            free(line);
            fclose(file);
            return 70;
        }
        if (strcmp(fields[4], "complete") != 0) {
            fprintf(stderr, "unknown run status: %s\n", fields[4]);
            free(line);
            fclose(file);
            return 3;
        }

        printf("%s\n", fields[5]);
        free(line);
        fclose(file);
        return 0;
    }

    fprintf(stderr, "unknown mock id: %s\n", argv[2]);
    free(line);
    fclose(file);
    return 4;
}
