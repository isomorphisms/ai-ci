#!/bin/sh
# Independent verifier builds its C *only* through authenticated ICK.
# The host GCC driver links already compiled objects, never C source.
set -eu
: "${ICK_CC:?pinned ICK compiler is required}"
: "${ICK_SOURCE_DIR:?pinned ICK source checkout is required}"
: "${HOST_LINKER:?object-only host linker is required}"
test "$#" -ge 3 || { echo 'usage: build-ick.sh OUTPUT SOURCE.c SOURCE2.c ...' >&2; exit 2; }
test "$ICK_CC" = "$ICK_SOURCE_DIR/stage/bin/x86_64-linux-gnu-gcc"
test "$(git -C "$ICK_SOURCE_DIR" rev-parse HEAD)" = c61e448251744a2f40ad743ebef1a027bdcd2f9d
test "$(git -C "$ICK_SOURCE_DIR/gcc" rev-parse HEAD)" = 6294f1d9e7536e5ffcde09d1528c918d63abfef5
test "$(sed -n 's/^gcc_commit=//p' "$ICK_SOURCE_DIR/ick/SOURCE.lock")" = 6294f1d9e7536e5ffcde09d1528c918d63abfef5
test "$("$ICK_CC" -dumpmachine)" = x86_64-linux-gnu
test -z "${GCC_EXEC_PREFIX-}${COMPILER_PATH-}"
cc1=$(readlink -f "$("$ICK_CC" -print-prog-name=cc1)")
case "$cc1" in
  "$ICK_SOURCE_DIR"/stage/libexec/gcc/x86_64-linux-gnu/*/cc1) test -x "$cc1" ;;
  *) echo 'Unqualified ICK cc1' >&2; exit 3 ;;
esac
output=$1
shift
mkdir -p "$(dirname "$output")"
tmp=$(mktemp -d "${RUNNER_TEMP:-/tmp}/fb-ick-objects.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM
printf '%s\n' "$@" > "$tmp/sources"
set --
index=0
while IFS= read -r source; do
    case "$source" in *.c) ;; *) echo 'Non-C source path' >&2; exit 4 ;; esac
    index=$((index + 1))
    object="$tmp/$index.o"
    "$ICK_CC" -O2 -std=c11 -Wall -Wextra -Werror -pedantic \
        -ffp-contract=off -fno-fast-math -fPIC -I_fb/src \
        -c "$source" -o "$object"
    test -s "$object"
    readelf -h "$object" | grep -q 'Class:.*ELF64'
    readelf -h "$object" | grep -q 'Machine:.*Advanced Micro Devices X86-64'
    set -- "$@" "$object"
done < "$tmp/sources"
test "$index" -ge 2
"$HOST_LINKER" "$@" -lm -o "$output"
test -s "$output"
sha256sum "$output"
