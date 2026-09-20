#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
classifier=${1:-"$root/merge/state.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

H=1111111111111111111111111111111111111111
B=2222222222222222222222222222222222222222
O=9999999999999999999999999999999999999999
S=3333333333333333333333333333333333333333
A=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

write_good() {
    destination=$1
    mkdir -p "$destination"
    printf '%b\n' \
        'schema\taici-pr-observation-v1' \
        'repository\tisomorphisms/example' \
        'pr\t17' \
        'title\tExample ordinary change' \
        "head_sha\t$H" \
        'base_ref\tmain' \
        "live_base_sha\t$B" \
        "reported_base_sha\t$B" \
        'draft\tno' \
        'mergeable\tyes' \
        'conflict_paths\t-' \
        'changed_path_overlap\tno' \
        'auto_reconcile\tyes' \
        'promotion_state\tNONE' \
        'promotion_condition\t-' \
        'promotion_action\tmark-ready' \
        'promotion_evidence_class\t-' > "$destination/pr.tsv"
    printf '%b\n' \
        'name\trequired\trun_ref\tobserved_head\tcheckout_sha\ttested_base_sha\tbase_independent\tbinding\tstatus\tconclusion\ttrigger_coverage\tfailure_class\tbaseline_ref\taction' \
        "verify\tyes\trun-100\t$H\t$H\t$B\tno\thead\tcompleted\tsuccess\tyes\t-\tbase-run-90\trerun-exact-head" > "$destination/checks.tsv"
    printf '%b\n' \
        'claim\trequired\tresult\thead_sha\trequired_head_sha\tevidence_class\trequired_evidence_class\texecution\trequired_execution\thardware\trequired_hardware\tnetwork\trequired_network\tprovenance\trequired_provenance\texecution_result\trequired_execution_result\tsource_sha\trequired_source_sha\tartifact_sha256\trequired_artifact_sha256\treceipt_ref\taction' \
        "runtime\tyes\tPASS\t$H\t$H\tphysical-phone\tphysical-phone\tphysical\tphysical\tphysical\tphysical\texternal-tls\texternal-tls\tinstalled-artifact\tinstalled-artifact\tsemantic-pass\tsemantic-pass\t$S\t$S\t$A\t$A\treceipt-phone.tsv\trun-phone-acceptance" > "$destination/evidence.tsv"
    printf '%b\n' \
        'dependency\trequired\tstate\texpected\tobserved\tobject_ref\taction' \
        "compiler\tyes\tREADY\t$S\t$S\tisomorphisms/Idric@$S\treconcile-dependency" > "$destination/dependencies.tsv"
    printf '%b\n' \
        'follower\tblocking\ttrigger\tcurrent_trigger\tacceptance_kind\tstate\tsuccessor\tobject_ref\taction' \
        "phone\tno\t$H\t$H\tphysical-device\tpending\t-\tfollowers/jobs/phone.tsv\trun-follower" > "$destination/followers.tsv"
    printf '%b\n' \
        'schema\taici-merge-authorization-observation-v1' \
        'state\tvalid' \
        "head_sha\t$H" \
        'authority_kind\ttask-context' \
        'scope_state\tsame' \
        'receipt_ref\tmerge/approval.tsv' \
        'action\trefresh-authorization' > "$destination/authorization.tsv"
}

rewrite_key() {
    file=$1 key=$2 value=$3
    awk -F '\t' -v OFS='\t' -v key="$key" -v value="$value" \
        '$1==key {$2=value} {print}' "$file" > "$file.new"
    mv "$file.new" "$file"
}

rewrite_row() {
    file=$1 column=$2 value=$3
    awk -F '\t' -v OFS='\t' -v column="$column" -v value="$value" \
        'NR==2 {$column=value} {print}' "$file" > "$file.new"
    mv "$file.new" "$file"
}

expect_ready() {
    name=$1 directory=$2
    if ! "$classifier" "$directory" > "$directory/out"; then
        printf 'FAIL: ready case was blocked: %s\n' "$name" >&2
        sed -n '1,120p' "$directory/out" >&2
        exit 1
    fi
    awk -F '\t' 'NR==2 && $1=="READY" && $2=="READY" {found=1} END {exit !found}' "$directory/out"
    printf 'PASS\t%s\n' "$name"
}

expect_blocker() {
    name=$1 expected=$2 directory=$3
    if "$classifier" "$directory" > "$directory/out"; then
        printf 'FAIL: blocked case became READY: %s\n' "$name" >&2
        exit 1
    fi
    awk -F '\t' -v expected="$expected" 'NR>1 && $2==expected {found=1} END {exit !found}' "$directory/out" || {
        printf 'FAIL: %s omitted %s\n' "$name" "$expected" >&2
        sed -n '1,120p' "$directory/out" >&2
        exit 1
    }
    printf 'PASS\t%s\t%s\n' "$name" "$expected"
}

case_dir() { directory=$work/$1; write_good "$directory"; printf '%s\n' "$directory"; }

D=$(case_dir ready); expect_ready clean-pr-does-not-need-another-audit "$D"

D=$(case_dir stale-ci); rewrite_row "$D/checks.tsv" 4 "$O"; expect_blocker stale-exact-head-evidence CI_STALE "$D"

D=$(case_dir stale-follower); rewrite_row "$D/followers.tsv" 3 "$O"; expect_blocker stale-follower-current-trigger FOLLOWER_STALE "$D"

D=$(case_dir package-not-physical)
rewrite_row "$D/evidence.tsv" 6 github-runner
rewrite_row "$D/evidence.tsv" 8 compile
rewrite_row "$D/evidence.tsv" 10 virtual
rewrite_row "$D/evidence.tsv" 14 packaged-only
rewrite_row "$D/evidence.tsv" 16 packaged
expect_blocker artifact-publication-is-not-phone-execution PHYSICAL_EXECUTION_REQUIRED "$D"

D=$(case_dir fake-transport); rewrite_row "$D/evidence.tsv" 12 fake-tls; expect_blocker fake-transport-is-not-external-network EVIDENCE_MISSING "$D"

D=$(case_dir qemu-phone); rewrite_row "$D/evidence.tsv" 6 qemu-system; rewrite_row "$D/evidence.tsv" 8 full-system; rewrite_row "$D/evidence.tsv" 10 virtual; expect_blocker qemu-is-not-phone PHYSICAL_EXECUTION_REQUIRED "$D"

D=$(case_dir ambiguous-okay); rewrite_key "$D/authorization.tsv" state missing; rewrite_key "$D/authorization.tsv" authority_kind acknowledgement; expect_blocker okay-is-not-authority HUMAN_AUTHORIZATION_REQUIRED "$D"

D=$(case_dir explicit-authority); rewrite_key "$D/authorization.tsv" authority_kind explicit-merge; expect_ready explicit-authority-does-not-reprompt "$D"

D=$(case_dir draft-satisfied); rewrite_key "$D/pr.tsv" draft yes; rewrite_key "$D/pr.tsv" promotion_state PASS; rewrite_key "$D/pr.tsv" promotion_condition all-declared-evidence-pass; expect_blocker satisfied-draft-is-mechanically-promotable DRAFT "$D"

D=$(case_dir upstream); rewrite_row "$D/checks.tsv" 10 failure; rewrite_row "$D/checks.tsv" 12 baseline; expect_blocker baseline-failure-is-not-pr-failure UPSTREAM_FAILURE "$D"

D=$(case_dir conflict); rewrite_key "$D/pr.tsv" mergeable no; rewrite_key "$D/pr.tsv" conflict_paths src/a.c,src/b.c; rewrite_key "$D/pr.tsv" changed_path_overlap yes; expect_blocker conflict-is-not-ci-failure CONFLICT "$D"

D=$(case_dir conflict-repaired-old-check); rewrite_row "$D/checks.tsv" 6 "$O"; expect_blocker repaired-conflict-invalidates-old-integration-check CI_STALE "$D"

D=$(case_dir not-verified); rewrite_row "$D/evidence.tsv" 3 NOT_VERIFIED; rewrite_row "$D/evidence.tsv" 7 host; expect_blocker absence-of-proof-is-not-failure NOT_VERIFIED "$D"

D=$(case_dir wrong-commit); rewrite_row "$D/evidence.tsv" 4 "$O"; expect_blocker receipt-tied-to-wrong-commit EVIDENCE_STALE "$D"

D=$(case_dir obsolete-dependent); rewrite_row "$D/followers.tsv" 3 "$O"; rewrite_row "$D/followers.tsv" 6 accepted; expect_blocker completed-obsolete-dependent-stays-stale FOLLOWER_STALE "$D"

printf '%s\n' 'merge-state regression corpus passes'
