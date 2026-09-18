#define _POSIX_C_SOURCE 200809L

#include <arpa/inet.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <unistd.h>

#define REQUEST_MAX 16384
#define BODY_MAX (1024 * 1024)
#define PATH_MAX_LOCAL 4096

static volatile sig_atomic_t running = 1;

static void stop_server(int signal_number) {
    (void)signal_number;
    running = 0;
}

static int write_all(int fd, const void *data, size_t length) {
    const unsigned char *bytes = data;
    size_t written = 0;
    while (written < length) {
#ifdef MSG_NOSIGNAL
        ssize_t amount = send(fd, bytes + written, length - written, MSG_NOSIGNAL);
#else
        ssize_t amount = send(fd, bytes + written, length - written, 0);
#endif
        if (amount < 0 && errno == EINTR) continue;
        if (amount <= 0) return 0;
        written += (size_t)amount;
    }
    return 1;
}

static unsigned char *read_file(const char *path, size_t *length) {
    FILE *file = fopen(path, "rb");
    if (file == NULL) return NULL;
    if (fseek(file, 0, SEEK_END) != 0) {
        fclose(file);
        return NULL;
    }
    long size = ftell(file);
    if (size < 0 || size > BODY_MAX || fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }
    unsigned char *data = malloc((size_t)size + 1u);
    if (data == NULL) {
        fclose(file);
        return NULL;
    }
    size_t got = fread(data, 1, (size_t)size, file);
    if (got != (size_t)size || ferror(file)) {
        free(data);
        fclose(file);
        return NULL;
    }
    fclose(file);
    data[got] = 0;
    *length = got;
    return data;
}

static int hex_value(int character) {
    if (character >= '0' && character <= '9') return character - '0';
    if (character >= 'a' && character <= 'f') return character - 'a' + 10;
    if (character >= 'A' && character <= 'F') return character - 'A' + 10;
    return -1;
}

static unsigned char *read_hex_file(const char *path, size_t *length) {
    size_t text_length = 0;
    unsigned char *text = read_file(path, &text_length);
    if (text == NULL) return NULL;
    unsigned char *bytes = malloc(text_length / 2u + 1u);
    if (bytes == NULL) {
        free(text);
        return NULL;
    }
    size_t used = 0;
    int high = -1;
    for (size_t index = 0; index < text_length; ++index) {
        int value = hex_value(text[index]);
        if (value >= 0) {
            if (high < 0) {
                high = value;
            } else {
                bytes[used++] = (unsigned char)((high << 4) | value);
                high = -1;
            }
        } else if (text[index] != ' ' && text[index] != '\t' &&
                   text[index] != '\r' && text[index] != '\n') {
            free(bytes);
            free(text);
            return NULL;
        }
    }
    free(text);
    if (high >= 0) {
        free(bytes);
        return NULL;
    }
    *length = used;
    return bytes;
}

static int load_body(const char *corpus_root, const char *relative, int hex,
                     unsigned char **body, size_t *length) {
    char path[PATH_MAX_LOCAL];
    int count = snprintf(path, sizeof(path), "%s/%s", corpus_root, relative);
    if (count < 0 || (size_t)count >= sizeof(path)) return 0;
    *body = hex ? read_hex_file(path, length) : read_file(path, length);
    return *body != NULL;
}

static int send_response(int fd, int status, const char *reason,
                         const char *content_type, const char *content_encoding,
                         const unsigned char *body, size_t body_length,
                         size_t declared_length, const char *extra_headers) {
    char headers[4096];
    int count = snprintf(
        headers, sizeof(headers),
        "HTTP/1.0 %d %s\r\n"
        "Content-Type: %s\r\n"
        "Content-Encoding: %s\r\n"
        "Content-Length: %zu\r\n"
        "Connection: close\r\n%s\r\n",
        status, reason, content_type, content_encoding, declared_length,
        extra_headers == NULL ? "" : extra_headers);
    return count > 0 && (size_t)count < sizeof(headers) &&
           write_all(fd, headers, (size_t)count) &&
           (body_length == 0 || write_all(fd, body, body_length));
}

static void handle_request(int fd, const char *corpus_root) {
    char request[REQUEST_MAX + 1];
    ssize_t amount = recv(fd, request, REQUEST_MAX, 0);
    if (amount <= 0) return;
    request[amount] = '\0';

    if (strncmp(request, "GET ", 4) != 0) {
        static const char plaintext[] = "this endpoint is deliberately not TLS\n";
        (void)write_all(fd, plaintext, sizeof(plaintext) - 1u);
        return;
    }
    char *path = request + 4;
    char *space = strchr(path, ' ');
    if (space == NULL) return;
    *space = '\0';

    if (strcmp(path, "/redirect") == 0) {
        static const unsigned char empty[] = "";
        (void)send_response(fd, 302, "Found", "text/plain; charset=utf-8",
                            "identity", empty, 0, 0, "Location: /valid\r\n");
        return;
    }

    const char *relative = "bodies/valid.html";
    const char *content_type = "text/html; charset=utf-8";
    const char *encoding = "identity";
    int status = 200;
    const char *reason = "OK";
    int hex = 0;
    int truncated = 0;

    if (strcmp(path, "/valid") == 0) {
        relative = "bodies/valid.html";
    } else if (strcmp(path, "/malformed") == 0) {
        relative = "bodies/malformed.html";
    } else if (strcmp(path, "/empty") == 0) {
        relative = "bodies/empty.html";
    } else if (strcmp(path, "/truncated") == 0) {
        relative = "bodies/valid.html";
        truncated = 1;
    } else if (strcmp(path, "/invalid-utf8") == 0) {
        relative = "bodies/invalid-utf8.hex";
        hex = 1;
    } else if (strcmp(path, "/unknown-charset") == 0) {
        relative = "bodies/valid.html";
        content_type = "text/html; charset=x-hostile-unknown";
    } else if (strcmp(path, "/gzip-truncated") == 0) {
        relative = "bodies/truncated-gzip.hex";
        content_type = "text/html";
        encoding = "gzip";
        hex = 1;
    } else if (strcmp(path, "/not-found") == 0) {
        relative = "bodies/not-found.html";
        status = 404;
        reason = "Not Found";
    } else {
        relative = "bodies/not-found.html";
        status = 404;
        reason = "Not Found";
    }

    unsigned char *body = NULL;
    size_t body_length = 0;
    if (!load_body(corpus_root, relative, hex, &body, &body_length)) {
        static const unsigned char error[] = "fixture server error\n";
        (void)send_response(fd, 500, "Internal Server Error",
                            "text/plain; charset=utf-8", "identity",
                            error, sizeof(error) - 1u, sizeof(error) - 1u, NULL);
        return;
    }
    size_t declared_length = truncated ? body_length + 7u : body_length;
    (void)send_response(fd, status, reason, content_type, encoding,
                        body, body_length, declared_length, NULL);
    free(body);
}

static int parse_port(const char *text) {
    char *end = NULL;
    long value = strtol(text, &end, 10);
    return end != NULL && *end == '\0' && value >= 1 && value <= 65535
        ? (int)value : -1;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: %s PORT CORPUS_ROOT\n", argv[0]);
        return 2;
    }
    int port = parse_port(argv[1]);
    if (port < 0) {
        fputs("invalid port\n", stderr);
        return 2;
    }
    signal(SIGTERM, stop_server);
    signal(SIGINT, stop_server);
    signal(SIGPIPE, SIG_IGN);

    int listener = socket(AF_INET, SOCK_STREAM, 0);
    if (listener < 0) {
        perror("socket");
        return 1;
    }
    int reuse = 1;
    (void)setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    address.sin_port = htons((unsigned short)port);
    if (bind(listener, (struct sockaddr *)&address, sizeof(address)) != 0 ||
        listen(listener, 16) != 0) {
        perror("bind/listen");
        close(listener);
        return 1;
    }
    printf("READY %d\n", port);
    fflush(stdout);

    while (running) {
        int client = accept(listener, NULL, NULL);
        if (client < 0) {
            if (errno == EINTR) continue;
            perror("accept");
            close(listener);
            return 1;
        }
        handle_request(client, argv[2]);
        close(client);
    }
    close(listener);
    return 0;
}
