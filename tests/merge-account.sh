#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
collector=${1:-"$root/merge/collect-account.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
export AICI_ACCOUNT_FIXTURES AICI_GITHUB_GET
AICI_ACCOUNT_FIXTURES=$work/api
AICI_GITHUB_GET=$work/github-get
mkdir -p "$AICI_ACCOUNT_FIXTURES"
printf 'repository\tpolicy\n' > "$work/registry.tsv"
cat > "$AICI_GITHUB_GET" <<'EOF'
#!/bin/sh
set -eu
case $1 in
    /search/issues\?q=user%3Afixture%20author%3Afixture%20is%3Apr%20is%3Aopen\&*)
        page=${1##*page=}
        page=${page%%&*}
        cat "$AICI_ACCOUNT_FIXTURES/$page.json"
        ;;
    *) echo "unexpected API request: $1" >&2; exit 1 ;;
esac
EOF
chmod +x "$AICI_GITHUB_GET"

assert_field() {
    awk -F '\t' -v key="$2" -v value="$3" '
        $1 == key && $2 == value { found=1 }
        END { exit !found }
    ' "$1"
}

collect() {
    sh "$collector" fixture "$work/registry.tsv" "$work/output" > "$work/summary.tsv" 2> "$work/error"
}

reject() {
    label=$1
    if collect; then
        echo "FAIL: account collection accepted $label" >&2
        exit 1
    fi
    assert_field "$work/output/collection.tsv" status INCOMPLETE
    if [ -n "${COCKSWAIN_PR_RETIREMENT:-}" ]; then
        if "$COCKSWAIN_PR_RETIREMENT" "$work/output" > "$work/decision" 2> "$work/consumer-error"; then
            echo "FAIL: supervisor accepted $label" >&2
            exit 1
        fi
        test ! -s "$work/decision"
    fi
}

printf '%s\n' '{"total_count":0,"incomplete_results":false,"items":[]}' > "$AICI_ACCOUNT_FIXTURES/1.json"
collect
assert_field "$work/output/collection.tsv" status COMPLETE
assert_field "$work/output/collection.tsv" expected_prs 0
if [ -n "${COCKSWAIN_PR_RETIREMENT:-}" ]; then
    "$COCKSWAIN_PR_RETIREMENT" "$work/output" > "$work/decision"
    assert_field "$work/decision" action DONE
fi

# Reuse the completed output: a failed refresh must invalidate old completion.
printf '%s\n' '{"total_count":0,"incomplete_results":true,"items":[]}' > "$AICI_ACCOUNT_FIXTURES/1.json"
reject incomplete-search
printf '%s\n' '{}' > "$AICI_ACCOUNT_FIXTURES/1.json"
reject missing-schema
printf '%s\n' '{"total_count":1,"incomplete_results":false,"items":[]}' > "$AICI_ACCOUNT_FIXTURES/1.json"
reject truncated-page
printf '%s\n' '{"total_count":1001,"incomplete_results":false,"items":[]}' > "$AICI_ACCOUNT_FIXTURES/1.json"
reject search-limit
printf '%s\n' '{"total_count":1.5,"incomplete_results":false,"items":[]}' > "$AICI_ACCOUNT_FIXTURES/1.json"
reject invalid-total
printf '%s\n' '{"total_count":1,"incomplete_results":false,"items":[{}]}' > "$AICI_ACCOUNT_FIXTURES/1.json"
reject malformed-pr
printf '%s\n' '{broken' > "$AICI_ACCOUNT_FIXTURES/1.json"
reject invalid-json
rm "$AICI_ACCOUNT_FIXTURES/1.json"
reject transport-failure

jq -n '{total_count:101,incomplete_results:false,items:
    [range(1;101) | {number:.,title:"Open work",pull_request:{},
        repository_url:"https://api.github.com/repos/fixture/project"}]}' > "$AICI_ACCOUNT_FIXTURES/1.json"
jq -n '{total_count:101,incomplete_results:false,items:
    [{number:101,title:"Last work",pull_request:{},
        repository_url:"https://api.github.com/repos/fixture/project"}]}' > "$AICI_ACCOUNT_FIXTURES/2.json"
collect
assert_field "$work/output/collection.tsv" expected_prs 101
test "$(wc -l < "$work/output/unmanaged.tsv")" -eq 102
if [ -n "${COCKSWAIN_PR_RETIREMENT:-}" ]; then
    "$COCKSWAIN_PR_RETIREMENT" "$work/output" > "$work/decision"
    assert_field "$work/decision" action CONTINUE
    assert_field "$work/decision" reason_code UNMANAGED_PR
fi
jq '.items[0].number=1' "$AICI_ACCOUNT_FIXTURES/2.json" > "$work/duplicate.json"
cp "$work/duplicate.json" "$AICI_ACCOUNT_FIXTURES/2.json"
reject duplicated-page
jq '.total_count=100' "$AICI_ACCOUNT_FIXTURES/2.json" > "$work/changed.json"
cp "$work/changed.json" "$AICI_ACCOUNT_FIXTURES/2.json"
reject changing-total

printf '%s\n' 'PASS: account scans reject incomplete, malformed, truncated, duplicated, changing, and failed discovery'
