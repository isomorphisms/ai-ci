#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
collector=${1:-"$root/merge/collect-github.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
policy=$work/policy
output=$work/output
mkdir -p "$policy" "$work/api" "$work/repository/.github/workflows"

H=1111111111111111111111111111111111111111
B=2222222222222222222222222222222222222222
OLD=9999999999999999999999999999999999999999
S=3333333333333333333333333333333333333333
A=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

printf '%b\n' \
    'schema\taici-merge-collection-policy-v2' \
    'repository\tisomorphisms/example' \
    'auto_reconcile\tyes' \
    'promotion_state\tNONE' \
    'promotion_condition\t-' \
    'promotion_action\tmark-ready' \
    'promotion_evidence_class\t-' > "$policy/settings.tsv"
printf '%b\n' \
    'name\tworkflow\trequired\tbase_independent\tbinding\ttrigger_coverage\taction' \
    'verify\t.github/workflows/verify.yml\tyes\tyes\thead\tyes\trerun-exact-head' > "$policy/checks.tsv"
printf '%s\n' \
    'on:' \
    '  pull_request:' \
    'jobs:' \
    '  verify:' \
    '    steps:' \
    '      - uses: actions/checkout@pinned' \
    '        with:' \
    '          ref: ${{ github.event.pull_request.head.sha || github.sha }}' \
    '          persist-credentials: false' > "$work/repository/.github/workflows/verify.yml"
printf '%b\n' \
    'claim\trequired\tresult\thead_sha\trequired_head_sha\tevidence_class\trequired_evidence_class\texecution\trequired_execution\thardware\trequired_hardware\tnetwork\trequired_network\tprovenance\trequired_provenance\texecution_result\trequired_execution_result\tsource_sha\trequired_source_sha\tartifact_sha256\trequired_artifact_sha256\treceipt_ref\taction\treuse_rule\trelevant_digest\trequired_relevant_digest' \
    "runtime\tno\tNOT_VERIFIED\t$H\t$H\thost\thost\thost\thost\tnone\tnone\tnone\tnone\tnone\tnone\tsemantic-pass\tsemantic-pass\t$S\t$S\t$A\t$A\t-\trun-runtime\texact-head\t-\t-" > "$policy/evidence.tsv"
printf '%b\n' 'dependency\trequired\tstate\texpected\tobserved\tobject_ref\taction' > "$policy/dependencies.tsv"
printf '%b\n' 'follower\tblocking\ttrigger\tcurrent_trigger\tacceptance_kind\tstate\tsuccessor\tobject_ref\taction' > "$policy/followers.tsv"
printf '%b\n' \
    'schema\taici-merge-authorization-observation-v1' \
    'state\tvalid' \
    "head_sha\t$H" \
    'authority_kind\texplicit-merge' \
    'scope_state\tsame' \
    'receipt_ref\tapproval.tsv' \
    'action\trefresh-authorization' > "$policy/authorization.tsv"

printf '%s\n' "{\"title\":\"Fixture PR\",\"draft\":false,\"mergeable\":true,\"head\":{\"sha\":\"$H\"},\"base\":{\"ref\":\"main\",\"sha\":\"$OLD\"}}" > "$work/api/pr.json"
printf '%s\n' "{\"commit\":{\"sha\":\"$B\"}}" > "$work/api/base.json"
printf '%s\n' "{\"check_runs\":[{\"id\":100,\"name\":\"verify\",\"head_sha\":\"$H\",\"status\":\"completed\",\"conclusion\":\"success\",\"details_url\":\"https://example.invalid/run/100\"}]}" > "$work/api/head.json"
printf '%s\n' "{\"check_runs\":[{\"id\":90,\"name\":\"verify\",\"head_sha\":\"$B\",\"status\":\"completed\",\"conclusion\":\"success\",\"details_url\":\"https://example.invalid/run/90\"}]}" > "$work/api/base-checks.json"

getter=$work/get
sed "s#@ROOT@#$work/api#g" "$root/tests/fixtures/github-get.sh.in" > "$getter"
chmod +x "$getter"

AICI_GITHUB_GET=$getter AICI_REPOSITORY_ROOT=$work/repository \
    "$collector" isomorphisms/example 17 "$policy" "$output" > "$work/result"
grep -F 'READY' "$work/result" >/dev/null
awk -F '\t' -v expected="$H" '$1=="head_sha" && $2==expected {found=1} END {exit !found}' "$output/pr.tsv"
awk -F '\t' -v expected="$B" '$1=="live_base_sha" && $2==expected {found=1} END {exit !found}' "$output/pr.tsv"
awk -F '\t' -v expected="$OLD" '$1=="reported_base_sha" && $2==expected {found=1} END {exit !found}' "$output/pr.tsv"
awk -F '\t' 'NR==2 && $1=="verify" && $4==$5 && $8=="head" && $10=="success" {found=1} END {exit !found}' "$output/checks.tsv"

sed 's/ref: .*/ref: refs\/pull\/17\/merge/' \
    "$work/repository/.github/workflows/verify.yml" > "$work/repository/.github/workflows/not-exact.yml"
sed -i 's#\.github/workflows/verify.yml#.github/workflows/not-exact.yml#' "$policy/checks.tsv"
if AICI_GITHUB_GET=$getter AICI_REPOSITORY_ROOT=$work/repository \
    "$collector" isomorphisms/example 17 "$policy" "$work/not-exact-output" > "$work/not-exact-result"; then
    echo 'collector accepted a check whose workflow lacks an exact-head checkout' >&2
    exit 1
fi
grep -F 'CI_STALE' "$work/not-exact-result" >/dev/null

sed -i 's#\.github/workflows/not-exact.yml#.github/workflows/verify.yml#' "$policy/checks.tsv"
printf '%b\n' \
    'repository\tpr\tpolicy' \
    "isomorphisms/example\t17\t$policy" \
    "isomorphisms/example\t17\t$policy" > "$work/set.tsv"
AICI_GITHUB_GET=$getter AICI_GITHUB_GET_LOG=$work/api.log \
    AICI_REPOSITORY_ROOT=$work/repository \
    "$root/merge/collect-set.sh" "$work/set.tsv" "$work/set-output" > "$work/set-result"
test "$(wc -l < "$work/api.log")" -eq 4
test "$(grep -c 'READY' "$work/set-result")" -eq 2

printf '%s\n' 'GitHub collector fixtures pass; set collection caches repeated API reads'
