#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
checker="$root/check_added_source"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

cd "$tmp"
git init -q
git config user.name 'ai-ci self-test'
git config user.email 'aici@example.invalid'

cat > sample.idric <<'EOF'
legacy_count : Nat
legacy_count = 0
EOF

git add sample.idric
git commit -q -m base
base=$(git rev-parse HEAD)

make_head() {
  name=$1
  content=$2
  git checkout -q -B "$name" "$base"
  printf '%s\n' "$content" >> sample.idric
  git add sample.idric
  git commit -q -m "$name"
  git rev-parse HEAD
}

expect_pass() {
  name=$1
  content=$2
  expected=${3:-}
  head=$(make_head "$name" "$content")
  err="$tmp/$name.err"
  if ! sh "$checker" "$base" "$head" 2>"$err"; then
    echo "$name: checker rejected source that should pass" >&2
    cat "$err" >&2
    exit 1
  fi
  if [ -n "$expected" ] && ! grep -F "$expected" "$err" >/dev/null; then
    echo "$name: expected warning was not emitted: $expected" >&2
    cat "$err" >&2
    exit 1
  fi
}

expect_fail() {
  name=$1
  content=$2
  expected=$3
  head=$(make_head "$name" "$content")
  err="$tmp/$name.err"
  if sh "$checker" "$base" "$head" 2>"$err"; then
    echo "$name: checker accepted source that should fail" >&2
    cat "$err" >&2
    exit 1
  fi
  if ! grep -F "$expected" "$err" >/dev/null; then
    echo "$name: expected error was not emitted: $expected" >&2
    cat "$err" >&2
    exit 1
  fi
}

expect_pass good 'identity : Number → Number
identity value = value'
expect_fail nat 'new_count : Nat
new_count = 1' 'must not introduce Nat'
expect_fail vect 'items : Vect 3 Number' 'must not introduce Vect'
expect_pass camel 'readRequest : Number → Number
readRequest value = value' 'lowerCamelCase is an Idriç style canary'
expect_pass ascii_arrow 'identity_ascii : Number -> Number
identity_ascii value = value' 'ASCII arrows are an Idriç style canary'
expect_pass comment_only '-- Nat Vect readRequest -> <-'

echo 'Idriç style self-test: PASS'
