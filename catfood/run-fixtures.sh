#!/bin/sh
set -eu

fixture_root=${1:-}
workspace=${CATFOOD_ROOT:-/opt}
prefix=${CATFOOD_PREFIX:-/usr/local}
temporary=${RUNNER_TEMP:-/tmp}/aici-catfood-fixtures
server_pid=

fail() {
    printf 'CATFOOD-ACCEPTANCE: %s\n' "$*" >&2
    exit 1
}

cleanup() {
    if [ -n "$server_pid" ]; then
        if kill "$server_pid" 2>/dev/null; then
            :
        fi
        if wait "$server_pid" 2>/dev/null; then
            :
        fi
    fi
}

require_executable() {
    label=$1
    path=$2
    if [ ! -x "$path" ]; then
        fail "$label was not built by Cat Food at $path"
    fi
}

expect_output() {
    label=$1
    expected=$2
    working_directory=$3
    shift 3
    actual=$temporary/$label.actual

    if ! (
        cd "$working_directory"
        "$@"
    ) > "$actual"; then
        fail "$label fixture did not run successfully"
    fi

    if ! cmp -s "$expected" "$actual"; then
        printf 'CATFOOD-OUTPUT: %s returned the wrong output\n' "$label" >&2
        diff -u "$expected" "$actual" >&2
        return 1
    fi

    printf '%-12s exact output ok\n' "$label"
}

[ -n "$fixture_root" ] || fail 'usage: run-fixtures.sh FIXTURE_ROOT'
[ -d "$fixture_root" ] || fail "fixture directory is missing: $fixture_root"

rm -rf "$temporary"
mkdir -p "$temporary"
trap cleanup EXIT HUP INT TERM

require_executable Grease "$workspace/bin/grease"
require_executable Idric "$workspace/Idric/build/exec/idris2"
require_executable Ithon "$workspace/.build/ithon/python"
require_executable Fieldmouse "$workspace/fieldmouse/build/exec/fieldmouse"
require_executable IR "$workspace/r/bin/R"
require_executable ICU "$workspace/icu/build/exec/icu"
require_executable IB "$workspace/ib/src/build/exec/ib-smoke"

grease_launcher=$(readlink -f "$workspace/bin/grease")
[ "$grease_launcher" = "$workspace/.build/grease/bin/grease" ] ||
    fail "Grease points at an unexpected implementation: $grease_launcher"
grep -F '# catfood Grease source launcher' "$grease_launcher" >/dev/null ||
    fail 'Grease is not the Cat Food pinned-source launcher'
grep -F "$workspace/grease/source/bin/oils_for_unix.py" "$grease_launcher" >/dev/null ||
    fail 'Grease does not execute the source pinned by the Grease repository'

PATH=$workspace/Idric/.tools/bin:$prefix/bin:$workspace/bin:$PATH
IDRIS2_PREFIX=$workspace/Idric/bootstrap-build
export PATH IDRIS2_PREFIX

expect_output grease \
    "$fixture_root/grease/program.expected" \
    "$fixture_root/grease" \
    "$workspace/bin/grease" "$fixture_root/grease/program.ysh"

idric_build=$temporary/idric
mkdir -p "$idric_build"
cp "$fixture_root/idric/Main.idric" "$idric_build/Main.idric"
(
    cd "$idric_build"
    "$workspace/Idric/build/exec/idris2" Main.idric -o aici-idric
)
require_executable 'Idric fixture' "$idric_build/build/exec/aici-idric"
expect_output idric \
    "$fixture_root/idric/program.expected" \
    "$idric_build" \
    "$idric_build/build/exec/aici-idric"

expect_output ithon \
    "$fixture_root/ithon/program.expected" \
    "$fixture_root/ithon" \
    "$workspace/.build/ithon/python" "$fixture_root/ithon/program.pi"

expect_output fieldmouse \
    "$fixture_root/fieldmouse/program.expected" \
    "$fixture_root/fieldmouse" \
    "$workspace/fieldmouse/build/exec/fieldmouse" "$fixture_root/fieldmouse/program.js"

expect_output ir \
    "$fixture_root/ir/program.expected" \
    "$fixture_root/ir" \
    "$workspace/r/bin/R" --vanilla --slave --file="$fixture_root/ir/program.R"

cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
    -o "$temporary/icu-server" "$fixture_root/icu/server.c"
"$temporary/icu-server" 18765 "$temporary/icu.ready" &
server_pid=$!
ready_wait=0
while [ ! -f "$temporary/icu.ready" ]; do
    ready_wait=$((ready_wait + 1))
    if [ "$ready_wait" -gt 10 ]; then
        fail 'ICU fixture server did not become ready'
    fi
    sleep 1
done
expect_output icu \
    "$fixture_root/icu/program.expected" \
    "$workspace/icu" \
    "$workspace/icu/build/exec/icu" get http://127.0.0.1:18765/aici
if ! wait "$server_pid"; then
    fail 'ICU fixture server rejected the request'
fi
server_pid=

cp "$fixture_root/ib/AiciCatfoodFixture.idric" \
    "$workspace/ib/src/AiciCatfoodFixture.idric"
(
    cd "$workspace/ib/src"
    "$workspace/Idric/build/exec/idris2" \
        AiciCatfoodFixture.idric -o aici-catfood-ib
)
require_executable 'IB fixture' \
    "$workspace/ib/src/build/exec/aici-catfood-ib"
expect_output ib \
    "$fixture_root/ib/program.expected" \
    "$workspace/ib/src" \
    "$workspace/ib/src/build/exec/aici-catfood-ib"

printf '%s\n' 'Cat Food bare-cloud acceptance passed'
