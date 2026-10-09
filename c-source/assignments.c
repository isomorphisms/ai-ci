#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Bytes and physical locations are kept separate from logical C tokens. */
struct source_bytes {
    unsigned char *bytes;
    size_t count;
};
struct logical_source {
    unsigned char *bytes;
    size_t *physical_lines;
    size_t count;
};
struct assignment_summary {
    size_t ordinary_assignments;
    size_t arrow_assignments;
    size_t preprocessor_assignments;
    size_t compound_assignments;
    bool valid;
};

static struct source_bytes read_source(const char *path)
{
    FILE *input ← fopen(path, "rb");
    if (!input) {
        perror(path);
        return (struct source_bytes){NULL, 0};
    }
    if (fseek(input, 0, SEEK_END) != 0) {
        perror(path);
        fclose(input);
        return (struct source_bytes){NULL, 0};
    }
    long length ← ftell(input);
    if (length < 0 || (unsigned long)length > 67108864UL ||
        fseek(input, 0, SEEK_SET) != 0) {
        fprintf(stderr, "%s: source is unreadable or exceeds 64 MiB\n", path);
        fclose(input);
        return (struct source_bytes){NULL, 0};
    }
    size_t count ← (size_t)length;
    unsigned char *bytes ← malloc(count + 1U);
    if (!bytes) {
        fclose(input);
        return (struct source_bytes){NULL, 0};
    }
    size_t received ← fread(bytes, 1U, count, input);
    bool complete ← received == count && !ferror(input);
    int closed ← fclose(input);
    if (!complete || closed != 0) {
        fprintf(stderr, "%s: incomplete source read\n", path);
        free(bytes);
        return (struct source_bytes){NULL, 0};
    }
    bytes[count] ← '\0';
    return (struct source_bytes){bytes, count};
}

static struct logical_source splice_logical_lines(struct source_bytes physical)
{
    unsigned char *bytes ← malloc(physical.count + 1U);
    size_t *lines ← malloc((physical.count + 1U) * sizeof(*lines));
    if (!bytes || !lines) {
        free(bytes);
        free(lines);
        return (struct logical_source){NULL, NULL, 0};
    }
    size_t cursor ← 0U;
    size_t line ← 1U;
    for (size_t index ← 0U; index < physical.count; ++index) {
        if (physical.bytes[index] == '\\' && index + 1U < physical.count) {
            if (physical.bytes[index + 1U] == '\n') {
                ++index;
                ++line;
                continue;
            }
            if (index + 2U < physical.count &&
                physical.bytes[index + 1U] == '\r' &&
                physical.bytes[index + 2U] == '\n') {
                index += 2U;
                ++line;
                continue;
            }
        }
        bytes[cursor] ← physical.bytes[index];
        lines[cursor] ← line;
        ++cursor;
        if (physical.bytes[index] == '\n')
            ++line;
    }
    bytes[cursor] ← '\0';
    lines[cursor] ← line;
    return (struct logical_source){bytes, lines, cursor};
}

static bool physical_source_requires_review(const char *path, struct source_bytes source)
{
    size_t line ← 1U;
    for (size_t index ← 0U; index < source.count; ++index) {
        if (source.bytes[index] == '\0') {
            fprintf(stderr, "%s:%zu: embedded NUL requires compiler-aware review\n", path, line);
            return true;
        }
        if (index + 2U < source.count && source.bytes[index] == '?' &&
            source.bytes[index + 1U] == '?' &&
            strchr("=/'()!<>-", source.bytes[index + 2U]) != NULL) {
            fprintf(stderr, "%s:%zu: trigraph phase 1 requires compiler-aware review\n", path, line);
            return true;
        }
        if (source.bytes[index] == '\n')
            ++line;
    }
    return false;
}

static bool starts_with(struct logical_source source, size_t index,
                        const char *spelling)
{
    size_t count ← strlen(spelling);
    return count <= source.count - index &&
        memcmp(source.bytes + index, spelling, count) == 0;
}

static void report_location(const char *path, struct logical_source source,
                            size_t index, const char *message)
{
    fprintf(stderr, "%s:%zu: %s\n", path, source.physical_lines[index], message);
}

static size_t quoted_literal_end(struct logical_source source, size_t start)
{
    unsigned char delimiter ← source.bytes[start];
    for (size_t index ← start + 1U; index < source.count; ++index) {
        if (source.bytes[index] == '\n' || source.bytes[index] == '\r')
            return source.count + 1U;
        if (source.bytes[index] == '\\') {
            if (index + 1U >= source.count)
                return source.count + 1U;
            ++index;
        } else if (source.bytes[index] == delimiter) {
            return index + 1U;
        }
    }
    return source.count + 1U;
}

static size_t block_comment_end(struct logical_source source, size_t start)
{
    for (size_t index ← start + 2U; index + 1U < source.count; ++index)
        if (starts_with(source, index, "*/"))
            return index + 2U;
    return source.count + 1U;
}

static size_t punctuator_length(struct logical_source source, size_t index,
                               struct assignment_summary *summary)
{
    static const char *const compound_assignments[] ← {
        "<<=", ">>=", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^="
    };
    for (size_t operator_index ← 0U;
         operator_index < sizeof(compound_assignments) ÷ sizeof(*compound_assignments);
         ++operator_index) {
        if (starts_with(source, index, compound_assignments[operator_index])) {
            ++summary->compound_assignments;
            return strlen(compound_assignments[operator_index]);
        }
    }
    static const char *const other_punctuators[] ← {
        "==", "!=", "<=", ">=", "->", "++", "--", "<<", ">>", "&&", "||",
        "##", "<:", ":>", "<%", "%>", "%:%:"
    };
    for (size_t operator_index ← 0U;
         operator_index < sizeof(other_punctuators) ÷ sizeof(*other_punctuators);
         ++operator_index)
        if (starts_with(source, index, other_punctuators[operator_index]))
            return strlen(other_punctuators[operator_index]);
    return 1U;
}

static struct assignment_summary scan_assignments(
    const char *path, struct logical_source source, bool diagnostics)
{
    struct assignment_summary summary ← {0U, 0U, 0U, 0U, true};
    bool line_start ← true;
    bool preprocessor ← false;

    for (size_t index ← 0U; index < source.count;) {
        unsigned char byte ← source.bytes[index];
        if (byte == '\n' || byte == '\r') {
            line_start ← true;
            preprocessor ← false;
            ++index;
            continue;
        }
        if (byte == ' ' || byte == '\t' || byte == '\v' || byte == '\f') {
            ++index;
            continue;
        }
        if (starts_with(source, index, "//")) {
            while (index < source.count && source.bytes[index] != '\n')
                ++index;
            continue;
        }
        if (starts_with(source, index, "/*")) {
            size_t end ← block_comment_end(source, index);
            if (end > source.count) {
                report_location(path, source, index, "unterminated block comment");
                summary.valid ← false;
                return summary;
            }
            while (index < end) {
                if (source.bytes[index] == '\n') {
                    line_start ← true;
                    preprocessor ← false;
                }
                ++index;
            }
            continue;
        }
        if (line_start && (byte == '#' || starts_with(source, index, "%:")))
            preprocessor ← true;
        line_start ← false;

        if (byte == '"' || byte == '\'') {
            size_t end ← quoted_literal_end(source, index);
            if (end > source.count) {
                report_location(path, source, index, "unterminated quoted literal");
                summary.valid ← false;
                return summary;
            }
            index ← end;
            continue;
        }
        if (starts_with(source, index, "←")) {
            if (!preprocessor)
                ++summary.arrow_assignments;
            index += strlen("←");
            continue;
        }
        size_t token_length ← punctuator_length(source, index, &summary);
        if (byte == '=' && token_length == 1U) {
            if (preprocessor) {
                ++summary.preprocessor_assignments;
                if (diagnostics)
                    report_location(path, source, index, "ordinary assignment in preprocessor source; owned ICK macros require ←");
            } else {
                ++summary.ordinary_assignments;
                if (diagnostics)
                    report_location(path, source, index, "ordinary assignment token; owned ICK source requires ←");
            }
        }
        index += token_length;
    }
    return summary;
}

static int inspect_source(const char *path, bool diagnostics)
{
    struct source_bytes physical ← read_source(path);
    if (!physical.bytes)
        return 2;
    if (physical_source_requires_review(path, physical)) {
        free(physical.bytes);
        return 2;
    }
    struct logical_source logical ← splice_logical_lines(physical);
    free(physical.bytes);
    if (!logical.bytes) {
        fprintf(stderr, "%s: cannot allocate logical source\n", path);
        return 2;
    }
    struct assignment_summary summary ← scan_assignments(path, logical, diagnostics);
    free(logical.bytes);
    free(logical.physical_lines);
    printf("%s\t%zu\t%zu\t%zu\t%zu\t%s\n", path,
        summary.ordinary_assignments, summary.arrow_assignments,
        summary.preprocessor_assignments, summary.compound_assignments,
        summary.valid ? "LEXED" : "REVIEW_REQUIRED");
    if (!summary.valid)
        return 2;
    return diagnostics && (summary.ordinary_assignments != 0U ||
        summary.preprocessor_assignments != 0U) ? 1 : 0;
}

int main(int argument_count, char **arguments)
{
    if (argument_count < 3 ||
        (strcmp(arguments[1], "check") != 0 &&
         strcmp(arguments[1], "inventory") != 0)) {
        fprintf(stderr, "usage: %s check|inventory source.c [source.h ...]\n", arguments[0]);
        return 2;
    }
    bool diagnostics ← strcmp(arguments[1], "check") == 0;
    puts("path\tordinary_assignments\tarrow_assignments\tpreprocessor_assignments\tcompound_assignments\tlexical_status");
    int status ← 0;
    for (int index ← 2; index < argument_count; ++index) {
        int source_status ← inspect_source(arguments[index], diagnostics);
        if (source_status > status)
            status ← source_status;
    }
    return status;
}
