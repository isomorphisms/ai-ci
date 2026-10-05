#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
classifier=${1:-"$root/merge/state.sh"}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

checks_header='name\trequired\trun_ref\tobserved_head\tcheckout_sha\ttested_base_sha\tbase_independent\tbinding\tstatus\tconclusion\ttrigger_coverage\tfailure_class\tbaseline_ref\taction'
evidence_header='claim\trequired\tresult\thead_sha\trequired_head_sha\tevidence_class\trequired_evidence_class\texecution\trequired_execution\thardware\trequired_hardware\tnetwork\trequired_network\tprovenance\trequired_provenance\texecution_result\trequired_execution_result\tsource_sha\trequired_source_sha\tartifact_sha256\trequired_artifact_sha256\treceipt_ref\taction\treuse_rule\trelevant_digest\trequired_relevant_digest'

write_common() {
    directory=$1 repository=$2 pr=$3 title=$4 head=$5 live_base=$6 reported_base=$7
    draft=$8 mergeable=$9
    shift 9
    conflict_paths=$1 overlap=$2 promotion_state=$3 promotion_condition=$4
    promotion_action=$5 promotion_class=$6 authorization_state=$7 authorization_kind=$8
    mkdir -p "$directory"
    printf '%b\n' \
        'schema\taici-pr-observation-v1' \
        "repository\t$repository" \
        "pr\t$pr" \
        "title\t$title" \
        "head_sha\t$head" \
        'base_ref\tmain' \
        "live_base_sha\t$live_base" \
        "reported_base_sha\t$reported_base" \
        "draft\t$draft" \
        "mergeable\t$mergeable" \
        "conflict_paths\t$conflict_paths" \
        "changed_path_overlap\t$overlap" \
        'auto_reconcile\tno' \
        "promotion_state\t$promotion_state" \
        "promotion_condition\t$promotion_condition" \
        "promotion_action\t$promotion_action" \
        "promotion_evidence_class\t$promotion_class" > "$directory/pr.tsv"
    printf '%b\n' "$checks_header" > "$directory/checks.tsv"
    printf '%b\n' "$evidence_header" > "$directory/evidence.tsv"
    printf '%b\n' 'dependency\trequired\tstate\texpected\tobserved\tobject_ref\taction' > "$directory/dependencies.tsv"
    printf '%b\n' 'follower\tblocking\ttrigger\tcurrent_trigger\tacceptance_kind\tstate\tsuccessor\tobject_ref\taction' > "$directory/followers.tsv"
    printf '%b\n' \
        'schema\taici-merge-authorization-observation-v1' \
        "state\t$authorization_state" \
        "head_sha\t$head" \
        "authority_kind\t$authorization_kind" \
        'scope_state\tsame' \
        "receipt_ref\t$repository#$pr-authorization" \
        'action\trecord-explicit-authority' > "$directory/authorization.tsv"
}

expect_codes() {
    name=$1 directory=$2 expected=$3
    status=0
    "$classifier" "$directory" > "$directory/result.tsv" || status=$?
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    actual=$(awk -F '\t' 'NR>1 {print $2}' "$directory/result.tsv" | sort -u | paste -sd, -)
    [ "$actual" = "$expected" ] || {
        printf 'real-state %s: expected %s, observed %s\n' "$name" "$expected" "$actual" >&2
        sed -n '1,$p' "$directory/result.tsv" >&2
        exit 1
    }
    printf 'PASS\t%s\t%s\n' "$name" "$actual"
}

# Clean current PR: exact-head CI is green; the sole remaining decision is
# durable human merge authority.
D=$work/ib-73
H=6a5e7b7e21a3d0176959c8d57149c7dcaf2975a0
B=be71ac0018468f8052e4c4999f3fa6ae0a7150fe
write_common "$D" isomorphisms/ib 73 'Repair occurrence evidence contract' "$H" "$B" "$B" no yes - no NONE - mark-ready - missing none
printf '%b\n' "IB-foundation\tyes\tworkflow-run:35514263059\t$H\t$H\t$B\tno\thead\tcompleted\tsuccess\tyes\t-\t-\trerun-exact-head" >> "$D/checks.tsv"
expect_codes ib-73-clean-only-needs-authority "$D" HUMAN_AUTHORIZATION_REQUIRED

# Current draft: cloud build/emulator evidence exists, but the declared phone
# survival claim has not been rerun on the exact head.
D=$work/ib-74
H=9b72b414f3e554005b7f6d43162b1928eaf1f631
B=2dba8be604a8c27609af0e73b35e2756786367a2
write_common "$D" isomorphisms/ib 74 'Keep incremental WebView loads alive while using another app' "$H" "$B" "$B" yes yes - no NOT_VERIFIED webview-background-survival run-retained-phone-command physical-phone missing none
printf '%b\n' \
    "IB-foundation\tyes\tworkflow-run:35511801959\t$H\t$H\t-\tyes\thead\tcompleted\tsuccess\tyes\t-\t-\trerun-exact-head" \
    "Android-WebView\tyes\tworkflow-run:35511801979\t$H\t$H\t-\tyes\thead\tcompleted\tsuccess\tyes\t-\t-\trerun-exact-head" >> "$D/checks.tsv"
printf '%b\n' "webview-background-survival\tyes\tNOT_VERIFIED\t-\t$H\tphysical-phone\tphysical-phone\tnone\tphysical\tnone\tphysical\tnone\texternal-tls\tnone\tinstalled-artifact\tnone\tsemantic-pass\t-\t-\t-\t-\t-\trun-retained-phone-command\texact-head\t-\t-" >> "$D/evidence.tsv"
expect_codes ib-74-device-proof-remains-not-verified "$D" HUMAN_AUTHORIZATION_REQUIRED,PHYSICAL_EXECUTION_REQUIRED

# Green historical checks cannot pass after exact-head checkout inspection
# shows that the old workflow tested a synthetic merge ref.
D=$work/catfood-69
H=38daf2c7388b372eddd4ff3616f2b8379a10048f
B=704e7bf06127373f86bbf1e9c3d363fab429540c
write_common "$D" isomorphisms/catfood 69 'Deliver Reddit through the normal Android package path' "$H" "$B" "$B" no yes - no NONE - mark-ready - missing none
printf '%b\n' "follower-reconciliation\tyes\tworkflow-run:35509991016\t$H\t-\t-\tyes\tsynthetic-merge\tcompleted\tsuccess\tyes\t-\t-\tadopt-exact-head-workflow" >> "$D/checks.tsv"
printf '%b\n' "phone\tno\t$H\t$H\tphysical-device\tpending\t-\tfollowers/jobs/phone.tsv\trun-follower" >> "$D/followers.tsv"
expect_codes catfood-69-green-is-not-exact-head "$D" CI_STALE,HUMAN_AUTHORIZATION_REQUIRED

# Conflict and stale CI remain distinct blockers.
D=$work/catfood-47
H=2517b9f194b01f888d5e528e531619ae4a623b36
B=704e7bf06127373f86bbf1e9c3d363fab429540c
R=5e585181ed1d276e8f016e77ccfd4b58b2ce153a
write_common "$D" isomorphisms/catfood 47 'Deliver cloud-storage API across targets' "$H" "$B" "$R" no no unknown unknown NONE - mark-ready - missing none
printf '%b\n' "stage-zero\tyes\tworkflow-run:35124403449\t$H\t-\t$R\tno\tsynthetic-merge\tcompleted\tfailure\tyes\tunknown\t-\trerun-after-conflict" >> "$D/checks.tsv"
expect_codes catfood-47-conflict-is-distinct "$D" CI_STALE,CONFLICT,HUMAN_AUTHORIZATION_REQUIRED

# A physical phone receipt for an unchanged exact producer/archive remains a
# bounded PASS under the explicit exact-artifact reuse rule. The PR is still
# blocked by its independent conflict and stale CI.
D=$work/catfood-41
H=a69a7ee0abf8289fdf75e83f24e140d19512e6fc
B=704e7bf06127373f86bbf1e9c3d363fab429540c
R=b0f2653a139aa6de741ad2c15ef1fe2d757c149c
O=cb726afa73a7b8484d4469790d8dab1945a511bb
S=7a2c75f1564dfe82fddee4e975367faf5a3720e4
A=714e5f706a05224ff4f43188a6fb043e7fa39f6a7f7f6ea7b0ef0dcb424502de
write_common "$D" isomorphisms/catfood 41 'Deliver cloud-built PowerVR runners to Android targets' "$H" "$B" "$R" no no unknown unknown NONE - mark-ready - missing none
printf '%b\n' "follower-reconciliation\tyes\tworkflow-run:35387945869\t$H\t-\t$R\tno\tsynthetic-merge\tcompleted\tsuccess\tyes\t-\t-\trerun-after-conflict" >> "$D/checks.tsv"
printf '%b\n' "powervr-phone\tyes\tPASS\t$O\t$H\tphysical-phone\tphysical-phone\tphysical\tphysical\tphysical\tphysical\tnone\tnone\tinstalled-artifact\tinstalled-artifact\tsemantic-pass\tsemantic-pass\t$S\t$S\t$A\t$A\tfollowers/receipts/catfood-cb726afa73a7-phone.tsv\trun-phone-follower\texact-artifact\t-\t-" >> "$D/evidence.tsv"
expect_codes catfood-41-reuses-only-the-exact-device-artifact "$D" CI_STALE,CONFLICT,HUMAN_AUTHORIZATION_REQUIRED

# Recent real authorization case: exact required check plus exact explicit
# authority yields READY without a second permission prompt.
D=$work/aici-139
H=4513bb0a7bc5d0d61d669ecb0a62244c945e6a81
B=084a1710d7257b4857b9c04aa1fc27f143365511
write_common "$D" isomorphisms/ai-ci 139 'Require exact merge approval receipts' "$H" "$B" "$B" no yes - no NONE - mark-ready - valid explicit-merge
printf '%b\n' "merge-authorization\tyes\tworkflow-run:35491443876\t$H\t$H\t-\tyes\thead\tcompleted\tsuccess\tyes\t-\t-\tmerge" >> "$D/checks.tsv"
expect_codes aici-139-valid-authority-does-not-reprompt "$D" READY

printf '%s\n' 'real merge-state dogfood passes'
