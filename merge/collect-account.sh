#!/bin/sh
set -eu

[ "$#" -eq 3 ] || {
    echo 'usage: merge/collect-account.sh OWNER REGISTRY.tsv OUTPUT_DIRECTORY' >&2
    exit 2
}

owner=$1
registry=$2
output=$3
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

command -v jq >/dev/null 2>&1 || {
    echo 'collect-account: jq is required' >&2
    exit 69
}

expected_header=$(printf 'repository\tpolicy')
header=$(sed -n '1p' "$registry")
[ "$header" = "$expected_header" ] || {
    echo 'collect-account: expected repository<TAB>policy header' >&2
    exit 1
}

mkdir -p "$output" "$output/managed"
manifest=$output/manifest.tsv
unmanaged=$output/unmanaged.tsv
summary=$output/summary.tsv
printf 'repository\tpr\tpolicy\n' > "$manifest"
printf 'repository\tpr\ttitle\treason\n' > "$unmanaged"

github_get() {
    path=$1
    if [ -n "${AICI_GITHUB_GET:-}" ]; then
        "$AICI_GITHUB_GET" "$path"
        return
    fi
    command -v curl >/dev/null 2>&1 || {
        echo 'collect-account: curl is required' >&2
        exit 69
    }
    token=${GITHUB_TOKEN:-${GH_TOKEN:-}}
    [ -n "$token" ] || {
        echo 'collect-account: set GITHUB_TOKEN or GH_TOKEN' >&2
        exit 69
    }
    curl -fsSL \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: Bearer $token" \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "https://api.github.com$path"
}

query=$(printf 'user:%s author:%s is:pr is:open' "$owner" "$owner" | jq -sRr @uri)
page=1
while [ "$page" -le 10 ]; do
    response=$output/search-$page.json
    github_get "/search/issues?q=$query&per_page=100&page=$page&sort=updated&order=desc" > "$response"
    count=$(jq '.items | length' "$response")

    jq -c '.items[] | select(.pull_request != null)' "$response" |
    while IFS= read -r item; do
        repository=$(printf '%s\n' "$item" | jq -r '.repository_url | sub("^https://api.github.com/repos/"; "")')
        pr=$(printf '%s\n' "$item" | jq -r '.number')
        title=$(printf '%s\n' "$item" | jq -r '.title | gsub("[\\t\\r\\n]"; " ")')
        policy=$(awk -F '\t' -v repository="$repository" '
            NR>1 && $1==repository { print $2; found=1; exit }
            END { if (!found) exit 1 }
        ' "$registry" 2>/dev/null || true)

        if [ -n "$policy" ]; then
            printf '%s\t%s\t%s\n' "$repository" "$pr" "$policy" >> "$manifest"
        else
            printf '%s\t%s\t%s\t%s\n' "$repository" "$pr" "$title" 'no-retirement-policy' >> "$unmanaged"
        fi
    done

    [ "$count" -lt 100 ] && break
    page=$((page + 1))
done

if [ "$(wc -l < "$manifest")" -gt 1 ]; then
    "$script_directory/collect-set.sh" "$manifest" "$output/managed" >/dev/null
else
    printf 'repository\tpr\tresult\n' > "$output/managed/results.tsv"
fi

printf 'repository\tpr\tstate\tdetail\n' > "$summary"
tail -n +2 "$output/managed/results.tsv" |
while IFS="$(printf '\t')" read -r repository pr result; do
    [ -n "$repository" ] || continue
    printf '%s\t%s\t%s\t%s\n' "$repository" "$pr" "$result" 'managed-by-ai-ci' >> "$summary"
done
tail -n +2 "$unmanaged" |
while IFS="$(printf '\t')" read -r repository pr title reason; do
    [ -n "$repository" ] || continue
    printf '%s\t%s\tUNMANAGED\t%s\n' "$repository" "$pr" "$reason" >> "$summary"
done

sed -n '1,$p' "$summary"
