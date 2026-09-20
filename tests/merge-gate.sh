#!/bin/sh
set -eu
bin=${1:-merge/verify.sh}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
H=1111111111111111111111111111111111111111
O=9999999999999999999999999999999999999999
B=2222222222222222222222222222222222222222
OLD=5555555555555555555555555555555555555555
S=3333333333333333333333333333333333333333
P1=6666666666666666666666666666666666666666
P2=7777777777777777777777777777777777777777
M=8888888888888888888888888888888888888888
A=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
C=cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
E=eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
F=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

write_good() {
    d=$1
    mkdir -p "$d"
    cat > "$d/state.tsv" <<STATE
schema	aici-merge-state-v3
repository	isomorphisms/example
pr	17
title	Example narrow change
head_sha	$H
event_sha	$H
event_kind	head
live_base_ref	main
live_base_sha	$B
reported_base_sha	$B
merge_base_sha	$B
scope_base_sha	$B
prospective_diff_sha256	$C
changed_paths_sha256	$E
intent_sha256	$F
diff_files	1
diff_additions	1
diff_deletions	0
job_kind	execution
job_state	COMPLETE
stack_parent_pr	-
stack_parent_state	none
stack_parent_expected_sha	-
stack_parent_current_sha	-
STATE
    cat > "$d/checks.tsv" <<CHECKS
workflow	job	event	run_id	required	binding	status	conclusion	reported_head_sha	checkout_sha	trigger_coverage
.github/workflows/verify.yml	verify-pr	pull_request	100	yes	head	completed	success	$H	$H	yes
CHECKS
    cat > "$d/dependencies.tsv" <<DEPS
name	repository	policy	declared_ref	resolved_sha	expected_sha
compiler	isomorphisms/Idric	exact	$S	$S	$S
DEPS
    cat > "$d/receipts.tsv" <<RECEIPTS
id	result	head_sha	source_sha	artifact_sha256	platform	abi	execution	hardware	network	artifact_mode	evidence_class	provenance	build_sha	execution_result	required_source_sha	required_artifact_sha256	required_platform	required_abi	required_execution	required_hardware	required_network	required_artifact_mode	required_evidence_class	required_provenance	required_build_sha	required_execution_result
runtime	PASS	$H	$S	$A	android-bionic	aarch64	android-emulator	virtual	none	exact-prebuilt	android-emulator	compiler-generated	$S	semantic-pass	$S	$A	android-bionic	aarch64	android-emulator	virtual	none	exact-prebuilt	android-emulator	compiler-generated	$S	semantic-pass
RECEIPTS
    cat > "$d/scope.tsv" <<SCOPE
kind	subject	provenance
file	src/example.c	intended
anchor	src/example.c	present
equivalent	backend/example	distinct
SCOPE
    cat > "$d/consumer.tsv" <<CONSUMER
artifact_sha256	source_sha	action	outcome
$A	$S	verify	pass
$A	$S	execute	pass
CONSUMER
    cat > "$d/approval.tsv" <<APPROVAL
schema	aici-merge-approval-v2
repository	isomorphisms/example
pr	17
title	Example narrow change
head_sha	$H
base_ref	main
base_sha	$B
prospective_diff_sha256	$C
changed_paths_sha256	$E
intent_sha256	$F
decision	MERGE
authorization_kind	explicit-merge
authorization_text_sha256	$F
authorized_by	human
authority_actor_kind	human
authority_source_kind	human-message
authority_source_id	conversation-message-17
authority_source_role	merge-instruction
unresolved_objections	none
APPROVAL
    cat > "$d/blockers.tsv" <<BLOCKERS
id	state	evidence
historical-obligation	RESOLVED	receipt-17
BLOCKERS
    cat > "$d/schedules.tsv" <<SCHEDULES
workflow	claim	required	default_branch	schedule_trigger	last_run_state	last_run_id
.github/workflows/watch.yml	operating	yes	yes	yes	PASS	200
SCHEDULES
    cat > "$d/completion.tsv" <<COMPLETION
step	phase	required	state	evidence
implement-control	implementation	yes	COMPLETE	commit-$H
verify-control	verification	yes	COMPLETE	run-100
COMPLETION
}

run_good() {
    name=$1; d=$2
    if ! sh "$bin" verify "$d/state.tsv" "$d/checks.tsv" "$d/dependencies.tsv" "$d/receipts.tsv" "$d/scope.tsv" "$d/consumer.tsv" "$d/approval.tsv" "$d/blockers.tsv" "$d/schedules.tsv" "$d/completion.tsv" >"$d/out" 2>"$d/err"; then
        printf 'good case failed: %s\n' "$name" >&2
        cat "$d/err" >&2
        exit 1
    fi
    printf 'PASS	%s\n' "$name"
}

run_bad() {
    expected=$1; name=$2; d=$3
    if sh "$bin" verify "$d/state.tsv" "$d/checks.tsv" "$d/dependencies.tsv" "$d/receipts.tsv" "$d/scope.tsv" "$d/consumer.tsv" "$d/approval.tsv" "$d/blockers.tsv" "$d/schedules.tsv" "$d/completion.tsv" >"$d/out" 2>"$d/err"; then
        printf 'bad case was accepted: %s\n' "$name" >&2
        exit 1
    fi
    if ! grep -F "first=$expected" "$d/err" >/dev/null; then
        printf 'wrong diagnostic for %s; expected %s\n' "$name" "$expected" >&2
        cat "$d/err" >&2
        exit 1
    fi
    printf 'PASS	%s	%s\n' "$name" "$expected"
}

case_dir() { d=$tmp/$1; write_good "$d"; printf '%s\n' "$d"; }

D=$(case_dir good); run_good exact-current-head "$D"

D=$(case_dir contextual-task)
awk -F '\t' -v OFS='\t' '
$1=="authorization_kind" {$2="task-context"}
$1=="authority_source_kind" {$2="human-task"}
$1=="authority_source_id" {$2="task-17"}
$1=="authority_source_role" {$2="merge-authorizing-task"}
{print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_good contextual-task-authority-survives-ambiguous-okay "$D"

D=$(case_dir acknowledgement-mislabeled)
awk -F '\t' -v OFS='\t' '
$1=="authorization_text_sha256" {$2="6a581ee901185606598bbd5369794c46dcf21ebf95955a46fb4a6244bb89e79f"}
$1=="authorization_kind" {$2="explicit-merge"}
$1=="authority_source_role" {$2="acknowledgement"}
{print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-SOURCE-NOT-AUTHORITY acknowledgement-hash-cannot-be-labeled-explicit-merge "$D"

D=$(case_dir assistant-recommendation)
awk -F '\t' -v OFS='\t' '$1=="authority_actor_kind" {$2="assistant"} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-SOURCE-NOT-HUMAN assistant-recommendation-is-not-human-authority "$D"

D=$(case_dir approval-wrong-head)
awk -F '\t' -v OFS='\t' -v old="$O" '$1=="head_sha" {$2=old} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-WRONG-HEAD approval-bound-to-old-head "$D"

D=$(case_dir approval-wrong-diff)
awk -F '\t' -v OFS='\t' -v wrong="$F" '$1=="prospective_diff_sha256" {$2=wrong} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-WRONG-DIFF approval-bound-to-other-diff "$D"

D=$(case_dir approval-wrong-paths)
awk -F '\t' -v OFS='\t' -v wrong="$F" '$1=="changed_paths_sha256" {$2=wrong} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-WRONG-PATHS approval-bound-to-other-paths "$D"

D=$(case_dir approval-wrong-intent)
awk -F '\t' -v OFS='\t' -v wrong="$E" '$1=="intent_sha256" {$2=wrong} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-WRONG-INTENT approval-bound-to-other-intent "$D"

D=$(case_dir approval-wrong-base)
awk -F '\t' -v OFS='\t' -v old="$OLD" '$1=="base_sha" {$2=old} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-WRONG-BASE approval-bound-to-other-base "$D"

D=$(case_dir approval-objection)
awk -F '\t' -v OFS='\t' '$1=="unresolved_objections" {$2="review-thread-3"} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-OBJECTION-OPEN unresolved-objection "$D"

D=$(case_dir approval-wrong-pr)
awk -F '\t' -v OFS='\t' '$1=="title" {$2="Another change"} {print}' "$D/approval.tsv" > "$D/x" && mv "$D/x" "$D/approval.tsv"
run_bad APPROVAL-WRONG-PR approval-bound-to-other-title "$D"

D=$(case_dir receipt-wrong-head)
awk -F '	' -v OFS='	' -v old="$O" 'NR==2 {$3=old} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-HEAD receipt-wrong-head "$D"

D=$(case_dir receipt-wrong-artifact)
awk -F '	' -v OFS='	' -v wrong="$C" 'NR==2 {$17=wrong} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-ARTIFACT receipt-wrong-artifact "$D"

D=$(case_dir stale-scope-base)
awk -F '	' -v OFS='	' -v old="$OLD" '$1=="reported_base_sha"||$1=="merge_base_sha"||$1=="scope_base_sha" {$2=old} {print}' "$D/state.tsv" > "$D/x" && mv "$D/x" "$D/state.tsv"
run_bad TOPOLOGY-STALE-SCOPE-BASE stale-base-diff "$D"

D=$(case_dir parent-moved)
awk -F '	' -v OFS='	' -v p1="$P1" -v p2="$P2" '
$1=="stack_parent_pr" {$2="16"}
$1=="stack_parent_state" {$2="open"}
$1=="stack_parent_expected_sha" {$2=p1}
$1=="stack_parent_current_sha" {$2=p2}
$1=="scope_base_sha"||$1=="merge_base_sha" {$2=p2}
{print}' "$D/state.tsv" > "$D/x" && mv "$D/x" "$D/state.tsv"
run_bad STACK-PARENT-MOVED stacked-parent-moved "$D"

D=$(case_dir historical-green)
awk -F '	' -v OFS='	' -v old="$O" 'NR==2 {$9=old} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-STALE historical-green-after-rebase "$D"

D=$(case_dir skipped)
awk -F '	' -v OFS='	' 'NR==2 {$8="skipped"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-SKIPPED skipped-required-check "$D"

D=$(case_dir cancelled)
awk -F '	' -v OFS='	' 'NR==2 {$8="cancelled"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-CANCELLED cancelled-required-check "$D"

D=$(case_dir failed)
awk -F '	' -v OFS='	' 'NR==2 {$8="failure"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-FAILED failed-required-check "$D"

D=$(case_dir unknown-check)
awk -F '	' -v OFS='	' 'NR==2 {$8="neutral"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-UNKNOWN neutral-required-check "$D"

D=$(case_dir absent)
awk -F '	' -v OFS='	' 'NR==2 {$4="-";$7="missing";$8="-";$9="-";$10="-"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-MISSING absent-required-workflow "$D"

D=$(case_dir malformed-pass)
awk -F '	' -v OFS='	' 'NR==2 {NF=26} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPTS-MALFORMED malformed-pass-receipt "$D"

D=$(case_dir wrong-abi)
awk -F '	' -v OFS='	' 'NR==2 {$19="armeabi-v7a"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-ABI wrong-abi "$D"

D=$(case_dir emulator-as-physical)
awk -F '	' -v OFS='	' 'NR==2 {$24="physical-phone"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-EVIDENCE-CLASS emulator-as-physical-phone "$D"

D=$(case_dir qemu-system-as-phone)
awk -F '	' -v OFS='	' 'NR==2 {$8="full-system";$9="virtual";$12="qemu-system";$20="full-system";$21="virtual";$24="physical-phone"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-EVIDENCE-CLASS qemu-system-as-physical-phone "$D"

D=$(case_dir malformed-physical-class)
awk -F '	' -v OFS='	' 'NR==2 {$12="physical-phone";$24="physical-phone"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-PHYSICAL-CLASS-MISMATCH physical-class-with-emulator-execution "$D"

D=$(case_dir malformed-qemu-class)
awk -F '	' -v OFS='	' 'NR==2 {$12="qemu-system";$24="qemu-system"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-QEMU-CLASS-MISMATCH qemu-class-with-emulator-execution "$D"

D=$(case_dir malformed-emulator-class)
awk -F '	' -v OFS='	' 'NR==2 {$8="host";$9="none";$20="host";$21="none"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-EMULATOR-CLASS-MISMATCH emulator-class-with-host-execution "$D"

D=$(case_dir handwritten-as-generated)
awk -F '	' -v OFS='	' 'NR==2 {$13="handwritten-oracle"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-PROVENANCE handwritten-oracle-as-compiler-generated "$D"

D=$(case_dir packaged-as-executed)
awk -F '	' -v OFS='	' 'NR==2 {$13="packaged-only";$15="semantic-pass"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-PACKAGE-AS-EXECUTION packaged-artifact-as-executed "$D"

D=$(case_dir wrong-build)
awk -F '	' -v OFS='	' -v wrong="$O" 'NR==2 {$26=wrong} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-BUILD receipt-wrong-build "$D"

D=$(case_dir wrong-execution-result)
awk -F '	' -v OFS='	' 'NR==2 {$27="launched"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-EXECUTION-RESULT launched-is-not-semantic-pass "$D"

D=$(case_dir mock-as-runtime)
awk -F '	' -v OFS='	' 'NR==2 {$8="host";$9="mock";$12="host";$20="host";$21="physical";$24="host"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-HARDWARE mock-as-runtime "$D"

D=$(case_dir rebuild-fallback)
printf '%s\n' "$A	$S	rebuild	attempted" >> "$D/consumer.tsv"
run_bad RUNTIME-REBUILD-FALLBACK runtime-rebuild-fallback "$D"

D=$(case_dir moving-ref)
awk -F '	' -v OFS='	' 'NR==2 {$4="Idriç"} {print}' "$D/dependencies.tsv" > "$D/x" && mv "$D/x" "$D/dependencies.tsv"
run_bad DEPENDENCY-MOVING-REF moving-ref-where-exact-required "$D"

D=$(case_dir synthetic-as-head)
awk -F '	' -v OFS='	' -v merge="$M" '$1=="event_sha" {$2=merge} {print}' "$D/state.tsv" > "$D/x" && mv "$D/x" "$D/state.tsv"
run_bad MERGE-SYNTHETIC-AS-HEAD synthetic-merge-mislabeled-head "$D"

D=$(case_dir implementation-lost)
awk -F '	' -v OFS='	' '$1=="anchor" {$3="missing"} {print}' "$D/scope.tsv" > "$D/x" && mv "$D/x" "$D/scope.tsv"
run_bad SCOPE-IMPLEMENTATION-MISSING ancestry-lost-implementation "$D"

D=$(case_dir check-collision)
printf '%s\n' ".github/workflows/verify.yml	verify-pr	push	101	no	head	completed	success	$H	$H	yes" >> "$D/checks.tsv"
run_bad CHECK-NAME-COLLISION push-pr-check-name-collision "$D"

D=$(case_dir trigger-gap)
awk -F '	' -v OFS='	' 'NR==2 {$11="no"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-TRIGGER-GAP workflow-trigger-gap "$D"

D=$(case_dir unknown-receipt)
awk -F '	' -v OFS='	' 'NR==2 {$2="UNKNOWN"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-UNKNOWN missing-evidence-is-unknown "$D"

D=$(case_dir inherited-scope)
awk -F '	' -v OFS='	' '$1=="file" {$3="inherited"} {print}' "$D/scope.tsv" > "$D/x" && mv "$D/x" "$D/scope.tsv"
run_bad SCOPE-INHERITED inherited-stack-scope "$D"

D=$(case_dir duplicate-backend)
awk -F '	' -v OFS='	' '$1=="equivalent" {$3="duplicate"} {print}' "$D/scope.tsv" > "$D/x" && mv "$D/x" "$D/scope.tsv"
run_bad SCOPE-EQUIVALENT-DUPLICATE duplicate-equivalent-path "$D"

D=$(case_dir exact-artifact-not-executed)
grep -v '	execute	' "$D/consumer.tsv" > "$D/x" && mv "$D/x" "$D/consumer.tsv"
run_bad RUNTIME-EXACT-ARTIFACT-NOT-EXECUTED exact-artifact-not-executed "$D"

D=$(case_dir exact-artifact-unpinned)
awk -F '\t' -v OFS='\t' 'NR==2 {$17="-"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_good exact-artifact-unpinned-but-bound-by-receipt "$D"
awk 'NR==1 {print}' "$D/consumer.tsv" > "$D/x" && mv "$D/x" "$D/consumer.tsv"
run_bad RUNTIME-EXACT-ARTIFACT-NOT-EXECUTED exact-artifact-unpinned-still-needs-consumer "$D"

D=$(case_dir receipt-wrong-source)
awk -F '	' -v OFS='	' -v wrong="$O" 'NR==2 {$16=wrong} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-SOURCE receipt-wrong-source "$D"

D=$(case_dir wrong-platform)
awk -F '	' -v OFS='	' 'NR==2 {$18="linux-glibc"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-PLATFORM wrong-platform "$D"

D=$(case_dir synthetic-only-check)
awk -F '	' -v OFS='	' -v merge="$M" '$1=="event_sha" {$2=merge} $1=="event_kind" {$2="synthetic-merge"} {print}' "$D/state.tsv" > "$D/x" && mv "$D/x" "$D/state.tsv"
awk -F '	' -v OFS='	' -v merge="$M" 'NR==2 {$6="synthetic-merge";$10=merge} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-EXACT-HEAD-MISSING synthetic-only-cannot-authorize-head "$D"

D=$(case_dir moving-resolved-good)
awk -F '	' -v OFS='	' 'NR==2 {$3="moving-resolved";$4="Idriç";$6="-"} {print}' "$D/dependencies.tsv" > "$D/x" && mv "$D/x" "$D/dependencies.tsv"
run_good active-integration-moving-ref-resolved "$D"

D=$(case_dir blocker-open)
printf '%s\n' "provision-workbench	OPEN	human-device-setup" >> "$D/blockers.tsv"
run_bad BLOCKER-OPEN mergeable-with-unresolved-blocker "$D"

D=$(case_dir schedule-pr-branch-only)
awk -F '	' -v OFS='	' 'NR==2 {$2="configured";$3="no";$4="no";$6="NEVER_RUN";$7="-"} {print}' "$D/schedules.tsv" > "$D/x" && mv "$D/x" "$D/schedules.tsv"
run_bad SCHEDULE-NOT-ON-DEFAULT scheduled-workflow-only-on-pr-branch "$D"

D=$(case_dir schedule-never-ran)
awk -F '	' -v OFS='	' 'NR==2 {$3="no";$6="NEVER_RUN";$7="-"} {print}' "$D/schedules.tsv" > "$D/x" && mv "$D/x" "$D/schedules.tsv"
run_bad SCHEDULE-NEVER-RAN operating-surveillance-never-ran "$D"

D=$(case_dir schedule-trigger-absent)
awk -F '	' -v OFS='	' 'NR==2 {$3="no";$5="no"} {print}' "$D/schedules.tsv" > "$D/x" && mv "$D/x" "$D/schedules.tsv"
run_bad SCHEDULE-TRIGGER-ABSENT schedule-claim-without-trigger "$D"

D=$(case_dir required-schedule-cancelled)
awk -F '	' -v OFS='	' 'NR==2 {$6="CANCELLED"} {print}' "$D/schedules.tsv" > "$D/x" && mv "$D/x" "$D/schedules.tsv"
run_bad SCHEDULE-NOT-PASS required-schedule-cancelled "$D"

D=$(case_dir completion-pending)
awk -F '	' -v OFS='	' '$1=="verify-control" {$4="PENDING";$5="not-run"} {print}' "$D/completion.tsv" > "$D/x" && mv "$D/x" "$D/completion.tsv"
run_bad COMPLETION-PENDING unfinished-required-step "$D"

D=$(case_dir completion-blocked)
awk -F '	' -v OFS='	' '$1=="verify-control" {$4="BLOCKED";$5="physical-device"} {print}' "$D/completion.tsv" > "$D/x" && mv "$D/x" "$D/completion.tsv"
run_bad COMPLETION-BLOCKED blocked-required-step "$D"

D=$(case_dir completion-failed)
awk -F '	' -v OFS='	' '$1=="verify-control" {$4="FAILED";$5="run-100"} {print}' "$D/completion.tsv" > "$D/x" && mv "$D/x" "$D/completion.tsv"
run_bad COMPLETION-FAILED failed-required-step "$D"

D=$(case_dir execution-plan-only)
awk -F '	' -v OFS='	' 'NR==1 || $2!="implementation"' "$D/completion.tsv" > "$D/x" && mv "$D/x" "$D/completion.tsv"
awk -F '	' -v OFS='	' 'NR==2 {$2="plan";$1="write-plan"} {print}' "$D/completion.tsv" > "$D/x" && mv "$D/x" "$D/completion.tsv"
run_bad EXECUTION-NOT-IMPLEMENTED execution-job-ended-with-plan "$D"

D=$(case_dir job-not-complete)
awk -F '	' -v OFS='	' '$1=="job_state" {$2="PENDING"} {print}' "$D/state.tsv" > "$D/x" && mv "$D/x" "$D/state.tsv"
run_bad JOB-INCOMPLETE successful-receipt-for-incomplete-job "$D"

D=$(case_dir check-state-table)
{
    printf '%s\n' 'workflow	job	event	run_id	required	binding	status	conclusion	reported_head_sha	checkout_sha	trigger_coverage'
    printf '%s\n' ".github/workflows/pass.yml	pass	pull_request	201	yes	head	completed	success	$H	$H	yes"
    printf '%s\n' ".github/workflows/fail.yml	fail	pull_request	202	yes	head	completed	failure	$H	$H	yes"
    printf '%s\n' ".github/workflows/cancel.yml	cancel	pull_request	203	yes	head	completed	cancelled	$H	$H	yes"
    printf '%s\n' ".github/workflows/skip.yml	skip	pull_request	204	yes	head	completed	skipped	$H	$H	yes"
    printf '%s\n' ".github/workflows/absent.yml	absent	pull_request	-	yes	head	missing	-	-	-	yes"
    printf '%s\n' ".github/workflows/stale.yml	stale	pull_request	205	yes	head	completed	success	$O	$O	yes"
    printf '%s\n' ".github/workflows/unknown.yml	unknown	pull_request	206	yes	head	in_progress	-	$H	$H	yes"
} > "$D/checks.tsv"
sh merge/check-table.sh "$D/state.tsv" "$D/checks.tsv" > "$D/check-table.out"
grep -F "HEAD        $H" "$D/check-table.out" >/dev/null
for row in 'pass PASS' 'fail FAIL' 'cancel CANCELLED' 'skip SKIPPED' 'absent ABSENT' 'stale STALE' 'unknown UNKNOWN'; do
    set -- $row
    awk -v check="$1" -v state="$2" '$1==check && $2==state {found=1} END {exit !found}' "$D/check-table.out" || {
        printf 'check table omitted normalized row: %s\n' "$row" >&2
        cat "$D/check-table.out" >&2
        exit 1
    }
done
printf 'PASS	check-state-table\n'

D=$(case_dir snapshot-directory)
sh merge/pr-verdict.sh "$D" >"$D/directory-out"
grep -F 'PASS	MERGE-AUTHORIZATION' "$D/directory-out" >/dev/null
printf 'PASS	snapshot-directory-entrypoint\n'
