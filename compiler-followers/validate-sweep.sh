#!/bin/sh
set -eu

policy=${1:-compiler-followers/policy.tsv}
receipt=${2:-compiler-followers/arm-thumb-sweep}
expected_from=${3:-$(tr -d '\r\n ' < compiler-followers/arm-thumb.checkpoint)}
expected_through=${4:-$(tr -d '\r\n ' < compiler-followers/arm-thumb.checkpoint)}
meta=$receipt/meta.tsv
classifications=$receipt/classifications.tsv

fail() {
  echo "invalid follower sweep: $*" >&2
  exit 1
}

sha_re='^[0-9a-f]{40}$'
printf '%s\n' "$expected_from" | grep -Eq "$sha_re" || fail "bad expected starting checkpoint"
printf '%s\n' "$expected_through" | grep -Eq "$sha_re" || fail "bad expected ending checkpoint"
[ -f "$meta" ] || fail "missing meta.tsv"
[ -f "$classifications" ] || fail "missing classifications.tsv"

tab=$(printf '\t')
get_meta() {
  key=$1
  value=$(awk -F '\t' -v key="$key" 'NR > 1 && $1 == key { count++; value=$2 } END { if (count == 1) print value; else exit 1 }' "$meta") ||
    fail "meta field $key must appear exactly once"
  [ -n "$value" ] || fail "empty meta field $key"
  printf '%s\n' "$value"
}

[ "$(sed -n '1p' "$meta")" = "field${tab}value" ] || fail "bad meta.tsv header"
[ "$(get_meta receipt_version)" = 1 ] || fail "unsupported receipt version"
repository=$(get_meta upstream_repository)
from=$(get_meta from)
through=$(get_meta through)
recorded_policy_hash=$(get_meta policy_sha256)
[ "$(get_meta coverage)" = full-policy-matrix ] || fail "receipt does not promise full policy coverage"
[ "$from" = "$expected_from" ] || fail "receipt starts at $from, expected $expected_from"
[ "$through" = "$expected_through" ] || fail "receipt ends at $through, expected $expected_through"
printf '%s\n' "$from" | grep -Eq "$sha_re" || fail "bad receipt starting commit"
printf '%s\n' "$through" | grep -Eq "$sha_re" || fail "bad receipt ending commit"
actual_policy_hash=$(sha256sum "$policy" | awk '{print $1}')
[ "$recorded_policy_hash" = "$actual_policy_hash" ] || fail "receipt was not made against this exact policy"

case "$repository" in
  *[!A-Za-z0-9._/-]*|/*|*..*|*//*|*/|'' ) fail "bad upstream repository" ;;
esac

cleanup=
if [ -n "${UPSTREAM_GIT:-}" ]; then
  upstream=$UPSTREAM_GIT
else
  cleanup=$(mktemp -d)
  upstream=$cleanup/upstream
  trap 'rm -rf "$cleanup"' EXIT HUP INT TERM
  git clone --quiet --filter=blob:none --no-checkout "https://github.com/$repository.git" "$upstream"
fi

git -C "$upstream" cat-file -e "$from^{commit}" 2>/dev/null || git -C "$upstream" fetch --quiet origin "$from"
git -C "$upstream" cat-file -e "$through^{commit}" 2>/dev/null || git -C "$upstream" fetch --quiet origin "$through"
git -C "$upstream" merge-base --is-ancestor "$from" "$through" || fail "starting commit is not an ancestor of ending commit"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp" ${cleanup:+"$cleanup"}' EXIT HUP INT TERM
git -C "$upstream" rev-list --reverse "$from..$through" > "$tmp/commits"
tail -n +2 "$policy" | cut -f1 > "$tmp/targets"

[ "$(sed -n '1p' "$classifications")" = "commit${tab}dimensions${tab}target${tab}outcome${tab}rationale" ] || fail "bad classifications.tsv header"
awk -F '\t' -v commits="$tmp/commits" -v targets="$tmp/targets" '
BEGIN {
  while ((getline line < commits) > 0) valid_commit[line] = 1
  while ((getline line < targets) > 0) valid_target[line] = 1
}
NR == 1 { next }
NF != 5 { print "bad classification field count on line " NR > "/dev/stderr"; exit 1 }
$1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" { print "empty classification field on line " NR > "/dev/stderr"; exit 1 }
!($1 in valid_commit) { print "classification names commit outside exact delta on line " NR > "/dev/stderr"; exit 1 }
$2 !~ /^[1-5](,[1-5])*$/ { print "bad change dimensions on line " NR > "/dev/stderr"; exit 1 }
!($3 in valid_target) { print "classification names target outside policy on line " NR > "/dev/stderr"; exit 1 }
$4 !~ /^(apply|adapt|already-covered|not-applicable|defer-measurement)$/ { print "bad outcome on line " NR > "/dev/stderr"; exit 1 }
seen[$1 SUBSEP $3]++ { print "duplicate commit/target classification on line " NR > "/dev/stderr"; exit 1 }
{ print $1 "\t" $3 }
' "$classifications" > "$tmp/actual-unsorted" || fail "classification syntax failed"
sort "$tmp/actual-unsorted" > "$tmp/actual"

: > "$tmp/expected"
while IFS= read -r commit; do
  while IFS= read -r target; do
    printf '%s\t%s\n' "$commit" "$target" >> "$tmp/expected"
  done < "$tmp/targets"
done < "$tmp/commits"
sort -o "$tmp/expected" "$tmp/expected"
cmp -s "$tmp/expected" "$tmp/actual" || fail "classification matrix is incomplete or contains excess rows"

commit_count=$(wc -l < "$tmp/commits" | tr -d ' ')
target_count=$(wc -l < "$tmp/targets" | tr -d ' ')
echo "valid follower sweep: $from..$through; $commit_count commits; $target_count policy rows"
