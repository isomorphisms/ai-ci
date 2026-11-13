#!/bin/sh
# Fault-inject receipts produced by actual test execution, not synthetic PASS
# strings alone. Verify that the admission mechanism rejects each bad case.
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)
observations=${1:?Pass the actual independent AICI receipt directory}
sut=${2:?Immutable Holomorphic source revision required}
aici=${3:?Immutable AICI verifier revision required}
compiler=${4:?Immutable ICK compiler revision required}
case_manifest="$root/tests/semantic-oracles/holomorphic-t1/cases.tsv"
validator="$root/validators/verify_semantic_mutants.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM

verify() {
    sh "$validator" "$case_manifest" "$1" "$sut" "$aici" \
        hand-derived-six-values fixed-six host-CPU-not-GPU-or-device "$compiler"
}
verify "$observations" > "$scratch/positive.log"
grep -Fq 'AICI-SEMANTIC-RECEIPT-ACCEPTED' "$scratch/positive.log" || {
    echo "AICI-POSITIVE-RECEIPT-MISSING-OBSERVATION" >&2
    exit 1
}

reject_bad() {
    label=$1
    path="$scratch/$label"
    if verify "$path" > "$scratch/$label.log" 2>&1; then
        echo "AICI-META-FALSE-ACCEPT case=$label" >&2
        exit 1
    fi
    if ! grep -Eq 'AICI-(SEMANTIC|MISSING|ORIGINAL|TEST|INVALID)' "$scratch/$label.log"; then
        echo "AICI-META-UNEXPLAINED-REJECTION case=$label" >&2
        cat "$scratch/$label.log" >&2
        exit 1
    fi
    printf 'AICI-META-KILLED case=%s\n' "$label"
}
fresh() {
    label=$1
    cp -R "$observations" "$scratch/$label"
}
tab=$(printf '\t')
fresh omitted-case
awk -F "$tab" '$1 != "omit-fifth"' "$scratch/omitted-case/aici-holomorphic-t1.tsv" > "$scratch/omitted-case/temp.tsv"
mv "$scratch/omitted-case/temp.tsv" "$scratch/omitted-case/aici-holomorphic-t1.tsv"
reject_bad omitted-case

fresh surviving-mutant
awk -F "$tab" 'BEGIN{OFS="\t"} $1=="scale-half" {$8="PASS"} {print}' \
    "$scratch/surviving-mutant/aici-holomorphic-t1.tsv" > "$scratch/surviving-mutant/temp.tsv"
mv "$scratch/surviving-mutant/temp.tsv" "$scratch/surviving-mutant/aici-holomorphic-t1.tsv"
reject_bad surviving-mutant

fresh skipped-mutant
awk -F "$tab" 'BEGIN{OFS="\t"} $1=="scale-half" {$8="SKIPPED"} {print}' \
    "$scratch/skipped-mutant/aici-holomorphic-t1.tsv" > "$scratch/skipped-mutant/temp.tsv"
mv "$scratch/skipped-mutant/temp.tsv" "$scratch/skipped-mutant/aici-holomorphic-t1.tsv"
reject_bad skipped-mutant

fresh stale-source
awk -F "$tab" 'BEGIN{OFS="\t"} $1=="good" {$2="0000000000000000000000000000000000000000"} {print}' \
    "$scratch/stale-source/aici-holomorphic-t1.tsv" > "$scratch/stale-source/temp.tsv"
mv "$scratch/stale-source/temp.tsv" "$scratch/stale-source/aici-holomorphic-t1.tsv"
reject_bad stale-source

fresh wrong-selected-test
awk -F "$tab" 'BEGIN{OFS="\t"} $1=="good" {$6="unrelated-semantic"} {print}' \
    "$scratch/wrong-selected-test/aici-holomorphic-t1.tsv" > "$scratch/wrong-selected-test/temp.tsv"
mv "$scratch/wrong-selected-test/temp.tsv" "$scratch/wrong-selected-test/aici-holomorphic-t1.tsv"
reject_bad wrong-selected-test

fresh missing-log
rm "$scratch/missing-log/omit-fifth-semantic.log"
reject_bad missing-log

fresh copied-passing-log
cp "$scratch/copied-passing-log/good-semantic.log" \
   "$scratch/copied-passing-log/reverse-coefficients-semantic.log"
reject_bad copied-passing-log

fresh candidate-changed
printf '\n/* corruption after receipt emission */\n' \
    >> "$scratch/candidate-changed/derivative-degree-candidate.c"
reject_bad candidate-changed
fresh executable-changed
printf 'BAD-AFTER-RECEIPT\n' >> "$scratch/executable-changed/good-semantic.bin"
reject_bad executable-changed

fresh duplicate-case
grep -F 'scale-half' "$observations/aici-holomorphic-t1.tsv" \
    >> "$scratch/duplicate-case/aici-holomorphic-t1.tsv"
reject_bad duplicate-case

fresh empty-cases
head -n 1 "$scratch/empty-cases/aici-holomorphic-t1.tsv" \
    > "$scratch/empty-cases/temp.tsv"
mv "$scratch/empty-cases/temp.tsv" "$scratch/empty-cases/aici-holomorphic-t1.tsv"
reject_bad empty-cases

fresh wrong-compiler-revision
awk -F "$tab" 'BEGIN{OFS="\t"} $1=="good" {$12="0000000000000000000000000000000000000000"} {print}' \
    "$scratch/wrong-compiler-revision/aici-holomorphic-t1.tsv" > "$scratch/wrong-compiler-revision/temp.tsv"
mv "$scratch/wrong-compiler-revision/temp.tsv" "$scratch/wrong-compiler-revision/aici-holomorphic-t1.tsv"
reject_bad wrong-compiler-revision

fresh malformed-compiler-digest
awk -F "$tab" 'BEGIN{OFS="\t"} $1=="good" {$13="not-a-sha256"} {print}' \
    "$scratch/malformed-compiler-digest/aici-holomorphic-t1.tsv" > "$scratch/malformed-compiler-digest/temp.tsv"
mv "$scratch/malformed-compiler-digest/temp.tsv" "$scratch/malformed-compiler-digest/aici-holomorphic-t1.tsv"
reject_bad malformed-compiler-digest

printf 'AICI-META-ACCEPTANCE valid=1 invalid-rejected=13 invalid-accepted=0\n'
