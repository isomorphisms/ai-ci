#!/bin/sh
# AICI: inspect execution-produced semantic receipts independently of the
# implementation under test and its test generator.
#
# This gate checks identities, completeness, log presence, and declared
# good/bad control sensitivity. It does NOT certify oracle soundness, prove
# unforgeability of local files, or replace running an independent evaluator.
set -eu
if [ "$#" -ne 7 ]; then
    echo "usage: $0 cases.tsv receipt-directory exact-sut-sha exact-aici-sha oracle-id seed evidence-boundary" >&2
    exit 2
fi
case_manifest=$1
receipt_dir=$2
expected_sut=$3
expected_aici=$4
expected_oracle=$5
expected_seed=$6
expected_layer=$7
receipt="$receipt_dir/aici-holomorphic-t1.tsv"
for required in "$case_manifest" "$receipt"; do
    if [ ! -s "$required" ]; then
        echo "AICI-SEMANTIC-EVIDENCE-ABSENT path=$required" >&2
        exit 1
    fi
done
LC_ALL=C
export LC_ALL
# Malformed or truncated immutable identity arguments block before interpreting
# any report. sha256 is for identity only, not mathematical truth.
for revision in "$expected_sut" "$expected_aici"; do
    case "$revision" in
        *[!0123456789abcdef]*|'') echo "AICI-INVALID-REVISION" >&2; exit 1 ;;
    esac
    if [ "${#revision}" -ne 40 ]; then
        echo "AICI-INVALID-REVISION-LENGTH" >&2
        exit 1
    fi
done

awk -F '\t' -v sut="$expected_sut" -v aici="$expected_aici" \
    -v oracle="$expected_oracle" -v seed="$expected_seed" \
    -v layer="$expected_layer" '
    function bad(message) {
        print "AICI-SEMANTIC-RECEIPT-REJECT " message > "/dev/stderr"
        errors++
    }
    FILENAME == ARGV[1] {
        if (FNR == 1) {
            if ($0 != "case_id\trole\texpected_result") bad("manifest-header")
            next
        }
        if (NF != 3) { bad("manifest-column-count"); next }
        if ($1 !~ /^[A-Za-z0-9][A-Za-z0-9._-]*$/) bad("manifest-case-identity")
        if ($2 != "control" && $2 != "mutant") bad("manifest-role")
        if (($2 == "control" && $3 != "PASS") || ($2 == "mutant" && $3 != "KILLED")) bad("manifest-expected")
        if ($1 in cases) bad("duplicate-manifest-id " $1)
        cases[$1] = $3
        if ($2 == "control") controls++
        if ($2 == "mutant") mutants++
        next
    }
    FILENAME == ARGV[2] {
        if (FNR == 1) {
            if ($0 != "case_id\tsut_revision\taici_revision\tcandidate_sha256\tcandidate_test\toriginal_smoke\tsemantic_result\toracle\tseed\tevidence_boundary")
                bad("receipt-header")
            next
        }
        if (NF != 10) { bad("receipt-column-count"); next }
        if (!($1 in cases)) bad("extra-case " $1)
        if (++observed[$1] != 1) bad("duplicate-case " $1)
        if ($2 != sut || $3 != aici) bad("stale-or-wrong-source " $1)
        if (length($4) != 64 || $4 !~ /^[0-9a-f]+$/) bad("invalid-candidate-digest " $1)
        if ($5 != $1 "-semantic") bad("wrong-test-selected " $1)
        if ($6 != "PASS") bad("original-smoke-not-observed " $1)
        if ($7 != cases[$1]) bad("surviving-or-wrong-mutant " $1)
        if ($8 != oracle || $9 != seed || $10 != layer) bad("wrong-oracle-seed-or-target " $1)
        total++
        next
    }
    END {
        if (controls < 1 || mutants < 1) bad("missing-good-or-bad-controls")
        if (total == 0) bad("empty-execution")
        for (id in cases) {
            if (observed[id] != 1) bad("missing-declared-case " id)
        }
        if (errors) exit 1
        print "AICI-SEMANTIC-RECEIPT-STRUCTURE-PASS control=" controls " mutants=" mutants " observed=" total
    }
    ' "$case_manifest" "$receipt"

tab=$(printf '\t')
while IFS="$tab" read -r case_id role expected; do
    if [ "$case_id" = case_id ]; then continue; fi
    candidate="$receipt_dir/$case_id-candidate.c"
    executable="$receipt_dir/$case_id-semantic.bin"
    smoke_log="$receipt_dir/$case_id-smoke.log"
    semantic_log="$receipt_dir/$case_id-semantic.log"
    for file in "$candidate" "$executable" "$smoke_log" "$semantic_log"; do
        if [ ! -s "$file" ]; then
            echo "AICI-MISSING-EXECUTION-ARTIFACT case=$case_id path=$file" >&2
            exit 1
        fi
    done
    if [ ! -x "$executable" ]; then
        echo "AICI-TEST-EXECUTABLE-ABSENT case=$case_id" >&2
        exit 1
    fi
    expected_digest=$(awk -F "$tab" -v wanted="$case_id" '$1 == wanted {print $4}' "$receipt")
    actual_digest=$(sha256sum "$candidate" | cut -d ' ' -f 1)
    if [ "$actual_digest" != "$expected_digest" ]; then
        echo "AICI-SEMANTIC-CANDIDATE-DRIFT case=$case_id" >&2
        exit 1
    fi
    if ! grep -Fq 'holomorphic workers ready:' "$smoke_log"; then
        echo "AICI-ORIGINAL-SMOKE-LOG-ABSENT case=$case_id" >&2
        exit 1
    fi
    if [ "$expected" = PASS ]; then
        if ! grep -Fq 'AICI-SEMANTIC-PASS cases=6' "$semantic_log" ||
            grep -Fq 'AICI-SEMANTIC-MISMATCH case=' "$semantic_log"; then
            echo "AICI-VALID-CONTROL-NOT-OBSERVED case=$case_id" >&2
            exit 1
        fi
    else
        if ! grep -Fq 'AICI-SEMANTIC-MISMATCH case=' "$semantic_log" ||
            grep -Fq 'AICI-SEMANTIC-PASS cases=6' "$semantic_log"; then
            echo "AICI-MUTANT-FAILURE-NOT-SEMANTIC case=$case_id" >&2
            exit 1
        fi
    fi
done < "$case_manifest"
printf 'AICI-SEMANTIC-RECEIPT-ACCEPTED cases=6 source=%s oracle=%s layer=%s\n' \
    "$expected_sut" "$expected_oracle" "$expected_layer"
