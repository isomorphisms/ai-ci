#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
consumer=${1:-"$root/merge/retire-ready.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

account=$work/account
mkdir -p "$account/managed/isomorphisms-example-7"
printf '%b\n' \
  'repository\tpr\tresult' \
  'isomorphisms/example\t7\tREADY' \
  'isomorphisms/example\t8\tBLOCKED' > "$account/managed/results.tsv"
printf '%b\n' \
  'schema\taici-pr-observation-v1' \
  'head_sha\t1111111111111111111111111111111111111111' > "$account/managed/isomorphisms-example-7/pr.tsv"

cat > "$work/state-ready" <<'STATE'
#!/bin/sh
printf '%b\n' \
  'status\tcode\tobject_kind\tobject_ref\thead\taction\tdetail' \
  'READY\tREADY\tpr\tisomorphisms/example#7\t1111111111111111111111111111111111111111\tmerge\tall-required-conditions-satisfied'
STATE
chmod +x "$work/state-ready"

cat > "$work/put" <<'PUT'
#!/bin/sh
set -eu
: "${RETIRE_TEST_LOG:?}"
printf '%s\t%s\n' "$1" "$2" >> "$RETIRE_TEST_LOG"
printf '%s\n' '{"merged":true,"sha":"2222222222222222222222222222222222222222","message":"merged"}'
PUT
chmod +x "$work/put"

RETIRE_TEST_LOG=$work/put.log AICI_STATE_CMD=$work/state-ready AICI_GITHUB_PUT=$work/put \
  "$consumer" "$account" > "$work/plan.tsv"
grep -F $'isomorphisms/example\t7\t1111111111111111111111111111111111111111\tPLAN\tready-to-merge' "$work/plan.tsv" >/dev/null
[ ! -e "$work/put.log" ] || {
    echo 'FAIL: planning mode performed a merge' >&2
    exit 1
}

RETIRE_TEST_LOG=$work/put.log AICI_STATE_CMD=$work/state-ready AICI_GITHUB_PUT=$work/put \
  "$consumer" --apply "$account" > "$work/apply.tsv"
grep -F $'isomorphisms/example\t7\t1111111111111111111111111111111111111111\tMERGED\t2222222222222222222222222222222222222222' "$work/apply.tsv" >/dev/null
[ "$(wc -l < "$work/put.log")" -eq 1 ] || {
    echo 'FAIL: retire-ready merged anything other than the single READY PR' >&2
    exit 1
}
grep -F '/repos/isomorphisms/example/pulls/7/merge' "$work/put.log" >/dev/null
! grep -F '/pulls/8/merge' "$work/put.log" >/dev/null

cat > "$work/state-blocked" <<'STATE'
#!/bin/sh
printf '%b\n' \
  'status\tcode\tobject_kind\tobject_ref\thead\taction\tdetail' \
  'BLOCKED\tCI_PENDING\tcheck\tverify\t1111111111111111111111111111111111111111\twait-check\trun=9'
exit 1
STATE
chmod +x "$work/state-blocked"
: > "$work/put.log"
status=0
RETIRE_TEST_LOG=$work/put.log AICI_STATE_CMD=$work/state-blocked AICI_GITHUB_PUT=$work/put \
  "$consumer" --apply "$account" > "$work/stale.out" 2> "$work/stale.err" || status=$?
[ "$status" -ne 0 ]
[ ! -s "$work/put.log" ] || {
    echo 'FAIL: retire-ready merged after READY revalidation failed' >&2
    exit 1
}

printf '%s\n' 'PASS: PR retirement merges only reverified READY heads'
