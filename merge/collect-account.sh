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

mkdir -p "$output" "$output/managed"
# Invalidate a previous run before any fallible collection or validation.
printf 'schema\taici-account-collection-v1\nstatus\tINCOMPLETE\n' > "$output/collection.tsv"
command -v sha256sum >/dev/null 2>&1 || {
    echo 'collect-account: sha256sum is required' >&2
    exit 69
}
command -v jq >/dev/null 2>&1 || {
    echo 'collect-account: jq is required' >&2
    exit 69
}

case $owner in
    ''|*[!A-Za-z0-9-]*)
        echo 'collect-account: OWNER must be a GitHub account name' >&2
        exit 1
        ;;
esac

expected_header=$(printf 'repository\tpolicy')
header=$(sed -n '1p' "$registry")
[ "$header" = "$expected_header" ] || {
    echo 'collect-account: expected repository<TAB>policy header' >&2
    exit 1
}

awk -F '\t' '
    NR == 1 { next }
    NF != 2 || $1 !~ /^[A-Za-z0-9_-]+\/[A-Za-z0-9_.-]+$/ ||
    $2 == "" || seen[$1]++ { bad=1 }
    END { exit bad }
' "$registry" || {
    echo 'collect-account: malformed or duplicate registry entry' >&2
    exit 1
}
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
discovered=0
expected=
while [ "$page" -le 10 ]; do
    response=$output/search-$page.json
    github_get "/search/issues?q=$query&per_page=100&page=$page&sort=updated&order=desc" > "$response"
    jq -e '
        type == "object" and .incomplete_results == false and
        (.total_count | type == "number" and . >= 0 and . == floor and . <= 1000) and
        (.items | type == "array" and length <= 100) and
        all(.items[];
            (.pull_request | type == "object") and
            (.number | type == "number" and . > 0 and . == floor) and
            (.title | type == "string") and
            (.repository_url | type == "string" and
                test("^https://api[.]github[.]com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_.-]+$")))
    ' "$response" >/dev/null || {
        echo 'collect-account: incomplete, malformed, or search-limited response; recollect before retirement' >&2
        exit 1
    }
    total=$(jq -r '.total_count' "$response")
    count=$(jq -r '.items | length' "$response")
    [ -n "$expected" ] || expected=$total
    [ "$total" -eq "$expected" ] || {
        echo 'collect-account: search total changed during pagination; recollect' >&2
        exit 1
    }
    remaining=$((expected - discovered))
    wanted=$remaining
    [ "$wanted" -le 100 ] || wanted=100
    [ "$count" -eq "$wanted" ] || {
        echo 'collect-account: search page does not match the reported total' >&2
        exit 1
    }

    jq -c '.items[]' "$response" > "$output/items.jsonl"
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
    done < "$output/items.jsonl"

    discovered=$((discovered + count))
    [ "$discovered" -eq "$expected" ] && break
    page=$((page + 1))
done

awk -F '\t' '
    FNR == 1 { next }
    seen[$1 SUBSEP $2]++ { bad=1 }
    END { exit bad }
' "$manifest" "$unmanaged" || {
    echo 'collect-account: duplicate PR in paginated search; recollect' >&2
    exit 1
}

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

# The consumer checks these exact tables before making a completion decision.
# This records completeness in the declared search scope, not live merge authority.
managed_digest=$(sha256sum "$output/managed/results.tsv")
managed_digest=${managed_digest%% *}
unmanaged_digest=$(sha256sum "$unmanaged")
unmanaged_digest=${unmanaged_digest%% *}
printf '%s\t%s\n' \
    schema aici-account-collection-v1 \
    status COMPLETE \
    scope owner-authored-owner-repositories \
    owner "$owner" \
    expected_prs "$expected" \
    discovered_prs "$discovered" \
    managed_sha256 "$managed_digest" \
    unmanaged_sha256 "$unmanaged_digest" > "$output/collection.tmp"
mv "$output/collection.tmp" "$output/collection.tsv"

sed -n '1,$p' "$summary"
