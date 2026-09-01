#define _POSIX_C_SOURCE 200809L

#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define PATH_CAP 4096

static const char pattern[] = "*.idric";
static const char language_attribute[] = "linguist-language";
static const char canonical_attribute[] = "linguist-language=Idris";

static int has_suffix(const char *name, const char *suffix) {
    size_t name_length = strlen(name);
    size_t suffix_length = strlen(suffix);
    return name_length >= suffix_length &&
           strcmp(name + name_length - suffix_length, suffix) == 0;
}

static int tree_has_idric(const char *path, int *found) {
    DIR *directory = opendir(path);
    struct dirent *entry;

    if (directory == NULL) return 0;
    while ((entry = readdir(directory)) != NULL) {
        char child[PATH_CAP];
        struct stat info;
        int written;

        if (strcmp(entry->d_name, ".") == 0 ||
            strcmp(entry->d_name, "..") == 0 ||
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
            if (!tree_has_idric(child, found)) {
                closedir(directory);
                return 0;
            }
            if (*found) {
                closedir(directory);
                return 1;
            }
        } else if (S_ISREG(info.st_mode) && has_suffix(entry->d_name, ".idric")) {
            *found = 1;
            closedir(directory);
            return 1;
        }
    }
    closedir(directory);
    return 1;
}

static int is_language_attribute(const char *attribute) {
    const char *candidate = attribute;
    size_t length = strlen(language_attribute);

    if (*candidate == '-' || *candidate == '!') ++candidate;
    return strncmp(candidate, language_attribute, length) == 0 &&
           (candidate[length] == '\0' || candidate[length] == '=');
}

static int canonical_gitattributes(const char *root) {
    char path[PATH_CAP];
    FILE *file;
    char *line = NULL;
    size_t capacity = 0;
    ssize_t length;
    int canonical_count = 0;
    int conflicting = 0;
    int written = snprintf(path, sizeof(path), "%s/.gitattributes", root);

    if (written < 0 || (size_t)written >= sizeof(path)) return -1;
    errno = 0;
    file = fopen(path, "rb");
    if (file == NULL) return errno == ENOENT ? 0 : -1;
    while ((length = getline(&line, &capacity, file)) >= 0) {
        char *copy;
        char *save = NULL;
        char *token;

        (void)length;
        copy = strdup(line);
        if (copy == NULL) {
            free(line);
            fclose(file);
            return -1;
        }
        token = strtok_r(copy, " \t\r\n", &save);
        if (token == NULL || token[0] == '#' || strcmp(token, pattern) != 0) {
            free(copy);
            continue;
        }
        while ((token = strtok_r(NULL, " \t\r\n", &save)) != NULL) {
            if (strcmp(token, canonical_attribute) == 0) {
                ++canonical_count;
            } else if (is_language_attribute(token)) {
                conflicting = 1;
            }
        }
        free(copy);
    }
    if (ferror(file)) {
        free(line);
        fclose(file);
        return -1;
    }
    free(line);
    fclose(file);
    return canonical_count == 1 && !conflicting;
}

int main(int argc, char **argv) {
    int found = 0;
    int canonical;

    if (argc != 2) {
        fprintf(stderr, "usage: %s ROOT\n", argv[0]);
        return 2;
    }
    if (!tree_has_idric(argv[1], &found)) {
        fprintf(stderr, "cannot inspect repository tree: %s\n", argv[1]);
        return 2;
    }
    if (!found) {
        puts("{\"kind\":\"idric-gitattributes\",\"status\":\"pass\",\"applicable\":false}");
        return 0;
    }
    canonical = canonical_gitattributes(argv[1]);
    if (canonical < 0) {
        fprintf(stderr, "cannot inspect root .gitattributes\n");
        return 2;
    }
    if (!canonical) {
        puts("{\"kind\":\"idric-gitattributes\",\"status\":\"fail\",\"applicable\":true,\"expected\":\"*.idric linguist-language=Idris\"}");
        return 1;
    }
    puts("{\"kind\":\"idric-gitattributes\",\"status\":\"pass\",\"applicable\":true}");
    return 0;
}
