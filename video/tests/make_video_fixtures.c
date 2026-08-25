#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define PATH_LIMIT 4096

enum Pattern {
    PATTERN_GOOD,
    PATTERN_CONSTANT,
    PATTERN_MOVING_END
};

static int wait_success(pid_t child) {
    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) return 0;
    }
    return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

static int make_directory(const char *path) {
    return mkdir(path, 0777) == 0 || errno == EEXIST;
}

static int fixture_path(char *output, size_t size, const char *root,
                        const char *fixture, const char *file) {
    int written = snprintf(output, size, "%s/%s/%s", root, fixture, file);
    return written >= 0 && (size_t)written < size;
}

static int make_fixture_directory(const char *root, const char *fixture) {
    char path[PATH_LIMIT];
    int written = snprintf(path, sizeof(path), "%s/%s", root, fixture);
    return written >= 0 && (size_t)written < sizeof(path) && make_directory(path);
}

static int write_all(int descriptor, const unsigned char *data, size_t length) {
    size_t offset = 0;
    while (offset < length) {
        ssize_t written = write(descriptor, data + offset, length - offset);
        if (written < 0) {
            if (errno == EINTR) continue;
            return 0;
        }
        offset += (size_t)written;
    }
    return 1;
}

static void fill_frame(unsigned char *frame, int width, int height, int index,
                       int frames, enum Pattern pattern) {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    size_t pixels = (size_t)width * (size_t)height;
    size_t pixel;
    if (pattern == PATTERN_CONSTANT) {
        red = 40;
        green = 180;
        blue = 220;
    } else if (index < frames / 2) {
        red = (unsigned char)(20 + (index * 17) % 180);
        green = 30;
        blue = 60;
    } else if (pattern == PATTERN_GOOD) {
        red = 40;
        green = 180;
        blue = 220;
    } else {
        red = (unsigned char)(30 + (index * 19) % 190);
        green = 180;
        blue = 220;
    }
    for (pixel = 0; pixel < pixels; ++pixel) {
        frame[pixel * 3] = red;
        frame[pixel * 3 + 1] = green;
        frame[pixel * 3 + 2] = blue;
    }
}

static int encode_video(const char *path, int width, int height, int fps,
                        int frames, enum Pattern pattern,
                        const char *pixel_format) {
    int descriptors[2];
    pid_t child;
    char size_text[64];
    char fps_text[32];
    unsigned char *frame;
    size_t frame_size;
    int index;
    int writes_ok = 1;
    if (pipe(descriptors) != 0) return 0;
    snprintf(size_text, sizeof(size_text), "%dx%d", width, height);
    snprintf(fps_text, sizeof(fps_text), "%d", fps);
    child = fork();
    if (child < 0) {
        close(descriptors[0]);
        close(descriptors[1]);
        return 0;
    }
    if (child == 0) {
        char *argv[] = {
            "ffmpeg", "-nostdin", "-y", "-v", "error", "-f", "rawvideo",
            "-pixel_format", "rgb24", "-video_size", size_text,
            "-framerate", fps_text, "-i", "-", "-an", "-c:v", "libx264",
            "-preset", "ultrafast", "-crf", "18", "-pix_fmt",
            (char *)pixel_format, "-movflags", "+faststart", (char *)path, NULL
        };
        close(descriptors[1]);
        if (dup2(descriptors[0], STDIN_FILENO) < 0) _exit(126);
        close(descriptors[0]);
        execvp(argv[0], argv);
        _exit(127);
    }
    close(descriptors[0]);
    frame_size = (size_t)width * (size_t)height * 3;
    frame = malloc(frame_size);
    if (frame == NULL) {
        close(descriptors[1]);
        return wait_success(child) && 0;
    }
    for (index = 0; index < frames; ++index) {
        fill_frame(frame, width, height, index, frames, pattern);
        if (!write_all(descriptors[1], frame, frame_size)) {
            writes_ok = 0;
            break;
        }
    }
    free(frame);
    close(descriptors[1]);
    return wait_success(child) && writes_ok;
}

static int add_audio(const char *video_path, const char *output_path) {
    pid_t child = fork();
    if (child < 0) return 0;
    if (child == 0) {
        char *argv[] = {
            "ffmpeg", "-nostdin", "-y", "-v", "error", "-i", (char *)video_path,
            "-f", "lavfi", "-i",
            "sine=frequency=1000:sample_rate=8000:duration=2",
            "-map", "0:v:0", "-map", "1:a:0", "-c:v", "copy",
            "-c:a", "aac", "-shortest", (char *)output_path, NULL
        };
        execvp(argv[0], argv);
        _exit(127);
    }
    return wait_success(child);
}

static int write_corrupt_file(const char *path) {
    static const unsigned char bytes[] = {
        0x00, 0x00, 0x00, 0x18, 'f', 't', 'y', 'p', 'b', 'r', 'o', 'k',
        'e', 'n'
    };
    FILE *file = fopen(path, "wb");
    if (file == NULL) return 0;
    if (fwrite(bytes, 1, sizeof(bytes), file) != sizeof(bytes)) {
        fclose(file);
        return 0;
    }
    return fclose(file) == 0;
}

static int generate(const char *root) {
    static const char *fixtures[] = {
        "good", "bad-decode", "bad-dimensions", "bad-duration", "bad-fps",
        "bad-audio", "bad-encoding", "bad-early-change", "bad-final-hold"
    };
    char path[PATH_LIMIT];
    char temporary[PATH_LIMIT];
    size_t index;
    if (!make_directory(root)) return 0;
    for (index = 0; index < sizeof(fixtures) / sizeof(fixtures[0]); ++index) {
        if (!make_fixture_directory(root, fixtures[index])) return 0;
    }
    if (!fixture_path(path, sizeof(path), root, "good", "short.mp4") ||
        !encode_video(path, 64, 128, 10, 20, PATTERN_GOOD, "yuv420p")) return 0;
    if (!fixture_path(path, sizeof(path), root, "bad-decode", "short.mp4") ||
        !write_corrupt_file(path)) return 0;
    if (!fixture_path(path, sizeof(path), root, "bad-dimensions", "short.mp4") ||
        !encode_video(path, 128, 128, 10, 20, PATTERN_GOOD, "yuv420p")) return 0;
    if (!fixture_path(path, sizeof(path), root, "bad-duration", "short.mp4") ||
        !encode_video(path, 64, 128, 10, 22, PATTERN_GOOD, "yuv420p")) return 0;
    if (!fixture_path(path, sizeof(path), root, "bad-fps", "short.mp4") ||
        !encode_video(path, 64, 128, 12, 24, PATTERN_GOOD, "yuv420p")) return 0;
    if (!fixture_path(temporary, sizeof(temporary), root, "bad-audio", "video-only.mp4") ||
        !fixture_path(path, sizeof(path), root, "bad-audio", "short.mp4") ||
        !encode_video(temporary, 64, 128, 10, 20, PATTERN_GOOD, "yuv420p") ||
        !add_audio(temporary, path)) return 0;
    if (unlink(temporary) != 0) return 0;
    if (!fixture_path(path, sizeof(path), root, "bad-encoding", "short.mp4") ||
        !encode_video(path, 64, 128, 10, 20, PATTERN_GOOD, "yuv444p")) return 0;
    if (!fixture_path(path, sizeof(path), root, "bad-early-change", "short.mp4") ||
        !encode_video(path, 64, 128, 10, 20, PATTERN_CONSTANT, "yuv420p")) return 0;
    if (!fixture_path(path, sizeof(path), root, "bad-final-hold", "short.mp4") ||
        !encode_video(path, 64, 128, 10, 20, PATTERN_MOVING_END, "yuv420p")) return 0;
    return 1;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "usage: %s FIXTURES_ROOT\n", argv[0]);
        return 2;
    }
    if (!generate(argv[1])) {
        fprintf(stderr, "could not generate video fixtures under %s\n", argv[1]);
        return 1;
    }
    printf("generated video fixtures under %s\n", argv[1]);
    return 0;
}
