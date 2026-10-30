#!/bin/sh
# Run after the independent oracle passes on actual source-bound runner output.
set -eu
[ "$#" -eq 2 ] || { echo "usage: mutation-test.sh RECEIPT_DIR FP_CHECKOUT" >&2; exit 2; }
root=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
receipt_root=$1
fp_root=$2
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
checker=$root/check-receipts.sh
sh "$checker" "$receipt_root" "$fp_root" >/dev/null

copy_source() {
    rm -rf "$tmp/receipts"
    cp -R "$receipt_root" "$tmp/receipts"
    dir=
    for r in "$tmp/receipts/link-good"/amazon-product-lookup-*; do
        [ -d "$r" ] || { echo "missing link-good fixture" >&2; exit 1; }
        dir=$r
    done
    out=$dir/01-product-lookup/stdout.bin
    json=$dir/receipt.json
}
must_reject() {
    label=$1
    if sh "$checker" "$tmp/receipts" "$fp_root" >"$tmp/check.out" 2>"$tmp/check.err"; then
        echo "ai-ci Amazon oracle accepted mutant: $label" >&2
        exit 1
    fi
    grep -F "ai-ci Amazon receipt FAIL:" "$tmp/check.err" >/dev/null || {
        echo "mutation $label failed without an oracle diagnostic" >&2
        cat "$tmp/check.err" >&2
        exit 1
    }
}
patch_value() {
    key=$1
    value=$2
    awk -F '\t' -v key="$key" -v value="$value" \
        'BEGIN { OFS="\t" } $1==key {$2=value} {print}' "$out" >"$tmp/altered"
    mv "$tmp/altered" "$out"
    sha=$(sha256sum "$out" | awk '{print $1}')
    jq --arg sha "$sha" '.stages[0].stdout_sha256 = $sha' "$json" >"$tmp/rewrite.json"
    mv "$tmp/rewrite.json" "$json"
}
copy_source
printf 'tampered\n' >>"$out"
must_reject 'raw output hash mismatch'
copy_source
patch_value status QUALIFIED
must_reject 'fabricated QUALIFIED with recomputed hashes'
copy_source
patch_value availability AVAILABLE
must_reject 'fabricated in-stock status with recomputed hashes'
copy_source
patch_value price 19.99
must_reject 'invented price with recomputed hashes'
copy_source
patch_value product_role interior-moisture-barrier
must_reject 'wrong use despite recalculated hash'
copy_source
patch_value affiliate_link 'https://www.amazon.com/dp/B000PEZ1L4?tag=macguyver03-20'
must_reject 'mismatched ASIN despite recalculated hash'
copy_source
jq '.repository_commit = "0000000000000000000000000000000000000000"' "$json" >"$tmp/rewrite.json"
mv "$tmp/rewrite.json" "$json"
must_reject 'claimed source identity swap'
copy_source
jq '.status = "FAIL" | .stages[0].exit_code = 2' "$json" >"$tmp/rewrite.json"
mv "$tmp/rewrite.json" "$json"
must_reject 'claimed success/failure inversion'
printf 'ai-ci Amazon independent mutation rejection: PASS (eight adversarial controls)\n'
