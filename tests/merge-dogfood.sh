#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
corpus=${1:-"$root/docs/dogfood/2026-09-20.tsv"}

awk -F '\t' '
BEGIN {
    expected="observed_at\trepository\tpr\thead\tdraft\tmergeable\tcheck_runs\tevidence_case\tblocker_set\tblocker_object\taction\tphase\tbefore_steps\tbefore_api_reads\tbefore_manual_inferences\tafter_commands\tafter_api_reads_max\tafter_manual_inferences"
}
NR==1 { if ($0!=expected) { print "dogfood: wrong header" > "/dev/stderr"; exit 1 }; next }
{
    if (NF!=18 || $2 !~ /^[^/]+\/[A-Za-z0-9_.-]+$/ || $3 !~ /^[1-9][0-9]*$/ ||
        length($4)!=40 || $4 !~ /^[0-9a-f]+$/ || ($5!="yes" && $5!="no") ||
        ($6!="yes" && $6!="no") || $7 !~ /^[0-9]+$/ || $9=="" || $10=="" ||
        $11=="" || ($12!="baseline" && $12!="postchange") || $16!=1 || $17>4 || $18!=0) {
        print "dogfood: malformed row " NR > "/dev/stderr"
        exit 1
    }
    rows++
    repositories[$2]=1
    blockers=blockers "," $9 ","
    evidence=evidence "," $8 ","
    if ($12=="baseline") {
        baseline++
        before_steps+=$13
        before_api+=$14
        before_inference+=$15
        after_commands+=$16
        after_api+=$17
        after_inference+=$18
    }
}
END {
    if (rows<20 || baseline<13) exit 1
    for (repository in repositories) count++
    if (count<7) exit 1
    required[1]="CONFLICT"; required[2]="CI_PENDING"; required[3]="CI_STALE"
    required[4]="FOLLOWER_PENDING"; required[5]="NOT_VERIFIED"
    required[6]="PHYSICAL_EXECUTION_REQUIRED"; required[7]="HUMAN_AUTHORIZATION_REQUIRED"
    required[8]="AMBIGUOUS"
    for (i=1; i<=8; i++) if (index(blockers, "," required[i])==0) exit 1
    if (index(evidence, ",physical-present-reusable,")==0 ||
        index(evidence, ",emulated-only,")==0 ||
        index(evidence, ",packaged-only,")==0) exit 1
    printf "dogfood rows=%d repositories=%d baseline_prs=%d\n", rows, count, baseline
    printf "before discovery_steps=%d api_reads=%d manual_inferences=%d\n", before_steps, before_api, before_inference
    printf "after commands=%d api_reads_max=%d manual_inferences=%d\n", after_commands, after_api, after_inference
}
' "$corpus"
