#!/bin/sh
set -eu

[ "$#" -eq 1 ] || {
    echo 'usage: merge/pr-verdict.sh SNAPSHOT_DIRECTORY' >&2
    exit 2
}

snapshot=$1
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for required_file in \
    state.tsv checks.tsv dependencies.tsv receipts.tsv scope.tsv consumer.tsv approval.tsv
do
    test -f "$snapshot/$required_file" || {
        printf 'FAIL\tMERGE-AUTHORIZATION\tmissing=%s\n' "$required_file" >&2
        exit 1
    }
done

exec sh "$script_directory/verify.sh" verify \
    "$snapshot/state.tsv" \
    "$snapshot/checks.tsv" \
    "$snapshot/dependencies.tsv" \
    "$snapshot/receipts.tsv" \
    "$snapshot/scope.tsv" \
    "$snapshot/consumer.tsv" \
    "$snapshot/approval.tsv"
