#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
checker="$root/check_added_source"
event_checker="$root/check_event_range"
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

expect_event() {
  name=$1
  expected_status=$2
  expected_diagnostic=$3
  event=$4
  pr_base=$5
  push_before=$6
  explicit_base=$7
  selected_head=$8
  event_head=${9-$selected_head}
  actual_status=0
  if AICI_EVENT_NAME="$event" \
      AICI_PR_BASE_SHA="$pr_base" \
      AICI_PR_HEAD_SHA="$event_head" \
      AICI_PUSH_BEFORE_SHA="$push_before" \
      AICI_IDRIC_STYLE_BASE="$explicit_base" \
      AICI_IDRIC_STYLE_HEAD="$selected_head" \
      sh "$event_checker" 2>"$tmp/$name.err"; then
    actual_status=0
  else
    actual_status=$?
  fi
  if [ "$actual_status" -ne "$expected_status" ] ||
      { [ -n "$expected_diagnostic" ] && ! grep -Fq "$expected_diagnostic" "$tmp/$name.err"; }; then
    printf '%s\n' "$name: expected status $expected_status, observed $actual_status" >&2
    cat "$tmp/$name.err" >&2
    exit 1
  fi
}

early_bad=$(make_head pr-early-violation 'new_count : Nat
new_count = 1')
printf '\n%s\n' '-- harmless follow-up' >> sample.idric
git commit -qam pr-harmless-follow-up
pr_head=$(git rev-parse HEAD)

# The former HEAD^ fallback inspects only this harmless last commit.
sh "$checker" "$early_bad" "$pr_head"
expect_event pr_complete 1 'must not introduce Nat' pull_request "$base" '' '' "$pr_head"
expect_event pr_checked_out_head 1 'must not introduce Nat' pull_request "$base" '' '' HEAD "$pr_head"
expect_event pr_earlier_head 2 'comparison head must resolve to the submitted pull request head' \
  pull_request "$base" '' '' "$base" "$pr_head"
expect_event pr_missing_event_head 2 'pull request head commit is unavailable' \
  pull_request "$base" '' '' "$pr_head" ''
expect_event pr_unavailable_event_head 2 'pull request head commit is unavailable' \
  pull_request "$base" '' '' "$pr_head" 1111111111111111111111111111111111111111
expect_event pr_same_explicit_base 1 'must not introduce Nat' pull_request "$base" '' "$base" "$pr_head"
expect_event pr_narrow_explicit_base 2 'explicit base must resolve to the pull request event base' \
  pull_request "$base" '' "$early_bad" "$pr_head"
expect_event pr_missing_base 2 'pull request base commit is unavailable' \
  pull_request '' "$base" '' "$pr_head"
expect_event pr_unavailable_base 2 'pull request base commit is unavailable' \
  pull_request 1111111111111111111111111111111111111111 '' '' "$pr_head"
expect_event pr_zero_base 2 'pull request base commit is unavailable' \
  pull_request 0000000000000000000000000000000000000000 '' '' "$pr_head"
expect_event push_complete 1 'must not introduce Nat' push '' "$base" '' "$pr_head"
expect_event push_explicit 0 '' push '' "$base" "$early_bad" "$pr_head"
expect_event push_zero_base 0 '' push '' 0000000000000000000000000000000000000000 '' "$pr_head"
expect_event push_unavailable_base 0 '' push '' 1111111111111111111111111111111111111111 '' "$pr_head"

benign_head=$(make_head pr-benign '-- an ordinary PR comment')
expect_event pr_benign 0 '' pull_request "$base" '' '' "$benign_head"
git checkout -q -B moved-base "$base"
sed 's/Nat/Number/' sample.idric > sample.changed
mv sample.changed sample.idric
git commit -qam 'clean up inherited vocabulary on the base branch'
moved_base=$(git rev-parse HEAD)
if sh "$checker" "$moved_base" "$benign_head" 2>"$tmp/two_trees.err"; then
  printf '%s\n' 'two_trees: comparison did not expose the inherited line as an addition' >&2
  exit 1
fi
grep -F 'must not introduce Nat' "$tmp/two_trees.err" >/dev/null
expect_event pr_moved_base 0 '' pull_request "$moved_base" '' '' "$benign_head"

synthetic_head=$(git commit-tree "$pr_head^{tree}" -p "$moved_base" -p "$pr_head" -m synthetic)
git checkout -q --detach "$synthetic_head"
expect_event pr_synthetic_checkout 2 'comparison head must resolve to the submitted pull request head' \
  pull_request "$moved_base" '' '' HEAD "$pr_head"

if sh "$checker" 1111111111111111111111111111111111111111 "$benign_head" 2>"$tmp/invalid_diff.err"; then
  printf '%s\n' 'invalid_diff: checker accepted an unavailable comparison commit' >&2
  exit 1
fi

echo 'Idriç style self-test: PASS'
