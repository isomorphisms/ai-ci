#!/bin/sh
set -eu

if [ "$#" -lt 1 ]; then
    printf '%s\n' 'usage: probe.sh HOST [COMMAND ...]' >&2
    exit 2
fi

host=$1
shift

os=$(uname -s)
arch=$(uname -m)

printf 'event\tstatus\thost\trole\tsubject\tvalue\tevidence\n'
printf 'host-role\tpass\t%s\texecution\tidentity\t%s\tobserved:probe\n' "$host" "$host"
printf 'host-fact\tpass\t%s\texecution\tos\t%s\tobserved:uname-s\n' "$host" "$os"
printf 'host-fact\tpass\t%s\texecution\tarch\t%s\tobserved:uname-m\n' "$host" "$arch"

for command_name in "$@"; do
    case $command_name in
        *[!A-Za-z0-9_.+-]*|'')
            printf 'unsafe command name: %s\n' "$command_name" >&2
            exit 2
            ;;
    esac
    if command -v "$command_name" >/dev/null 2>&1; then
        presence=present
    else
        presence=absent
    fi
    printf 'command-presence\tpass\t%s\texecution\t%s\t%s\tobserved:command-v\n' \
        "$host" "$command_name" "$presence"
done
