#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 VERIFIER" >&2
    exit 2
fi

verifier=$1
root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
fixtures="$root/fixtures"
identity='fixture:ikfile-v1'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

"$verifier" verify "$fixtures/good.tsv" "$identity"

check_bad()
{
    name=$1
    diagnostic=$2
    if "$verifier" verify "$fixtures/$name" "$identity" \
        >"$tmp/$name.out" 2>"$tmp/$name.err"; then
        echo "expected $name to fail" >&2
        exit 1
    fi
    grep -Fqx "aici-ike-receipt: $diagnostic" "$tmp/$name.err"
}

check_bad bad-target.tsv 'selected target mismatch'
check_bad bad-identity.tsv 'Ikefile identity mismatch'
check_bad bad-runner.tsv 'recipe runner identity mismatch'
check_bad bad-recipe.tsv 'compile recipe mismatch'
check_bad bad-recipe-status.tsv 'compile recipe mismatch'
check_bad bad-final.tsv 'final result mismatch'
check_bad bad-truncated.tsv 'compile rule mismatch'
