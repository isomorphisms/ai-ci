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
release=$(uname -r)

printf 'event\tstatus\thost\trole\tsubject\tvalue\tevidence\n'
printf 'host-role\tpass\t%s\texecution\tidentity\t%s\tobserved:probe\n' "$host" "$host"
printf 'host-fact\tpass\t%s\texecution\tos\t%s\tobserved:uname-s\n' "$host" "$os"
printf 'host-fact\tpass\t%s\texecution\tarch\t%s\tobserved:uname-m\n' "$host" "$arch"
printf 'host-fact\tpass\t%s\texecution\trelease\t%s\tobserved:uname-r\n' "$host" "$release"

for command_name in "$@"; do
    case $command_name in
        *[!A-Za-z0-9_.+-]*|'')
            printf 'unsafe command name: %s\n' "$command_name" >&2
            exit 2
            ;;
    esac
    resolved=$(command -v "$command_name" 2>/dev/null || true)
    if [ -n "$resolved" ]; then
        presence=present
        evidence="observed:command-v:$resolved"
    else
        presence=absent
        evidence=observed:command-v:absent
    fi
    case $evidence in
        *"	"*|*"
"*)
            printf 'command resolution contains unsafe whitespace: %s\n' "$command_name" >&2
            exit 2
            ;;
    esac
    printf 'command-presence\tpass\t%s\texecution\t%s\t%s\t%s\n' \
        "$host" "$command_name" "$presence" "$evidence"
done
