#!/bin/sh
set -eu

[ "$#" -eq 4 ] || {
    echo 'usage: merge/collect-verdict.sh OWNER/REPOSITORY PR POLICY_DIRECTORY OUTPUT_DIRECTORY' >&2
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

case $repository in */*) ;; *) echo 'verdict collector: repository must be OWNER/NAME' >&2; exit 2 ;; esac
case $pr_number in ''|*[!0-9]*) echo 'verdict collector: PR must be a positive integer' >&2; exit 2 ;; esac

for name in settings checks dependencies receipts scope consumer authority blockers schedules completion; do
    test -f "$policy/$name.tsv" || {
        printf 'verdict collector: policy is missing %s.tsv\n' "$name" >&2
        exit 1
    }
done
for command_name in awk git jq sha256sum sort; do
    command -v "$command_name" >/dev/null 2>&1 || {
        printf 'verdict collector: %s is required\n' "$command_name" >&2
        exit 69
    }
done

setting() {
    awk -F '\t' -v key="$1" '$1==key {print $2; found=1} END {if (!found) exit 1}' "$policy/settings.tsv"
}

[ "$(setting schema)" = aici-merge-verdict-collection-policy-v1 ] || {
    echo 'verdict collector: unsupported settings schema' >&2
    exit 1
}
[ "$(setting repository)" = "$repository" ] || {
    echo 'verdict collector: repository differs from policy' >&2
    exit 1
}

github_fetch() {
    path=$1
    if [ -n "${AICI_GITHUB_GET:-}" ]; then
        "$AICI_GITHUB_GET" "$path"
        return
    fi
    command -v curl >/dev/null 2>&1 || {
        echo 'verdict collector: curl is required' >&2
        exit 69
    }
    token=${GITHUB_TOKEN:-${GH_TOKEN:-}}
    [ -n "$token" ] || {
        echo 'verdict collector: set GITHUB_TOKEN or GH_TOKEN' >&2
        exit 69
    }
    curl -fsSL \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: Bearer $token" \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "https://api.github.com$path"
}

github_get() {
    path=$1
    if [ -z "${AICI_GITHUB_CACHE:-}" ]; then
        github_fetch "$path"
        return
    fi
    mkdir -p "$AICI_GITHUB_CACHE"
    key=$(printf '%s' "$path" | cksum | awk '{print $1 "-" $2}')
    cached=$AICI_GITHUB_CACHE/$key.response
    if [ -f "$cached" ]; then
        sed -n '1,$p' "$cached"
        return
    fi
    github_fetch "$path" | tee "$cached"
}

ensure_commit() {
    revision=$1
    if git -C "$repository_root" cat-file -e "${revision}^{commit}" 2>/dev/null; then
        return
    fi
    [ "${AICI_NO_FETCH:-0}" != 1 ] || {
        printf 'verdict collector: local repository lacks commit %s\n' "$revision" >&2
        exit 1
    }
    git -C "$repository_root" fetch --no-tags --filter=blob:none origin "$revision" >/dev/null 2>&1 || {
        printf 'verdict collector: cannot fetch commit %s\n' "$revision" >&2
        exit 1
    }
    git -C "$repository_root" cat-file -e "${revision}^{commit}" 2>/dev/null || {
        printf 'verdict collector: fetched object is not a commit: %s\n' "$revision" >&2
        exit 1
    }
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
ensure_commit "$head_sha"
ensure_commit "$live_base_sha"

stack_parent_pr=$(setting stack_parent_pr)
stack_parent_expected_sha=$(setting stack_parent_expected_sha)
stack_parent_state=none
stack_parent_current_sha=-
scope_base_sha=$live_base_sha
if [ "$stack_parent_pr" != - ]; then
    github_get "/repos/$repository/pulls/$stack_parent_pr" > "$work/parent.json"
    stack_parent_current_sha=$(jq -er '.head.sha' "$work/parent.json")
    ensure_commit "$stack_parent_current_sha"
    if [ "$(jq -r '.merged' "$work/parent.json")" = true ]; then
        stack_parent_state=landed
    else
        stack_parent_state=open
    fi
    scope_base_sha=$stack_parent_current_sha
fi

merge_base_sha=$(git -C "$repository_root" merge-base "$scope_base_sha" "$head_sha")
merge_tree_status=0
git -C "$repository_root" merge-tree --write-tree "$live_base_sha" "$head_sha" > "$work/merge-tree.out" 2> "$work/merge-tree.err" || merge_tree_status=$?
if [ "$merge_tree_status" -eq 0 ]; then
    prospective_tree=$(sed -n '1p' "$work/merge-tree.out")
else
    prospective_tree=$(git -C "$repository_root" rev-parse "${head_sha}^{tree}")
fi

git -C "$repository_root" diff --binary --full-index --no-renames "$live_base_sha" "$prospective_tree" > "$output/prospective.diff"
git -C "$repository_root" diff --name-only --no-renames "$live_base_sha" "$prospective_tree" | LC_ALL=C sort -u > "$output/changed-paths.txt"
prospective_diff_sha256=$(sha256sum "$output/prospective.diff" | awk '{print $1}')
changed_paths_sha256=$(sha256sum "$output/changed-paths.txt" | awk '{print $1}')
diff_files=$(awk 'END {print NR}' "$output/changed-paths.txt")
set -- $(git -C "$repository_root" diff --numstat --no-renames "$live_base_sha" "$prospective_tree" | awk '
    { files++; if ($1!="-") additions+=$1; if ($2!="-") deletions+=$2 }
    END { print additions+0, deletions+0 }
')
diff_additions=$1
diff_deletions=$2

intent_file=$(setting intent_file)
case $intent_file in ''|/*|../*|*/../*|*/..) echo 'verdict collector: intent_file must stay inside the policy directory' >&2; exit 1 ;; esac
test -f "$policy/$intent_file" || {
    printf 'verdict collector: missing intent file: %s\n' "$intent_file" >&2
    exit 1
}
intent_sha256=$(sha256sum "$policy/$intent_file" | awk '{print $1}')
current_scope_sha256=$(printf '%s\t%s\n' "$intent_sha256" "$changed_paths_sha256" | sha256sum | awk '{print $1}')

event_sha=${AICI_EVENT_SHA:-$head_sha}
event_kind=${AICI_EVENT_KIND:-head}
cat > "$output/state.tsv" <<EOF
schema	aici-merge-state-v4
repository	$repository
pr	$pr_number
title	$title
head_sha	$head_sha
event_sha	$event_sha
event_kind	$event_kind
live_base_ref	$base_ref
live_base_sha	$live_base_sha
reported_base_sha	$reported_base_sha
merge_base_sha	$merge_base_sha
scope_base_sha	$scope_base_sha
prospective_diff_sha256	$prospective_diff_sha256
changed_paths_sha256	$changed_paths_sha256
intent_sha256	$intent_sha256
current_scope_sha256	$current_scope_sha256
diff_files	$diff_files
diff_additions	$diff_additions
diff_deletions	$diff_deletions
draft	$draft
mergeable	$mergeable
job_kind	$(setting job_kind)
job_state	$(setting job_state)
stack_parent_pr	$stack_parent_pr
stack_parent_state	$stack_parent_state
stack_parent_expected_sha	$stack_parent_expected_sha
stack_parent_current_sha	$stack_parent_current_sha
EOF

printf '%s\n' 'id	state	evidence' > "$output/blockers.tsv"
awk -F '\t' 'NR>1 && $0 !~ /^[[:space:]]*(#|$)/ {print}' "$policy/blockers.tsv" >> "$output/blockers.tsv"
if [ "$merge_tree_status" -ne 0 ]; then
    printf 'live-merge-conflict\tOPEN\tgit-merge-tree-exit-%s\n' "$merge_tree_status" >> "$output/blockers.tsv"
fi

github_get "/repos/$repository/rulesets?includes_parents=true" > "$work/rulesets.json"
: > "$work/required-contexts.txt"
for ruleset_id in $(jq -r '.[] | select(.enforcement=="active" and .target=="branch") | .id' "$work/rulesets.json"); do
    github_get "/repos/$repository/rulesets/$ruleset_id" > "$work/ruleset-$ruleset_id.json"
    applies=$(jq -r --arg base "$base_ref" '
        .conditions.ref_name as $r |
        (($r.include | index("~DEFAULT_BRANCH")) != null or
         ($r.include | index($base)) != null or
         ($r.include | index("refs/heads/" + $base)) != null) and
        (($r.exclude | index($base)) == null and
         ($r.exclude | index("refs/heads/" + $base)) == null)
    ' "$work/ruleset-$ruleset_id.json")
    [ "$applies" = true ] || continue
    jq -r '.rules[] | select(.type=="required_status_checks") | .parameters.required_status_checks[]?.context' \
        "$work/ruleset-$ruleset_id.json" >> "$work/required-contexts.txt"
done
LC_ALL=C sort -u "$work/required-contexts.txt" -o "$work/required-contexts.txt"
cp "$work/required-contexts.txt" "$output/required-checks.txt"

github_get "/repos/$repository/actions/runs?head_sha=$head_sha&per_page=100" > "$work/runs.json"
printf '%s\n' 'workflow	job	event	run_id	required	binding	status	conclusion	reported_head_sha	checkout_sha	tested_base_sha	base_independent	trigger_coverage' > "$output/checks.tsv"
tab=$(printf '\t')
tail -n +2 "$policy/checks.tsv" | while IFS="$tab" read -r workflow job event requirement applicable binding base_independent trigger_coverage witness_step action; do
    [ -n "$workflow" ] || continue
    case $requirement in
        universal) required=yes ;;
        conditional) if [ "$applicable" = yes ]; then required=yes; else required=no; fi ;;
        observe) required=no ;;
        *) printf 'verdict collector: invalid check requirement: %s\n' "$requirement" >&2; exit 1 ;;
    esac
    if [ "$requirement" = universal ] && ! grep -Fx "$job" "$work/required-contexts.txt" >/dev/null; then
        printf 'branch-gate-%s\tOPEN\trequired-status-context-absent\n' "$job" >> "$output/blockers.tsv"
    fi

    run=$(jq -c --arg path "$workflow" --arg event "$event" --arg head "$head_sha" '
        [.workflow_runs[] | select(.path==$path and .event==$event and .head_sha==$head)] |
        sort_by(.run_number // .id) | last // empty
    ' "$work/runs.json")
    if [ -z "$run" ]; then
        printf '%s\t%s\t%s\t-\t%s\t%s\tmissing\t-\t-\t-\t-\t%s\t%s\n' \
            "$workflow" "$job" "$event" "$required" "$binding" "$base_independent" "$trigger_coverage" >> "$output/checks.tsv"
        continue
    fi

    run_id=$(printf '%s\n' "$run" | jq -r '.id')
    github_get "/repos/$repository/actions/runs/$run_id/jobs?per_page=100" > "$work/jobs-$run_id.json"
    job_count=$(jq --arg job "$job" '[.jobs[] | select(.name==$job)] | length' "$work/jobs-$run_id.json")
    if [ "$job_count" -eq 0 ]; then
        status=$(printf '%s\n' "$run" | jq -r '.status')
        conclusion=$(printf '%s\n' "$run" | jq -r '.conclusion // "-"')
        reported_head=$(printf '%s\n' "$run" | jq -r '.head_sha')
        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t-\t-\t%s\t%s\n' \
            "$workflow" "$job" "$event" "$run_id" "$required" "$binding" "$status" "$conclusion" "$reported_head" "$base_independent" "$trigger_coverage" >> "$output/checks.tsv"
        continue
    fi
    if [ "$job_count" -ne 1 ]; then
        printf 'check-job-collision-%s\tOPEN\trun-%s\n' "$job" "$run_id" >> "$output/blockers.tsv"
    fi
    job_json=$(jq -c --arg job "$job" '[.jobs[] | select(.name==$job)] | first' "$work/jobs-$run_id.json")
    status=$(printf '%s\n' "$job_json" | jq -r '.status')
    conclusion=$(printf '%s\n' "$job_json" | jq -r '.conclusion // "-"')
    reported_head=$(printf '%s\n' "$run" | jq -r '.head_sha')
    checkout_sha=-
    if [ "$binding" = head ] &&
       "$script_directory/check-workflow-head.sh" "$repository_root/$workflow" >/dev/null 2>&1 &&
       [ "$(printf '%s\n' "$job_json" | jq -r --arg step "$witness_step" '[.steps[]? | select(.name==$step and .conclusion=="success")] | length')" -eq 1 ]; then
        checkout_sha=$reported_head
    elif [ "$binding" = synthetic-merge ] && [ "$event_kind" = synthetic-merge ]; then
        checkout_sha=$event_sha
    fi
    tested_base_sha=-
    if [ "$base_independent" = no ]; then
        tested_base_sha=$(printf '%s\n' "$run" | jq -r '.pull_requests[0].base.sha // "-"')
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$workflow" "$job" "$event" "$run_id" "$required" "$binding" "$status" "$conclusion" \
        "$reported_head" "$checkout_sha" "$tested_base_sha" "$base_independent" "$trigger_coverage" >> "$output/checks.tsv"
done

while IFS= read -r context; do
    [ -n "$context" ] || continue
    if ! awk -F '\t' -v wanted="$context" 'NR>1 && $2==wanted {found=1} END {exit !found}' "$policy/checks.tsv"; then
        printf 'unmapped-required-check-%s\tOPEN\tactive-ruleset-context\n' "$context" >> "$output/blockers.tsv"
    fi
done < "$work/required-contexts.txt"

printf '%s\n' 'name	repository	policy	declared_ref	resolved_sha	expected_sha' > "$output/dependencies.tsv"
tail -n +2 "$policy/dependencies.tsv" | while IFS="$tab" read -r name dependency_repository dependency_policy declared_ref expected_sha; do
    [ -n "$name" ] || continue
    encoded_ref=$(printf '%s' "$declared_ref" | jq -sRr @uri)
    github_get "/repos/$dependency_repository/commits/$encoded_ref" > "$work/dependency-$name.json"
    resolved_sha=$(jq -er '.sha' "$work/dependency-$name.json")
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$dependency_repository" "$dependency_policy" "$declared_ref" "$resolved_sha" "$expected_sha" >> "$output/dependencies.tsv"
done

cp "$policy/receipts.tsv" "$output/receipts.tsv"
cp "$policy/consumer.tsv" "$output/consumer.tsv"
cp "$policy/completion.tsv" "$output/completion.tsv"

awk -F '\t' '
BEGIN { OFS="\t" }
FNR==NR {
    if (NR==1 || $0 ~ /^[[:space:]]*(#|$)/) next
    kind[++rules]=$1; subject[rules]=$2; provenance[rules]=$3
    next
}
{
    path=$0; result="unexplained"
    for (i=1; i<=rules; i++) {
        if (kind[i]=="file" && path==subject[i]) result=provenance[i]
        else if (kind[i]=="prefix" && index(path,subject[i])==1 && result=="unexplained") result=provenance[i]
    }
    print "file",path,result
}
END {
    for (i=1; i<=rules; i++) if (kind[i]=="anchor" || kind[i]=="equivalent")
        print kind[i],subject[i],provenance[i]
}
' "$policy/scope.tsv" "$output/changed-paths.txt" > "$output/scope.tsv"
sed -i '1i kind\tsubject\tprovenance' "$output/scope.tsv"

printf '%s\n' 'workflow	claim	required	default_branch	schedule_trigger	last_run_state	last_run_id' > "$output/schedules.tsv"
tail -n +2 "$policy/schedules.tsv" | while IFS="$tab" read -r workflow claim required; do
    [ -n "$workflow" ] || continue
    default_branch=no
    schedule_trigger=no
    if git -C "$repository_root" cat-file -e "$live_base_sha:$workflow" 2>/dev/null; then
        default_branch=yes
        git -C "$repository_root" show "$live_base_sha:$workflow" > "$work/schedule.yml"
        if grep -Eq '^[[:space:]]+schedule[[:space:]]*:' "$work/schedule.yml"; then schedule_trigger=yes; fi
    fi
    encoded_workflow=$(printf '%s' "$workflow" | jq -sRr @uri)
    encoded_branch=$(printf '%s' "$base_ref" | jq -sRr @uri)
    github_get "/repos/$repository/actions/workflows/$encoded_workflow/runs?event=schedule&branch=$encoded_branch&per_page=1" > "$work/schedule-runs.json"
    last_run_id=$(jq -r '.workflow_runs[0].id // "-"' "$work/schedule-runs.json")
    last_run_state=NEVER_RUN
    if [ "$last_run_id" != - ]; then
        run_status=$(jq -r '.workflow_runs[0].status' "$work/schedule-runs.json")
        run_conclusion=$(jq -r '.workflow_runs[0].conclusion // "-"' "$work/schedule-runs.json")
        if [ "$run_status" != completed ]; then last_run_state=UNKNOWN
        else
            case $run_conclusion in
                success) last_run_state=PASS ;;
                failure|timed_out|action_required) last_run_state=FAIL ;;
                cancelled) last_run_state=CANCELLED ;;
                skipped) last_run_state=SKIPPED ;;
                *) last_run_state=UNKNOWN ;;
            esac
        fi
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$workflow" "$claim" "$required" "$default_branch" "$schedule_trigger" "$last_run_state" "$last_run_id" >> "$output/schedules.tsv"
done

"$script_directory/collect-authority.sh" "$policy/authority.tsv" "$output/state.tsv" "$output/approval.tsv"

if [ "${AICI_COLLECT_ONLY:-0}" = 1 ]; then
    printf 'snapshot\t%s\thead\t%s\tbase\t%s\n' "$output" "$head_sha" "$live_base_sha"
    exit 0
fi

exec "$script_directory/pr-verdict.sh" "$output"
