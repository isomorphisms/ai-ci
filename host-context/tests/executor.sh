#!/bin/sh
# Behavioural tests: the oracle inspects child side effects, not a claimed trace.
set -eu
root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
runner=$root/execute.sh
shell=${TEST_SHELL:-/bin/sh}
for tool in mktemp mkdir chmod cat grep cmp uname id ln od cp rm; do
    command -v "$tool" >/dev/null 2>&1 || { printf 'test dependency missing: %s\n' "$tool" >&2; exit 1; }
done
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' 0
trap 'exit 1' HUP INT TERM
os=$(uname -s)
arch=$(uname -m)
node=$(uname -n)
uid=$(id -u)
passed=0
request=$tmp/request
marker=$tmp/marker

cat > "$tmp/child.sh" <<'EOF'
printf '%s\n' ran > "$1"
shift
printf '<%s>\n' "$@"
EOF
cat > "$tmp/failing.sh" <<'EOF'
printf '%s\n' ran > "$1"
printf '%s\n' 'FAKE: PASS succeeded'
exit 7
EOF
cat > "$tmp/private-fd.sh" <<'EOF'
if (printf 'FORGED\n' >&3) 2>/dev/null; then exit 9; fi
printf '%s\n' ran > "$1"
EOF

request_for() { printf '%s\n' "$@" > "$request"; }
invoke() {
    "$shell" "$runner" --request "$request" --receipt "$tmp/$case_id.tsv" \
        --expect-os "$os" --expect-arch "$arch" "$@"
}
check_pass() {
    case_id=$1
    shift
    rm -f "$marker"
    invoke "$@" > "$tmp/stdout" 2> "$tmp/stderr" || { cat "$tmp/stderr"; exit 1; }
    test -f "$marker"
    grep -F 'final	outcome	succeeded' "$tmp/$case_id.tsv" >/dev/null
    passed=$((passed + 1))
    printf 'PASS %s\n' "$case_id"
}
check_blocked() {
    case_id=$1
    diagnostic=$2
    shift 2
    rm -f "$marker"
    if invoke "$@" > "$tmp/stdout" 2> "$tmp/stderr"; then
        printf 'FAIL %s: accepted invalid request\n' "$case_id" >&2
        exit 1
    else
        status=$?
    fi
    test "$status" -eq 125
    grep -F "$diagnostic" "$tmp/stderr" >/dev/null
    test ! -e "$marker"
    if test -f "$tmp/$case_id.tsv"; then
        if grep -F 'launched	child_pid' "$tmp/$case_id.tsv" >/dev/null; then
            printf 'FAIL %s: child started before rejection\n' "$case_id" >&2
            exit 1
        fi
    fi
    passed=$((passed + 1))
    printf 'PASS %s\n' "$case_id"
}

request_for "$shell" "$tmp/child.sh" "$marker" 'two words' '' '$(touch unwanted)' '; exit 17' '*.txt' 'λ ⇒'
check_pass exact-argv --expect-node "$node" --expect-uid "$uid"
printf '<%s>\n' 'two words' '' '$(touch unwanted)' '; exit 17' '*.txt' 'λ ⇒' > "$tmp/expected"
cmp "$tmp/expected" "$tmp/stdout"
grep -F 'argument	3	two words' "$tmp/exact-argv.tsv" >/dev/null

request_for "$shell" "$tmp/child.sh" "$marker"
saved_os=$os
os=definitely-not-this-os
check_blocked wrong-os HC-OS
os=$saved_os
saved_arch=$arch
arch=definitely-not-this-arch
check_blocked wrong-arch HC-ARCH
arch=$saved_arch
check_blocked wrong-release HC-RELEASE --expect-release definitely-not-this-release
check_blocked wrong-cwd HC-CWD --expect-cwd /definitely/not/the/current/directory
check_blocked wrong-node HC-NODE --expect-node definitely-not-this-node
check_blocked wrong-uid HC-UID --expect-uid 999999999
check_blocked invented-trace HC-REQUEST --trace "$tmp/forged.tsv"
check_blocked invented-installer HC-REQUEST --install gh
check_blocked duplicate-option HC-REQUEST --expect-os "$os"
check_blocked unknown-option HC-REQUEST --skip-preflight
request_for aici-program-that-does-not-exist "$marker"
check_blocked missing-program HC-COMMAND
request_for ./relative-program "$marker"
check_blocked relative-program HC-COMMAND
request_for "$tmp"
check_blocked directory-not-program HC-COMMAND
printf '#!/bin/sh\nprintf ran > "%s"\n' "$marker" > "$tmp/not-executable"
request_for "$tmp/not-executable"
check_blocked nonexecutable HC-COMMAND
: > "$request"
check_blocked empty-request HC-REQUEST
request_for '' "$marker"
check_blocked empty-program HC-REQUEST
request_for "$shell" "$tmp/child.sh" "$marker" "$(printf 'bad\targument')"
check_blocked tab-in-argument HC-REQUEST
request_for "$shell" "$tmp/child.sh" "$marker" "$(printf 'bad\rargument')"
check_blocked cr-in-argument HC-REQUEST
request_for "$shell" "$tmp/child.sh" "$marker"
check_blocked tab-in-expectation HC-REQUEST --expect-node "$(printf 'bad\tvalue')"

case_id=bad-path
rm -f "$marker"
if PATH=relative:/bin invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; fi
grep -F HC-PATH "$tmp/stderr" >/dev/null
test ! -e "$marker"
passed=$((passed + 1)); printf 'PASS %s\n' "$case_id"
case_id=empty-path-component
if PATH=/bin::/usr/bin invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; fi
grep -F HC-PATH "$tmp/stderr" >/dev/null
test ! -e "$marker"
passed=$((passed + 1)); printf 'PASS %s\n' "$case_id"

# No fallback into package installation, even with plausible installer names.
mkdir "$tmp/narrow-path"
ln -s "$(command -v uname)" "$tmp/narrow-path/uname"
ln -s "$(command -v id)" "$tmp/narrow-path/id"
ln -s "$(command -v od)" "$tmp/narrow-path/od"
for installer in apt pkg brew; do
    printf '#!/bin/sh\nprintf ran > "%s"\n' "$tmp/installer-ran" > "$tmp/narrow-path/$installer"
    chmod +x "$tmp/narrow-path/$installer"
done
request_for gh run download
case_id=missing-gh-no-installer
if PATH="$tmp/narrow-path" invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; fi
grep -F HC-COMMAND "$tmp/stderr" >/dev/null
test ! -e "$tmp/installer-ran"
passed=$((passed + 1)); printf 'PASS %s\n' "$case_id"

# Even foundational measurement dependencies must exist before launch.
rm "$tmp/narrow-path/uname"
request_for "$shell" "$tmp/child.sh" "$marker"
case_id=missing-probe
if PATH="$tmp/narrow-path" invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; fi
grep -F HC-PROBE "$tmp/stderr" >/dev/null
test ! -e "$marker"
passed=$((passed + 1)); printf 'PASS %s\n' "$case_id"

# Forged or stale receipt cannot be read back as permission to execute.
case_id=receipt-replay
printf '999\tfinal\toutcome\tsucceeded\n' > "$tmp/$case_id.tsv"
cp "$tmp/$case_id.tsv" "$tmp/saved-receipt"
if invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; fi
cmp "$tmp/$case_id.tsv" "$tmp/saved-receipt"
test ! -e "$marker"
passed=$((passed + 1)); printf 'PASS %s\n' "$case_id"
case_id=receipt-symlink
ln -s "$tmp/saved-receipt" "$tmp/$case_id.tsv"
if invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; fi
cmp "$tmp/receipt-replay.tsv" "$tmp/saved-receipt"
test ! -e "$marker"
passed=$((passed + 1)); printf 'PASS %s\n' "$case_id"
case_id=receipt-missing-parent/path
if invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; fi
test ! -e "$marker"
passed=$((passed + 1)); printf 'PASS missing-receipt-parent\n'

request_for "$shell" "$tmp/failing.sh" "$marker"
case_id=child-failure-not-forged-stdout
if invoke > "$tmp/stdout" 2> "$tmp/stderr"; then exit 1; else status=$?; fi
test "$status" -eq 7
test -f "$marker"
grep -F 'exited	wait_status	7' "$tmp/$case_id.tsv" >/dev/null
grep -F 'final	outcome	failed' "$tmp/$case_id.tsv" >/dev/null
if grep -F 'final	outcome	succeeded' "$tmp/$case_id.tsv" >/dev/null; then exit 1; fi
passed=$((passed + 1)); printf 'PASS %s\n' "$case_id"
request_for "$shell" "$tmp/private-fd.sh" "$marker"
check_pass receipt-fd-not-inherited
if grep -F FORGED "$tmp/receipt-fd-not-inherited.tsv" >/dev/null; then exit 1; fi

# Malformed binary requests must not be accepted with their NUL bytes discarded.
request_for "$shell" "$tmp/child.sh" "$marker"
printf 'bad\000argument\n' >> "$request"
check_blocked nul-in-request HC-REQUEST
request_for "$shell" "$tmp/child.sh" "$marker"
index=0
while [ "$index" -lt 260 ]; do printf 'argument\n' >> "$request"; index=$((index + 1)); done
check_blocked argument-count-limit HC-REQUEST

# Deleted/invalid request inputs must not be mistaken for an empty success.
rm "$request"
request=$tmp/no-request
check_blocked unreadable-request HC-REQUEST
printf 'SUMMARY shell=%s cases=%s failures=0\n' "$shell" "$passed"
