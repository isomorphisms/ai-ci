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
  source_path=${3:-sample.idric}
  git checkout -q -B "$name" "$base"
  printf '%s\n' "$content" >> "$source_path"
  git add "$source_path"
  git commit -q -m "$name"
  git rev-parse HEAD
}

expect_pass() {
  name=$1
  content=$2
  expected=${3:-}
  source_path=${4:-sample.idric}
  head=$(make_head "$name" "$content" "$source_path")
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

# The inherited language uses real Nat/Vect types and its own naming/arrows.
# This same text must still fail after crossing into the Idriç filename.
expect_pass idris_compat 'compilerCount : Nat
compilerCount = 1
compilerItems : Vect 3 Nat
compilerIdentity : Nat -> Nat
compilerIdentity value = value' '' sample.idr
if [ -s "$tmp/idris_compat.err" ]; then
  echo 'idris_compat: inherited source produced Idriç style diagnostics' >&2
  cat "$tmp/idris_compat.err" >&2
  exit 1
fi
compat_head=$head
git checkout -q -B idric_filename_boundary "$compat_head"
git mv sample.idr renamed.idric
git commit -q -m idric_filename_boundary
renamed_head=$(git rev-parse HEAD)
if sh "$checker" "$compat_head" "$renamed_head" 2>"$tmp/renamed.err"; then
  echo 'idric_filename_boundary: renamed Idriç source was not checked' >&2
  exit 1
fi
grep -F 'must not introduce Nat' "$tmp/renamed.err" >/dev/null
grep -F 'must not introduce Vect' "$tmp/renamed.err" >/dev/null

echo 'Idriç style self-test: PASS'
