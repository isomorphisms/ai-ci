#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
bash -n "$root/android-companion/verify.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
if bash "$root/android-companion/verify.sh" >"$tmp/out" 2>"$tmp/err"; then
    echo "missing arguments were accepted" >&2; exit 1
fi
grep -F 'usage: verify.sh CATFOOD_ROOT' "$tmp/err" >/dev/null
if bash "$root/android-companion/verify.sh" /x /y /z /a /b >"$tmp/out" 2>"$tmp/err"; then
    echo "missing source/plan artifacts were accepted" >&2; exit 1
fi
grep -F 'missing input: /z' "$tmp/err" >/dev/null
printf '%s\n' 'AICI companion verifier syntax and fail-closed input smoke: PASS'
