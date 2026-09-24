#!/bin/sh
set -eu

apply=no
if [ "${1:-}" = --apply ]; then
    apply=yes
    shift
fi

[ "$#" -eq 1 ] || {
    echo 'usage: merge/retire-ready.sh [--apply] ACCOUNT_OUTPUT_DIRECTORY' >&2
    exit 2
}

account_output=$1
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
results=$account_output/managed/results.tsv
[ -f "$results" ] || {
    printf 'retire-ready: missing %s\n' "$results" >&2
    exit 1
}

command -v jq >/dev/null 2>&1 || {
    echo 'retire-ready: jq is required' >&2
    exit 69
}

github_put() {
    path=$1
    payload=$2
    if [ -n "${AICI_GITHUB_PUT:-}" ]; then
        "$AICI_GITHUB_PUT" "$path" "$payload"
        return
    fi
    command -v curl >/dev/null 2>&1 || {
        echo 'retire-ready: curl is required' >&2
        exit 69
    }
    token=${GITHUB_TOKEN:-${GH_TOKEN:-}}
    [ -n "$token" ] || {
        echo 'retire-ready: set GITHUB_TOKEN or GH_TOKEN' >&2
        exit 69
    }
    curl -fsSL -X PUT \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: Bearer $token" \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        -H 'Content-Type: application/json' \
        --data "$payload" \
        "https://api.github.com$path"
}

state_command=${AICI_STATE_CMD:-"$script_directory/state.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

printf 'repository\tpr\thead\taction\tresult\n'
tab=$(printf '\t')
tail -n +2 "$results" |
while IFS="$tab" read -r repository pr result; do
    [ "$result" = READY ] || continue

    slug=$(printf '%s-%s' "$repository" "$pr" | tr '/' '-')
    snapshot=$account_output/managed/$slug
    [ -f "$snapshot/pr.tsv" ] || {
        printf 'retire-ready: missing snapshot for %s#%s\n' "$repository" "$pr" >&2
        exit 1
    }

    state_file=$work/state-$pr.tsv
    status=0
    "$state_command" "$snapshot" > "$state_file" || status=$?
    [ "$status" -eq 0 ] || {
        printf 'retire-ready: %s#%s is no longer READY\n' "$repository" "$pr" >&2
        exit 1
    }
    awk -F '\t' '
        NR==1 { next }
        $1=="READY" && $2=="READY" { ready++ }
        END { exit !(ready==1) }
    ' "$state_file" || {
        printf 'retire-ready: %s#%s did not reverify as READY\n' "$repository" "$pr" >&2
        exit 1
    }

    head=$(awk -F '\t' '$1=="head_sha" {print $2; found=1} END {if (!found) exit 1}' "$snapshot/pr.tsv")
    if [ "$apply" != yes ]; then
        printf '%s\t%s\t%s\tPLAN\tready-to-merge\n' "$repository" "$pr" "$head"
        continue
    fi

    payload=$(jq -n --arg sha "$head" '{sha:$sha, merge_method:"squash"}')
    response=$(github_put "/repos/$repository/pulls/$pr/merge" "$payload")
    merged=$(printf '%s\n' "$response" | jq -r '.merged // false')
    [ "$merged" = true ] || {
        message=$(printf '%s\n' "$response" | jq -r '.message // "merge rejected"')
        printf 'retire-ready: merge rejected for %s#%s: %s\n' "$repository" "$pr" "$message" >&2
        exit 1
    }
    merge_sha=$(printf '%s\n' "$response" | jq -r '.sha // "-"')
    printf '%s\t%s\t%s\tMERGED\t%s\n' "$repository" "$pr" "$head" "$merge_sha"
done
