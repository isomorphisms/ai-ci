#!/bin/sh
set -eu
[ "$#" -eq 11 ] && [ "$1" = verify ] || {
    echo 'usage: merge/verify.sh verify STATE CHECKS DEPENDENCIES RECEIPTS SCOPE CONSUMER APPROVAL BLOCKERS SCHEDULES COMPLETION' >&2
    exit 2
}
shift
awk -v state_file="$1" -v checks_file="$2" -v deps_file="$3" \
    -v receipts_file="$4" -v scope_file="$5" -v consumer_file="$6" \
    -v approval_file="$7" -v blockers_file="$8" -v schedules_file="$9" \
    -v completion_file="${10}" '
BEGIN { FS="\t"; OFS="\t" }
function bad(code, detail) {
    failures++
    if (first == "") first=code
    print code, (detail=="" ? "-" : detail) > "/dev/stderr"
}
function hex(s,n) { return length(s)==n && s ~ /^[0-9A-Fa-f]+$/ }
function gitsha(s) { return hex(s,40) || hex(s,64) }
function sha256(s) { return hex(s,64) }
function posint(s) { return s ~ /^[1-9][0-9]*$/ }
function nonnegative(s) { return s ~ /^(0|[1-9][0-9]*)$/ }
function yesno(s) { return s=="yes" || s=="no" }
function token(s) { return s!="" && s !~ /[[:space:]]/ }
function optgit(s) { return s=="-" || gitsha(s) }
function optsha256(s) { return s=="-" || sha256(s) }
function member(s,list,    a,n,i) { n=split(list,a,"|"); for(i=1;i<=n;i++) if(s==a[i]) return 1; return 0 }
function required(actual, expected, code, id) { if(expected!="-" && actual!=expected) bad(code,id) }
function noncomment() { return $0 !~ /^[[:space:]]*(#|$)/ }
function reset_header() { header_seen=0; data_rows=0 }
FILENAME!=last_file { last_file=FILENAME; reset_header() }
FILENAME==state_file && noncomment() {
    if (NF!=2) { bad("MERGE-STATE-MALFORMED","expected key<TAB>value"); next }
    if (seen_state[$1]++) { bad("MERGE-STATE-MALFORMED","duplicate field " $1); next }
    st[$1]=$2
    next
}
FILENAME==approval_file && noncomment() {
    if (NF!=2) { bad("APPROVAL-MALFORMED","expected key<TAB>value"); next }
    if (seen_approval[$1]++) { bad("APPROVAL-MALFORMED","duplicate field " $1); next }
    approval[$1]=$2
    next
}
FILENAME==checks_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="workflow\tjob\tevent\trun_id\trequired\tbinding\tstatus\tconclusion\treported_head_sha\tcheckout_sha\ttested_base_sha\tbase_independent\ttrigger_coverage") bad("CHECKS-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=13 || !token($1) || !token($2) || !token($3) || !yesno($5) ||
        !yesno($12) || !yesno($13) || !member($6,"head|synthetic-merge") ||
        !member($7,"queued|in_progress|completed|missing") ||
        !member($8,"success|failure|cancelled|skipped|neutral|timed_out|action_required|stale|-") ||
        !(posint($4) || $4=="-") || !optgit($9) || !optgit($10) ||
        !optgit($11)) { bad("CHECKS-MALFORMED","invalid check row"); next }
    key=$1 SUBSEP $2 SUBSEP $3
    if (seen_check[key]++) bad("CHECKS-MALFORMED","duplicate check row")
    namekey=$2
    if (name_workflow[namekey]!="" && (name_workflow[namekey]!=$1 || name_event[namekey]!=$3)) bad("CHECK-NAME-COLLISION",$2)
    name_workflow[namekey]=$1; name_event[namekey]=$3
    if ($5=="yes") {
        required_checks++
        if ($7=="missing" || $4=="-") { bad("CHECK-MISSING",$2); next }
        if ($8=="skipped") { bad("CHECK-SKIPPED",$2); next }
        if ($8=="cancelled") { bad("CHECK-CANCELLED",$2); next }
        if ($7!="completed") { bad("CHECK-INCOMPLETE",$2); next }
        if ($8=="failure" || $8=="timed_out") { bad("CHECK-FAILED",$2); next }
        if ($8!="success") { bad("CHECK-UNKNOWN",$2); next }
        if (!member($3,"pull_request|merge_group")) bad("CHECK-WRONG-EVENT",$2)
        if ($9!=st["head_sha"]) bad("CHECK-STALE",$2)
        wanted=($6=="head" ? st["head_sha"] : st["event_sha"])
        if ($10!=wanted) bad("CHECK-WRONG-CHECKOUT",$2)
        if ($12=="no" && $11!=st["live_base_sha"]) bad("CHECK-STALE-BASE",$2)
        if ($13!="yes") bad("CHECK-TRIGGER-GAP",$2)
        if ($6=="head" && $10==st["head_sha"] && $9==st["head_sha"] &&
            ($12=="yes" || $11==st["live_base_sha"]) && $7=="completed" &&
            $8=="success" && $13=="yes") exact_head_checks++
    }
    next
}
FILENAME==deps_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="name\trepository\tpolicy\tdeclared_ref\tresolved_sha\texpected_sha") bad("DEPENDENCIES-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=6 || !member($3,"exact|moving-resolved") || !gitsha($5) || ($6!="-" && !gitsha($6))) { bad("DEPENDENCIES-MALFORMED",$1); next }
    if ($3=="exact") {
        if (!gitsha($4)) bad("DEPENDENCY-MOVING-REF",$1)
        else if ($4!=$5 || ($6!="-" && $5!=$6)) bad("DEPENDENCY-REVISION-MISMATCH",$1)
    } else if ($6!="-" && $5!=$6) bad("DEPENDENCY-REVISION-MISMATCH",$1)
    next
}
FILENAME==receipts_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="id\tresult\thead_sha\tsource_sha\tartifact_sha256\tplatform\tabi\texecution\thardware\tnetwork\tartifact_mode\tevidence_class\tprovenance\tbuild_sha\texecution_result\trequired_source_sha\trequired_artifact_sha256\trequired_platform\trequired_abi\trequired_execution\trequired_hardware\trequired_network\trequired_artifact_mode\trequired_evidence_class\trequired_provenance\trequired_build_sha\trequired_execution_result") bad("RECEIPTS-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=27 || !token($1) || !member($2,"PASS|FAIL|NOT_VERIFIED") || !gitsha($3) || !gitsha($4) || !optsha256($5) || !token($6) || !token($7) || !member($8,"none|compile|host|qemu-user|full-system|android-emulator|physical") || !member($9,"none|mock|virtual|physical") || !member($10,"none|loopback|fake-tls|external-tls") || !member($11,"none|exact-prebuilt|rebuilt") || !member($12,"host|github-runner|qemu-user|qemu-system|android-emulator|physical-phone|physical-tablet") || !member($13,"none|handwritten-oracle|compiler-generated|packaged-only|installed-artifact") || !optgit($14) || !member($15,"none|compiled|packaged|installed|launched|semantic-pass") || !optgit($16) || !optsha256($17) || !token($18) || !token($19) || !member($20,"-|none|compile|host|qemu-user|full-system|android-emulator|physical") || !member($21,"-|none|mock|virtual|physical") || !member($22,"-|none|loopback|fake-tls|external-tls") || !member($23,"-|none|exact-prebuilt|rebuilt") || !member($24,"-|host|github-runner|qemu-user|qemu-system|android-emulator|physical-phone|physical-tablet") || !member($25,"-|none|handwritten-oracle|compiler-generated|packaged-only|installed-artifact") || !optgit($26) || !member($27,"-|none|compiled|packaged|installed|launched|semantic-pass")) { bad("RECEIPTS-MALFORMED",$1); next }
    if (($11=="exact-prebuilt" || $11=="rebuilt") && $5=="-") { bad("RECEIPTS-MALFORMED",$1); next }
    if ($13=="packaged-only" && !member($15,"none|compiled|packaged")) { bad("RECEIPT-PACKAGE-AS-EXECUTION",$1); next }
    if (member($12,"physical-phone|physical-tablet") && ($8!="physical" || $9!="physical")) { bad("RECEIPT-PHYSICAL-CLASS-MISMATCH",$1); next }
    if ($12=="qemu-user" && ($8!="qemu-user" || $9!="virtual")) { bad("RECEIPT-QEMU-CLASS-MISMATCH",$1); next }
    if ($12=="qemu-system" && ($8!="full-system" || $9!="virtual")) { bad("RECEIPT-QEMU-CLASS-MISMATCH",$1); next }
    if ($12=="android-emulator" && ($8!="android-emulator" || $9!="virtual")) { bad("RECEIPT-EMULATOR-CLASS-MISMATCH",$1); next }
    if ($2=="NOT_VERIFIED") { bad("RECEIPT-NOT-VERIFIED",$1); next }
    if ($2!="PASS") { bad("RECEIPT-NOT-PASS",$1); next }
    if ($3!=st["head_sha"]) bad("RECEIPT-WRONG-HEAD",$1)
    required($4,$16,"RECEIPT-WRONG-SOURCE",$1)
    required($5,$17,"RECEIPT-WRONG-ARTIFACT",$1)
    required($6,$18,"RECEIPT-WRONG-PLATFORM",$1)
    required($7,$19,"RECEIPT-WRONG-ABI",$1)
    required($8,$20,"RECEIPT-WRONG-EXECUTION",$1)
    required($9,$21,"RECEIPT-WRONG-HARDWARE",$1)
    required($10,$22,"RECEIPT-WRONG-NETWORK",$1)
    required($11,$23,"RECEIPT-WRONG-ARTIFACT-MODE",$1)
    required($12,$24,"RECEIPT-WRONG-EVIDENCE-CLASS",$1)
    required($13,$25,"RECEIPT-WRONG-PROVENANCE",$1)
    required($14,$26,"RECEIPT-WRONG-BUILD",$1)
    required($15,$27,"RECEIPT-WRONG-EXECUTION-RESULT",$1)
    if ($23=="exact-prebuilt") { exact_id[$5]=$1; exact_source[$5]=$4; exact_needed[$5]=1 }
    next
}
FILENAME==scope_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="kind\tsubject\tprovenance") bad("SCOPE-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=3 || $2=="" || $3=="" || !member($1,"commit|file|anchor|equivalent")) { bad("SCOPE-MALFORMED",$2); next }
    if ($1=="commit" || $1=="file") {
        if ($3=="inherited") bad("SCOPE-INHERITED",$2)
        else if ($3=="unexplained") bad("SCOPE-UNEXPLAINED",$2)
        else if ($3!="intended") bad("SCOPE-MALFORMED",$2)
    } else if ($1=="anchor") {
        if ($3=="missing") bad("SCOPE-IMPLEMENTATION-MISSING",$2)
        else if ($3!="present") bad("SCOPE-MALFORMED",$2)
    } else {
        if ($3=="duplicate") bad("SCOPE-EQUIVALENT-DUPLICATE",$2)
        else if ($3!="distinct") bad("SCOPE-MALFORMED",$2)
    }
    next
}
FILENAME==consumer_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="artifact_sha256\tsource_sha\taction\toutcome") bad("RUNTIME-CONSUMER-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=4 || !sha256($1) || !gitsha($2) || !member($3,"verify|execute|rebuild|substitute") || !member($4,"pass|fail|attempted")) { bad("RUNTIME-CONSUMER-MALFORMED",$1); next }
    if (!($1 in exact_needed)) { bad("RUNTIME-ARTIFACT-SUBSTITUTION",$1); next }
    if ($2!=exact_source[$1]) bad("RUNTIME-SOURCE-MISMATCH",exact_id[$1])
    if ($3=="rebuild") bad("RUNTIME-REBUILD-FALLBACK",exact_id[$1])
    else if ($3=="substitute") bad("RUNTIME-ARTIFACT-SUBSTITUTION",exact_id[$1])
    else if ($3=="verify" && $4=="pass") verified[$1]=1
    else if ($3=="execute" && $4=="pass") executed[$1]=1
    next
}
FILENAME==blockers_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="id\tstate\tevidence") bad("BLOCKERS-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=3 || !token($1) || !member($2,"OPEN|RESOLVED|WITHDRAWN") || $3=="") { bad("BLOCKERS-MALFORMED",$1); next }
    if (seen_blocker[$1]++) { bad("BLOCKERS-MALFORMED","duplicate blocker " $1); next }
    if ($2=="OPEN") bad("BLOCKER-OPEN",$1)
    next
}
FILENAME==schedules_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="workflow\tclaim\trequired\tdefault_branch\tschedule_trigger\tlast_run_state\tlast_run_id") bad("SCHEDULES-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=7 || !token($1) || !member($2,"planned|configured|operating") || !yesno($3) || !yesno($4) || !yesno($5) || !member($6,"PASS|FAIL|CANCELLED|SKIPPED|ABSENT|STALE|UNKNOWN|NEVER_RUN") || !(posint($7) || $7=="-")) { bad("SCHEDULES-MALFORMED",$1); next }
    if (seen_schedule[$1]++) { bad("SCHEDULES-MALFORMED","duplicate workflow " $1); next }
    if ($2!="planned" && $4!="yes") bad("SCHEDULE-NOT-ON-DEFAULT",$1)
    if ($2!="planned" && $5!="yes") bad("SCHEDULE-TRIGGER-ABSENT",$1)
    if ($2=="operating" && ($6=="NEVER_RUN" || $7=="-")) bad("SCHEDULE-NEVER-RAN",$1)
    if ($3=="yes" && ($2!="operating" || $6!="PASS" || $7=="-")) bad("SCHEDULE-NOT-PASS",$1)
    next
}
FILENAME==completion_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="step\tphase\trequired\tstate\tevidence") bad("COMPLETION-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=5 || !token($1) || !member($2,"plan|audit|implementation|verification|merge|cleanup") || !yesno($3) || !member($4,"PENDING|BLOCKED|FAILED|COMPLETE") || $5=="") { bad("COMPLETION-MALFORMED",$1); next }
    if (seen_completion[$1]++) { bad("COMPLETION-MALFORMED","duplicate step " $1); next }
    if ($3=="yes") {
        required_steps++
        if ($2=="implementation") required_implementation++
        if ($4=="PENDING") bad("COMPLETION-PENDING",$1)
        else if ($4=="BLOCKED") bad("COMPLETION-BLOCKED",$1)
        else if ($4=="FAILED") bad("COMPLETION-FAILED",$1)
    }
    next
}
END {
    if (st["schema"]!="aici-merge-state-v4" || st["repository"]=="" ||
        !posint(st["pr"]) || st["title"]=="" || !gitsha(st["head_sha"]) ||
        !gitsha(st["event_sha"]) || !member(st["event_kind"],"head|synthetic-merge") ||
        st["live_base_ref"]=="" || !gitsha(st["live_base_sha"]) ||
        !gitsha(st["reported_base_sha"]) || !gitsha(st["merge_base_sha"]) ||
        !gitsha(st["scope_base_sha"]) || !sha256(st["prospective_diff_sha256"]) ||
        !sha256(st["changed_paths_sha256"]) || !sha256(st["intent_sha256"]) ||
        !sha256(st["current_scope_sha256"]) || !posint(st["diff_files"]) ||
        !nonnegative(st["diff_additions"]) || !nonnegative(st["diff_deletions"]) ||
        !yesno(st["draft"]) || !member(st["mergeable"],"yes|no|unknown") ||
        !member(st["job_kind"],"execution|advisory") ||
        !member(st["job_state"],"PENDING|BLOCKED|FAILED|COMPLETE") ||
        st["stack_parent_pr"]=="" || !member(st["stack_parent_state"],"none|open|landed") ||
        st["stack_parent_expected_sha"]=="" || st["stack_parent_current_sha"]=="")
        bad("MERGE-STATE-MALFORMED","missing or invalid required field")
    if (approval["schema"]!="aici-merge-approval-v3" || approval["repository"]=="" ||
        !posint(approval["pr"]) || approval["title"]=="" || !gitsha(approval["head_sha"]) ||
        approval["base_ref"]=="" || !gitsha(approval["base_sha"]) ||
        !sha256(approval["prospective_diff_sha256"]) || !sha256(approval["changed_paths_sha256"]) ||
        !sha256(approval["intent_sha256"]) || approval["decision"]=="" ||
        approval["authorization_kind"]=="" || !sha256(approval["authorization_text_sha256"]) ||
        !token(approval["authorized_by"]) ||
        !member(approval["authority_actor_kind"],"human|assistant|automation") ||
        !member(approval["authority_source_kind"],"human-message|human-task|github-review") ||
        !token(approval["authority_source_id"]) ||
        !member(approval["authority_source_role"],"merge-instruction|conditional-merge-task|merge-authorizing-task|github-approval|acknowledgement|implementation-instruction") ||
        !token(approval["authority_context_ref"]) || !sha256(approval["authority_context_sha256"]) ||
        !member(approval["authority_context_state"],"recovered|missing|unknown") ||
        approval["authority_classifier_repository"]!="isomorphisms/cockswain" ||
        !gitsha(approval["authority_classifier_revision"]) ||
        !sha256(approval["authority_classifier_contract_sha256"]) ||
        !sha256(approval["authority_scope_sha256"]) ||
        !member(approval["authority_scope_state"],"same|changed|unknown") ||
        !member(approval["revocation_state"],"none|revoked|unknown") ||
        approval["unresolved_objections"]=="")
        bad("APPROVAL-MALFORMED","missing or invalid required field")
    if (approval["decision"]!="MERGE" || !member(approval["authorization_kind"],"explicit-merge|conditional-clean|github-approval|task-context")) bad("APPROVAL-NOT-AUTHORIZED",approval["authorization_kind"])
    if (approval["authority_actor_kind"]!="human") bad("APPROVAL-SOURCE-NOT-HUMAN",approval["authority_actor_kind"])
    if (member(approval["authority_source_role"],"acknowledgement|implementation-instruction")) bad("APPROVAL-SOURCE-NOT-AUTHORITY",approval["authority_source_role"])
    if (approval["authorization_kind"]=="explicit-merge" && !(approval["authority_source_kind"]=="human-message" && approval["authority_source_role"]=="merge-instruction")) bad("APPROVAL-SOURCE-MISMATCH",approval["authorization_kind"])
    if (approval["authorization_kind"]=="conditional-clean" && !(member(approval["authority_source_kind"],"human-message|human-task") && approval["authority_source_role"]=="conditional-merge-task")) bad("APPROVAL-SOURCE-MISMATCH",approval["authorization_kind"])
    if (approval["authorization_kind"]=="task-context" && !(approval["authority_source_kind"]=="human-task" && approval["authority_source_role"]=="merge-authorizing-task")) bad("APPROVAL-SOURCE-MISMATCH",approval["authorization_kind"])
    if (approval["authorization_kind"]=="github-approval" && !(approval["authority_source_kind"]=="github-review" && approval["authority_source_role"]=="github-approval")) bad("APPROVAL-SOURCE-MISMATCH",approval["authorization_kind"])
    if (approval["authority_context_state"]!="recovered") bad("APPROVAL-CONTEXT-MISSING",approval["authority_context_state"])
    if (approval["authority_scope_state"]!="same" || approval["authority_scope_sha256"]!=st["current_scope_sha256"]) bad("APPROVAL-SCOPE-CHANGED",approval["authority_scope_state"])
    if (approval["revocation_state"]!="none") bad("APPROVAL-REVOKED",approval["revocation_state"])
    if (approval["unresolved_objections"]!="none") bad("APPROVAL-OBJECTION-OPEN",approval["unresolved_objections"])
    if (approval["repository"]!=st["repository"] || approval["pr"]!=st["pr"] || approval["title"]!=st["title"]) bad("APPROVAL-WRONG-PR","approval identity differs from merge state")
    if (approval["head_sha"]!=st["head_sha"]) bad("APPROVAL-WRONG-HEAD",approval["head_sha"])
    if (approval["base_ref"]!=st["live_base_ref"] || approval["base_sha"]!=st["live_base_sha"]) bad("APPROVAL-WRONG-BASE",approval["base_ref"])
    if (approval["prospective_diff_sha256"]!=st["prospective_diff_sha256"]) bad("APPROVAL-WRONG-DIFF",approval["prospective_diff_sha256"])
    if (approval["changed_paths_sha256"]!=st["changed_paths_sha256"]) bad("APPROVAL-WRONG-PATHS",approval["changed_paths_sha256"])
    if (approval["intent_sha256"]!=st["intent_sha256"]) bad("APPROVAL-WRONG-INTENT",approval["intent_sha256"])
    if (st["draft"]=="yes") bad("PR-DRAFT","mark ready before merge")
    if (st["mergeable"]=="no") bad("PR-NOT-MERGEABLE","GitHub reports the PR cannot merge")
    if (st["mergeable"]=="unknown") bad("PR-MERGEABILITY-UNKNOWN","refresh live mergeability")
    if (st["event_kind"]=="head" && st["event_sha"]!=st["head_sha"]) bad("MERGE-SYNTHETIC-AS-HEAD","event labeled head differs from PR head")
    if (st["event_kind"]=="synthetic-merge" && st["event_sha"]==st["head_sha"]) bad("MERGE-STATE-MALFORMED","synthetic merge equals head")
    if (st["stack_parent_state"]=="none") {
        if (st["stack_parent_pr"]!="-" || st["stack_parent_expected_sha"]!="-" || st["stack_parent_current_sha"]!="-") bad("MERGE-STATE-MALFORMED","standalone carries parent")
        if (st["scope_base_sha"]!=st["live_base_sha"]) bad("TOPOLOGY-STALE-SCOPE-BASE","scope base is not live base")
    } else {
        if (!posint(st["stack_parent_pr"]) || !gitsha(st["stack_parent_expected_sha"]) || !gitsha(st["stack_parent_current_sha"])) bad("MERGE-STATE-MALFORMED","invalid stack parent")
        else if (st["stack_parent_expected_sha"]!=st["stack_parent_current_sha"]) bad("STACK-PARENT-MOVED","parent moved")
        if (st["stack_parent_state"]=="open") {
            if (st["scope_base_sha"]!=st["stack_parent_current_sha"]) bad("TOPOLOGY-STALE-SCOPE-BASE","child scope not current parent")
            bad("STACK-PARENT-OPEN","merge parent first")
        } else bad("STACK-RETARGET-REQUIRED","landed parent requires reconciliation")
    }
    if (st["merge_base_sha"]!=st["scope_base_sha"]) bad("TOPOLOGY-BASE-DRIFT","merge-base differs from intended scope base")
    if (st["job_state"]!="COMPLETE") bad("JOB-INCOMPLETE",st["job_state"])
    if (required_steps==0) bad("COMPLETION-MALFORMED","no required steps declared")
    if (st["job_kind"]=="execution" && required_implementation==0) bad("EXECUTION-NOT-IMPLEMENTED","no required implementation step")
    if (required_checks==0) bad("CHECK-MISSING","no required checks declared")
    if (exact_head_checks==0) bad("CHECK-EXACT-HEAD-MISSING","no required exact-head check")
    for (a in exact_needed) if (!verified[a] || !executed[a]) bad("RUNTIME-EXACT-ARTIFACT-NOT-EXECUTED",exact_id[a])
    if (failures) {
        print "FAIL\tMERGE-AUTHORIZATION\tfirst=" first "\tfailures=" failures > "/dev/stderr"
        exit 1
    }
    print "PASS\tMERGE-AUTHORIZATION\trepository=" st["repository"] "\tpr=" st["pr"] "\thead=" st["head_sha"] "\tbase=" st["live_base_sha"] "\tdiff=" st["prospective_diff_sha256"] "\tchecks=exact\treceipts=bound\tauthorization=" approval["authorization_kind"]
}
' "$@"
