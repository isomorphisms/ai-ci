#!/bin/sh
set -eu
[ "$#" -eq 7 ] && [ "$1" = verify ] || {
    echo 'usage: merge/verify.sh verify STATE CHECKS DEPENDENCIES RECEIPTS SCOPE CONSUMER' >&2
    exit 2
}
shift
awk -v state_file="$1" -v checks_file="$2" -v deps_file="$3" \
    -v receipts_file="$4" -v scope_file="$5" -v consumer_file="$6" '
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
FILENAME==checks_file && noncomment() {
    if (!header_seen) {
        header_seen=1
        if ($0!="workflow\tjob\tevent\trun_id\trequired\tbinding\tstatus\tconclusion\treported_head_sha\tcheckout_sha\ttrigger_coverage") bad("CHECKS-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=11 || !token($1) || !token($2) || !token($3) || !yesno($5) || !yesno($11) || !member($6,"head|synthetic-merge") || !member($7,"queued|in_progress|completed|missing") || !member($8,"success|failure|cancelled|skipped|neutral|timed_out|action_required|stale|-") || !(posint($4) || $4=="-") || !optgit($9) || !optgit($10)) { bad("CHECKS-MALFORMED","invalid check row"); next }
    key=$1 SUBSEP $2 SUBSEP $3
    if (seen_check[key]++) bad("CHECKS-MALFORMED","duplicate check row")
    namekey=$2
    if (name_workflow[namekey]!="" && (name_workflow[namekey]!=$1 || name_event[namekey]!=$3)) bad("CHECK-NAME-COLLISION",$2)
    name_workflow[namekey]=$1; name_event[namekey]=$3
    if ($5=="yes") {
        required_checks++
        if ($7=="missing" || $4=="-") { bad("CHECK-MISSING",$2); next }
        if ($8=="skipped") { bad("CHECK-SKIPPED",$2); next }
        if ($7!="completed") { bad("CHECK-INCOMPLETE",$2); next }
        if ($8!="success") { bad("CHECK-NOT-PASS",$2); next }
        if (!member($3,"pull_request|merge_group")) bad("CHECK-WRONG-EVENT",$2)
        if ($9!=st["head_sha"]) bad("CHECK-WRONG-HEAD",$2)
        wanted=($6=="head" ? st["head_sha"] : st["event_sha"])
        if ($10!=wanted) bad("CHECK-WRONG-CHECKOUT",$2)
        if ($11!="yes") bad("CHECK-TRIGGER-GAP",$2)
        if ($6=="head" && $10==st["head_sha"] && $9==st["head_sha"] && $7=="completed" && $8=="success" && $11=="yes") exact_head_checks++
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
        if ($0!="id\tresult\thead_sha\tsource_sha\tartifact_sha256\tplatform\tabi\texecution\thardware\tnetwork\tartifact_mode\trequired_source_sha\trequired_artifact_sha256\trequired_platform\trequired_abi\trequired_execution\trequired_hardware\trequired_network\trequired_artifact_mode") bad("RECEIPTS-MALFORMED","wrong header")
        next
    }
    data_rows++
    if (NF!=19 || !token($1) || !member($2,"PASS|FAIL|UNKNOWN") || !gitsha($3) || !gitsha($4) || !optsha256($5) || !token($6) || !token($7) || !member($8,"none|compile|host|qemu-user|full-system|android-emulator|physical") || !member($9,"none|mock|virtual|physical") || !member($10,"none|loopback|fake-tls|external-tls") || !member($11,"none|exact-prebuilt|rebuilt") || !optgit($12) || !optsha256($13) || !token($14) || !token($15) || !member($16,"-|none|compile|host|qemu-user|full-system|android-emulator|physical") || !member($17,"-|none|mock|virtual|physical") || !member($18,"-|none|loopback|fake-tls|external-tls") || !member($19,"-|none|exact-prebuilt|rebuilt")) { bad("RECEIPTS-MALFORMED",$1); next }
    if (($11=="exact-prebuilt" || $11=="rebuilt") && $5=="-") { bad("RECEIPTS-MALFORMED",$1); next }
    if ($2=="UNKNOWN") { bad("RECEIPT-UNKNOWN",$1); next }
    if ($2!="PASS") { bad("RECEIPT-NOT-PASS",$1); next }
    if ($3!=st["head_sha"]) bad("RECEIPT-WRONG-HEAD",$1)
    required($4,$12,"RECEIPT-WRONG-SOURCE",$1)
    required($5,$13,"RECEIPT-WRONG-ARTIFACT",$1)
    required($6,$14,"RECEIPT-WRONG-PLATFORM",$1)
    required($7,$15,"RECEIPT-WRONG-ABI",$1)
    required($8,$16,"RECEIPT-WRONG-EXECUTION",$1)
    required($9,$17,"RECEIPT-WRONG-HARDWARE",$1)
    required($10,$18,"RECEIPT-WRONG-NETWORK",$1)
    required($11,$19,"RECEIPT-WRONG-ARTIFACT-MODE",$1)
    if ($19=="exact-prebuilt" && $13!="-") { exact_id[$13]=$1; exact_source[$13]=$4; exact_needed[$13]=1 }
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
END {
    if (st["schema"]!="aici-merge-state-v1" || st["repository"]=="" || !posint(st["pr"]) || st["title"]=="" || !gitsha(st["head_sha"]) || !gitsha(st["event_sha"]) || !member(st["event_kind"],"head|synthetic-merge") || st["live_base_ref"]=="" || !gitsha(st["live_base_sha"]) || !gitsha(st["reported_base_sha"]) || !gitsha(st["merge_base_sha"]) || !gitsha(st["scope_base_sha"]) || st["stack_parent_pr"]=="" || !member(st["stack_parent_state"],"none|open|landed") || st["stack_parent_expected_sha"]=="" || st["stack_parent_current_sha"]=="") bad("MERGE-STATE-MALFORMED","missing or invalid required field")
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
    if (required_checks==0) bad("CHECK-MISSING","no required checks declared")
    if (exact_head_checks==0) bad("CHECK-EXACT-HEAD-MISSING","no required exact-head check")
    for (a in exact_needed) if (!verified[a] || !executed[a]) bad("RUNTIME-EXACT-ARTIFACT-NOT-EXECUTED",exact_id[a])
    if (failures) {
        print "FAIL\tMERGE-AUTHORIZATION\tfirst=" first "\tfailures=" failures > "/dev/stderr"
        exit 1
    }
    print "PASS\tMERGE-AUTHORIZATION\thead=" st["head_sha"] "\tbase=" st["live_base_sha"] "\tchecks=exact\treceipts=bound"
}
' "$@"
