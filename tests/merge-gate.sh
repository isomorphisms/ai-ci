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

write_good() {
    d=$1
    mkdir -p "$d"
    cat > "$d/state.tsv" <<STATE
schema	aici-merge-state-v1
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
id	result	head_sha	source_sha	artifact_sha256	platform	abi	execution	hardware	network	artifact_mode	required_source_sha	required_artifact_sha256	required_platform	required_abi	required_execution	required_hardware	required_network	required_artifact_mode
runtime	PASS	$H	$S	$A	android-bionic	aarch64	android-emulator	virtual	none	exact-prebuilt	$S	$A	android-bionic	aarch64	android-emulator	virtual	none	exact-prebuilt
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
}

run_good() {
    name=$1; d=$2
    if ! sh "$bin" verify "$d/state.tsv" "$d/checks.tsv" "$d/dependencies.tsv" "$d/receipts.tsv" "$d/scope.tsv" "$d/consumer.tsv" >"$d/out" 2>"$d/err"; then
        printf 'good case failed: %s\n' "$name" >&2
        cat "$d/err" >&2
        exit 1
    fi
    printf 'PASS	%s\n' "$name"
}

run_bad() {
    expected=$1; name=$2; d=$3
    if sh "$bin" verify "$d/state.tsv" "$d/checks.tsv" "$d/dependencies.tsv" "$d/receipts.tsv" "$d/scope.tsv" "$d/consumer.tsv" >"$d/out" 2>"$d/err"; then
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

D=$(case_dir receipt-wrong-head)
awk -F '	' -v OFS='	' -v old="$O" 'NR==2 {$3=old} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-HEAD receipt-wrong-head "$D"

D=$(case_dir receipt-wrong-artifact)
awk -F '	' -v OFS='	' -v wrong="$C" 'NR==2 {$13=wrong} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
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
run_bad CHECK-WRONG-HEAD historical-green-after-rebase "$D"

D=$(case_dir skipped)
awk -F '	' -v OFS='	' 'NR==2 {$8="skipped"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-SKIPPED skipped-required-check "$D"

D=$(case_dir absent)
awk -F '	' -v OFS='	' 'NR==2 {$4="-";$7="missing";$8="-";$9="-";$10="-"} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-MISSING absent-required-workflow "$D"

D=$(case_dir malformed-pass)
awk -F '	' -v OFS='	' 'NR==2 {NF=18} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPTS-MALFORMED malformed-pass-receipt "$D"

D=$(case_dir wrong-abi)
awk -F '	' -v OFS='	' 'NR==2 {$15="armeabi-v7a"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-ABI wrong-abi "$D"

D=$(case_dir emulator-as-physical)
awk -F '	' -v OFS='	' 'NR==2 {$16="physical";$17="physical"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-EXECUTION emulator-as-physical "$D"

D=$(case_dir mock-as-runtime)
awk -F '	' -v OFS='	' 'NR==2 {$8="host";$9="mock";$16="host";$17="physical"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
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

D=$(case_dir receipt-wrong-source)
awk -F '	' -v OFS='	' -v wrong="$O" 'NR==2 {$12=wrong} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-SOURCE receipt-wrong-source "$D"

D=$(case_dir wrong-platform)
awk -F '	' -v OFS='	' 'NR==2 {$14="linux-glibc"} {print}' "$D/receipts.tsv" > "$D/x" && mv "$D/x" "$D/receipts.tsv"
run_bad RECEIPT-WRONG-PLATFORM wrong-platform "$D"

D=$(case_dir synthetic-only-check)
awk -F '	' -v OFS='	' -v merge="$M" '$1=="event_sha" {$2=merge} $1=="event_kind" {$2="synthetic-merge"} {print}' "$D/state.tsv" > "$D/x" && mv "$D/x" "$D/state.tsv"
awk -F '	' -v OFS='	' -v merge="$M" 'NR==2 {$6="synthetic-merge";$10=merge} {print}' "$D/checks.tsv" > "$D/x" && mv "$D/x" "$D/checks.tsv"
run_bad CHECK-EXACT-HEAD-MISSING synthetic-only-cannot-authorize-head "$D"

D=$(case_dir moving-resolved-good)
awk -F '	' -v OFS='	' 'NR==2 {$3="moving-resolved";$4="Idriç";$6="-"} {print}' "$D/dependencies.tsv" > "$D/x" && mv "$D/x" "$D/dependencies.tsv"
run_good active-integration-moving-ref-resolved "$D"
