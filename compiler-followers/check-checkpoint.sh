#!/bin/sh
# Run from the AICI repository root. This checks a proposal; it never edits a file.
set -eu
export GIT_NO_REPLACE_OBJECTS=1
fail() { echo "invalid checkpoint proposal: $*" >&2; exit 1; }
[ "$#" -ge 2 ] && [ "$#" -le 3 ] || fail "usage: check-checkpoint.sh TRUSTED_BASE_SHA UPSTREAM_HEAD [UPSTREAM_REF]"
base=$1
latest=$2
ref=${3:-main}
checkpoint=compiler-followers/arm-thumb.checkpoint
receipt=compiler-followers/arm-thumb-sweep
root=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
# The reviewed seed predates this policy on main. Never seed from the PR's value.
seed=5f132d2f68cdd5ee7ddd98788af882598ad4c2f8
sha_re='^[0-9a-f]{40}$'
printf '%s\n' "$base" | grep -Eq "$sha_re" || fail "bad trusted base SHA"
current=$(cat "$checkpoint")
printf '%s\n' "$current" | grep -Eq "$sha_re" || fail "bad checkpoint"
if [ "$base" = 0000000000000000000000000000000000000000 ]; then
  previous=$seed
else
  git cat-file -e "$base^{commit}" 2>/dev/null || fail "trusted base commit is unavailable"
  if git cat-file -e "$base:$checkpoint" 2>/dev/null; then
    previous=$(git show "$base:$checkpoint")
  elif git cat-file -e "$base:compiler-followers" 2>/dev/null; then
    fail "trusted base has follower policy but no checkpoint"
  else
    previous=$seed
  fi
fi
printf '%s\n' "$previous" | grep -Eq "$sha_re" || fail "bad checkpoint in trusted base"
expected_from=$previous
if [ "$current" != "$previous" ]; then
  [ "$ref" = main ] || fail "checkpoint proposals must target ARM/Thumb main"
  [ "$current" = "$latest" ] || fail "proposed checkpoint must equal the independently resolved upstream head"
else
  # A retained transition receipt may end at an already-reviewed checkpoint.
  # It is usable only while there is NO new upstream delta. Otherwise start at current.
  recorded_through=$(awk -F '\t' '$1 == "through" {print $2}' "$receipt/meta.tsv")
  if [ "$current" = "$latest" ] && [ "$recorded_through" = "$current" ]; then
    expected_from=$(awk -F '\t' '$1 == "from" {print $2}' "$receipt/meta.tsv")
  fi
fi
sh "$root/validate-sweep.sh" compiler-followers/policy.tsv "$receipt" "$expected_from" "$latest" "$ref"
printf 'checkpoint_base\t%s\ncheckpoint_proposed\t%s\n' "$previous" "$current"
