#include <arpa/inet.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

static int send_all(int descriptor, const char *bytes, size_t length) {
    size_t sent = 0;

    while (sent < length) {
        ssize_t count = send(descriptor, bytes + sent, length - sent, 0);
        if (count < 0) {
            if (errno == EINTR) {
                continue;
            }
            return 0;
        }
        sent += (size_t)count;
    }
    return 1;
}

int main(int argc, char **argv) {
    static const char response[] =
        "HTTP/1.0 200 OK\r\n"
        "Content-Type: text/plain\r\n"
        "Content-Length: 7\r\n"
        "Connection: close\r\n"
        "\r\n"
        "icu=42\n";
    struct sockaddr_in address;
    char request[4096];
    char *end = NULL;
    long parsed_port;
    int listener;
    int client;
    int reuse = 1;
    size_t used = 0;
    FILE *ready;

    if (argc != 3) {
        fprintf(stderr, "usage: %s PORT READY_FILE\n", argv[0]);
        return 2;
    }

    parsed_port = strtol(argv[1], &end, 10);
    if (end == argv[1] || *end != '\0' || parsed_port < 1 || parsed_port > 65535) {
        fprintf(stderr, "invalid port: %s\n", argv[1]);
        return 2;
    }

    signal(SIGPIPE, SIG_IGN);
    listener = socket(AF_INET, SOCK_STREAM, 0);
    if (listener < 0) {
        perror("socket");
        return 1;
    }
    if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
        perror("setsockopt");
        close(listener);
        return 1;
    }

    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_port = htons((unsigned short)parsed_port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(listener, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind");
        close(listener);
        return 1;
    }
    if (listen(listener, 1) < 0) {
        perror("listen");
        close(listener);
        return 1;
    }

    ready = fopen(argv[2], "w");
    if (ready == NULL) {
        perror("ready file");
        close(listener);
        return 1;
    }
    fputs("ready\n", ready);
    if (fclose(ready) != 0) {
        perror("ready file close");
        close(listener);
        return 1;
    }

    client = accept(listener, NULL, NULL);
    if (client < 0) {
        perror("accept");
        close(listener);
        return 1;
    }

    while (used + 1 < sizeof(request)) {
        ssize_t count = recv(client, request + used, sizeof(request) - used - 1, 0);
        if (count < 0) {
            if (errno == EINTR) {
                continue;
            }
            perror("recv");
            close(client);
            close(listener);
            return 1;
        }
        if (count == 0) {
            break;
        }
        used += (size_t)count;
        request[used] = '\0';
        if (strstr(request, "\r\n\r\n") != NULL) {
            break;
        }
    }

    request[used] = '\0';
    if (strncmp(request, "GET /aici HTTP/1.",
                sizeof("GET /aici HTTP/1.") - 1) != 0) {
        fprintf(stderr, "unexpected ICU request: %s\n", request);
        close(client);
        close(listener);
        return 1;
    }
    if (!send_all(client, response, sizeof(response) - 1)) {
        perror("send");
        close(client);
        close(listener);
        return 1;
    }

    close(client);
    close(listener);
    return 0;
}
