#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define AICI_PATH_MAX 4096
#define AICI_LINE_MAX (1024 * 1024)
#define AICI_FIELDS_MAX 16
#define AICI_CAPTURE_MAX ((size_t)512 * 1024 * 1024)

typedef struct {
    int assertions;
    int failures;
    int quiet;
    char first_code[128];
} VerifyResult;

typedef struct StringNode {
    char *value;
    struct StringNode *next;
} StringNode;

typedef struct ContractCoverage {
    char *path;
    int has_positive;
    StringNode *negative_codes;
    struct ContractCoverage *next;
} ContractCoverage;

typedef struct {
    int width;
    int height;
    double fps;
    double duration;
    int audio_streams;
    char codec[64];
    char pixel_format[64];
} VideoMetadata;

static int regular_file(const char *path) {
    struct stat info;
    return lstat(path, &info) == 0 && S_ISREG(info.st_mode);
}

static char *trim(char *text) {
    char *end;
    while (isspace((unsigned char)*text)) ++text;
    end = text + strlen(text);
    while (end > text && isspace((unsigned char)end[-1])) --end;
    *end = '\0';
    return text;
}

static int has_suffix(const char *name, const char *suffix) {
    size_t name_length = strlen(name);
    size_t suffix_length = strlen(suffix);
    return suffix_length <= name_length &&
           strcmp(name + name_length - suffix_length, suffix) == 0;
}

static int safe_relative_path(const char *path) {
    const char *component;
    const char *slash;
    if (path == NULL || *path == '\0' || *path == '/') return 0;
    component = path;
    while (1) {
        size_t length;
        slash = strchr(component, '/');
        length = slash == NULL ? strlen(component) : (size_t)(slash - component);
        if (length == 0 || (length == 1 && component[0] == '.') ||
            (length == 2 && component[0] == '.' && component[1] == '.')) {
            return 0;
        }
        if (slash == NULL) break;
        component = slash + 1;
    }
    return 1;
}

static int join_path(char *output, size_t size, const char *root,
                     const char *relative) {
    int written;
    if (!safe_relative_path(relative)) return 0;
    written = snprintf(output, size, "%s/%s", root, relative);
    return written >= 0 && (size_t)written < size;
}

static int split_tabs(char *line, char **fields, int maximum) {
    int count = 0;
    char *p = line;
    if (maximum <= 0) return 0;
    fields[count++] = p;
    while (*p != '\0') {
        if (*p == '\t') {
            *p = '\0';
            if (count >= maximum) return -1;
            fields[count++] = p + 1;
        }
        ++p;
    }
    return count;
}

static int parse_int(const char *text, int minimum, int maximum, int *value) {
    char *end = NULL;
    long parsed;
    errno = 0;
    parsed = strtol(text, &end, 10);
    if (errno != 0 || end == text || *end != '\0' ||
        parsed < minimum || parsed > maximum) {
        return 0;
    }
    *value = (int)parsed;
    return 1;
}

static int parse_double_value(const char *text, double minimum,
                              double maximum, double *value) {
    char *end = NULL;
    double parsed;
    errno = 0;
    parsed = strtod(text, &end);
    if (errno != 0 || end == text || *end != '\0' || !isfinite(parsed) ||
        parsed < minimum || parsed > maximum) {
        return 0;
    }
    *value = parsed;
    return 1;
}

static int valid_code(const char *code) {
    const unsigned char *p = (const unsigned char *)code;
    if (*p == '\0') return 0;
    while (*p != '\0') {
        if (!(isupper(*p) || isdigit(*p) || *p == '-')) return 0;
        ++p;
    }
    return 1;
}

static void json_string(const char *text) {
    const unsigned char *p = (const unsigned char *)text;
    putchar('"');
    while (*p != '\0') {
        switch (*p) {
            case '"': fputs("\\\"", stdout); break;
            case '\\': fputs("\\\\", stdout); break;
            case '\n': fputs("\\n", stdout); break;
            case '\r': fputs("\\r", stdout); break;
            case '\t': fputs("\\t", stdout); break;
            default:
                if (*p < 0x20) {
                    printf("\\u%04x", (unsigned int)*p);
                } else {
                    putchar((int)*p);
                }
        }
        ++p;
    }
    putchar('"');
}

static void emit_assertion(const char *status, const char *code,
                           const char *operation, const char *detail) {
    fputs("{\"kind\":\"video-assertion\",\"status\":", stdout);
    json_string(status);
    fputs(",\"code\":", stdout);
    json_string(code);
    fputs(",\"operation\":", stdout);
    json_string(operation);
    fputs(",\"detail\":", stdout);
    json_string(detail);
    fputs("}\n", stdout);
}

static void record_result(VerifyResult *result, int ok, const char *code,
                          const char *operation, const char *detail) {
    ++result->assertions;
    if (!ok) {
        ++result->failures;
        if (result->first_code[0] == '\0') {
            snprintf(result->first_code, sizeof(result->first_code), "%s", code);
        }
    }
    if (!result->quiet) {
        emit_assertion(ok ? "pass" : "fail", code, operation, detail);
    }
}

static int wait_success(pid_t child) {
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) return 0;
    }
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

static int run_status(char *const argv[]) {
    pid_t child = fork();
    if (child < 0) return 0;
    if (child == 0) {
        FILE *null_file = fopen("/dev/null", "w");
        if (null_file == NULL) _exit(126);
        if (dup2(fileno(null_file), STDOUT_FILENO) < 0 ||
            dup2(fileno(null_file), STDERR_FILENO) < 0) {
            _exit(126);
        }
        fclose(null_file);
        execvp(argv[0], argv);
        _exit(127);
    }
    return wait_success(child);
}

static int capture_command(char *const argv[], size_t maximum,
                           unsigned char **output, size_t *output_length) {
    int descriptors[2];
    pid_t child;
    unsigned char *buffer = NULL;
    size_t length = 0;
    size_t capacity = 0;
    int overflow = 0;
    int read_error = 0;
    if (pipe(descriptors) != 0) return 0;
    child = fork();
    if (child < 0) {
        close(descriptors[0]);
        close(descriptors[1]);
        return 0;
    }
    if (child == 0) {
        FILE *null_file;
        close(descriptors[0]);
        null_file = fopen("/dev/null", "w");
        if (null_file == NULL ||
            dup2(descriptors[1], STDOUT_FILENO) < 0 ||
            dup2(fileno(null_file), STDERR_FILENO) < 0) {
            _exit(126);
        }
        close(descriptors[1]);
        fclose(null_file);
        execvp(argv[0], argv);
        _exit(127);
    }
    close(descriptors[1]);
    while (1) {
        unsigned char chunk[8192];
        ssize_t count = read(descriptors[0], chunk, sizeof(chunk));
        if (count == 0) break;
        if (count < 0) {
            if (errno == EINTR) continue;
            read_error = 1;
            break;
        }
        if (!overflow && length + (size_t)count <= maximum) {
            size_t needed = length + (size_t)count + 1;
            if (needed > capacity) {
                size_t grown = capacity == 0 ? 16384 : capacity;
                unsigned char *replacement;
                while (grown < needed && grown < maximum + 1) {
                    size_t next = grown > maximum / 2 ? maximum + 1 : grown * 2;
                    if (next <= grown) {
                        next = maximum + 1;
                    }
                    grown = next;
                }
                replacement = realloc(buffer, grown);
                if (replacement == NULL) {
                    overflow = 1;
                } else {
                    buffer = replacement;
                    capacity = grown;
                }
            }
            if (!overflow) {
                memcpy(buffer + length, chunk, (size_t)count);
                length += (size_t)count;
            }
        } else {
            overflow = 1;
        }
    }
    close(descriptors[0]);
    if (!wait_success(child) || overflow || read_error) {
        free(buffer);
        return 0;
    }
    if (buffer == NULL) {
        buffer = malloc(1);
        if (buffer == NULL) return 0;
    }
    buffer[length] = '\0';
    *output = buffer;
    *output_length = length;
    return 1;
}

static int parse_ratio(const char *text, double *value) {
    char *slash;
    char *copy = strdup(text);
    double numerator;
    double denominator;
    int ok = 0;
    if (copy == NULL) return 0;
    slash = strchr(copy, '/');
    if (slash == NULL) {
        ok = parse_double_value(copy, 0.000001, 1000000.0, value);
    } else {
        *slash = '\0';
        if (parse_double_value(copy, 0.0, 1000000000.0, &numerator) &&
            parse_double_value(slash + 1, 0.000001, 1000000000.0, &denominator)) {
            *value = numerator / denominator;
            ok = isfinite(*value) && *value > 0.0;
        }
    }
    free(copy);
    return ok;
}

static int count_nonempty_lines(char *text) {
    int count = 0;
    char *save = NULL;
    char *line;
    for (line = strtok_r(text, "\r\n", &save); line != NULL;
         line = strtok_r(NULL, "\r\n", &save)) {
        if (*trim(line) != '\0') ++count;
    }
    return count;
}

static int probe_metadata(const char *path, VideoMetadata *metadata) {
    char *argv[] = {
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries",
        "stream=codec_name,width,height,avg_frame_rate,pix_fmt:format=duration",
        "-of", "default=noprint_wrappers=1", (char *)path, NULL
    };
    char *audio_argv[] = {
        "ffprobe", "-v", "error", "-select_streams", "a",
        "-show_entries", "stream=index", "-of", "csv=p=0",
        (char *)path, NULL
    };
    unsigned char *raw = NULL;
    unsigned char *audio_raw = NULL;
    size_t length = 0;
    size_t audio_length = 0;
    char *save = NULL;
    char *line;
    int have_width = 0;
    int have_height = 0;
    int have_fps = 0;
    int have_duration = 0;
    int have_codec = 0;
    int have_pixel_format = 0;
    memset(metadata, 0, sizeof(*metadata));
    if (!regular_file(path) ||
        !capture_command(argv, AICI_LINE_MAX, &raw, &length) || length == 0) {
        free(raw);
        return 0;
    }
    for (line = strtok_r((char *)raw, "\r\n", &save); line != NULL;
         line = strtok_r(NULL, "\r\n", &save)) {
        char *equals = strchr(line, '=');
        const char *key;
        const char *value;
        if (equals == NULL) continue;
        *equals = '\0';
        key = trim(line);
        value = trim(equals + 1);
        if (strcmp(key, "width") == 0) {
            have_width = parse_int(value, 1, 100000, &metadata->width);
        } else if (strcmp(key, "height") == 0) {
            have_height = parse_int(value, 1, 100000, &metadata->height);
        } else if (strcmp(key, "avg_frame_rate") == 0) {
            have_fps = parse_ratio(value, &metadata->fps);
        } else if (strcmp(key, "duration") == 0) {
            have_duration = parse_double_value(value, 0.000001, 1000000000.0,
                                               &metadata->duration);
        } else if (strcmp(key, "codec_name") == 0 && *value != '\0') {
            have_codec = snprintf(metadata->codec, sizeof(metadata->codec),
                                  "%s", value) > 0;
        } else if (strcmp(key, "pix_fmt") == 0 && *value != '\0') {
            have_pixel_format =
                snprintf(metadata->pixel_format, sizeof(metadata->pixel_format),
                         "%s", value) > 0;
        }
    }
    free(raw);
    if (!(have_width && have_height && have_fps && have_duration &&
          have_codec && have_pixel_format)) {
        return 0;
    }
    if (!capture_command(audio_argv, AICI_LINE_MAX, &audio_raw, &audio_length)) {
        free(audio_raw);
        return 0;
    }
    metadata->audio_streams = count_nonempty_lines((char *)audio_raw);
    free(audio_raw);
    return 1;
}

static int decode_video(const char *path) {
    char *argv[] = {
        "ffmpeg", "-nostdin", "-v", "error", "-xerror", "-i", (char *)path,
        "-map", "0:v?", "-map", "0:a?", "-f", "null", "-", NULL
    };
    return regular_file(path) && run_status(argv);
}

static int decode_frame(const char *path, double timestamp,
                        int width, int height, unsigned char **frame) {
    char time_text[64];
    char *argv[] = {
        "ffmpeg", "-nostdin", "-v", "error", "-i", (char *)path,
        "-ss", time_text,
        "-frames:v", "1", "-f", "rawvideo", "-pix_fmt", "rgb24", "-", NULL
    };
    unsigned char *raw = NULL;
    size_t length = 0;
    size_t pixels;
    if (width <= 0 || height <= 0 ||
        (size_t)width > AICI_CAPTURE_MAX / (size_t)height / 3) {
        return 0;
    }
    pixels = (size_t)width * (size_t)height * 3;
    snprintf(time_text, sizeof(time_text), "%.9f", timestamp);
    if (!capture_command(argv, pixels, &raw, &length) || length != pixels) {
        free(raw);
        return 0;
    }
    *frame = raw;
    return 1;
}

static int frame_region_mae(const char *path, double first_time,
                            double second_time, int x, int y, int region_width,
                            int region_height, double *mae) {
    VideoMetadata metadata;
    unsigned char *first = NULL;
    unsigned char *second = NULL;
    long double total = 0.0;
    size_t samples;
    int row;
    int column;
    int channel;
    if (!probe_metadata(path, &metadata) || x < 0 || y < 0 ||
        region_width < 1 || region_height < 1 ||
        x > metadata.width - region_width || y > metadata.height - region_height) {
        return 0;
    }
    if (!decode_frame(path, first_time, metadata.width, metadata.height, &first) ||
        !decode_frame(path, second_time, metadata.width, metadata.height, &second)) {
        free(first);
        free(second);
        return 0;
    }
    for (row = y; row < y + region_height; ++row) {
        for (column = x; column < x + region_width; ++column) {
            size_t base = ((size_t)row * (size_t)metadata.width +
                           (size_t)column) * 3;
            for (channel = 0; channel < 3; ++channel) {
                total += abs((int)first[base + (size_t)channel] -
                             (int)second[base + (size_t)channel]);
            }
        }
    }
    samples = (size_t)region_width * (size_t)region_height * 3;
    *mae = (double)(total / (long double)samples);
    free(first);
    free(second);
    return 1;
}

static int verify_contract(const char *contract_path, const char *root,
                           int quiet, VerifyResult *result) {
    FILE *contract = fopen(contract_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int line_number = 0;
    memset(result, 0, sizeof(*result));
    result->quiet = quiet;
    if (contract == NULL || !regular_file(contract_path)) {
        if (contract != NULL) fclose(contract);
        record_result(result, 0, "AICI-VIDEO-CONTRACT-UNREADABLE", "contract",
                      contract_path);
        return 0;
    }
    while ((length = getline(&line, &capacity, contract)) >= 0) {
        char *fields[AICI_FIELDS_MAX];
        char *content;
        const char *operation;
        const char *code;
        char media_path[AICI_PATH_MAX];
        char detail[AICI_PATH_MAX];
        int count;
        int malformed = 0;
        int ok = 0;
        ++line_number;
        if (length > AICI_LINE_MAX) {
            record_result(result, 0, "AICI-VIDEO-CONTRACT-LINE-LONG",
                          "contract", contract_path);
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, AICI_FIELDS_MAX);
        if (count < 3) {
            record_result(result, 0, "AICI-VIDEO-CONTRACT-MALFORMED",
                          "contract", contract_path);
            continue;
        }
        operation = fields[0];
        code = fields[1];
        if (!valid_code(code)) {
            record_result(result, 0, "AICI-VIDEO-CONTRACT-CODE", "contract",
                          contract_path);
            continue;
        }
        malformed = !join_path(media_path, sizeof(media_path), root, fields[2]);
        if (strcmp(operation, "video_decode") == 0 && count == 3) {
            if (!malformed) ok = decode_video(media_path);
            snprintf(detail, sizeof(detail), "%s", fields[2]);
        } else if (strcmp(operation, "video_dimensions") == 0 && count == 5) {
            VideoMetadata metadata;
            int width = 0;
            int height = 0;
            malformed = malformed || !parse_int(fields[3], 1, 100000, &width) ||
                        !parse_int(fields[4], 1, 100000, &height);
            memset(&metadata, 0, sizeof(metadata));
            if (!malformed && probe_metadata(media_path, &metadata)) {
                ok = metadata.width == width && metadata.height == height;
            }
            snprintf(detail, sizeof(detail), "%s expected=%sx%s actual=%dx%d",
                     fields[2], fields[3], fields[4], metadata.width, metadata.height);
        } else if (strcmp(operation, "video_duration") == 0 && count == 5) {
            VideoMetadata metadata;
            double minimum = 0.0;
            double maximum = 0.0;
            malformed = malformed ||
                        !parse_double_value(fields[3], 0.0, 1000000000.0, &minimum) ||
                        !parse_double_value(fields[4], 0.0, 1000000000.0, &maximum) ||
                        maximum < minimum;
            memset(&metadata, 0, sizeof(metadata));
            if (!malformed && probe_metadata(media_path, &metadata)) {
                ok = metadata.duration >= minimum && metadata.duration <= maximum;
            }
            snprintf(detail, sizeof(detail),
                     "%s expected=[%s,%s] actual=%.6f", fields[2], fields[3],
                     fields[4], metadata.duration);
        } else if (strcmp(operation, "video_fps") == 0 && count == 5) {
            VideoMetadata metadata;
            double expected = 0.0;
            double tolerance = 0.0;
            malformed = malformed ||
                        !parse_double_value(fields[3], 0.000001, 1000000.0, &expected) ||
                        !parse_double_value(fields[4], 0.0, 1000000.0, &tolerance);
            memset(&metadata, 0, sizeof(metadata));
            if (!malformed && probe_metadata(media_path, &metadata)) {
                ok = fabs(metadata.fps - expected) <= tolerance;
            }
            snprintf(detail, sizeof(detail),
                     "%s expected=%s+-%s actual=%.6f", fields[2], fields[3],
                     fields[4], metadata.fps);
        } else if (strcmp(operation, "video_audio") == 0 && count == 4) {
            VideoMetadata metadata;
            int expect_audio = strcmp(fields[3], "present") == 0;
            malformed = malformed ||
                        (!expect_audio && strcmp(fields[3], "absent") != 0);
            memset(&metadata, 0, sizeof(metadata));
            if (!malformed && probe_metadata(media_path, &metadata)) {
                ok = expect_audio ? metadata.audio_streams > 0 :
                                    metadata.audio_streams == 0;
            }
            snprintf(detail, sizeof(detail), "%s expected=%s actualStreams=%d",
                     fields[2], fields[3], metadata.audio_streams);
        } else if (strcmp(operation, "video_encoding") == 0 && count == 5) {
            VideoMetadata metadata;
            malformed = malformed || fields[3][0] == '\0' || fields[4][0] == '\0';
            memset(&metadata, 0, sizeof(metadata));
            if (!malformed && probe_metadata(media_path, &metadata)) {
                ok = strcmp(metadata.codec, fields[3]) == 0 &&
                     strcmp(metadata.pixel_format, fields[4]) == 0;
            }
            snprintf(detail, sizeof(detail),
                     "%s expected=%s/%s actual=%s/%s", fields[2], fields[3],
                     fields[4], metadata.codec, metadata.pixel_format);
        } else if (strcmp(operation, "video_frame_mae") == 0 && count == 11) {
            double first_time = 0.0;
            double second_time = 0.0;
            double minimum = 0.0;
            double maximum = 0.0;
            double actual = -1.0;
            int x = 0;
            int y = 0;
            int width = 0;
            int height = 0;
            malformed = malformed ||
                        !parse_double_value(fields[3], 0.0, 1000000000.0, &first_time) ||
                        !parse_double_value(fields[4], 0.0, 1000000000.0, &second_time) ||
                        !parse_int(fields[5], 0, 100000, &x) ||
                        !parse_int(fields[6], 0, 100000, &y) ||
                        !parse_int(fields[7], 1, 100000, &width) ||
                        !parse_int(fields[8], 1, 100000, &height) ||
                        !parse_double_value(fields[9], 0.0, 255.0, &minimum) ||
                        !parse_double_value(fields[10], 0.0, 255.0, &maximum) ||
                        maximum < minimum;
            if (!malformed && frame_region_mae(media_path, first_time, second_time,
                                                x, y, width, height, &actual)) {
                ok = actual >= minimum && actual <= maximum;
            }
            snprintf(detail, sizeof(detail),
                     "%s times=%s,%s region=%s,%s,%s,%s expected=[%s,%s] actual=%.6f",
                     fields[2], fields[3], fields[4], fields[5], fields[6],
                     fields[7], fields[8], fields[9], fields[10], actual);
        } else {
            malformed = 1;
            snprintf(detail, sizeof(detail), "%s:%d", contract_path, line_number);
        }
        if (malformed) {
            record_result(result, 0, "AICI-VIDEO-CONTRACT-MALFORMED",
                          operation, detail);
        } else {
            record_result(result, ok, code, operation, detail);
        }
    }
    free(line);
    fclose(contract);
    if (result->assertions == 0) {
        record_result(result, 0, "AICI-VIDEO-NO-ASSERTIONS", "contract",
                      contract_path);
    }
    if (!quiet) {
        printf("{\"kind\":\"video-summary\",\"status\":\"%s\",\"assertions\":%d,\"failures\":%d}\n",
               result->failures == 0 ? "pass" : "fail",
               result->assertions, result->failures);
    }
    return result->failures == 0;
}

static int string_set_contains(const StringNode *set, const char *value) {
    while (set != NULL) {
        if (strcmp(set->value, value) == 0) return 1;
        set = set->next;
    }
    return 0;
}

static int string_set_add(StringNode **set, const char *value) {
    StringNode *node;
    if (string_set_contains(*set, value)) return 1;
    node = malloc(sizeof(*node));
    if (node == NULL) return 0;
    node->value = strdup(value);
    if (node->value == NULL) {
        free(node);
        return 0;
    }
    node->next = *set;
    *set = node;
    return 1;
}

static void string_set_free(StringNode *set) {
    while (set != NULL) {
        StringNode *next = set->next;
        free(set->value);
        free(set);
        set = next;
    }
}

static ContractCoverage *coverage_find(ContractCoverage *coverage,
                                       const char *path) {
    while (coverage != NULL) {
        if (strcmp(coverage->path, path) == 0) return coverage;
        coverage = coverage->next;
    }
    return NULL;
}

static ContractCoverage *coverage_add(ContractCoverage **coverage,
                                      const char *path) {
    ContractCoverage *item = coverage_find(*coverage, path);
    if (item != NULL) return item;
    item = calloc(1, sizeof(*item));
    if (item == NULL) return NULL;
    item->path = strdup(path);
    if (item->path == NULL) {
        free(item);
        return NULL;
    }
    item->next = *coverage;
    *coverage = item;
    return item;
}

static void coverage_free(ContractCoverage *coverage) {
    while (coverage != NULL) {
        ContractCoverage *next = coverage->next;
        free(coverage->path);
        string_set_free(coverage->negative_codes);
        free(coverage);
        coverage = next;
    }
}

static int register_contract_files(const char *path, ContractCoverage **coverage,
                                   int *files_seen) {
    DIR *directory = opendir(path);
    struct dirent *entry;
    if (directory == NULL) return 0;
    while ((entry = readdir(directory)) != NULL) {
        char child[AICI_PATH_MAX];
        struct stat info;
        int written;
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0 ||
            strcmp(entry->d_name, ".git") == 0) {
            continue;
        }
        written = snprintf(child, sizeof(child), "%s/%s", path, entry->d_name);
        if (written < 0 || (size_t)written >= sizeof(child) ||
            lstat(child, &info) != 0) {
            closedir(directory);
            return 0;
        }
        if (S_ISDIR(info.st_mode)) {
            if (!register_contract_files(child, coverage, files_seen)) {
                closedir(directory);
                return 0;
            }
        } else if (has_suffix(entry->d_name, ".contract.tsv")) {
            if (!S_ISREG(info.st_mode) || coverage_add(coverage, child) == NULL) {
                closedir(directory);
                return 0;
            }
            ++*files_seen;
        }
    }
    closedir(directory);
    return 1;
}

static void emit_coverage_result(const char *status, const char *contract,
                                 const char *code, const char *detail) {
    fputs("{\"kind\":\"video-self-test-coverage\",\"status\":", stdout);
    json_string(status);
    fputs(",\"contract\":", stdout);
    json_string(contract);
    fputs(",\"code\":", stdout);
    json_string(code);
    fputs(",\"detail\":", stdout);
    json_string(detail);
    fputs("}\n", stdout);
}

static int audit_contract_coverage(ContractCoverage *coverage) {
    ContractCoverage *item;
    int failures = 0;
    for (item = coverage; item != NULL; item = item->next) {
        FILE *contract;
        char *line = NULL;
        size_t capacity = 0;
        ssize_t length;
        StringNode *seen_codes = NULL;
        if (!item->has_positive) {
            ++failures;
            emit_coverage_result("fail", item->path, "", "missing positive fixture");
        } else {
            emit_coverage_result("pass", item->path, "", "positive fixture");
        }
        contract = fopen(item->path, "r");
        if (contract == NULL || !regular_file(item->path)) {
            if (contract != NULL) fclose(contract);
            ++failures;
            emit_coverage_result("fail", item->path, "", "contract unreadable");
            continue;
        }
        while ((length = getline(&line, &capacity, contract)) >= 0) {
            char *fields[AICI_FIELDS_MAX];
            char *content;
            int count;
            const char *code;
            if (length > AICI_LINE_MAX) {
                ++failures;
                emit_coverage_result("fail", item->path, "", "contract line too long");
                continue;
            }
            content = trim(line);
            if (*content == '\0' || *content == '#') continue;
            count = split_tabs(content, fields, AICI_FIELDS_MAX);
            if (count < 2) continue;
            code = fields[1];
            if (string_set_contains(seen_codes, code)) {
                ++failures;
                emit_coverage_result("fail", item->path, code,
                                     "diagnostic code is not unique");
            } else if (!string_set_add(&seen_codes, code)) {
                ++failures;
                emit_coverage_result("fail", item->path, code,
                                     "coverage allocation failed");
            } else if (!string_set_contains(item->negative_codes, code)) {
                ++failures;
                emit_coverage_result("fail", item->path, code,
                                     "missing targeted bad fixture");
            } else {
                emit_coverage_result("pass", item->path, code,
                                     "targeted bad fixture");
            }
        }
        free(line);
        fclose(contract);
        string_set_free(seen_codes);
    }
    return failures;
}

static int run_self_test(const char *cases_path, const char *fixtures_root) {
    FILE *cases = fopen(cases_path, "r");
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int total = 0;
    int failures = 0;
    int contract_files = 0;
    ContractCoverage *coverage = NULL;
    if (cases == NULL) {
        fprintf(stderr, "cannot read video self-test cases: %s\n", cases_path);
        return 0;
    }
    if (!register_contract_files("video/contracts", &coverage, &contract_files) ||
        contract_files == 0) {
        ++failures;
    }
    while ((length = getline(&line, &capacity, cases)) >= 0) {
        char *fields[4];
        char *content;
        char fixture[AICI_PATH_MAX];
        int count;
        int expected_pass;
        int actual_pass;
        int case_ok;
        ContractCoverage *coverage_item;
        VerifyResult result;
        if (length > AICI_LINE_MAX) {
            ++failures;
            continue;
        }
        content = trim(line);
        if (*content == '\0' || *content == '#') continue;
        count = split_tabs(content, fields, 4);
        if (count != 4 ||
            (strcmp(fields[0], "pass") != 0 && strcmp(fields[0], "fail") != 0) ||
            (strcmp(fields[0], "pass") == 0 && strcmp(fields[3], "-") != 0) ||
            (strcmp(fields[0], "fail") == 0 && !valid_code(fields[3])) ||
            !join_path(fixture, sizeof(fixture), fixtures_root, fields[2])) {
            ++failures;
            continue;
        }
        ++total;
        expected_pass = strcmp(fields[0], "pass") == 0;
        coverage_item = coverage_find(coverage, fields[1]);
        actual_pass = verify_contract(fields[1], fixture, 1, &result);
        case_ok = coverage_item != NULL &&
                  (expected_pass ? actual_pass :
                   (!actual_pass && strcmp(result.first_code, fields[3]) == 0));
        if (!case_ok) {
            ++failures;
        } else if (expected_pass) {
            coverage_item->has_positive = 1;
        } else if (!string_set_add(&coverage_item->negative_codes, fields[3])) {
            ++failures;
            case_ok = 0;
        }
        fputs("{\"kind\":\"video-self-test\",\"status\":", stdout);
        json_string(case_ok ? "pass" : "fail");
        fputs(",\"contract\":", stdout);
        json_string(fields[1]);
        fputs(",\"fixture\":", stdout);
        json_string(fields[2]);
        fputs(",\"expected\":", stdout);
        json_string(fields[0]);
        fputs(",\"observedCode\":", stdout);
        json_string(result.first_code);
        fputs("}\n", stdout);
    }
    free(line);
    fclose(cases);
    if (total == 0) ++failures;
    failures += audit_contract_coverage(coverage);
    coverage_free(coverage);
    printf("{\"kind\":\"video-self-test-summary\",\"status\":\"%s\",\"cases\":%d,\"failures\":%d}\n",
           failures == 0 ? "pass" : "fail", total, failures);
    return failures == 0;
}

static void usage(const char *program) {
    fprintf(stderr,
            "usage:\n"
            "  %s verify CONTRACT ROOT\n"
            "  %s self-test CASES FIXTURES_ROOT\n",
            program, program);
}

int main(int argc, char **argv) {
    VerifyResult result;
    signal(SIGPIPE, SIG_IGN);
    if (argc == 4 && strcmp(argv[1], "verify") == 0) {
        return verify_contract(argv[2], argv[3], 0, &result) ? 0 : 1;
    }
    if (argc == 4 && strcmp(argv[1], "self-test") == 0) {
        return run_self_test(argv[2], argv[3]) ? 0 : 1;
    }
    usage(argv[0]);
    return 2;
}
