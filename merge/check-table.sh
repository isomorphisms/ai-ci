#!/bin/sh
set -eu

[ "$#" -eq 2 ] || {
    echo 'usage: merge/check-table.sh STATE CHECKS' >&2
    exit 2
}

state_file=$1
checks_file=$2

head_sha=$(awk -F '	' '$1=="head_sha" {print $2; exit}' "$state_file")
base_sha=$(awk -F '	' '$1=="live_base_sha" {print $2; exit}' "$state_file")
[ -n "$head_sha" ] || {
    printf 'check-table: state has no head_sha\n' >&2
    exit 1
}

printf 'HEAD        %s\n\n' "$head_sha"
printf '%-29s %s\n' check state
printf '%-29s %s\n' --------------------------- --------

awk -F '	' -v head="$head_sha" -v base="$base_sha" '
NR==1 { next }
/^[[:space:]]*(#|$)/ { next }
{
    state="UNKNOWN"
    if ($7=="missing" || $4=="-") state="ABSENT"
    else if ($6!="head" || $9!=head || $10!=head || ($12=="no" && $11!=base)) state="STALE"
    else if ($8=="success" && $7=="completed") state="PASS"
    else if ($8=="failure" || $8=="timed_out") state="FAIL"
    else if ($8=="cancelled") state="CANCELLED"
    else if ($8=="skipped") state="SKIPPED"
    printf "%-29s %s\n", $2, state
}
' "$checks_file"
