#!/bin/sh
set -eu

[ "$#" -eq 1 ] || {
    echo 'usage: merge/state.sh SNAPSHOT_DIRECTORY' >&2
    exit 2
}

snapshot=$1
for name in pr checks evidence dependencies followers authorization; do
    test -f "$snapshot/$name.tsv" || {
        printf 'BLOCKED\tAMBIGUOUS\tsnapshot\t%s\t-\tcreate-observation\tmissing=%s.tsv\n' \
            "$snapshot" "$name"
        exit 1
    }
done

awk \
    -v pr_file="$snapshot/pr.tsv" \
    -v checks_file="$snapshot/checks.tsv" \
    -v evidence_file="$snapshot/evidence.tsv" \
    -v dependencies_file="$snapshot/dependencies.tsv" \
    -v followers_file="$snapshot/followers.tsv" \
    -v authorization_file="$snapshot/authorization.tsv" '
BEGIN { FS="\t"; OFS="\t" }

function present(value) { return value != "" }
function token(value) { return value != "" && value !~ /[[:space:]]/ }
function one_of(value, choices,    item, count, position) {
    count=split(choices,item,"|")
    for(position=1; position<=count; position++) if(value==item[position]) return 1
    return 0
}
function git_sha(value) {
    return (length(value)==40 || length(value)==64) && value ~ /^[0-9a-f]+$/
}
function optional_git_sha(value) { return value=="-" || git_sha(value) }
function sha256_or_dash(value) {
    return value=="-" || (length(value)==64 && value ~ /^[0-9a-f]+$/)
}
function yes_no(value) { return value=="yes" || value=="no" }
function noncomment() { return $0 !~ /^[[:space:]]*(#|$)/ }
function reset_file() { header_seen=0 }
function blocker(code, kind, reference, action, detail,    key) {
    key=code SUBSEP kind SUBSEP reference SUBSEP action SUBSEP detail
    if (emitted[key]++) return
    blockers++
    rows[blockers]="BLOCKED" OFS code OFS kind OFS reference OFS pr["head_sha"] OFS action OFS detail
}
function malformed(kind, detail) {
    blocker("AMBIGUOUS",kind,kind,"repair-observation",detail)
}

FILENAME!=previous_file { previous_file=FILENAME; reset_file() }

FILENAME==pr_file && noncomment() {
    if (NF!=2 || !present($1) || !present($2)) {
        malformed("pr","expected-key-value-row")
        next
    }
    if (seen_pr[$1]++) malformed("pr","duplicate=" $1)
    pr[$1]=$2
    next
}

FILENAME==checks_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="name\trequired\trun_ref\tobserved_head\tcheckout_sha\ttested_base_sha\tbase_independent\tbinding\tstatus\tconclusion\ttrigger_coverage\tfailure_class\tbaseline_ref\taction") malformed("checks","wrong-header")
        next
    }
    if (NF!=14 || !token($1) || !yes_no($2) || !optional_git_sha($4) ||
        !optional_git_sha($5) || !optional_git_sha($6) || !yes_no($7) ||
        !one_of($8,"head|synthetic-merge|unknown") ||
        !one_of($9,"queued|in_progress|completed|missing") ||
        !one_of($10,"success|failure|cancelled|skipped|timed_out|neutral|action_required|-") ||
        !yes_no($11) || !one_of($12,"pr|baseline|upstream|transient|unknown|-") ||
        !token($14)) {
        malformed("check",$1)
        next
    }
    if ($2!="yes") next
    required_checks++
    if ($9=="queued" || $9=="in_progress") {
        blocker("CI_PENDING","check",$1,$14,"run=" $3)
        next
    }
    if ($9=="missing") {
        blocker("NOT_VERIFIED","check",$1,$14,"required-check-absent")
        next
    }
    if ($4!=pr["head_sha"] || $5!=pr["head_sha"] || $8!="head" ||
        ($7=="no" && $6!=pr["live_base_sha"]) || $11!="yes") {
        blocker("CI_STALE","check",$1,$14,"run=" $3)
        next
    }
    if ($10=="success") next
    if ($10=="failure" || $10=="timed_out") {
        if ($12=="pr") blocker("CI_FAILED","check",$1,$14,"run=" $3)
        else if ($12=="baseline" || $12=="upstream") blocker("UPSTREAM_FAILURE","check",$1,$14,"baseline=" $13)
        else if ($12=="transient") blocker("INFRASTRUCTURE_FAILURE","check",$1,$14,"run=" $3)
        else blocker("AMBIGUOUS","check",$1,"compare-target-branch","run=" $3)
        next
    }
    if ($10=="cancelled") blocker("CI_FAILED","check",$1,$14,"conclusion=cancelled")
    else if ($10=="skipped") blocker("NOT_VERIFIED","check",$1,$14,"conclusion=skipped")
    else blocker("AMBIGUOUS","check",$1,"inspect-check","conclusion=" $10)
    next
}

FILENAME==evidence_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="claim\trequired\tresult\thead_sha\trequired_head_sha\tevidence_class\trequired_evidence_class\texecution\trequired_execution\thardware\trequired_hardware\tnetwork\trequired_network\tprovenance\trequired_provenance\texecution_result\trequired_execution_result\tsource_sha\trequired_source_sha\tartifact_sha256\trequired_artifact_sha256\treceipt_ref\taction\treuse_rule\trelevant_digest\trequired_relevant_digest") malformed("evidence","wrong-header")
        next
    }
    if (NF!=26 || !token($1) || !yes_no($2) || !one_of($3,"PASS|FAIL|NOT_VERIFIED") ||
        !optional_git_sha($4) || !optional_git_sha($5) || !token($6) || !token($7) ||
        !token($8) || !token($9) || !token($10) || !token($11) || !token($12) ||
        !token($13) || !token($14) || !token($15) || !token($16) || !token($17) ||
        !optional_git_sha($18) || !optional_git_sha($19) || !sha256_or_dash($20) ||
        !sha256_or_dash($21) || !present($22) || !token($23) ||
        !one_of($24,"exact-head|exact-artifact|relevant-tree") ||
        !sha256_or_dash($25) || !sha256_or_dash($26)) {
        malformed("evidence",$1)
        next
    }
    if ($2!="yes") next
    required_evidence++
    if ($3=="NOT_VERIFIED") {
        if (one_of($7,"physical-phone|physical-tablet"))
            blocker("PHYSICAL_EXECUTION_REQUIRED","claim",$1,$23,"receipt=" $22 ";result=NOT_VERIFIED")
        else blocker("NOT_VERIFIED","claim",$1,$23,"receipt=" $22)
        next
    }
    if ($3=="FAIL") {
        blocker("EVIDENCE_FAILED","claim",$1,$23,"receipt=" $22)
        next
    }
    head_fresh=($4==$5 && $4==pr["head_sha"])
    artifact_reusable=($24=="exact-artifact" && $20!="-" && $20==$21 && $18==$19)
    tree_reusable=($24=="relevant-tree" && $25!="-" && $25==$26 && $18==$19 && $20==$21)
    if ((!head_fresh && !artifact_reusable && !tree_reusable) || $18!=$19 || $20!=$21) {
        blocker("EVIDENCE_STALE","claim",$1,$23,"receipt=" $22)
        next
    }
    if ($6!=$7 || $8!=$9 || $10!=$11) {
        if (one_of($7,"physical-phone|physical-tablet"))
            blocker("PHYSICAL_EXECUTION_REQUIRED","claim",$1,$23,"receipt=" $22 ";wrong-provenance")
        else blocker("EVIDENCE_MISSING","claim",$1,$23,"receipt=" $22 ";wrong-provenance")
        next
    }
    if ($12!=$13 || $14!=$15 || $16!=$17) {
        blocker("EVIDENCE_MISSING","claim",$1,$23,"receipt=" $22 ";wrong-provenance")
    }
    next
}

FILENAME==dependencies_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="dependency\trequired\tstate\texpected\tobserved\tobject_ref\taction") malformed("dependencies","wrong-header")
        next
    }
    if (NF!=7 || !token($1) || !yes_no($2) || !one_of($3,"READY|PENDING|STALE|FAILED|NOT_VERIFIED") || !present($4) || !present($5) || !present($6) || !token($7)) {
        malformed("dependency",$1)
        next
    }
    if ($2!="yes" || $3=="READY") next
    if ($3=="NOT_VERIFIED") blocker("NOT_VERIFIED","dependency",$1,$7,"object=" $6)
    else blocker("DEPENDENCY_PENDING","dependency",$1,$7,"state=" $3 ";object=" $6)
    next
}

FILENAME==followers_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="follower\tblocking\ttrigger\tcurrent_trigger\tacceptance_kind\tstate\tsuccessor\tobject_ref\taction") malformed("followers","wrong-header")
        next
    }
    if (NF!=9 || !token($1) || !yes_no($2) || !git_sha($3) || !git_sha($4) ||
        !token($5) || !one_of($6,"accepted|pending|blocked|unsupported|superseded|not-verified") ||
        !present($7) || !present($8) || !token($9)) {
        malformed("follower",$1)
        next
    }
    if ($3!=$4 && $6!="superseded") {
        blocker("FOLLOWER_STALE","follower",$1,$9,"old_trigger=" $3 ";current_trigger=" $4)
        next
    }
    if ($6=="superseded" && $7=="-") {
        blocker("FOLLOWER_STALE","follower",$1,$9,"successor=missing")
        next
    }
    if ($2!="yes" || $6=="accepted" || $6=="superseded") next
    if ($5=="physical-device")
        blocker("PHYSICAL_EXECUTION_REQUIRED","follower",$1,$9,"state=" $6 ";object=" $8)
    else blocker("FOLLOWER_PENDING","follower",$1,$9,"state=" $6 ";object=" $8)
    next
}

FILENAME==authorization_file && noncomment() {
    if (NF!=2 || !present($1) || !present($2)) {
        malformed("authorization","expected-key-value-row")
        next
    }
    if (seen_authorization[$1]++) malformed("authorization","duplicate=" $1)
    authorization[$1]=$2
    next
}

END {
    if (pr["schema"]!="aici-pr-observation-v1" || !present(pr["repository"]) ||
        pr["pr"] !~ /^[1-9][0-9]*$/ || !present(pr["title"]) || !git_sha(pr["head_sha"]) ||
        !present(pr["base_ref"]) || !git_sha(pr["live_base_sha"]) ||
        !git_sha(pr["reported_base_sha"]) || !yes_no(pr["draft"]) ||
        !one_of(pr["mergeable"],"yes|no|unknown") || !present(pr["conflict_paths"]) ||
        !one_of(pr["changed_path_overlap"],"yes|no|unknown") ||
        !yes_no(pr["auto_reconcile"]) ||
        !one_of(pr["promotion_state"],"PASS|FAIL|NOT_VERIFIED|HOLD|NONE") ||
        !present(pr["promotion_condition"]) || !token(pr["promotion_action"]) ||
        !present(pr["promotion_evidence_class"])) malformed("pr","missing-or-invalid-field")

    if (pr["mergeable"]=="no") {
        action=(pr["auto_reconcile"]=="yes" && pr["changed_path_overlap"]=="no") ? "auto-reconcile" : "resolve-conflict"
        blocker("CONFLICT","pr",pr["repository"] "#" pr["pr"],action,"paths=" pr["conflict_paths"])
    } else if (pr["mergeable"]=="unknown") {
        blocker("AMBIGUOUS","pr",pr["repository"] "#" pr["pr"],"refresh-mergeability","mergeable=unknown")
    }

    if (pr["draft"]=="yes") {
        if (pr["promotion_state"]=="PASS")
            blocker("DRAFT","pr",pr["repository"] "#" pr["pr"],pr["promotion_action"],"condition=" pr["promotion_condition"])
        else if (pr["promotion_state"]=="NOT_VERIFIED" && one_of(pr["promotion_evidence_class"],"physical-phone|physical-tablet"))
            blocker("PHYSICAL_EXECUTION_REQUIRED","promotion",pr["promotion_condition"],pr["promotion_action"],"draft=yes;result=NOT_VERIFIED")
        else if (pr["promotion_state"]=="NOT_VERIFIED")
            blocker("NOT_VERIFIED","promotion",pr["promotion_condition"],pr["promotion_action"],"draft=yes")
        else if (pr["promotion_state"]=="FAIL" || pr["promotion_state"]=="HOLD")
            blocker("DRAFT","promotion",pr["promotion_condition"],pr["promotion_action"],"state=" pr["promotion_state"])
        else blocker("AMBIGUOUS","promotion",pr["repository"] "#" pr["pr"],"declare-promotion-condition","draft-without-condition")
    }

    if (authorization["schema"]!="aici-merge-authorization-observation-v1" ||
        !one_of(authorization["state"],"valid|missing|stale|revoked|ambiguous") ||
        !present(authorization["head_sha"]) || !present(authorization["authority_kind"]) ||
        !present(authorization["scope_state"]) || !present(authorization["receipt_ref"]) ||
        !token(authorization["action"])) malformed("authorization","missing-or-invalid-field")
    else if (authorization["state"]=="valid" && authorization["head_sha"]==pr["head_sha"]) {
        # Exact valid authority is intentionally silent: no repeated prompt.
    } else if (authorization["state"]=="stale" && authorization["authority_kind"]=="task-context" && authorization["scope_state"]=="same") {
        blocker("AUTHORIZATION_STALE","authorization",authorization["receipt_ref"],authorization["action"],"refresh-exact-state-receipt")
    } else {
        blocker("HUMAN_AUTHORIZATION_REQUIRED","authorization",authorization["receipt_ref"],authorization["action"],"state=" authorization["state"])
    }

    if (required_checks==0) blocker("AMBIGUOUS","policy","required-checks","declare-required-checks","none-declared")

    print "status","code","object_kind","object_ref","head","action","detail"
    if (blockers==0) {
        print "READY","READY","pr",pr["repository"] "#" pr["pr"],pr["head_sha"],"merge","all-required-conditions-satisfied"
        exit 0
    }
    for(position=1; position<=blockers; position++) print rows[position]
    exit 1
}
' \
    "$snapshot/pr.tsv" \
    "$snapshot/checks.tsv" \
    "$snapshot/evidence.tsv" \
    "$snapshot/dependencies.tsv" \
    "$snapshot/followers.tsv" \
    "$snapshot/authorization.tsv"
