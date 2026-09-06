#!/bin/sh
# Check coverage, not the truth of a review or target execution. Never write a checkpoint.
set -eu
export LC_ALL=C GIT_NO_REPLACE_OBJECTS=1

fail() {
  echo "invalid follower sweep: $*" >&2
  exit 1
}
[ "$#" -ge 4 ] && [ "$#" -le 5 ] ||
  fail "usage: validate-sweep.sh POLICY RECEIPT EXPECTED_FROM EXPECTED_THROUGH [EXPECTED_REF]"
policy=$1
receipt=$2
expected_from=$3
expected_through=$4
expected_ref=${5:-main}
root=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
sh "$root/validate-policy.sh" "$policy" || fail "invalid policy"
sha_re='^[0-9a-f]{40}$'
printf '%s\n' "$expected_from" | grep -Eq "$sha_re" || fail "bad expected starting checkpoint"
printf '%s\n' "$expected_through" | grep -Eq "$sha_re" || fail "bad expected ending checkpoint"
git check-ref-format "refs/heads/$expected_ref" >/dev/null || fail "bad expected upstream ref"
meta=$receipt/meta.tsv
classifications=$receipt/classifications.tsv
[ -f "$meta" ] || fail "missing meta.tsv"
[ -f "$classifications" ] || fail "missing classifications.tsv"
tab=$(printf '\t')
[ "$(sed -n '1p' "$meta")" = "field${tab}value" ] || fail "bad meta.tsv header"
awk -F '\t' '
NR == 1 { next }
NF != 2 || $2 !~ /[^[:space:]]/ { exit 1 }
$1 !~ /^(receipt_version|upstream_repository|upstream_ref|from|through|policy_sha256|coverage)$/ { exit 1 }
seen[$1]++ { exit 1 }
END { if (NR != 8) exit 1 }
' "$meta" || fail "metadata must contain exactly the seven unique version-2 fields"
get_meta() { awk -F '\t' -v key="$1" 'NR > 1 && $1 == key { print $2 }' "$meta"; }
[ "$(get_meta receipt_version)" = 2 ] || fail "unsupported receipt version"
# The receipt cannot choose its own upstream authority.
repository=isomorphisms/idric-arm-thumb
[ "$(get_meta upstream_repository)" = "$repository" ] || fail "wrong upstream authority"
[ "$(get_meta upstream_ref)" = "$expected_ref" ] || fail "receipt names a different upstream ref"
[ "$(get_meta coverage)" = full-policy-matrix ] || fail "receipt does not promise full policy coverage"
from=$(get_meta from)
through=$(get_meta through)
[ "$from" = "$expected_from" ] || fail "receipt starts at $from, expected $expected_from"
[ "$through" = "$expected_through" ] || fail "receipt ends at $through, expected $expected_through"
actual_policy_hash=$(sha256sum "$policy" | awk '{print $1}')
[ "$(get_meta policy_sha256)" = "$actual_policy_hash" ] || fail "receipt was not made against this exact policy"
# Validate the authority independently of receipt metadata and other policy rows.
awk -F '\t' '$1 == "arm-thumb" { if ($2 == "isomorphisms/idric-arm-thumb" && $3 == "main" && $4 == "cpu-codegen" && $5 == "authority-active" && $6 == "authority" && $7 == "exact" && $8 == "exact" && $9 == "primary") ok=1 } END { exit !ok }' "$policy" || fail "ARM/Thumb must remain the primary authority"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
if [ -n "${UPSTREAM_GIT:-}" ]; then
  upstream=$UPSTREAM_GIT
else
  upstream=$tmp/upstream
  git clone --quiet --filter=blob:none --no-checkout "https://github.com/$repository.git" "$upstream"
fi
# A supplied checkout is read-only: missing objects fail, rather than fetching into it.
[ "$(git -C "$upstream" rev-parse --is-shallow-repository)" = false ] || fail "shallow upstream history"
grafts=$(git -C "$upstream" rev-parse --path-format=absolute --git-path info/grafts)
[ ! -s "$grafts" ] || fail "grafted upstream history"
git -C "$upstream" cat-file -e "$from^{commit}" 2>/dev/null || fail "missing starting commit"
git -C "$upstream" cat-file -e "$through^{commit}" 2>/dev/null || fail "missing ending commit"
git -C "$upstream" merge-base --is-ancestor "$from" "$through" || fail "starting commit is not an ancestor of ending commit"
# Do not use --first-parent: merged-side commits and merge resolutions need review too.
git -C "$upstream" rev-list --reverse --topo-order "$from..$through" > "$tmp/commits"
tail -n +2 "$policy" | cut -f1 > "$tmp/targets"
[ "$(sed -n '1p' "$classifications")" = "commit${tab}dimensions${tab}target${tab}outcome${tab}rationale" ] || fail "bad classifications.tsv header"
awk -F '\t' -v commits="$tmp/commits" -v targets="$tmp/targets" '
BEGIN {
  while ((getline line < commits) > 0) valid_commit[line] = 1
  while ((getline line < targets) > 0) valid_target[line] = 1
}
NR == 1 { next }
NF != 5 { print "bad classification field count on line " NR > "/dev/stderr"; exit 1 }
$5 !~ /[^[:space:]]/ { print "empty rationale on line " NR > "/dev/stderr"; exit 1 }
!($1 in valid_commit) { print "commit outside exact delta on line " NR > "/dev/stderr"; exit 1 }
$2 !~ /^[1-5](,[1-5])*$/ { print "bad change dimensions on line " NR > "/dev/stderr"; exit 1 }
{
  n=split($2, dimensions, ",")
  for (i=2; i<=n; i++) if (dimensions[i] <= dimensions[i-1]) {
    print "dimensions must be unique and ascending on line " NR > "/dev/stderr"; exit 1
  }
  if (($1 in commit_dimensions) && commit_dimensions[$1] != $2) {
    print "inconsistent dimensions for commit on line " NR > "/dev/stderr"; exit 1
  }
  commit_dimensions[$1]=$2
}
!($3 in valid_target) { print "target outside policy on line " NR > "/dev/stderr"; exit 1 }
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

# Machine-readable output is produced only after every gate succeeds.
printf 'field\tvalue\nresult\tPASS\ncoverage\tfull-policy-matrix\n'
printf 'upstream_repository\t%s\nupstream_ref\t%s\nfrom\t%s\nthrough\t%s\n' "$repository" "$expected_ref" "$from" "$through"
printf 'policy_sha256\t%s\nclassifications_sha256\t%s\n' "$actual_policy_hash" "$(sha256sum "$classifications" | awk '{print $1}')"
printf 'commit_count\t%s\npolicy_row_count\t%s\nclassification_count\t%s\n' "$(wc -l < "$tmp/commits" | tr -d ' ')" "$(wc -l < "$tmp/targets" | tr -d ' ')" "$(wc -l < "$tmp/actual" | tr -d ' ')"
printf 'checkpoint_action\tread-only\nmerge_readiness\tnot-asserted\ntarget_execution\tnot-asserted\n'
