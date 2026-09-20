#!/bin/sh
set -eu

[ "$#" -eq 4 ] || {
    echo 'usage: merge/collect-github.sh OWNER/REPOSITORY PR POLICY_DIRECTORY OUTPUT_DIRECTORY' >&2
    exit 2
}

repository=$1
pr_number=$2
policy=$3
output=$4
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repository_root=${AICI_REPOSITORY_ROOT:-}
if [ -z "$repository_root" ]; then
    repository_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
fi

case $repository in
    */*) ;;
    *) echo 'collector: repository must be OWNER/NAME' >&2; exit 2 ;;
esac
case $pr_number in
    ''|*[!0-9]*) echo 'collector: PR must be a positive integer' >&2; exit 2 ;;
esac

for name in settings checks evidence dependencies followers authorization; do
    test -f "$policy/$name.tsv" || {
        printf 'collector: policy is missing %s.tsv\n' "$name" >&2
        exit 1
    }
done

command -v jq >/dev/null 2>&1 || {
    echo 'collector: jq is required for the GitHub JSON interface' >&2
    exit 69
}

setting() {
    awk -F '\t' -v key="$1" '$1==key {print $2; found=1} END {if (!found) exit 1}' "$policy/settings.tsv"
}

[ "$(setting schema)" = aici-merge-collection-policy-v2 ] || {
    echo 'collector: unsupported settings schema' >&2
    exit 1
}
[ "$(setting repository)" = "$repository" ] || {
    echo 'collector: repository differs from policy' >&2
    exit 1
}

github_get() {
    path=$1
    if [ -n "${AICI_GITHUB_GET:-}" ]; then
        "$AICI_GITHUB_GET" "$path"
        return
    fi
    command -v curl >/dev/null 2>&1 || {
        echo 'collector: curl is required' >&2
        exit 69
    }
    token=${GITHUB_TOKEN:-${GH_TOKEN:-}}
    [ -n "$token" ] || {
        echo 'collector: set GITHUB_TOKEN or GH_TOKEN' >&2
        exit 69
    }
    curl -fsSL \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: Bearer $token" \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "https://api.github.com$path"
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
mkdir -p "$output"

github_get "/repos/$repository/pulls/$pr_number" > "$work/pr.json"
head_sha=$(jq -er '.head.sha' "$work/pr.json")
base_ref=$(jq -er '.base.ref' "$work/pr.json")
reported_base_sha=$(jq -er '.base.sha' "$work/pr.json")
title=$(jq -er '.title | gsub("[\\t\\r\\n]"; " ")' "$work/pr.json")
draft=$(jq -er 'if .draft then "yes" else "no" end' "$work/pr.json")
mergeable=$(jq -er 'if .mergeable == true then "yes" elif .mergeable == false then "no" else "unknown" end' "$work/pr.json")

github_get "/repos/$repository/branches/$base_ref" > "$work/base.json"
live_base_sha=$(jq -er '.commit.sha' "$work/base.json")
github_get "/repos/$repository/commits/$head_sha/check-runs?per_page=100" > "$work/head-checks.json"
github_get "/repos/$repository/commits/$live_base_sha/check-runs?per_page=100" > "$work/base-checks.json"

conflict_paths=-
changed_path_overlap=no
if [ "$mergeable" = no ]; then
    conflict_paths=unknown
    changed_path_overlap=unknown
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
       git cat-file -e "${head_sha}^{commit}" 2>/dev/null &&
       git cat-file -e "${live_base_sha}^{commit}" 2>/dev/null; then
        common=$(git merge-base "$live_base_sha" "$head_sha")
        index=$work/merge-index
        GIT_INDEX_FILE=$index git read-tree -m "$common" "$live_base_sha" "$head_sha" 2>/dev/null || true
        paths=$(GIT_INDEX_FILE=$index git ls-files --unmerged 2>/dev/null |
            awk '{print $4}' | sort -u | paste -sd, -)
        if [ -n "$paths" ]; then
            conflict_paths=$paths
            changed_path_overlap=yes
        fi
    fi
fi

printf '%s\n' \
    'schema\taici-pr-observation-v1' \
    "repository\t$repository" \
    "pr\t$pr_number" \
    "title\t$title" \
    "head_sha\t$head_sha" \
    "base_ref\t$base_ref" \
    "live_base_sha\t$live_base_sha" \
    "reported_base_sha\t$reported_base_sha" \
    "draft\t$draft" \
    "mergeable\t$mergeable" \
    "conflict_paths\t$conflict_paths" \
    "changed_path_overlap\t$changed_path_overlap" \
    "auto_reconcile\t$(setting auto_reconcile)" \
    "promotion_state\t$(setting promotion_state)" \
    "promotion_condition\t$(setting promotion_condition)" \
    "promotion_action\t$(setting promotion_action)" \
    "promotion_evidence_class\t$(setting promotion_evidence_class)" |
    awk '{gsub(/\\t/,"\t"); print}' > "$output/pr.tsv"

printf '%s\n' 'name\trequired\trun_ref\tobserved_head\tcheckout_sha\ttested_base_sha\tbase_independent\tbinding\tstatus\tconclusion\ttrigger_coverage\tfailure_class\tbaseline_ref\taction' |
    awk '{gsub(/\\t/,"\t"); print}' > "$output/checks.tsv"

tab=$(printf '\t')
tail -n +2 "$policy/checks.tsv" | while IFS="$tab" read -r name workflow required base_independent binding trigger_coverage action; do
    [ -n "$name" ] || continue
    effective_binding=$binding
    workflow_path=$repository_root/$workflow
    if [ "$binding" = head ] &&
       ! "$script_directory/check-workflow-head.sh" "$workflow_path" > "$work/workflow-head.out"; then
        effective_binding=unknown
    fi
    count=$(jq --arg name "$name" '[.check_runs[] | select(.name==$name)] | length' "$work/head-checks.json")
    if [ "$count" -eq 0 ]; then
        printf '%s\t%s\t-\t-\t-\t-\t%s\t%s\tmissing\t-\t%s\t-\t-\t%s\n' \
            "$name" "$required" "$base_independent" "$effective_binding" "$trigger_coverage" "$action" >> "$output/checks.tsv"
        continue
    fi
    if [ "$count" -ne 1 ]; then
        printf '%s\t%s\tcheck-collision\t%s\t-\t-\t%s\tunknown\tcompleted\tneutral\t%s\tunknown\t-\tinspect-check-collision\n' \
            "$name" "$required" "$head_sha" "$base_independent" "$trigger_coverage" >> "$output/checks.tsv"
        continue
    fi
    check=$(jq -c --arg name "$name" '.check_runs[] | select(.name==$name)' "$work/head-checks.json")
    run_ref=$(printf '%s\n' "$check" | jq -r '.details_url // ("check-run-" + (.id|tostring))')
    observed_head=$(printf '%s\n' "$check" | jq -r '.head_sha')
    status=$(printf '%s\n' "$check" | jq -r '.status')
    conclusion=$(printf '%s\n' "$check" | jq -r '.conclusion // "-"')
    checkout_sha=-
    [ "$effective_binding" = head ] && checkout_sha=$observed_head
    tested_base_sha=-
    [ "$base_independent" = yes ] || tested_base_sha=$reported_base_sha
    failure_class=-
    baseline_ref=-
    if [ "$conclusion" = failure ] || [ "$conclusion" = timed_out ]; then
        base_count=$(jq --arg name "$name" '[.check_runs[] | select(.name==$name)] | length' "$work/base-checks.json")
        if [ "$base_count" -eq 1 ]; then
            base_check=$(jq -c --arg name "$name" '.check_runs[] | select(.name==$name)' "$work/base-checks.json")
            base_conclusion=$(printf '%s\n' "$base_check" | jq -r '.conclusion // "-"')
            baseline_ref=$(printf '%s\n' "$base_check" | jq -r '.details_url // ("check-run-" + (.id|tostring))')
            case $base_conclusion in
                success) failure_class=pr ;;
                failure|timed_out) failure_class=baseline ;;
                *) failure_class=unknown ;;
            esac
        else
            failure_class=unknown
        fi
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$name" "$required" "$run_ref" "$observed_head" "$checkout_sha" \
        "$tested_base_sha" "$base_independent" "$effective_binding" "$status" "$conclusion" \
        "$trigger_coverage" "$failure_class" "$baseline_ref" "$action" >> "$output/checks.tsv"
done

cp "$policy/evidence.tsv" "$output/evidence.tsv"
cp "$policy/dependencies.tsv" "$output/dependencies.tsv"
cp "$policy/followers.tsv" "$output/followers.tsv"
cp "$policy/authorization.tsv" "$output/authorization.tsv"

if [ "${AICI_STATE_ONLY:-0}" = 1 ]; then
    printf 'snapshot\t%s\thead\t%s\tapi_queries\t4\n' "$output" "$head_sha"
    exit 0
fi

exec "$script_directory/state.sh" "$output"
