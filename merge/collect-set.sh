#!/bin/sh
set -eu

[ "$#" -eq 2 ] || {
    echo 'usage: merge/collect-set.sh MANIFEST.tsv OUTPUT_DIRECTORY' >&2
    exit 2
}

manifest=$1
output=$2
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cache=$(mktemp -d)
trap 'rm -rf "$cache"' EXIT HUP INT TERM
mkdir -p "$output"

header=$(sed -n '1p' "$manifest")
expected_header=$(printf 'repository\tpr\tpolicy')
[ "$header" = "$expected_header" ] || {
    echo 'collect-set: expected repository<TAB>pr<TAB>policy header' >&2
    exit 1
}

printf 'repository\tpr\tresult\n' > "$output/results.tsv"
tab=$(printf '\t')
tail -n +2 "$manifest" | while IFS="$tab" read -r repository pr policy; do
    [ -n "$repository" ] || continue
    slug=$(printf '%s-%s' "$repository" "$pr" | tr '/' '-')
    snapshot=$output/$slug
    result=$snapshot/result.tsv
    mkdir -p "$snapshot"
    status=0
    AICI_GITHUB_CACHE=$cache \
        "$script_directory/collect-github.sh" "$repository" "$pr" "$policy" "$snapshot" > "$result" || status=$?
    case $status in
        0) verdict=READY ;;
        1) verdict=BLOCKED ;;
        *) printf 'collect-set: collection failed for %s#%s with status %s\n' "$repository" "$pr" "$status" >&2; exit "$status" ;;
    esac
    # Exit 1 can also mean API/policy failure before the classifier ran.
    # Only an actual classifier table establishes READY or BLOCKED.
    awk -F '\t' -v verdict="$verdict" '
        NR == 1 {
            if ($0 != "status\tcode\tobject_kind\tobject_ref\thead\taction\tdetail") bad=1
            next
        }
        { rows++; if (NF != 7 || $1 != verdict) bad=1 }
        END { exit bad || rows == 0 || (verdict == "READY" && rows != 1) }
    ' "$result" || {
        printf 'collect-set: no valid classifier result for %s#%s; collection failed\n' "$repository" "$pr" >&2
        exit 65
    }
    printf '%s\t%s\t%s\n' "$repository" "$pr" "$verdict" >> "$output/results.tsv"
done

sed -n '1,$p' "$output/results.tsv"
