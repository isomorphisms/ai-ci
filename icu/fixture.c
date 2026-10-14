/* Independent disposable HTTP/TLS/proxy fixtures, never a client transport. */
#define _POSIX_C_SOURCE 200809L
#include <arpa/inet.h>
#include <errno.h>
#include <openssl/ssl.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

static int send_all(int fd, SSL *tls, const void *data, size_t size) {
    const unsigned char *bytes = data;
    while (size) {
        int n = tls ? SSL_write(tls, bytes, (int)size) : (int)send(fd, bytes, size, MSG_NOSIGNAL);
        if (n <= 0) return 0;
        bytes += n; size -= (size_t)n;
    }
    return 1;
}

static void respond(int fd, SSL *tls, const char *request, int port) {
    char path[256];
    if (sscanf(request, "%*s %255s", path) != 1) return;
    if (!strcmp(path, "/timeout")) { sleep(17); return; }
    if (!strcmp(path, "/malformed")) {
        const char *r = "garbage 200 OK\r\n\r\n";
        (void)send_all(fd, tls, r, strlen(r)); return;
    }
    if (!strcmp(path, "/status-digits")) {
        const char *r = "HTTP/1.0 2000 Wrong\r\nContent-Length: 0\r\n\r\n";
        (void)send_all(fd, tls, r, strlen(r)); return;
    }
    if (!strcmp(path, "/same") || !strcmp(path, "/cross")) {
        char r[512];
        int n = !strcmp(path, "/same")
            ? snprintf(r, sizeof(r), "HTTP/1.0 302 Found\r\nLocation: /require-credentials\r\nContent-Length: 0\r\n\r\n")
            : snprintf(r, sizeof(r), "HTTP/1.0 302 Found\r\nLocation: http://127.0.0.1:%d/must-be-clean\r\nContent-Length: 0\r\n\r\n", port);
        (void)send_all(fd, tls, r, (size_t)n); return;
    }
    int sensitive = strstr(request, "Authorization:") != NULL || strstr(request, "X-API-Key:") != NULL;
    const char *body = "hello";
    if (!strcmp(path, "/require-credentials")) body = sensitive ? "retained" : "MISSING";
    if (!strcmp(path, "/must-be-clean")) body = sensitive ? "LEAKED" : "stripped";
    if (!strcmp(path, "/post")) {
        const char *content = strstr(request, "\r\n\r\n");
        body = content && !strcmp(content + 4, "caf\xc3\xa9") ? "posted" : "BAD-POST";
    }
    unsigned char binary[] = {0, 1, 2, 255, 10, 13, 0, 128};
    unsigned char invalid[] = {0xc0, 0xaf};
    unsigned char held[16385];
    int holding = !strncmp(path, "/hold-", 6);
    if (holding) { memset(held, 'x', sizeof(held)); memcpy(held, path + 1, strlen(path) - 1); }
    size_t size = strlen(body);
    const void *bytes = body;
    if (!strcmp(path, "/binary")) { size = sizeof(binary); bytes = binary; }
    if (!strcmp(path, "/invalid-utf8")) { size = sizeof(invalid); bytes = invalid; }
    if (holding) { size = sizeof(held); bytes = held; }
    if (!strcmp(path, "/empty")) size = 0;
    int status = 200;
    if (!strncmp(path, "/status/", 8)) status = atoi(path + 8);
    if (!strcmp(path, "/empty")) status = 204;
    int large = !strcmp(path, "/limit") || !strcmp(path, "/limit-stream") || !strcmp(path, "/exact-limit");
    if (large) size = 8u * 1024u * 1024u + (strcmp(path, "/exact-limit") != 0);
    char length[100];
    (void)snprintf(length, sizeof(length), "Content-Length: %zu\r\n", size);
    if (!strcmp(path, "/truncated")) strcpy(length, "Content-Length: 123\r\n");
    if (!strcmp(path, "/bad-length")) strcpy(length, "Content-Length: bad\r\n");
    if (!strcmp(path, "/duplicate-length")) strcpy(length, "Content-Length: 5\r\nContent-Length: 6\r\n");
    if (!strcmp(path, "/chunked")) strcpy(length, "Transfer-Encoding: chunked\r\n");
    if (!strcmp(path, "/limit-stream")) length[0] = 0;
    const char *encoding = !strcmp(path, "/compressed") ? "gzip" : "identity";
    const char *type = !strcmp(path, "/charset") ? "text/plain; charset=iso-8859-1" : "text/plain; charset=utf-8";
    char head[512];
    int n = snprintf(head, sizeof(head), "HTTP/1.0 %d Fixture\r\n%sContent-Type: %s\r\nContent-Encoding: %s\r\nConnection: close\r\n\r\n", status, length, type, encoding);
    if (!send_all(fd, tls, head, (size_t)n)) return;
    if (holding) {
        if (!send_all(fd, tls, held, sizeof(held) - 1)) return;
        sleep(2);
        (void)send_all(fd, tls, held + sizeof(held) - 1, 1);
        return;
    }
    if (large) {
        unsigned char block[4096]; memset(block, 'x', sizeof(block));
        while (size) {
            size_t count = size > sizeof(block) ? sizeof(block) : size;
            if (!send_all(fd, tls, block, count)) break;
            size -= count;
        }
    } else (void)send_all(fd, tls, bytes, size);
}

static int tcp(int port) {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in address = {0};
    address.sin_family = AF_INET; address.sin_port = htons((unsigned short)port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (fd < 0 || connect(fd, (struct sockaddr *)&address, sizeof(address)) < 0) { if (fd >= 0) close(fd); return -1; }
    return fd;
}

static void serve(int fd, SSL_CTX *context, const char *mode, int port, int backend) {
    SSL *tls = context ? SSL_new(context) : NULL;
    if (tls && (SSL_set_fd(tls, fd) != 1 || SSL_accept(tls) != 1)) goto done;
    char request[65537]; size_t used = 0;
    while (used < sizeof(request) - 1) {
        int n = tls ? SSL_read(tls, request + used, 1) : (int)recv(fd, request + used, 1, 0);
        if (n <= 0) goto done;
        used += (size_t)n; request[used] = 0;
        if (strstr(request, "\r\n\r\n")) break;
    }
    if (!strcmp(mode, "proxy") || !strcmp(mode, "proxy6") || !strcmp(mode, "reject")) {
        if (strncmp(request, "CONNECT ", 8) || strstr(request, "Authorization:") || strstr(request, "Cookie:")) goto done;
        const char *reply = !strcmp(mode, "reject") ? "HTTP/1.0 407 Rejected\r\n\r\n" : "HTTP/1.0 200 Established\r\n\r\n";
        int upstream = strcmp(mode, "reject") ? tcp(backend) : -1;
        if (!send_all(fd, NULL, reply, strlen(reply)) || upstream < 0) goto done;
        for (;;) {
            struct pollfd pair[2] = {{fd, POLLIN, 0}, {upstream, POLLIN, 0}};
            if (poll(pair, 2, 25000) <= 0) break;
            int stop = 0;
            for (int i = 0; i < 2; ++i) if (pair[i].revents) {
                char bytes[16384]; ssize_t n = recv(pair[i].fd, bytes, sizeof(bytes), 0);
                if (n <= 0 || !send_all(pair[1-i].fd, NULL, bytes, (size_t)n)) { stop = 1; break; }
            }
            if (stop) break;
        }
        close(upstream);
    } else {
        const char *length = strstr(request, "\r\nContent-Length: ");
        int count = length ? atoi(length + 18) : 0;
        while (count-- > 0 && used < sizeof(request) - 1) {
            int n = tls ? SSL_read(tls, request + used, 1) : (int)recv(fd, request + used, 1, 0);
            if (n != 1) goto done;
            ++used;
        }
        request[used] = 0;
        respond(fd, tls, request, tls ? 28080 : port);
    }
done:
    if (tls) { (void)SSL_shutdown(tls); SSL_free(tls); }
    close(fd);
}

int main(int argc, char **argv) {
    if (argc < 4) return 2;
    signal(SIGPIPE, SIG_IGN); signal(SIGCHLD, SIG_IGN);
    int port = atoi(argv[2]);
    SSL_CTX *context = NULL;
    if (!strcmp(argv[1], "tls")) {
        if (argc != 6) return 2;
        context = SSL_CTX_new(TLS_server_method());
        if (!context || SSL_CTX_use_certificate_file(context, argv[4], SSL_FILETYPE_PEM) != 1 ||
            SSL_CTX_use_PrivateKey_file(context, argv[5], SSL_FILETYPE_PEM) != 1) return 3;
    }
    int ipv6 = !strcmp(argv[1], "proxy6");
    int listener = socket(ipv6 ? AF_INET6 : AF_INET, SOCK_STREAM, 0), reuse = 1;
    (void)setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    struct sockaddr_in address = {0}; address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK); address.sin_port = htons((unsigned short)port);
    struct sockaddr_in6 address6 = {0}; address6.sin6_family = AF_INET6;
    address6.sin6_addr = in6addr_loopback; address6.sin6_port = htons((unsigned short)port);
    int bound = ipv6 ? bind(listener, (struct sockaddr *)&address6, sizeof(address6))
                     : bind(listener, (struct sockaddr *)&address, sizeof(address));
    if (listener < 0 || bound || listen(listener, 16)) return 4;
    FILE *ready = fopen(argv[3], "w"); if (!ready) return 5;
    fputs("ready\n", ready); fclose(ready);
    for (;;) {
        int fd = accept(listener, NULL, NULL); if (fd < 0) { if (errno == EINTR) continue; return 6; }
        pid_t child = fork(); if (child < 0) return 7;
        if (!child) { close(listener); serve(fd, context, argv[1], port, argc == 5 ? atoi(argv[4]) : 0); _exit(0); }
        close(fd);
    }
}
