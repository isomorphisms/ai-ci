#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
collector=${1:-"$root/merge/collect-verdict.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
repository_root=$work/repository
api=$work/api
policy=$work/policy
mkdir -p "$repository_root/.github/workflows" "$api" "$policy"

git -C "$repository_root" init -q -b main
git -C "$repository_root" config user.name fixture
git -C "$repository_root" config user.email fixture@example.invalid
printf '%s\n' base > "$repository_root/base.txt"
cat > "$repository_root/.github/workflows/verify.yml" <<'WORKFLOW'
name: merge gate
on:
  pull_request:
jobs:
  verify:
    name: merge-gate
    steps:
      - uses: actions/checkout@pinned
        with:
          ref: ${{ github.event.pull_request.head.sha || github.sha }}
          persist-credentials: false
      - name: Prove exact revision
        run: test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
WORKFLOW
git -C "$repository_root" add .
git -C "$repository_root" commit -qm base
B=$(git -C "$repository_root" rev-parse HEAD)

git -C "$repository_root" switch -qc change
mkdir -p "$repository_root/src"
printf '%s\n' one > "$repository_root/src/change.c"
git -C "$repository_root" add src/change.c
git -C "$repository_root" commit -qm change
H=$(git -C "$repository_root" rev-parse HEAD)

git -C "$repository_root" switch -q main
printf '%s\n' base-moved > "$repository_root/base-two.txt"
git -C "$repository_root" add base-two.txt
git -C "$repository_root" commit -qm base-two
B2=$(git -C "$repository_root" rev-parse HEAD)
git -C "$repository_root" switch -q change

printf '%s\n' 'Finish the exact merge collector fixture.' > "$policy/intent.txt"
cat > "$policy/settings.tsv" <<'SETTINGS'
schema	aici-merge-verdict-collection-policy-v1
repository	isomorphisms/example
job_kind	execution
job_state	COMPLETE
intent_file	intent.txt
stack_parent_pr	-
stack_parent_expected_sha	-
SETTINGS
cat > "$policy/checks.tsv" <<'CHECKS'
workflow	job	event	requirement	applicable	binding	base_independent	trigger_coverage	checkout_witness	action
.github/workflows/verify.yml	merge-gate	pull_request	universal	yes	head	no	yes	Prove exact revision	rerun-exact-head
CHECKS
printf '%s\n' 'name	repository	policy	declared_ref	expected_sha' > "$policy/dependencies.tsv"
cat > "$policy/receipts.tsv" <<'RECEIPTS'
id	result	head_sha	source_sha	artifact_sha256	platform	abi	execution	hardware	network	artifact_mode	evidence_class	provenance	build_sha	execution_result	required_source_sha	required_artifact_sha256	required_platform	required_abi	required_execution	required_hardware	required_network	required_artifact_mode	required_evidence_class	required_provenance	required_build_sha	required_execution_result
RECEIPTS
cat > "$policy/scope.tsv" <<'SCOPE'
kind	subject	provenance
prefix	src/	intended
SCOPE
printf '%s\n' 'artifact_sha256	source_sha	action	outcome' > "$policy/consumer.tsv"
printf '%s\n' 'id	state	evidence' > "$policy/blockers.tsv"
printf '%s\n' 'workflow	claim	required' > "$policy/schedules.tsv"
cat > "$policy/completion.tsv" <<'COMPLETION'
step	phase	required	state	evidence
implement-collector	implementation	yes	COMPLETE	fixture-commit
verify-collector	verification	yes	COMPLETE	fixture-run
COMPLETION

A=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
C=cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
F=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
write_authority() {
    classification=$1
    role=$2
    context_state=$3
    authority_scope=$4
    revocation=${5:-none}
    objections=${6:-none}
    cat > "$policy/authority.tsv" <<EOF
schema	cockswain-merge-authority-v1
classification	$classification
authorization_kind	task-context
authorized_by	human
authority_actor_kind	human
authority_source_kind	human-task
authority_source_id	task-17
authority_source_role	$role
authority_text_sha256	$F
authority_context_ref	private-task-17
authority_context_sha256	$A
authority_context_state	$context_state
classifier_repository	isomorphisms/cockswain
classifier_revision	$H
classifier_contract_sha256	$C
authorized_repository	isomorphisms/example
authorized_pr	17
authorized_title	Fixture PR
authorized_scope_sha256	$authority_scope
revocation_state	$revocation
unresolved_objections	$objections
EOF
}

write_pr() {
    head=$1
    reported_base=$2
    cat > "$api/pr.json" <<EOF
{"title":"Fixture PR","draft":false,"mergeable":true,"merged":false,"head":{"sha":"$head"},"base":{"ref":"main","sha":"$reported_base"}}
EOF
}
write_base() { printf '{"commit":{"sha":"%s"}}\n' "$1" > "$api/base.json"; }
write_run() {
    head=$1
    tested_base=$2
    status=$3
    conclusion=$4
    cat > "$api/runs.json" <<EOF
{"workflow_runs":[{"id":100,"run_number":1,"path":".github/workflows/verify.yml","event":"pull_request","head_sha":"$head","status":"$status","conclusion":"$conclusion","pull_requests":[{"base":{"sha":"$tested_base"}}]}]}
EOF
}
write_job() {
    status=$1
    conclusion=$2
    step_conclusion=${3:-success}
    cat > "$api/jobs.json" <<EOF
{"jobs":[{"name":"merge-gate","status":"$status","conclusion":"$conclusion","steps":[{"name":"Prove exact revision","status":"completed","conclusion":"$step_conclusion"}]}]}
EOF
}

cat > "$api/rulesets.json" <<'RULESETS'
[{"id":1,"name":"protect-default","target":"branch","enforcement":"active"}]
RULESETS
cat > "$api/ruleset.json" <<'RULESET'
{"id":1,"target":"branch","enforcement":"active","conditions":{"ref_name":{"include":["~DEFAULT_BRANCH"],"exclude":[]}},"rules":[{"type":"required_status_checks","parameters":{"required_status_checks":[{"context":"merge-gate"}]}}]}
RULESET
cat > "$work/get" <<EOF
#!/bin/sh
set -eu
case \$1 in
  /repos/isomorphisms/example/pulls/17) file=pr.json ;;
  /repos/isomorphisms/example/branches/main) file=base.json ;;
  '/repos/isomorphisms/example/rulesets?includes_parents=true') file=rulesets.json ;;
  /repos/isomorphisms/example/rulesets/1) file=ruleset.json ;;
  /repos/isomorphisms/example/actions/runs?head_sha=*) file=runs.json ;;
  /repos/isomorphisms/example/actions/runs/*/jobs?per_page=100) file=jobs.json ;;
  *) printf 'fixture API path not found: %s\n' "\$1" >&2; exit 1 ;;
esac
cat "$api/\$file"
EOF
chmod +x "$work/get"

run_collector() {
    name=$1
    shift
    directory=$work/output-$name
    status=0
    AICI_GITHUB_GET=$work/get AICI_REPOSITORY_ROOT=$repository_root AICI_NO_FETCH=1 \
        "$@" "$collector" isomorphisms/example 17 "$policy" "$directory" \
        > "$work/$name.out" 2> "$work/$name.err" || status=$?
    printf '%s\n' "$status" > "$work/$name.status"
}

expect_pass() {
    name=$1
    test "$(cat "$work/$name.status")" -eq 0 || {
        printf 'collector case should pass: %s\n' "$name" >&2
        cat "$work/$name.err" >&2
        sed -n '1,$p' "$work/output-$name/state.tsv" >&2
        sed -n '1,$p' "$work/output-$name/approval.tsv" >&2
        exit 1
    }
    grep -F 'PASS	MERGE-AUTHORIZATION' "$work/$name.out" >/dev/null
    printf 'PASS\t%s\n' "$name"
}

expect_fail() {
    name=$1
    diagnostic=$2
    test "$(cat "$work/$name.status")" -ne 0 || {
        printf 'collector case should fail: %s\n' "$name" >&2
        exit 1
    }
    if ! grep -F "$diagnostic" "$work/$name.err" "$work/$name.out" >/dev/null; then
        printf 'collector case %s missed diagnostic %s\n' "$name" "$diagnostic" >&2
        cat "$work/$name.err" >&2
        exit 1
    fi
    printf 'PASS\t%s\t%s\n' "$name" "$diagnostic"
}

write_pr "$H" "$B"
write_base "$B"
write_run "$H" "$B" completed success
write_job completed success
write_authority AUTHORIZED merge-authorizing-task recovered "$A"
run_collector seed env AICI_COLLECT_ONLY=1
accepted_scope=$(awk -F '\t' '$1=="current_scope_sha256" {print $2}' "$work/output-seed/state.tsv")
write_authority AUTHORIZED merge-authorizing-task recovered "$accepted_scope"

run_collector clean env
expect_pass clean
run_collector contextual-authority-later-okay env
expect_pass contextual-authority-later-okay

git -C "$repository_root" switch -q change
printf '%s\n' two > "$repository_root/src/change.c"
git -C "$repository_root" add src/change.c
git -C "$repository_root" commit -qm change-two
H2=$(git -C "$repository_root" rev-parse HEAD)
write_pr "$H2" "$B"
write_run "$H" "$B" completed success
run_collector stale-head env
expect_fail stale-head CHECK-MISSING

write_pr "$H" "$B"
write_base "$B2"
write_run "$H" "$B" completed success
run_collector stale-base env
expect_fail stale-base CHECK-STALE-BASE

write_base "$B"
run_collector synthetic-as-head env AICI_EVENT_SHA="$B2" AICI_EVENT_KIND=head
expect_fail synthetic-as-head MERGE-SYNTHETIC-AS-HEAD

printf '%s\n' '{"workflow_runs":[]}' > "$api/runs.json"
run_collector missing-check env
expect_fail missing-check CHECK-MISSING

write_run "$H" "$B" completed cancelled
write_job completed cancelled cancelled
run_collector cancelled-check env
expect_fail cancelled-check CHECK-CANCELLED

write_run "$H" "$B" completed failure
write_job completed failure success
run_collector failed-check env
expect_fail failed-check CHECK-FAILED

write_run "$H" "$B" completed success
write_job completed success
printf '%s\n' 'id	state	evidence' 'declared-blocker	OPEN	fixture' > "$policy/blockers.tsv"
run_collector open-blocker env
expect_fail open-blocker BLOCKER-OPEN
printf '%s\n' 'id	state	evidence' > "$policy/blockers.tsv"

cat > "$policy/receipts.tsv" <<EOF
id	result	head_sha	source_sha	artifact_sha256	platform	abi	execution	hardware	network	artifact_mode	evidence_class	provenance	build_sha	execution_result	required_source_sha	required_artifact_sha256	required_platform	required_abi	required_execution	required_hardware	required_network	required_artifact_mode	required_evidence_class	required_provenance	required_build_sha	required_execution_result
phone	PASS	$H	$H	-	android-bionic	armeabi-v7a	android-emulator	virtual	none	none	android-emulator	installed-artifact	$H	semantic-pass	$H	-	android-bionic	armeabi-v7a	physical	physical	none	none	physical-phone	installed-artifact	$H	semantic-pass
EOF
run_collector emulator-as-phone env
expect_fail emulator-as-phone RECEIPT-WRONG-EXECUTION
sed -n '1p' "$policy/receipts.tsv" > "$policy/receipts.empty"
mv "$policy/receipts.empty" "$policy/receipts.tsv"

write_authority NOT_AUTHORIZED acknowledgement recovered "$accepted_scope"
run_collector okay-without-authority env
expect_fail okay-without-authority APPROVAL-NOT-AUTHORIZED

write_authority AUTHORIZED merge-authorizing-task missing "$accepted_scope"
run_collector missing-context env
expect_fail missing-context APPROVAL-CONTEXT-MISSING

write_authority AUTHORIZED merge-authorizing-task recovered "$A"
run_collector changed-scope env
expect_fail changed-scope APPROVAL-SCOPE-CHANGED

write_pr "$H2" "$B"
write_run "$H2" "$B" completed success
write_job completed success
write_authority AUTHORIZED merge-authorizing-task recovered "$accepted_scope"
run_collector refreshed-same-scope env
expect_pass refreshed-same-scope

printf '%s\n' 'full live-verdict collector acceptance cases pass'
